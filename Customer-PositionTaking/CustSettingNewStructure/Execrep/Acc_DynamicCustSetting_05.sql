SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_DynamicCustSetting_05]
    @SuperID			INT	= 0,
    @MasterID			INT = 0,
    @AgentID			INT = 0,
    @RoleID				INT	= 0,
    @SportBetTypeXML	NVARCHAR(MAX) = '' ,
    @IsUpdateAllMembers BIT = 0,
    @IsUpdateMultiple	BIT = 0,
    @NewS1				TINYINT =0 ,
    @NewM1				TINYINT =0
AS
/*
    Created: Dominic
    Date: 20150901
    Task: Use Execrep to correct member PT setting values WHEN updating auto pt on master , agent(Dynamic Customer Setting)
    DB: DBCUST/CustDB
    Original versions: Acc_CustSetting3rd_05                
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
	
	--Affected sport/BetType/islive
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
					L4				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
--******************************************VARIABLE INITITATES****************************************************** 
	--Get SMA Info
	SELECT @_SuperID = @SuperID, @_MasterID = @MasterID, @_AgentID = @AgentID , @_RoleID = @RoleID
	
	--Parse affected SportType/BetType/islive
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
    --UPDATE min/max pt ON master
    IF @_RoleID = 3
    BEGIN			
		IF EXISTS (
				SELECT TOP 1 1
				FROM @tblPT
				WHERE isUpdateAutoPT = 1
				)
		BEGIN
			--UPDATE use Auto_SPT at master for all members only when:
			--(autoSPT at master changes AND isauto at master = 1
			--OR isauto at master changes FROM 0 to 1)
			--AND isauto at member = 0
			UPDATE cs
			SET cs.SuperPT = CASE 
					WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > b.AutoSuperPT
						THEN b.AutoSuperPT
					ELSE scs.SuperPT - cs.MasterPT - cs.AgentPT
					END
			FROM CustPTSetting3rd_Member cs WITH (
					UPDLOCK
					, ROWLOCK
					)
			INNER JOIN CustInfo ci WITH (NOLOCK)
				ON cs.custid = ci.custid
			INNER JOIN @tblPT b
				ON b.sporttype = cs.sporttype
					AND b.bettype = cs.bettype
					AND b.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
					AND scs.sporttype = cs.sporttype
					AND scs.bettype = cs.bettype
					AND scs.isLive = cs.isLive
			WHERE ci.mrecommend = @mrecommend
				AND ci.roleid = 1
				AND ci.Enabled = 1
				AND b.isUpdateAutoPT = 1
				AND b.isAutoSuperPT > 0 --auto PT is used	
				AND cs.isAutoSuperPT = 0 -- only UPDATE members without AutoSPT at member	

			--update grouped settings	
			UPDATE cs
			SET cs.SuperPT = CASE 
					WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > b.AutoSuperPT
						THEN b.AutoSuperPT
					ELSE scs.SuperPT - cs.MasterPT - cs.AgentPT
					END
			FROM CustPTGroupSetting3rd_Member cs WITH (
					UPDLOCK
					, ROWLOCK
					)
			INNER JOIN CustInfo ci WITH (NOLOCK)
				ON cs.AgentID = ci.custid
			INNER JOIN @tblPT b
				ON b.sporttype = cs.sporttype
					AND b.bettype = cs.bettype
					AND b.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
					AND scs.sporttype = cs.sporttype
					AND scs.bettype = cs.bettype
					AND scs.isLive = cs.isLive
			WHERE ci.mrecommend = @mrecommend
				AND ci.roleid = 2
				AND ci.Enabled = 1
				AND b.isUpdateAutoPT = 1
				AND b.isAutoSuperPT > 0 --auto PT is used	
				AND cs.isAutoSuperPT = 0 -- only UPDATE members without AutoSPT at member	

			--IF @Updateallmembers = 1				
			--UPDATE a specific SPT for all members only when:
			-- @updateallmembers = 1
			-- isauto at master = 0
			--AND isauto at master change FROM 1 to 0
			--AND isauto at member = 0
			UPDATE cs
			SET cs.SuperPT = CASE 
					WHEN b.NewSuperPT > scs.SuperPT - mcs.MasterPT
						THEN scs.SuperPT - mcs.MasterPT
					ELSE b.NewSuperPT
					END
			FROM CustPTSetting3rd_Member cs WITH (
					UPDLOCK
					, ROWLOCK
					)
			INNER JOIN CustInfo ci WITH (NOLOCK)
				ON cs.custid = ci.custid
			INNER JOIN @tblPT b
				ON b.sporttype = cs.sporttype
					AND b.bettype = cs.bettype
					AND b.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH (NOLOCK)
				ON mcs.custid = @mrecommend
					AND mcs.sporttype = cs.sporttype
					AND mcs.bettype = cs.bettype
					AND mcs.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
					AND scs.sporttype = cs.sporttype
					AND scs.bettype = cs.bettype
					AND scs.isLive = cs.isLive
			WHERE ci.mrecommend = @mrecommend
				AND ci.roleid = 1
				AND ci.Enabled = 1
				AND b.isUpdateAutoPT = 1
				AND b.UpdAllMems = 1
				AND b.isAutoSuperPT = 0 --auto PT is NOT used
				AND b.isAutoSuperPTOld = 1
				AND cs.IsAutoSuperPT = 0

			--grouped settings
			UPDATE cs
			SET cs.SuperPT = CASE 
					WHEN b.NewSuperPT > scs.SuperPT - mcs.MasterPT
						THEN scs.SuperPT - mcs.MasterPT
					ELSE b.NewSuperPT
					END
			FROM CustPTGroupSetting3rd_Member cs WITH (
					UPDLOCK
					, ROWLOCK
					)
			INNER JOIN CustInfo ci WITH (NOLOCK)
				ON cs.AgentID = ci.custid
			INNER JOIN @tblPT b
				ON b.sporttype = cs.sporttype
					AND b.bettype = cs.bettype
					AND b.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH (NOLOCK)
				ON mcs.custid = @mrecommend
					AND mcs.sporttype = cs.sporttype
					AND mcs.bettype = cs.bettype
					AND mcs.isLive = cs.isLive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
					AND scs.sporttype = cs.sporttype
					AND scs.bettype = cs.bettype
					AND scs.isLive = cs.isLive
			WHERE ci.mrecommend = @mrecommend
				AND ci.roleid = 2
				AND ci.Enabled = 1
				AND b.isUpdateAutoPT = 1
				AND b.UpdAllMems = 1
				AND b.isAutoSuperPT = 0 --auto PT is NOT used
				AND b.isAutoSuperPTOld = 1
				AND cs.IsAutoSuperPT = 0
		END

		IF EXISTS (
				SELECT TOP 1 1
				FROM @tblPT
				WHERE isUpdateAutoPT = 0
				)
		BEGIN
			--apply new value position taking for super on members
			--@Updateallmembers = 1				
			UPDATE cs
			SET SuperPT = b.NewSuperPT
			FROM CustPTSetting3rd_Member cs WITH (
					ROWLOCK
					, UPDLOCK
					)
			INNER JOIN custinfo ci WITH (NOLOCK)
				ON ci.custid = cs.custid
					AND ci.mrecommend = @mrecommend
					AND ci.roleid = 1
			INNER JOIN @tblPT b
				ON b.bettype = cs.bettype
					AND b.sporttype = cs.sporttype
					AND b.isLive = cs.isLive
			WHERE b.isUpdateAutoPT = 0
				AND b.isAutoSuperPT = 0
				AND b.UpdAllMems = 1
				AND cs.isAutoSuperPT = 0

			--grouped settings
			UPDATE cs
			SET SuperPT = @newspositiontaking
			FROM CustPTGroupSetting3rd_Member cs WITH (
					ROWLOCK
					, UPDLOCK
					)
			INNER JOIN custinfo ci WITH (NOLOCK)
				ON ci.custid = cs.AgentID
					AND ci.mrecommend = @mrecommend
					AND ci.roleid = 2
			INNER JOIN @tblPT b
				ON b.bettype = cs.bettype
					AND b.sporttype = cs.sporttype
					AND b.isLive = cs.isLive
			WHERE b.isUpdateAutoPT = 0
				AND b.isAutoSuperPT = 0
				AND b.UpdAllMems = 1
				AND cs.isAutoSuperPT = 0
		END			
    END--end roleid = 3  
    ELSE
    BEGIN
		IF @mode = 'Others'
		BEGIN
		  -- For read xml					
			EXEC sp_xml_preparedocument @DocHandler OUTPUT, @AutoPT
			
			INSERT INTO @tblPT(
						SportType,
						BetType,
						IsLive,
						MasterPT,						
						IsAutoMasterPT,
						IsAutoMasterPTOld,
						AutoMasterPT,
						isUpdateAutoPT,
						UpdAllMems,
						NewMasterPT
					)
			SELECT
				Data.SportType,
				Data.BetType,
				Data.IsLive,
				Data.MasterPT,				
				Data.isAutoMasterPT,
				Data.isAutoMasterPTOld,
				Data.AutoMasterPT,
				Data.IsUpdateAutoPT,
				Data.UpdAllMems,
				Data.NewMasterPT
			FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
			WITH (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLINT,
				IsAutoMasterPT	BIT,
				IsAutoMasterPTOld BIT,
				AutoMasterPT	SMALLINT,
				IsUpdateAutoPT	BIT,
				UpdAllMems		BIT,
				NewMasterPT		SMALLINT	
			) AS Data
			OPTION(OPTIMIZE FOR UNKNOWN)
			
			EXEC sp_xml_removedocument @DocHandler
			-- end read xml	
			
			IF EXISTS(SELECT TOP 1 1 FROM @tblPT WHERE isUpdateAutoPT =1)
			BEGIN
				--Use AUTO MPT 
				--m1=min(m3-a1,u2) 
				UPDATE cs       
				SET MasterPT =
						CASE
							WHEN mcs.MasterPT - cs.AgentPT > b.AutoMasterPT THEN b.AutoMasterPT
							ELSE mcs.MasterPT - cs.AgentPT
						END        
				FROM CustPTSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)        
					INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid 
					INNER JOIN @tblPT b ON b.sporttype = cs.sporttype
											AND b.bettype = cs.bettype
											AND b.isLive = cs.isLive
					INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																			AND b.sporttype = cs.sporttype
																			AND b.bettype = cs.bettype
																			AND b.isLive = cs.isLive										
				WHERE c.recommend = @recommend 
						AND c.roleid = 1
						AND b.isAutoMasterPT > 0
						AND b.isUpdateAutoPT = 1
				
				--update grouped settings
				UPDATE cs       
				SET MasterPT =
						CASE
							WHEN mcs.MasterPT - cs.AgentPT > b.AutoMasterPT THEN b.AutoMasterPT
							ELSE mcs.MasterPT - cs.AgentPT
						END        
				FROM CustPTGroupSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)        
					INNER JOIN custinfo c WITH(NOLOCK) ON cs.AgentID = c.custid 
					INNER JOIN @tblPT b ON b.sporttype = cs.sporttype
											AND b.bettype = cs.bettype
											AND b.isLive = cs.isLive
					INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																			AND b.sporttype = cs.sporttype
																			AND b.bettype = cs.bettype
																			AND b.isLive = cs.isLive										
				WHERE c.custid = @recommend 				
						AND b.isAutoMasterPT > 0
						AND b.isUpdateAutoPT = 1
				
				IF EXISTS(SELECT TOP (1) 1 FROM @tblPT WHERE UpdAllMems = 1)--all member       
				BEGIN
					--Not use AUTO MPT
					--m1=min(m3-a2,@m1)
					UPDATE cs             
					SET MasterPT =
									CASE
									WHEN mcs.MasterPT - acs.AgentPT < b.NewMasterPT THEN mcs.MasterPT - acs.AgentPT
									ELSE b.NewMasterPT END        
					FROM CustPTSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)         
							INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid   
							INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
													AND cs.bettype=b.bettype        
													AND cs.isLive = b.isLive     
							INNER JOIN CustPTSetting3rd_Agent as acs WITH(NOLOCK) ON acs.custid = @recommend 
																					AND cs.sporttype=acs.sporttype 
																					AND cs.bettype=acs.bettype        
																					AND cs.isLive = acs.isLive
							INNER JOIN CustPTSetting3rd_Agent as mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																					AND mcs.sporttype = cs.sporttype 
																					AND mcs.bettype = cs.bettype
																					AND mcs.isLive = cs.isLive        
					WHERE c.recommend = @recommend 
							AND c.roleid = 1 
							AND b.UpdAllMems = 1
							AND b.isUpdateAutoPT = 1
							AND b.isAutoMasterPT = 0
							AND b.isAutoMasterPTOld = 1
					
					--update grouped settings
					 UPDATE cs             
					SET MasterPT =
									CASE
									WHEN mcs.MasterPT - acs.AgentPT < b.NewMasterPT THEN mcs.MasterPT - acs.AgentPT
									ELSE b.NewMasterPT END        
					FROM CustPTGroupSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)         
							INNER JOIN custinfo c WITH(NOLOCK) ON cs.AgentID = c.custid   
							INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
													AND cs.bettype=b.bettype        
													AND cs.isLive = b.isLive     
							INNER JOIN CustPTSetting3rd_Agent as acs WITH(NOLOCK) ON acs.custid = @recommend 
																					AND cs.sporttype=acs.sporttype 
																					AND cs.bettype=acs.bettype        
																					AND cs.isLive = acs.isLive
							INNER JOIN CustPTSetting3rd_Agent as mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																					AND mcs.sporttype = cs.sporttype 
																					AND mcs.bettype = cs.bettype
																					AND mcs.isLive = cs.isLive        
					WHERE c.custid = @recommend 
							AND b.UpdAllMems = 1
							AND b.isUpdateAutoPT = 1
							AND b.isAutoMasterPT = 0
							AND b.isAutoMasterPTOld = 1
				END
			END
			
			IF EXISTS(SELECT TOP 1 1 FROM @tblPT WHERE isUpdateAutoPT = 0 AND UpdAllMems = 1) 
			BEGIN
				--IF @updateallmembers =  1			
				UPDATE cs
				SET cs.MasterPT = b.NewMasterPT
				FROM CustPTSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)
					INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid   
					INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
											AND cs.bettype=b.bettype        
											AND cs.isLive = b.isLive  
				WHERE c.recommend = @recommend 
					AND c.roleid = 1
					AND b.isUpdateAutoPT = 0
					AND b.UpdAllMems = 1
					AND b.IsAutoMasterPT = 0					
					AND cs.IsAutoMasterPT = 0
				
				--update grouped settings	
				UPDATE cs
				SET cs.MasterPT = b.NewMasterPT
				FROM CustPTGroupSetting3rd_Member cs WITH(ROWLOCK, UPDLOCK)
					INNER JOIN custinfo c WITH(NOLOCK) ON cs.AgentID = c.custid   
					INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
											AND cs.bettype=b.bettype        
											AND cs.isLive = b.isLive  
				WHERE c.custid = @recommend 
					AND b.isUpdateAutoPT = 0
					AND b.UpdAllMems = 1
					AND b.IsAutoMasterPT = 0					
					AND cs.IsAutoMasterPT = 0
				
			END
	END--end mode = 'Others'
END


