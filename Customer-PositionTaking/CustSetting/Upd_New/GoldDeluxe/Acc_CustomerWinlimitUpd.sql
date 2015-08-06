USE CustDB
GO
ALTER PROCEDURE dbo.Acc_CustomerWinLimitUpd @CustId INT
	, @MaxWinLimit SMALLMONEY
	, @IsAutoReset BIT
	, @SportType SMALLINT
	, @BetType SMALLINT
	, @SubAccId INT = 0 -- Sub Account  
	, @IP VARCHAR(50) = ''
	, @UserId INT = 0
	, @Language VARCHAR(20) = 'E'
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*  
  Created: 20150706@Patrick  
  Task: update win limit on customer  
  DB: DBCUST/CustDB  
    
  Revisions:  
  Parameters Explanation:    
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @RoleId TINYINT, @ErrAcc NVARCHAR(4000)
	SET @StartRun = GETDATE()

	SELECT @ErrCode = 0, @ErrMsg = ''
	EXEC Age_CustomerSelCheckBelongingByCustID
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode > 0
	BEGIN	
		RETURN
	END

	DECLARE @MaxWinLimit_Old SMALLMONEY, @IsAutoReset_Old BIT, @UplineMaxWinLimit SMALLMONEY, @UplineIsAutoReset BIT

	SELECT @RoleID = roleid
	FROM dbo.Custinfo WITH (NOLOCK)
	WHERE CustID = @CustId

	SELECT @MaxWinLimit_Old = ISNULL(MaxWinLimit, 0), @IsAutoReset_Old = ISNULL(IsAutoReset, 0)
	FROM dbo.CustWinLimit WITH (NOLOCK)
	WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType
	
	IF @RoleId NOT IN (1, 2, 3, 4)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Invalid user!'
				ELSE dbo.f_Get_MsgNamebyMsgID(40002, @Language)
				END, @ErrCode = 100

		RETURN
	END

	-- not change  
	IF @MaxWinLimit_Old = @MaxWinLimit
		AND @IsAutoReset_Old = @IsAutoReset
	BEGIN
		RETURN
	END

	-- if update MaxWinLiveCasino  
	IF @MaxWinLimit_Old != @MaxWinLimit
		OR @IsAutoReset = 1 -- check status upline  
	BEGIN
		IF @RoleId = 3
		BEGIN
			SELECT @UplineMaxWinLimit = ISNULL(MaxWinLimit, 0), @UplineIsAutoReset = ISNULL(IsAutoReset, 0)
			FROM dbo.CustWinLimit WITH (NOLOCK)
			WHERE CustId = (SELECT srecommend
							FROM dbo.custInfo WITH (NOLOCK)
							WHERE custid = @CustId
					)
				 AND SportType = @SportType AND BetType = @BetType
		END

		IF @RoleId = 2
		BEGIN
			SELECT @UplineMaxWinLimit = ISNULL(MaxWinLimit, 0), @UplineIsAutoReset = ISNULL(IsAutoReset, 0)
			FROM dbo.CustWinLimit WITH (NOLOCK)
			WHERE CustId = (SELECT mrecommend
							FROM dbo.custInfo WITH (NOLOCK)
							WHERE custid = @CustId
					)
				 AND SportType = @SportType AND BetType = @BetType
		END

		IF @RoleID = 1
		BEGIN
			SELECT @UplineMaxWinLimit = ISNULL(MaxWinLimit, 0), @UplineIsAutoReset = ISNULL(IsAutoReset, 0)
			FROM dbo.CustWinLimit WITH (NOLOCK)
			WHERE CustId = (SELECT recommend
							FROM dbo.custInfo WITH (NOLOCK)
							WHERE custid = @CustId
					)
				 AND SportType = @SportType AND BetType = @BetType
		END

		IF @RoleID = 4
		BEGIN
			SELECT @UplineMaxWinLimit = 0, @UplineIsAutoReset = 1 --not checking the upline when the customer is the super
		END
	END

	IF @MaxWinLimit_Old != @MaxWinLimit
	BEGIN
		IF @UplineMaxWinLimit > 0
			AND (@MaxWinLimit = 0 OR @UplineMaxWinLimit < @MaxWinLimit)
		BEGIN
			SELECT @ErrMsg = CASE @Language	WHEN 'E' 
								THEN 'Maximum Win should be less than or equal to Maximum Win of Direct Upline!'
								ELSE dbo.f_Get_MsgNamebyMsgID(10024, @Language) END
				, @ErrCode = 101

			RETURN
		END
	END

	IF @IsAutoReset = 1
		AND @UplineIsAutoReset = 0
	BEGIN
		SELECT @ErrMsg = CASE @Language	WHEN 'E' 
							THEN 'You are not allowed to change Daily auto reset limit.'
							ELSE dbo.f_Get_MsgNamebyMsgID(10022, @Language)	END
			, @ErrCode = 102

		RETURN
	END

	UPDATE dbo.CustWinLimit WITH (UPDLOCK, ROWLOCK)
	SET IsAutoReset = @IsAutoReset, MaxWinLimit = @MaxWinLimit
	WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language	WHEN 'E' 
							THEN 'Update process is unsuccessful !'
							ELSE dbo.f_Get_MsgNamebyMsgID(90001, @Language)	END
			, @ErrCode = 103

		RETURN
	END

	-- update to downline if new value of max win < current value or turn off daily reset  
	IF (@IsAutoReset_Old != @IsAutoReset AND @IsAutoReset = 0)
		OR (@MaxWinLimit_Old != @MaxWinLimit
			AND @MaxWinLimit > 0
			AND (@MaxWinLimit_Old = 0 OR @MaxWinLimit < @MaxWinLimit_Old))
	BEGIN
		EXEC dbo.Acc_CustomerInfo_Execrep_08 @CustId = @CustId
			, @RoleId = @RoleId
			, @MaxWinLimit = @MaxWinLimit
			, @IsAutoReset = @IsAutoReset
			, @SportType = @SportType
			, @BetType = @BetType
			, @Mode = 'GoldDeluxe'
			
	END

	--DECLARE @Today SMALLDATETIME
	--SET @Today = CONVERT(NVARCHAR(10), CURRENT_TIMESTAMP, 120)

	----for weekly reset, insert default balance for member if not exists to keep track balance 
	--IF @MaxWinLimit > 0
	--BEGIN			
	--	-- if customer is weekly reset then insert default balance
	--	EXEC DBTXN.bodb02.dbo.Acc_MemberWinlossGameIns @CustId = @CustId
	--		, @SportType = @SportType
	--		, @BetType = @BetType
	--		, @RoleId = @RoleId
	--		, @IsAutoReset = @IsAutoReset
	--		, @ErrCode = @ErrCode OUTPUT
	--		, @ErrMsg = @ErrMsg OUTPUT

	--	IF @ErrCode <> 0
	--	BEGIN			
	--		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful.'
	--										ELSE dbo.f_Get_MsgNamebyMsgID(90001, @Language) END
	--		RETURN
	--	END
	--END	

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)

	SELECT @LogSPData = '<Acc_CustomerWinlimitUpd Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'MaxWinLimit="' + CASE WHEN @MaxWinLimit = 0 THEN 'Unlimited'
								ELSE CASE WHEN @MaxWinLimit - FLOOR(@MaxWinLimit) > 0 
									THEN COALESCE(CAST(@MaxWinLimit AS VARCHAR(50)), SPACE(1)) + 'X'
									ELSE COALESCE(CAST(CAST(@MaxWinLimit AS INT) AS VARCHAR(50)), SPACE(1)) + 'X' END -- cut off decimal  
							END + '" ' 
		+ 'IsAutoReset="' + COALESCE(CAST(@IsAutoReset AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
		+ 'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' 
		+ 'IP="' + COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerWinlimitUpd Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'MaxWinLimit="' + CASE WHEN @MaxWinLimit_Old = 0 THEN 'Unlimited'
									ELSE CASE WHEN @MaxWinLimit_Old - FLOOR(@MaxWinLimit_Old) > 0 
										THEN COALESCE(CAST(@MaxWinLimit_Old AS VARCHAR(50)), SPACE(1)) + 'X'
										ELSE COALESCE(CAST(CAST(@MaxWinLimit_Old AS INT) AS VARCHAR(50)), SPACE(1)) + 'X' END-- cut off decimal  
								END + '" ' 
		+ 'IsAutoReset="' + COALESCE(CAST(@IsAutoReset_Old AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
		+ 'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' 
		+ 'IP="' + COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' 
		+ 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	--Log customer info   
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 390
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @Duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerWinlimitUpd Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'MaxWinLimit="' + CASE WHEN @MaxWinLimit = 0 THEN 'Unlimited'
									ELSE CASE WHEN @MaxWinLimit - FLOOR(@MaxWinLimit) > 0 
										THEN COALESCE(CAST(@MaxWinLimit AS VARCHAR(50)), SPACE(1)) + 'X'
										ELSE COALESCE(CAST(CAST(@MaxWinLimit AS INT) AS VARCHAR(50)), SPACE(1)) + 'X' END -- cut off decimal  
								END + '" ' 
			+ 'IsAutoReset="' + COALESCE(CAST(@IsAutoReset AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' 
			+ 'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' 
			+ 'IP="' + COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' 
			+ 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID, @CustID = @CustID
			, @ActionID = 390
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @Duration
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitUpd] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitUpd] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitUpd] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerWinLimitUpd] TO [vnteam] AS [dbo]
GO
