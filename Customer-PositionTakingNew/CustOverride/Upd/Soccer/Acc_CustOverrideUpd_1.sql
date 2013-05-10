ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_1] 
	@custid int,

	@minpositiontaking_1 smallmoney,
	@minpositiontaking_2 smallmoney,
	@minpositiontaking_3 smallmoney,
	@minpositiontaking_4 smallmoney,
	@minpositiontaking_5 smallmoney,
	@minpositiontaking_6 smallmoney,
	@minpositiontaking_7 smallmoney,
	@minpositiontaking_8 smallmoney,
	@minpositiontaking_9 smallmoney,
	@minpositiontaking_10 smallmoney,

	@minlivepositiontaking_1 smallmoney,
	@minlivepositiontaking_3 smallmoney,
	@minlivepositiontaking_7 smallmoney,
	@minlivepositiontaking_8 smallmoney,
	
	@maxpositiontaking_1 smallmoney,
	@maxpositiontaking_2 smallmoney,
	@maxpositiontaking_3 smallmoney,
	@maxpositiontaking_4 smallmoney,
	@maxpositiontaking_5 smallmoney,
	@maxpositiontaking_6 smallmoney,
	@maxpositiontaking_7 smallmoney,
	@maxpositiontaking_8 smallmoney,
	@maxpositiontaking_9 smallmoney,
	@maxpositiontaking_10 smallmoney,
	
	@maxlivepositiontaking_1 smallmoney,
	@maxlivepositiontaking_3 smallmoney,
	@maxlivepositiontaking_7 smallmoney,
	@maxlivepositiontaking_8 smallmoney,
	
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
Task : Update CustOverride for Soccer
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
Declare 	
	@old_minpositiontaking_1 smallmoney,
	@old_minpositiontaking_2 smallmoney,
	@old_minpositiontaking_3 smallmoney,
	@old_minpositiontaking_4 smallmoney,
	@old_minpositiontaking_5 smallmoney,
	@old_minpositiontaking_6 smallmoney,
	@old_minpositiontaking_7 smallmoney,
	@old_minpositiontaking_8 smallmoney,
	@old_minpositiontaking_9 smallmoney,
	@old_minpositiontaking_10 smallmoney,

	@old_minlivepositiontaking_1 smallmoney,
	@old_minlivepositiontaking_3 smallmoney,
	@old_minlivepositiontaking_7 smallmoney,
	@old_minlivepositiontaking_8 smallmoney,
	
	@old_maxpositiontaking_1 smallmoney,
	@old_maxpositiontaking_2 smallmoney,
	@old_maxpositiontaking_3 smallmoney,
	@old_maxpositiontaking_4 smallmoney,
	@old_maxpositiontaking_5 smallmoney,
	@old_maxpositiontaking_6 smallmoney,
	@old_maxpositiontaking_7 smallmoney,
	@old_maxpositiontaking_8 smallmoney,
	@old_maxpositiontaking_9 smallmoney,
	@old_maxpositiontaking_10 smallmoney,
	
	@old_maxlivepositiontaking_1 smallmoney,
	@old_maxlivepositiontaking_3 smallmoney,
	@old_maxlivepositiontaking_7 smallmoney,
	@old_maxlivepositiontaking_8 smallmoney		
	
--Get Old data
	select @old_minpositiontaking_1 = minpositiontaking, @old_maxpositiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @old_minpositiontaking_2 = minpositiontaking, @old_maxpositiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 2
	select @old_minpositiontaking_3 = minpositiontaking, @old_maxpositiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @old_minpositiontaking_4 = minpositiontaking, @old_maxpositiontaking_4 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 4
	select @old_minpositiontaking_5 = minpositiontaking, @old_maxpositiontaking_5 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 5
	select @old_minpositiontaking_6 = minpositiontaking, @old_maxpositiontaking_6 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 6
	select @old_minpositiontaking_7 = minpositiontaking, @old_maxpositiontaking_7 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @old_minpositiontaking_8 = minpositiontaking, @old_maxpositiontaking_8 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
	select @old_minpositiontaking_9 = minpositiontaking, @old_maxpositiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 9
	select @old_minpositiontaking_10 = minpositiontaking, @old_maxpositiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 10
	
	select @old_minlivepositiontaking_1 = minlivepositiontaking, @old_maxlivepositiontaking_1 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @old_minlivepositiontaking_3 = minlivepositiontaking, @old_maxlivepositiontaking_3 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @old_minlivepositiontaking_7 = minlivepositiontaking, @old_maxlivepositiontaking_7 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @old_minlivepositiontaking_8 = minlivepositiontaking, @old_maxlivepositiontaking_8 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
	
