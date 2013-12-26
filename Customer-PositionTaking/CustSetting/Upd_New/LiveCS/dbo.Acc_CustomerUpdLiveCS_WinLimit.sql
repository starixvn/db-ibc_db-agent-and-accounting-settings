ALTER PROCEDURE [dbo].[Acc_CustomerUpdLiveCS_WinLimit] 
	@custid		INT,
	@MaxWinLiveCasino		SMALLMONEY,
	@isAutoResetLiveCasino	BIT,
	
	@SubAccID	INT = 0, -- Sub Account
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Dan
		Date: 2012-09-26
		Task: update win limit on customer
		DB: DBCUST/CustDB
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: change linked server BD053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20130808@Elodie: Splitting bodb02 into CustDB (Insert/Delete BalanceCreditGame, BalanceDebitGame by link database)
		Parameters Explanation:		
	*/
SET NOCOUNT ON

DECLARE @startRun DATETIME, @endRun DATETIME ,@duration INT

SET @startRun = GETDATE()

DECLARE @roleid TINYINT, @ErrAcc NVARCHAR(4000)
SELECT @ErrCode = 0, @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
IF @ErrCode > 0
BEGIN	
	RETURN
END
--end
DECLARE @MaxWinLiveCasino_old SMALLMONEY, 
		@isAutoResetLiveCasino_old BIT,
		@UplineMaxWinLiveCasino SMALLMONEY,
		@UplineIsAutoResetLiveCasino BIT

SELECT @MaxWinLiveCasino_old = ISNULL(MaxWinLiveCasino,0),
	@isAutoResetLiveCasino_old = ISNULL(isAutoResetLiveCasino,0),
	@RoleID = RoleID
FROM Custinfo with (nolock)
WHERE CustID = @CustID

if @RoleID not in (1,2,3,4)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Invalid user!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
					end, @ErrCode = 100	
	return
END

-- not change
IF @MaxWinLiveCasino_old = @MaxWinLiveCasino AND @isAutoResetLiveCasino_old = @isAutoResetLiveCasino
	RETURN

-- if update MaxWinLiveCasino
IF @MaxWinLiveCasino_old != @MaxWinLiveCasino  or @isAutoResetLiveCasino = 1 -- check status upline
BEGIN			
	IF @RoleID = 3
		SELECT @UplineMaxWinLiveCasino = isnull(MaxWinLiveCasino,0), @UplineIsAutoResetLiveCasino =  isnull(IsAutoResetLiveCasino,0)
		FROM CustInfo with (nolock)
		WHERE custid = (SELECT SRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 2
		SELECT @UplineMaxWinLiveCasino = isnull(MaxWinLiveCasino,0) , @UplineIsAutoResetLiveCasino =  isnull(IsAutoResetLiveCasino,0)
		FROM CustInfo with (nolock)
		WHERE custid = (SELECT MRecommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 1
		SELECT @UplineMaxWinLiveCasino = isnull(MaxWinLiveCasino,0) , @UplineIsAutoResetLiveCasino =  isnull(IsAutoResetLiveCasino,0)
		FROM CustInfo with (nolock)
		WHERE custid = (SELECT Recommend FROM Custinfo with (nolock) WHERE custid = @CustID)
	IF @RoleID = 4 
		SELECT @UplineMaxWinLiveCasino = 0, @UplineIsAutoResetLiveCasino = 1   --not checking the upline when the customer is the super
END		

IF @MaxWinLiveCasino_old != @MaxWinLiveCasino  
BEGIN
	IF @UplineMaxWinLiveCasino > 0 AND 
		(@MaxWinLiveCasino = 0 OR @UplineMaxWinLiveCasino<@MaxWinLiveCasino)		
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Maximum Win should be less than or equal to Maximum Win of Direct Upline!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10024,@Language)
						END, @ErrCode = 101
		RETURN
	END 
END

IF @isAutoResetLiveCasino = 1 AND @UplineIsAutoResetLiveCasino = 0
BEGIN
	SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to change Daily auto reset limit.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10022,@Language)
						END, @ErrCode = 102		
	RETURN	
END


UPDATE Custinfo WITH(UPDLOCK,ROWLOCK) 
SET  isAutoResetLiveCasino = @isAutoResetLiveCasino,
	MaxWinLiveCasino = @MaxWinLiveCasino
WHERE custid = @custid 

IF (@@ERROR <> 0)
BEGIN	
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END	, @ErrCode = 103
	RETURN
END

