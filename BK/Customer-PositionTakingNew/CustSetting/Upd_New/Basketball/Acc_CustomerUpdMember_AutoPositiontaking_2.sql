ALTER PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_2
	@custid int,

	@auto_v2spositiontaking_1 smallmoney = 0,
	@auto_v2spositiontaking_2 smallmoney = 0,
	@auto_v2spositiontaking_3 smallmoney = 0,
	@auto_v2spositiontaking_7 smallmoney = 0,
	@auto_v2spositiontaking_8 smallmoney = 0,
--	@auto_v2spositiontaking_9 smallmoney = 0,
	@auto_v2spositiontaking_20 smallmoney = 0,

	@isauto_v2spositiontaking_1 bit = 0,
	@isauto_v2spositiontaking_2 bit = 0,
	@isauto_v2spositiontaking_3 bit = 0,
	@isauto_v2spositiontaking_7 bit = 0,
	@isauto_v2spositiontaking_8 bit = 0,
	@isauto_v2spositiontaking_9 bit = 0,
	@isauto_v2spositiontaking_20 bit = 0,

	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Basketball at member level
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
	@autov2positiontaking smallmoney,
	@isautov2positiontaking bit, 
	@old_autov2positiontaking smallmoney,
	@old_isautov2positiontaking bit,
	
	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
	@old_auto_v2spositiontaking_1 smallmoney,
	@old_auto_v2spositiontaking_2 smallmoney,
	@old_auto_v2spositiontaking_3 smallmoney,
	@old_auto_v2spositiontaking_7 smallmoney,
	@old_auto_v2spositiontaking_8 smallmoney,
--	@old_auto_v2spositiontaking_9 smallmoney,
	@old_auto_v2spositiontaking_20 smallmoney,
	
	@old_isauto_v2spositiontaking_1 bit,
	@old_isauto_v2spositiontaking_2 bit,
	@old_isauto_v2spositiontaking_3 bit,
	@old_isauto_v2spositiontaking_7 bit,
	@old_isauto_v2spositiontaking_8 bit,
--	@old_isauto_v2spositiontaking_9 bit,
	@old_isauto_v2spositiontaking_20 bit,
	
	@master_auto_v2spositiontaking_1 smallmoney,
	@master_auto_v2spositiontaking_2 smallmoney,
	@master_auto_v2spositiontaking_3 smallmoney,
	@master_auto_v2spositiontaking_7 smallmoney,
	@master_auto_v2spositiontaking_8 smallmoney,
--	@master_auto_v2spositiontaking_9 smallmoney,
	@master_auto_v2spositiontaking_20 smallmoney,

	@master_isauto_v2spositiontaking_1 bit,
	@master_isauto_v2spositiontaking_2 bit,
	@master_isauto_v2spositiontaking_3 bit,
	@master_isauto_v2spositiontaking_7 bit,
	@master_isauto_v2spositiontaking_8 bit,
--	@master_isauto_v2spositiontaking_9 bit,
	@master_isauto_v2spositiontaking_20 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_v2spositiontaking_1	=	autopositiontaking		,	@old_isauto_v2spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=1
select 	@old_auto_v2spositiontaking_2	=	autopositiontaking		,	@old_isauto_v2spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=2
select 	@old_auto_v2spositiontaking_3	=	autopositiontaking		,	@old_isauto_v2spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=3
select 	@old_auto_v2spositiontaking_7	=	autopositiontaking		,	@old_isauto_v2spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=7
select 	@old_auto_v2spositiontaking_8	=	autopositiontaking		,	@old_isauto_v2spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=8
--select 	@old_auto_v2spositiontaking_9	=	autopositiontaking		,	@old_isauto_v2spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=9
select 	@old_auto_v2spositiontaking_20	=	autopositiontaking		,	@old_isauto_v2spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=20

--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_v2spositiontaking_1 = autopositiontaking, @master_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @master_auto_v2spositiontaking_2 = autopositiontaking, @master_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @master_auto_v2spositiontaking_3 = autopositiontaking, @master_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @master_auto_v2spositiontaking_7 = autopositiontaking, @master_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @master_auto_v2spositiontaking_8 = autopositiontaking, @master_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
--select @master_auto_v2spositiontaking_9 = autopositiontaking, @master_isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @master_auto_v2spositiontaking_20 = autopositiontaking, @master_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2

