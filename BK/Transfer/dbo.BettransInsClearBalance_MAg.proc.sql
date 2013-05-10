ALTER PROCEDURE [BettransInsClearBalance_MAg]
	@MasterID int,
	@ToCustIDs varchar(4000),
	@Transdate datetime,
	@creator int,
	@FullTransfer bit = 1,
	@AmtTrans float = 0,
	@Language varchar(2)= 'E',
	@SubAccID int = 0, --Sub-AccountID
	@YesterdayData bit = 0, --0:get all data; 1:get data of Yesterdays only
	@ReturnErrCode bit = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT	

AS
--Source control
--AGENT SITE
--Multiple Transfer
SET NOCOUNT ON

--select @YesterdayData = 1
---------------------------
-- ***Check Sub-Account***
Declare @spPageAccess varchar(10)
set @spPageAccess = '[C]' --Transfer - PageAccess for this sp
Declare @SubAllow bit
Exec CustSubCheckPageAccess @SubAccID, @spPageAccess, @Language, @SubAllow OUTPUT
if @SubAllow = 0
	Return
---------------------------

Declare @srecommend int
--declare @ErrMsg varchar(200), @ErrCode int
DECLARE @AgList TABLE (CustID int NULL, Amt float NULL, AgCurr int NULL, AgUser nvarchar(50))
/*
if @masterid<>68287
BEGIN
	declare @errmsg nvarchar(200)
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
	@CustID = @MasterID,
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
	and not exists(select 1 from customer with (nolock) where custid = @MasterID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))   
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
if ((datename(weekday, getdate()) not in ('Saturday','Sunday') and datepart(hour, getdate()) between 8 and 19) or (datename(weekday, getdate())  in ('Saturday','Sunday') and datepart(hour, getdate()) between 6 and 19)  
 and not exists(select 1 from customer with (nolock) where custid = @MasterID and srecommend = (select custid from customer with (nolock) where username = 'SSSUUS'))     
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
Select @srecommend = srecommend from custinfo with (nolock) where custid = @masterid

if @YesterdayData = 1
BEGIN
	--Clear the Balance of Yesterday's transactions only
	INSERT INTO @AgList (CustID, Amt, AgCurr, AgUser)
	select 	recommend AS CustID, 
		case when @FullTransfer = 0 then @AmtTrans else
		isnull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end), 0) + isnull(sum(case when custid<>recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end), 0) end as Amt,
		0, ''
	from bettrans with(nolock)
	where
		mrecommend = @masterid  and recommend in (select convert(int, val) from dbo.strSplit (@ToCustIDs, ',' ) )
		--Yesterday's transactions only		
		--and case when bettype > 100 then bettrans.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)	
		and bettrans.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)	
	group by recommend
END
else
BEGIN
	INSERT INTO @AgList (CustID, Amt, AgCurr, AgUser)
	select 	recommend AS CustID, 
		case when @FullTransfer = 0 then @AmtTrans else
		isnull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end), 0) + isnull(sum(case when custid<>recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end), 0) end as Amt,
		0, ''
	from bettrans with(nolock)
	where mrecommend = @masterid  and recommend in (select convert(int, val) from dbo.strSplit (@ToCustIDs, ',' ) )
	group by recommend
END

Update A Set AgCurr = C.currency, AgUser = C.UserName
from @AgList as A INNER JOIN Customer AS C with (NOLOCK) on A.CustID = C.CustID

DECLARE @maCurr int, @AgCurr int, @MAUser nvarchar(50), @AgUser nvarchar(50), @transcode bigint, @amount float, @AgentID int, @grefno int
SELECT @maCurr = currency, @maUser = username FROM customer (nolock) WHERE custid = @masterid AND roleid = 3
declare @LogData nvarchar(200)

DECLARE CUR CURSOR FOR SELECT CustID, Amt, AgCurr, AgUser FROM @Aglist
OPEN CUR
FETCH NEXT FROM CUR INTO @AgentID, @Amount, @AgCurr, @AgUser
WHILE @@FETCH_STATUS = 0
BEGIN
	if not exists (select 1 from custinfo with (nolock) where custid = @agentid and mrecommend = @masterid)
	BEGIN
		Select @Amount = 0
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
		Select @ErrMsg = case @Language 
								when 'E' then 'Clear balance failed. Please try again.'
								when 'CS' then N'結清餘額不成功,請重新嘗試.'
								when 'J' then N'もう一度残高ポイントを確認してください。'
								else N'Clear balance failed. Please try again.'
						end
		
		IF @amount >= 0
		BEGIN
			
			INSERT INTO bettrans 
				(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
			VALUES (@masterid, @masterid, @transcode, CURRENT_TIMESTAMP, 103, 'From Customer ::: ' + @agUser, @amount, 0, 
				@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @maCurr, 0, @masterid, @srecommend, 0, 0)
			if @@Error <> 0
			BEGIN								
				select @ErrCode = 102
				if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
				ROLLBACK TRANSACTION
				return
			END
			INSERT INTO bettrans
				(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
			VALUES (@masterid, @agentid, @transcode, CURRENT_TIMESTAMP, 103, 'To Customer ::: ' + @maUser, 0, @amount,
				@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @masterid, @srecommend, 0, 0)
			if @@Error <> 0
			BEGIN						
				select @ErrCode = 103
				if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
				ROLLBACK TRANSACTION
				return
			END

			--Add writelog for each amt transfered - Vinh 20080629
			Select @LogData = 'Transfer from Agent ' + @agUser + ' to Master ' + @maUser + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
			
			
		END
		ELSE if @amount<0
		BEGIN
			SET @amount = abs(@amount)
		
			INSERT INTO bettrans 
				(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
			VALUES (@masterid, @masterid, @transcode, CURRENT_TIMESTAMP, 103, 'To Customer ::: ' + @agUser, 0, @amount,
				@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @maCurr, 0, @masterid, @srecommend, 0, 0)
			if @@Error <> 0
			BEGIN						
				select @ErrCode = 107
				if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
				ROLLBACK TRANSACTION
				return
			END
			INSERT INTO bettrans
				(creator, custid, refno, transdate, bettype, transdesc, winlost, actual_stake, 
				comstatus, status, ruben, winlostdate, currency, recommend, mrecommend, srecommend, scomm, swinlost)
			VALUES (@masterid, @agentid, @transcode, CURRENT_TIMESTAMP, 103, 'From Customer ::: ' + @maUser, @amount, 0,
				@transcode, '', 1, convert(nvarchar(10), @WinlostDate,120), @agCurr, @agentid, @masterid, @srecommend, 0, 0)
			if @@Error <> 0
			BEGIN
				select @ErrCode = 104
				if (@ReturnErrCode = 0) RaisError (@ErrMsg, 16, 1)
				ROLLBACK TRANSACTION
				return
			END
			
			--Add writelog for each amt transfered - Vinh 20080629
			Select @LogData = 'Transfer from Master ' + @maUser + ' to Agent ' + @agUser + ' with amount ' + convert(varchar(20), @amount) + ' Ref.No ' + convert(varchar(20), @transcode)
			
			
		END
		COMMIT TRANSACTION	
		Select @ErrMsg = ''

		if @SubAccID > 0
			SET @LogData = 'SubAccountID:' +  convert(varchar(20), @SubAccID) + ' - ' + @LogData
		EXEC WriteLog_UserLog @UserID = @creator, @Doing = @LogData
		
	END

	FETCH NEXT FROM CUR INTO @AgentID, @Amount, @AgCurr, @AgUser
END
CLOSE CUR
DEALLOCATE CUR

--declare @LogData nvarchar(300)
--Select @LogData = 'Master ' + convert(varchar(20), @MasterID) + ' insert clear balance for custid: ' + convert(varchar(200), @ToCustIDs) 
-----------------------------
---- ***Check Sub-Account***
--if @SubAccID > 0
	--SET @LogData = 'SubAccountID:' +  convert(varchar(20), @SubAccID) + ' - ' + @LogData
-----------------------------
--EXEC WriteLog_UserLog @UserID = @MasterID, @Doing = @LogData




GO

GRANT EXECUTE ON [BettransInsClearBalance_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [BettransInsClearBalance_MAg] TO [bodbDownlineNetView]