--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or 
		(
			@minpositiontaking_1 = @old_minpositiontaking_1 and
			@minpositiontaking_2 = @old_minpositiontaking_2 and
			@minpositiontaking_3 = @old_minpositiontaking_3 and
			@minpositiontaking_4 = @old_minpositiontaking_4 and
			@minpositiontaking_5 = @old_minpositiontaking_5 and
			@minpositiontaking_6 = @old_minpositiontaking_6 and
			@minpositiontaking_7 = @old_minpositiontaking_7 and
			@minpositiontaking_8 = @old_minpositiontaking_8 and
			@minpositiontaking_9 = @old_minpositiontaking_9 and
			@minpositiontaking_10 = @old_minpositiontaking_10 and

			@minlivepositiontaking_1 = @old_minlivepositiontaking_1 and
			@minlivepositiontaking_3 = @old_minlivepositiontaking_3 and
			@minlivepositiontaking_7 = @old_minlivepositiontaking_7 and
			@minlivepositiontaking_8 = @old_minlivepositiontaking_8			
		)
	)
	and 
	( @UpdateMaxPos = 0 or
		(
			@maxpositiontaking_1 = @old_maxpositiontaking_1 and
			@maxpositiontaking_2 = @old_maxpositiontaking_2 and
			@maxpositiontaking_3 = @old_maxpositiontaking_3 and
			@maxpositiontaking_4 = @old_maxpositiontaking_4 and
			@maxpositiontaking_5 = @old_maxpositiontaking_5 and
			@maxpositiontaking_6 = @old_maxpositiontaking_6 and
			@maxpositiontaking_7 = @old_maxpositiontaking_7 and
			@maxpositiontaking_8 = @old_maxpositiontaking_8 and
			@maxpositiontaking_9 = @old_maxpositiontaking_9 and
			@maxpositiontaking_10 = @old_maxpositiontaking_10 and

			@maxlivepositiontaking_1 = @old_maxlivepositiontaking_1 and
			@maxlivepositiontaking_3 = @old_maxlivepositiontaking_3 and
			@maxlivepositiontaking_7 = @old_maxlivepositiontaking_7 and
			@maxlivepositiontaking_8 = @old_maxlivepositiontaking_8
		)
	)
BEGIN
	return
END

--check and set new values
IF(@UpdateMinPos = 0)	
BEGIN
	SELECT  @minpositiontaking_1 = @old_minpositiontaking_1,
			@minpositiontaking_2 = @old_minpositiontaking_2,
			@minpositiontaking_3 = @old_minpositiontaking_3,
			@minpositiontaking_4 = @old_minpositiontaking_4,
			@minpositiontaking_5 = @old_minpositiontaking_5,
			@minpositiontaking_6 = @old_minpositiontaking_6,
			@minpositiontaking_7 = @old_minpositiontaking_7,
			@minpositiontaking_8 = @old_minpositiontaking_8,
			@minpositiontaking_9 = @old_minpositiontaking_9,
			@minpositiontaking_10 = @old_minpositiontaking_10,

			@minlivepositiontaking_1 = @old_minlivepositiontaking_1,
			@minlivepositiontaking_3 = @old_minlivepositiontaking_3,
			@minlivepositiontaking_7 = @old_minlivepositiontaking_7,
			@minlivepositiontaking_8 = @old_minlivepositiontaking_8
END

