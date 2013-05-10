CREATE PROCEDURE [dbo].[Acc_CustomerUpdSuper_PositionTaking_161]
	@custid int,-- superid	
	
	@v161spositiontaking_81 smallmoney,
	@v161spositiontaking_83 smallmoney,
	--@v161spositiontaking_85 smallmoney,
	@v161spositiontaking_86 smallmoney,
	@v161spositiontaking_88 smallmoney = 0.9,
	
	@v161slivepositiontaking_85 smallmoney,
	@v161slivepositiontaking_86 smallmoney,
	@v161slivepositiontaking_87 smallmoney,
	@v161slivepositiontaking_89 smallmoney = 0.9,
	@v161slivepositiontaking_90 smallmoney = 0.9,
	
	@v161mpositiontaking_81 smallmoney = 0.7,
	@v161mpositiontaking_83 smallmoney = 0.7,
	--@v161mpositiontaking_85 smallmoney = 0.7,
	@v161mpositiontaking_86 smallmoney = 0.7,
	@v161mpositiontaking_88 smallmoney = 0.7,
	
	@v161mlivepositiontaking_85 smallmoney = 0.7,
	@v161mlivepositiontaking_86 smallmoney = 0.7,
	@v161mlivepositiontaking_87 smallmoney = 0.7,
	@v161mlivepositiontaking_89 smallmoney = 0.7,
	@v161mlivepositiontaking_90 smallmoney = 0.7,
	
	@v161apositiontaking_81 smallmoney = 0.7,
	@v161apositiontaking_83 smallmoney = 0.7,
	--@v161apositiontaking_85 smallmoney = 0.7,
	@v161apositiontaking_86 smallmoney = 0.7,
	@v161apositiontaking_88 smallmoney = 0.7,
	
	@v161alivepositiontaking_85 smallmoney = 0.7,
	@v161alivepositiontaking_86 smallmoney = 0.7,
	@v161alivepositiontaking_87 smallmoney = 0.7,
	@v161alivepositiontaking_89 smallmoney = 0.7,
	@v161alivepositiontaking_90 smallmoney = 0.7,
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120511@Elodie
Task : Update Super's PT of Number Game
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

if 
	   @v161spositiontaking_81 <0
	or @v161spositiontaking_83 <0
	--or @v161spositiontaking_85 <0
	or @v161spositiontaking_86 <0
	or @v161spositiontaking_88 <0
	
	or @v161slivepositiontaking_85 <0
	or @v161slivepositiontaking_86 <0
	or @v161slivepositiontaking_87 <0
	or @v161slivepositiontaking_89 <0
	or @v161slivepositiontaking_90 <0
	
	or @v161mpositiontaking_81 <0
	or @v161mpositiontaking_83 <0
	--or @v161mpositiontaking_85 <0
	or @v161mpositiontaking_86 <0
	or @v161mpositiontaking_88 <0
	
	or @v161mlivepositiontaking_85 <0
	or @v161mlivepositiontaking_86 <0
	or @v161mlivepositiontaking_87 <0
	or @v161mlivepositiontaking_89 <0
	or @v161mlivepositiontaking_90 <0
	
	or @v161apositiontaking_81 <0
	or @v161apositiontaking_83 <0
	--or @v161apositiontaking_85 <0
	or @v161apositiontaking_86 <0
	or @v161apositiontaking_88 <0
	
	or @v161alivepositiontaking_85 <0
	or @v161alivepositiontaking_86 <0	
	or @v161alivepositiontaking_87 <0
	or @v161alivepositiontaking_89 <0	
	or @v161alivepositiontaking_90 <0
	
	or @v161spositiontaking_81 >0.9
	or @v161spositiontaking_83 >0.9
	--or @v161spositiontaking_85 >0.9
	or @v161spositiontaking_86 >0.9
	or @v161spositiontaking_88 >0.9
	
	or @v161slivepositiontaking_85 >0.9
	or @v161slivepositiontaking_86 >0.9
	or @v161slivepositiontaking_87 >0.9
	or @v161slivepositiontaking_89 >0.9
	or @v161slivepositiontaking_90 >0.9
	
	or @v161mpositiontaking_81 >0.9
	or @v161mpositiontaking_83 >0.9
	--or @v161mpositiontaking_85 >0.9
	or @v161mpositiontaking_86 >0.9
	or @v161mpositiontaking_88 >0.9
	
	or @v161mlivepositiontaking_85 >0.9
	or @v161mlivepositiontaking_86 >0.9
	or @v161mlivepositiontaking_87 >0.9
	or @v161mlivepositiontaking_89 >0.9
	or @v161mlivepositiontaking_90 >0.9

	or @v161apositiontaking_81 >0.9
	or @v161apositiontaking_83 >0.9
	--or @v161apositiontaking_85 >0.9
	or @v161apositiontaking_86 >0.9
	or @v161apositiontaking_88 >0.9
	
	or @v161alivepositiontaking_85 >0.9
	or @v161alivepositiontaking_86 >0.9
	or @v161alivepositiontaking_87 >0.9
	or @v161alivepositiontaking_89 >0.9
	or @v161alivepositiontaking_90 >0.9
	
	or @v161spositiontaking_81 < @v161mpositiontaking_81
	or @v161spositiontaking_83 < @v161mpositiontaking_83
	--or @v161spositiontaking_85 < @v161mpositiontaking_85
	or @v161spositiontaking_86 < @v161mpositiontaking_86
	or @v161spositiontaking_88 < @v161mpositiontaking_88
	
	or @v161slivepositiontaking_85 < @v161mlivepositiontaking_85
	or @v161slivepositiontaking_86 < @v161mlivepositiontaking_86
	or @v161slivepositiontaking_87 < @v161mlivepositiontaking_87
	or @v161slivepositiontaking_89 < @v161mlivepositiontaking_89
	or @v161slivepositiontaking_90 < @v161mlivepositiontaking_90
	
	or @v161mpositiontaking_81 < @v161apositiontaking_81
	or @v161mpositiontaking_83 < @v161apositiontaking_83
	--or @v161mpositiontaking_85 < @v161apositiontaking_85
	or @v161mpositiontaking_86 < @v161apositiontaking_86
	or @v161mpositiontaking_88 < @v161apositiontaking_88
	
	or @v161mlivepositiontaking_85 < @v161alivepositiontaking_85
	or @v161mlivepositiontaking_86 < @v161alivepositiontaking_86
	or @v161mlivepositiontaking_87 < @v161alivepositiontaking_87
	or @v161mlivepositiontaking_89 < @v161alivepositiontaking_89
	or @v161mlivepositiontaking_90 < @v161alivepositiontaking_90
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

