ALTER PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_161
	@custid int,

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

	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Number game at member level
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
	@autov161positiontaking smallmoney,
	@isautov161positiontaking bit,
	@old_autov161positiontaking smallmoney,
	@old_isautov161positiontaking bit,
	
	@autov161livepositiontaking smallmoney,
	@isautov161livepositiontaking bit,	
	@old_autov161livepositiontaking smallmoney,
	@old_isautov161livepositiontaking bit,
	
	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
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
	@old_isauto_v161slivepositiontaking_90 bit,
	
	@master_auto_v161spositiontaking_81 smallmoney,
	@master_auto_v161spositiontaking_83 smallmoney,
	@master_auto_v161spositiontaking_86 smallmoney,
	@master_auto_v161spositiontaking_88 smallmoney,
	@master_auto_v161slivepositiontaking_85 smallmoney,
	@master_auto_v161slivepositiontaking_86 smallmoney,
	@master_auto_v161slivepositiontaking_87 smallmoney,
	@master_auto_v161slivepositiontaking_89 smallmoney,
	@master_auto_v161slivepositiontaking_90 smallmoney,

	@master_isauto_v161spositiontaking_81 bit,
	@master_isauto_v161spositiontaking_83 bit,
	@master_isauto_v161spositiontaking_86 bit,
	@master_isauto_v161spositiontaking_88 bit,
	@master_isauto_v161slivepositiontaking_85 bit,
	@master_isauto_v161slivepositiontaking_86 bit,
	@master_isauto_v161slivepositiontaking_87 bit,
	@master_isauto_v161slivepositiontaking_89 bit,
	@master_isauto_v161slivepositiontaking_90 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_v161spositiontaking_81	=	autopositiontaking		,	@old_isauto_v161spositiontaking_81	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=81
select 	@old_auto_v161spositiontaking_83	=	autopositiontaking		,	@old_isauto_v161spositiontaking_83	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=83
select 	@old_auto_v161spositiontaking_86	=	autopositiontaking		,	@old_isauto_v161spositiontaking_86	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
select 	@old_auto_v161spositiontaking_88	=	autopositiontaking		,	@old_isauto_v161spositiontaking_88	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=88
select 	@old_auto_v161slivepositiontaking_85	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_85	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=85
select 	@old_auto_v161slivepositiontaking_86	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_86	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
select 	@old_auto_v161slivepositiontaking_87	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_87	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=87
select 	@old_auto_v161slivepositiontaking_89	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_89	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=89
select 	@old_auto_v161slivepositiontaking_90	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_90	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=90

--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_v161spositiontaking_81 = autopositiontaking, @master_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
select @master_auto_v161spositiontaking_83 = autopositiontaking, @master_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
select @master_auto_v161spositiontaking_88 = autopositiontaking, @master_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161
select															 @master_auto_v161slivepositiontaking_85 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
select @master_auto_v161spositiontaking_86 = autopositiontaking, @master_auto_v161slivepositiontaking_86 = autolivepositiontaking, @master_isauto_v161spositiontaking_86 = isautopositiontaking, @master_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select															 @master_auto_v161slivepositiontaking_87 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
select															 @master_auto_v161slivepositiontaking_89 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
select															 @master_auto_v161slivepositiontaking_90 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161

