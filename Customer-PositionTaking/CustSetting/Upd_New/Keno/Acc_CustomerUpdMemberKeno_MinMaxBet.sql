ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet]
	@CustID			INT,
	@Bettype		INT,

	@MinBet			MONEY,
	@MaxBet			MONEY,
	@MaxPerMatch	MONEY,

	@UserID			INT = 0,	
	@Language		VARCHAR(2) = 'E',
	@IP				VARCHAR(15)='',
	@ErrCode		VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg			NVARCHAR(4000) = '' OUTPUT
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

	SET @startRun = GETDATE()

	DECLARE @ErrCode_Cur INT
		,@ErrMsg_Cur NVARCHAR(4000)

	SELECT @ErrCode_Cur = 0
		,@ErrMsg_Cur = ''
		,@ErrCode = ''
		,@ErrMsg = ''

	IF @MinBet < 0
		OR @MaxBet < 0
		OR @MaxPerMatch < 0
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language
				WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)
				END
			,@ErrCode_Cur = 101

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
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
		SELECT @ErrMsg_Cur = CASE @Language
				WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language)
				END
			,@ErrCode_Cur = 102

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
	END

	-- update CustGameType proccess
	SELECT @GameTypeID = g.GameTypeID
	FROM dbo.GameType g WITH (NOLOCK)
	WHERE g.IBCBetTypeID = @Bettype
		AND g.IsDisabled = 0 -- active bettype

	SET @GameTypeID = ISNULL(@GameTypeID, 0)

	IF (@GameTypeID = 0)
	BEGIN
		SELECT @ErrMsg = 'Bettype is disabled. Update process is unsuccessful.'
			,@ErrCode = 105

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
			SELECT @ErrMsg_Cur = CASE @Language
					WHEN 'E' THEN 'Update process is unsuccessful!'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
					END
				,@ErrCode_Cur = 103

			RETURN
		END

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7)
				,@ErrMsg = @ErrMsg + CHAR(7)
	END

	DECLARE @LogSPData VARCHAR(MAX)
		,@TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MinB="' + coalesce(cast(@MinBet AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MaxB="' + coalesce(cast(@MaxBet AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MPM="' + coalesce(cast(@MaxPerMatch AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS NVARCHAR(4000)), space(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' 
		+ 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MinB="' + coalesce(cast(@MinBet_old AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MaxB="' + coalesce(cast(@MaxBet_old AS VARCHAR(50)), space(1)) + '" ' 
		+ 'MPM="' + coalesce(cast(@MaxPerMatch_old AS VARCHAR(50)), space(1)) + '" ' 
		+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" '
		+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
		+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
		+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' 
		+ 'ErrMsg="' + coalesce(cast(@ErrMsg AS NVARCHAR(4000)), space(1)) + '" />'

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
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet custid="' + coalesce(cast(@custid AS VARCHAR(50)), space(1)) + '" ' 
			+ 'bettype="' + coalesce(cast(@bettype AS VARCHAR(50)), space(1)) + '" ' 
			+ 'MinB="' + coalesce(cast(@MinBet AS VARCHAR(50)), space(1)) + '" ' 
			+ 'MaxB="' + coalesce(cast(@MaxBet AS VARCHAR(50)), space(1)) + '" ' 
			+ 'MPM="' + coalesce(cast(@MaxPerMatch AS VARCHAR(50)), space(1)) + '" '
			+ 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' 
			+ 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' 
			+ 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" ' 
			+ 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(300)), space(1)) + '" ' 
			+ 'ErrMsg="' + ERROR_MESSAGE() + '" />'

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



