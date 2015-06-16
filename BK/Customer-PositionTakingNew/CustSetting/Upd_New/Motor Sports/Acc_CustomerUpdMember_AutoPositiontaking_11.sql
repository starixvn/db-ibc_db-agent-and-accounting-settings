CREATE PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_11
	@custid int,

	@auto_v11spositiontaking_1 smallmoney = 0,
	@auto_v11spositiontaking_20 smallmoney = 0,

	@isauto_v11spositiontaking_1 bit = 0,
	@isauto_v11spositiontaking_20 bit = 0,

	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Motor Sports at member level
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
	@autov11positiontaking smallmoney,
	@isautov11positiontaking bit, 
	@old_autov11positiontaking smallmoney,
	@old_isautov11positiontaking bit,
	
	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
	@old_auto_v11spositiontaking_1 smallmoney,
	@old_auto_v11spositiontaking_20 smallmoney,

	@old_isauto_v11spositiontaking_1 bit,
	@old_isauto_v11spositiontaking_20 bit,

	@master_auto_v11spositiontaking_1 smallmoney,
	@master_auto_v11spositiontaking_20 smallmoney,
	
	@master_isauto_v11spositiontaking_1 bit,
	@master_isauto_v11spositiontaking_20 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_v11spositiontaking_1	=	autopositiontaking		,	@old_isauto_v11spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=1
select 	@old_auto_v11spositiontaking_20	=	autopositiontaking		,	@old_isauto_v11spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=20
		
--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_v11spositiontaking_1 = autopositiontaking, @master_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
select @master_auto_v11spositiontaking_20 = autopositiontaking, @master_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11
		
--------------------------------------------------------
--Update Member account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
	(
				select 1 as bettype, 11 as sporttype, @auto_v11spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, 11 as sporttype, @auto_v11spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
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
	@auto_v11spositiontaking_1 = case when @isauto_v11spositiontaking_1>0 then @auto_v11spositiontaking_1 else @master_auto_v11spositiontaking_1 end,
	@auto_v11spositiontaking_20 = case when @isauto_v11spositiontaking_20>0 then @auto_v11spositiontaking_20 else @master_auto_v11spositiontaking_20 end,

	@isauto_v11spositiontaking_1 = case when @isauto_v11spositiontaking_1>0 then @isauto_v11spositiontaking_1 else @master_isauto_v11spositiontaking_1 end,
	@isauto_v11spositiontaking_20 = case when @isauto_v11spositiontaking_20>0 then @isauto_v11spositiontaking_20 else @master_isauto_v11spositiontaking_20 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v11spositiontaking_1 as isautov11positiontaking	,	   @auto_v11spositiontaking_1 as autov11positiontaking	,	   @old_auto_v11spositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking	
union all 	select 20 as bettype,	   @isauto_v11spositiontaking_20 as isautov11positiontaking,	   @auto_v11spositiontaking_20 as autov11positiontaking	,	   @old_auto_v11spositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking	
------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,20) --and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking )
	BEGIN
		if @isautov11positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=11
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
				RaisError (@ErrMsg, 16, 1)
				DEALLOCATE CUR
				CLOSE CUR
				return
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
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_11 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_11 TO [bodbAdminNet]
 
  