declare @Old_v161spositiontaking_81 smallmoney,
		@Old_v161spositiontaking_83 smallmoney,
		--@Old_v161spositiontaking_85 smallmoney,
		@Old_v161spositiontaking_86 smallmoney,
		@Old_v161spositiontaking_88 smallmoney,
		
		@Old_v161slivepositiontaking_85 smallmoney,
		@Old_v161slivepositiontaking_86 smallmoney,
		@Old_v161slivepositiontaking_87 smallmoney,
		@Old_v161slivepositiontaking_89 smallmoney,
		@Old_v161slivepositiontaking_90 smallmoney,
		
		@Old_v161mpositiontaking_81 smallmoney,
		@Old_v161mpositiontaking_83 smallmoney,
		--@Old_v161mpositiontaking_85 smallmoney,
		@Old_v161mpositiontaking_86 smallmoney,
		@Old_v161mpositiontaking_88 smallmoney,
		
		@Old_v161mlivepositiontaking_85 smallmoney,
		@Old_v161mlivepositiontaking_86 smallmoney,
		@Old_v161mlivepositiontaking_87 smallmoney,
		@Old_v161mlivepositiontaking_89 smallmoney,
		@Old_v161mlivepositiontaking_90 smallmoney,
		
		@Old_v161apositiontaking_81 smallmoney,
		@Old_v161apositiontaking_83 smallmoney,
		--@Old_v161apositiontaking_85 smallmoney,
		@Old_v161apositiontaking_86 smallmoney,
		@Old_v161apositiontaking_88 smallmoney,
		
		@Old_v161alivepositiontaking_85 smallmoney,
		@Old_v161alivepositiontaking_86 smallmoney,
		@Old_v161alivepositiontaking_87 smallmoney,
		@Old_v161alivepositiontaking_89 smallmoney,
		@Old_v161alivepositiontaking_90 smallmoney
		
