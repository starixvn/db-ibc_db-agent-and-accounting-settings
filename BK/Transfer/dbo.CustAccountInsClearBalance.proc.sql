/****** Object:  StoredProcedure [CustAccountInsClearBalance]    Script Date: 12/21/2007 09:33:04 ******/
ALTER PROCEDURE [CustAccountInsClearBalance]
	@FromCustID int, --Agent ID here
	@ToCustIDs nvarchar(4000), 
	@Transdate datetime,
	@creator int,
	@Language varchar(2)= 'E',
	@SubAccID int = 0, --Sub-AccountID
	@YesterdayData bit = 0, --0:get all data; 1:get data of Yesterdays only
	@ReturnErrCode bit = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
--ADMIN SITE
--NOTE: If change the SP name, then need to change in Acc_BettransInsTransferAllMembers also
--UPDATED 02/25/2006: remove refno

SET NOCOUNT ON
---------------------------


-- ***Check Sub-Account***
Declare @spPageAccess varchar(10)
set @spPageAccess = '[C]' --Transfer - PageAccess for this sp
Declare @SubAllow bit
Exec CustSubCheckPageAccess @SubAccID, @spPageAccess, @Language, @SubAllow OUTPUT
if @SubAllow = 0
	Return
---------------------------

Declare @LogData nvarchar(200)
Declare @agentid int, @custid int
DECLARE @agCurr int, @Curr int , @agActualrate float, @actualrate float  
DECLARE @agUser nvarchar(50), @User nvarchar(50)
Declare @refno bigint, @transcode bigint, @ToCustID int, @OldTransCode bigint, @Amount float, @Recommend1 int, @MRecommend1 int, @Recommend2 int, @MRecommend2 int, @grefno int, @srecommend1 int
/*
if not exists (select 1 from customer with (nolock) where custid = @fromcustid and mrecommend = 68287)
BEGIN
	Select @ErrMsg = 'Sorry, please try again later.'
	RaisError (@ErrMsg, 16, 1)
	return
END
*/

----------------------------------------------------------------------
--Check Transfer Condition
--1		2		3		4		5		6		7		8
--isSun	isMon	isTue	isWed	isThurs	isFri	isSat	isWeekly
--0		1		0		0		1		0		1		1
EXEC dbo.CustomerCheckTransferOption 
	@CustID = @FromCustID,
	@ErrMsg = @ErrMsg OUTPUT,
	@ErrCode = @ErrCode OUTPUT,
	@Language = @Language
if @ErrCode > 0
BEGIN
	if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
	return
END
----------------------------------------------------------------------
if ((datepart(hour, getdate()) between 11 and 23)
		and not exists(select 1 from customer with (nolock) where custid = @FromCustID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))   
	)
	
BEGIN
	select @ErrCode = 101
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, you can only transfer from 12pm to 10pm.'
						when 'CS' then N'對不起, 您只能於12pm 至 10pm轉帳.'
						when 'J' then N'Sorry, you can only transfer from 12pm to 10pm.'
						else N'Sorry, you can only transfer from 12pm to 10pm.'
					end			
	if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
	return
END
/*
if ((datepart(hour, getdate()) between 11 and 23)  
  and not exists(select 1 from customer with (nolock) where custid = @FromCustID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))     
 )  
   
BEGIN  
 select @ErrCode = 101  
 Select @ErrMsg = case @Language   
      when 'E' then 'Sorry, you can only transfer from 12pm to 10pm (on Everyday).'  
      when 'CS' then N'Sorry, you can only transfer from 12pm to 10pm (on Everyday).'  
      when 'J' then N'Sorry, you can only transfer from 12pm to 10pm (on Everyday).'  
      else N'Sorry, you can only transfer from 12pm to 10pm (on Everyday).'  
     end     
 if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)  
 return  
END  
*/
if not exists (select 1 from customer with (NOLOCK) where custid = @FromCustID)
BEGIN
	select @ErrCode = 102
	Select @ErrMsg = case @Language 
							when 'E' then 'Customer does not exist.'
							when 'CS' then N'會員 不存在.'
							when 'J' then N'ID確認できません。'
							else N'Customer does not exist.'
						end		
	if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)	
	
	return
