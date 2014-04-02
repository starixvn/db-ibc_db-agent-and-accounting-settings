ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentKeno_MinMaxBet] 
(
	@CustId INT --agentID
	, @SportType INT = 202
	, @BetType INT --IBCBetTypeID
	, @MinBet MONEY
	, @MaxBet MONEY
	, @MaxPerMatch MONEY

	, @SubAccID INT = 0 --Sub-AccountID		
	, @UserID INT = 0
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(15) = ''
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140319@Patrick
	Task : Update agent's minbet, maxbet, max per match for Keno
	DB: DBTXN/CustDB
	Original: 

	Revisions:
	Param's Explanation:
	• @ErrCode:
		= 0: Update successfully.
		> 0: Specific Error.
  
	• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
	SELECT @ErrCode = 0, @ErrMsg = '', @startRun = GETDATE()

	DECLARE @MinMinBet MONEY, @MaxMaxBet MONEY, @MaxMaxPerMatch MONEY, @UserName VARCHAR(50), @mrecommend INT, @srecommend INT
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend
	FROM dbo.customer WITH (NOLOCK) WHERE CustID = @CustID AND roleid = 2

	IF (@UserName = NULL) RETURN
	IF (@MinBet < 0 OR @MaxBet < 0 OR @MaxPerMatch < 0)
	BEGIN
		SELECT @ErrCode = 101
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)	END
		RETURN
	END

	DECLARE @GameTypeID INT
	SELECT @GameTypeID = GameTypeID FROM bodb02.dbo.GameType WHERE IBCBetTypeID = @bettype

	SELECT @MinMinBet = 0, @MaxMaxBet = 0
	SELECT @MinMinBet = MAX(ISNULL(MinBet, 0))
		, @MaxMaxBet = MIN(ISNULL(MaxBet, 0))
		, @MaxMaxperMatch = MIN(ISNULL(cg.MaxPerGameType, 0))
	FROM dbo.CustGameType AS cg WITH (NOLOCK)
		INNER JOIN dbo.custinfo AS ci WITH (NOLOCK) ON cg.CustID = ci.custid
	WHERE cg.custid IN (@mrecommend, @srecommend) AND cg.GameTypeID = @GameTypeID

	IF (@MinBet <> 0 AND @MaxBet <> 0 AND @MinBet > @MaxBet)
		OR (@MaxBet <> 0 AND @MaxPerMatch <> 0 AND @MaxBet > @MaxPerMatch)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language)
				END + CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), @MinBet) + '-' + CONVERT(VARCHAR(20), @MaxBet) + '-' + CONVERT(VARCHAR(20), @MaxPerMatch)
			, @ErrCode = 102
		RETURN
	END

	IF (@MinMinBet > 0 AND @MinBet > 0 AND @MinBet < @MinMinBet)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Min bet must be equal to or greater than Master Agent min bet'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10019, @Language)
				END + ' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').'
			, @ErrCode = 103
		RETURN
	END

	IF (@MaxMaxBet > 0 AND @MaxBet > 0 AND @MaxBet > @MaxMaxBet)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Max bet must be equal to or less than Master Agent max bet'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10020, @Language)
				END + ' (' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').'
			, @ErrCode = 104
		RETURN
	END

	IF (@MaxMaxPerMatch > 0 AND @MaxPerMatch > 0 AND @MaxPerMatch > @MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Max Per Match must be equal to or less than Master Agent Max Per Match'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10021, @Language)
				END + ' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').'
			, @ErrCode = 111
		RETURN
	END

	--check old values and new values before update
	DECLARE @Old_MinBet MONEY, @Old_MaxBet MONEY, @Old_MaxPerGame MONEY

	SELECT @Old_MinBet = MinBet, @Old_MaxBet = MaxBet, @Old_MaxPerGame = MaxPerGameType
	FROM dbo.CustGameType AS cg WITH (NOLOCK)
	WHERE cg.custid = @custid AND GameTypeID = @GameTypeID

	--Check not change value
	IF (@Old_MinBet = @Minbet AND @Old_MaxBet = @MaxBet AND @Old_MaxPerGame = @MaxPerMatch)
		RETURN
	
	UPDATE dbo.CustGameType WITH (ROWLOCK, UPDLOCK)
	SET MinBet = @MinBet, MaxBet = @MaxBet, MaxPerGameType = @MaxPerMatch
	WHERE custid = @custid AND GameTypeID = @GameTypeID

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Update process is unsuccessful !'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)	END
			, @ErrCode = 105
		RETURN
	END

	-- Compare old value & new value Betting Limit: Popup Message For Betting Limit 
	IF @MinBet <> @Old_MinBet OR @MaxBet <> @Old_MaxBet OR @MaxPerMatch <> @Old_MaxPerGame
	BEGIN
		EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid
			, @userID = @UserID
			, @TypeID = 2
	END

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData = '<Acc_CustomerUpdAgentKeno_MinMaxBet CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MinBet="' + COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxBet="' + COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxPerMatch="' + COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdAgentKeno_MinMaxBet CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MinBet="' + COALESCE(CAST(@Old_MinBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxBet="' + COALESCE(CAST(@Old_MaxBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxPerMatch="' + COALESCE(CAST(@Old_MaxPerGame AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 381
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 381
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH
		---------------------------------------------------------
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentKeno_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentKeno_MinMaxBet] TO [vnteam] AS [dbo]
