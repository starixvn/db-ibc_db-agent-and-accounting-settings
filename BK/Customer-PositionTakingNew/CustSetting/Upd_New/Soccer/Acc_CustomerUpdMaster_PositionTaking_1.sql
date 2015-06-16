ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_PositionTaking_1
	@custid int,-- masterid	
	
	@spositiontaking_1 smallmoney,
	@spositiontaking_2 smallmoney,
	@spositiontaking_3 smallmoney,
	@spositiontaking_4 smallmoney,
	@spositiontaking_5 smallmoney,
	@spositiontaking_6 smallmoney,
	@spositiontaking_7 smallmoney,
	@spositiontaking_8 smallmoney,
	@spositiontaking_9 smallmoney,
	@spositiontaking_10 smallmoney,
	@slivepositiontaking_1 smallmoney,
	@slivepositiontaking_3 smallmoney,
	@slivepositiontaking_7 smallmoney,
	@slivepositiontaking_8 smallmoney,
	
	@auto_spositiontaking_1 smallmoney = 0,
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney= 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
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
	
	@mpositiontaking_1 smallmoney = 0.7,
	@mpositiontaking_2 smallmoney = 0.7,
	@mpositiontaking_3 smallmoney = 0.7,
	@mpositiontaking_4 smallmoney = 0.7,
	@mpositiontaking_5 smallmoney = 0.7,
	@mpositiontaking_6 smallmoney = 0.7,
	@mpositiontaking_7 smallmoney = 0.7,
	@mpositiontaking_8 smallmoney = 0.7,
	@mpositiontaking_9 smallmoney = 0.7,
	@mpositiontaking_10 smallmoney = 0.7,
	@mlivepositiontaking_1 smallmoney = 0.7,
	@mlivepositiontaking_3 smallmoney = 0.7,
	@mlivepositiontaking_7 smallmoney = 0.7,
	@mlivepositiontaking_8 smallmoney = 0.7,
	
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
Created: 20120529@Elodie
Task : Update Position Taking of Soccer for Master
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
	   @spositiontaking_1  <0
	or @spositiontaking_2  <0
	or @spositiontaking_3  <0
	or @spositiontaking_4  <0
	or @spositiontaking_5  <0
	or @spositiontaking_6  <0
	or @spositiontaking_7  <0
	or @spositiontaking_8  <0
	or @spositiontaking_9  <0
	or @spositiontaking_10 <0
	or @slivepositiontaking_1  <0
	or @slivepositiontaking_3  <0
	or @slivepositiontaking_7  <0
	or @slivepositiontaking_8  <0
	
	
	or @mpositiontaking_1  <0
	or @mpositiontaking_2  <0
	or @mpositiontaking_3  <0
	or @mpositiontaking_4  <0
	or @mpositiontaking_5  <0
	or @mpositiontaking_6  <0
	or @mpositiontaking_7  <0
	or @mpositiontaking_8  <0
	or @mpositiontaking_9  <0
	or @mpositiontaking_10 <0
	or @mlivepositiontaking_1  <0
	or @mlivepositiontaking_3  <0
	or @mlivepositiontaking_7  <0
	or @mlivepositiontaking_8  <0
	
	
	or @spositiontaking_1+@mpositiontaking_1 >0.9
	or @spositiontaking_2+@mpositiontaking_2 >0.9
	or @spositiontaking_3+@mpositiontaking_3 >0.9
	or @spositiontaking_4+@mpositiontaking_4 >0.9
	or @spositiontaking_5+@mpositiontaking_5 >0.9
	or @spositiontaking_6+@mpositiontaking_6 >0.9
	or @spositiontaking_7+@mpositiontaking_7 >0.9
	or @spositiontaking_8+@mpositiontaking_8 >0.9
	or @spositiontaking_9+@mpositiontaking_9 >0.9
	or @spositiontaking_10+@mpositiontaking_10 >0.9
	or @slivepositiontaking_1+@mlivepositiontaking_1 >0.9
	or @slivepositiontaking_3+@mlivepositiontaking_3 >0.9
	or @slivepositiontaking_7+@mlivepositiontaking_7 >0.9
	or @slivepositiontaking_8+@mlivepositiontaking_8 >0.9

	or @auto_spositiontaking_1  <0
	or @auto_spositiontaking_2  <0
	or @auto_spositiontaking_3  <0
	or @auto_spositiontaking_4  <0
	or @auto_spositiontaking_5  <0
	or @auto_spositiontaking_6  <0
	or @auto_spositiontaking_7  <0
	or @auto_spositiontaking_8  <0
	or @auto_spositiontaking_9  <0
	or @auto_spositiontaking_10 <0
	or @auto_slivepositiontaking_1  <0
	or @auto_slivepositiontaking_3  <0
	or @auto_slivepositiontaking_7  <0
	or @auto_slivepositiontaking_8  <0

	or @auto_spositiontaking_1  >0.9
	or @auto_spositiontaking_2  >0.9
	or @auto_spositiontaking_3  >0.9
	or @auto_spositiontaking_4  >0.9
	or @auto_spositiontaking_5  >0.9
	or @auto_spositiontaking_6  >0.9
	or @auto_spositiontaking_7  >0.9
	or @auto_spositiontaking_8  >0.9
	or @auto_spositiontaking_9  >0.9
	or @auto_spositiontaking_10 >0.9
	or @auto_slivepositiontaking_1  >0.9
	or @auto_slivepositiontaking_3  >0.9
	or @auto_slivepositiontaking_7  >0.9
	or @auto_slivepositiontaking_8  >0.9
