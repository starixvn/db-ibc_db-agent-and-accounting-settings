ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTCheck]
	@custid		INT,	
	@username	VARCHAR(30),
	@srecommend INT,
	
	@PT			VARCHAR(MAX),
	@UpdateMinPT BIT = 1, 
	@UpdatePresetPT BIT = 1,
	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000)='' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task: check input parameters for updating pt on Master
		DB: DBCUST/CustDB
		
		Revisions:
		
		Parameter's Explanations:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MasterMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MasterMinPT="0"/>
				</ROOT>
				
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tmpPTGroup TABLE(sporttype INT
							,bettype INT
							,isLive BIT
							,custid INT)

	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLINT,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLINT,
				MasterPT		SMALLINT,				
				MasterMinPT		SMALLINT
				)
	
	-- For read xml
	DECLARE @DocHandler INT    
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @PT
	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				IsAutoSuperPT,
				AutoSuperPT,
				MasterPT,				
				MasterMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.SuperPT,
		Data.isAutoSuperPT,
		Data.AutoSuperPT,
		Data.MasterPT,		
		Data.MasterMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType		SMALLINT,
		BetType			SMALLINT,
		IsLive			BIT,
		SuperPT			SMALLINT,
		IsAutoSuperPT	BIT,
		AutoSuperPT		SMALLINT,
		MasterPT		SMALLINT,		
		MasterMinPT		SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	--Check Param
    DECLARE @ErrType XML
			
	SET @ErrType =
		(
			SELECT t.SportType, t.BetType, t.IsLive
			FROM @tblPT t
				INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																	AND t.BetType = ps.bettype 
																	AND t.IsLive = ps.IsLive
			WHERE ps.SettingType = 1--PT
				AND (t.SuperPT < 0 OR t.MasterPT < 0 
					OR t.SuperPT + t.MasterPT > ps.MaxPT
					OR t.AutoSuperPT < 0 
					OR t.AutoSuperPT > ps.MaxPT
					OR t.MasterMinPT < 0					
				)
			FOR XML RAW('Row'), TYPE
		)
	
	IF @ErrType IS NOT NULL
	 BEGIN        
         SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 101
                    , @MsgType = 5
        RETURN
    END			
    
    IF @UpdateMinPT = 1
    BEGIN
        --check min(m3,m4)>=n3
        SELECT @ErrType = ''
	     
	     SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive
				FROM 
					CustPTSetting3rd_Agent AS scs WITH (NOLOCK) 
					INNER JOIN custInfo ci WITH(NOLOCK) ON scs.CustID = ci.custid
					INNER JOIN @tblPT AS b ON scs.sporttype=b.sporttype 
												AND scs.bettype = b.bettype
												AND scs.isLive = b.isLive
				WHERE scs.custid = @srecommend 
					AND (b.MasterPT < b.MasterMinPT OR scs.MasterPT < b.MasterMinPT)			
				FOR XML RAW('Row'), TYPE
		)
        
        IF @ErrType IS NOT NULL
        BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 102
                    , @MsgType = 5                                    
            RETURN
        END
    END	
    
    IF @UpdatePresetPT = 1
    BEGIN
		--check n4<=s3+m3<=l4 if i3 = 0, 
        --m3<=l4 and u3+m3>=n4 if i3 = 1
        SELECT @ErrType = ''
        
		 SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive, scs.MinPT, scs.MaxPT       
				FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK) 
					INNER JOIN @tblPT as b ON scs.sporttype = b.sporttype 
												AND scs.bettype = b.bettype
												AND scs.isLive = b.isLive					
				WHERE scs.custid = @srecommend 
					AND (    
							(
								b.IsAutoSuperPT=0 
								AND (
									b.SuperPT + b.MasterPT > scs.MaxPT 
									OR b.SuperPT + b.MasterPT < scs.MinPT
									)
							) 
							OR 
							(
								b.IsAutoSuperPT >0 
								AND (
									b.MasterPT>scs.MaxPT 
									OR b.MasterPT + b.AutoSuperPT < scs.MinPT
									)
							)
					  )
				FOR XML RAW('Row'), TYPE
				)	 
              
        IF @ErrType IS NOT NULL
        BEGIN
			SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 103
                    , @MsgType = 4                                   
            RETURN            
        END
        
        --n3<=m3<=l3
        SELECT @ErrType = ''        
		SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive, b.MasterMinPT as MinPT, mcs.MaxPT       				
				FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
												AND mcs.bettype = b.bettype
												AND mcs.isLive = b.IsLive					
				WHERE mcs.custid = @custid 
					AND (
							b.MasterPT > mcs.MaxPT 
						OR b.MasterPT < b.MasterMinPT
						)        
				FOR XML RAW('Row'), TYPE
				)
                        
        IF @ErrType IS NOT NULL
        BEGIN            
			SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 104
                    , @MsgType = 4                                   
            RETURN                
                       
        END
        
         --m2+a2<=m3
        SELECT @ErrType = ''
        
         SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				 SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
				 FROM custinfo ci WITH(NOLOCK) 
						INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON ci.custid = acs.custid 
						INNER JOIN @tblPT b ON acs.sporttype = b.sporttype 
												AND acs.bettype = b.bettype
												AND acs.isLive = b.IsLive
				 WHERE ci.mrecommend = @custid
				   AND ci.roleid     = 2
				   AND ci.Enabled    = 1
				   AND acs.MasterPT + acs.AgentPT > b.MasterPT
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)
			
        
        IF @ErrType IS NOT NULL
        BEGIN        
			SELECT @ErrMsg = '<Root MsgID="20026" Msg="Existing agents exceeded new Master Max PT">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 105
                    , @MsgType = 1                                   
            RETURN   
        END
		
		-------------------------------
		--m1+a1<=m3
        SELECT @ErrType = ''
        SELECT @ErrType =
		( 
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				 SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
				 FROM custinfo ci WITH(NOLOCK) 
					INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.custid
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
											AND cs.bettype = b.bettype
											AND cs.isLive = b.IsLive
				 WHERE ci.mrecommend = @custid
				   AND ci.roleid     = 1
				   AND ci.Enabled    = 1
				   AND cs.MasterPT + cs.AgentPT > b.MasterPT
			)b
			WHERE b.rn<= 10
			FOR XML RAW('Row'), TYPE
		)

        IF @ErrType IS NOT NULL
        BEGIN         
			SELECT @ErrMsg = '<Root MsgID="20022" Msg="Existing members exceeded new Master Max PT">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 106
                    , @MsgType = 1                                  
            RETURN                
        END
        
        --check on grouped settings
        
		INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
		SELECT b.SportType, b.BetType, islive, custid 
		FROM
		(
			SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn												
			FROM custinfo ci WITH(NOLOCK) 
				INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.AgentID
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
										AND cs.bettype = b.bettype
										AND cs.isLive = b.IsLive
			 WHERE ci.mrecommend = @custid
			   AND ci.roleid     = 2
			   AND ci.Enabled    = 1
			   AND cs.MasterPT + cs.AgentPT > b.MasterPT
		)b
		WHERE b.rn<= 10      
      
		SELECT @ErrType = ''	 
		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 
				FROM custinfo c WITH(NOLOCK)
					INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
					INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
				WHERE roleid = 1
					AND c.Enabled = 1
					AND IsGrouped = 1
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN      
			SELECT @ErrMsg = '<Root MsgID="20022" Msg="Existing members exceeded new Master Max PT">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 106
                    , @MsgType = 1                                  
            RETURN     
		END
		
		--check m3<=m4
       SELECT @ErrType = ''        
		SELECT @ErrType = (     			
				SELECT b.SportType, b.BetType, b.IsLive, scs.MasterPT as MaxPT				       
				FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK)
					INNER JOIN @tblPT b ON scs.sporttype = b.SportType
											AND scs.bettype = b.BetType
											AND scs.isLive = b.IsLive					
				WHERE custid = @srecommend 
					AND scs.MasterPT < b.MasterPT
				FOR XML RAW('Row'), TYPE
		)
        
        IF @ErrType IS NOT NULL
        BEGIN           
			SELECT @ErrMsg = '<Root MsgID="20027" Msg="The position taking violates Master Max PT set by company">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 107
                    , @MsgType = 3                                 
            RETURN  
        END
        
        --m3>=u2
        SELECT @ErrType = ''        
        SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 				 				
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON ci.custid = cs.custid 
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype
											AND cs.isLive = b.IsLive
				 WHERE ci.mrecommend = @custid
				   AND ci.roleid     = 2
				   AND ci.Enabled    = 1
				   AND cs.AutoMasterPT > b.MasterPT
				   AND cs.IsAutoMasterPT = 1
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)
			

        IF @ErrType IS NOT NULL
        BEGIN        
			SELECT @ErrMsg = '<Root MsgID="20026" Msg="Existing agents exceeded new Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 108
                    , @MsgType = 1                                 
            RETURN  
        END
        
        --u3<=s4
        SELECT @ErrType = ''
        SELECT @ErrType = (
			SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT 					
			FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
										AND cs.bettype = b.bettype
										AND cs.isLive = b.IsLive														
			WHERE cs.custid = @srecommend 
				AND cs.SuperPT < b.AutoSuperPT
			FOR XML RAW('Row'), TYPE
        )
            
        IF @ErrType IS NOT NULL
        BEGIN
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 109
                    , @MsgType = 3                                 
            RETURN
        END
        
         --u3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
		SELECT @ErrType = (
					SELECT b.SportType, b.BetType, b.IsLive, (CASE WHEN scs.MinPT - scs.MasterPT > 0 
																	THEN scs.MinPT - scs.MasterPT ELSE 0 END) as MinPT 																								
					FROM CustPTSetting3rd_Agent AS scs WITH (NOLOCK)
						INNER JOIN @tblPT b ON scs.sporttype = b.sporttype 
												AND scs.bettype = b.bettype
												AND scs.isLive = b.IsLive						
				   WHERE scs.custid = @srecommend 
						AND (b.IsAutoSuperPT >0 
							AND b.AutoSuperPT < (CASE WHEN scs.MinPT > scs.MasterPT
														THEN scs.MinPT - scs.MasterPT ELSE 0 END)
							)
					FOR XML RAW('Row'), TYPE
				)
        
        IF @ErrType IS NOT NULL
        BEGIN
			SELECT @ErrMsg = '<Root MsgID="20029" Msg=" The position taking violates Super Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 110
                    , @MsgType = 2                                
            RETURN            
        END 
        
        --s3<=s4,s3+m3<=s4
        SELECT @ErrType = ''        
        SELECT @ErrType = (
					SELECT b.SportType, b.BetType, b.IsLive, cs.SuperPT as MaxPT
					FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
						INNER JOIN @tblPT b ON cs.sporttype = b.SportType
												AND cs.bettype = b.BetType
												AND cs.isLive = b.IsLive																									
					WHERE custid = @srecommend 
						AND (cs.SuperPT < b.SuperPT OR b.SuperPT + b.MasterPT > cs.SuperPT)
					FOR XML RAW('Row'), TYPE
				)
        
        IF @ErrType IS NOT NULL
        BEGIN
			SELECT @ErrMsg = '<Root MsgID="20028" Msg="The position taking violates Super Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 111
                    , @MsgType = 3                                 
            RETURN
        END
        
        --s3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
        SELECT @ErrType = (
					SELECT b.SportType, b.BetType, b.IsLive, 
					CASE WHEN cs.MinPT - cs.MasterPT > 0 
							THEN cs.MinPT - cs.MasterPT ELSE 0 END as MinPT
        FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT b ON cs.sporttype = b.SportType
									AND cs.bettype = b.BetType
									AND cs.isLive = b.isLive            																						      									
        WHERE cs.custid = @srecommend
            AND (b.IsAutoSuperPT = 0 
				AND b.SuperPT < CASE WHEN cs.MinPT > cs.MasterPT
										THEN cs.MinPT - cs.MasterPT ELSE 0 END)
		FOR XML RAW('Row'), TYPE									
		)										
        
        IF @ErrType IS NOT NULL
        BEGIN
			SELECT @ErrMsg = '<Root MsgID="20029" Msg="The position taking violates Super Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 112
                    , @MsgType = 2                                
            RETURN             
        END 	
    END								
	
END 