--------------------------------------------------------
--Update Member account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
					 	select 1 as bettype, 2 as sporttype, @auto_v2spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @auto_v2spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @auto_v2spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
			union all 	select 7 as bettype, 2 as sporttype, @auto_v2spositiontaking_7 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_7 as isautopositiontaking, 0	as isautolivepositiontaking
			union all 	select 8 as bettype, 2 as sporttype, @auto_v2spositiontaking_8 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_8 as isautopositiontaking, 0	as isautolivepositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @auto_v2spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @auto_v2spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
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
	@auto_v2spositiontaking_1 = case when @isauto_v2spositiontaking_1>0 then @auto_v2spositiontaking_1 else @master_auto_v2spositiontaking_1 end,
	@auto_v2spositiontaking_2 = case when @isauto_v2spositiontaking_2>0 then @auto_v2spositiontaking_2 else @master_auto_v2spositiontaking_2 end,
	@auto_v2spositiontaking_3 = case when @isauto_v2spositiontaking_3>0 then @auto_v2spositiontaking_3 else @master_auto_v2spositiontaking_3 end,
	@auto_v2spositiontaking_7 = case when @isauto_v2spositiontaking_7>0 then @auto_v2spositiontaking_7 else @master_auto_v2spositiontaking_7 end,
	@auto_v2spositiontaking_8 = case when @isauto_v2spositiontaking_8>0 then @auto_v2spositiontaking_8 else @master_auto_v2spositiontaking_8 end,
--		@auto_v2spositiontaking_9 = case when @isauto_v2spositiontaking_9>0 then @auto_v2spositiontaking_9 else @master_auto_v2spositiontaking_9 end,
	@auto_v2spositiontaking_20 = case when @isauto_v2spositiontaking_20>0 then @auto_v2spositiontaking_20 else @master_auto_v2spositiontaking_20 end,

	@isauto_v2spositiontaking_1 = case when @isauto_v2spositiontaking_1>0 then @isauto_v2spositiontaking_1 else @master_isauto_v2spositiontaking_1 end,
	@isauto_v2spositiontaking_2 = case when @isauto_v2spositiontaking_2>0 then @isauto_v2spositiontaking_2 else @master_isauto_v2spositiontaking_2 end,
	@isauto_v2spositiontaking_3 = case when @isauto_v2spositiontaking_3>0 then @isauto_v2spositiontaking_3 else @master_isauto_v2spositiontaking_3 end,
	@isauto_v2spositiontaking_7 = case when @isauto_v2spositiontaking_7>0 then @isauto_v2spositiontaking_7 else @master_isauto_v2spositiontaking_7 end,
	@isauto_v2spositiontaking_8 = case when @isauto_v2spositiontaking_8>0 then @isauto_v2spositiontaking_8 else @master_isauto_v2spositiontaking_8 end,
--		@isauto_v2spositiontaking_9 = case when @isauto_v2spositiontaking_9>0 then @isauto_v2spositiontaking_9 else @master_isauto_v2spositiontaking_9 end,
	@isauto_v2spositiontaking_20 = case when @isauto_v2spositiontaking_20>0 then @isauto_v2spositiontaking_20 else @master_isauto_v2spositiontaking_20 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v2spositiontaking_1 as isautov2positiontaking	,	   @auto_v2spositiontaking_1 as autov2positiontaking	,	   @old_auto_v2spositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking
union all  	select 2 as bettype	,	   @isauto_v2spositiontaking_2 as isautov2positiontaking	,	   @auto_v2spositiontaking_2 as autov2positiontaking	,	     @old_auto_v2spositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking
union all 	select 3 as bettype	,	   @isauto_v2spositiontaking_3 as isautov2positiontaking	,	   @auto_v2spositiontaking_3 as autov2positiontaking	,	   @old_auto_v2spositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking
union all  	select 7 as bettype	,	   @isauto_v2spositiontaking_7 as isautov2positiontaking	,	   @auto_v2spositiontaking_7 as autov2positiontaking	,	   @old_auto_v2spositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking
union all  	select 8 as bettype	,	   @isauto_v2spositiontaking_8 as isautov2positiontaking	,	   @auto_v2spositiontaking_8 as autov2positiontaking	,	   @old_auto_v2spositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking
union all 	select 20 as bettype,	   @isauto_v2spositiontaking_20 as isautov2positiontaking	,	   @auto_v2spositiontaking_20 as autov2positiontaking	,	   @old_auto_v2spositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking
-------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking
	
WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,7,8,20)
	BEGIN
		if @isautov2positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=2
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking (for Basketball)'
						when 'CS' then N'更新占成数不成功(于篮球))'
						when 'CT' then N'更新佔成數不成功(於籃球)'
						when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบาสเก็ตบอล)'
						when 'J' then N'Error updating auto position taking (for Basketball)'
						when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (농구)'
						else N'Error updating auto position taking (for Basketball)'
					end	
				RaisError (@ErrMsg, 16, 1)
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END	
FETCH NEXT FROM CUR INTO			
	@bettype, @isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_2 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_2 TO [bodbAdminNet]
 
  