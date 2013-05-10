CREATE PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_1
	@custid int,

	@auto_spositiontaking_1 smallmoney = 0,
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney= 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
	@isauto_spositiontaking_1 bit = 0,
	@isauto_spositiontaking_2 bit = 0,
	@isauto_spositiontaking_3 bit = 0,
	@isauto_spositiontaking_4 bit = 0,
	@isauto_spositiontaking_5 bit= 0,
	@isauto_spositiontaking_6 bit = 0,
	@isauto_spositiontaking_7 bit = 0,
	@isauto_spositiontaking_8 bit = 0,
	@isauto_spositiontaking_9 bit = 0,
	@isauto_spositiontaking_10 bit = 0,
	
	@isauto_slivepositiontaking_1 bit = 0,
	@isauto_slivepositiontaking_3 bit = 0,
	@isauto_slivepositiontaking_7 bit = 0,
	@isauto_slivepositiontaking_8 bit = 0,
	
	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Soccer at member level
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdMember_AutoPositiontaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
Declare @ErrMsg nvarchar(2000)
Declare @bettype int,
	@autopositiontaking smallmoney, 	
	@isautopositiontaking bit,	
	@old_autopositiontaking smallmoney,
	@old_isautopositiontaking bit,
	
	@autolivepositiontaking smallmoney,
	@isautolivepositiontaking bit,	
	@old_autolivepositiontaking smallmoney,
	@old_isautolivepositiontaking bit,
	
	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
	@old_auto_spositiontaking_1 smallmoney,
	@old_auto_spositiontaking_2 smallmoney,
	@old_auto_spositiontaking_3 smallmoney,
	@old_auto_spositiontaking_4 smallmoney,
	@old_auto_spositiontaking_5 smallmoney,
	@old_auto_spositiontaking_6 smallmoney,
	@old_auto_spositiontaking_7 smallmoney,
	@old_auto_spositiontaking_8 smallmoney,
	@old_auto_spositiontaking_9 smallmoney,
	@old_auto_spositiontaking_10 smallmoney,	
	@old_auto_slivepositiontaking_1 smallmoney,
	@old_auto_slivepositiontaking_3 smallmoney,
	@old_auto_slivepositiontaking_7 smallmoney,
	@old_auto_slivepositiontaking_8 smallmoney,

	@old_isauto_spositiontaking_1 bit,
	@old_isauto_spositiontaking_2 bit,
	@old_isauto_spositiontaking_3 bit,
	@old_isauto_spositiontaking_4 bit,
	@old_isauto_spositiontaking_5 bit,
	@old_isauto_spositiontaking_6 bit,
	@old_isauto_spositiontaking_7 bit,
	@old_isauto_spositiontaking_8 bit,
	@old_isauto_spositiontaking_9 bit,
	@old_isauto_spositiontaking_10 bit,
	
	@old_isauto_slivepositiontaking_1 bit,
	@old_isauto_slivepositiontaking_3 bit,
	@old_isauto_slivepositiontaking_7 bit,
	@old_isauto_slivepositiontaking_8 bit,
	
	@master_auto_spositiontaking_1 smallmoney,
	@master_auto_spositiontaking_2 smallmoney,
	@master_auto_spositiontaking_3 smallmoney,
	@master_auto_spositiontaking_4 smallmoney,
	@master_auto_spositiontaking_5 smallmoney,
	@master_auto_spositiontaking_6 smallmoney,
	@master_auto_spositiontaking_7 smallmoney,
	@master_auto_spositiontaking_8 smallmoney,
	@master_auto_spositiontaking_9 smallmoney,
	@master_auto_spositiontaking_10 smallmoney,
	
	@master_auto_slivepositiontaking_1 smallmoney,
	@master_auto_slivepositiontaking_3 smallmoney,
	@master_auto_slivepositiontaking_7 smallmoney,
	@master_auto_slivepositiontaking_8 smallmoney,

	@master_isauto_spositiontaking_1 bit,
	@master_isauto_spositiontaking_2 bit,
	@master_isauto_spositiontaking_3 bit,
	@master_isauto_spositiontaking_4 bit,
	@master_isauto_spositiontaking_5 bit,
	@master_isauto_spositiontaking_6 bit,
	@master_isauto_spositiontaking_7 bit,
	@master_isauto_spositiontaking_8 bit,
	@master_isauto_spositiontaking_9 bit,
	@master_isauto_spositiontaking_10 bit,
	
	@master_isauto_slivepositiontaking_1 bit,
	@master_isauto_slivepositiontaking_3 bit,
	@master_isauto_slivepositiontaking_7 bit,
	@master_isauto_slivepositiontaking_8 bit
	
