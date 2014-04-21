ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking]
(
	@custid INT
	, @SportType INT = 202
	, @BetType INT

	, @MPositionTaking SMALLMONEY --m2
	, @Auto_MPositionTaking SMALLMONEY --um2
	, @IsAuto_MPositionTaking BIT = 0 --im2
	, @APositionTaking SMALLMONEY --a2
	, @APositiontaking_Min SMALLMONEY --n2
	
	, @UpdateAllMembers	BIT = 0
	, @NewMPositionTaking SMALLMONEY = 0 --equals max(m+a) - chosen(a)
	
	, @UpdatePositionTaking BIT = 0
	, @UpdateAutoPositionTaking	BIT = 0
	, @UpdateMinPositionTaking	BIT = 0
	
	, @SubAccID INT = 0 --Sub-AccountID		
	, @UserID	INT = 0
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(15) = ''
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140320@Patrick
	Task: Master update agent's Keno PT setting
	DB: DBTXN/CustDB
	
	Revisions:
	Parameters Explanation:
		@ErrCode: 0 is successful
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT, @UserName NVARCHAR(50), @mrecommend INT, @srecommend INT
		, @ErrAcc VARCHAR(4000), @ErrType VARCHAR(4000)
	SET @startRun = GETDATE()

	--Checking total downlines before UPDATEs 
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid = @custid
		, @roleid = 2
		, @isExecRep = 1
		, @isUpdatePT = 1
		, @Sporttype = 1
		, @Language = 'E'
		, @ErrMsg = @ErrMsg OUTPUT
		, @ErrCode = @ErrCode OUTPUT

	IF	@ErrCode <> 0 
		RETURN 
		
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE CustID = @CustID
	
	DECLARE @Old_APositionTaking SMALLMONEY, @Old_MPositionTaking SMALLMONEY
		, @Old_Auto_MPositionTaking SMALLMONEY,	@Old_IsAuto_MPositionTaking BIT
		, @MPositiontaking_Max SMALLMONEY, @MaxPos SMALLMONEY

	SELECT @Old_MPositionTaking = mpositiontaking, @Old_APositionTaking = apositiontaking
		, @Old_Auto_MPositionTaking = autompositiontaking, @Old_IsAuto_MPositiontaking = isautompositiontaking	
	FROM dbo.CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
	
	--check if not change setting
	IF (@Old_MPositionTaking = @MPositionTaking	AND @Old_APositionTaking = @APositionTaking
		AND @Old_Auto_MPositionTaking = @Auto_MPositionTaking AND @Old_IsAuto_MPositionTaking = @IsAuto_MPositionTaking)
		RETURN

	IF (@APositionTaking < 0 OR @MPositionTaking < 0 OR @APositionTaking + @MPositionTaking > 1)
	BEGIN
		SELECT @ErrCode = 100
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
		RETURN
	END
	
	--check n3<=m2+a2  if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM dbo.custoverrideGame co WITH(NOLOCK)
		INNER JOIN 
		(
			SELECT @BetType AS bettype, @SportType AS sporttype
				, @APositionTaking AS apositiontaking, @MPositionTaking AS mpositiontaking
				, @IsAuto_MPositionTaking AS isauto_mpositiontaking, @Auto_MPositionTaking AS auto_mpositiontaking
		) b ON co.bettype = b.bettype AND co.sporttype = b.sporttype
		INNER JOIN bodb02.dbo.bettype bt WITH(NOLOCK) ON b.bettype = bt.typeid
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype
	WHERE co.custid = @mrecommend
		AND (((b.isauto_mpositiontaking = 0) AND (b.mpositiontaking + b.apositiontaking < co.minpositiontaking)) 
			OR (b.isauto_mpositiontaking > 0 AND (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking)))

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 101
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
		RETURN
	END

	--n2<=a2
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM (SELECT @BetType AS bettype, @SportType AS sporttype, @APositiontaking_Min AS minpositiontaking) AS co
		INNER JOIN (SELECT @BetType AS bettype, @SportType AS sporttype, @APositionTaking AS apositiontaking) AS b
			ON co.bettype = b.bettype AND co.sporttype = b.sporttype
		INNER JOIN bodb02.dbo.bettype bt WITH(NOLOCK) ON b.bettype = bt.typeid
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype
	WHERE b.apositiontaking < co.minpositiontaking

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 102
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	SELECT @MPositiontaking_Max = mpositiontaking 
	FROM dbo.CustSettingGame WITH(NOLOCK) 
	WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType
	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType +  'Max: '+ CAST((b.max_mapositiontaking) AS VARCHAR(10)) + '<br>'
	FROM
	(
		SELECT @BetType AS bettype, @SportType AS sporttype, @APositionTaking AS apositiontaking
			, @MPositionTaking AS mpositiontaking, @MPositiontaking_Max AS max_mapositiontaking
	) b
		INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype
	WHERE (b.apositiontaking + b.mpositiontaking > b.max_mapositiontaking) 

	IF @ErrType <> ''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = @UserName + ': '+ CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	--check um2<=min(m3,l3)
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee + '-Max: '+ CAST(max_mapositiontaking AS VARCHAR(10)) + '<br>'
	FROM 
	(
		SELECT @BetType AS bettype, @SportType AS sporttype, @Auto_MPositionTaking as autopositiontaking
			, @IsAuto_MPositionTaking as isautopositiontaking, @MPositiontaking_Max as max_mapositiontaking
	) AS b 
		INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype
	WHERE b.isautopositiontaking = 1
		AND b.autopositiontaking > max_mapositiontaking
		

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrCode = 104
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
		RETURN
	END
	
	--update
	IF @UpdatePositiontaking = 1
	BEGIN	
		UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK)
		SET apositiontaking = @APositiontaking
			, mpositiontaking = @MPositiontaking
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ':' + CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 105
			RETURN
		END
	END
		
	--Update Master Agent account
	IF @UpdateAutoPositiontaking = 1
	BEGIN	
		UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK) 
		SET autompositiontaking	= @Auto_MPositionTaking
			, isautompositiontaking	= @IsAuto_MPositionTaking
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
					WHEN 'E' THEN 'Error updating auto position taking'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20010, @Language) END
				,  @ErrCode = 106
			RETURN
		END
		--Call execrep
		IF (@Auto_MPositionTaking <> @Old_Auto_MPositionTaking OR @IsAuto_MPositionTaking <> @Old_IsAuto_MPositionTaking)
		BEGIN
			EXEC dbo.Acc_CustSetting3rd_05_xtest @mrecommend = @mrecommend
					, @recommend = @custid
					, @roleid = 2
					, @mode = 'Keno'
					, @IsAuto_KenoMPositionTaking = @IsAuto_MPositiontaking
					, @Old_IsAuto_KenoMPositionTaking = @Old_IsAuto_MPositiontaking
					, @Auto_KenoMPositionTaking = @Auto_MPositionTaking
					, @UpdateAllMembers = @UpdateAllMembers
					, @NewMPositionTaking = @NewMPositionTaking
		END
	END
	
	IF (@UpdateAutoPositionTaking = 1 OR @UpdatePositionTaking = 1)
	BEGIN 
		EXEC dbo.Acc_CustSetting3rd_07_xtest @recommend = @custid, @roleid = 2, @mode = 'Keno'
		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 109					 
			RETURN
		END
	END

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData ='<Acc_CustomerUpdAgentKeno_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST(@UpdateAllMembers AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'NewMPositionTaking="' + COALESCE(CAST(@NewMPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'APositiontaking="' + COALESCE(CAST(@APositiontaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_MPositionTaking="' + COALESCE(CAST(@Auto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking="' + COALESCE(CAST(@IsAuto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB ='<Acc_CustomerUpdAgentKeno_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST(@UpdateAllMembers AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'NewMPositionTaking="' + COALESCE(CAST(@NewMPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'APositiontaking="' + COALESCE(CAST(@Old_APositiontaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_MPositionTaking="' + COALESCE(CAST(@Old_Auto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking="' + COALESCE(CAST(@Old_IsAuto_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	select @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 444
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 444
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentKeno_PositionTaking] TO [vnteam] AS [dbo]