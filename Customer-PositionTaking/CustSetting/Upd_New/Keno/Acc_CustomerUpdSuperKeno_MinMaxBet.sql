ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_MinMaxBet]
	@CustID			INT,
	@Sporttype		INT = 202,
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
	Created: 20140225@Elodie
	Task : Update super's minbet, maxbet, max per match for Keno
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
	DECLARE @startRun datetime, @endRun datetime, @duration int,
			@minbet_old money, @maxbet_old money, @maxpermatch_old money

	SET @startRun = GETDATE()

	DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	IF 
		@MinBet < 0
		or @MaxBet < 0
		or @MaxPerMatch <0	
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language 
							WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) END, 
				@ErrCode_Cur = 101
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END

	IF(@MinBet <> 0 AND @MaxBet <> 0 AND  @MinBet > @MaxBet) 
		or (@MaxBet <> 0 AND @MaxPerMatch <> 0 AND @MaxBet > @MaxPerMatch) 
		or (@MinBet <> 0 AND @MaxPerMatch <> 0 AND @MinBet > @MaxPerMatch) 
	BEGIN
		SELECT
			@ErrMsg_Cur =	CASE @Language 
								WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) END, 
			@ErrCode_Cur = 102
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END

	SELECT @minbet_old = cg.MinBet, @maxbet_old = cg.MaxBet, @maxpermatch_old = cg.MaxPerGameType
	FROM CustGameType cg WITH(NOLOCK)
		INNER JOIN bodb02.dbo.GameType gt ON cg.GameTypeID = gt.GameTypeID
	WHERE custid = @CustID and gt.IBCBetTypeID = @bettype

	IF @MinBet <> @minbet_old OR @MaxBet <> @maxbet_old OR @MaxPerMatch <> @maxpermatch_old
	BEGIN
		UPDATE cg with (ROWLOCK, UPDLOCK)
		SET	MinBet = @MinBet, 
			MaxBet= @MaxBet,
			MaxPerGameType = @MaxPerMatch
		FROM CustGameType cg INNER JOIN bodb02.dbo.GameType gt WITH (NOLOCK) ON cg.GameTypeID = gt.GameTypeID
		WHERE custid=@CustID AND gt.IBCBetTypeID = @bettype
	
		IF (@@error <> 0)
		BEGIN
			SELECT	@ErrMsg_Cur = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END, 
					@ErrCode_Cur = 103 
			RETURN
		END
	
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
		ELSE	
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END

	DECLARE @LogSPData VARCHAR (MAX),
			@TrackingValueDB VARCHAR(4000)
		
	Select @LogSPData ='<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
	'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
	'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY 
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 379,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData ='<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 379,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno_MinMaxBet] TO [vnteam] AS [dbo]