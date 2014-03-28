ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet]
(
	@CustId INT --master
	, @SportType INT = 202
	, @BetType INT --IBCBetTypeID
	, @MinBet MONEY
	, @MaxBet MONEY
	, @MaxPerMatch MONEY
	
	, @SubAccID	INT = 0
	, @UserId INT
	, @IP VARCHAR(50)= ''
	, @Language	VARCHAR(20) = 'E'
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
 AS
/*
	Created: 20140325@Patrick
	Task: update bet setting of Keno on master
	DB: DBTXN/CustDB
		
	Revisions:
														
	Parameter's Explanation
		@ErrCode = -101 update successfully

*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun	DATETIME, @duration INT, @srecommend INT, @Username VARCHAR(50)
		, @MinMinBet MONEY, @MaxMaxBet MONEY, @MaxMaxPerMatch MONEY
		, @Old_MinBet MONEY, @Old_MaxBet MONEY,	@Old_MaxPerMatch MONEY, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = '', @startRun = GETDATE()
	
	SELECT @srecommend = srecommend, @UserName = username
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE custid = @custid AND roleid = 3

	IF @srecommend IS NULL
		RETURN
	--Check @MinBet, @MaxBet & @MaxPerMatch >= 0
	IF @MinBet < 0 OR @MaxBet < 0 OR @MaxPerMatch < 0
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)	END
			, @ErrCode_Cur = 101
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	--Check @MinBet <= @MaxBet <= @MaxPerMatch
	IF (@MinBet <> 0 AND @MaxBet <> 0 AND  @MinBet > @MaxBet) 
		OR (@MaxBet <> 0 AND @MaxPerMatch <> 0 AND @MaxBet > @MaxPerMatch) 
		OR (@MinBet <> 0 AND @MaxPerMatch <> 0 AND @MinBet > @MaxPerMatch)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language 
							WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language) END
			, @ErrCode_Cur = 102
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	
	DECLARE @GameTypeID INT
	SELECT @GameTypeID = GameTypeID FROM bodb02.dbo.GameType WHERE IBCBetTypeID = @BetType

	SELECT @MinMinBet = 0, @MaxMaxBet = 0
	SELECT @MinMinBet = MAX(ISNULL(MinBet, 0))
		, @MaxMaxBet = MIN(ISNULL(MaxBet, 0))
		, @MaxMaxPerMatch = MIN(ISNULL(cg.MaxPerGameType, 0))
	FROM dbo.CustGameType AS cg WITH (NOLOCK)
		INNER JOIN dbo.custinfo AS ci WITH (NOLOCK) ON cg.CustID = ci.custid
	WHERE cg.custid = @srecommend AND cg.GameTypeID = @GameTypeID
	
	--Check @MinBet >= @MinMinBet
	IF (@MinMinBet > 0 AND @MinBet > 0 AND @MinBet < @MinMinBet)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Min bet must be equal to or greater than Super Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10016, @Language) END +' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').'
				, @ErrCode_Cur = 103
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	--Check @MaxBet <= @MaxMaxBet
	IF (@MaxMaxBet > 0 AND @MaxBet > 0 AND @MaxBet > @MaxMaxBet)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Max bet must be equal to or less than Super Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10017, @Language) END +' (' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').'
				, @ErrCode_Cur = 104
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	--Check @MaxPerMatch <= @MaxMaxPerMatch
	IF (@MaxMaxPerMatch > 0 AND @MaxPerMatch > 0 AND @MaxPerMatch > @MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Max Per Match must be equal to or less than Super Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10018, @Language) END +' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').'
				, @ErrCode_Cur = 105
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	
	--check old values and new values before update
	SELECT @Old_MinBet = MinBet, @Old_MaxBet = MaxBet, @Old_MaxPerMatch = MaxPerGameType
	FROM dbo.CustGameType AS cg WITH (NOLOCK)
	WHERE cg.custid = @custid AND GameTypeID = @GameTypeID

	--Check not change value
	IF (@Old_MinBet = @MinBet AND @Old_MaxBet = @MaxBet AND @Old_MaxPerMatch = @MaxPerMatch)
		RETURN

	UPDATE dbo.CustGameType WITH (ROWLOCK, UPDLOCK)
	SET MinBet = @MinBet, MaxBet = @MaxBet, MaxPerGameType = @MaxMaxPerMatch
	WHERE custid = @custid AND GameTypeID = @GameTypeID

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)	END
			, @ErrCode_cur = 106
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END
	ELSE
		SELECT @ErrCode = '-101', @ErrMsg = @ErrMsg + CHAR(7)
		
	DECLARE @LogSPData VARCHAR(5000), @TrackingValueDB VARCHAR(4000)
	SELECT @LogSPData ='<Acc_CustomerUpdMasterKeno_MinMaxBet CustId="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="'+ COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'BetType="'+ COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg as varchar(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB ='<Acc_CustomerUpdMasterKeno_MinMaxBet CustId="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="'+ COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'BetType="'+ COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MinB="'+ COALESCE(CAST(@Old_MinBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MaxB="'+ COALESCE(CAST(@Old_MaxBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPM="'+ COALESCE(CAST(@Old_MaxPerMatch AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg as varchar(5000)), SPACE(1)) + '" />'
	
	SELECT @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 380,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 380,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet] TO [vnteam] AS [dbo]