BEGIN
	select @ErrCode = 5
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong position taking (for Soccer).'
						when 'CS' then N'占成数不正确(于足球).'
						when 'CT' then N'佔成數不正確(於足球).'
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (สำหรับกีฬาฟุตบอล).'
						when 'J' then N'Wrong position taking (for Soccer).'
						when 'KO' then N'거래 조건이 잘못 되었습니다 (축구).'
						else N'Wrong position taking (for Soccer).'
				end
	return
END

----------------------------------------------
--check n4<=s3+m3<=l4 if i3 = 0, 
--m3<=l4 and u3+m3>=n4 if i3 = 1
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
from 
	custoverride as co with (NOLOCK) 
	inner join
	(
				select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @isauto_spositiontaking_1 as isauto_spositiontaking,  @isauto_slivepositiontaking_1 as isauto_slivepositiontaking, @auto_spositiontaking_1 as auto_spositiontaking,  @auto_slivepositiontaking_1 as auto_slivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @isauto_spositiontaking_3 as isauto_spositiontaking,  @isauto_slivepositiontaking_3 as isauto_slivepositiontaking, @auto_spositiontaking_3 as auto_spositiontaking,  @auto_slivepositiontaking_3 as auto_slivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @isauto_spositiontaking_7 as isauto_spositiontaking,  @isauto_slivepositiontaking_7 as isauto_slivepositiontaking, @auto_spositiontaking_7 as auto_spositiontaking,  @auto_slivepositiontaking_7 as auto_slivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @isauto_spositiontaking_8 as isauto_spositiontaking,  @isauto_slivepositiontaking_8 as isauto_slivepositiontaking, @auto_spositiontaking_8 as auto_spositiontaking,  @auto_slivepositiontaking_8 as auto_slivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_2 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_4 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_4 as auto_spositiontaking,  0 as auto_slivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_5 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_5 as auto_spositiontaking,  0 as auto_slivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_6 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_6 as auto_spositiontaking,  0 as auto_slivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_9 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_10 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking	
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @srecommend and (	
					((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
					(b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking)) or 
					((b.bettype in (1,3,7,8) and b.isauto_slivepositiontaking=0) and (b.slivepositiontaking+b.mlivepositiontaking>co.maxlivepositiontaking or b.slivepositiontaking+b.mlivepositiontaking<co.minlivepositiontaking)) or
					((b.bettype in (1,3,7,8) and b.isauto_slivepositiontaking>0) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking + b.auto_slivepositiontaking<co.minlivepositiontaking))
				)
if @ErrType <>''
BEGIN
	select @ErrCode = 6
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

--check n3<=m3<=l3 
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
+ case when b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
from 
	custoverride as co with (NOLOCK) 
	inner join
	(
				select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @isauto_spositiontaking_1 as isauto_spositiontaking,  @isauto_slivepositiontaking_1 as isauto_slivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @isauto_spositiontaking_3 as isauto_spositiontaking,  @isauto_slivepositiontaking_3 as isauto_slivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @isauto_spositiontaking_7 as isauto_spositiontaking,  @isauto_slivepositiontaking_7 as isauto_slivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @isauto_spositiontaking_8 as isauto_spositiontaking,  @isauto_slivepositiontaking_8 as isauto_slivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_2 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_4 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_5 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_6 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_9 as isauto_spositiontaking,  0 as isauto_slivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_spositiontaking_10 as isauto_spositiontaking,  0 as isauto_slivepositiontaking	
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and (	
					(b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) or 
					(b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
				)
if @ErrType <>''
BEGIN
	select @ErrCode = 7
	Select @ErrMsg = @UserName + ': '+
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

--a2+m2<=m3
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				  select 	1 as sporttype, 1 as bettype, @mpositiontaking_1 as maxpositiontaking,  @mlivepositiontaking_1 as maxlivepositiontaking
		union all select 	1 as sporttype, 2 as bettype, @mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 3 as bettype, @mpositiontaking_3 as maxpositiontaking,  @mlivepositiontaking_3 as maxlivepositiontaking
		union all select 	1 as sporttype, 4 as bettype, @mpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 5 as bettype, @mpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 6 as bettype, @mpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 7 as bettype, @mpositiontaking_7 as maxpositiontaking,  @mlivepositiontaking_7 as maxlivepositiontaking
		union all select 	1 as sporttype, 8 as bettype, @mpositiontaking_8 as maxpositiontaking,  @mlivepositiontaking_8 as maxlivepositiontaking
		union all select 	1 as sporttype, 9 as bettype, @mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 10 as bettype, @mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 
		and (cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking or (b.bettype in (1,3,7,8) and cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking))
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 8
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Soccer).'
						--when 'E' then 'Existing agents exceeded new master position taking <br> ' +@ErrAcc
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (于足球).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (於足球).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับกีฬาฟุตบอล).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Soccer).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (축구).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Soccer).'
				end
	return
