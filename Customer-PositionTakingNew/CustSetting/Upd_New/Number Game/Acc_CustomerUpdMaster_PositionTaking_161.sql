 ALTER PROCEDURE [dbo].Acc_CustomerUpdMaster_PositionTaking_161
	@custid int,-- masterid	
	
	@v161spositiontaking_81 smallmoney,
	@v161spositiontaking_83 smallmoney,	
	@v161spositiontaking_86 smallmoney,
	@v161spositiontaking_88 smallmoney = 0,
	@v161slivepositiontaking_85 smallmoney,
	@v161slivepositiontaking_86 smallmoney,
	@v161slivepositiontaking_87 smallmoney,
	@v161slivepositiontaking_89 smallmoney = 0,
	@v161slivepositiontaking_90 smallmoney = 0,
	
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
	
	@v161mpositiontaking_81 smallmoney = 0.7,
	@v161mpositiontaking_83 smallmoney = 0.7,	
	@v161mpositiontaking_86 smallmoney = 0.7,
	@v161mpositiontaking_88 smallmoney = 0.7,
	@v161mlivepositiontaking_85 smallmoney = 0.7,
	@v161mlivepositiontaking_86 smallmoney = 0.7,
	@v161mlivepositiontaking_87 smallmoney = 0.7,
	@v161mlivepositiontaking_89 smallmoney = 0.7,
	@v161mlivepositiontaking_90 smallmoney = 0.7,
	
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
Task : Update Position Taking of Number Game for Master
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
	   @v161spositiontaking_81  <0
	or @v161spositiontaking_83  <0		
	or @v161spositiontaking_86  <0
	or @v161spositiontaking_88  <0
	or @v161slivepositiontaking_85  <0
	or @v161slivepositiontaking_86  <0
	or @v161slivepositiontaking_87  <0
	or @v161slivepositiontaking_89  <0
	or @v161slivepositiontaking_90  <0
	
	or @v161mpositiontaking_81  <0
	or @v161mpositiontaking_83  <0		
	or @v161mpositiontaking_86  <0
	or @v161mpositiontaking_88  <0
	or @v161mlivepositiontaking_85  <0
	or @v161mlivepositiontaking_86  <0
	or @v161mlivepositiontaking_87  <0
	or @v161mlivepositiontaking_89  <0
	or @v161mlivepositiontaking_90  <0
	
	or @v161spositiontaking_81 + @v161mpositiontaking_81 > 0.9
	or @v161spositiontaking_83 + @v161mpositiontaking_83 > 0.9		
	or @v161spositiontaking_86 + @v161mpositiontaking_86 > 0.9
	or @v161spositiontaking_88 + @v161mpositiontaking_88 > 0.9
	or @v161slivepositiontaking_85 + @v161mlivepositiontaking_85 > 0.9
	or @v161slivepositiontaking_86 + @v161mlivepositiontaking_86 > 0.9
	or @v161slivepositiontaking_87 + @v161mlivepositiontaking_87 > 0.9
	or @v161slivepositiontaking_89 + @v161mlivepositiontaking_89 > 0.9
	or @v161slivepositiontaking_90 + @v161mlivepositiontaking_90 > 0.9

	or @auto_v161spositiontaking_81  < 0
	or @auto_v161spositiontaking_83  < 0		
	or @auto_v161spositiontaking_86  < 0
	or @auto_v161spositiontaking_88  < 0
	or @auto_v161slivepositiontaking_85  < 0
	or @auto_v161slivepositiontaking_86  < 0
	or @auto_v161slivepositiontaking_87  < 0
	or @auto_v161slivepositiontaking_89  < 0
	or @auto_v161slivepositiontaking_90  < 0
	
	or @auto_v161spositiontaking_81  > 0.9
	or @auto_v161spositiontaking_83  > 0.9		
	or @auto_v161spositiontaking_86  > 0.9
	or @auto_v161spositiontaking_88  > 0.9
	or @auto_v161slivepositiontaking_85  > 0.9
	or @auto_v161slivepositiontaking_86  > 0.9
	or @auto_v161slivepositiontaking_87  > 0.9
	or @auto_v161slivepositiontaking_89  > 0.9
	or @auto_v161slivepositiontaking_90  > 0.9
