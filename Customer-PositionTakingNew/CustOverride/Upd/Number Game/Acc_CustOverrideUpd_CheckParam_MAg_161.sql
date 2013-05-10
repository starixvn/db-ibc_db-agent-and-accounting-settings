CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_161]
	@custid int,
	
	@minv161positiontaking_81 smallmoney,
	@minv161positiontaking_83 smallmoney,
	@minv161positiontaking_86 smallmoney,
	@minv161positiontaking_88 smallmoney,
	@minv161livepositiontaking_85 smallmoney,
	@minv161livepositiontaking_86 smallmoney,
	@minv161livepositiontaking_87 smallmoney,
	@minv161livepositiontaking_89 smallmoney,
	@minv161livepositiontaking_90 smallmoney,

	@maxv161positiontaking_81 smallmoney,
	@maxv161positiontaking_83 smallmoney,
	@maxv161positiontaking_86 smallmoney,
	@maxv161positiontaking_88 smallmoney,
	@maxv161livepositiontaking_85 smallmoney,
	@maxv161livepositiontaking_86 smallmoney,
	@maxv161livepositiontaking_87 smallmoney,
	@maxv161livepositiontaking_89 smallmoney,
	@maxv161livepositiontaking_90 smallmoney,

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
Task : Check parameters to update CustOverride for Number Game
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
		inner join custoverride3rd as aco with (NOLOCK) on c.custid = aco.custid
		inner join (
						  select 	161 as sporttype, 81 as bettype, @maxv161positiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	161 as sporttype, 83 as bettype, @maxv161positiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	161 as sporttype, 88 as bettype, @maxv161positiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_85 as maxlivepositiontaking
				union all select 	161 as sporttype, 86 as bettype, @maxv161positiontaking_86 as maxpositiontaking,  @maxv161livepositiontaking_86 as maxlivepositiontaking
				union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_87 as maxlivepositiontaking
				union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_89 as maxlivepositiontaking
				union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @maxv161livepositiontaking_90 as maxlivepositiontaking			
			) as b on aco.sporttype=b.sporttype and aco.bettype = b.bettype
	where c.mrecommend = @custid and c.roleid = 2 and (aco.minpositiontaking>b.maxpositiontaking or (b.bettype in (85,86,87,89,90) and aco.minlivepositiontaking>b.maxlivepositiontaking))
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
		inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
		inner join (
				          select 	161 as sporttype, 81 as bettype, @minv161positiontaking_81 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	161 as sporttype, 83 as bettype, @minv161positiontaking_83 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	161 as sporttype, 88 as bettype, @minv161positiontaking_88 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	161 as sporttype, 85 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_85 as minlivepositiontaking
				union all select 	161 as sporttype, 86 as bettype, @minv161positiontaking_86 as minpositiontaking,  @minv161livepositiontaking_86 as minlivepositiontaking
				union all select 	161 as sporttype, 87 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_87 as minlivepositiontaking
				union all select 	161 as sporttype, 89 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_89 as minlivepositiontaking
				union all select 	161 as sporttype, 90 as bettype, 0 as minpositiontaking,  @minv161livepositiontaking_90 as minlivepositiontaking
			) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
	where cs.custid = @custid and (cs.mpositiontaking<b.minpositiontaking or (b.bettype in (85,86,87,89,90) and	 cs.mlivepositiontaking<b.minlivepositiontaking))
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 307
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_161] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_MAg_161] TO vnteam
GO

 