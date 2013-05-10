ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_Ag_1]
	@custid int,

	@minpositiontaking_1 smallmoney,
	@minpositiontaking_2 smallmoney,
	@minpositiontaking_3 smallmoney,
	@minpositiontaking_4 smallmoney,
	@minpositiontaking_5 smallmoney,
	@minpositiontaking_6 smallmoney,
	@minpositiontaking_7 smallmoney,
	@minpositiontaking_8 smallmoney,
	@minpositiontaking_9 smallmoney,
	@minpositiontaking_10 smallmoney,
	
	@minlivepositiontaking_1 smallmoney,
	@minlivepositiontaking_3 smallmoney,
	@minlivepositiontaking_7 smallmoney,
	@minlivepositiontaking_8 smallmoney,
	
	@UpdateMinPos bit = 1,
	@UpdateMaxPos bit = 1,
	@roleid int, 
	@srecommend int, 
	@mrecommend int, 
	@recommend int,
	@isvalid bit OUTPUT,
	@errmsg nvarchar(4000) OUTPUT,
	@errcode int OUTPUT,
	@language varchar(2) = 'E'
AS
/*
Created: 20120509@Elodie
Task : Check parameters to update CustOverride for Soccer
DB: DBTRANS.bodb02
Original: Acc_CustOverrideUpd_CheckParam_Ag

Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: check parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
declare @ErrAcc varchar(4000)
if @UpdateMinPos = 1
BEGIN
	--check l3 >= n2
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username +', '
	from 
		customer as c with (NOLOCK) 
		inner join custoverride as mco with (NOLOCK) on c.custid = mco.custid
		inner join (
						  select 	1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
				union all select 	1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
				union all select 	1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
				union all select 	1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
				union all select 	1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
				) as b on mco.sporttype=b.sporttype and mco.bettype = b.bettype
	where
		c.custid = (select mrecommend from customer with (NOLOCK) where custid = @custid) and c.roleid=3
		and (mco.maxpositiontaking<b.minpositiontaking or (b.bettype in (1,3,7,8) and mco.maxlivepositiontaking<b.minlivepositiontaking))
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 201
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Master maximum position taking violates new minimum position taking setting ('+@ErrAcc+').'
							when 'CS' then N'总代理占成数设定不符合新的最低占成数设定 ('+@ErrAcc+').'
							when 'CT' then N'總代理佔成數設定不符合新的最低佔成數設定 ('+@ErrAcc+').'
							when 'TH' then N'จำนวนตัวแทนหลักที่กำหนดไว้ ไม่สอดคล้องกับจำนวนต่ำสุดที่กำหนดไว้จากบริษัท ('+@ErrAcc+').'
							when 'J' then N'Master maximum position taking violates new minimum position taking setting ('+@ErrAcc+').'
							when 'KO' then N'마스터의 최대 거래조건에 위반됩니다 새로운 최소 거래조건을 설정해 주시기 바랍니다 ('+@ErrAcc+').'
							else N'Master maximum position taking violates new minimum position taking setting ('+@ErrAcc+').'
					end
		return
	END
	
	--check a2 >= n2
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username +', '
	from 
		customer as c with (NOLOCK) 
		inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
		inner join (
				          select 	1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
				union all select 	1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
				union all select 	1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
				union all select 	1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
				union all select 	1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
				) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
	where cs.custid = @custid and (cs.apositiontaking<b.minpositiontaking or (b.bettype in (1,3,7,8) and cs.alivepositiontaking<b.minlivepositiontaking))
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 203
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Current account position taking violates new minimum position taking setting ('+@ErrAcc+').'
							when 'CS' then N'现有占成数设定不符合新的最低占成数设定 ('+@ErrAcc+').'
							when 'CT' then N'現有佔成數設定不符合新的最低佔成數設定 ('+@ErrAcc+').'
							when 'TH' then N'แบ่งสู้ปัจจุบัน ไม่สอดคล้องกับแบ่งสู้ขั้นต่ำที่ตั้งค่า ('+@ErrAcc+').'
							when 'J' then N'Current account position taking violates new minimum position taking setting ('+@ErrAcc+').'
							when 'KO' then N'현재 계정의 포지션조건이 잘못되었으므로 최소의 새로운 포지션조건을 설정해 주시기 바랍니다 ('+@ErrAcc+').'
							else N'Current account position taking violates new minimum position taking setting ('+@ErrAcc+').'
					end
		return
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_Ag_1] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_Ag_1] TO vnteam
GO

