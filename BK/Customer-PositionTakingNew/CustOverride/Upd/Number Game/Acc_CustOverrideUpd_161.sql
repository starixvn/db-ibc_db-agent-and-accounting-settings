CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_161] 
	@custid int,

	@minv161positiontaking_81 smallmoney,
	@minv161positiontaking_83 smallmoney,
	--@minv161positiontaking_85 smallmoney,
	@minv161positiontaking_86 smallmoney,
	@minv161positiontaking_88 smallmoney = 0,
	
	@minv161livepositiontaking_85 smallmoney,
	@minv161livepositiontaking_86 smallmoney,
	@minv161livepositiontaking_87 smallmoney,
	@minv161livepositiontaking_89 smallmoney = 0,
	@minv161livepositiontaking_90 smallmoney = 0,

	@maxv161positiontaking_81 smallmoney,
	@maxv161positiontaking_83 smallmoney,
	--@maxv161positiontaking_85 smallmoney,
	@maxv161positiontaking_86 smallmoney,
	@maxv161positiontaking_88 smallmoney = 0,
	
	@maxv161livepositiontaking_85 smallmoney,
	@maxv161livepositiontaking_86 smallmoney,
	@maxv161livepositiontaking_87 smallmoney,
	@maxv161livepositiontaking_89 smallmoney = 0,
	@maxv161livepositiontaking_90 smallmoney = 0,
	
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
Task : Update CustOverride for Number Game
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
-- Hardcode by Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
SELECT	@minv161livepositiontaking_90 = 0,
		@maxv161livepositiontaking_90 = 0

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
Declare @old_minv161positiontaking_81 smallmoney,
		@old_minv161positiontaking_83 smallmoney,
		--@old_minv161positiontaking_85 smallmoney,
		@old_minv161positiontaking_86 smallmoney,
		@old_minv161positiontaking_88 smallmoney,
		
		@old_minv161livepositiontaking_85 smallmoney,
		@old_minv161livepositiontaking_86 smallmoney,
		@old_minv161livepositiontaking_87 smallmoney,
		@old_minv161livepositiontaking_89 smallmoney,
		@old_minv161livepositiontaking_90 smallmoney,

		@old_maxv161positiontaking_81 smallmoney,
		@old_maxv161positiontaking_83 smallmoney,
		--@old_maxv161positiontaking_85 smallmoney,
		@old_maxv161positiontaking_86 smallmoney,
		@old_maxv161positiontaking_88 smallmoney,
		
		@old_maxv161livepositiontaking_85 smallmoney,
		@old_maxv161livepositiontaking_86 smallmoney,
		@old_maxv161livepositiontaking_87 smallmoney,
		@old_maxv161livepositiontaking_89 smallmoney,
		@old_maxv161livepositiontaking_90 smallmoney	
	
--Get Old data
select @old_minv161positiontaking_81 = minpositiontaking, @old_maxv161positiontaking_81 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 81
select @old_minv161positiontaking_83 = minpositiontaking, @old_maxv161positiontaking_83 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 83
--select @old_minv161positiontaking_85 = minpositiontaking, @old_maxv161positiontaking_85 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 85
select @old_minv161positiontaking_86 = minpositiontaking, @old_maxv161positiontaking_86 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 86
select @old_minv161positiontaking_88 = minpositiontaking, @old_maxv161positiontaking_88 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 88

select @old_minv161livepositiontaking_85 = minlivepositiontaking, @old_maxv161livepositiontaking_85 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype = 161 and bettype = 85
select @old_minv161livepositiontaking_86 = minlivepositiontaking, @old_maxv161livepositiontaking_86 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype = 161 and bettype = 86
select @old_minv161livepositiontaking_87 = minlivepositiontaking, @old_maxv161livepositiontaking_87 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype = 161 and bettype = 87
select @old_minv161livepositiontaking_89 = minlivepositiontaking, @old_maxv161livepositiontaking_89 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype = 161 and bettype = 89
select @old_minv161livepositiontaking_90 = minlivepositiontaking, @old_maxv161livepositiontaking_90 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype = 161 and bettype = 90
	
--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or 
		(
			@minv161positiontaking_81 = @old_minv161positiontaking_81 and
			@minv161positiontaking_83 = @old_minv161positiontaking_83 and
			--@minv161positiontaking_85 = @old_minv161positiontaking_85 and
			@minv161positiontaking_86 = @old_minv161positiontaking_86 and
			@minv161positiontaking_88 = @old_minv161positiontaking_88 and
			
			@minv161livepositiontaking_85 = @old_minv161livepositiontaking_85 and
			@minv161livepositiontaking_86 = @old_minv161livepositiontaking_86 and
			@minv161livepositiontaking_87 = @old_minv161livepositiontaking_87 and
			@minv161livepositiontaking_89 = @old_minv161livepositiontaking_89 and
			@minv161livepositiontaking_90 = @old_minv161livepositiontaking_90			
		)
	)
	and 
	( @UpdateMaxPos = 0 or
		(
			@maxv161positiontaking_81 = @old_maxv161positiontaking_81 and
			@maxv161positiontaking_83 = @old_maxv161positiontaking_83 and
			--@maxv161positiontaking_85 = @old_maxv161positiontaking_85 and
			@maxv161positiontaking_86 = @old_maxv161positiontaking_86 and
			@maxv161positiontaking_88 = @old_maxv161positiontaking_88 and
			
			@maxv161livepositiontaking_85 = @old_maxv161livepositiontaking_85 and
			@maxv161livepositiontaking_86 = @old_maxv161livepositiontaking_86 and
			@maxv161livepositiontaking_87 = @old_maxv161livepositiontaking_87 and
			@maxv161livepositiontaking_89 = @old_maxv161livepositiontaking_89 and
			@maxv161livepositiontaking_90 = @old_maxv161livepositiontaking_90 
		)
	)
