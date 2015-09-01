SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting_07] 
    @SuperID			INT	= 0,
    @MasterID			INT = 0,
    @AgentID			INT = 0,
    @RoleID				INT	= 0,
    @SportBetTypeXML	NVARCHAR(MAX) = '' 
AS
/*
    Created: Dominic
    Date: 20150831
    Task: Use Execrep to correct member PT setting values(Dynamic Customer Setting)
    DB: DBCUST/CustDB
    Original versions: Acc_CustSetting3rd_07                
    Revision:

    Parameter's Explanation:
		- @SportBetTypeXML
						<ROOT>
							<PT SportType="180" BetType="1201" IsLive="0" />
							<PT SportType="181" BetType="1202" IsLive="0" />
							<PT SportType="183" BetType="1203" IsLive="0" />
						</ROOT>
*/ 
BEGIN
    SET NOCOUNT ON
--******************************************CHECK EXISTING TABLES*****************************************************    
    IF dbo.f_CheckRepTable('custinfo') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN  
    IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN             

--******************************************VARIABLE DECLARATION****************************************************** 
	--Line info 
	DECLARE @_SuperID INT, @_MasterID INT, @_AgentID INT, @_RoleID  INT
	
	--Affected sport/bettype/islive
	DECLARE @_SportBetTypeTbl TABLE (
					SportType		SMALLINT,
					BetType			SMALLINT,
					IsLive			BIT
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
	
	--Super PT Setting Values		
	DECLARE @_SuperPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S4				TINYINT  ,
					M4				TINYINT  ,
					A4				TINYINT  ,
					IM4				BIT  ,
					UM4				TINYINT  ,
					IS4				BIT  ,
					US4				TINYINT  ,
					N4				TINYINT  ,
					S4				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Super PT Setting Values
	DECLARE @_MasterPTTbl TABLE(
					CustID			INT,
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S3				TINYINT  ,
					M3				TINYINT  ,
					A3				TINYINT  ,
					IM3				BIT  ,
					UM3				TINYINT  ,
					IS3				BIT  ,
					US3				TINYINT  ,
					N3				TINYINT  ,
					S3				TINYINT  
					UNIQUE CLUSTERED (CustID, SportType, BetType, IsLive) 
				)
				
	--Super PT Setting Values
	DECLARE @_AgentPTTbl TABLE(
					CustID			INT,
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S2				TINYINT  ,
					M2				TINYINT  ,
					A2				TINYINT  ,
					IM2				BIT  ,
					UM2				TINYINT  ,
					IS2				BIT  ,
					US2				TINYINT  ,
					N2				TINYINT  ,
					S2				TINYINT  
					UNIQUE CLUSTERED (CustID, SportType, BetType, IsLive) 
				)
				
	--A bunch of variables for calculation
	DECLARE @_S1				TINYINT  ,
			@_M1				TINYINT  ,
			@_A1				TINYINT  ,
			@_IM1				BIT  ,
			@_UM1				TINYINT  ,
			@_IS1				BIT  ,
			@_US1				TINYINT,
			@_AutoM1AutoM2		TINYINT,
			@_AutoS1AutoS3		TINYINT,
			@_MinM3L3			TINYINT,
			@_MinM3L3MinusA1	TINYINT,
			@_MinM3L3A1			TINYINT,
			@_S4MinusM1MinusA1	TINYINT,
			@_Temp				TINYINT,
			@_Temp2				TINYINT,
			@_Temp3				TINYINT,
			@_Temp4				TINYINT,
			@_Temp5				TINYINT,
			@_Temp6				TINYINT,
			@_Temp7				TINYINT
--******************************************VARIABLE INITITATES****************************************************** 
	--Get SMA Info
	SELECT @_SuperID = @SuperID, @_MasterID = @MasterID, @AgentID = @_AgentID, @_RoleID = @RoleID
	
	--Parse affected sporttype/bettype/islive
	INSERT @_SportBetTypeTbl(
				SportType,
				BetType,
				IsLive
			)
	SELECT SportType,
			BetType,
			IsLive
	FROM dbo.f_SportBetTypeXMLParse(@SportBetTypeXML,1)  
	
	--Get Super PT Setting Values
	INSERT @_SuperPTTbl(SportType,BetType,IsLive,S4,M4,A4
							,IM4,UM4,IS4,US4,N4,L4)	
	SELECT cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,AgentPT
							,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
	INNER JOIN @_SportBetTypeTbl mt 
		ON mt.SportType = cs.SportType
			AND mt.BetType = cs.BetType
			AND mt.IsLive = cs.IsLive
	WHERE CustID = @_SuperID

--******************************************START CORRECTING PT SETTING VALUES***************************************  
    IF @roleid = 4 --When Super Update Members
    BEGIN 
		--Get master PT Setting Values
		INSERT @_MasterPTTbl(CustID,SportType,BetType,IsLive,S3,M3,A3
					,IM3,UM3,IS3,US3,N3,L3)	
		SELECT cs.CustID,cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,AgentPT
					,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT 
		FROM dbo.custinfo c WITH(NOLOCK)
		INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
			ON acs.CustID = c.CustID
		INNER JOIN @_SportBetTypeTbl mt 
			ON mt.SportType = acs.SportType
				AND mt.BetType = acs.BetType
				AND mt.IsLive = acs.IsLive
		WHERE c.srecommend = @_SuperID AND c.RoleID = 3
	           
		--if is1|is3 then s1 = min(s4-m1-a1, is1?us1:us3)
        UPDATE cs 
        SET @_M1 = cs.MasterPT,
            @_A1 = cs.AgentPT ,
            @_IS1 = cs.IsAutoSuperPT,
            @_US1 = cs.AutoSuperPT,
            
            --is1?us1:us3
            @_US1 = CASE WHEN @_IS1 = 1 THEN  @_US1 ELSE US3 END,
            
            --min(s4-m1-a1, is1?us1:us3)
            @_S1 = CASE WHEN S4 - @_M1 - @_A1 > @_US1 THEN @_US1 ELSE S4 - @_M1 - @_A1 END    
        FROM CustInfo ci WITH(NOLOCK)
            INNER JOIN CustPTSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
					ON ci.CustID = cs.CustID
            INNER JOIN @_MasterPTTbl mcs 
					ON mcs.custid = ci.mrecommend 
						AND mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
            INNER JOIN @_SuperPTTbl scs 
					ON scs.sporttype = cs.sporttype 
						AND scs.bettype = cs.bettype 
						AND scs.isLive = cs.isLive
        WHERE ci.srecommend = @_SuperID 
			AND ci.Roleid = 1
            AND ci.Enabled = 1              
            AND (cs.IsAutoSuperPT = 1 OR mcs.IS3 = 1)
           
        
        --if is1|is3 then s1 = min(s4-m1-a1, is1?us1:us3)
        UPDATE cs 
        SET @_M1 = cs.MasterPT,
            @_A1 = cs.AgentPT ,
            @_IS1 = cs.IsAutoSuperPT,
            @_US1 = cs.AutoSuperPT,
            
            --is1?us1:us3
            @_US1 = CASE WHEN @_IS1 = 1 THEN  @_US1 ELSE US3 END,
            
            --min(s4-m1-a1, is1?us1:us3)
            @_S1 = CASE WHEN S4 - @_M1 - @_A1 > @_US1 THEN @_US1 ELSE S4 - @_M1 - @_A1 END    
        FROM CustInfo ci WITH(NOLOCK)
            INNER JOIN CustPTGroupSetting3rd_Member cs WITH (ROWLOCK, UPDLOCK) 
					ON ci.CustID = cs.AgentID
            INNER JOIN @_MasterPTTbl mcs 
					ON mcs.custid = ci.mrecommend 
						AND mcs.SportType = cs.SportType 
						AND mcs.BetType = cs.BetType 
						AND mcs.IsLive = cs.IsLive
            INNER JOIN @_SuperPTTbl scs 
					ON scs.sporttype = cs.sporttype 
						AND scs.bettype = cs.bettype 
						AND scs.isLive = cs.isLive
        WHERE ci.srecommend = @_SuperID 
			AND ci.Roleid = 2
            AND ci.Enabled = 1              
            AND (cs.IsAutoSuperPT = 1 OR mcs.IS3 = 1 )       
    END
    ELSE
    BEGIN
		--Get master PT Setting Values
		INSERT @_MasterPTTbl(CustID,SportType,BetType,IsLive,S3,M3,A3
					,IM3,UM3,IS3,US3,N3,L3)	
		SELECT cs.CustID,cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,AgentPT
					,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT 
		FROM dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
		INNER JOIN @_SportBetTypeTbl mt 
			ON mt.SportType = acs.SportType
				AND mt.BetType = acs.BetType
				AND mt.IsLive = acs.IsLive
		WHERE acs.CustID = @_MasterID
		
		--Get Agent PT Setting Values
		IF @roleid = 2
		BEGIN	
			INSERT @_AgentPTTbl(CustID,SportType,BetType,IsLive,S3,M3,A3
						,IM3,UM3,IS3,US3,N3,L3)	
			SELECT cs.CustID,cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,AgentPT
						,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT 
			FROM dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
			INNER JOIN @_SportBetTypeTbl mt 
				ON mt.SportType = acs.SportType
					AND mt.BetType = acs.BetType
					AND mt.IsLive = acs.IsLive
			WHERE acs.CustID = @_AgentID
		END
		ELSE
		BEGIN
			INSERT @_AgentPTTbl(CustID,SportType,BetType,IsLive,S3,M3,A3
						,IM3,UM3,IS3,US3,N3,L3)	
			SELECT cs.CustID,cs.SportType,cs.BetType,cs.IsLive,SuperPT,MasterPT,AgentPT
						,IsAutoMasterPT,AutoMasterPT,IsAutoSuperPT,AutoSuperPT,MinPT,MaxPT 
			FROM dbo.custinfo c WITH(NOLOCK)
			INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
				ON acs.CustID = c.CustID
			INNER JOIN @_SportBetTypeTbl mt 
				ON mt.SportType = acs.SportType
					AND mt.BetType = acs.BetType
					AND mt.IsLive = acs.IsLive
			WHERE c.mrecommend = @_MasterID AND c.RoleID = 2
		END
		
		IF @RoleID = 2
		BEGIN
			UPDATE cs
			SET
				----------------------------------Get values-----------------------------------------
				@_A1 = cs.AgentPT ,
				@_M1 = cs.MasterPT,
				
				--------------------------------Start correcting--------------------------------------
				--if a1 < n2 then a1 = n2
				@_A1 = CASE WHEN @_A1 < N2 THEN N2 ELSE @_A1 END,
				
				
				--if a1 > l2 then a1 = l2
				@_A1 = CASE WHEN @_A1 > L2 THEN L2 ELSE @_A1 END,
				
				--if a1 > l2 then a1 = l2
				@_A1 = CASE WHEN @_A1 > L2 THEN L2 ELSE @_A1 END,
				
				
				--if m1+a1>m3 then m1=m3-a1
				@_M1 = CASE WHEN @_M1 + @_A1 > M3 THEN M3 - @_A1 ELSE @_M1 END,
				------------------------Apply changes-----------------------------------------
				cs.SuperPT = @_S1,
				cs.MasterPT = @_M1,
				cs.AgentPT = @_A1
			FROM dbo.CustPTSetting3rd_Member AS cs WITH (ROWLOCK, UPDLOCK) 
				INNER JOIN dbo.custinfo AS c WITH (NOLOCK) 
						ON cs.custid = c.custid 
							AND c.mrecommend = @_MasterID 
							AND c.roleid =1 
							AND c.Enabled = 1
				INNER JOIN @_MasterPTTbl AS mcs 
						ON mcs.custid = @_MasterID 
							AND mcs.sporttype=cs.sporttype 
							AND mcs.bettype=cs.bettype
							AND mcs.isLive = cs.isLive
				INNER JOIN @_AgentPTTbl AS acs
						ON acs.custid = c.recommend 
							AND acs.sporttype=cs.sporttype 
							AND acs.bettype=cs.bettype
							AND acs.isLive = cs.isLive
		END
		
		--Start Correcting PT values
		UPDATE cs
		SET 
			----------------------------------Get values-----------------------------------------
			@_S1 = cs.SuperPT,
			@_M1 = cs.MasterPT,
            @_A1 = cs.AgentPT ,
            @_IM1 = cs.IsAutoMasterPT,
            @_UM1 = cs.AutoMasterPT,
            @_IS1 = cs.IsAutoSuperPT,
            @_US1 = cs.AutoSuperPT,
            
            --------------------------------Start correcting--------------------------------------
            
            --AutoMaster = im1=1 ? um1 : um2
            @_UM1 = CASE WHEN @_IM1 = 1 THEN  @_UM1 ELSE UM2 END,
            --min(m3-a1,im1=1 ? um1 : um2)
            @_AutoM1AutoM2 = CASE WHEN M3 - @_A1 > @_UM1 THEN @_UM1 ELSE M3 - @_A1 END,
            --if im1=1 or im2 = 1 then m1 = min(m3-a1,im1=1 ? um1 : um2)
            @_M1 = CASE WHEN @_IM1 = 1 OR IM2 = 1 THEN @_AutoM1AutoM2 ELSE @_M1 END,
            
            
            --if m1 + a1 < n3 then m1 = n3 - a1
            @_M1 = CASE WHEN @_M1 + @_A1 < N3 THEN N3 - @_A1 ELSE @_M1 END,
            
            
            --MIN(m3,l3)
            @_MinM3L3 = CASE WHEN M3 > L3 THEN L3 ELSE M3 END,
            --MAX(0,MIN(m3,l3) - a1)
            @_MinM3L3MinusA1 = CASE WHEN @_MinM3L3 - @_A1 > 0 THEN @_MinM3L3 - @_A1 ELSE 0 END,
            --m1 + a1
            @_Temp = @_M1 + @_A1,
            --if m1 + a1 > MIN(m3,l3) then m1 = MIN(m3,l3) - a1
            @_M1 = CASE WHEN @_Temp > @_MinM3L3 THEN @_MinM3L3MinusA1 ELSE @_M1 END,
            --Min(m3,l3,a1)
            @_MinM3L3A1 = CASE WHEN @_MinM3L3 > @_A1 THEN @_A1 ELSE @_MinM3L3 END,
            --Max(Min(m3,l3,a1), n2)
            @_Temp2 = CASE WHEN @_MinM3L3A1 > N2 THEN @_MinM3L3A1 ELSE N2 END,
            --if a1 + m1 > MIN(m3,l3) Then a1 = Max(Min(m3,l3,a1), n2)
            @_A1 = CASE WHEN @_Temp > @_MinM3L3 THEN @_Temp2 ELSE @_A1 END,
            
            
            --AutoSuper = is1=1 ? us1 : us3
            @_US1 = CASE WHEN @_IS1 = 1 THEN  @_US1 ELSE US3 END,
            --min(s4-m1-a1,is1=1 ? us1 : us3)
            @_AutoS1AutoS3 = CASE WHEN S4 - @_M1 - @_A1 > @_US1 THEN @_US1 ELSE S4 - @_M1 - @_A1 END,
            --if is1= 1 or is3 = 1 then s1 = min(s4-m1-a1,is1=1 ? us1 : us3)
            @_S1 = CASE WHEN @_IS1 = 1 OR IS3 = 1 THEN @_AutoS1AutoS3 ELSE @_S1 END,
            
            
            --if s1+ m1 + a1< n4 then s1= n4-m1-a1
            @_S1 = CASE WHEN @_S1 + @_M1 + @_A1 < N4 THEN N4 - @_M1 - @_A1 ELSE @_S1 END,
            
            
            --s1+ m1 + a1
            @_Temp = @_S1 + @_M1 + @_A1,
            --max(0,s4-m1-a1)
            @_S4MinusM1MinusA1 = CASE WHEN S4 - @_M1 - @_A1 > 0 THEN S4 - @_M1 - @_A1 ELSE 0 END,
            --if s1+ m1 + a1> s4 then s1=max(0,s4-m1-a1)
            @_S1 = CASE WHEN @_Temp > S4 THEN @_S4MinusM1MinusA1 ELSE @_S1 END,
            --MIN(s4-s1, m1+a1)
            @_Temp2 = CASE WHEN @_M1 + @_A1 > S4 - @_S1 THEN S4 - @_S1 ELSE @_M1 + @_A1 END,
            --MIN( MIN(m3,l3) , MIN(s4-s1, m1+a1) )
            @_Temp3 = CASE WHEN @_Temp2 > @_MinM3L3 THEN @_MinM3L3 ELSE @_Temp2 END,
            --MAX(@_Temp3, N3)
            @_Temp4 = CASE WHEN @_Temp3 > N3 THEN @_Temp3 ELSE N3 END,
            --MAX(0,@_Temp4-a1)
            @_Temp5 = CASE WHEN @_Temp4 - @_A1 > 0 THEN @_Temp4 - @_A1 ELSE 0 END,
            --if s1 + m1 + a1 > s4 then m1 = @_Temp5
            @_M1 = CASE WHEN @_Temp > S4 THEN @_Temp5 ELSE @_M1 END,
            --MIN(@_A1, @_Temp4 - @_M1)
            @_Temp6 = CASE WHEN @_A1 > @_Temp4 - @_M1 THEN @_Temp4 - @_M1 ELSE @_A1 END,
            --MAX(@_Temp6, N2)
            @_Temp7 = CASE WHEN @_Temp6 > N2 THEN @_Temp6 ELSE N2 END,
            --if s1 + m1 + a1 > s4 then a1 = @_Temp7
            @_A1 = CASE WHEN @_Temp > S4 THEN @_Temp7 ELSE @_A1 END,
            
            --------------------------------Apply changes---------------------------------------
            cs.SuperPT = @_S1,
            cs.MasterPT = @_M1,
            cs.AgentPT = @_A1
            
		FROM dbo.CustPTSetting3rd_Member AS cs WITH (ROWLOCK, UPDLOCK) 
			INNER JOIN dbo.custinfo AS c WITH (NOLOCK) 
					ON cs.custid = c.custid 
						AND c.mrecommend = @_MasterID 
						AND c.roleid =1 
						AND c.Enabled = 1
			INNER JOIN @_SuperPTTbl scs 
					ON scs.sporttype = cs.sporttype 
						AND scs.bettype = cs.bettype 
						AND scs.isLive = cs.isLive
			INNER JOIN @_MasterPTTbl AS mcs 
					ON mcs.custid = @_MasterID 
						AND mcs.sporttype=cs.sporttype 
						AND mcs.bettype=cs.bettype
						AND mcs.isLive = cs.isLive
			INNER JOIN @_AgentPTTbl AS acs
					ON acs.custid = c.recommend 
						AND acs.sporttype=cs.sporttype 
						AND acs.bettype=cs.bettype
						AND acs.isLive = cs.isLive
			
                           
    END
END




GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustSetting_07] TO [vnteam]
GO 