BEGIN
	select @ErrCode = 207
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong position taking (for Number Game).'
						when 'CS' then N'占成数不正确(供数字游戏).'
						when 'CT' then N'佔成數不正確(供數字游戲).'
						when 'TH' then N'การกำหนดจำนวนเงินไม่ถูกต้อง (สำหรับเกมหมายเลข).'
						when 'J' then N'Wrong position taking (for Number Game).'
						when 'KO' then N'거래 조건이 잘못 되었습니다 (for Number Game).'
						else N'Wrong position taking (for Number Game).'
				end
	return
END

select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
+ case when b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
from 
	custoverride3rd as co with (NOLOCK) 
	inner join
	(
				 	select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking,  0 as auto_slivepositiontaking	
		union all 	select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
		union all 	select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
		union all 	select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
		union all 	select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
		union all 	select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @srecommend and (	
		((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
		(b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking)) or 
		((b.bettype in (85,86,87,89,90) and b.isauto_slivepositiontaking=0) and (b.slivepositiontaking+b.mlivepositiontaking>co.maxlivepositiontaking or b.slivepositiontaking+b.mlivepositiontaking<co.minlivepositiontaking)) or
		((b.bettype in (85,86,87,89,90) and b.isauto_slivepositiontaking>0) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking + b.auto_slivepositiontaking<co.minlivepositiontaking))
		)
if @ErrType <>''
BEGIN
	select @ErrCode = 208
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
+ case when b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
from 
	custoverride3rd as co with (NOLOCK) 
	inner join
	(
					select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking,  0 as auto_slivepositiontaking	
		union all 	select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 83 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
		union all 	select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
		union all 	select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
		union all 	select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
		union all 	select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and (	
		(b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) or 
		(b.bettype in (85,86,87,89,90) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
				)
if @ErrType <>''
BEGIN
	select @ErrCode = 209
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
	inner join custsetting3rd as cs3 with (NOLOCK) on c.custid = cs3.custid
	inner join (											  
					  select 161 as sporttype, 81 as bettype, @v161mpositiontaking_81 as maxpositiontaking, 0 as maxlivepositiontaking
			union all select 161 as sporttype, 83 as bettype, @v161mpositiontaking_83 as maxpositiontaking, 0 as maxlivepositiontaking
			union all select 161 as sporttype, 88 as bettype, @v161mpositiontaking_88 as maxpositiontaking, 0 as maxlivepositiontaking
			union all select 161 as sporttype, 85 as bettype, 0 as maxpositiontaking, @v161mlivepositiontaking_85 as maxlivepositiontaking
			union all select 161 as sporttype, 86 as bettype, @v161mpositiontaking_86 as maxpositiontaking, @v161mlivepositiontaking_86 as maxlivepositiontaking
			union all select 161 as sporttype, 87 as bettype, 0 as maxpositiontaking, @v161mlivepositiontaking_87 as maxlivepositiontaking
			union all select 161 as sporttype, 89 as bettype, 0 as maxpositiontaking, @v161mlivepositiontaking_89 as maxlivepositiontaking
			union all select 161 as sporttype, 90 as bettype, 0 as maxpositiontaking, @v161mlivepositiontaking_90 as maxlivepositiontaking
		) as b on cs3.sporttype=b.sporttype and cs3.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 
		and (cs3.apositiontaking+cs3.mpositiontaking>b.maxpositiontaking or (b.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking>b.maxlivepositiontaking))
group by username

if @ErrAcc<>''
BEGIN
	select @ErrCode = 210
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Number Game).'
						--when 'E' then 'Existing agents exceeded new master position taking <br> ' +@ErrAcc
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (供数字游戏).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (供數字游戲).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับเกมหมายเลข).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Number Game).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (for Number Game).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Number Game).'
				end
	return
