CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_1]
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
	
	@maxpositiontaking_1 smallmoney,
	@maxpositiontaking_2 smallmoney,
	@maxpositiontaking_3 smallmoney,
	@maxpositiontaking_4 smallmoney,
	@maxpositiontaking_5 smallmoney,
	@maxpositiontaking_6 smallmoney,
	@maxpositiontaking_7 smallmoney,
	@maxpositiontaking_8 smallmoney,
	@maxpositiontaking_9 smallmoney,
	@maxpositiontaking_10 smallmoney,
	
	@maxlivepositiontaking_1 smallmoney,
	@maxlivepositiontaking_3 smallmoney,
	@maxlivepositiontaking_7 smallmoney,
	@maxlivepositiontaking_8 smallmoney,
	
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
DB: DB02.bodb02
Original: 

Revisions:

Param's Explanation:
• @ErrCode:
    = 0: check parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
declare @ErrAcc varchar(4000)
if @UpdateMaxPos = 1
BEGIN
	--check all (n2)<=l3
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username +', '
	from 
		customer as c with (NOLOCK) 
		inner join custoverride as aco with (NOLOCK) on c.custid = aco.custid
		inner join (
				          select 	1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
				union all select 	1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
				union all select 	1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
				union all select 	1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
				union all select 	1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
			) as b on aco.sporttype=b.sporttype and aco.bettype = b.bettype
	where c.mrecommend = @custid and c.roleid = 2 and (aco.minpositiontaking>b.maxpositiontaking or (b.bettype in (1,3,7,8) and aco.minlivepositiontaking>b.maxlivepositiontaking))
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 301
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Existing agents (minimum position taking) exceeded new maximum position taking ('+@ErrAcc+').'
							when 'CS' then N'现有代理(最低占成数)超出新的最高占成数设定 ('+@ErrAcc+').'
							when 'CT' then N'現有代理(最低佔成數)超出新的最高佔成數設定 ('+@ErrAcc+').'
							when 'TH' then N'จำนวนตัวแทนที่มี่อยู่ในขณะนี้  ( ขั้นต่ำที่กำหนดไว้ ) มีเกินกว่า จำนวนสูงสุดของบริษัทที่กำหนดใหม่ ('+@ErrAcc+').'
							when 'J' then N'Existing agents (minimum position taking) exceeded new maximum position taking ('+@ErrAcc+').'
							when 'KO' then N'현재 에이전트의 최소 거래조건이새로운 최대 거래조건을 초과 했습니다 ('+@ErrAcc+').'
							else N'Existing agents (minimum position taking) exceeded new maximum position taking ('+@ErrAcc+').'
					end
		return
	END	
END

if @UpdateMinPos = 1
BEGIN
	--check m3>=n3
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username + ', '
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
	where cs.custid = @custid and (cs.mpositiontaking<b.minpositiontaking or (b.bettype in (1,3,7,8) and	 cs.mlivepositiontaking<b.minlivepositiontaking))
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 304
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_1] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_1] TO vnteam
GO

 