--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_spositiontaking_1	=	autopositiontaking		,	@old_isauto_spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=1
select 	@old_auto_spositiontaking_2	=	autopositiontaking		,	@old_isauto_spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=2
select 	@old_auto_spositiontaking_3	=	autopositiontaking		,	@old_isauto_spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=3
select 	@old_auto_spositiontaking_4	=	autopositiontaking		,	@old_isauto_spositiontaking_4	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=4
select 	@old_auto_spositiontaking_5	=	autopositiontaking		,	@old_isauto_spositiontaking_5	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=5
select 	@old_auto_spositiontaking_6	=	autopositiontaking		,	@old_isauto_spositiontaking_6	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=6
select 	@old_auto_spositiontaking_7	=	autopositiontaking		,	@old_isauto_spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=7
select 	@old_auto_spositiontaking_8	=	autopositiontaking		,	@old_isauto_spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=8
select 	@old_auto_spositiontaking_9	=	autopositiontaking		,	@old_isauto_spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=9
select 	@old_auto_spositiontaking_10	=	autopositiontaking		,	@old_isauto_spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=10
select 	@old_auto_slivepositiontaking_1	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_1	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=1
select 	@old_auto_slivepositiontaking_3	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_3	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=3
select 	@old_auto_slivepositiontaking_7	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_7	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=7
select 	@old_auto_slivepositiontaking_8	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_8	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=8

--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_spositiontaking_1 = autopositiontaking, @master_auto_slivepositiontaking_1 = autolivepositiontaking, @master_isauto_spositiontaking_1 = isautopositiontaking, @master_isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @master_auto_spositiontaking_3 = autopositiontaking, @master_auto_slivepositiontaking_3 = autolivepositiontaking, @master_isauto_spositiontaking_3 = isautopositiontaking, @master_isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @master_auto_spositiontaking_7 = autopositiontaking, @master_auto_slivepositiontaking_7 = autolivepositiontaking, @master_isauto_spositiontaking_7 = isautopositiontaking, @master_isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @master_auto_spositiontaking_8 = autopositiontaking, @master_auto_slivepositiontaking_8 = autolivepositiontaking, @master_isauto_spositiontaking_8 = isautopositiontaking, @master_isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
select @master_auto_spositiontaking_2 = autopositiontaking, @master_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @master_auto_spositiontaking_4 = autopositiontaking, @master_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @master_auto_spositiontaking_5 = autopositiontaking, @master_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @master_auto_spositiontaking_6 = autopositiontaking, @master_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @master_auto_spositiontaking_9 = autopositiontaking, @master_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @master_auto_spositiontaking_10 = autopositiontaking, @master_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

--------------------------------------------------------
--Update Member account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
		(
					select 1 as bettype, 1 as sporttype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1	as autolivepositiontaking, @isauto_spositiontaking_1 as isautopositiontaking, @isauto_slivepositiontaking_1	as isautolivepositiontaking
		union all 	select 2 as bettype, 1 as sporttype, @auto_spositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking
		union all 	select 3 as bettype, 1 as sporttype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 	as autolivepositiontaking, @isauto_spositiontaking_3 as isautopositiontaking, @isauto_slivepositiontaking_3	as isautolivepositiontaking
		union all 	select 4 as bettype, 1 as sporttype, @auto_spositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking
		union all 	select 5 as bettype, 1 as sporttype, @auto_spositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking
		union all 	select 6 as bettype, 1 as sporttype, @auto_spositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking
		union all 	select 7 as bettype, 1 as sporttype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 	as autolivepositiontaking, @isauto_spositiontaking_7 as isautopositiontaking, @isauto_slivepositiontaking_7	as isautolivepositiontaking
		union all 	select 8 as bettype, 1 as sporttype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 	as autolivepositiontaking, @isauto_spositiontaking_8 as isautopositiontaking, @isauto_slivepositiontaking_8	as isautolivepositiontaking
		union all 	select 9 as bettype, 1 as sporttype, @auto_spositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking
		union all 	select 10 as bettype, 1 as sporttype, @auto_spositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking
		) as b on b.bettype = custsetting.bettype and b.sporttype = custsetting.sporttype
where custsetting.custid = @custid
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
	case @Language 
		when 'E' then 'Error updating auto position taking'
		when 'CS' then N'更新占成数不成功'
		when 'CT' then N'更新佔成數不成功'
		when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์'
		when 'J' then N'Error updating auto position taking'
		when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다.'
		else N'Error updating auto position taking'
	end	
	RaisError (@ErrMsg, 16, 1)
	return
END
	
