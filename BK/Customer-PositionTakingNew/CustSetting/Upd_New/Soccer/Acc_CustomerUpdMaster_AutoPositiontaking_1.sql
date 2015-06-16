 ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_AutoPositiontaking_1]
	@mrecommend int,
	@srecommend int,

	@auto_spositiontaking_1 smallmoney = 0, 
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney = 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,

	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,
	
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
	
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Soccer at master level
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
	@autopositiontaking smallmoney,
	@autolivepositiontaking smallmoney,
	@old_autopositiontaking smallmoney,
	@old_autolivepositiontaking smallmoney,
	
	@maxpos smallmoney,
	@isautopositiontaking bit, 
	@isautolivepositiontaking bit, 
	
	@old_isautopositiontaking bit, 
	@old_isautolivepositiontaking bit

Declare 
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
	@old_isauto_slivepositiontaking_8 bit
	
--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_spositiontaking_1	=	autopositiontaking		,	@old_isauto_spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	1
select 	@old_auto_spositiontaking_2	=	autopositiontaking		,	@old_isauto_spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	2
select 	@old_auto_spositiontaking_3	=	autopositiontaking		,	@old_isauto_spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	3
select 	@old_auto_spositiontaking_4	=	autopositiontaking		,	@old_isauto_spositiontaking_4	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	4
select 	@old_auto_spositiontaking_5	=	autopositiontaking		,	@old_isauto_spositiontaking_5	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	5
select 	@old_auto_spositiontaking_6	=	autopositiontaking		,	@old_isauto_spositiontaking_6	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	6
select 	@old_auto_spositiontaking_7	=	autopositiontaking		,	@old_isauto_spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	7
select 	@old_auto_spositiontaking_8	=	autopositiontaking		,	@old_isauto_spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	8
select 	@old_auto_spositiontaking_9	=	autopositiontaking		,	@old_isauto_spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	9
select 	@old_auto_spositiontaking_10	=	autopositiontaking		,	@old_isauto_spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	10
select 	@old_auto_slivepositiontaking_1	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_1	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	1
select 	@old_auto_slivepositiontaking_3	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_3	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	3
select 	@old_auto_slivepositiontaking_7	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_7	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	7
select 	@old_auto_slivepositiontaking_8	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_8	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype =	1	and bettype=	8

--Update Master Agent account (autopositiontaking field) for Soccer
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
		(
						select 1 as bettype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1	as autolivepositiontaking, @isauto_spositiontaking_1 as isautopositiontaking, @isauto_slivepositiontaking_1	as isautolivepositiontaking
			union all 	select 2 as bettype, @auto_spositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking
			union all 	select 3 as bettype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 	as autolivepositiontaking, @isauto_spositiontaking_3 as isautopositiontaking, @isauto_slivepositiontaking_3	as isautolivepositiontaking
			union all 	select 4 as bettype, @auto_spositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking
			union all 	select 5 as bettype, @auto_spositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking
			union all 	select 6 as bettype, @auto_spositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking
			union all 	select 7 as bettype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 	as autolivepositiontaking, @isauto_spositiontaking_7 as isautopositiontaking, @isauto_slivepositiontaking_7	as isautolivepositiontaking
			union all 	select 8 as bettype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 	as autolivepositiontaking, @isauto_spositiontaking_8 as isautopositiontaking, @isauto_slivepositiontaking_8	as isautolivepositiontaking			
			union all 	select 9 as bettype, @auto_spositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking
			union all 	select 10 as bettype, @auto_spositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking
		) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=1
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
		,  @ErrCode=201
	return
END

Declare CUR CURSOR FOR 
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

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking
WHILE @@FETCH_STATUS = 0
BEGIN
	if @autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking
	BEGIN
		if @isautopositiontaking >0 --auto PT is used
		BEGIN
			--Update use Auto_SPT at master for all members only when:
				--(autoSPT at master changes AND isauto at master = 1
				--OR isauto at master changes from 0 to 1)
				--AND isauto at member = 0
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where
				c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1
				and custsetting.isautopositiontaking=0 -- only update members without AutoSPT at member
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
					,  @ErrCode=209
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
		BEGIN
			if @updateallmembers = 1 -- Update All Member option is used
			BEGIN
				--Update a specific SPT for all members only when:
					--@updateallmembers = 1
					--AND isauto at master = 0
					--AND isauto at master change from 1 to 0
					--AND isauto at member = 0
				
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautopositiontaking=0				
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
					,  @ErrCode=210
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END
	---------------------------------
	--Update LIVE
	if @bettype in (1,3,7,8) and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking )
	BEGIN
		if @isautolivepositiontaking >0
		BEGIN
			select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0
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
					,  @ErrCode=211
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautolivepositiontaking <> @old_isautolivepositiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0				
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
					,  @ErrCode=212
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END
	END
	
FETCH NEXT FROM CUR INTO
	@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_1 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_1 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_1 TO vnteam


