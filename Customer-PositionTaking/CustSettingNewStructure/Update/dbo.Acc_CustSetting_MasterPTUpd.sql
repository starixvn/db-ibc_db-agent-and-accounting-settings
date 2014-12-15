ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTUpd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	@updateallmembers	BIT = 0,
	@newSuperPT			SMALLINT = 0,	
	
	@SubAccID			INT = 0,
	@UserID				INT = 0,    
    @Language			VARCHAR(2) = 'E',
    @IP					VARCHAR(15)='',
    @ErrCode			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-2
		Task: Update pt on Master
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MasterMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MasterMinPT="0"/>
				</ROOT>
				
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid			TINYINT			
			,@startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT			
			,@logSPData		VARCHAR(5000)
			,@logSPDataOld	VARCHAR(5000)
			,@AutoPT		VARCHAR(MAX)
			,@sports		VARCHAR(500)=''			
			,@xml			XML
	  SET @startRun = GETDATE()
			
	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
		RETURN
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 3
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
    IF    @ErrCode <> 0 
		RETURN 
    ----------		
    
    IF @PT = '' RETURN 

    DECLARE @username VARCHAR(40), @srecommend INT
	
	SELECT @username = username, @srecommend = srecommend 
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	DECLARE @tmpPTGroup TABLE(custid INT)

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
	DECLARE @tmpPTGroup TABLE(custid INT)		
	
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
   
   --log old data
	SET @xml =(
		SELECT @custid AS '@ci'
				,f_GetSubUsername(@SubAccID) AS '@su'
				,@userid AS '@ui'
				,@language AS '@l'
				,@IP AS '@Ip'
				,@updateallmembers AS '@ua'
				,@newSuperPT AS '@s1'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.SuperPT AS '@s3'
						,cs.isAutoSuperPT AS '@is3'
						,cs.AutoSuperPT AS '@us3'
						,cs.MasterPT AS '@m3'						
						,cs.MinPT AS '@n3'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('pt'), TYPE
				)
		FOR XML PATH('r'), TYPE
	)
	
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)    
    
    SET @AutoPT =(
		SELECT cs.sporttype AS '@SportType'
			,cs.bettype AS '@BetType'
			,cs.isLive AS '@IsLive'			
			,t.isAutoSuperPT AS '@IsAutoSuperPT'
			,cs.isAutoSuperPT AS '@IsAutoSuperPTOld'
			,t.AutoSuperPT AS '@AutoSuperPT'			
			,CASE WHEN t.IsAutoSuperPT = cs.IsAutoSuperPT AND t.AutoSuperPT = cs.AutoSuperPT THEN 0 ELSE 1 END AS '@IsUpdateAutoPT'			
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
		WHERE custid = @custid
		FOR XML PATH('PT'), ROOT('ROOT')
	 )
	 
    --Check Param
    DECLARE @ErrAcc NVARCHAR(4000)
			,@ErrType VARCHAR(1000)
			,@UpdateMinPT BIT
			,@UpdatePresetPT BIT
	
		
	IF EXISTS(SELECT TOP 1 1 
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
			)
	 BEGIN
        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    END, @ErrCode = 101
        RETURN
    END			
    
    SELECT @sports = @sports + CAST(sporttype AS VARCHAR(5)) + ','
    FROM @tblPT
    
    --check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND (cs.SuperPT <> t.SuperPT
			OR cs.IsAutoSuperPT <> t.IsAutoSuperPT
			OR cs.AutoSuperPT <> t.AutoSuperPT
			OR cs.MasterPT <> t.MasterPT				
		)
	)
	BEGIN
		SELECT @UpdatePresetPT = 1
	END
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND cs.MinPT <> t.SuperMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	IF @UpdateMinPT = 1
    BEGIN
        --check min(m3,m4)>=n3
        SELECT @ErrAcc = ''        
        SELECT top 100 @ErrAcc = @ErrAcc + username + ', '
        FROM 
            CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend
            INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype 
										AND cs.bettype = b.bettype
										AND cs.isLive = b.isLive
        WHERE c.custid = @custid 
			AND (b.MasterPT < b.MasterMinPT OR scs.MasterPT < b.MasterMinPT)
        GROUP BY username
        
        IF @ErrAcc<>''
        BEGIN           
            SELECT @ErrMsg =     CASE @Language 
                                WHEN 'E' THEN 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                        END, @ErrCode = 102
                                
            RETURN
        END
    END	
    
    IF @UpdatePresetPT = 1
    BEGIN
		--check n4<=s3+m3<=l4 if i3 = 0, 
        --m3<=l4 and u3+m3>=n4 if i3 = 1
        SELECT @ErrType = ''
        
        SELECT @ErrType = @ErrType + sportname + '-'+ typenamee +  
        CASE WHEN b.IsLive = 0 THEN '-Min: '+ CAST((scs.MinPT) AS VARCHAR(10))+ '-Max: '+ CAST((scs.MaxPT) AS VARCHAR(10))+ '<br>'
			WHEN b.IsLive = 1 THEN '-MinLive: '+ CAST((scs.MinPT) AS VARCHAR(10))+ '-MaxLive: '+ CAST((scs.MaxPT) AS VARCHAR(10))+ '<br>' 
			END	
        FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK) 
            INNER JOIN @tblPT as b ON scs.sporttype = b.sporttype 
										AND scs.bettype = b.bettype
										AND scs.isLive = b.isLive
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt WITH(NOLOCK) ON b.bettype = bt.typeid										
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
              
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg = CASE @Language 
                                    WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                        END, @ErrCode = 103
                               
            RETURN
        END
        
        --n3<=m3<=l3
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
            + CASE WHEN b.IsLive = 0 THEN '-Min: '+ cast((b.MasterMinPT) AS VARCHAR(10))+ '-Max: '+ CAST((mcs.MaxPT) AS VARCHAR(10)) + '<br>'
					WHEN b.IsLive = 1 THEN '-MinLive: '+ cast((b.MasterMinPT) AS VARCHAR(10))+ '-MaxLive: '+ CAST((mcs.MaxPT) AS VARCHAR(10)) + '<br>'
				END
        FROM CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
			INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype
										AND mcs.isLive = b.IsLive
            INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s with(nolock) on b.sporttype = s.sporttype
        WHERE mcs.custid = @custid 
			AND (
					b.MasterPT > mcs.MaxPT 
				OR b.MasterPT < b.MasterMinPT
				)        
                        
        IF @ErrType <>''
        BEGIN            
            SELECT @ErrMsg = @UserName + ': '+
                        CASE @Language 
                                WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                        END,@ErrCode = 104
                        
            RETURN            
        END
        
         --m2+a2<=m3
        SELECT @ErrAcc = ''
        
         SELECT top 100 @ErrAcc = @ErrAcc + username + ', '
         FROM custinfo ci WITH(NOLOCK) 
				INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON ci.custid = acs.custid 
				INNER JOIN @tblPT b ON acs.sporttype = b.sporttype 
										AND acs.bettype = b.bettype
										AND acs.isLive = b.IsLive
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND acs.MasterPT + acs.AgentPT > b.MasterPT
		GROUP BY username
        
        IF @ErrAcc <> ''
        BEGIN            
            SELECT @ErrMsg = CASE @Language 
                                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                                 END
                 , @ErrCode = 105

            RETURN    
        END
		
		-------------------------------
		--m1+a1<=m3
        SELECT @ErrAcc = ''
        
        SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
        FROM custinfo ci WITH(NOLOCK) 
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
									AND cs.bettype = b.bettype
									AND cs.isLive = b.IsLive
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 1
           AND ci.Enabled    = 1
           AND cs.MasterPT + cs.AgentPT > b.MasterPT
      GROUP BY username

        IF @ErrAcc <> ''
        BEGIN            
            SELECT @ErrMsg =
                     CASE @Language 
                       WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') .'
                       ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                     END
                 , @ErrCode = 106

           RETURN    
        END
        
        --check on grouped settings
         SELECT @ErrAcc = ''
		
		INSERT INTO @tmpPTGroup(custid)
		SELECT TOP 100 ci.custid
		FROM custinfo ci WITH(NOLOCK) 
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON ci.custid = cs.AgentID
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
									AND cs.bettype = b.bettype
									AND cs.isLive = b.IsLive
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.MasterPT + cs.AgentPT > b.MasterPT
      GROUP BY ci.custid
      
		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
		WHERE c.recommend IN (SELECT custid FROM @tmpPTGroup)
			AND roleid = 1
			AND c.Enabled = 1
			AND IsGrouped = 1

		IF @ErrAcc <> ''
		BEGIN            
			SELECT @ErrMsg =
					 CASE @Language 
					   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') .'
					   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
					 END
				 , @ErrCode = 106

		   RETURN    
		END
		
		--check m3<=m4
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee +
					CASE WHEN b.IsLive = 0 THEN '-Max: '+ CAST((scs.MasterPT) AS VARCHAR(10)) + '<br>'
						WHEN b.IsLive = 1 THEN '-MaxLive: '+ CAST((scs.MasterPT) AS VARCHAR(10)) + '<br>'
						END
        FROM CustPTSetting3rd_Agent as scs WITH (NOLOCK)
			INNER JOIN @tblPT b ON scs.sporttype = b.SportType
									AND scs.bettype = b.BetType
									AND scs.isLive = b.IsLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype									
        WHERE custid = @srecommend 
            AND scs.MasterPT < b.MasterPT
        
        IF @ErrType <>''
        BEGIN            
            SELECT @ErrMsg = CASE @Language                                     
                                    WHEN 'E' THEN 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                            END, @ErrCode = 107
                 
            RETURN    
        END
        
        --m3>=u2
        SELECT @ErrAcc = ''
        
        SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
        FROM custinfo ci WITH(NOLOCK)
			INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON ci.custid = cs.custid 
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype
									AND cs.isLive = b.IsLive
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.AutoMasterPT > b.MasterPT
           and cs.IsAutoMasterPT = 1
      GROUP BY username

        IF @ErrAcc <> ''
        BEGIN        
            SELECT @ErrMsg = CASE @Language 
                                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                                 END
                 , @ErrCode = 108

            RETURN    
        END
        
        --u3<=s4
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee +
						CASE WHEN b.IsLive = 0 THEN '-Max: '+ CAST((cs.SuperPT) AS VARCHAR(10)) + '<br>'
							WHEN b.IsLive = 1 THEN '-MaxLive: '+ CAST((cs.SuperPT) AS VARCHAR(10)) + '<br>'
							END
        FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype
									AND cs.isLive = b.IsLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype										
        WHERE cs.custid = @srecommend 
            AND cs.SuperPT < b.AutoSuperPT
            
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg = CASE @Language 
                                    WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                                END, @ErrCode = 109
                                
            RETURN    
        END
        
         --u3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee +
						 CASE WHEN b.IsLive = 0 THEN '-Min: '+ CAST((CASE WHEN scs.MinPT - scs.MasterPT > 0 
																			THEN scs.MinPT - scs.MasterPT ELSE 0 END) AS VARCHAR(10))+ '<br>'
								WHEN b.IsLive = 1 THEN '-MinLive: '+ CAST((CASE WHEN scs.MinPT - scs.MasterPT > 0 
																			THEN scs.MinPT - scs.MasterPT ELSE 0 END) AS VARCHAR(10))+ '<br>'
							END																			
        FROM CustPTSetting3rd_Agent AS scs WITH (NOLOCK)
            INNER JOIN @tblPT b ON scs.sporttype = b.sporttype 
									AND scs.bettype = b.bettype
									AND scs.isLive = b.IsLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype										
       WHERE scs.custid = @srecommend 
            AND (b.IsAutoSuperPT >0 
				AND b.AutoSuperPT < CASE WHEN scs.MinPT - scs.MasterPT > 0 
											THEN scs.MinPT - cs.MasterPT ELSE 0 END
				)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode = 110
            
            RETURN
        END 
        
         --s3<=s4,s3+m3<=s4
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee +
							CASE WHEN b.IsLive = 0 THEN '-Max: '+ CAST((cs.SuperPT) AS VARCHAR(10))+ '<br>'
								WHEN b.IsLive = 1 THEN '-MaxLive: '+ CAST((cs.SuperPT) AS VARCHAR(10))+ '<br>'
							END
        FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT b ON cs.sporttype = b.SportType
									AND cs.bettype = b.BetType
									AND cs.isLive = b.IsLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype																			
        WHERE custid = @srecommend 
            AND (cs.SuperPT < b.SuperPT OR b.SuperPT + b.MasterPT > cs.SuperPT)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode = 111
            
                  
            RETURN
        END
        
        --s3>=Max(0, N4-M4)        
        SELECT @ErrType = ''
        SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee +
					CASE WHEN b.IsLive = 0 THEN '-Min: ' ELSE  '-MinLive: ' END
					+ CAST((CASE WHEN cs.MinPT - cs.MasterPT > 0 THEN cs.MinPT - cs.MasterPT ELSE 0 END) AS VARCHAR(10))+ '<br>'
        FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK)
			INNER JOIN @tblPT b ON cs.sporttype = b.SportType
									AND cs.bettype = b.BetType
									AND cs.isLive = b.isLive            
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
            INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype																			      									
        WHERE cs.custid = @srecommend
            AND (b.IsAutoSuperPT = 0 
				AND b.SuperPT < CASE WHEN cs.MinPT - cs.MasterPT > 0 
										THEN cs.MinPT - cs.MasterPT ELSE 0 END)
        
        IF @ErrType <>''
        BEGIN
            SELECT @ErrMsg = CASE @Language 
                                    WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
                                    ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                                END, @ErrCode = 112
                                
            RETURN
        END 	
    END	
    --end check constraint
    
    --update data change into db
    UPDATE cs
	SET cs.SuperPT = b.SuperPT
		,cs.MasterPT = b.MasterPT
		,cs.IsAutoSuperPT = b.IsAutoSuperPT
		,cs.AutoSuperPT = b.AutoSuperPT
		,cs.MinPT = b.MasterMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.SuperPT <> b.SuperPT
			OR cs.isAutoSuperPT <> b.IsAutoSuperPT
			OR cs.AutoSuperPT <> b.AutoSuperPT			
			OR cs.MasterPT <> b.MasterPT
			OR cs.MinPT <> b.MasterMinPT					
		)
	
	IF @UpdateMinPT = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_04 
				@mrecommend = @custid
				,@srecommend = @srecommend
				,@mode = 'Others'
				,@roleid = 3
				,@sports = @sports
	END
	
	IF @UpdatePresetPT = 1
	BEGIN
		 EXEC dbo.Acc_CustSetting3rd_05
            @srecommend = @srecommend,
            @mrecommend = @custid,
            @roleid = 3,
            @mode = 'Others',
            
            @PT = @AutoPT,
                            
            @updateallmembers = @updateallmembers,
            @newspositiontaking = @newSuperPT
            
         EXEC dbo.Acc_CustSetting3rd_07
            ,@srecommend = @srecommend
            ,@mrecommend = @custid
            ,@roleid = 3
            ,@mode = 'Others'
            ,@sports = @sports
	END
	
	 -- Write log after update
	SET @xml = (
			SELECT @custid AS '@ci'
					,f_GetSubUsername(@SubAccID) AS '@su'
					,@userid AS '@ui'
					,@langue AS '@l'
					,@IP AS '@Ip'
					,@updateallmembers AS '@ua'
					,@newSuperPT AS '@s1'
					,(
						SELECT cs.sporttype AS '@s'
							,cs.bettype AS '@b'
							,cs.isLive AS '@i'
							,cs.SuperPT AS '@s3'
							,cs.isAutoSuperPT AS '@is3'
							,cs.AutoSuperPT AS '@us3'
							,cs.MasterPT AS '@m3'						
							,cs.MinPT AS '@n3'						
						FROM @tblPT	cs							
						FOR XML PATH('pt'), Type
					)
			FOR XML PATH('r'),TYPE				
	)
    
    
	SET @logSPData = CONVERT(VARCHAR(MAX), @xml)	
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	BEGIN TRY
		DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 449,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 449,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 
		
END	
 GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbExtAccNet]
GO 