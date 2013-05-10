ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_3
	@mrecommend int,
	@srecommend int,

	@auto_v3spositiontaking_1 smallmoney = 0,
	@auto_v3spositiontaking_2 smallmoney = 0,
	@auto_v3spositiontaking_3 smallmoney = 0,
	@auto_v3spositiontaking_20 smallmoney = 0,

	@isauto_v3spositiontaking_1 bit = 0,
	@isauto_v3spositiontaking_2 bit = 0,
	@isauto_v3spositiontaking_3 bit = 0,
	@isauto_v3spositiontaking_20 bit = 0,

	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Football at master level
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

	@autov3positiontaking smallmoney,
	@old_autov3positiontaking smallmoney,
	@isautov3positiontaking bit,
	@old_isautov3positiontaking bit

Declare 
	@old_auto_v3spositiontaking_1 smallmoney,
	@old_auto_v3spositiontaking_2 smallmoney,
	@old_auto_v3spositiontaking_3 smallmoney,
	@old_auto_v3spositiontaking_20 smallmoney,

	@old_isauto_v3spositiontaking_1 bit,
	@old_isauto_v3spositiontaking_2 bit,
	@old_isauto_v3spositiontaking_3 bit,
	@old_isauto_v3spositiontaking_20 bit
	
--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v3spositiontaking_1	=	autopositiontaking		,	@old_isauto_v3spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=3	and bettype=	1
select 	@old_auto_v3spositiontaking_2	=	autopositiontaking		,	@old_isauto_v3spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=3	and bettype=	2
select 	@old_auto_v3spositiontaking_3	=	autopositiontaking		,	@old_isauto_v3spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=3	and bettype=	3
select 	@old_auto_v3spositiontaking_20	=	autopositiontaking		,	@old_isauto_v3spositiontaking_20=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=3	and bettype=	20

--Update Master Agent account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
(
				select 1 as bettype, @auto_v3spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 2 as bettype, @auto_v3spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 3 as bettype, @auto_v3spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, @auto_v3spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=3
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (for Football)'
			when 'CS' then N'更新占成数不成功(于美式足球)'
			when 'CT' then N'更新佔成數不成功(於美式足球)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอเมริกันฟุตบอล)'
			when 'J' then N'Error updating auto position taking (for Football)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (풋볼)'
			else N'Error updating auto position taking (for Football)'
		end	
		,  @ErrCode=203
	return
END

Declare CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v3spositiontaking_1 as isautov3positiontaking	,	   @auto_v3spositiontaking_1 as autov3positiontaking	,	   @old_auto_v3spositiontaking_1 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking
union all  	select 2 as bettype	,	   @isauto_v3spositiontaking_2 as isautov3positiontaking	,	   @auto_v3spositiontaking_2 as autov3positiontaking	,	   @old_auto_v3spositiontaking_2 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking
union all 	select 3 as bettype	,	   @isauto_v3spositiontaking_3 as isautov3positiontaking	,	   @auto_v3spositiontaking_3 as autov3positiontaking	,	   @old_auto_v3spositiontaking_3 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking
union all 	select 20 as bettype,	   @isauto_v3spositiontaking_20 as isautov3positiontaking	,	   @auto_v3spositiontaking_20 as autov3positiontaking	,	   @old_auto_v3spositiontaking_20 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking
	
WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,20) and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking )
	BEGIN
		if @isautov3positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=3 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Football)'
							when 'CS' then N'更新占成数不成功(于美式足球)'
							when 'CT' then N'更新佔成數不成功(於美式足球)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอเมริกันฟุตบอล)'
							when 'J' then N'Error updating auto position taking (for Football)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (풋볼)'
							else N'Error updating auto position taking (for Football)'
						end	
						,  @ErrCode=215
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov3positiontaking <> @old_isautov3positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Football)'
							when 'CS' then N'更新占成数不成功(于美式足球)'
							when 'CT' then N'更新佔成數不成功(於美式足球)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอเมริกันฟุตบอล)'
							when 'J' then N'Error updating auto position taking (for Football)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (풋볼)'
							else N'Error updating auto position taking (for Football)'
						end	
						,  @ErrCode=216
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END	
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_3 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_3 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_3 TO vnteam


 