-- update to downline if new value of max win < current value or turn off daily reset
IF (@isAutoResetLiveCasino_old != @isAutoResetLiveCasino and @isAutoResetLiveCasino=0) 
	OR	(@MaxWinLiveCasino_old != @MaxWinLiveCasino and @MaxWinLiveCasino > 0 AND 
	(@MaxWinLiveCasino_old=0 or @MaxWinLiveCasino < @MaxWinLiveCasino_old)) 
BEGIN	
	IF @RoleID = 4 
	BEGIN
		UPDATE CustInfo with (ROWLOCK, UPDLOCK) 
		SET MaxWinLiveCasino = case when (@MaxWinLiveCasino > 0 AND (MaxWinLiveCasino = 0 OR MaxWinLiveCasino > @MaxWinLiveCasino)) 
								then @MaxWinLiveCasino else MaxWinLiveCasino end,
			isAutoResetLiveCasino =  case when @isAutoResetLiveCasino=0	then 0 else isAutoResetLiveCasino end
		WHERE SRecommend = @CustID AND custid <> @custid 			
			
		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 104
			RETURN
		END				
	END
	
	IF @RoleID = 3 
	BEGIN
		UPDATE CustInfo with (ROWLOCK, UPDLOCK) 
		SET MaxWinLiveCasino = case when (@MaxWinLiveCasino > 0 AND (MaxWinLiveCasino = 0 OR MaxWinLiveCasino > @MaxWinLiveCasino)) 
								then @MaxWinLiveCasino else MaxWinLiveCasino end,
			isAutoResetLiveCasino =  case when @isAutoResetLiveCasino=0	then 0 else isAutoResetLiveCasino end
		WHERE MRecommend = @CustID AND custid <> @custid 
			
		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 105
			RETURN
		END
	END
	
	IF @RoleID = 2 
	BEGIN
		UPDATE CustInfo with (ROWLOCK, UPDLOCK) 
		SET MaxWinLiveCasino = case when (@MaxWinLiveCasino > 0 AND (MaxWinLiveCasino = 0 OR MaxWinLiveCasino > @MaxWinLiveCasino)) 
								then @MaxWinLiveCasino else MaxWinLiveCasino end,
			isAutoResetLiveCasino =  case when @isAutoResetLiveCasino=0	then 0 else isAutoResetLiveCasino end
		WHERE Recommend = @CustID AND custid <> @custid 
			
		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = 
						case @Language 
							when 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 106
			RETURN
		END
	END
END

DECLARE @today smalldatetime
SET @today = convert(nvarchar(10), current_timestamp,120)

--for weekly reset, insert default balance for member if not exists to keep track balance 
IF @MaxWinLiveCasino > 0
BEGIN			
	-- if customer is weekly reset then insert default balance
	IF @RoleID = 1 AND @isAutoResetLiveCasino = 0
	BEGIN				
		IF NOT EXISTS(SELECT 1 
					FROM bodb02.dbo.BalanceDebitGame bal
					WHERE bal.custid=@custid AND bal.winlostdate=@today)
		BEGIN								
			-- insert BalanceDebitGame
			--INSERT dbo.BalanceDebitGame(custid, winlostdate, Balance)
			--SELECT @custid, @today, 0 
			EXEC bodb02.dbo.Dot_BalanceInsDebitGame @CustID = @custid, @winlostdate = @today
							
			IF (@@ERROR <> 0)
			BEGIN	
				SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Update process is unsuccessful !'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
								END	, @ErrCode = 107
				RETURN
			END		
		END	
		
		-- insert BalanceCreditGame
		IF NOT EXISTS(SELECT 1 
					FROM bodb02.dbo.BalanceCreditGame bal
					WHERE bal.custid=@custid AND bal.winlostdate=@today)		
		
		BEGIN
			--INSERT dbo.BalanceCreditGame(custid, winlostdate, Balance)
			--SELECT @custid, @today, 0 
			EXEC bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @custid, @winlostdate = @today

			IF (@@ERROR <> 0)
			BEGIN	
				SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Update process is unsuccessful !'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
								END	, @ErrCode = 108
				RETURN
			END				
		END	
	END
	ELSE IF @RoleID = 2
	BEGIN									
		-- insert BalanceDebitGame
		--INSERT dbo.BalanceDebitGame(custid, winlostdate, Balance)
		DECLARE @recommend INT
		SELECT @recommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE Recommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsDebitGame @CustID = @recommend, @winlostdate = @today
						
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END			
		
		-- insert BalanceCreditGame
		--INSERT dbo.BalanceCreditGame(custid, winlostdate, Balance)
		SELECT @recommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE Recommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @recommend, @winlostdate = @today

		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 110
			RETURN
		END	
	END
	ELSE IF @RoleID = 3
	BEGIN
		-- insert BalanceDebitGame
		--INSERT dbo.BalanceDebitGame(custid, winlostdate, Balance)
		DECLARE @mrecommend INT
		SELECT @mrecommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE MRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsDebitGame @CustID = @mrecommend, @winlostdate = @today
						
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 111
			RETURN
		END			
		
		-- insert BalanceCreditGame
		--INSERT dbo.BalanceCreditGame(custid, winlostdate, Balance)
		SELECT @mrecommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE MRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @mrecommend, @winlostdate = @today
		
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 112
			RETURN
		END	
	END
	ELSE IF @RoleID = 4
	BEGIN		
		-- insert BalanceDebitGame
		--INSERT dbo.BalanceDebitGame(custid, winlostdate, Balance)
		DECLARE @srecommend INT
		SELECT @srecommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE SRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceDebitGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsDebitGame @CustID = @srecommend, @winlostdate = @today
						
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 113
			RETURN
		END			
		
		-- insert BalanceCreditGame
		--INSERT dbo.BalanceCreditGame(custid, winlostdate, Balance)
		SELECT @srecommend = custid
		FROM CustInfo cust WITH (NOLOCK)
		WHERE SRecommend = @CustID AND roleid=1
			AND isAutoResetLiveCasino=0 AND MaxWinLiveCasino>0
			AND NOT EXISTS(SELECT 1 
						FROM bodb02.dbo.BalanceCreditGame bal WITH (NOLOCK)
						WHERE bal.custid=cust.custid AND bal.winlostdate=@today)

		EXEC bodb02.dbo.Dot_BalanceInsCreditGame @CustID = @srecommend, @winlostdate = @today
		
		IF (@@ERROR <> 0)
		BEGIN	
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 114
			RETURN
		END	
	END	