END

--a1+m1<=m3
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					  select 	1 as sporttype, 1 as bettype, @mpositiontaking_1 as maxpositiontaking,  @mlivepositiontaking_1 as maxlivepositiontaking
			union all select 	1 as sporttype, 2 as bettype, @mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 3 as bettype, @mpositiontaking_3 as maxpositiontaking,  @mlivepositiontaking_3 as maxlivepositiontaking
			union all select 	1 as sporttype, 4 as bettype, @mpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 5 as bettype, @mpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 6 as bettype, @mpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 7 as bettype, @mpositiontaking_7 as maxpositiontaking,  @mlivepositiontaking_7 as maxlivepositiontaking
			union all select 	1 as sporttype, 8 as bettype, @mpositiontaking_8 as maxpositiontaking,  @mlivepositiontaking_8 as maxlivepositiontaking
			union all select 	1 as sporttype, 9 as bettype, @mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 10 as bettype, @mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 1 
		and (cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking or (b.bettype in (1,3,7,8) and cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking))
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 9
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') (for Soccer).'
						when 'CS' then N'现有会员超出新总代理占成数设定 ('+@ErrAcc+ N') (于足球).'
						when 'CT' then N'現有會員超出新總代理佔成數設定 ('+@ErrAcc+ N') (於足球).'
						when 'TH' then N'สมาชิกที่มีอยู่ในขณะนี้เกินกว่า จำนวนตัวแทนหลักรายใหม่ กำหนดไว้('+@ErrAcc+ N')(สำหรับฟุตบอล ).'
						when 'J' then N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Soccer).'
						when 'KO' then N'회원의 거래조건 설정 범위를 넘어섰습니다 ('+@ErrAcc+ N') (축구).'
						else N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Soccer).'
				end
	return