END
Select @Recommend1 = recommend, @MRecommend1 = mrecommend, @srecommend1 = srecommend from Customer with (NOLOCK) where CustID = @FromCustID
Select @LogData = 'Add transaction for :' + convert(varchar(20), @FromCustID) + ' to '

Select @AgentID = @FromCustID
SELECT @agCurr = currency, @agUser = username, @MRecommend1 = mrecommend 
FROM customer (nolock) WHERE custid = @agentid AND roleid = 2

SELECT @agActualrate = actualrate FROM Exchange e with (Nolock) where e.exchangeid = @agCurr
	declare CUR Cursor for Select convert(int, val) from dbo.strSplit (@ToCustIDs, ',' )
	declare @ErrItems nvarchar(4000)
	declare @SkipTransfer bit
	
	select @ErrItems = ''

	OPEN CUR
	FETCH NEXT FROM CUR INTO @ToCustID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @AgentID = @FromCustID, @CustID = @ToCustID

		SELECT @Curr   = currency, @User = username   FROM customer (nolock) WHERE custid = @custid AND roleid = 1
		
		
		--Check for existing transfer (allow only one transfer per day) - Vinh@20071221
		
		select @SkipTransfer = 0
		
		if(exists(
			SELECT 1 FROM bettrans WITH (NOLOCK) 
			WHERE custid=@custid AND bettype in (103, 104) 
				AND (transdate BETWEEN convert(varchar(10), @transdate, 120) AND convert(varchar(10), @transdate, 120) + ' 23:59:59')
			))
		begin
			select @SkipTransfer = 1
			select @ErrItems = @ErrItems + @User + ', '
		end	
		
		if @YesterdayData = 1
		BEGIN
			--Clear the Balance of Yesterday's transactions only
			Select @Amount = isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0)
			From bettrans AS b with (NOLOCK)
			where
				CustID = @CustID				
				and b.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)			
				--and case when bettype > 100 then b.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)
		END
		else
		BEGIN
			Select @Amount = isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0)
			From bettrans AS b with (NOLOCK)
			where CustID = @CustID
		END
		
			
		--When calculate the remaining amount (based on current balance), always include all existing transfers regardless of the time of transfer - Vinh@20071221
		--Select @Amount = isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0)
		--From bettrans AS b with (NOLOCK)
		--where CustID = @CustID
		
		if not exists (select 1 from custinfo with (NOLOCK) where  custid = @ToCustID and recommend = @FromCustID)
		BEGIN
			select @Amount = 0
		END
		if @Amount<>0
		BEGIN
		
			declare @WinlostDate datetime
			if (@YesterdayData = 1) 
				select @WinlostDate = dateadd(day, -1, current_timestamp)
			else 
				select @WinlostDate = current_timestamp
		
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
			
			-- All error messages are the same, so we set it here
			select @ErrCode = 105
			Select @ErrMsg = case @Language 
								when 'E' then 'Clear balance failed. Please try again.'
								when 'CS' then N'結清餘額不成功,請重新嘗試.'
								when 'J' then N'もう一度残高ポイントを確認してください。'
								else N'Clear balance failed. Please try again.'
							end
				
			IF (@amount > 0) and (@SkipTransfer = 0)
			BEGIN
				INSERT INTO bettrans 
					(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
					comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
				VALUES (@agentid, @agentid, @transcode, CURRENT_TIMESTAMP, 104, 'From Customer :: ' + @User, @amount, 0, 
					@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @MRecommend1, @srecommend1, 0, 0)
				if @@Error <> 0
				BEGIN
					if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
					ROLLBACK TRANSACTION
					return
				END
				INSERT INTO bettrans
					(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
					comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
				VALUES (@agentid, @custid, @transcode, CURRENT_TIMESTAMP, 104, 'To Customer :: ' + @agUser, 0, @amount,
					@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @Curr, @agentid, @MRecommend1, @srecommend1, 0, 0)
				if @@Error <> 0
				BEGIN
					if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
					ROLLBACK TRANSACTION
					return
				END

				--Add writelog for each amt transfered - Vinh 20080629
				Select @LogData = 'Transfer from Customer ' + @User + ' to Agent ' + @agUser + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
				
			END
			ELSE if (@amount<0) and (@SkipTransfer = 0)
			BEGIN
				SET @amount = abs(@amount) 			
				INSERT INTO bettrans 
					(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
					comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
				VALUES (@agentid, @agentid, @transcode, CURRENT_TIMESTAMP, 104, 'To Customer :: ' + @User, 0, @amount,
					@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @MRecommend1, @srecommend1, 0, 0)
				if @@Error <> 0
				BEGIN
					if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
					ROLLBACK TRANSACTION
					return
				END
				INSERT INTO bettrans
					(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
					comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
				VALUES (@agentid, @custid, @transcode, CURRENT_TIMESTAMP, 104, 'From Customer :: ' + @agUser, @amount, 0,
					@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @Curr, @agentid, @MRecommend1, @srecommend1, 0, 0)
				if @@Error <> 0
				BEGIN
					if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
					ROLLBACK TRANSACTION
					return
				END
				
				--Add writelog for each amt transfered - Vinh 20080629
				Select @LogData = 'Transfer from Agent ' + @agUser + ' to Customer ' + @User + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
				
			END
			exec CustBetCreditUpdResync @custid, 1
			exec CustBetCreditUpdResync @agentid, 1
			COMMIT TRANSACTION
			select @ErrCode = 0
			Select @ErrMsg = ''
			if (@SkipTransfer = 0) 
			BEGIN
				--Select @LogData = @LogData + '[' + convert(varchar(20),@ToCustID) + ', ' + convert(varchar(20), @amount) + ']'				
				if @SubAccID > 0
					SET @LogData = 'SubAccountID:' +  convert(varchar(20), @SubAccID) + ' - ' + @LogData
				EXEC WriteLog_UserLog @UserID = @creator, @Doing = @LogData
				------------------------------------------------------------------------------------------
			END
		END
		FETCH NEXT FROM CUR INTO @ToCustID
	END
	CLOSE CUR
	DEALLOCATE CUR
	
	if @ErrItems <> ''
	BEGIN
		select @ErrCode = 104
		select @ErrItems = LEFT(@ErrItems, len(@ErrItems)-1)
		Select @ErrMsg = case @Language 
							when 'E' then N'Clear balance failed for the following user(s): ' + @ErrItems + '.\nReason: Allow only one transfer per day!'
							when 'CS' then N'結清餘額不成功於會員: ' + @ErrItems + N'.\n原因  ：只允许每天转账一次。'
							when 'J' then N'Clear balance failed for the following user(s): ' + @ErrItems + '.\nReason: Allow only one transfer per day!'
							else N'Clear balance failed for the following user(s): ' + @ErrItems + '.\nReason: Allow only one transfer per day!'
						end
		--select @ErrMsg = @ErrMsg + '.\nReason: Allow only one transfer per day!'
		if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
	END
		

---------------------------
---- ***Check Sub-Account***
--if @SubAccID > 0
	--SET @LogData = 'SubAccountID:' +  convert(varchar(20), @SubAccID) + ' - ' + @LogData
-----------------------------
--EXEC WriteLog_UserLog @UserID = @creator, @Doing = @LogData


GO

GRANT EXECUTE ON [CustAccountInsClearBalance] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [CustAccountInsClearBalance] TO [bodbDownlineNetView]