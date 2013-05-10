ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_PositionTaking_1]
	@custid int,-- superid	
	
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
	
	@apositiontaking_1 smallmoney = 0.7,
	@apositiontaking_2 smallmoney = 0.7,
	@apositiontaking_3 smallmoney = 0.7,
	@apositiontaking_4 smallmoney = 0.7,
	@apositiontaking_5 smallmoney = 0.7,
	@apositiontaking_6 smallmoney = 0.7,
	@apositiontaking_7 smallmoney = 0.7,
	@apositiontaking_8 smallmoney = 0.7,
	@apositiontaking_9 smallmoney = 0.7,
	@apositiontaking_10 smallmoney = 0.7,
	
	@alivepositiontaking_1 smallmoney = 0.7,
	@alivepositiontaking_3 smallmoney = 0.7,
	@alivepositiontaking_7 smallmoney = 0.7,
	@alivepositiontaking_8 smallmoney = 0.7,
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120510@Elodie
Task : Update Super's PT of Soccer
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
	
	or @apositiontaking_1  <0
	or @apositiontaking_2  <0
	or @apositiontaking_3  <0
	or @apositiontaking_4  <0
	or @apositiontaking_5  <0
	or @apositiontaking_6  <0
	or @apositiontaking_7  <0
	or @apositiontaking_8  <0
	or @apositiontaking_9  <0
	or @apositiontaking_10 <0
	
	or @alivepositiontaking_1  <0
	or @alivepositiontaking_3  <0
	or @alivepositiontaking_7  <0
	or @alivepositiontaking_8  <0
	
	or @spositiontaking_1  >0.9
	or @spositiontaking_2  >0.9
	or @spositiontaking_3  >0.9
	or @spositiontaking_4  >0.9
	or @spositiontaking_5  >0.9
	or @spositiontaking_6  >0.9
	or @spositiontaking_7  >0.9
	or @spositiontaking_8  >0.9
	or @spositiontaking_9  >0.9
	or @spositiontaking_10 >0.9
	
	or @slivepositiontaking_1  >0.9
	or @slivepositiontaking_3  >0.9
	or @slivepositiontaking_7  >0.9
	or @slivepositiontaking_8  >0.9
	
	or @mpositiontaking_1  >0.9
	or @mpositiontaking_2  >0.9
	or @mpositiontaking_3  >0.9
	or @mpositiontaking_4  >0.9
	or @mpositiontaking_5  >0.9
	or @mpositiontaking_6  >0.9
	or @mpositiontaking_7  >0.9
	or @mpositiontaking_8  >0.9
	or @mpositiontaking_9  >0.9
	or @mpositiontaking_10 >0.9
	
	or @mlivepositiontaking_1  >0.9
	or @mlivepositiontaking_3  >0.9
	or @mlivepositiontaking_7  >0.9
	or @mlivepositiontaking_8  >0.9
	
	or @apositiontaking_1  >0.9
	or @apositiontaking_2  >0.9
	or @apositiontaking_3  >0.9
	or @apositiontaking_4  >0.9
	or @apositiontaking_5  >0.9
	or @apositiontaking_6  >0.9
	or @apositiontaking_7  >0.9
	or @apositiontaking_8  >0.9
	or @apositiontaking_9  >0.9
	or @apositiontaking_10 >0.9

	or @alivepositiontaking_1  >0.9
	or @alivepositiontaking_3  >0.9
	or @alivepositiontaking_7  >0.9
	or @alivepositiontaking_8  >0.9
	
	or @spositiontaking_1   <  @mpositiontaking_1  
	or @spositiontaking_2   <  @mpositiontaking_2  
	or @spositiontaking_3   <  @mpositiontaking_3  
	or @spositiontaking_4   <  @mpositiontaking_4  
	or @spositiontaking_5   <  @mpositiontaking_5  
	or @spositiontaking_6   <  @mpositiontaking_6  
	or @spositiontaking_7   <  @mpositiontaking_7  
	or @spositiontaking_8   <  @mpositiontaking_8  
	or @spositiontaking_9   <  @mpositiontaking_9  
	or @spositiontaking_10  <  @mpositiontaking_10 
	or @slivepositiontaking_1   <  @mlivepositiontaking_1  
	or @slivepositiontaking_3   <  @mlivepositiontaking_3
	or @slivepositiontaking_7   <  @mlivepositiontaking_7  
	or @slivepositiontaking_8   <  @mlivepositiontaking_8
	 
	or @mpositiontaking_1	< @apositiontaking_1  
	or @mpositiontaking_2   <  @apositiontaking_2  
	or @mpositiontaking_3   <  @apositiontaking_3  
	or @mpositiontaking_4   <  @apositiontaking_4  
	or @mpositiontaking_5   <  @apositiontaking_5  
	or @mpositiontaking_6   <  @apositiontaking_6  
	or @mpositiontaking_7   <  @apositiontaking_7  
	or @mpositiontaking_8   <  @apositiontaking_8  
	or @mpositiontaking_9   <  @apositiontaking_9  
	or @mpositiontaking_10  <  @apositiontaking_10 
	or @mlivepositiontaking_1   <  @alivepositiontaking_1  
	or @mlivepositiontaking_3   <  @alivepositiontaking_3  
	or @mlivepositiontaking_7   <  @alivepositiontaking_7  
	or @mlivepositiontaking_8   <  @alivepositiontaking_8 	
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