END

--check m3<=m4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
+ case when b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting as scs with (NOLOCK) inner join
	(
					select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @auto_spositiontaking_1 as auto_spositiontaking,  @auto_slivepositiontaking_1 as auto_slivepositiontaking
		union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @auto_spositiontaking_3 as auto_spositiontaking,  @auto_slivepositiontaking_3 as auto_slivepositiontaking
		union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @auto_spositiontaking_7 as auto_spositiontaking,  @auto_slivepositiontaking_7 as auto_slivepositiontaking
		union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @auto_spositiontaking_8 as auto_spositiontaking,  @auto_slivepositiontaking_8 as auto_slivepositiontaking
		union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_4 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_5 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_6 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
	) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where scs.custid = @srecommend and (
					scs.mpositiontaking<b.mpositiontaking or (b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
					)
if @ErrType <>''
BEGIN
	select @ErrCode = 10
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
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				  select 	1 as sporttype, 1 as bettype, @mpositiontaking_1 as maxpositiontaking,  @mlivepositiontaking_1 as maxlivepositiontaking
		union all select 	1 as sporttype, 2 as bettype, @mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 3 as bettype, @mpositiontaking_3 as maxpositiontaking,  @mlivepositiontaking_3 as maxlivepositiontaking
		union all select 	1 as sporttype, 4 as bettype, @mpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 5 as bettype, @mpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 6 as bettype, @mpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 7 as bettype, @mpositiontaking_7 as maxpositiontaking,  @mlivepositiontaking_7 as maxlivepositiontaking
		union all select 	1 as sporttype, 8 as bettype, @mpositiontaking_8 as maxpositiontaking,  @mlivepositiontaking_8 as maxlivepositiontaking
		union all select 	1 as sporttype, 9 as bettype, @mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
		union all select 	1 as sporttype, 10 as bettype, @mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 
	and (	(cs.autompositiontaking > b.maxpositiontaking and cs.isautompositiontaking = 1)
			or ((b.bettype in (1,3,7,8) and cs.autolivempositiontaking > b.maxlivepositiontaking) and cs.isautolivempositiontaking = 1)
		)
group by username
if @ErrAcc<>''
BEGIN
	select @ErrCode = 17
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Soccer).'
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (于足球).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (於足球).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับกีฬาฟุตบอล).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Soccer).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (축구).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Soccer).'
				end
	return
END