END

--a1+m1<=m3
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					  select 	161 as sporttype, 81 as bettype, @v161mpositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161mpositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161mpositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_85 as maxlivepositiontaking
			union all select	161 as sporttype, 86 as bettype, @v161mpositiontaking_86 as maxpositiontaking,  @v161mlivepositiontaking_86 as maxlivepositiontaking
			union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_90 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 1 
		and (cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking or (b.bettype in (85,86,87,89,90) and cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking))
group by username

if @ErrAcc<>''
BEGIN
	select @ErrCode = 211
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') (for Number Game).'
						when 'CS' then N'现有会员超出新总代理占成数设定 ('+@ErrAcc+ N') (供数字游戏).'
						when 'CT' then N'現有會員超出新總代理佔成數設定 ('+@ErrAcc+ N') (供數字游戲).'
						when 'TH' then N'สมาชิกที่มีอยู่ในขณะนี้เกินกว่า จำนวนตัวแทนหลักรายใหม่ กำหนดไว้('+@ErrAcc+ N')(สำหรับเกมหมายเลข).'
						when 'J' then N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Number Game).'
						when 'KO' then N'회원의 거래조건 설정 범위를 넘어섰습니다 ('+@ErrAcc+ N') (for Number Game).'
						else N'Existing members exceeded new master position taking ('+@ErrAcc+ N') (for Number Game).'
				end
	return
END

--check m3<=m4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
+ case when b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting3rd as scs with (NOLOCK) inner join
	(
					select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking,  0 as auto_slivepositiontaking	
		union all 	select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking,  0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking,  0 as auto_slivepositiontaking
		union all 	select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
		union all 	select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
		union all 	select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
		union all 	select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
		union all 	select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
	) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where scs.custid = @srecommend and (
		scs.mpositiontaking<b.mpositiontaking or (b.bettype in (85,86,87,89,90) and scs.mlivepositiontaking<b.mlivepositiontaking)
		)

if @ErrType <>''
BEGIN
	select @ErrCode = 212
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
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					  select 	161 as sporttype, 81 as bettype, @v161mpositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161mpositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161mpositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_85 as maxlivepositiontaking
			union all select 	161 as sporttype, 86 as bettype, @v161mpositiontaking_86 as maxpositiontaking,  @v161mlivepositiontaking_86 as maxlivepositiontaking
			union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_90 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.mrecommend = @custid and c.roleid = 2 
	and ((cs.autompositiontaking > b.maxpositiontaking and cs.isautompositiontaking = 1)
			or ((b.bettype in (85,86,87,89,90) and cs.autolivempositiontaking > b.maxlivepositiontaking) and cs.isautolivempositiontaking = 1)
		)
group by username

if @ErrAcc<>''
BEGIN
	select @ErrCode = 213
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Number Game).'
						when 'CS' then N'现有代理超出新总代理占成数设定 ('+@ErrAcc+ N') (供数字游戏).'
						when 'CT' then N'現有代理超出新總代理佔成數設定 ('+@ErrAcc+ N') (供數字游戲).'
						when 'TH' then N'ตัวแทนที่มีอยู่ขณะนี้เกินกว่าจำนวนตัวแทนหลักรายใหม่ ('+@ErrAcc+ N')(สำหรับเกมหมายเลข).'
						when 'J' then N'Existing agents exceeded new master position taking ('+@ErrAcc+ N') (for Number Game).'
						when 'KO' then N'에이전트의 거래조건 설정 법위를 넘어섰습니다 ('+@ErrAcc+ N') (for Number Game).'
						else N'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Number Game).'
				end
	return
END