--------------------------------------------------------
--Update Member account (autopositiontaking field)
update cs3 with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
	from custsetting3rd cs3 inner join 
			(
							select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking,									0	as isautolivepositiontaking
				union all 	select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking,									0	as isautolivepositiontaking
				union all 	select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking,									0	as isautolivepositiontaking
				union all 	select 85 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_85	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_85	as isautolivepositiontaking
				union all 	select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86	as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86	as isautolivepositiontaking
				union all 	select 87 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_87	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_87	as isautolivepositiontaking
				union all 	select 89 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_89	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_89	as isautolivepositiontaking
				union all 	select 90 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_90	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_90	as isautolivepositiontaking					
			) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
	where cs3.custid = @custid
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
	@auto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @auto_v161spositiontaking_81 else @master_auto_v161spositiontaking_81 end,			
	@auto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @auto_v161spositiontaking_83 else @master_auto_v161spositiontaking_83 end,			
	@auto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @auto_v161spositiontaking_86 else @master_auto_v161spositiontaking_86 end,			
	@auto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @auto_v161spositiontaking_88 else @master_auto_v161spositiontaking_88 end,			

	@auto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @auto_v161slivepositiontaking_85 else @master_auto_v161slivepositiontaking_85 end,			
	@auto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @auto_v161slivepositiontaking_86 else @master_auto_v161slivepositiontaking_86 end,			
	@auto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @auto_v161slivepositiontaking_87 else @master_auto_v161slivepositiontaking_87 end,
	@auto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @auto_v161slivepositiontaking_89 else @master_auto_v161slivepositiontaking_89 end,
	@auto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @auto_v161slivepositiontaking_90 else @master_auto_v161slivepositiontaking_90 end,

	@isauto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @isauto_v161spositiontaking_81 else @master_isauto_v161spositiontaking_81 end,
	@isauto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @isauto_v161spositiontaking_83 else @master_isauto_v161spositiontaking_83 end,
	@isauto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @isauto_v161spositiontaking_86 else @master_isauto_v161spositiontaking_86 end,
	@isauto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @isauto_v161spositiontaking_88 else @master_isauto_v161spositiontaking_88 end,

	@isauto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @isauto_v161slivepositiontaking_85 else @master_isauto_v161slivepositiontaking_85 end,
	@isauto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @isauto_v161slivepositiontaking_86 else @master_isauto_v161slivepositiontaking_86 end,
	@isauto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @isauto_v161slivepositiontaking_87 else @master_isauto_v161slivepositiontaking_87 end,
	@isauto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @isauto_v161slivepositiontaking_89 else @master_isauto_v161slivepositiontaking_89 end,
	@isauto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @isauto_v161slivepositiontaking_90 else @master_isauto_v161slivepositiontaking_90 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 81 as bettype,	   @isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
union all  	select 83 as bettype,	   @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
union all  	select 88 as bettype,	   @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking

union all  	select 85 as bettype,	   0							  as isautov161positiontaking	, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking,							  @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
union all  	select 86 as bettype,	   @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
union all  	select 87 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
union all  	select 89 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
union all  	select 90 as bettype,	   0 as isautov161positiontaking								, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking
	
------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Update number game (non-live)
		if @bettype in (81,83,86,88) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if @isautov161positiontaking > 0
			BEGIN
				select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
				update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
				from custsetting3rd cs3
				where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Number Game)'
							when 'CS' then N'更新占成数不成功(供数字游戏)'
							when 'CT' then N'更新佔成數不成功(供數字游戲)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข)'
							when 'J' then N'Error updating auto position taking (for Number Game)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number Game)'
							else N'Error updating auto position taking (for Number Game)'
						end	
					RaisError (@ErrMsg, 16, 1)
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
		END

		---------------------------------
		-- Update number game (live)
		if @bettype in (85,86,87,89,90) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if @isautov161livepositiontaking > 0
			BEGIN
				select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
				update cs3 with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
				from custsetting3rd cs3
				where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Number Game - Live)'
							when 'CS' then N'更新占成数不成功(供数字游戏-现场)'
							when 'CT' then N'更新佔成數不成功(供數字游戲-現場)'
							when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับเกมหมายเลข -สด)'
							when 'J' then N'Error updating auto position taking (for Number Game - Live)'
							when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (for Number Game - Live)'
							else N'Error updating auto position taking (for Number Game - Live)'
						end	
					RaisError (@ErrMsg, 16, 1)
					DEALLOCATE CUR
					CLOSE CUR
					return
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
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_161 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_161 TO [bodbAdminNet]
 
  