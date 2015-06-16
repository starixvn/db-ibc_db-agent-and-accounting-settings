ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_2
	@mrecommend int,
	@srecommend int,

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
--	@isauto_v2spositiontaking_9 bit = 0,
	@isauto_v2spositiontaking_20 bit = 0,

	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Basketball at master level
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdMaster_AutoPositiontaking

Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
Declare
	@bettype int,
	@maxpos smallmoney,

	@autov2positiontaking smallmoney,
	@old_autov2positiontaking smallmoney,
	@isautov2positiontaking bit,
	@old_isautov2positiontaking bit

Declare 
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
	@old_isauto_v2spositiontaking_20 bit
	
--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v2spositiontaking_1	=	autopositiontaking		,	@old_isauto_v2spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	1
select 	@old_auto_v2spositiontaking_2	=	autopositiontaking		,	@old_isauto_v2spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	2
select 	@old_auto_v2spositiontaking_3	=	autopositiontaking		,	@old_isauto_v2spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	3
select 	@old_auto_v2spositiontaking_7	=	autopositiontaking		,	@old_isauto_v2spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	7
select 	@old_auto_v2spositiontaking_8	=	autopositiontaking		,	@old_isauto_v2spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	8
--select 	@old_auto_v2spositiontaking_9	=	autopositiontaking		,	@old_isauto_v2spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	9
select 	@old_auto_v2spositiontaking_20	=	autopositiontaking		,	@old_isauto_v2spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=2	and bettype=	20

--Update Master Agent account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
	(
				select 1 as bettype, @auto_v2spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 2 as bettype, @auto_v2spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 3 as bettype, @auto_v2spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 7 as bettype, @auto_v2spositiontaking_7 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_7 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 8 as bettype, @auto_v2spositiontaking_8 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_8 as isautopositiontaking, 0	as isautolivepositiontaking
	--union all 	select 9 as bettype, @auto_v2spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, @auto_v2spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
	) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=2
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (for Basketball)'
			when 'CS' then N'更新占成数不成功(于篮球)'
			when 'CT' then N'更新佔成數不成功(於籃球)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบาสเก็ตบอล)'
			when 'J' then N'Error updating auto position taking (for Basketball)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (농구)'
			else N'Error updating auto position taking (for Basketball)'
		end	
		,  @ErrCode=202
	return
END

Declare CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v2spositiontaking_1 as isautov2positiontaking	,	   @auto_v2spositiontaking_1 as autov2positiontaking	,	   @old_auto_v2spositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking
union all  	select 2 as bettype	,	   @isauto_v2spositiontaking_2 as isautov2positiontaking	,	   @auto_v2spositiontaking_2 as autov2positiontaking	,	   @old_auto_v2spositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking
union all 	select 3 as bettype	,	   @isauto_v2spositiontaking_3 as isautov2positiontaking	,	   @auto_v2spositiontaking_3 as autov2positiontaking	,	   @old_auto_v2spositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking
union all  	select 7 as bettype	,	   @isauto_v2spositiontaking_7 as isautov2positiontaking	,	   @auto_v2spositiontaking_7 as autov2positiontaking	,	   @old_auto_v2spositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking
union all  	select 8 as bettype	,	   @isauto_v2spositiontaking_8 as isautov2positiontaking	,	   @auto_v2spositiontaking_8 as autov2positiontaking	,	   @old_auto_v2spositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking
union all 	select 20 as bettype,	   @isauto_v2spositiontaking_20 as isautov2positiontaking	,	   @auto_v2spositiontaking_20 as autov2positiontaking	,	   @old_auto_v2spositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking
WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,7,8,20) and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking )
	BEGIN
		if @isautov2positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Basketball)'
							when 'CS' then N'更新占成数不成功(于篮球)'
							when 'CT' then N'更新佔成數不成功(於籃球)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบาสเก็ตบอล)'
							when 'J' then N'Error updating auto position taking (for Basketball)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (농구)'
							else N'Error updating auto position taking (for Basketball)'
						end
					,  @ErrCode=213
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov2positiontaking <> @old_isautov2positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Basketball)'
							when 'CS' then N'更新占成数不成功(于篮球)'
							when 'CT' then N'更新佔成數不成功(於籃球)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบาสเก็ตบอล)'
							when 'J' then N'Error updating auto position taking (for Basketball)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (농구)'
							else N'Error updating auto position taking (for Basketball)'
						end	
						,  @ErrCode=214
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_2 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_2 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_2 TO vnteam


 