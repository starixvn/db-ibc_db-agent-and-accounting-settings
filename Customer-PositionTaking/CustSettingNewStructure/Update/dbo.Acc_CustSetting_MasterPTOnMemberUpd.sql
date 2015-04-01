 ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTOnMemberUpd]
	@custid		INT,
	
	@PT			VARCHAR(MAX),
	
	@UserID		INT = 0,    
	@SubAccID	INT = 0, --Sub-AccountID     
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2014-12-18
		Task: Update master's pt on member
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT =<ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MasterPT="50" AutoMasterPT="0" IsAutoMasterPT="0" />
					<PT SportType="1" BetType="1" IsLive="1" MasterPT="30" AutoMasterPT="0" IsAutoMasterPT="0" />
				</ROOT>	
	*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @startRun		DATETIME  
			,@endRun		DATETIME  	
			,@duration		INT  
			,@roleid		INT
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
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 
		
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
			,0
			,MasterPT
			,0
			,0
			,0
			,IsAutoMasterPT
			,AutoMasterPT
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsLive	BIT
			, MasterPT	TINYINT
			, AutoMasterPT TINYINT
			, IsAutoMasterPT BIT
			)

	EXEC sp_xml_removedocument @iDoc
	
	SELECT @SettingMode = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @CustID
	
	IF @SettingMode = 0
	BEGIN
		UPDATE b
		SET b.SuperPT = cs.SuperPT
			,b.AgentPT = cs.AgentPT
			,b.IsAutoSuperPT = cs.IsAutoSuperPT
			,b.AutoSuperPT = cs.AutoSuperPT
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
			SELECT @custid AS '@custid'
					,dbo.f_GetSubUsername(@SubAccID) AS '@subAccName'
					,@userid AS '@userid'					
					,@IP AS '@Ip'					
					,(
						SELECT cs.sporttype
							,cs.bettype 
							,cs.isLive 
							,cs.MasterPT
							,cs.isAutoMasterPT 
							,cs.AutoMasterPT 							
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
		SET b.SuperPT = cs.SuperPT
			,b.AgentPT = cs.AgentPT
			,b.IsAutoSuperPT = cs.IsAutoSuperPT
			,b.AutoSuperPT = cs.AutoSuperPT
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
			SELECT @custid AS '@custid'
					,dbo.f_GetSubUsername(@SubAccID) AS '@subAccName'
					,@userid AS '@userid'					
					,@IP AS '@Ip'					
					,(
						SELECT cs.sporttype 
							,cs.bettype 
							,cs.isLive 
							,cs.MasterPT 
							,cs.isAutoMasterPT
							,cs.AutoMasterPT 							
						FROM CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
													AND cs.bettype = t.BetType 
													AND cs.isLive = t.IsLive
						WHERE cs.AgentID = @custid
						FOR XML PATH('pt'), TYPE
					)
			FOR XML PATH('r'), TYPE
		)
	END
	
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)  
	
	 --log old data
	SET @xml =(
		SELECT @custid AS '@custid'
				,dbo.f_GetSubUsername(@SubAccID) AS '@subAccName'
				,@userid AS '@userid'				
				,@IP AS '@Ip'					
				,(
					SELECT cs.sporttype
						,cs.bettype
						,cs.isLive 
						,cs.MasterPT
						,cs.isAutoMasterPT
						,cs.AutoMasterPT 						
					FROM @tblPT cs 					
					FOR XML PATH('pt'), TYPE
				)
		FOR XML PATH('r'), TYPE
	)
	
	--check any settings change
	IF NOT EXISTS(SELECT TOP 1 1 
				FROM @NewPT cs 
					INNER JOIN @tblPT b ON cs.SportType = b.SportType
											AND cs.BetType = b.BetType
											AND cs.IsLive = b.IsLive
				WHERE cs.MasterPT <> b.MasterPT
					OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
					OR cs.AutoMasterPT <> b.AutoMasterPT
				)
		RETURN--no pt change
		
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
				@CustID = @CustID
				, @RoleID		= 3
				, @AgentID		= @recommend
				, @MasterID		= @mrecommend
				, @SuperID		= @srecommend
				, @PT_XML		= @PT

				, @ErrCode		= @ErrCode	OUTPUT
				, @MsgType		= @MsgType  OUTPUT
				, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		
	
	--adjust pt before update
	--m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1  
	UPDATE cs
	SET cs.MasterPT = CASE WHEN scs.MasterPT > mcs.MasterPT 
							THEN mcs.MasterPT - cs.AgentPT 
							ELSE scs.MasterPT - cs.AgentPT 
						END
	FROM @tblPT cs
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
																AND scs.sporttype = cs.sporttype
																AND scs.bettype = cs.bettype
																AND scs.isLive = cs.isLive
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																AND mcs.sporttype = cs.sporttype
																AND mcs.bettype = cs.bettype
																AND mcs.isLive = cs.isLive																
	WHERE cs.MasterPT + cs.AgentPT > (CASE WHEN scs.MasterPT > mcs.MasterPT 
											THEN mcs.MasterPT ELSE scs.MasterPT
										END
									)																
	
	--m1=m1+a1<n3?n3-a1:m1  
	UPDATE cs
	SET cs.MasterPT = CASE WHEN	mcs.MinPT -cs.AgentPT > 0 
								THEN 0 ELSE mcs.MinPT -cs.AgentPT 
							END
	FROM @tblPT cs
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																AND mcs.sporttype = cs.sporttype
																AND mcs.bettype = cs.bettype
																AND mcs.isLive = cs.isLive																
	 WHERE cs.MasterPT + cs.AgentPT < mcs.MinPT		
	 
	----------------***Use Auto Position Taking***----------------------------------  
	--m1=im>0?min(um,m3-a1):m1  
	UPDATE cs
	SET cs.MasterPT = CASE WHEN mcs.MasterPT - cs.AgentPT > ( CASE WHEN cs.IsAutoMasterPT = 1 
																		THEN cs.AutoMasterPT 
																		ELSE acs.AutoMasterPT 
																	END
															)
								THEN ( CASE WHEN cs.IsAutoMasterPT = 1 
												THEN cs.AutoMasterPT 
												ELSE acs.AutoMasterPT 
											END
									)
								ELSE mcs.MasterPT - cs.AgentPT
							END															
	FROM @tblPT cs
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																AND mcs.sporttype = cs.sporttype
																AND mcs.bettype = cs.bettype
																AND mcs.isLive = cs.isLive																
		INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON acs.custid = @recommend
																AND acs.sporttype = cs.sporttype
																AND acs.bettype = cs.bettype
																AND acs.isLive = cs.isLive																																
	WHERE cs.IsAutoMasterPT = 1 OR acs.IsAutoMasterPT = 1																
	 
	---------------------------------------------------------------------------------------------------------------------------------------------  
	--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)  
	----------------***Use Auto Position Taking***----------------------------------  
	--s1=is>0?(us,s4-m1-a1):s1
	UPDATE cs
	SET cs.SuperPT = CASE WHEN scs.SuperPT - cs.MasterPT - cs.AgentPT > ( CASE WHEN cs.IsAutoSuperPT = 1 
																					THEN cs.AutoSuperPT 
																					ELSE mcs.AutoSuperPT 
																				END
																		)
								THEN ( CASE WHEN cs.IsAutoSuperPT = 1 
												THEN cs.AutoSuperPT 
												ELSE mcs.AutoSuperPT 
											END
									)
								ELSE scs.SuperPT - cs.MasterPT - cs.AgentPT
							END															
	FROM @tblPT cs
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
																AND scs.sporttype = cs.sporttype
																AND scs.bettype = cs.bettype
																AND scs.isLive = cs.IsLive
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																AND mcs.sporttype = cs.sporttype
																AND mcs.bettype = cs.bettype
																AND mcs.isLive = cs.isLive																
		INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON acs.custid = @recommend
																AND acs.sporttype = cs.sporttype
																AND acs.bettype = cs.bettype
																AND acs.isLive = cs.isLive																																																																																			
	WHERE cs.IsAutoSuperPT = 1 OR mcs.IsAutoSuperPT = 1	
	
	--s1=s1>(is?s4:s4-m3)?(is?s4:s4-m3):s1
	UPDATE cs
	SET cs.SuperPT = CASE WHEN cs.IsAutoSuperPT = 1 OR mcs.IsAutoSuperPT = 1
								THEN scs.SuperPT
								ELSE scs.SuperPT - mcs.MasterPT
							END
	FROM @tblPT cs
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
																AND scs.sporttype = cs.sporttype
																AND scs.bettype = cs.bettype
																AND scs.isLive = cs.IsLive
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
																AND mcs.sporttype = cs.sporttype
																AND mcs.bettype = cs.bettype
																AND mcs.isLive = cs.isLive																
	WHERE cs.SuperPT > (CASE WHEN cs.IsAutoSuperPT = 1 OR mcs.IsAutoSuperPT = 1
								THEN scs.SuperPT
								ELSE scs.SuperPT - mcs.MasterPT
							END
						)	
	
	--update pt change
	--don't update m1,s1 for member under agent was set im2=1  
	UPDATE cs
	SET MasterPT = b.MasterPT ,  
		SuperPT = b.SuperPT  
	FROM @NewPT cs 
		INNER JOIN @tblPT b ON cs.SportType = b.SportType
								AND cs.BetType = b.BetType
								AND cs.IsLive = b.IsLive
		INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON acs.custid = @recommend
																AND cs.sporttype = acs.sporttype 
																AND cs.bettype = acs.bettype   
																AND cs.IsLive = acs.IsLive
	WHERE acs.IsAutoMasterPT = 0   	 
	
	--Update auto PT  
	--------------------------------------------------------  
	--Update Member account (autompositiontaking field)
	UPDATE cs
	SET AutoMasterPT =  b.AutoMasterPT,   
		IsAutoMasterPT = b.IsAutoMasterPT
	FROM @NewPT cs 
		INNER JOIN @tblPT b ON cs.SportType = b.SportType
								AND cs.BetType = b.BetType
								AND cs.IsLive = b.IsLive  
	 	
	UPDATE cs
	SET cs.MasterPT = CASE WHEN mcs.MasterPT - cs.AgentPT > (CASE WHEN cs.IsAutoMasterPT = 1
																		THEN cs.AutoMasterPT
																		ELSE acs.AutoMasterPT
																	END	
															)
								THEN (CASE WHEN cs.IsAutoMasterPT = 1
												THEN cs.AutoMasterPT
												ELSE acs.AutoMasterPT
											END	
									)
								ELSE mcs.MasterPT - cs.AgentPT
							END																
	FROM @NewPT cs
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
															AND mcs.sporttype = cs.sporttype
															AND mcs.bettype = cs.bettype
															AND mcs.isLive = cs.isLive																
		INNER JOIN CustPTSetting3rd_Agent acs WITH(NOLOCK) ON acs.custid = @recommend
															AND cs.sporttype = acs.sporttype 
															AND cs.bettype = acs.bettype   
															AND cs.IsLive = acs.IsLive																	
	WHERE cs.IsAutoMasterPT = 1 OR acs.IsAutoMasterPT = 1																
	
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
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 456,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 456,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 	
	
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbExtAccNet] AS [dbo]