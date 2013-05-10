CREATE PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_11
	@mrecommend int,
	@srecommend int,

	@auto_v11spositiontaking_1 smallmoney = 0,
	@auto_v11spositiontaking_20 smallmoney = 0,

	@isauto_v11spositiontaking_1 bit = 0,
	@isauto_v11spositiontaking_20 bit = 0,

	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Motor Sports at master level
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

	@autov11positiontaking smallmoney,
	@old_autov11positiontaking smallmoney,
	@isautov11positiontaking bit,
	@old_isautov11positiontaking bit

Declare 
	@old_auto_v11spositiontaking_1 smallmoney,
	@old_auto_v11spositiontaking_20 smallmoney,
	
	@old_isauto_v11spositiontaking_1 bit,
	@old_isauto_v11spositiontaking_20 bit

--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v11spositiontaking_1	=	autopositiontaking		,	@old_isauto_v11spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=11	and bettype=	1
select 	@old_auto_v11spositiontaking_20	=	autopositiontaking		,	@old_isauto_v11spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=11	and bettype=	20

--Update Master Agent account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
(
				select 1 as bettype, @auto_v11spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, @auto_v11spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=11
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (for Motorsports)'
			when 'CS' then N'更新占成数不成功(于赛车)'
			when 'CT' then N'更新佔成數不成功(於賽車)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬารถแข่ง)'
			when 'J' then N'Error updating auto position taking (for Motorsports)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (모토스포츠)'
			else N'Error updating auto position taking (for Motorsports)'
		end	
		,  @ErrCode=207
	return
END

Declare CUR CURSOR FOR 
			select 1 as bettype	,	@isauto_v11spositiontaking_1 as isautov11positiontaking	,	   @auto_v11spositiontaking_1 as autov11positiontaking	,	   @old_auto_v11spositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking 
union all 	select 20 as bettype,	@isauto_v11spositiontaking_20 as isautov11positiontaking,	   @auto_v11spositiontaking_20 as autov11positiontaking	,	   @old_auto_v11spositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,20) and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking )
	BEGIN
		if @isautov11positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Motorsports)'
							when 'CS' then N'更新占成数不成功(于赛车)'
							when 'CT' then N'更新佔成數不成功(於賽車)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬารถแข่ง)'
							when 'J' then N'Error updating auto position taking (for Motorsports)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (모토스포츠)'
							else N'Error updating auto position taking (for Motorsports)'
						end	
						,  @ErrCode=223
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov11positiontaking <> @old_isautov11positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Motorsports)'
							when 'CS' then N'更新佔成數不成功(於賽車)'
							when 'CT' then N'更新佔成數不成功(於賽車)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬารถแข่ง)'
							when 'J' then N'Error updating auto position taking (for Motorsports)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (모토스포츠)'
							else N'Error updating auto position taking (for Motorsports)'
						end	
						,  @ErrCode=224
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END	
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking	
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_11 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_11 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_11 TO vnteam


 