declare 
	@Old_v161spositiontaking_81 smallmoney,
	@Old_v161spositiontaking_83 smallmoney,	
	@Old_v161spositiontaking_86 smallmoney,
	@Old_v161spositiontaking_88 smallmoney,
	@Old_v161slivepositiontaking_85 smallmoney,
	@Old_v161slivepositiontaking_86 smallmoney,
	@Old_v161slivepositiontaking_87 smallmoney,
	@Old_v161slivepositiontaking_89 smallmoney,
	@Old_v161slivepositiontaking_90 smallmoney,
	
	@Old_auto_v161spositiontaking_81 smallmoney ,
	@Old_auto_v161spositiontaking_83 smallmoney ,	
	@Old_auto_v161spositiontaking_86 smallmoney ,
	@Old_auto_v161spositiontaking_88 smallmoney ,
	@Old_auto_v161slivepositiontaking_85 smallmoney ,
	@Old_auto_v161slivepositiontaking_86 smallmoney ,
	@Old_auto_v161slivepositiontaking_87 smallmoney ,
	@Old_auto_v161slivepositiontaking_89 smallmoney ,
	@Old_auto_v161slivepositiontaking_90 smallmoney ,
	
	@Old_isauto_v161spositiontaking_81 bit,
	@Old_isauto_v161spositiontaking_83 bit,	
	@Old_isauto_v161spositiontaking_86 bit,
	@Old_isauto_v161spositiontaking_88 bit,
	@Old_isauto_v161slivepositiontaking_85 bit,
	@Old_isauto_v161slivepositiontaking_86 bit,
	@Old_isauto_v161slivepositiontaking_87 bit,
	@Old_isauto_v161slivepositiontaking_89 bit,
	@Old_isauto_v161slivepositiontaking_90 bit,
	
	@Old_v161mpositiontaking_81 smallmoney,
	@Old_v161mpositiontaking_83 smallmoney,	
	@Old_v161mpositiontaking_86 smallmoney,
	@Old_v161mpositiontaking_88 smallmoney,
	@Old_v161mlivepositiontaking_85 smallmoney,
	@Old_v161mlivepositiontaking_86 smallmoney,
	@Old_v161mlivepositiontaking_87 smallmoney,
	@Old_v161mlivepositiontaking_89 smallmoney,
	@Old_v161mlivepositiontaking_90 smallmoney
	
select @old_v161mpositiontaking_81 = mpositiontaking, @old_v161spositiontaking_81 = spositiontaking, @old_auto_v161spositiontaking_81 = autopositiontaking, @old_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
select @old_v161mpositiontaking_83 = mpositiontaking, @old_v161spositiontaking_83 = spositiontaking, @old_auto_v161spositiontaking_83 = autopositiontaking, @old_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
select @old_v161mpositiontaking_88 = mpositiontaking, @old_v161spositiontaking_88 = spositiontaking, @old_auto_v161spositiontaking_88 = autopositiontaking, @old_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
select @old_v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161slivepositiontaking_85 = slivepositiontaking, @old_auto_v161slivepositiontaking_85 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
select @old_v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161mpositiontaking_86 = mpositiontaking,@old_v161spositiontaking_86 = spositiontaking,@old_v161slivepositiontaking_86 = slivepositiontaking, @old_auto_v161spositiontaking_86 = autopositiontaking, @old_isauto_v161spositiontaking_86 = isautopositiontaking, @old_auto_v161slivepositiontaking_86 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
select @old_v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161slivepositiontaking_87 = slivepositiontaking, @old_auto_v161slivepositiontaking_87 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
select @old_v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161slivepositiontaking_89 = slivepositiontaking, @old_auto_v161slivepositiontaking_89 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
select @old_v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161slivepositiontaking_90 = slivepositiontaking, @old_auto_v161slivepositiontaking_90 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161
	
