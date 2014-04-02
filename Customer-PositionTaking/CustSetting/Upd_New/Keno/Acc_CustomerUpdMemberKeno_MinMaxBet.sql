ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet] 
	@CustID INT
	,@Bettype INT
	,@sporttype INT = 202
	,@MinBet MONEY
	,@MaxBet MONEY
	,@MaxPerMatch MONEY
	,@UserID INT = 0
	,@Language VARCHAR(2) = 'E'
	,@IP VARCHAR(15) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140319@Bobby
	Task : Update member's minbet, maxbet, max per match for Keno
	DB: DBTXN/CustDB

	Revisions:
							
							
	Param's Explanation:
	* @ErrCode:
		= 0: Transaction recorded successfully.
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
		,@endRun DATETIME
		,@duration INT
		,@minbet_old MONEY
		,@maxbet_old MONEY
		,@maxpermatch_old MONEY
		,@GameTypeID INT

	SET @GameTypeID = ISNULL(@GameTypeID, 0)
	SET @startRun = GETDATE()

	SELECT @ErrCode = 0
		,@ErrMsg = ''

	IF @MinBet < 0
		OR @MaxBet < 0
		OR @MaxPerMatch < 0
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)
				END
			,@ErrCode = 101

		RETURN
	END

	IF (
			(
				@MinBet <> 0
				AND @MaxBet <> 0
				AND @MinBet > @MaxBet
				)
			OR (
				@MinBet <> 0
				AND @MaxPerMatch <> 0
				AND @MinBet > @MaxPerMatch
				)
			OR (
				@MaxBet <> 0
				AND @MaxPerMatch <> 0
				AND @MaxBet > @MaxPerMatch
				)
			)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language)
				END
			,@ErrCode = 102

		RETURN
	END

	-- update CustGameType proccess
	SELECT @GameTypeID = g.GameTypeID
	FROM DBPRO.bodb02.dbo.GameType g WITH (NOLOCK)
	WHERE g.IBCBetTypeID = @Bettype
		AND g.IsDisabled = 0 -- active bettype

	SET @GameTypeID = ISNULL(@GameTypeID, 0)

	IF (@GameTypeID = 0)
	BEGIN
		SELECT @ErrMsg = 'Bettype is disabled. Update process is unsuccessful.'
			,@ErrCode = 103

		RETURN
	END

	SELECT @minbet_old = cg.MinBet
		,@maxbet_old = cg.MaxBet
		,@maxpermatch_old = cg.MaxPerGameType
	FROM CustGameType cg WITH (NOLOCK)
	WHERE custid = @CustID
		AND GameTypeID = @GameTypeID

	IF (
			@MinBet <> @minbet_old
			OR @MaxBet <> @maxbet_old
			OR @MaxPerMatch <> @maxpermatch_old
			)
	BEGIN
		UPDATE cg
		SET MinBet = @MinBet
			,MaxBet = @MaxBet
			,MaxPerGameType = @MaxPerMatch
		FROM CustGameType cg WITH (ROWLOCK, UPDLOCK)
		WHERE custid = @CustID
			AND gametypeid = @GameTypeID

		IF (@@error <> 0)
		BEGIN
			SELECT @ErrMsg = CASE @Language
					WHEN 'E' THEN 'Update process is unsuccessful!'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
					END
				,@ErrCode = 104

			RETURN
		END
	END

	DECLARE @LogSPData VARCHAR(MAX)
		,@TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' + 'sporttype="' + COALESCE(CAST(@sporttype AS VARCHAR(10)), SPACE(1)) + '" ' + 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' + 'MinB="' + coalesce(cast(@MinBet AS VARCHAR(50)), space(1)) + '" ' + 'MaxB="' + coalesce(cast(@MaxBet AS VARCHAR(50)), space(1)) + '" ' + 'MPM="' + coalesce(cast(@MaxPerMatch AS VARCHAR(50)), space(1)) + '" ' + 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' + 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' + 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' + 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' + 'ErrMsg="' + coalesce(cast(@ErrMsg AS NVARCHAR(4000)), space(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' + 'sporttype="' + COALESCE(CAST(@sporttype AS VARCHAR(10)), SPACE(1)) + '" ' + 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' + 'MinB="' + coalesce(cast(@MinBet_old AS VARCHAR(50)), space(1)) + '" ' + 'MaxB="' + coalesce(cast(@MaxBet_old AS VARCHAR(50)), space(1)) + '" ' + 'MPM="' + coalesce(cast(@MaxPerMatch_old AS VARCHAR(50)), space(1)) + '" ' + 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' + 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' + 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' + 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' + 'ErrMsg="' + coalesce(cast(@ErrMsg AS NVARCHAR(4000)), space(1)) + '" />'

	SET @endRun = getdate()
	SET @duration = datediff(millisecond, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 379
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValueDB
			,@duration = @duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@custid AS VARCHAR(50)), space(1)) + '" ' + 'sporttype="' + COALESCE(CAST(@sporttype AS VARCHAR(10)), SPACE(1)) + '" ' + 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' + 'MinB="' + coalesce(cast(@MinBet AS VARCHAR(50)), space(1)) + '" ' + 'MaxB="' + coalesce(cast(@MaxBet AS VARCHAR(50)), space(1)) + '" ' + 'MPM="' + coalesce(cast(@MaxPerMatch AS VARCHAR(50)), space(1)) + '" ' + 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' + 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' + 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' + 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' + 'ErrMsg="' + ERROR_MESSAGE() + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 379
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValueDB
			,@duration = @duration
	END CATCH
END
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet] TO [vnteam] AS [dbo]
GO


