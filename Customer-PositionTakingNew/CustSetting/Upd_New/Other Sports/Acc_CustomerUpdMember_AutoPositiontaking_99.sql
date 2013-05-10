ALTER PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_99
	@custid int,

	@auto_v99spositiontaking_1 smallmoney = 0,
	@auto_v99spositiontaking_2 smallmoney = 0,
	@auto_v99spositiontaking_3 smallmoney = 0,
	@auto_v99spositiontaking_20 smallmoney = 0,
	
	-- mixed sports
	@auto_v99spositiontaking_9 smallmoney = 0,

	@isauto_v99spositiontaking_1 bit = 0,
	@isauto_v99spositiontaking_2 bit = 0,
	@isauto_v99spositiontaking_3 bit = 0,
	@isauto_v99spositiontaking_20 bit = 0,
	
	-- mixed sports
	@isauto_v99spositiontaking_9 bit = 0,

	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Other Sports at member level
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
	@autov99positiontaking smallmoney,
	@isautov99positiontaking bit, 
	@old_autov99positiontaking smallmoney,
	@old_isautov99positiontaking bit,

	-- mixed sports
	@autov99mppositiontaking smallmoney,
	@isautov99mppositiontaking bit,
	@old_autov99mppositiontaking smallmoney,
	@old_isautov99mppositiontaking bit,

	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
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
	@old_isauto_v99spositiontaking_9 bit,

	@master_auto_v99spositiontaking_1 smallmoney,
	@master_auto_v99spositiontaking_2 smallmoney,
	@master_auto_v99spositiontaking_3 smallmoney,
	@master_auto_v99spositiontaking_20 smallmoney,

	-- mixed sports
	@master_auto_v99spositiontaking_9 smallmoney,

	@master_isauto_v99spositiontaking_1 bit,
	@master_isauto_v99spositiontaking_2 bit,
	@master_isauto_v99spositiontaking_3 bit,
	@master_isauto_v99spositiontaking_20 bit,

	-- mixed sports
	@master_isauto_v99spositiontaking_9 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_v99spositiontaking_1	=	autopositiontaking		,	@old_isauto_v99spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=1
select 	@old_auto_v99spositiontaking_2	=	autopositiontaking		,	@old_isauto_v99spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=2
select 	@old_auto_v99spositiontaking_3	=	autopositiontaking		,	@old_isauto_v99spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=3
select 	@old_auto_v99spositiontaking_20	=	autopositiontaking		,	@old_isauto_v99spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=20
-- mixed 
select 	@old_auto_v99spositiontaking_9	=	autopositiontaking		,	@old_isauto_v99spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=9
	
--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_v99spositiontaking_1 = autopositiontaking, @master_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
select @master_auto_v99spositiontaking_2 = autopositiontaking, @master_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
select @master_auto_v99spositiontaking_3 = autopositiontaking, @master_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
select @master_auto_v99spositiontaking_20 = autopositiontaking, @master_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99

--------------------------------------------------------
--Update Member account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
	(
				select 1 as bettype, 99 as sporttype, @auto_v99spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 2 as bettype, 99 as sporttype, @auto_v99spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 3 as bettype, 99 as sporttype, @auto_v99spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, 99 as sporttype, @auto_v99spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking

	-- mixed sports
	union all 	select 9 as bettype, 99 as sporttype, @auto_v99spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking 
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
	@auto_v99spositiontaking_1 = case when @isauto_v99spositiontaking_1>0 then @auto_v99spositiontaking_1 else @master_auto_v99spositiontaking_1 end,
	@auto_v99spositiontaking_2 = case when @isauto_v99spositiontaking_2>0 then @auto_v99spositiontaking_2 else @master_auto_v99spositiontaking_2 end,
	@auto_v99spositiontaking_3 = case when @isauto_v99spositiontaking_3>0 then @auto_v99spositiontaking_3 else @master_auto_v99spositiontaking_3 end,
	@auto_v99spositiontaking_20 = case when @isauto_v99spositiontaking_20>0 then @auto_v99spositiontaking_20 else @master_auto_v99spositiontaking_20 end,

	-- mixed sports
	@auto_v99spositiontaking_9 = case when @isauto_v99spositiontaking_9>0 then @auto_v99spositiontaking_9 else @master_auto_v99spositiontaking_9 end,

	@isauto_v99spositiontaking_1 = case when @isauto_v99spositiontaking_1>0 then @isauto_v99spositiontaking_1 else @master_isauto_v99spositiontaking_1 end,
	@isauto_v99spositiontaking_2 = case when @isauto_v99spositiontaking_2>0 then @isauto_v99spositiontaking_2 else @master_isauto_v99spositiontaking_2 end,
	@isauto_v99spositiontaking_3 = case when @isauto_v99spositiontaking_3>0 then @isauto_v99spositiontaking_3 else @master_isauto_v99spositiontaking_3 end,
	@isauto_v99spositiontaking_20 = case when @isauto_v99spositiontaking_20>0 then @isauto_v99spositiontaking_20 else @master_isauto_v99spositiontaking_20 end,

	-- mixed sports
	@isauto_v99spositiontaking_9 = case when @isauto_v99spositiontaking_9>0 then @isauto_v99spositiontaking_9 else @master_isauto_v99spositiontaking_9 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v99spositiontaking_1 as isautov99positiontaking	,		@auto_v99spositiontaking_1 as autov99positiontaking	,	   @old_auto_v99spositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all  	select 2 as bettype	,	   @isauto_v99spositiontaking_2 as isautov99positiontaking	,		@auto_v99spositiontaking_2 as autov99positiontaking	,	   @old_auto_v99spositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all 	select 3 as bettype	,	   @isauto_v99spositiontaking_3 as isautov99positiontaking	,		@auto_v99spositiontaking_3 as autov99positiontaking	,	   @old_auto_v99spositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking
union all  	select 9 as bettype	,	   0 as isautov99positiontaking								,		0 as autov99positiontaking							,	   0 as old_autov99positiontaking								,	   0 as old_isautov99positiontaking									, @isauto_v99spositiontaking_9 as isautov99mppositiontaking	, @auto_v99spositiontaking_9 as autov99mppositiontaking	, @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking	, @old_auto_v99spositiontaking_9 as old_autov99mppositiontaking
union all 	select 20 as bettype,	   @isauto_v99spositiontaking_20 as isautov99positiontaking ,		@auto_v99spositiontaking_20 as autov99positiontaking,	   @old_auto_v99spositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking	

------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
	@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking
WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,20)
	BEGIN
		if @isautov99positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
			if @@Error <> 0
			BEGIN
				SELECT @ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking (for Other sports)'
						when 'CS' then N'更新占成数不成功(于其他)'
						when 'CT' then N'更新佔成數不成功(於其他'
						when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬาอื่นๆ)'
						when 'J' then N'Error updating auto position taking (for Other sports)'
						when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (기타 스포츠)'
						else N'Error updating auto position taking (for Other sports)'
					end	
				RaisError (@ErrMsg, 16, 1)
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	-- Update mixed sports
	if @bettype = 9 --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
	BEGIN
		if @isautov99mppositiontaking > 0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
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
				RaisError (@ErrMsg, 16, 1)
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
FETCH NEXT FROM CUR INTO			
	@bettype,
	@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
	@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking
END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_99 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_99 TO [bodbAdminNet]
 
  