ALTER PROCEDURE [dbo].[CustAccountInsTransfer] 
	@FromCustID int, --the customer here
	@ToUserName nvarchar(50), --the agent here
	@Transdate datetime,
	@Amount float,
	@Remark nvarchar(200),
	@Ex float,
	@creator int,
	@Language varchar(2)= 'E',
	@SubAccID int = 0, --Sub-AccountID
	@ReturnErrCode bit = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@YesterdayData bit = 0 --0:get all data; 1:get data of Yesterdays only
AS
--ADMIN SITE
--UPDATED 02/25/2006: remove refno

---------------------------
-- ***Check Sub-Account***
Declare @spPageAccess varchar(10)
set @spPageAccess = '[C]' --Transfer - PageAccess for this sp
Declare @SubAllow bit
Exec CustSubCheckPageAccess @SubAccID, @spPageAccess, @Language, @SubAllow OUTPUT
if @SubAllow = 0
	Return
---------------------------

--Declare @ErrMsg nvarchar(200), @ErrCode int
Declare @refno bigint, @transcode bigint, @ToCustID int, @OldTransCode bigint, @MRecommend1 int, @agentid int, @custid int, @grefno int, @srecommend int
DECLARE @agCurr int, @Curr int
DECLARE @agUser nvarchar(50), @User nvarchar(50)


Select @ToCustID = null
select @ToCustID = CustID from customer with (NOLOCK) where username = @ToUserName
if @ToCustID is NULL or @ToCustID = 0
BEGIN
	Select @ErrMsg = case @Language 
							when 'E' then 'Customer ' + @ToUserName + ' does not exist.'
							when 'CS' then N'會員 ' + @ToUserName + ' 不存在.'
							when 'J' then N'ID確認できません。'
							else N'Customer ' + @ToUserName + ' does not exist.'
					end
		
	return
END

----------------------------------------------------------------------
--Check Transfer Condition
--1		2		3		4		5		6		7		8
--isSun	isMon	isTue	isWed	isThurs	isFri	isSat	isWeekly
--0		1		0		0		1		0		1		1
EXEC dbo.CustomerCheckTransferOption 
	@CustID = @ToCustID,
	@ErrMsg = @ErrMsg OUTPUT,
	@ErrCode = @ErrCode OUTPUT,
	@Language = @Language
if @ErrCode > 0
BEGIN
	if (@ReturnErrCode = 0)  RaisError (@ErrMsg, 16, 1)
	return
END
----------------------------------------------------------------------

if ((datepart(hour, getdate()) between 11 and 23)
	and not exists(select 1 from customer with (nolock) where custid = @FromCustID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))   	
	)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, you can only transfer from 12pm to 10pm.'
						when 'CS' then N'對不起, 您只能於12pm 至 10pm轉帳.'
						when 'J' then N'Sorry, you can only transfer from 12pm to 10pm.'
						else N'Sorry, you can only transfer from 12pm to 10pm.'
					end			
		select @ErrCode = 102
		if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)

	return
END

/*
if ((datename(weekday, getdate()) not in ('Saturday','Sunday') and datepart(hour, getdate()) between 8 and 20) or (datename(weekday, getdate()) in ('Saturday','Sunday') and datepart(hour, getdate()) between 6 and 20)  
 and not exists(select 1 from customer with (nolock) where custid = @FromCustID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))     
 )  
  
BEGIN  
 Select @ErrMsg = case @Language   
      when 'E' then 'Sorry, you can only transfer from 8am to 8pm (on Monday to Friday) and 8am to 6pm (on Saturday and Sunday).'  
      when 'CS' then N'Sorry, you can only transfer from 8am to 8pm (on Monday to Friday) and 8am to 6pm (on Saturday and Sunday).'  
      when 'J' then N'月曜～金曜の朝8時から夜8時まで、土曜・日曜は朝8時から午後6時までに作業を行ってください。'  
      else N'Sorry, you can only transfer from 8am to 8pm (on Monday to Friday) and 8am to 6pm (on Saturday and Sunday).'  
     end     
  select @ErrCode = 102  
  if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)  
  
 return  
END 
*/

if not exists (select 1 from customer with (NOLOCK) where custid = @FromCustID and recommend = @ToCustID)
BEGIN
	Select @ErrMsg = case @Language 
							when 'E' then 'Customer does not exist.'
							when 'CS' then N'會員 不存在.'
							when 'J' then N'ID確認できません。'
							else N'Customer does not exist.'
						end		
	select @ErrCode = 103
	if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
	return
END

Select @AgentID = @ToCustID, @CustID = @FromCustID
------------------------------------------------
--Check valid balance
Declare @CustBalance money

if @YesterdayData = 0
	Select @CustBalance = isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0)
	From bettrans AS b with (NOLOCK)
	where CustID = @CustID
else
	Select @CustBalance = isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0)
	From bettrans AS b with (NOLOCK)
	where CustID = @CustID and b.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)
	--where CustID = @CustID and case when bettype > 100 then b.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)


	