END	
	
Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
	 
SELECT @LogSPData = '<Acc_CustomerUpdLiveCS_WinLimit Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'MaxWinLiveCasino="' + CASE WHEN @MaxWinLiveCasino = 0 THEN 'Unlimited'
						ELSE CASE WHEN @MaxWinLiveCasino - FLOOR(@MaxWinLiveCasino) > 0 
								THEN COALESCE(CAST(@MaxWinLiveCasino AS VARCHAR(50)),SPACE(1)) + 'X' 
								ELSE COALESCE(CAST(CAST(@MaxWinLiveCasino AS INT) AS VARCHAR(50)),SPACE(1)) + 'X' -- cut off decimal
								END
						END	+ '" ' +
'isAutoResetLiveCasino="' + COALESCE(CAST(@isAutoResetLiveCasino AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdLiveCS_WinLimit Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'MaxWinLiveCasino="' + CASE WHEN @MaxWinLiveCasino_old = 0 THEN 'Unlimited'
						ELSE CASE WHEN @MaxWinLiveCasino_old - FLOOR(@MaxWinLiveCasino_old) > 0 
								THEN COALESCE(CAST(@MaxWinLiveCasino_old AS VARCHAR(50)),SPACE(1)) + 'X' 
								ELSE COALESCE(CAST(CAST(@MaxWinLiveCasino_old AS INT) AS VARCHAR(50)),SPACE(1)) + 'X' -- cut off decimal
								END
						END	+ '" ' +
'isAutoResetLiveCasino="' + COALESCE(CAST(@isAutoResetLiveCasino_old AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'



SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

--Log customer info 
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 375,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdLiveCS_WinLimit Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'MaxWinLiveCasino="' + CASE WHEN @MaxWinLiveCasino = 0 THEN 'Unlimited'
							ELSE CASE WHEN @MaxWinLiveCasino - FLOOR(@MaxWinLiveCasino) > 0 
									THEN COALESCE(CAST(@MaxWinLiveCasino AS VARCHAR(50)),SPACE(1)) + 'X' 
									ELSE COALESCE(CAST(CAST(@MaxWinLiveCasino AS INT) AS VARCHAR(50)),SPACE(1)) + 'X' -- cut off decimal
									END
							END	+ '" ' +
	'isAutoResetLiveCasino="' + COALESCE(CAST(@isAutoResetLiveCasino AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 375,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH		




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdLiveCS_WinLimit] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdLiveCS_WinLimit] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdLiveCS_WinLimit] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdLiveCS_WinLimit] TO [vnteam] AS [dbo]