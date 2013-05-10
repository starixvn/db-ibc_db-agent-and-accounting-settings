ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_99
	@mrecommend int,
	@srecommend int,

	@auto_v99spositiontaking_1 smallmoney = 0,
	@auto_v99spositiontaking_2 smallmoney = 0,
	@auto_v99spositiontaking_3 smallmoney = 0,
	@auto_v99spositiontaking_20 smallmoney = 0,
	--- mixed sports
	@auto_v99spositiontaking_9 smallmoney = 0,

	@isauto_v99spositiontaking_1 bit = 0,
	@isauto_v99spositiontaking_2 bit = 0,
	@isauto_v99spositiontaking_3 bit = 0,
	@isauto_v99spositiontaking_20 bit = 0,
	-- mixed sports
	@isauto_v99spositiontaking_9 bit = 0,
	
	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Other Sports at master level
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

	@autov99positiontaking smallmoney,
	@autov99mppositiontaking smallmoney,
	@old_autov99positiontaking smallmoney,
	@old_autov99mppositiontaking smallmoney,
	
	@isautov99positiontaking bit,
	@isautov99mppositiontaking bit,
	@old_isautov99positiontaking smallmoney,
	@old_isautov99mppositiontaking smallmoney

Declare 
	@old_auto_v99spositiontaking_1 smallmoney,
	@old_auto_v99spositiontaking_2 smallmoney,
	@old_auto_v99spositiontaking_3 smallmoney,
	@old_auto_v99spositiontaking_20 smallmoney,
	-- mixed sports
	@old_auto_v99spositiontaking_9 smallmoney,
	
	@old_isauto_v99spositiontaking_1 bit,
	@old_isauto_v99spositiontaking_2 bit,
	@old_isauto_v99spositiontaking_3 bit,
	@old_isauto_v99spositiontaking_20 bit,
	-- mixed sports
	@old_isauto_v99spositiontaking_9 bit
	
--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v99spositiontaking_1	=	autopositiontaking		,	@old_isauto_v99spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=99	and bettype=	1
select 	@old_auto_v99spositiontaking_2	=	autopositiontaking		,	@old_isauto_v99spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=99	and bettype=	2
select 	@old_auto_v99spositiontaking_3	=	autopositiontaking		,	@old_isauto_v99spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=99	and bettype=	3
select 	@old_auto_v99spositiontaking_20	=	autopositiontaking		,	@old_isauto_v99spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=99	and bettype=	20
--mixed sports
select 	@old_auto_v99spositiontaking_9	=	autopositiontaking		,	@old_isauto_v99spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=99	and bettype=	9

--Update Master Agent account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
(
				select 1 as bettype, @auto_v99spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 2 as bettype, @auto_v99spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 3 as bettype, @auto_v99spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, @auto_v99spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=99
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (for Other sports)'
			when 'CS' then N'更新占成数不成功(于其他)'
			when 'CT' then N'更新佔成數不成功(於其他)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอื่นๆ)'
			when 'J' then N'Error updating auto position taking (for Other sports)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (기타 스포츠)'
			else N'Error updating auto position taking (for Other sports)'
		end	
		,  @ErrCode=208
	return
END

update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
(
	select 9 as bettype, @auto_v99spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking				
) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=99
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
			when 'CS' then N'更新占成数不成功(供混合体育过关)'
			when 'CT' then N'更新佔成數不成功(供混合體育過關)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบอลชุด)'
			when 'J' then N'Error updating auto position taking (for Mix Sports Parlay)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Mix Sports Parlay)'
			else N'Error updating auto position taking (for Mix Sports Parlay)'
		end	
		,  @ErrCode=301
	return
END

Declare CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v99spositiontaking_1 as isautov99positiontaking	,		@auto_v99spositiontaking_1 as autov99positiontaking	,	   @old_auto_v99spositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all  	select 2 as bettype	,	   @isauto_v99spositiontaking_2 as isautov99positiontaking	,		@auto_v99spositiontaking_2 as autov99positiontaking	,	   @old_auto_v99spositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all 	select 3 as bettype	,	   @isauto_v99spositiontaking_3 as isautov99positiontaking	,		@auto_v99spositiontaking_3 as autov99positiontaking	,	   @old_auto_v99spositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all  	select 9 as bettype	,	   0 as isautov99positiontaking								,		0 as autov99positiontaking							,		0 as old_autov99positiontaking								,	   0 as old_isautov99positiontaking									, @isauto_v99spositiontaking_9 as isautov99mppositiontaking	, @auto_v99spositiontaking_9 as autov99mppositiontaking	, @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking	, @old_auto_v99spositiontaking_9 as old_autov99mppositiontaking	
union all 	select 20 as bettype,	   @isauto_v99spositiontaking_20 as isautov99positiontaking	,		@auto_v99spositiontaking_20 as autov99positiontaking,	   @old_auto_v99spositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
	@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,20) and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
	BEGIN
		if @isautov99positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Other sports)'
							when 'CS' then N'更新占成数不成功(于其他)'
							when 'CT' then N'更新佔成數不成功(於其他)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอื่นๆ)'
							when 'J' then N'Error updating auto position taking (for Other sports)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (기타 스포츠)'
							else N'Error updating auto position taking (for Other sports)'
						end	
						,  @ErrCode=225
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov99positiontaking <> @old_isautov99positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Other sports)'
							when 'CS' then N'更新占成数不成功(于其他)'
							when 'CT' then N'更新佔成數不成功(於其他)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอื่นๆ)'
							when 'J' then N'Error updating auto position taking (for Other sports)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (기타 스포츠)'
							else N'Error updating auto position taking (for Other sports)'
						end	
						,  @ErrCode=226
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END			
	
	---------------------------------
	--Update Mixed sports
	if @bettype =9 and (@autov99mppositiontaking <> @old_autov99mppositiontaking or @isautov99mppositiontaking <> @old_isautov99mppositiontaking )
	BEGIN
		if @isautov99mppositiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
							when 'CS' then N'更新占成数不成功(供混合体育过关)'
							when 'CT' then N'更新佔成數不成功(供混合體育過關)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบอลชุด)'
							when 'J' then N'Error updating auto position taking (for Mix Sports Parlay)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Mix Sports Parlay)'
							else N'Error updating auto position taking (for Mix Sports Parlay)'
						end	
						,  @ErrCode=303
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov99mppositiontaking <> @old_isautov99mppositiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
							when 'CS' then N'更新占成数不成功(供混合体育过关)'
							when 'CT' then N'更新佔成數不成功(供混合體育過關)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาบอลชุด)'
							when 'J' then N'Error updating auto position taking (for Mix Sports Parlay)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Mix Sports Parlay)'
							else N'Error updating auto position taking (for Mix Sports Parlay)'
						end	
						,  @ErrCode=304
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking	,
	@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking

END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_99 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_99 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_99 TO vnteam


 