IF @UpdateMaxPos = 0 
BEGIN
	SELECT  @maxpositiontaking_1 = @old_maxpositiontaking_1,
			@maxpositiontaking_2 = @old_maxpositiontaking_2,
			@maxpositiontaking_3 = @old_maxpositiontaking_3,
			@maxpositiontaking_4 = @old_maxpositiontaking_4,
			@maxpositiontaking_5 = @old_maxpositiontaking_5,
			@maxpositiontaking_6 = @old_maxpositiontaking_6,
			@maxpositiontaking_7 = @old_maxpositiontaking_7,
			@maxpositiontaking_8 = @old_maxpositiontaking_8,
			@maxpositiontaking_9 = @old_maxpositiontaking_9,
			@maxpositiontaking_10 = @old_maxpositiontaking_10,

			@maxlivepositiontaking_1 = @old_maxlivepositiontaking_1,
			@maxlivepositiontaking_3 = @old_maxlivepositiontaking_3,
			@maxlivepositiontaking_7 = @old_maxlivepositiontaking_7,
			@maxlivepositiontaking_8 = @old_maxlivepositiontaking_8
END	

EXEC dbo.Acc_CustOverrideUpd_CheckParam_1
			@custid = @custid,

			@minpositiontaking_1 = @minpositiontaking_1,
			@minpositiontaking_2 = @minpositiontaking_2,
			@minpositiontaking_3 = @minpositiontaking_3,
			@minpositiontaking_4 = @minpositiontaking_4,
			@minpositiontaking_5 = @minpositiontaking_5,
			@minpositiontaking_6 = @minpositiontaking_6,
			@minpositiontaking_7 = @minpositiontaking_7,
			@minpositiontaking_8 = @minpositiontaking_8,
			@minpositiontaking_9 = @minpositiontaking_9,
			@minpositiontaking_10 = @minpositiontaking_10,

			@minlivepositiontaking_1 = @minlivepositiontaking_1,
			@minlivepositiontaking_3 = @minlivepositiontaking_3,
			@minlivepositiontaking_7 = @minlivepositiontaking_7,
			@minlivepositiontaking_8 = @minlivepositiontaking_8,

			@maxpositiontaking_1 = @maxpositiontaking_1,
			@maxpositiontaking_2 = @maxpositiontaking_2,
			@maxpositiontaking_3 = @maxpositiontaking_3,
			@maxpositiontaking_4 = @maxpositiontaking_4,
			@maxpositiontaking_5 = @maxpositiontaking_5,
			@maxpositiontaking_6 = @maxpositiontaking_6,
			@maxpositiontaking_7 = @maxpositiontaking_7,
			@maxpositiontaking_8 = @maxpositiontaking_8,
			@maxpositiontaking_9 = @maxpositiontaking_9,
			@maxpositiontaking_10 = @maxpositiontaking_10,

			@maxlivepositiontaking_1 = @maxlivepositiontaking_1,
			@maxlivepositiontaking_3 = @maxlivepositiontaking_3,
			@maxlivepositiontaking_7 = @maxlivepositiontaking_7,
			@maxlivepositiontaking_8 = @maxlivepositiontaking_8,			
			
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
						  select 	@custid as custid,  1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking								
			) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
	where custoverride.custid = @custid			
END

if @UpdateMaxPos = 1
BEGIN
	Update custoverride with (ROWLOCK, UPDLOCK) set maxpositiontaking = b.maxpositiontaking, maxlivepositiontaking = b.maxlivepositiontaking
	from custoverride inner join 	
			(
						  select 	@custid as custid,  1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	@custid as custid,  1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking				
			) as b on custoverride.custid = b.custid and custoverride.sporttype=b.sporttype and custoverride.bettype = b.bettype
	where custoverride.custid = @custid
END

if @roleid = 2
BEGIN
	EXEC dbo.Acc_CustomerUpdAgent_MinMaxPositiontaking_1 @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
	-- The minimum position taking value of agent was modified by agent's upline
	EXEC DB03.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID
END
else if @roleid = 3
BEGIN
	EXEC dbo.Acc_CustomerUpdMaster_MinMaxPositiontaking_1 @mrecommend = @mrecommend, @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMinPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting_00_1 @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting_01_1 @srecommend = @srecommend
END

if @WriteLog = 1
BEGIN
	Declare @LogSPData varchar(5000)
	Declare @TrackingValue2 varchar(5000)
	
	Select @LogSPData = '<Acc_CustOverrideUpd_1><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	
	'<MinMaxPT minpt_1="'+ coalesce(cast(@minpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minpt_2="'+ coalesce(cast(@minpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'minpt_3="'+ coalesce(cast(@minpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'minpt_4="'+ coalesce(cast(@minpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'minpt_5="'+ coalesce(cast(@minpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'minpt_6="'+ coalesce(cast(@minpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'minpt_7="'+ coalesce(cast(@minpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'minpt_8="'+ coalesce(cast(@minpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'minpt_9="'+ coalesce(cast(@minpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'minpt_10="'+ coalesce(cast(@minpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'minlivept_1="'+ coalesce(cast(@minlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minlivept_3="'+ coalesce(cast(@minlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'minlivept_7="'+ coalesce(cast(@minlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'minlivept_8="'+ coalesce(cast(@minlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'maxpt_1="'+ coalesce(cast(@maxpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxpt_2="'+ coalesce(cast(@maxpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'maxpt_3="'+ coalesce(cast(@maxpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'maxpt_4="'+ coalesce(cast(@maxpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'maxpt_5="'+ coalesce(cast(@maxpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'maxpt_6="'+ coalesce(cast(@maxpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'maxpt_7="'+ coalesce(cast(@maxpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'maxpt_8="'+ coalesce(cast(@maxpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'maxpt_9="'+ coalesce(cast(@maxpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'maxpt_10="'+ coalesce(cast(@maxpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'maxlivept_1="'+ coalesce(cast(@maxlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxlivept_3="'+ coalesce(cast(@maxlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'maxlivept_7="'+ coalesce(cast(@maxlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'maxlivept_8="'+ coalesce(cast(@maxlivepositiontaking_8 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_1>'
	
	SELECT @TrackingValue2 = '<Acc_CustOverrideUpd_1><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	
	'<MinMaxPT minpt_1="'+ coalesce(cast(@old_minpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minpt_2="'+ coalesce(cast(@old_minpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'minpt_3="'+ coalesce(cast(@old_minpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'minpt_4="'+ coalesce(cast(@old_minpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'minpt_5="'+ coalesce(cast(@old_minpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'minpt_6="'+ coalesce(cast(@old_minpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'minpt_7="'+ coalesce(cast(@old_minpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'minpt_8="'+ coalesce(cast(@old_minpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'minpt_9="'+ coalesce(cast(@old_minpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'minpt_10="'+ coalesce(cast(@old_minpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'minlivept_1="'+ coalesce(cast(@old_minlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'minlivept_3="'+ coalesce(cast(@old_minlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'minlivept_7="'+ coalesce(cast(@old_minlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'minlivept_8="'+ coalesce(cast(@old_minlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'maxpt_1="'+ coalesce(cast(@old_maxpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxpt_2="'+ coalesce(cast(@old_maxpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'maxpt_3="'+ coalesce(cast(@old_maxpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'maxpt_4="'+ coalesce(cast(@old_maxpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'maxpt_5="'+ coalesce(cast(@old_maxpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'maxpt_6="'+ coalesce(cast(@old_maxpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'maxpt_7="'+ coalesce(cast(@old_maxpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'maxpt_8="'+ coalesce(cast(@old_maxpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'maxpt_9="'+ coalesce(cast(@old_maxpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'maxpt_10="'+ coalesce(cast(@old_maxpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'maxlivept_1="'+ coalesce(cast(@old_maxlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'maxlivept_3="'+ coalesce(cast(@old_maxlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'maxlivept_7="'+ coalesce(cast(@old_maxlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'maxlivept_8="'+ coalesce(cast(@old_maxlivepositiontaking_8 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_1>'
		
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_1] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_1] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_1] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_1] TO [vnteam]