BEGIN
	return
END

--check and set new values
IF(@UpdateMinPos = 0)	
BEGIN
	SELECT  @minv161positiontaking_81 = @old_minv161positiontaking_81,
			@minv161positiontaking_83 = @old_minv161positiontaking_83,
			--@minv161positiontaking_85 = @old_minv161positiontaking_85,
			@minv161positiontaking_86 = @old_minv161positiontaking_86,
			@minv161positiontaking_88 = @old_minv161positiontaking_88,
			
			@minv161livepositiontaking_85 = @old_minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @old_minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @old_minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @old_minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @old_minv161livepositiontaking_90  
END

IF @UpdateMaxPos = 0 
BEGIN
	SELECT  @maxv161positiontaking_81 = @old_maxv161positiontaking_81,
			@maxv161positiontaking_83 = @old_maxv161positiontaking_83,
			--@maxv161positiontaking_85 = @old_maxv161positiontaking_85,
			@maxv161positiontaking_86 = @old_maxv161positiontaking_86,
			@maxv161positiontaking_88 = @old_maxv161positiontaking_88,
			
			@maxv161livepositiontaking_85 = @old_maxv161livepositiontaking_85,
			@maxv161livepositiontaking_86 = @old_maxv161livepositiontaking_86,
			@maxv161livepositiontaking_87 = @old_maxv161livepositiontaking_87,
			@maxv161livepositiontaking_89 = @old_maxv161livepositiontaking_89,
			@maxv161livepositiontaking_90 = @old_maxv161livepositiontaking_90
END	

EXEC dbo.Acc_CustOverrideUpd_CheckParam_161
			@custid = @custid,

			@minv161positiontaking_81 = @minv161positiontaking_81,
			@minv161positiontaking_83 = @minv161positiontaking_83,
			--@minv161positiontaking_85 = @minv161positiontaking_85,
			@minv161positiontaking_86 = @minv161positiontaking_86,
			@minv161positiontaking_88 = @minv161positiontaking_88,
			
			@minv161livepositiontaking_85 = @minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @minv161livepositiontaking_90,

			@maxv161positiontaking_81 = @maxv161positiontaking_81,
			@maxv161positiontaking_83 = @maxv161positiontaking_83,
			--@maxv161positiontaking_85 = @maxv161positiontaking_85,
			@maxv161positiontaking_86 = @maxv161positiontaking_86,
			@maxv161positiontaking_88 = @maxv161positiontaking_88,
			
			@maxv161livepositiontaking_85 = @maxv161livepositiontaking_85,
			@maxv161livepositiontaking_86 = @maxv161livepositiontaking_86,
			@maxv161livepositiontaking_87 = @maxv161livepositiontaking_87,
			@maxv161livepositiontaking_89 = @maxv161livepositiontaking_89,
			@maxv161livepositiontaking_90 = @maxv161livepositiontaking_90,			
			
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
	Update custoverride3rd with (ROWLOCK, UPDLOCK) set minpositiontaking = b.minpositiontaking, minlivepositiontaking = b.minlivepositiontaking
	from custoverride3rd inner join 	
			(
				      select 	@custid as custid,  161 as sporttype, 81 as bettype, @minv161positiontaking_81 as minpositiontaking,  0 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 83 as bettype, @minv161positiontaking_83 as minpositiontaking,  0 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 85 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_85 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 86 as bettype, @minv161positiontaking_86 as minpositiontaking,  @minv161livepositiontaking_86 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 87 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_87 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 88 as bettype, @minv161positiontaking_88 as minpositiontaking,  0 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 89 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_89 as minlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 90 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_90 as minlivepositiontaking
			) as b on custoverride3rd.custid = b.custid and custoverride3rd.sporttype=b.sporttype and custoverride3rd.bettype = b.bettype
	where custoverride3rd.custid = @custid		
END

if @UpdateMaxPos = 1
BEGIN
	Update custoverride3rd with (ROWLOCK, UPDLOCK) set maxpositiontaking = b.maxpositiontaking, maxlivepositiontaking = b.maxlivepositiontaking
	from custoverride3rd inner join 	
			(
				      select 	@custid as custid,  161 as sporttype, 81 as bettype, @maxv161positiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 83 as bettype, @maxv161positiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_85 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 86 as bettype, @maxv161positiontaking_86 as maxpositiontaking,  @maxv161livepositiontaking_86 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_87 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 88 as bettype, @maxv161positiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_89 as maxlivepositiontaking
			union all select 	@custid as custid,  161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_90 as maxlivepositiontaking
			) as b on custoverride3rd.custid = b.custid and custoverride3rd.sporttype=b.sporttype and custoverride3rd.bettype = b.bettype
	where custoverride3rd.custid = @custid