declare 
	@Old_spositiontaking_1 smallmoney,
	@Old_spositiontaking_2 smallmoney,
	@Old_spositiontaking_3 smallmoney,
	@Old_spositiontaking_4 smallmoney,
	@Old_spositiontaking_5 smallmoney,
	@Old_spositiontaking_6 smallmoney,
	@Old_spositiontaking_7 smallmoney,
	@Old_spositiontaking_8 smallmoney,
	@Old_spositiontaking_9 smallmoney,
	@Old_spositiontaking_10 smallmoney,
	@Old_slivepositiontaking_1 smallmoney,
	@Old_slivepositiontaking_3 smallmoney,
	@Old_slivepositiontaking_7 smallmoney,
	@Old_slivepositiontaking_8 smallmoney,
	
	@Old_auto_spositiontaking_1 smallmoney ,
	@Old_auto_spositiontaking_2 smallmoney ,
	@Old_auto_spositiontaking_3 smallmoney ,
	@Old_auto_spositiontaking_4 smallmoney ,
	@Old_auto_spositiontaking_5 smallmoney,
	@Old_auto_spositiontaking_6 smallmoney ,
	@Old_auto_spositiontaking_7 smallmoney ,
	@Old_auto_spositiontaking_8 smallmoney ,
	@Old_auto_spositiontaking_9 smallmoney ,
	@Old_auto_spositiontaking_10 smallmoney ,
	@Old_auto_slivepositiontaking_1 smallmoney ,
	@Old_auto_slivepositiontaking_3 smallmoney ,
	@Old_auto_slivepositiontaking_7 smallmoney ,
	@Old_auto_slivepositiontaking_8 smallmoney ,
	
	@Old_isauto_spositiontaking_1 bit,
	@Old_isauto_spositiontaking_2 bit,
	@Old_isauto_spositiontaking_3 bit,
	@Old_isauto_spositiontaking_4 bit,
	@Old_isauto_spositiontaking_5 bit,
	@Old_isauto_spositiontaking_6 bit,
	@Old_isauto_spositiontaking_7 bit,
	@Old_isauto_spositiontaking_8 bit,
	@Old_isauto_spositiontaking_9 bit,
	@Old_isauto_spositiontaking_10 bit,
	@Old_isauto_slivepositiontaking_1 bit,
	@Old_isauto_slivepositiontaking_3 bit,
	@Old_isauto_slivepositiontaking_7 bit,
	@Old_isauto_slivepositiontaking_8 bit,
	
	@Old_mpositiontaking_1 smallmoney,
	@Old_mpositiontaking_2 smallmoney,
	@Old_mpositiontaking_3 smallmoney,
	@Old_mpositiontaking_4 smallmoney,
	@Old_mpositiontaking_5 smallmoney,
	@Old_mpositiontaking_6 smallmoney,
	@Old_mpositiontaking_7 smallmoney,
	@Old_mpositiontaking_8 smallmoney,
	@Old_mpositiontaking_9 smallmoney,
	@Old_mpositiontaking_10 smallmoney,
	@Old_mlivepositiontaking_1 smallmoney,
	@Old_mlivepositiontaking_3 smallmoney,
	@Old_mlivepositiontaking_7 smallmoney,
	@Old_mlivepositiontaking_8 smallmoney

select @old_mpositiontaking_1 = mpositiontaking, @old_mlivepositiontaking_1 = mlivepositiontaking, 
	@old_spositiontaking_1 = spositiontaking, @old_slivepositiontaking_1 = slivepositiontaking,
	@Old_auto_spositiontaking_1 = autopositiontaking, @Old_isauto_spositiontaking_1=isautopositiontaking,
	@Old_auto_slivepositiontaking_1 = autolivepositiontaking, @Old_isauto_slivepositiontaking_1=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1

select @old_mpositiontaking_3 = mpositiontaking, @old_mlivepositiontaking_3 = mlivepositiontaking, 
	@old_spositiontaking_3 = spositiontaking, @old_slivepositiontaking_3 = slivepositiontaking,
	@Old_auto_spositiontaking_3 = autopositiontaking, @Old_isauto_spositiontaking_3=isautopositiontaking,
	@Old_auto_slivepositiontaking_3 = autolivepositiontaking, @Old_isauto_slivepositiontaking_3=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1

select @old_mpositiontaking_7 = mpositiontaking, @old_mlivepositiontaking_7 = mlivepositiontaking, 
	@old_spositiontaking_7 = spositiontaking, @old_slivepositiontaking_7 = slivepositiontaking, 
	@Old_auto_spositiontaking_7 = autopositiontaking, @Old_isauto_spositiontaking_7=isautopositiontaking,
	@Old_auto_slivepositiontaking_7 = autolivepositiontaking, @Old_isauto_slivepositiontaking_7=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1

select @old_mpositiontaking_8 = mpositiontaking, @old_mlivepositiontaking_8 = mlivepositiontaking, 
	@old_spositiontaking_8 = spositiontaking, @old_slivepositiontaking_8 = slivepositiontaking,
	@Old_auto_spositiontaking_8 = autopositiontaking, @Old_isauto_spositiontaking_8=isautopositiontaking,
	@Old_auto_slivepositiontaking_8 = autolivepositiontaking, @Old_isauto_slivepositiontaking_8=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