if @amount = 0
	or (@CustBalance >= 0 AND (@Amount <= 0 or @Amount > @CustBalance))
	or (@CustBalance < 0 AND (@Amount >= 0 or @Amount < @CustBalance))
BEGIN
	Select @ErrMsg = case @Language 
							when 'E' then 'Amount to transfer must be between' + ' 0 and '+ cast(-@CustBalance as varchar(20)) +'.'
							when 'CS' then N'轉帳數目必須 0 和 '+ cast(-@CustBalance as varchar(20)) +'之間.'
							when 'J' then N'Amount to transfer must be between' + ' 0 and '+ cast(-@CustBalance as varchar(20)) +'.'
							else N'Amount to transfer must be between' + ' 0 and '+ cast(-@CustBalance as varchar(20)) +'.'
						end		
	select @ErrCode = 104
	if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
	return
END
----------------------------------------------------------

SELECT @agCurr = currency, @agUser = username, @MRecommend1 = mrecommend, @srecommend = srecommend FROM customer (nolock) WHERE custid = @agentid AND roleid = 2
SELECT @Curr   = currency, @User = username   FROM customer (nolock) WHERE custid = @custid AND roleid = 1
BEGIN TRANSACTION
	UPDATE ref with (rowlock, UPDLOCK)  SET   @grefno=transcode=transcode+1
	WHERE  refid='acc'

	if @@Error <> 0
	BEGIN
		ROLLBACK TRANSACTION
		return
	END		

	select @transcode=200000000000+@grefno
COMMIT TRANSACTION

BEGIN TRANSACTION

	declare @LogData nvarchar(200)
	declare @WinlostDate datetime
	if (@YesterdayData = 1) 
		select @WinlostDate = dateadd(day, -1, current_timestamp)
	else 
		select @WinlostDate = current_timestamp
	
	
-- All error messages are the same, so we set it here
	Select @ErrMsg = case @Language 
						when 'E' then 'Transfer failed. Please try again.'
						when 'CS' then N'轉帳不成功. 請重新嘗試.'
						when 'J' then N'払戻処理上にエラーが発生しました。もう一度確認してください。'
						else N'Transfer failed. Please try again.'
					end
	
	IF @amount >= 0
	BEGIN
		INSERT INTO bettrans 
			(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
		VALUES (@agentid, @agentid, @transcode, CURRENT_TIMESTAMP, 104, 'From Customer :: ' + @User, @amount, 0, 
			@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @MRecommend1, @srecommend, 0, 0)
		if @@Error <> 0
		BEGIN

			select @ErrCode = 104
			if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)

			ROLLBACK TRANSACTION
			return
		END
		INSERT INTO bettrans
			(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
		VALUES (@agentid, @custid, @transcode, CURRENT_TIMESTAMP, 104, 'To Customer :: ' + @agUser, 0, @amount,
			@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @Curr, @agentid, @MRecommend1, @srecommend, 0, 0)
		if @@Error <> 0
		BEGIN
			select @ErrCode = 105
			if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)

			ROLLBACK TRANSACTION
			return
		END
		
		Select @LogData = 'Transfer from Customer ' + @User + ' to Agent ' + @agUser + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
		
	END
	ELSE
	BEGIN
		SET @amount = abs(@amount)
	
		INSERT INTO bettrans 
			(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
		VALUES (@agentid, @agentid, @transcode, CURRENT_TIMESTAMP, 104, 'To Customer :: ' + @User, 0, @amount,
			@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @MRecommend1, @srecommend, 0, 0)
		if @@Error <> 0
		BEGIN
			select @ErrCode = 106
			if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
			ROLLBACK TRANSACTION
			return
		END
		INSERT INTO bettrans
			(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
			comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
		VALUES (@agentid, @custid, @transcode, CURRENT_TIMESTAMP, 104, 'From Customer :: ' + @agUser, @amount, 0,
			@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @Curr, @agentid, @MRecommend1, @srecommend, 0, 0)
		if @@Error <> 0
		BEGIN
			select @ErrCode = 107
			if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
			ROLLBACK TRANSACTION
			return
		END
		
		Select @LogData = 'Transfer from Agent ' + @agUser + ' to Customer ' + @User + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)		
		
	END
	exec CustBetCreditUpdResync @custid, 1
	exec CustBetCreditUpdResync @agentid, 1
COMMIT TRANSACTION
Select @ErrMsg = ''

--declare @LogData nvarchar(200)
--Select @LogData = 'Add transaction for :' + convert(varchar(20), @FromCustID) + ' to ' + convert(varchar(20), @ToCustID) + ' amount: ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
---------------------------
-- ***Check Sub-Account***
if @SubAccID > 0
	SET @LogData = 'SubAccountID:' +  convert(varchar(20), @SubAccID) + ' - ' + @LogData
---------------------------
EXEC WriteLog_UserLog @UserID = @creator, @Doing = @LogData




GO

GRANT EXECUTE ON [dbo].[CustAccountInsTransfer] TO [bodbDownlineNet]