declare @Old_spositiontaking_1 smallmoney,
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
		@Old_mlivepositiontaking_8 smallmoney,
		
		@Old_apositiontaking_1 smallmoney,
		@Old_apositiontaking_2 smallmoney,
		@Old_apositiontaking_3 smallmoney,
		@Old_apositiontaking_4 smallmoney,
		@Old_apositiontaking_5 smallmoney,
		@Old_apositiontaking_6 smallmoney,
		@Old_apositiontaking_7 smallmoney,
		@Old_apositiontaking_8 smallmoney,
		@Old_apositiontaking_9 smallmoney,
		@Old_apositiontaking_10 smallmoney,
		
		@Old_alivepositiontaking_1 smallmoney,
		@Old_alivepositiontaking_3 smallmoney,
		@Old_alivepositiontaking_7 smallmoney,
		@Old_alivepositiontaking_8 smallmoney
	
select @Old_spositiontaking_1= spositiontaking, @Old_mpositiontaking_1= mpositiontaking, @Old_apositiontaking_1= apositiontaking,
	@Old_slivepositiontaking_1= slivepositiontaking, @Old_mlivepositiontaking_1= mlivepositiontaking, @Old_alivepositiontaking_1= alivepositiontaking
from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=1

select @Old_spositiontaking_3= spositiontaking, @Old_mpositiontaking_3= mpositiontaking, @Old_apositiontaking_3= apositiontaking, 
	@Old_slivepositiontaking_3= slivepositiontaking, @Old_mlivepositiontaking_3= mlivepositiontaking, @Old_alivepositiontaking_3= alivepositiontaking
from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=1

select @Old_spositiontaking_7= spositiontaking, @Old_mpositiontaking_7= mpositiontaking, @Old_apositiontaking_7= apositiontaking, 
	@Old_slivepositiontaking_7= slivepositiontaking, @Old_mlivepositiontaking_7= mlivepositiontaking, @Old_alivepositiontaking_7= alivepositiontaking
from custsetting with (nolock) where custid=@custid and bettype=7 and sporttype=1

select @Old_spositiontaking_8= spositiontaking, @Old_mpositiontaking_8= mpositiontaking, @Old_apositiontaking_8= apositiontaking, 
	@Old_slivepositiontaking_8= slivepositiontaking, @Old_mlivepositiontaking_8= mlivepositiontaking, @Old_alivepositiontaking_8= alivepositiontaking
from custsetting with (nolock) where custid=@custid and bettype=8 and sporttype=1

select @Old_spositiontaking_2= spositiontaking, @Old_mpositiontaking_2= mpositiontaking, @Old_apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=1
select @Old_spositiontaking_4= spositiontaking, @Old_mpositiontaking_4= mpositiontaking, @Old_apositiontaking_4= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=4 and sporttype=1
select @Old_spositiontaking_5= spositiontaking, @Old_mpositiontaking_5= mpositiontaking, @Old_apositiontaking_5= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=5 and sporttype=1
select @Old_spositiontaking_6= spositiontaking, @Old_mpositiontaking_6= mpositiontaking, @Old_apositiontaking_6= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=6 and sporttype=1
select @Old_spositiontaking_9= spositiontaking, @Old_mpositiontaking_9= mpositiontaking, @Old_apositiontaking_9= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9 and sporttype=1
select @Old_spositiontaking_10= spositiontaking, @Old_mpositiontaking_10= mpositiontaking, @Old_apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=1