----------------------------------------------------------------------------
--check u3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
+ case when b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting3rd as cs with (NOLOCK) inner join
	(
					select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking, 0 as autolivepositiontaking			
		union all   select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking, 0 as autolivepositiontaking			
		union all   select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking, 0 as autolivepositiontaking			
		union all 	select 85 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_85 as autolivepositiontaking
		union all 	select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86 as autolivepositiontaking
		union all 	select 87 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_86 as autolivepositiontaking
		union all 	select 89 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_89 as autolivepositiontaking
		union all 	select 90 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_90 as autolivepositiontaking
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
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
+ case when b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
from custsetting3rd as cs with (NOLOCK) inner join
	(
					select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking
		union all	select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking	
		union all	select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking	
		union all	select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking	
		union all	select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking	
		union all	select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking	
		union all	select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking	
		union all	select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking	
	) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend
	and 
	((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking<b.spositiontaking+b.mpositiontaking)
		or (b.bettype in (85,86,87,89,90) and cs.slivepositiontaking<b.slivepositiontaking)
	)  

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
update custsetting3rd with(rowlock,updlock)
set spositiontaking = case sporttype when 161 then case bettype when 81 then @v161spositiontaking_81 when 83 then @v161spositiontaking_83 when 86 then @v161spositiontaking_86 when 88 then @v161spositiontaking_88 else spositiontaking end else spositiontaking end,
	slivepositiontaking = case sporttype when 161 then case bettype when 85 then @v161slivepositiontaking_85 when 86 then @v161slivepositiontaking_86 when 87 then @v161slivepositiontaking_87 when 89 then @v161slivepositiontaking_89 when 90 then @v161slivepositiontaking_90 else slivepositiontaking end else slivepositiontaking end,
	mpositiontaking = case sporttype when 161 then case bettype when 81 then @v161mpositiontaking_81 when 83 then @v161mpositiontaking_83 when 86 then @v161mpositiontaking_86 when 88 then @v161mpositiontaking_88 else mpositiontaking end else mpositiontaking end,
	mlivepositiontaking = case sporttype when 161 then case bettype when 85 then @v161mlivepositiontaking_85 when 86 then @v161mlivepositiontaking_86 when 87 then @v161mlivepositiontaking_87 when 89 then @v161mlivepositiontaking_89 when 90 then @v161mlivepositiontaking_90 else mlivepositiontaking end else mlivepositiontaking end 
where custid = @custid

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

EXEC dbo.Acc_CustomerUpdMaster_AutoPositiontaking_161
		@mrecommend=@custid, 
		@srecommend = @srecommend,

		@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81, 
		@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83, 		
		@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86, 
		@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88, 
		@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85, 
		@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86, 
		@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87, 
		@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89, 
		@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90, 
		
		@isauto_v161spositiontaking_81	=	 @isauto_v161spositiontaking_81,
		@isauto_v161spositiontaking_83	=	 @isauto_v161spositiontaking_83,		
		@isauto_v161spositiontaking_86	=	 @isauto_v161spositiontaking_86,
		@isauto_v161spositiontaking_88	=	 @isauto_v161spositiontaking_88,
		@isauto_v161slivepositiontaking_85	=	 @isauto_v161slivepositiontaking_85,
		@isauto_v161slivepositiontaking_86	=	 @isauto_v161slivepositiontaking_86,
		@isauto_v161slivepositiontaking_87	=	 @isauto_v161slivepositiontaking_87,
		@isauto_v161slivepositiontaking_89	=	 @isauto_v161slivepositiontaking_89,
		@isauto_v161slivepositiontaking_90	=	 @isauto_v161slivepositiontaking_90,

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

EXEC dbo.Acc_CustomerUpdMaster_MaxPositiontaking_161
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
	
Select @LogSPData = '<Acc_CustomerUpdMaster_PositionTaking_161><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<au a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<ia isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) +  '" />' +

'<m v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) +
'" /></Acc_CustomerUpdMaster_PositionTaking_161>' 


Select @TrackingValue2 = '<Acc_CustomerUpdMaster_PositionTaking_161><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<au a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<ia isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMaster_PositionTaking_161>' 

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_161] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_161] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_PositionTaking_161] TO vnteam
  