--select old data
select @Old_v161spositiontaking_81 = spositiontaking, @Old_v161mpositiontaking_81 = mpositiontaking, @Old_v161apositiontaking_81 = apositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=81 and sporttype=161
select @Old_v161spositiontaking_83 = spositiontaking, @Old_v161mpositiontaking_83 = mpositiontaking, @Old_v161apositiontaking_83 = apositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=83 and sporttype=161
select @Old_v161slivepositiontaking_85 = slivepositiontaking, @Old_v161mlivepositiontaking_85 = mlivepositiontaking, @Old_v161alivepositiontaking_85 = alivepositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=85 and sporttype=161
select @Old_v161spositiontaking_86 = spositiontaking, @Old_v161mpositiontaking_86 = mpositiontaking, @Old_v161apositiontaking_86 = apositiontaking, @Old_v161slivepositiontaking_86= slivepositiontaking, @Old_v161mlivepositiontaking_86= mlivepositiontaking, @Old_v161alivepositiontaking_86= alivepositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=86 and sporttype=161
select @Old_v161slivepositiontaking_87 = slivepositiontaking, @Old_v161mlivepositiontaking_87 = mlivepositiontaking, @Old_v161alivepositiontaking_87 = alivepositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=87 and sporttype=161
select @Old_v161spositiontaking_88 = spositiontaking, @Old_v161mpositiontaking_88 = mpositiontaking, @Old_v161apositiontaking_88 = apositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=88 and sporttype=161
select @Old_v161slivepositiontaking_89 = slivepositiontaking, @Old_v161mlivepositiontaking_89 = mlivepositiontaking, @Old_v161alivepositiontaking_89 = alivepositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=89 and sporttype=161
select @Old_v161slivepositiontaking_90 = slivepositiontaking, @Old_v161mlivepositiontaking_90 = mlivepositiontaking, @Old_v161alivepositiontaking_90 = alivepositiontaking from custsetting3rd with (nolock) where custid=@custid and bettype=90 and sporttype=161