END

if @roleid = 2
BEGIN
	EXEC dbo.Acc_CustomerUpdAgent_MinMaxPositiontaking_161 @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
	-- The minimum position taking value of agent was modified by agent's upline
	EXEC DB03.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID
END
else if @roleid = 3
BEGIN
	EXEC dbo.Acc_CustomerUpdMaster_MinMaxPositiontaking_161 @mrecommend = @mrecommend, @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMinPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting3rd_00_161 @srecommend = @srecommend
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1
BEGIN
	EXEC dbo.Acc_CustSetting3rd_01_161 @srecommend = @srecommend
END

if @WriteLog = 1
BEGIN
	Declare @LogSPData varchar(5000)
	Declare @TrackingValue2 varchar(5000)
	
	Select @LogSPData = '<Acc_CustOverrideUpd_161><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	
	'<MinMaxPT minv161pt_81="'+ coalesce(cast(@minv161positiontaking_81 as varchar(50)),space(1)) + '" ' +
	'minv161pt_83="'+ coalesce(cast(@minv161positiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'minv161pt_85="'+ coalesce(cast(@minv161positiontaking_85 as varchar(50)),space(1)) + '" ' +
	'minv161pt_86="'+ coalesce(cast(@minv161positiontaking_86 as varchar(50)),space(1)) + '" ' +
	'minv161pt_88="'+ coalesce(cast(@minv161positiontaking_88 as varchar(50)),space(1)) + '" ' +
	
	'minv161livept_85="'+ coalesce(cast(@minv161livepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'minv161livept_86="'+ coalesce(cast(@minv161livepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'minv161livept_87="'+ coalesce(cast(@minv161livepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'minv161livept_89="'+ coalesce(cast(@minv161livepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'minv161livept_90="'+ coalesce(cast(@minv161livepositiontaking_90 as varchar(50)),space(1)) + '" ' +
	
	'maxv161pt_81="'+ coalesce(cast(@maxv161positiontaking_81 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_83="'+ coalesce(cast(@maxv161positiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'maxv161pt_85="'+ coalesce(cast(@maxv161positiontaking_85 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_86="'+ coalesce(cast(@maxv161positiontaking_86 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_88="'+ coalesce(cast(@maxv161positiontaking_88 as varchar(50)),space(1)) + '" ' +
	
	'maxv161livept_85="'+ coalesce(cast(@maxv161livepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_86="'+ coalesce(cast(@maxv161livepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_87="'+ coalesce(cast(@maxv161livepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_89="'+ coalesce(cast(@maxv161livepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_90="'+ coalesce(cast(@maxv161livepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_161>'
	
	SELECT @TrackingValue2 = '<Acc_CustOverrideUpd_161><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	
	'<MinMaxPT minv161pt_81="'+ coalesce(cast(@old_minv161positiontaking_81 as varchar(50)),space(1)) + '" ' +
	'minv161pt_83="'+ coalesce(cast(@old_minv161positiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'minv161pt_85="'+ coalesce(cast(@old_minv161positiontaking_85 as varchar(50)),space(1)) + '" ' +
	'minv161pt_86="'+ coalesce(cast(@old_minv161positiontaking_86 as varchar(50)),space(1)) + '" ' +
	'minv161pt_88="'+ coalesce(cast(@old_minv161positiontaking_88 as varchar(50)),space(1)) + '" ' +
	
	'minv161livept_85="'+ coalesce(cast(@old_minv161livepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'minv161livept_86="'+ coalesce(cast(@old_minv161livepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'minv161livept_87="'+ coalesce(cast(@old_minv161livepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'minv161livept_89="'+ coalesce(cast(@old_minv161livepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'minv161livept_90="'+ coalesce(cast(@old_minv161livepositiontaking_90 as varchar(50)),space(1)) + '" ' +
	
	'maxv161pt_81="'+ coalesce(cast(@old_maxv161positiontaking_81 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_83="'+ coalesce(cast(@old_maxv161positiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'maxv161pt_85="'+ coalesce(cast(@old_maxv161positiontaking_85 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_86="'+ coalesce(cast(@old_maxv161positiontaking_86 as varchar(50)),space(1)) + '" ' +
	'maxv161pt_88="'+ coalesce(cast(@old_maxv161positiontaking_88 as varchar(50)),space(1)) + '" ' +
	
	'maxv161livept_85="'+ coalesce(cast(@old_maxv161livepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_86="'+ coalesce(cast(@old_maxv161livepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_87="'+ coalesce(cast(@old_maxv161livepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_89="'+ coalesce(cast(@old_maxv161livepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'maxv161livept_90="'+ coalesce(cast(@old_maxv161livepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpd_161>'
		
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_161] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_161] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_161] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_161] TO [vnteam]