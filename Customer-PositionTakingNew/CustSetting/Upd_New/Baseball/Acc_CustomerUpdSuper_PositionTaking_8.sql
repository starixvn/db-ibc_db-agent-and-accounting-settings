CREATE PROCEDURE [dbo].[Acc_CustomerUpdSuper_PositionTaking_8]
	@custid int,-- superid	
	
	@v8spositiontaking_1 smallmoney,
	@v8spositiontaking_3 smallmoney,
	@v8spositiontaking_20 smallmoney,

	@v8mpositiontaking_1 smallmoney = 0.7,
	@v8mpositiontaking_3 smallmoney = 0.7,
	@v8mpositiontaking_20 smallmoney = 0.7,

	@v8apositiontaking_1 smallmoney = 0.7,
	@v8apositiontaking_3 smallmoney = 0.7,
	@v8apositiontaking_20 smallmoney = 0.7,
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120511@Elodie
Task : Update Super's PT of Baseball
DB: DBTrans.bodb02
Original: Acc_CustomerUpdSuper_PositionTaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @username varchar(40)
select @username = username from custinfo with (NOLOCK) where custid = @custid
--------------------------------------------------------------------------------------------
--Check Param
Declare @ErrAcc nvarchar(4000)
declare @ErrType varchar(1000)

if	   @v8spositiontaking_1  <0
	or @v8spositiontaking_3  <0
	or @v8spositiontaking_20  <0

	or @v8mpositiontaking_1  <0
	or @v8mpositiontaking_3  <0
	or @v8mpositiontaking_20  <0

	or @v8apositiontaking_1  <0
	or @v8apositiontaking_3  <0
	or @v8apositiontaking_20  <0

	or @v8spositiontaking_1  >0.9
	or @v8spositiontaking_3  >0.9
	or @v8spositiontaking_20  >0.9
	
	or @v8mpositiontaking_1  >0.9
	or @v8mpositiontaking_3  >0.9
	or @v8mpositiontaking_20  >0.9

	or @v8apositiontaking_1  >0.9
	or @v8apositiontaking_3  >0.9
	or @v8apositiontaking_20  >0.9

	or @v8spositiontaking_1   <  @v8mpositiontaking_1 
	or @v8spositiontaking_3   <  @v8mpositiontaking_3 
	or @v8spositiontaking_20   <  @v8mpositiontaking_20

	or @v8mpositiontaking_1   <  @v8apositiontaking_1  
	or @v8mpositiontaking_3   <  @v8apositiontaking_3  
	or @v8mpositiontaking_20   <  @v8apositiontaking_20
BEGIN
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong position taking.'
						when 'CS' then N'占成数不正确.'
						when 'CT' then N'佔成數不正確.'
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง.'
						when 'J' then N'Wrong position taking.'
						else N'Wrong position taking.'
				end, @ErrCode = 101
	return
END

declare @Old_v8spositiontaking_1 smallmoney,
		@Old_v8spositiontaking_3 smallmoney,
		@Old_v8spositiontaking_20 smallmoney,

		@Old_v8mpositiontaking_1 smallmoney,
		@Old_v8mpositiontaking_3 smallmoney,
		@Old_v8mpositiontaking_20 smallmoney,

		@Old_v8apositiontaking_1 smallmoney,
		@Old_v8apositiontaking_3 smallmoney,
		@Old_v8apositiontaking_20 smallmoney
	
--select old data
select @Old_v8spositiontaking_1= spositiontaking, @Old_v8mpositiontaking_1= mpositiontaking, @Old_v8apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=8
select @Old_v8spositiontaking_3= spositiontaking, @Old_v8mpositiontaking_3= mpositiontaking, @Old_v8apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=8
select @Old_v8spositiontaking_20= spositiontaking, @Old_v8mpositiontaking_20= mpositiontaking, @Old_v8apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=8