--check n4<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MinLive: '+ cast((co.minlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride3rd as co with (NOLOCK) 
	inner join
	(
		        select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking
	union all 	select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking
	union all 	select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking
	union all 	select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking
	union all 	select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking
	union all 	select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking
	union all 	select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking
	union all 	select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and (	
					(b.spositiontaking<co.minpositiontaking) or 
					(b.sporttype = 161 and b.bettype in (85,86,87,89,90) and (b.slivepositiontaking<co.minlivepositiontaking))
				)
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
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					  select 	161 as sporttype, 81 as bettype, @v161spositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161spositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_85 as maxlivepositiontaking
			union all select 	161 as sporttype, 86 as bettype, @v161spositiontaking_86 as maxpositiontaking,  @v161slivepositiontaking_86 as maxlivepositiontaking
			union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161spositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_90 as maxlivepositiontaking
			
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 3 and (
						((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) or 
						((b.sporttype=161) and (b.bettype in (85,86,87,89,90)) and (cs.isautolivepositiontaking=0) and (cs.slivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking)) or
						((b.sporttype=161) and (b.bettype in (85,86,87,89,90)) and (cs.isautolivepositiontaking=1) and (cs.mlivepositiontaking>b.maxlivepositiontaking)) or
						((b.sporttype=161) and (b.bettype in (85,86,87,89,90)) and (cs.isautolivepositiontaking=1) and (cs.autolivepositiontaking>b.maxlivepositiontaking))						
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
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
			          select 	161 as sporttype, 81 as bettype, @v161spositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161spositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_85 as maxlivepositiontaking
			union all select 	161 as sporttype, 86 as bettype, @v161spositiontaking_86 as maxpositiontaking,  @v161slivepositiontaking_86 as maxlivepositiontaking
			union all select	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161spositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161slivepositiontaking_90 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and (
			(cs.spositiontaking+cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking) or 
			(b.sporttype=161 and b.bettype in (85,86,87,89,90) and cs.slivepositiontaking+ cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking) or
			(cs.isautopositiontaking=1 and cs.autopositiontaking>b.maxpositiontaking) or 
			(cs.isautolivepositiontaking=1 and b.sporttype=161 and b.bettype in (85,86,87,89,90) and cs.autolivepositiontaking>b.maxlivepositiontaking)
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
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
			          select 	161 as sporttype, 81 as bettype, @v161mpositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161mpositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_85 as maxlivepositiontaking
			union all select 	161 as sporttype, 86 as bettype, @v161mpositiontaking_86 as maxpositiontaking,  @v161mlivepositiontaking_86 as maxlivepositiontaking						
			union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161mpositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161mlivepositiontaking_90 as maxlivepositiontaking
			) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and (
			(cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking) 
			or 
			(b.sporttype=161 and b.bettype in (85,86,87,89,90) and cs.mlivepositiontaking+ cs.alivepositiontaking>b.maxlivepositiontaking)   
			)
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
	inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
			          select 	161 as sporttype, 81 as bettype, @v161apositiontaking_81 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 83 as bettype, @v161apositiontaking_83 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 85 as bettype, 0 as maxpositiontaking,  @v161alivepositiontaking_85 as maxlivepositiontaking
			union all select 	161 as sporttype, 86 as bettype, @v161apositiontaking_86 as maxpositiontaking,  @v161alivepositiontaking_86 as maxlivepositiontaking
			union all select 	161 as sporttype, 87 as bettype, 0 as maxpositiontaking,  @v161alivepositiontaking_87 as maxlivepositiontaking
			union all select 	161 as sporttype, 88 as bettype, @v161apositiontaking_88 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	161 as sporttype, 89 as bettype, 0 as maxpositiontaking,  @v161alivepositiontaking_89 as maxlivepositiontaking
			union all select 	161 as sporttype, 90 as bettype, 0 as maxpositiontaking,  @v161alivepositiontaking_90 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and (
				(cs.apositiontaking>b.maxpositiontaking)   
				or 
				(b.sporttype=161 and b.bettype in (85,86,87,89,90) and cs.alivepositiontaking > b.maxlivepositiontaking)   
			)
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
update custsetting3rd with (ROWLOCK, UPDLOCK)
set
	spositiontaking = case bettype when 81 then @v161spositiontaking_81 when 83 then @v161spositiontaking_83 when 86 then @v161spositiontaking_86 when 88 then @v161spositiontaking_88 else 0 end,
					
	slivepositiontaking = case bettype when 85 then @v161slivepositiontaking_85 when 86 then @v161slivepositiontaking_86 when 87 then @v161slivepositiontaking_87 when 89 then @v161slivepositiontaking_89 when 90 then @v161slivepositiontaking_90 else 0 end ,
	
	mpositiontaking = case bettype when 81 then @v161mpositiontaking_81 when 83 then @v161mpositiontaking_83 when 86 then @v161mpositiontaking_86 when 88 then @v161mpositiontaking_88 else 0 end,
	
	mlivepositiontaking =  case bettype when 85 then @v161mlivepositiontaking_85 when 86 then @v161mlivepositiontaking_86 when 87 then @v161mlivepositiontaking_87 when 89 then @v161mlivepositiontaking_89 when 90 then @v161mlivepositiontaking_90 else 0 end,
	
	apositiontaking = case bettype when 81 then @v161apositiontaking_81 when 83 then @v161apositiontaking_83 when 86 then @v161apositiontaking_86 when 88 then @v161apositiontaking_88 else 0 end,
	
	alivepositiontaking = case bettype when 85 then @v161alivepositiontaking_85 when 86 then @v161alivepositiontaking_86 when 87 then @v161alivepositiontaking_87 when 89 then @v161alivepositiontaking_89 when 90 then @v161alivepositiontaking_90 else 0 end	
where custid=@custid and sporttype = 161
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

exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking_161 @srecommend = @custid
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
EXEC dbo.Acc_CustoverrideUpd_161
		@custid = @custid,
		
		@minv161positiontaking_81 = 0,
		@minv161positiontaking_83 = 0,
		--@minv161positiontaking_85 = 0,
		@minv161positiontaking_86 = 0,
		@minv161positiontaking_88 = 0,
		
		@minv161livepositiontaking_85 = 0,
		@minv161livepositiontaking_86 = 0,
		@minv161livepositiontaking_87 = 0,
		@minv161livepositiontaking_89 = 0,
		@minv161livepositiontaking_90 = 0,
		
		@maxv161positiontaking_81 = @v161spositiontaking_81,
		@maxv161positiontaking_83 = @v161spositiontaking_83,
		--@maxv161positiontaking_85 = @v161spositiontaking_85,
		@maxv161positiontaking_86 = @v161spositiontaking_86,
		@maxv161positiontaking_88 = @v161spositiontaking_88,
		
		@maxv161livepositiontaking_85 = @v161slivepositiontaking_85,
		@maxv161livepositiontaking_86 = @v161slivepositiontaking_86,
		@maxv161livepositiontaking_87 = @v161slivepositiontaking_87,
		@maxv161livepositiontaking_89 = @v161slivepositiontaking_89,
		@maxv161livepositiontaking_90 = @v161slivepositiontaking_90,
		
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

Select @LogSPData = '<Acc_CustomerUpdSuper_PositionTaking_161><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161spt_85="'+ coalesce(cast(@v161spositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +


'<ag v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_161>'


Select @TrackingValue2 = '<Acc_CustomerUpdSuper_PositionTaking_161><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161spt_85="'+ coalesce(cast(@Old_v161spositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161mpt_85="'+ coalesce(cast(@Old_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +


'<ag v161apt_81="'+ coalesce(cast(@Old_v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@Old_v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161apt_85="'+ coalesce(cast(@Old_v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@Old_v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@Old_v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161alivept_85="'+ coalesce(cast(@Old_v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@Old_v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@Old_v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@Old_v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@Old_v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_161>'

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_161] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_161] TO vnteam
 