---------------------------------------------------------------------------------------------------------------------------------------------
--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
select 
	@auto_spositiontaking_1 = case when @isauto_spositiontaking_1>0 then @auto_spositiontaking_1 else @master_auto_spositiontaking_1 end,
	@auto_spositiontaking_2 = case when @isauto_spositiontaking_2>0 then @auto_spositiontaking_2 else @master_auto_spositiontaking_2 end,
	@auto_spositiontaking_3 = case when @isauto_spositiontaking_3>0 then @auto_spositiontaking_3 else @master_auto_spositiontaking_3 end,
	@auto_spositiontaking_4 = case when @isauto_spositiontaking_4>0 then @auto_spositiontaking_4 else @master_auto_spositiontaking_4 end,
	@auto_spositiontaking_5 = case when @isauto_spositiontaking_5>0 then @auto_spositiontaking_5 else @master_auto_spositiontaking_5 end,
	@auto_spositiontaking_6 = case when @isauto_spositiontaking_6>0 then @auto_spositiontaking_6 else @master_auto_spositiontaking_6 end,
	@auto_spositiontaking_7 = case when @isauto_spositiontaking_7>0 then @auto_spositiontaking_7 else @master_auto_spositiontaking_7 end,
	@auto_spositiontaking_8 = case when @isauto_spositiontaking_8>0 then @auto_spositiontaking_8 else @master_auto_spositiontaking_8 end,
	@auto_spositiontaking_9 = case when @isauto_spositiontaking_9>0 then @auto_spositiontaking_9 else @master_auto_spositiontaking_9 end,
	@auto_spositiontaking_10 = case when @isauto_spositiontaking_10>0 then @auto_spositiontaking_10 else @master_auto_spositiontaking_10 end,

	@auto_slivepositiontaking_1 = case when @isauto_slivepositiontaking_1>0 then @auto_slivepositiontaking_1 else @master_auto_slivepositiontaking_1 end,
	@auto_slivepositiontaking_3 = case when @isauto_slivepositiontaking_3>0 then @auto_slivepositiontaking_3 else @master_auto_slivepositiontaking_3 end,
	@auto_slivepositiontaking_7 = case when @isauto_slivepositiontaking_7>0 then @auto_slivepositiontaking_7 else @master_auto_slivepositiontaking_7 end,
	@auto_slivepositiontaking_8 = case when @isauto_slivepositiontaking_8>0 then @auto_slivepositiontaking_8 else @master_auto_slivepositiontaking_8 end,

	@isauto_spositiontaking_1 = case when @isauto_spositiontaking_1>0 then @isauto_spositiontaking_1 else @master_isauto_spositiontaking_1 end,
	@isauto_spositiontaking_2 = case when @isauto_spositiontaking_2>0 then @isauto_spositiontaking_2 else @master_isauto_spositiontaking_2 end,
	@isauto_spositiontaking_3 = case when @isauto_spositiontaking_3>0 then @isauto_spositiontaking_3 else @master_isauto_spositiontaking_3 end,
	@isauto_spositiontaking_4 = case when @isauto_spositiontaking_4>0 then @isauto_spositiontaking_4 else @master_isauto_spositiontaking_4 end,
	@isauto_spositiontaking_5 = case when @isauto_spositiontaking_5>0 then @isauto_spositiontaking_5 else @master_isauto_spositiontaking_5 end,
	@isauto_spositiontaking_6 = case when @isauto_spositiontaking_6>0 then @isauto_spositiontaking_6 else @master_isauto_spositiontaking_6 end,
	@isauto_spositiontaking_7 = case when @isauto_spositiontaking_7>0 then @isauto_spositiontaking_7 else @master_isauto_spositiontaking_7 end,
	@isauto_spositiontaking_8 = case when @isauto_spositiontaking_8>0 then @isauto_spositiontaking_8 else @master_isauto_spositiontaking_8 end,
	@isauto_spositiontaking_9 = case when @isauto_spositiontaking_9>0 then @isauto_spositiontaking_9 else @master_isauto_spositiontaking_9 end,
	@isauto_spositiontaking_10 = case when @isauto_spositiontaking_10>0 then @isauto_spositiontaking_10 else @master_isauto_spositiontaking_10 end,

	@isauto_slivepositiontaking_1 = case when @isauto_slivepositiontaking_1>0 then @isauto_slivepositiontaking_1 else @master_isauto_slivepositiontaking_1 end,
	@isauto_slivepositiontaking_3 = case when @isauto_slivepositiontaking_3>0 then @isauto_slivepositiontaking_3 else @master_isauto_slivepositiontaking_3 end,
	@isauto_slivepositiontaking_7 = case when @isauto_slivepositiontaking_7>0 then @isauto_slivepositiontaking_7 else @master_isauto_slivepositiontaking_7 end,
	@isauto_slivepositiontaking_8 = case when @isauto_slivepositiontaking_8>0 then @isauto_slivepositiontaking_8 else @master_isauto_slivepositiontaking_8 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_spositiontaking_1 as isautopositiontaking	,	  @isauto_slivepositiontaking_1 as isautolivepositiontaking	,	  @auto_spositiontaking_1 as autopositiontaking	,	   @auto_slivepositiontaking_1 as autolivepositiontaking	,	  @old_auto_spositiontaking_1 as old_autopositiontaking	    ,	   @old_auto_slivepositiontaking_1 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_1 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking
