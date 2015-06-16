ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_161
	@mrecommend int,
	@srecommend int,

	@auto_v161spositiontaking_81 smallmoney = 0,
	@auto_v161spositiontaking_83 smallmoney = 0,	
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,

	@isauto_v161spositiontaking_81 bit = 0,
	@isauto_v161spositiontaking_83 bit = 0,	
	@isauto_v161spositiontaking_86 bit = 0,
	@isauto_v161spositiontaking_88 bit = 0,

	@isauto_v161slivepositiontaking_85 bit = 0,
	@isauto_v161slivepositiontaking_86 bit = 0,
	@isauto_v161slivepositiontaking_87 bit = 0,
	@isauto_v161slivepositiontaking_89 bit = 0,
	@isauto_v161slivepositiontaking_90 bit = 0,

	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Number Game at master level
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

	@autov161positiontaking smallmoney,
	@autov161livepositiontaking smallmoney,
	@old_autov161positiontaking smallmoney,
	@old_autov161livepositiontaking smallmoney,
	
	@isautov161positiontaking bit,
	@isautov161livepositiontaking bit,
	@old_isautov161positiontaking bit,
	@old_isautov161livepositiontaking bit	

Declare 
	@old_auto_v161spositiontaking_81 smallmoney,
	@old_auto_v161spositiontaking_83 smallmoney,	
	@old_auto_v161spositiontaking_86 smallmoney,
	@old_auto_v161spositiontaking_88 smallmoney,
	@old_auto_v161slivepositiontaking_85 smallmoney,
	@old_auto_v161slivepositiontaking_86 smallmoney,
	@old_auto_v161slivepositiontaking_87 smallmoney,
	@old_auto_v161slivepositiontaking_89 smallmoney,
	@old_auto_v161slivepositiontaking_90 smallmoney,

	@old_isauto_v161spositiontaking_81 bit,
	@old_isauto_v161spositiontaking_83 bit,	
	@old_isauto_v161spositiontaking_86 bit,
	@old_isauto_v161spositiontaking_88 bit,
	@old_isauto_v161slivepositiontaking_85 bit,
	@old_isauto_v161slivepositiontaking_86 bit,
	@old_isauto_v161slivepositiontaking_87 bit,
	@old_isauto_v161slivepositiontaking_89 bit,
	@old_isauto_v161slivepositiontaking_90 bit	

--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v161spositiontaking_81	=	autopositiontaking		,	@old_isauto_v161spositiontaking_81	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161	and bettype=	81
select 	@old_auto_v161spositiontaking_83	=	autopositiontaking		,	@old_isauto_v161spositiontaking_83	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161	and bettype=	83
select 	@old_auto_v161spositiontaking_86	=	autopositiontaking		,	@old_isauto_v161spositiontaking_86	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161	and bettype=	86
select 	@old_auto_v161spositiontaking_88	=	autopositiontaking		,	@old_isauto_v161spositiontaking_88	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype=161	and bettype=	88
select 	@old_auto_v161slivepositiontaking_85	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_85	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =	161	and bettype=	85
select 	@old_auto_v161slivepositiontaking_86	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_86	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =	161	and bettype=	86
select 	@old_auto_v161slivepositiontaking_87	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_87	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =	161	and bettype=	87
select 	@old_auto_v161slivepositiontaking_89	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_89	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =	161	and bettype=	89
select 	@old_auto_v161slivepositiontaking_90	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_90	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @mrecommend and sporttype =	161	and bettype=	90

--Update Master Agent account (autopositiontaking field)
update cs with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting3rd cs inner join 
(
				select 81 as bettype, @auto_v161spositiontaking_81 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 83 as bettype, @auto_v161spositiontaking_83 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 88 as bettype, @auto_v161spositiontaking_88 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 85 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_85 	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_85	as isautolivepositiontaking
	union all 	select 86 as bettype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86 	as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86	as isautolivepositiontaking
	union all 	select 87 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_87 	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_87	as isautolivepositiontaking
	union all 	select 89 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_89 	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_89	as isautolivepositiontaking
	union all 	select 90 as bettype, 0 as autopositiontaking, @auto_v161slivepositiontaking_90 	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161slivepositiontaking_90	as isautolivepositiontaking

) as b on b.bettype = cs.bettype
where cs.custid = @mrecommend and cs.sporttype=161
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking (For Number game)'
			when 'CS' then N'更新占成数不成功(供数字游戏)'
			when 'CT' then N'更新佔成數不成功(供數字游戲)'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข)'
			when 'J' then N'Error updating auto position taking (For Number game)'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (For Number game)'
			else N'Error updating auto position taking (For Number game)'
		end	
		,  @ErrCode=302
	return
END

Declare CUR CURSOR FOR 
			select 81 as bettype,	   @isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking										, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
union all  	select 83 as bettype,	   @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking										, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
union all  	select 88 as bettype,	   @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking										, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
union all  	select 85 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
union all  	select 86 as bettype,	   @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking	, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
union all  	select 87 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
union all  	select 89 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
union all  	select 90 as bettype,	   0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (81,83,86,88) and (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking )
	BEGIN
		if @isautov161positiontaking > 0
		BEGIN
			select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
			update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
			if @@Error <> 0
			BEGIN
				SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Number game)'
							when 'CS' then N'更新占成数不成功(供数字游戏)'
							when 'CT' then N'更新佔成數不成功(供數字游戲)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข)'
							when 'J' then N'Error updating auto position taking (for Number game)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number game)'
							else N'Error updating auto position taking (for Number game)'
						end	
						,  @ErrCode=305
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov161positiontaking <> @old_isautov161positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs3.spositiontaking<@newspositiontaking then mcs3.spositiontaking else @newspositiontaking end
				from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
				inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = @mrecommend and cs3.sporttype=mcs3.sporttype and cs3.bettype=mcs3.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
				if @@Error <> 0
				BEGIN
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Number game)'
							when 'CS' then N'更新占成数不成功(供数字游戏)'
							when 'CT' then N'更新佔成數不成功(供數字游戲)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข)'
							when 'J' then N'Error updating auto position taking (for Number game)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number game)'
							else N'Error updating auto position taking (for Number game)'
						end	
						,  @ErrCode=306
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END					
	END
	--- number game live        
	if @bettype in (85,86,87,89,90) and (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking )
	BEGIN
		if @isautov161livepositiontaking > 0
		BEGIN
			select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
			update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
			from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking (for Number Game - LIVE)'
						when 'CS' then N'更新占成数不成功(供数字游戏-现场)'
						when 'CT' then N'更新佔成數不成功(供數字游戲-現場)'
						when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข -สด)'
						when 'J' then N'Error updating auto position taking (for Number Game - LIVE)'
						when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number Game - LIVE)'
						else N'Error updating auto position taking (for Number Game - LIVE)'
					end	
					,  @ErrCode=307
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov161livepositiontaking <> @old_isautov161livepositiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
				from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting3rd.sporttype=mcs.sporttype and custsetting3rd.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0				
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking (for Number Game - LIVE)'
						when 'CS' then N'更新占成数不成功(供数字游戏-现场)'
						when 'CT' then N'更新佔成數不成功(供數字游戲-現場)'
						when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข -สด)'
						when 'J' then N'Error updating auto position taking (for Number Game - LIVE)'
						when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number Game - LIVE)'
						else N'Error updating auto position taking (for Number Game - LIVE)'
					end	
					,  @ErrCode=308
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END 
	END	
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking

END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_161 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_161 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_161 TO vnteam


 