  ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTOnMemberUpd]
	@custid		INT,
	
	@PT			VARCHAR(MAX),
	
	@UserID		INT = 0,    
	@SubAccID	INT = 0, --Sub-AccountID  
    
    @Language	VARCHAR(2) = 'E',
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task: Update super's pt on member
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT =<Root>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="50" AutoSuperPT="0" IsAutoSuperPT="0" />
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" AutoSuperPT="0" IsAutoSuperPT="0" />
				</Root>
	*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @startRun		DATETIME  
			,@endRun		DATETIME  	
			,@duration		INT  
			,@logSPData		VARCHAR(5000)
			,@logSPDataOld	VARCHAR(5000)
			,@PT_Adjusted	VARCHAR(5000)
			,@PT_Corrected	VARCHAR(5000)
			,@xml			XML
			,@SettingMode	BIT = 0
			
	SET @startRun = GETDATE()
	
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging   
		 @SessionCustID = @Userid,   
		 @Custid = @custid,  		 
		 @roleid = @roleid OUTPUT  
	
	IF (@roleid <> 1) RETURN-- return if not member    
	
	--Check disable user  
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
			@custid = @custid
			,@ErrCode=@ErrCode OUTPUT
			,@ErrMsg=@ErrMsg OUTPUT  
			
	IF @ErrCode > 0  
		RETURN
	
	DECLARE @tblPT TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT		
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		)
	
	DECLARE @NewPT TABLE(
		SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT		
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		)	
		
	DECLARE @mrecommend INT
			,@recommend INT
			,@srecommend INT
			,@username VARCHAR(30)
							
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username   
	FROM customer WITH (NOLOCK)   
	WHERE custid = @custid 
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PT

	INSERT @tblPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
	SELECT SportType
			,BetType
			,IsLive
			,SuperPT
			,0
			,0
			,IsAutoSuperPT
			,AutoSuperPT
			,0
			,0
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsLive	BIT
			, SuperPT	TINYINT
			, AutoSuperPT TINYINT
			, IsAutoSuperPT BIT
			)

	EXEC sp_xml_removedocument @iDoc
		
	SELECT @SettingMode = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @CustID
	
	IF @SettingMode = 0
	BEGIN
		UPDATE b
		SET b.MasterPT = cs.MasterPT,
			b.AgentPT = cs.AgentPT,
			b.IsAutoMasterPT = cs.IsAutoMasterPT,
			b.AutoMasterPT = cs.AutoMasterPT
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.custid = @custid					
		
		INSERT @NewPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
		SELECT cs.SportType		
			, cs.BetType		
			, cs.ISLive	
			, cs.SuperPT							
			, cs.MasterPT	
			, cs.AgentPT		
			, cs.IsAutoSuperPT	
			, cs.AutoSuperPT	
			, cs.IsAutoMasterPT
			, cs.AutoMasterPT						
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.custid = @custid																	
																	
			
		 --log old data
		SET @xml =(
			SELECT @custid AS '@ci'
					,f_GetSubUsername(@SubAccID) AS '@su'
					,@userid AS '@ui'
					,@language AS '@l'
					,@IP AS '@Ip'					
					,(
						SELECT cs.sporttype AS '@s'
							,cs.bettype AS '@b'
							,cs.isLive AS '@i'
							,cs.SuperPT AS '@s1'
							,cs.isAutoSuperPT AS '@is1'
							,cs.AutoSuperPT AS '@us1'								
						FROM CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
													AND cs.bettype = t.BetType 
													AND cs.isLive = t.IsLive
						WHERE custid = @custid
						FOR XML PATH('pt'), TYPE
					)
			FOR XML PATH('r'), TYPE
		)
	END
	ELSE 
	BEGIN
		UPDATE b
		SET b.MasterPT = cs.MasterPT,
			b.AgentPT = cs.AgentPT,
			b.IsAutoMasterPT = cs.IsAutoMasterPT,
			b.AutoMasterPT = cs.AutoMasterPT
		FROM @tblPT b
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.AgentID = @recommend
		
		INSERT @NewPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
		SELECT cs.SportType		
			, cs.BetType		
			, cs.ISLive	
			, cs.SuperPT							
			, cs.MasterPT	
			, cs.AgentPT		
			, cs.IsAutoSuperPT	
			, cs.AutoSuperPT	
			, cs.IsAutoMasterPT
			, cs.AutoMasterPT						
		FROM @tblPT b
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.AgentID = @recommend
				
		 --log old data
		SET @xml =(
			SELECT @custid AS '@ci'
					,f_GetSubUsername(@SubAccID) AS '@su'
					,@userid AS '@ui'
					,@language AS '@l'
					,@IP AS '@Ip'					
					,(
						SELECT cs.sporttype AS '@s'
							,cs.bettype AS '@b'
							,cs.isLive AS '@i'
							,cs.SuperPT AS '@s1'
							,cs.isAutoSuperPT AS '@is1'
							,cs.AutoSuperPT AS '@us1'								
						FROM CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
													AND cs.bettype = t.BetType 
													AND cs.isLive = t.IsLive
						WHERE AgentID = @recommend
						FOR XML PATH('pt'), TYPE
					)
			FOR XML PATH('r'), TYPE
		)
	END
		
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)  
	
	SET @xml =(
			SELECT @custid AS '@ci'
					,f_GetSubUsername(@SubAccID) AS '@su'
					,@userid AS '@ui'
					,@language AS '@l'
					,@IP AS '@Ip'					
					,(
						SELECT cs.sporttype AS '@s'
							,cs.bettype AS '@b'
							,cs.isLive AS '@i'
							,cs.SuperPT AS '@s1'
							,cs.isAutoSuperPT AS '@is1'
							,cs.AutoSuperPT AS '@us1'								
						FROM @tblPT cs						
						FOR XML PATH('pt'), TYPE
					)
			FOR XML PATH('r'), TYPE
		)  
	SET @logSPData = CONVERT(VARCHAR(MAX), @xml)  
	
	--check any settings change
	IF NOT EXISTS(SELECT TOP 1 1 
				FROM @NewPT cs 
					INNER JOIN @tblPT b ON cs.SportType = b.SportType
											AND cs.BetType = b.BetType
											AND cs.IsLive = b.IsLive
				WHERE cs.SuperPT <> b.SuperPT
					OR cs.IsAutoSuperPT <> b.IsAutoSuperPT
					OR cs.AutoSuperPT <> b.AutoSuperPT
				)
		RETURN--no pt change
	
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTUpdCheck 
				@CustID = @CustID
				, @RoleID		= 4
				, @AgentID		= @recommend
				, @MasterID		= @mrecommend
				, @SuperID		= @srecommend
				, @PT_XML		= @PT
				
				, @Language		= @Language
				, @ErrCode		= @ErrCode	OUTPUT
				, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		
	
	--correct s1 if s1 + m1+ a1>s4	
	UPDATE b
	SET b.SuperPT = CASE WHEN scs.SuperPT - b.MasterPT - b.AgentPT > 0 
								THEN scs.SuperPT - b.MasterPT - b.AgentPT 
								ELSE 0 
							END
	FROM @tblPT b
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON b.SportType = scs.sporttype
																AND b.BetType = scs.bettype
																AND b.IsLive = scs.isLive
	WHERE scs.custid = @srecommend
		AND b.SuperPT + b.MasterPT + b.AgentPT > scs.SuperPT	
		
	--begin update pt change
																	
	--don't update s1 for member under master was set i3=1(normal) 
	 UPDATE cs
	 SET cs.SuperPT = b.SuperPT  
	 FROM @NewPT cs
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON  mcs.custid = @mrecommend
																AND cs.sporttype = mcs.sporttype 
																AND cs.bettype = mcs.bettype  
																AND cs.IsLive = mcs.isLive
		INNER JOIN @tblPT b ON b.SportType = cs.SportType
								AND b.BetType = cs.BetType
								AND b.IsLive = cs.IsLive															
	 WHERE mcs.IsAutoSuperPT = 0	
	 		 
	UPDATE cs
	SET	AutoSuperPT = b.AutoSuperPT,  
		IsAutoSuperPT = b.IsAutoSuperPT
	FROM @NewPT cs 
	INNER JOIN @tblPT b ON b.SportType = cs.SportType
							AND b.BetType = cs.BetType
							AND b.IsLive = cs.IsLive	  
  
	--correct pt
	SET @PT_Adjusted = 
		(
			SELECT SportType		
				, BetType		
				, ISLive	
				, SuperPT							
				, MasterPT	
				, AgentPT		
				, IsAutoSuperPT	
				, AutoSuperPT	
				, IsAutoMasterPT
				, AutoMasterPT
			FROM @tblPT
			FOR XML PATH('PT'), ROOT('ROOT')
		)
	
	EXEC Acc_CustSetting_MemberPTCorrect
			@AgentID = @recommend
			, @MasterID = @mrecommend
			, @SuperID = @srecommend
			, @PT_XML = @PT_Adjusted
			, @CorrectedPT_XML = @PT_Corrected OUTPUT
	
	DELETE @NewPT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PT_Corrected

	INSERT @NewPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
	SELECT SportType
			,BetType
			,IsLive
			,SuperPT
			,MasterPT
			,AgentPT
			,IsAutoSuperPT
			,AutoSuperPT
			,IsAutoMasterPT
			,AutoMasterPT
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsLive	BIT
			, SuperPT	TINYINT
			, MasterPT	TINYINT
			, AgentPT	TINYINT
			, AutoMasterPT TINYINT
			, IsAutoMasterPT BIT
			, AutoSuperPT TINYINT
			, IsAutoSuperPT BIT
			)

	EXEC sp_xml_removedocument @iDoc
		
	IF @SettingMode = 0
	BEGIN
		UPDATE cs
		SET cs.SuperPT = b.SuperPT
			,cs.MasterPT = b.MasterPT
			,cs.AgentPT = b.AgentPT
			,cs.isAutoSuperPT = b.isAutoSuperPT
			,cs.IsAutoMasterPT = b.IsAutoMasterPT
			,cs.AutoSuperPT = b.AutoSuperPT
			,cs.AutoMasterPT = b.AutoMasterPT
		FROM CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
			INNER JOIN @NewPT b ON cs.sporttype = b.SportType	
									AND cs.bettype = b.BetType
									AND cs.isLive = b.IsLive
		WHERE cs.custid = @custid
			AND (
					cs.SuperPT <> b.SuperPT
				OR cs.MasterPT <> b.MasterPT
				OR cs.AgentPT <> b.AgentPT
				OR cs.isAutoSuperPT <> b.isAutoSuperPT
				OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
				OR cs.AutoSuperPT <> b.AutoSuperPT
				OR cs.AutoMasterPT <> b.AutoMasterPT
			)
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
					FROM CustPTGroupSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
						INNER JOIN @NewPT b ON cs.sporttype = b.SportType	
												AND cs.bettype = b.BetType
												AND cs.isLive = b.IsLive
					WHERE cs.AgentID = @recommend
						AND (
								cs.SuperPT <> b.SuperPT
							OR cs.MasterPT <> b.MasterPT
							OR cs.AgentPT <> b.AgentPT
							OR cs.isAutoSuperPT <> b.isAutoSuperPT
							OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
							OR cs.AutoSuperPT <> b.AutoSuperPT
							OR cs.AutoMasterPT <> b.AutoMasterPT
						)		
				)
		RETURN
		
		--Move to Individual Setting
		INSERT INTO dbo.CustPTSetting3rd_Member
		SELECT
				@CustID,
				grpt.SportType,
				grpt.BetType,
				grpt.IsLive,
				grpt.SuperPT,
				grpt.MasterPT,
				grpt.AgentPT,
				grpt.IsAutoMasterPT,
				grpt.AutoMasterPT,
				grpt.IsAutoSuperPT,
				grpt.AutoSuperPT
		FROM dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
			LEFT JOIN dbo.CustPTSetting3rd_Member mempt ON mempt.CustID = @CustID
															AND grpt.SportType=mempt.SportType
															AND grpt.BetType=mempt.BetType
															AND grpt.IsLive=mempt.IsLive
		WHERE grpt.AgentID=@recommend AND mempt.CustID IS NULL
		
		--Update Adjusted PT for indiviual setting
		UPDATE cs
		SET cs.SuperPT=b.SuperPT,
			cs.MasterPT=b.MasterPT,
			cs.AgentPT=b.AgentPT,
			cs.isAutoSuperPT = b.isAutoSuperPT,
			cs.IsAutoMasterPT = b.IsAutoMasterPT,
			cs.AutoSuperPT = b.AutoSuperPT,
			cs.AutoMasterPT = b.AutoMasterPT
		FROM dbo.CustPTSetting3rd_Member cs WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewPT b ON  b.SportType=cs.SportType
									AND b.BetType=cs.BetType
									AND b.IsLive=cs.IsLive
		WHERE cs.CustID = @CustID AND
				(
						cs.SuperPT <> b.SuperPT
					OR cs.MasterPT <> b.MasterPT
					OR cs.AgentPT <> b.AgentPT
					OR cs.isAutoSuperPT <> b.isAutoSuperPT
					OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
					OR cs.AutoSuperPT <> b.AutoSuperPT
					OR cs.AutoMasterPT <> b.AutoMasterPT
				)
		
		---Update setting mode
		UPDATE dbo.CustSettingMode3rd WITH(ROWLOCK,UPDLOCK)
		SET IsGrouped = 0
		WHERE CustID = @CustID
		
	END
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	BEGIN TRY
		DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 455,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 455,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 	
	 
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbExtAccNet] AS [dbo]