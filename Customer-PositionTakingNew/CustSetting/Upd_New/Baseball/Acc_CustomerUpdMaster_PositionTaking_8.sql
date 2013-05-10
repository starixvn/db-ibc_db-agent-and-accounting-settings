 ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_PositionTaking_8
	@custid int,-- masterid	
	
	@v8spositiontaking_1 smallmoney,
	@v8spositiontaking_3 smallmoney,	
	@v8spositiontaking_20 smallmoney,
	
	@auto_v8spositiontaking_1 smallmoney = 0,
	@auto_v8spositiontaking_3 smallmoney = 0,
	@auto_v8spositiontaking_20 smallmoney = 0,
	
	@isauto_v8spositiontaking_1 bit = 0,
	@isauto_v8spositiontaking_3 bit = 0,
	@isauto_v8spositiontaking_20 bit = 0,
	
	@v8mpositiontaking_1 smallmoney = 0.7,
	@v8mpositiontaking_3 smallmoney = 0.7,
	@v8mpositiontaking_20 smallmoney = 0.7,
	
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney = 0,--equals max(s+m) - chosen(m)
	
	@SubAccID int = 0, --Sub-AccountID	
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
as
/*
Created: 20120531@Elodie
Task : Update Position Taking of Baseball for Master
DB: DBTrans.bodb02
Original: Acc_CustomerUpdMaster_PositionTaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

declare @ErrAcc varchar(4000), @ErrType varchar(4000)
declare @UserName varchar(30), @srecommend int
		
Select @UserName  = username, @srecommend = srecommend from custinfo with (NOLOCK) where CustID = @CustID

---------------------------------------------------------------------------------
if 
	   @v8spositiontaking_1  <0
	or @v8spositiontaking_3  <0
	or @v8spositiontaking_20  <0
	
	or @v8spositiontaking_1+@v8mpositiontaking_1 >0.9
	or @v8spositiontaking_3+@v8mpositiontaking_3 >0.9
	or @v8spositiontaking_20+@v8mpositiontaking_20 >0.9
	
	or @auto_v8spositiontaking_1  >0.9
	or @auto_v8spositiontaking_3  >0.9
	or @auto_v8spositiontaking_20  >0.9
	
	or @v8mpositiontaking_1 <0
	or @v8mpositiontaking_3 <0
	or @v8mpositiontaking_20 <0
BEGIN
	select @ErrCode = 11
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong position taking (for Baseball).'
						when 'CS' then N'占成数不正确(于棒球).'
						when 'CT' then N'佔成數不正確(於棒球).'
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (สำหรับกีฬาเบสบอล).'
						when 'J' then N'Wrong position taking (for Baseball).'
						when 'KO' then N'거래 조건이 잘못 되었습니다 (야구).'
						else N'Wrong position taking (for Baseball).'
				end
	return
END

--check n4<=s3+m3<=l4 if i3 = 0, 
--m3<=l4 and u3+m3>=n4 if i3 = 1
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
from custoverride as co with (NOLOCK) inner join
	(
		 		select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @srecommend and (	
		((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
		(b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
		)
if @ErrType <>''
BEGIN
	select @ErrCode = 12
	Select @ErrMsg = 	case @Language
						when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
						when 'CS' then N'占成数不正确(公司设给最低/高占成).<br>'+@ErrType
						when 'CT' then N'佔成數不正確(公司設給最低/高佔成).<br>'+@ErrType
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (สูงสุด หรือ ต่ำสุด อ้างอิงจากข้อมูลบริษัท).<br>'+@ErrType
						when 'J' then N'Wrong position taking (min/max set by company).<br>'+@ErrType
						when 'KO' then N'거래 조건이 잘못 되었습니다 (ibc가 설정한 최소값/최대값).<br>'+@ErrType
						else N'Wrong position taking (min/max set by company).<br>'+@ErrType
				end
	return
END

--n3<=m3<=l3
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
from custoverride as co with (NOLOCK) inner join
	(
		 		select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
if @ErrType <>''
BEGIN
	select @ErrCode = 13
	Select @ErrMsg = 	@UserName + ': '+
				case @Language 
						when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
						when 'CS' then N'占成数不正确(公司设给最低/高占成).<br>'+@ErrType
						when 'CT' then N'佔成數不正確(公司設給最低/高佔成).<br>'+@ErrType
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (สูงสุด หรือ ต่ำสุด อ้างอิงจากข้อมูลบริษัท).<br>'+@ErrType
						when 'J' then N'Wrong position taking (min/max set by company).<br>'+@ErrType
						when 'KO' then N'거래 조건이 잘못 되었습니다 (ibc가 설정한 최소값/최대값).<br>'+@ErrType
						else N'Wrong position taking (min/max set by company).<br>'+@ErrType
				end
	return
END

--m2+a2<=m3
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
	    		  select 	8 as sporttype, 1 as bettype, @v8mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	8 as sporttype, 3 as bettype, @v8mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	8 as sporttype, 20 as bettype, @v8mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 and cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 14
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Baseball).'
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (于棒球).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (於棒球).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับกีฬาเบสบอล).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (야구).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
				end
	return
END

--m1+a1<=m3
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				  select 	8 as sporttype, 1 as bettype, @v8mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	8 as sporttype, 3 as bettype, @v8mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	8 as sporttype, 20 as bettype, @v8mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 1 and cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking 
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 15
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') (for Baseball).'
						when 'CS' then N'现有会员超出新总代理占成数设定 ('+@ErrAcc+ N')(于棒球).'
						when 'CT' then N'現有會員超出新總代理佔成數設定 ('+@ErrAcc+ N') (於棒球).'
						when 'TH' then N'สมาชิกที่มีอยู่ในขณะนี้เกินกว่า จำนวนตัวแทนหลักรายใหม่ กำหนดไว้ ('+@ErrAcc+ N')(สำหรับกีฬาเบสบอล).'
						when 'J' then N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
						when 'KO' then N'회원의 거래조건 설정 범위를 넘어섰습니다 ('+@ErrAcc+ N') (야구).'
						else N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
				end
	return
END

--check m3<=m4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))+ '<br>'
from custsetting as scs with (NOLOCK) inner join
	(
			 		select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
	) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where scs.custid = @srecommend and scs.mpositiontaking<b.mpositiontaking 
if @ErrType <>''
BEGIN
	select @ErrCode = 16
	Select @ErrMsg = 	@UserName + ': '+
				case @Language 
						when 'E' then 'Wrong position taking (max for master set by company).<br>'+@ErrType
						when 'CS' then N'占成数不正确(公司设给总代理最高占成).<br>'+@ErrType
						when 'CT' then N'佔成數不正確(公司設給總代理最高佔成).<br>'+@ErrType
						when 'TH' then N'การกำหนดไม่ถูกต้อง (สูงสุดไม่เกิน สำหรับรายการหลัก อ้างอิงจากข้อมูลบริษัท).<br>'+@ErrType
						when 'J' then N'Wrong position taking (max for master set by company).<br>'+@ErrType
						when 'KO' then N'거래 조건이 잘못 되었습니다 (ibc가 설정한 마스터의 최대값).<br>'+@ErrType
						else N'Wrong position taking (max for master set by company).<br>'+@ErrType
				end
	return
END

--m3>=u2
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					  select 	8 as sporttype, 1 as bettype, @v8mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	8 as sporttype, 3 as bettype, @v8mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	8 as sporttype, 20 as bettype, @v8mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 
	and cs.autompositiontaking > b.maxpositiontaking and cs.isautompositiontaking = 1
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 17
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Baseball).'
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (于棒球).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (於棒球).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับกีฬาเบสบอล).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (야구).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Baseball).'
				end
	return
END

declare 
	@Old_v8spositiontaking_1 smallmoney,
	@Old_v8spositiontaking_3 smallmoney,	
	@Old_v8spositiontaking_20 smallmoney,
	
	@Old_auto_v8spositiontaking_1 smallmoney ,
	@Old_auto_v8spositiontaking_3 smallmoney ,
	@Old_auto_v8spositiontaking_20 smallmoney ,
	
	@Old_isauto_v8spositiontaking_1 bit,
	@Old_isauto_v8spositiontaking_3 bit,
	@Old_isauto_v8spositiontaking_20 bit,
	
	@Old_v8mpositiontaking_1 smallmoney,
	@Old_v8mpositiontaking_3 smallmoney,
	@Old_v8mpositiontaking_20 smallmoney
	
select @old_v8mpositiontaking_1 = mpositiontaking, @old_v8spositiontaking_1 = spositiontaking, @old_auto_v8spositiontaking_1 = autopositiontaking, @old_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
select @old_v8mpositiontaking_3 = mpositiontaking, @old_v8spositiontaking_3 = spositiontaking, @old_auto_v8spositiontaking_3 = autopositiontaking, @old_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
select @old_v8mpositiontaking_20 = mpositiontaking, @old_v8spositiontaking_20 = spositiontaking, @old_auto_v8spositiontaking_20 = autopositiontaking, @old_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

----------------------------------------------------------------------------
--check u3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
from custsetting as cs with (NOLOCK) inner join
	(
					select 1 as bettype, 8 as sporttype, @auto_v8spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 3 as bettype, 8 as sporttype, @auto_v8spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 20 as bettype, 8 as sporttype, @auto_v8spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend and cs.spositiontaking<b.autopositiontaking

if @ErrType <>''
BEGIN
	Select @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Wrong auto position taking.<br>'+@ErrType
							when 'CS' then N'自动占成数不正确.<br>'+@ErrType
							when 'CT' then N'自動佔成數不正確.<br>'+@ErrType
							when 'TH' then N'การปรับยอดเงินที่ผิดพลาดอันเนื่องมาจากระบบ.<br>'+@ErrType
							when 'J' then N'Wrong auto position taking.<br>'+@ErrType
							when 'KO' then N'자동 거래조건이 잘못 되었습니다.<br>'+@ErrType
							else N'Wrong auto position taking.<br>'+@ErrType
						end, @ErrCode = 103
	return
END

--s3<=s4,s3+m3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
from custsetting as cs with (NOLOCK) inner join
	(
				select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_1 as mpositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_3 as mpositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_20 as mpositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend and ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking<b.spositiontaking+b.mpositiontaking))
if @ErrType <>''
BEGIN
	Select @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Wrong  position taking.<br>'+@ErrType
							when 'CS' then N'占成数不正确.<br>'+@ErrType
							when 'CT' then N'佔成數不正確.<br>'+@ErrType
							when 'TH' then N'การกำหนดไม่ถูกต้อง.<br>'+@ErrType
							when 'J' then N'Wrong  position taking.<br>'+@ErrType
							when 'KO' then N'거래 조건이 잘못 되었습니다.<br>'+@ErrType
							else N'Wrong  position taking.<br>'+@ErrType
						end, @ErrCode = 104
	return
END

-------------------------------------------------------------------
update custsetting with (ROWLOCK, UPDLOCK)
set
	spositiontaking = case sporttype when 8 then case bettype 
														when 1 then @v8spositiontaking_1 
														when 3 then @v8spositiontaking_3 
														when 20 then @v8spositiontaking_20 
														else 0 end
									else spositiontaking end,
	
	mpositiontaking = case sporttype when 8 then case bettype 
														when 1 then @v8mpositiontaking_1 
														when 3 then @v8mpositiontaking_3 
														when 20 then @v8mpositiontaking_20 
														else 0 end
									else mpositiontaking end
	
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
						when 'KO' then N'업데이트에 실패했습니다.'
						else N'Update process is unsuccessful !'
					end	, @ErrCode = 122					 
	
	return
end

EXEC dbo.Acc_CustomerUpdMaster_AutoPositiontaking_8
		@mrecommend=@custid, 
		@srecommend = @srecommend,

		@auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
		@auto_v8spositiontaking_3 = @auto_v8spositiontaking_3, 
		@auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,

		@isauto_v8spositiontaking_1	=	 @isauto_v8spositiontaking_1,
		@isauto_v8spositiontaking_3	=	 @isauto_v8spositiontaking_3,
		@isauto_v8spositiontaking_20=	 @isauto_v8spositiontaking_20,

		@language = @language,
		@updateallmembers = @updateallmembers,
		@newspositiontaking = @newspositiontaking,
		@userid = @userid,

		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
		
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						when 'CS' then N'更新程序不成功 !'
						when 'CT' then N'更新程序不成功 !'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
						when 'J' then N'アップデート出来ません。'
						when 'KO' then N'업데이트에 실패했습니다.'
						else N'Update process is unsuccessful !'
					end, @ErrCode = 123					 
	
	return
end

EXEC dbo.Acc_CustomerUpdMaster_MaxPositiontaking_8
		 @mrecommend = @custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						when 'CS' then N'更新程序不成功 !'
						when 'CT' then N'更新程序不成功 !'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
						when 'J' then N'アップデート出来ません。'
						when 'KO' then N'업데이트에 실패했습니다.'
						else N'Update process is unsuccessful !'
					end, @ErrCode = 124					 
	
	return
end

Declare @LogSPData varchar(5000)
Declare @TrackingValue2 varchar(5000)
	
Select @LogSPData = '<Acc_CustomerUpdMaster_PositionTaking_8><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<au a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<ia isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<m v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMaster_PositionTaking_8>' 


Select @TrackingValue2 = '<Acc_CustomerUpdMaster_PositionTaking_8><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<au a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<ia isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" />' +

'<m v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMaster_PositionTaking_8>' 

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 411,
	@TrackingValue = @LogSPData,
	@TrackingValue2 = @TrackingValue2,
	@duration = @duration

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_8] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_8] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_8] TO vnteam
 