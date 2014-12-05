 ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,    
    @Language	VARCHAR(2) = 'E',
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update pt on super
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
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
        ,@roleid		= 4
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

    DECLARE @username VARCHAR(40)
	
	SELECT @username = username 
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	DECLARE @tmpPTGroup TABLE(custid INT)

	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				MasterPT	SMALLINT,
				AgentPT		SMALLINT,
				SuperMinPT	SMALLINT
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
				MasterPT,
				AgentPT,
				SuperMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.SuperPT,
		Data.MasterPT,
		Data.AgentPT,
		Data.SuperMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType	SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,
		SuperPT		SMALLINT,
		MasterPT	SMALLINT,
		AgentPT		SMALLINT,
		SuperMinPT	SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	--log old data
	SET @xml =(
		SELECT @custid AS '@ci'
				,@userid AS '@ui'
				,@langue AS '@l'
				,@IP AS '@Ip'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.SuperPT AS '@s4'
						,cs.MasterPT AS '@m4'
						,cs.AgentPT AS '@a4'
						,cs.MinPT AS '@n4'
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
		
    --Check Param
    DECLARE @ErrAcc NVARCHAR(4000)
			,@ErrType VARCHAR(1000)
			,@UpdateMinPT BIT
			,@UpdatePresetPT BIT
	
	IF EXISTS(SELECT TOP 1 1 
			FROM @tblPT t
				INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype AND t.BetType = ps.bettype AND t.IsLive = ps.IsLive
		WHERE ps.SettingType = 1--PT
			AND (t.SuperPT < 0 OR t.SuperPT > ps.MaxPT
				OR t.MasterPT < 0 OR t.MasterPT > ps.MaxPT
				OR t.AgentPT < 0 OR t.AgentPT > ps.MaxPT
				OR t.SuperMinPT < 0
				OR t.SuperPT < t.MasterPT 
				OR t.MasterPT < t.AgentPT
			))
	 BEGIN
        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    END, @ErrCode = 101
        RETURN
    END		
	
	--check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND (cs.SuperPT <> t.SuperPT
			OR cs.MasterPT <> t.MasterPT
			OR cs.AgentPT <> t.AgentPT			
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

	IF @UpdatePresetPT = 1
	BEGIN		
		--check n4<=s4
		 SELECT @ErrType = ''
	     
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + 
			CASE WHEN t.IsLive = 0 THEN '-Min: '+ CAST((t.SuperMinPT) AS VARCHAR(10))
				WHEN t.IsLive = 1 THEN '-MinLive: '+ CAST((t.SuperMinPT) AS VARCHAR(10)) ELSE '' END + '<br>'        
		 FROM @tblPT t
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.SportType = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid
		WHERE SuperPT < SuperMinPT	
		ORDER BY t.SportType, t.BetType, t.IsLive
			
		IF @ErrType <>''
		BEGIN
			SELECT @ErrMsg =     CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
						END, @ErrCode = 102
			RETURN
		END
		
		------------------------------------------------------------------------------------------
		--check all s3+m3<=s4 if i3 = 0,
		--m3<=s4 and u3<=s4 if i3=1
		SELECT @ErrAcc = ''
		SELECT top 100 @ErrAcc = @ErrAcc + username +', '
		FROM 
			custinfo as c WITH (NOLOCK) 
			INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype 
										AND cs.bettype = b.BetType 
										AND cs.isLive = b.IsLive
		WHERE c.srecommend = @custid AND c.roleid = 3 AND (
								((cs.IsAutoSuperPT=0) AND (cs.SuperPT+cs.MasterPT>b.SuperPT)) OR 
								((cs.IsAutoSuperPT=1) AND (cs.MasterPT>b.SuperPT)) OR 
								((cs.IsAutoSuperPT=1) AND (cs.AutoSuperPT>b.SuperPT)) 
							)
		GROUP BY username
	    
		IF @ErrAcc<>''
		BEGIN
			SELECT @ErrMsg = @username + ': ' +
						CASE @Language 
								WHEN 'E' THEN 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
						end, @ErrCode = 103        
			RETURN        
		END
		
		------------------------------------------------------------------------------------------
		--check all s1+m1+a1 <= s4
		--check all u1<=s4 if i1=1
		SELECT @ErrAcc = ''

		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype 
									AND cs.IsLive = b.IsLive
		WHERE c.srecommend = @custid
			AND c.roleid     = 1
			AND c.Enabled    = 1
			AND (cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT
				OR (cs.IsAutoSuperPT = 1
					AND cs.AutoSuperPT > b.SuperPT
				   )  
			   )
		  GROUP BY username

		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language 
								   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
								 END
				 , @ErrCode = 104	        
			RETURN
		END
		 
		 --check pt on grouped settings
		 SELECT @ErrAcc = ''
		
		INSERT INTO @tmpPTGroup(custid)
		SELECT TOP 100 c.custid
		FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.AgentID
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype 
									AND cs.IsLive = b.IsLive		
		WHERE c.srecommend = @custid
			AND c.roleid     = 2
			AND c.Enabled    = 1
			AND (cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT
				OR (cs.IsAutoSuperPT = 1
					AND cs.AutoSuperPT > b.SuperPT
				   )  
			   )
		  GROUP BY c.custid
		  
		 SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		 FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
		WHERE c.recommend IN (SELECT custid FROM @tmpPTGroup)
			AND roleid = 1
			AND c.Enabled    = 1
			AND IsGrouped = 1

		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language 
								   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
								 END
				 , @ErrCode = 104	        
			RETURN
		END
		
		------------------------------------------------------------------------------------------
		--Check all m3<=m4
		SELECT @ErrAcc = ''
		SELECT top 100 @ErrAcc = @ErrAcc + username +', '
		FROM 
			custinfo AS c WITH (NOLOCK) 
			INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype 
										AND cs.bettype = b.bettype 
										AND cs.IsLive = b.IsLive
		WHERE c.srecommend = @custid AND c.roleid = 3 
			AND cs.MasterPT > b.MasterPT
		GROUP BY username

		IF @ErrAcc<>''
		BEGIN
			SELECT @ErrMsg =     @UserName + ': '+
				CASE @Language 
								WHEN 'E' THEN 'Existing masters exceeded new master position taking ('+@ErrAcc+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20015,@Language) + ' ('+@ErrAcc+').'
						END, @ErrCode = 105
			RETURN
		END
		
		-------------------------------------------------------------------------------------------
		--Check all m1+a1<=m4
		SELECT @ErrAcc = ''

		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		FROM custinfo c WITH(NOLOCK) 
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype 
									AND cs.IsLive = b.IsLive
		WHERE c.srecommend = @custid
			   AND c.roleid     = 1
			   AND c.Enabled    = 1
			   AND cs.MasterPT + cs.AgentPT > b.MasterPT
		GROUP BY username

		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language 
								   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
								 END
				 , @ErrCode = 106
			RETURN
		END
		
		--check PT on grouped settings
		 SELECT @ErrAcc = ''
		
		INSERT INTO @tmpPTGroup(custid)
		SELECT TOP 100 c.custid
		FROM custinfo c WITH(NOLOCK) 
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.AgentID
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype 
									AND cs.IsLive = b.IsLive
		WHERE c.srecommend = @custid
			   AND c.roleid     = 2
			   AND c.Enabled    = 1
			   AND cs.MasterPT + cs.AgentPT > b.MasterPT
		GROUP BY c.custid
		
		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		 FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
		WHERE c.recommend IN (SELECT custid FROM @tmpPTGroup)
			AND roleid = 1
			AND c.Enabled    = 1
			AND IsGrouped = 1
			
		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language 
								   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
								 END
				 , @ErrCode = 106
			RETURN
		END     
		
		-------------------------------------------------------------------------------------------------------------------
		--Check all a2<=a4
		SELECT @ErrAcc = ''

		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		FROM custinfo c WITH(NOLOCK) 
			INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
									AND cs.bettype = b.bettype 
									AND cs.IsLive = b.IsLive
		 WHERE c.srecommend = @custid
		   AND c.roleid     = 2
		   AND c.Enabled    = 1
		   AND cs.AgentPT > b.AgentPT
		GROUP BY username

		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @UserName + ': '
						   + CASE @Language 
							   WHEN 'E' THEN 'Existing agents exceeded new agent position taking (' + @ErrAcc + ').'
							   ELSE [dbo].[f_Get_MsgNamebyMsgID](20016, @Language) + ' (' + @ErrAcc + ').'
							  END
				  , @ErrCode = 107
			RETURN
		END
	    
		-----------------------------------------------------------------------------------------------------------------
		--Check all a1<=a4
		SELECT @ErrAcc = ''

		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		FROM custinfo c WITH(NOLOCK) 
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
									AND cs.bettype = b.bettype
									AND cs.IsLive = b.IsLive
		 WHERE c.srecommend = @custid
		   AND c.roleid     = 1
		   AND c.Enabled    = 1
		   AND cs.AgentPT > b.AgentPT
		GROUP BY username

		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language
								   WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
								  END
				  , @ErrCode = 108
			RETURN
		END
	    
		--check PT on grouped settings
		 SELECT @ErrAcc = ''
		
		INSERT INTO @tmpPTGroup(custid)
		SELECT TOP 100 c.custid
		FROM custinfo c WITH(NOLOCK) 
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON c.custid = cs.custid
			INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
									AND cs.bettype = b.bettype
									AND cs.IsLive = b.IsLive
		 WHERE c.srecommend = @custid
		   AND c.roleid     = 2
		   AND c.Enabled    = 1
		   AND cs.AgentPT > b.AgentPT
		GROUP BY username
		
		SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
		 FROM custinfo c WITH(NOLOCK)
			INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
		WHERE c.recommend IN (SELECT custid FROM @tmpPTGroup)
			AND roleid = 1
			AND c.Enabled    = 1
			AND IsGrouped = 1
					
		IF @ErrAcc <> ''
		BEGIN
			SELECT @ErrMsg = @username + ': '
							   + CASE @Language
								   WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
								  END
				  , @ErrCode = 108
			RETURN
		END
	END
	
	--Update data change
	UPDATE cs
	SET cs.SuperPT = b.SuperPT
		,cs.MasterPT = b.MasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.SuperMinPT
		,cs.MaxPT = b.SuperPT	
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.SuperPT <> b.SuperPT
			OR cs.MasterPT <> b.MasterPT
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.SuperMinPT					
		)
	
	IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg = @UserName + ': '+
                        CASE @Language 
                            WHEN 'E' THEN 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        END    , @ErrCode = 109                    
        
        RETURN
    END
    
    IF @UpdatePresetPT = 1
    BEGIN
		EXEC dbo.Acc_CustSetting3rd_07 @srecommend = @custid, @roleid = 4, @mode = 'Others'
		
		EXEC dbo.Acc_CustSetting3rd_01 @srecommend = @custid, @mode = 'Others'
    END
    
    IF @UpdateMinPT = 1
    BEGIN
		EXEC dbo.Acc_CustSetting3rd_04 @srecommend = @srecommend, @roleid = 4, @mode = 'Others'
    END
    
    -- Write log after update
	SET @xml = (
			SELECT @custid AS '@ci'
					,@userid AS '@ui'
					,@langue AS '@l'
					,@IP AS '@Ip'
					,(
						SELECT cs.sporttype AS '@s'
							,cs.bettype AS '@b'
							,cs.isLive AS '@i'
							,cs.SuperPT AS '@s4'
							,cs.MasterPT AS '@m4'
							,cs.AgentPT AS '@a4'
							,cs.SuperMinPT AS '@n4'							
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
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 
 
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbExtAccNet]
GO 