select @old_mpositiontaking_2 = mpositiontaking, @old_spositiontaking_2 = spositiontaking, @old_auto_spositiontaking_2 = autopositiontaking, @old_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
select @old_mpositiontaking_4 = mpositiontaking, @old_spositiontaking_4 = spositiontaking, @old_auto_spositiontaking_4 = autopositiontaking, @old_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
select @old_mpositiontaking_5 = mpositiontaking, @old_spositiontaking_5 = spositiontaking, @old_auto_spositiontaking_5 = autopositiontaking, @old_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
select @old_mpositiontaking_6 = mpositiontaking, @old_spositiontaking_6 = spositiontaking, @old_auto_spositiontaking_6 = autopositiontaking, @old_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
select @old_mpositiontaking_9 = mpositiontaking, @old_spositiontaking_9 = spositiontaking, @old_auto_spositiontaking_9 = autopositiontaking, @old_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
select @old_mpositiontaking_10 = mpositiontaking, @old_spositiontaking_10 = spositiontaking, @old_auto_spositiontaking_10 = autopositiontaking, @old_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--check u3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
+ case when b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting as cs with (NOLOCK) inner join
	(
					select 1 as bettype, 1 as sporttype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1 as autolivepositiontaking
		union all 	select 2 as bettype, 1 as sporttype, @auto_spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 3 as bettype, 1 as sporttype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 as autolivepositiontaking
		union all 	select 4 as bettype, 1 as sporttype, @auto_spositiontaking_4 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 5 as bettype, 1 as sporttype, @auto_spositiontaking_5 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 6 as bettype, 1 as sporttype, @auto_spositiontaking_6 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 7 as bettype, 1 as sporttype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 as autolivepositiontaking
		union all 	select 8 as bettype, 1 as sporttype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 as autolivepositiontaking
		union all 	select 9 as bettype, 1 as sporttype, @auto_spositiontaking_9 as autopositiontaking, 0 as autolivepositiontaking
		union all 	select 10 as bettype, 1 as sporttype, @auto_spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend
	and 
	((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and cs.slivepositiontaking<b.autolivepositiontaking))

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
						end	, @ErrCode = 101
	return
END

--check s3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
+ case when b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting as cs with (NOLOCK) inner join
	(
				select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
	) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend
	and 
	((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking<b.spositiontaking+b.mpositiontaking) or (b.bettype in (1,3,7,8) and cs.slivepositiontaking<b.slivepositiontaking) or (b.bettype in (1,3,7,8) and cs.slivepositiontaking<b.slivepositiontaking+b.mlivepositiontaking))

if @ErrType <>''
BEGIN
	Select @ErrMsg =	@UserName + ': '+
						case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							when 'CS' then N'占成数不正确.<br>'+@ErrType
							when 'CT' then N'佔成數不正確.<br>'+@ErrType
							when 'TH' then N'การกำหนดไม่ถูกต้อง.<br>'+@ErrType
							when 'J' then N'Wrong position taking.<br>'+@ErrType
							when 'KO' then N'거래 조건이 잘못 되었습니다.<br>'+@ErrType
							else N'Wrong position taking.<br>'+@ErrType
						end	, @ErrCode = 102
	return
END

-------------------------------------------------------------------
update custsetting with (ROWLOCK, UPDLOCK)
set
	spositiontaking = case sporttype when 1 then case bettype 
														when 1 then @spositiontaking_1 
														when 2 then @spositiontaking_2 
														when 3 then @spositiontaking_3 
														when 4 then @spositiontaking_4 
														when 5 then @spositiontaking_5 
														when 6 then @spositiontaking_6 
														when 7 then @spositiontaking_7 
														when 8 then @spositiontaking_8
														when 9 then @spositiontaking_9  
														when 10 then @spositiontaking_10 
														else 0 end
									else spositiontaking end,
	
	slivepositiontaking = case sporttype when 1 then case bettype 
															when 1 then @slivepositiontaking_1 
															when 3 then @slivepositiontaking_3 
															when 7 then @slivepositiontaking_7 
															when 8 then @slivepositiontaking_8 
															else slivepositiontaking end 
										else slivepositiontaking end,
	
	mpositiontaking = case sporttype when 1 then case bettype 
														when 1 then @mpositiontaking_1 
														when 2 then @mpositiontaking_2 
														when 3 then @mpositiontaking_3 
														when 4 then @mpositiontaking_4 
														when 5 then @mpositiontaking_5 
														when 6 then @mpositiontaking_6 
														when 7 then @mpositiontaking_7 
														when 8 then @mpositiontaking_8 
														when 9 then @mpositiontaking_9  
														when 10 then @mpositiontaking_10 
														else 0 end
									else mpositiontaking end,
	
	mlivepositiontaking = case sporttype when 1 then case bettype 
															when 1 then @mlivepositiontaking_1 
															when 3 then @mlivepositiontaking_3 
															when 7 then @mlivepositiontaking_7 
															when 8 then @mlivepositiontaking_8 
															else mlivepositiontaking end 
										else mlivepositiontaking end
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

EXEC dbo.Acc_CustomerUpdMaster_AutoPositiontaking_1
		@mrecommend=@custid, 
		@srecommend = @srecommend,

		@auto_spositiontaking_1 = @auto_spositiontaking_1,
		@auto_spositiontaking_2 = @auto_spositiontaking_2, 
		@auto_spositiontaking_3 = @auto_spositiontaking_3,
		@auto_spositiontaking_4 = @auto_spositiontaking_4,
		@auto_spositiontaking_5 = @auto_spositiontaking_5, 
		@auto_spositiontaking_6 = @auto_spositiontaking_6,
		@auto_spositiontaking_7 = @auto_spositiontaking_7,
		@auto_spositiontaking_8 = @auto_spositiontaking_8, 
		@auto_spositiontaking_9 = @auto_spositiontaking_9,
		@auto_spositiontaking_10 = @auto_spositiontaking_10,
		
		@auto_slivepositiontaking_1 = @auto_slivepositiontaking_1, 
		@auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
		@auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
		@auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
		 
		@language = @language,
		@updateallmembers = @updateallmembers,
		@newspositiontaking = @newspositiontaking,
		@userid = @userid,

		@isauto_spositiontaking_1	=	 @isauto_spositiontaking_1,
		@isauto_spositiontaking_2	=	 @isauto_spositiontaking_2,
		@isauto_spositiontaking_3	=	 @isauto_spositiontaking_3,
		@isauto_spositiontaking_4	=	 @isauto_spositiontaking_4,
		@isauto_spositiontaking_5	=	 @isauto_spositiontaking_5,
		@isauto_spositiontaking_6	=	 @isauto_spositiontaking_6,
		@isauto_spositiontaking_7	=	 @isauto_spositiontaking_7,
		@isauto_spositiontaking_8	=	 @isauto_spositiontaking_8,
		@isauto_spositiontaking_9	=	 @isauto_spositiontaking_9,
		@isauto_spositiontaking_10	=	 @isauto_spositiontaking_10,
		
		@isauto_slivepositiontaking_1	=	 @isauto_slivepositiontaking_1,
		@isauto_slivepositiontaking_3	=	 @isauto_slivepositiontaking_3,
		@isauto_slivepositiontaking_7	=	 @isauto_slivepositiontaking_7,
		@isauto_slivepositiontaking_8	=	 @isauto_slivepositiontaking_8,
		
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

EXEC dbo.Acc_CustomerUpdMaster_MaxPositiontaking_1
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
	
Select @LogSPData = '<Acc_CustomerUpdMaster_PositionTaking_1><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMaster_PositionTaking_1>' 


Select @TrackingValue2 = '<Acc_CustomerUpdMaster_PositionTaking_1><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@Old_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@Old_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@Old_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@Old_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@Old_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@Old_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@Old_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@Old_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@Old_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@Old_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@Old_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@Old_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@Old_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMaster_PositionTaking_1>' 

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_1] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_1] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_1] TO vnteam
 