union all  	select 2 as bettype	,	   @isauto_spositiontaking_2 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_2 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_2 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_2 as old_isautopositiontaking    	,										0 as old_isautolivepositiontaking
union all 	select 3 as bettype	,	   @isauto_spositiontaking_3 as isautopositiontaking	,	  @isauto_slivepositiontaking_3 as isautolivepositiontaking	,	  @auto_spositiontaking_3 as autopositiontaking	,	   @auto_slivepositiontaking_3 as autolivepositiontaking	,		@old_auto_spositiontaking_3 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_3 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_3 as old_isautopositiontaking	    ,		@old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking
union all  	select 4 as bettype	,	   @isauto_spositiontaking_4 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_4 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_4 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_4 as old_isautopositiontaking	,										 0 as old_isautolivepositiontaking
union all 	select 5 as bettype	,	   @isauto_spositiontaking_5 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_5 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_5 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_5 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking
union all  	select 6 as bettype	,	   @isauto_spositiontaking_6 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_6 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_6 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_6 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking
union all  	select 7 as bettype	,	   @isauto_spositiontaking_7 as isautopositiontaking	,	  @isauto_slivepositiontaking_7 as isautolivepositiontaking	,	  @auto_spositiontaking_7 as autopositiontaking	,	   @auto_slivepositiontaking_7 as autolivepositiontaking	,		@old_auto_spositiontaking_7 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_7 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_7 as old_isautopositiontaking	    ,		 @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking
union all  	select 8 as bettype	,	   @isauto_spositiontaking_8 as isautopositiontaking	,	  @isauto_slivepositiontaking_8 as isautolivepositiontaking	,	  @auto_spositiontaking_8 as autopositiontaking	,	   @auto_slivepositiontaking_8 as autolivepositiontaking	,		@old_auto_spositiontaking_8 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_8 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_8 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking
union all  	select 9 as bettype	,	   @isauto_spositiontaking_9 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_9 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_9 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_9 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking
union all  	select 10 as bettype,	   @isauto_spositiontaking_10 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_10 as autopositiontaking,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_10 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_10 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking
union all 	select 20 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking  
union all  	select 21 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	 
union all  	select 22 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	 

-------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking
	
WHILE @@FETCH_STATUS = 0
BEGIN
	if @isautopositiontaking >0
	BEGIN
		select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
		update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
		where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
		if @@Error <> 0
		BEGIN
			
			SELECT @ErrMsg =  
				case @Language 
					when 'E' then 'Error updating auto position taking (for Soccer)'
					when 'CS' then N'更新占成数不成功(于足球)'
					when 'CT' then N'更新佔成數不成功(於足球)'
					when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาฟุตบอล)'
					when 'J' then N'Error updating auto position taking (for Soccer)'
					when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (축구)'
					else N'Error updating auto position taking (for Soccer)'
				end	
			RaisError (@ErrMsg, 16, 1)
			DEALLOCATE CUR
			CLOSE CUR
			return
		END
	---------------------------------
	--Update LIVE
		if @bettype in (1,3,7,8) --and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking)
		BEGIN
			if @isautolivepositiontaking >0
			BEGIN
				select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
				from custsetting
				where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
				if @@Error <> 0
				BEGIN
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Soccer - LIVE)'
							when 'CS' then N'更新占成数不成功(于足球-现场)'
							when 'CT' then N'更新佔成數不成功(於足球-現場)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ ( สำหรับการเล่นสดขณะแข่งขัน ของฟุตบอล)'
							when 'J' then N'Error updating auto position taking (for Soccer - LIVE)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (축구- 생중계)'
							else N'Error updating auto position taking (for Soccer - LIVE)'
						end	
					RaisError (@ErrMsg, 16, 1)
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END		
	End --@UpdatePositiontaking
		
FETCH NEXT FROM CUR INTO			
	@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_1 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_1 TO [bodbAdminNet]
 