ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_SAg_2]
	@custid int,
	
	@minv2positiontaking_1 smallmoney,
	@minv2positiontaking_2 smallmoney,
	@minv2positiontaking_3 smallmoney,
	@minv2positiontaking_7 smallmoney,
	@minv2positiontaking_8 smallmoney,
	--@minv2positiontaking_9 smallmoney,
	@minv2positiontaking_20 smallmoney,

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
Task : Check parameters to update CustOverride for Basketball
DB: DBTRANS.bodb02
Original: Acc_CustOverrideUpd_CheckParam_SAg

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
	--check s4 >= new_n4
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username +', '
	from 
		customer as c with (NOLOCK) 
		inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
		inner join (
					      select 	2 as sporttype, 1 as bettype, @minv2positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	2 as sporttype, 2 as bettype, @minv2positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	2 as sporttype, 3 as bettype, @minv2positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	2 as sporttype, 7 as bettype, @minv2positiontaking_7 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	2 as sporttype, 8 as bettype, @minv2positiontaking_8 as minpositiontaking,  0 as minlivepositiontaking
				--union all select 	2 as sporttype, 9 as bettype, @minv2positiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
				union all select 	2 as sporttype, 20 as bettype, @minv2positiontaking_20 as minpositiontaking,  0 as minlivepositiontaking				
			) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
	where cs.custid = @custid and cs.spositiontaking<b.minpositiontaking
	group by username
	if @ErrAcc<>''
	BEGIN
		select @isvalid = 0, @ErrCode = 404
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_SAg_2] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_SAg_2] TO vnteam
GO

 