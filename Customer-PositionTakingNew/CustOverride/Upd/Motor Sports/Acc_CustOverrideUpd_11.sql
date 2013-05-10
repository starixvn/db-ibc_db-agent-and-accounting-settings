CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_11] 
	@custid int,

	@minv11positiontaking_1 smallmoney,
	@minv11positiontaking_20 smallmoney,

	@maxv11positiontaking_1 smallmoney,
	@maxv11positiontaking_20 smallmoney,
	
	@CheckPermission bit = 1,
	@UpdateMinPos bit = 1,
	@UpdateMaxPos bit = 1,
	@language varchar(2) = 'E',
	@UserID int = 0,
	@SubAccID int = 0, --Sub-AccountID
	@WriteLog bit = 1,
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120510@Elodie
Task : Update CustOverride for Motor Sports
DB: DBTrans.bodb02
Original: Acc_CustOverrideUpd

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC DB053.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end

Declare @roleid int, @srecommend int, @mrecommend int, @recommend int
select @roleid = roleid, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend from customer with (NOLOCK) where custid = @custid
----------------------------------------------------------------------------------------------------
declare @IsValid bit, @totalDownlines int 

 --Disable on Weekend's peak hour, from 7PM - 2AM (GMT+8)
if @roleid in (3, 4) and datename(weekday, getdate()) in ('Saturday','Sunday') and datepart(hour, getdate()) between 7 and  14
BEGIN
	SELECT @totalDownlines = count(custid) FROM Custinfo WITH (NOLOCK) WHERE case @roleid when 4 then srecommend else mrecommend end = @custID 
	IF @totalDownlines >  500
	BEGIN 		
		Select @ErrCode = 100, @ErrMsg = 'This function is not available during peak hour at weekend since it might affect the performance of the whole system. Please contact IT for further assistance.'
		RETURN
	END 
END

--Check Old_minmax <> New_minmax
Declare @old_minv11positiontaking_1 smallmoney,
		@old_minv11positiontaking_20 smallmoney, 	
		
		@old_maxv11positiontaking_1 smallmoney,
		@old_maxv11positiontaking_20 smallmoney

--Get Old data
select @old_minv11positiontaking_1 = minpositiontaking, @old_maxv11positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 1
select @old_minv11positiontaking_20 = minpositiontaking, @old_maxv11positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 20
		
--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or 
		(
			@minv11positiontaking_1 = @old_minv11positiontaking_1 and
			@minv11positiontaking_20 = @old_minv11positiontaking_20			
		)
	)
	and 
	( @UpdateMaxPos = 0 or
		(
			@maxv11positiontaking_1 = @old_maxv11positiontaking_1 and
			@maxv11positiontaking_20 = @old_maxv11positiontaking_20
		)
	)
BEGIN
	return
END

--check and set new values
IF(@UpdateMinPos = 0)	
BEGIN
	SELECT  @minv11positiontaking_1 = @old_minv11positiontaking_1,
			@minv11positiontaking_20 = @old_minv11positiontaking_20
END

IF @UpdateMaxPos = 0 
BEGIN
	SELECT  @maxv11positiontaking_1 = @old_maxv11positiontaking_1,
			@maxv11positiontaking_20 = @old_maxv11positiontaking_20
END	

EXEC dbo.Acc_CustOverrideUpd_CheckParam_11
			@custid = @custid,

			@minv11positiontaking_1 = @minv11positiontaking_1,
			@minv11positiontaking_20 = @minv11positiontaking_20,

			@maxv11positiontaking_1 = @maxv11positiontaking_1,
			@maxv11positiontaking_20 = @maxv11positiontaking_20,			
			
			@UpdateMinPos = @UpdateMinPos,
			@UpdateMaxPos = @UpdateMaxPos,
			@roleid = @roleid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language

if @ErrCode <> 0
BEGIN
	return
END

----------------------------------------------------------------------------------------------------
declare @logdata nvarchar(300)

if @UpdateMinPos = 1
BEGIN
	
	Update custoverride with (ROWLOCK, UPDLOCK) set minpositiontaking = b.minpositiontaking, minlivepositiontaking = b.minlivepositiontaking
	from custoverride inner join 	
			(
			          select 	@custid as custid,  11 as sporttype, 1 as bettype, @minv11positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
			union all select 	@custid as custid,  11 as sporttype, 20 as bettype, @minv11positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking
			) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
	where custoverride.custid = @custid			
END

if @UpdateMaxPos = 1
BEGIN
	Update custoverride with (ROWLOCK, UPDLOCK) set maxpositiontaking = b.maxpositiontaking, maxlivepositiontaking = b.maxlivepositiontaking
	from custoverride inner join 	
			(
			          select 	@custid as custid,  11 as sporttype, 1 as bettype, @maxv11positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	@custid as custid,  11 as sporttype, 20 as bettype, @maxv11positiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
			) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
	where custoverride.custid = @custid
END

if @roleid = 2
BEGIN
	EXEC dbo.Acc_CustomerUpdAgent_MinMaxPositiontaking_11 @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
	-- The minimum position taking value of agent was modified by agent's upline
	EXEC DB03.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID
END
else if @roleid = 3
BEGIN
	EXEC dbo.Acc_CustomerUpdMaster_MinMaxPositiontaking_11 @mrecommend = @mrecommend, @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMinPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting_00_11 @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting_01_11 @srecommend = @srecommend
END

if @WriteLog = 1
BEGIN
	Declare @LogSPData varchar(5000)
	Declare @TrackingValue2 varchar(5000)
	
	Select @LogSPData = '<Acc_CustOverrideUpd_11><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
	'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
	'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
	'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
	
	'<MinMaxPT minv11pt_1="'+ coalesce(cast(@minv11positiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minv11pt_20="'+ coalesce(cast(@minv11positiontaking_20 as varchar(50)),space(1)) + '" ' +
	'maxv11pt_1="'+ coalesce(cast(@maxv11positiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxv11pt_20="'+ coalesce(cast(@maxv11positiontaking_20 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_11>'
	
	SELECT @TrackingValue2 = '<Acc_CustOverrideUpd_11><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
	'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
	'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
	'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
	
	'<MinMaxPT minv11pt_1="'+ coalesce(cast(@old_minv11positiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minv11pt_20="'+ coalesce(cast(@old_minv11positiontaking_20 as varchar(50)),space(1)) + '" ' +
	'maxv11pt_1="'+ coalesce(cast(@old_maxv11positiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxv11pt_20="'+ coalesce(cast(@old_maxv11positiontaking_20 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_11>'
		
	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)
		
	--Write Log 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 500,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_11] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_11] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_11] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_11] TO [vnteam] 