--check n4<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10)) + '<br>'
	from custoverride as co with (NOLOCK) 
	inner join
	(
				select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and b.spositiontaking<co.minpositiontaking

if @ErrType <>''
BEGIN
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong position taking (min set by company).<br>'+@ErrType
						when 'CS' then N'占成数不正确(公司设给最低占成).<br>'+@ErrType
						when 'CT' then N'佔成數不正確(公司設給最低佔成).<br>'+@ErrType
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (ต่ำสุด อ้างอิงจากข้อมูลบริษัท).<br>'+@ErrType
						when 'J' then N'Wrong position taking (min set by company).<br>'+@ErrType
						else N'Wrong position taking (min set by company).<br>'+@ErrType
				end, @ErrCode = 102
	return
END

--check all s3+m3<=s4 if i3 = 0,
--m3<=s4 and u3<=s4 if i3=1
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join 
	(
		      select 	8 as sporttype, 1 as bettype, @v8spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 3 as bettype, @v8spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 20 as bettype, @v8spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 3 and 
						(
						((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) 
						)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
						when 'CS' then N'现有总代理超出新超级总代理占成数设定 ('+@ErrAcc+').'
						when 'CT' then N'現有總代理超出新超級總代理佔成數設定 ('+@ErrAcc+').'
						when 'TH' then N'ตัวแทนหลักที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนสูงสุดที่บริษัทกำหนดไว้('+@ErrAcc+').'
						when 'J' then N'Existing masters exceeded new super position taking ('+@ErrAcc+').'
						else N'Existing masters exceeded new super position taking ('+@ErrAcc+').'
				end, @ErrCode = 103
	return
END

--check all s1+m1+a1 <= s4
--check all u1<=s4 if i1=1
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join 
	(
		      select 	8 as sporttype, 1 as bettype, @v8spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 3 as bettype, @v8spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 20 as bettype, @v8spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and 
			(
			(cs.spositiontaking+cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking) or 
			(cs.isautopositiontaking=1 and cs.autopositiontaking>b.maxpositiontaking)
			)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing members exceeded new super position taking ('+@ErrAcc+').'
						when 'CS' then N'现有会员超出新超级总代理占成数设定('+@ErrAcc+').'
						when 'CT' then N'現有會員超出新超級總代理佔成數設定('+@ErrAcc+').'
						when 'TH' then N'สมาชิกที่มีอยู่ในขณะนี้เกินกว่า จำนวนตัวแทนสูงสุดรายใหม่กำหนดไว้('+@ErrAcc+').'
						when 'J' then N'Existing members exceeded new super position taking ('+@ErrAcc+').'
						else N'Existing members exceeded new super position taking ('+@ErrAcc+').'
				end, @ErrCode = 104
	return
END

--------------------------------------------------------------------------------------------
--Check all m1+a1<=m4
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join 
	(
		      select 	8 as sporttype, 1 as bettype, @v8mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 3 as bettype, @v8mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 20 as bettype, @v8mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
		 	
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = 	@UserName + ': '+
		case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+').'
						when 'CS' then N'现有会员超过新总代理的占成数 ('+@ErrAcc+').'
						when 'CT' then N'現有會員超過新總代理的佔成數 ('+@ErrAcc+').'
						when 'TH' then N'Existing members exceeded new master position taking ('+@ErrAcc+').'
						when 'J' then N'Existing members exceeded new master position taking ('+@ErrAcc+').'
						else N'Existing members exceeded new master position taking ('+@ErrAcc+').'
				end, @ErrCode = 108
	return
END

--Check all a1<=a4
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join 
	(
			  select 	8 as sporttype, 1 as bettype, @v8apositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 3 as bettype, @v8apositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
	union all select 	8 as sporttype, 20 as bettype, @v8apositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and cs.apositiontaking>b.maxpositiontaking				
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = 	@UserName + ': '+
		case @Language 
						when 'E' then 'Existing members exceeded new agent position taking ('+@ErrAcc+').'
						when 'CS' then N'现有会员超过新代理的占成数 ('+@ErrAcc+').'
						when 'CT' then N'現有會員超過新代理的佔成數 ('+@ErrAcc+').'
						when 'TH' then N'Existing members exceeded new agent position taking ('+@ErrAcc+').'
						when 'J' then N'Existing members exceeded new agent position taking ('+@ErrAcc+').'
						else N'Existing members exceeded new agent position taking ('+@ErrAcc+').'
				end, @ErrCode = 109
	return
END

--------------------------------------------------------------------------------------------
update custsetting with (ROWLOCK, UPDLOCK)
set
	spositiontaking = case sporttype 	when 8 then case bettype when 1 then @v8spositiontaking_1 when 3 then @v8spositiontaking_3 when 20 then @v8spositiontaking_20 else 0 end
					else spositiontaking end,
	
	mpositiontaking = case sporttype 	when 8 then case bettype when 1 then @v8mpositiontaking_1 when 3 then @v8mpositiontaking_3 when 20 then @v8mpositiontaking_20 else 0 end
					else mpositiontaking end,
	
	apositiontaking = case sporttype 	when 8 then case bettype when 1 then @v8apositiontaking_1 when 3 then @v8apositiontaking_3 when 20 then @v8apositiontaking_20 else 0 end
					else apositiontaking end
	
where custid=@custid
if (@@error <> 0)
begin
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						when 'CS' then N'更新程序不成功 !'
						when 'CT' then N'更新程序不成功 !'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
						when 'J' then N'アップデート出来ません。'
						else N'Update process is unsuccessful !'
					end	, @ErrCode = 105					 
	
	return
end

exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking_8 @srecommend = @custid
if (@@error <> 0)
begin
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						when 'CS' then N'更新程序不成功 !'
						when 'CT' then N'更新程序不成功 !'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
						when 'J' then N'アップデート出来ません。'
						else N'Update process is unsuccessful !'
					end, @ErrCode = 107	
	return
end

--Update l4=s4
EXEC dbo.Acc_CustoverrideUpd_8
		@custid = @custid,
		
		@minv8positiontaking_1 = 0,
		@minv8positiontaking_3 = 0,
		@minv8positiontaking_20 = 0,

		@maxv8positiontaking_1 = @v8spositiontaking_1,
		@maxv8positiontaking_3 = @v8spositiontaking_3,
		@maxv8positiontaking_20 = @v8spositiontaking_20,
		
		@CheckPermission = 0,
		@UpdateMinPos = 0,
		@UpdateMaxPos = 1,
		@language = @language,
		@UserID = @UserID,
		@SubAccID = 0,
		@WriteLog = 0

if (@@error <> 0)
begin
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						when 'CS' then N'更新程序不成功 !'
						when 'CT' then N'更新程序不成功 !'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
						when 'J' then N'アップデート出来ません。'
						else N'Update process is unsuccessful !'
					end, @ErrCode = 106			 
	
	return
end



Declare @LogSPData varchar(5000)

Declare @TrackingValue2 varchar(5000)

Select @LogSPData = '<Acc_CustomerUpdSuper_PositionTaking_8><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<m v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" />' +


'<ag v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_8>'


Select @TrackingValue2 = '<Acc_CustomerUpdSuper_PositionTaking_8><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<m v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + '" />' +


'<ag v8apt_1="'+ coalesce(cast(@Old_v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@Old_v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@Old_v8apositiontaking_20 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_8>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
@UserID = @UserID,
@CustID = @CustID,
@ActionID = 410,
@TrackingValue = @LogSPData,
@TrackingValue2 = @TrackingValue2,
@duration = @duration

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_8] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_8] TO vnteam