--check n4<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))
	+ case when b.bettype in (1,3,7,8) then '-MinLive: '+ cast((co.minlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) 
	inner join
	(
					select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking
		union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking
		union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking
		union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking
		union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
		union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking
		union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking
		union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking
		union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking
		union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking		
	) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
	inner join sports with (nolock) on b.sporttype = sports.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @custid and (	
					(b.spositiontaking<co.minpositiontaking) or 
					(b.bettype in (1,3,7,8) and (b.slivepositiontaking<co.minlivepositiontaking))
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
	inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
	inner join (

					  select 	1 as sporttype, 1 as bettype, @spositiontaking_1 as maxpositiontaking,  @slivepositiontaking_1 as maxlivepositiontaking
			union all select 	1 as sporttype, 2 as bettype, @spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 3 as bettype, @spositiontaking_3 as maxpositiontaking,  @slivepositiontaking_3 as maxlivepositiontaking
			union all select 	1 as sporttype, 4 as bettype, @spositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 5 as bettype, @spositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 6 as bettype, @spositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 7 as bettype, @spositiontaking_7 as maxpositiontaking,  @slivepositiontaking_7 as maxlivepositiontaking
			union all select 	1 as sporttype, 8 as bettype, @spositiontaking_8 as maxpositiontaking,  @slivepositiontaking_8 as maxlivepositiontaking
			union all select 	1 as sporttype, 9 as bettype, @spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 10 as bettype, @spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 3 and (
						((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
						((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) or 
						((b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=0) and (cs.slivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking)) or
						((b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=1) and (cs.mlivepositiontaking>b.maxlivepositiontaking)) or
						((b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=1) and (cs.autolivepositiontaking>b.maxlivepositiontaking))						
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
	inner join (

					  select 	1 as sporttype, 1 as bettype, @spositiontaking_1 as maxpositiontaking,  @slivepositiontaking_1 as maxlivepositiontaking
			union all select 	1 as sporttype, 2 as bettype, @spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 3 as bettype, @spositiontaking_3 as maxpositiontaking,  @slivepositiontaking_3 as maxlivepositiontaking
			union all select 	1 as sporttype, 4 as bettype, @spositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 5 as bettype, @spositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 6 as bettype, @spositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 7 as bettype, @spositiontaking_7 as maxpositiontaking,  @slivepositiontaking_7 as maxlivepositiontaking
			union all select 	1 as sporttype, 8 as bettype, @spositiontaking_8 as maxpositiontaking,  @slivepositiontaking_8 as maxlivepositiontaking
			union all select 	1 as sporttype, 9 as bettype, @spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 10 as bettype, @spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and (
			(cs.spositiontaking+cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking) or 
			(b.bettype in (1,3,7,8) and cs.slivepositiontaking+ cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking) or
			(cs.isautopositiontaking=1 and cs.autopositiontaking>b.maxpositiontaking) or 
			(cs.isautolivepositiontaking=1 and b.bettype in (1,3,7,8) and cs.autolivepositiontaking>b.maxlivepositiontaking)
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
where c.srecommend = @custid and c.roleid = 1 and (
			(cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking) 
			or 
			(b.bettype in (1,3,7,8) and cs.mlivepositiontaking+ cs.alivepositiontaking>b.maxlivepositiontaking)   
			)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = @UserName + ': '+
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
	inner join (
				      select 	1 as sporttype, 1 as bettype, @apositiontaking_1 as maxpositiontaking,  @alivepositiontaking_1 as maxlivepositiontaking
			union all select 	1 as sporttype, 2 as bettype, @apositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 3 as bettype, @apositiontaking_3 as maxpositiontaking,  @alivepositiontaking_3 as maxlivepositiontaking
			union all select 	1 as sporttype, 4 as bettype, @apositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 5 as bettype, @apositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 6 as bettype, @apositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 7 as bettype, @apositiontaking_7 as maxpositiontaking,  @alivepositiontaking_7 as maxlivepositiontaking
			union all select 	1 as sporttype, 8 as bettype, @apositiontaking_8 as maxpositiontaking,  @alivepositiontaking_8 as maxlivepositiontaking
			union all select 	1 as sporttype, 9 as bettype, @apositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
			union all select 	1 as sporttype, 10 as bettype, @apositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid and c.roleid = 1 and (
				(cs.apositiontaking>b.maxpositiontaking)   
				or 
				(b.bettype in (1,3,7,8) and cs.alivepositiontaking > b.maxlivepositiontaking)   
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
update custsetting with (ROWLOCK, UPDLOCK)
set
	spositiontaking = case sporttype when 1 then case bettype when 1 then @spositiontaking_1 when 2 then @spositiontaking_2 when 3 then @spositiontaking_3 when 4 then @spositiontaking_4 when 5 then @spositiontaking_5 when 6 then @spositiontaking_6 when 7 then @spositiontaking_7 when 8 then @spositiontaking_8 when 9 then @spositiontaking_9  when 10 then @spositiontaking_10 else 0 end					
					else spositiontaking end,
	slivepositiontaking = case sporttype when 1 then case bettype when 1 then @slivepositiontaking_1 when 3 then @slivepositiontaking_3 when 7 then @slivepositiontaking_7 when 8 then @slivepositiontaking_8 else slivepositiontaking end else slivepositiontaking end,
	
	mpositiontaking = case sporttype when 1 then case bettype when 1 then @mpositiontaking_1 when 2 then @mpositiontaking_2 when 3 then @mpositiontaking_3 when 4 then @mpositiontaking_4 when 5 then @mpositiontaking_5 when 6 then @mpositiontaking_6 when 7 then @mpositiontaking_7 when 8 then @mpositiontaking_8 when 9 then @mpositiontaking_9  when 10 then @mpositiontaking_10 else 0 end					
					else mpositiontaking end,	
	mlivepositiontaking = case sporttype when 1 then case bettype when 1 then @mlivepositiontaking_1 when 3 then @mlivepositiontaking_3 when 7 then @mlivepositiontaking_7 when 8 then @mlivepositiontaking_8 else mlivepositiontaking end else mlivepositiontaking end,

	apositiontaking = case sporttype when 1 then case bettype when 1 then @apositiontaking_1 when 2 then @apositiontaking_2 when 3 then @apositiontaking_3 when 4 then @apositiontaking_4 when 5 then @apositiontaking_5 when 6 then @apositiontaking_6 when 7 then @apositiontaking_7 when 8 then @apositiontaking_8 when 9 then @apositiontaking_9  when 10 then @apositiontaking_10 else 0 end					
					else apositiontaking end,	
	alivepositiontaking = case sporttype when 1 then case bettype when 1 then @alivepositiontaking_1 when 3 then @alivepositiontaking_3 when 7 then @alivepositiontaking_7 when 8 then @alivepositiontaking_8 else alivepositiontaking end else alivepositiontaking end	

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

exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking_1 @srecommend = @custid
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
EXEC dbo.Acc_CustoverrideUpd_1
		@custid = @custid,
		@minpositiontaking_1 = 0,
		@minpositiontaking_2 = 0,
		@minpositiontaking_3 = 0,
		@minpositiontaking_4 = 0,
		@minpositiontaking_5 = 0,
		@minpositiontaking_6 = 0,
		@minpositiontaking_7 = 0,
		@minpositiontaking_8 = 0,
		@minpositiontaking_9 = 0,
		@minpositiontaking_10 = 0,

		@minlivepositiontaking_1 = 0,
		@minlivepositiontaking_3 = 0,
		@minlivepositiontaking_7 = 0,
		@minlivepositiontaking_8 = 0,		
		
		@maxpositiontaking_1 = @spositiontaking_1,
		@maxpositiontaking_2 = @spositiontaking_2,
		@maxpositiontaking_3 = @spositiontaking_3,
		@maxpositiontaking_4 = @spositiontaking_4,
		@maxpositiontaking_5 = @spositiontaking_5,
		@maxpositiontaking_6 = @spositiontaking_6,
		@maxpositiontaking_7 = @spositiontaking_7,
		@maxpositiontaking_8 = @spositiontaking_8,
		@maxpositiontaking_9 = @spositiontaking_9,
		@maxpositiontaking_10 = @spositiontaking_10,

		@maxlivepositiontaking_1 = @slivepositiontaking_1,
		@maxlivepositiontaking_3 = @slivepositiontaking_3,
		@maxlivepositiontaking_7 = @slivepositiontaking_7,
		@maxlivepositiontaking_8 = @slivepositiontaking_8,
		
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

Select @LogSPData = '<Acc_CustomerUpdSuper_PositionTaking_1><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

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
'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'<ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_1>'


Select @TrackingValue2 = '<Acc_CustomerUpdSuper_PositionTaking_1><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

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
'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'<ag apt_1="'+ coalesce(cast(@Old_apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@Old_apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@Old_apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@Old_apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@Old_apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@Old_apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@Old_apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@Old_apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@Old_apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@Old_apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@Old_alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@Old_alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@Old_alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@Old_alivepositiontaking_8 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking_1>'

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_1] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_PositionTaking_1] TO vnteam
