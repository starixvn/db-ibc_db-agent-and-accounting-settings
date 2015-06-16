ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_1] 
	@CustID INT,--memberid
	@UserID int,

	@spositiontaking_1 SMALLMONEY OUTPUT,
	@spositiontaking_2 SMALLMONEY OUTPUT,
	@spositiontaking_3 SMALLMONEY OUTPUT,
	@spositiontaking_4 SMALLMONEY OUTPUT,
	@spositiontaking_5 SMALLMONEY OUTPUT,
	@spositiontaking_6 SMALLMONEY OUTPUT,
	@spositiontaking_7 SMALLMONEY OUTPUT,
	@spositiontaking_8 SMALLMONEY OUTPUT,
	@spositiontaking_9 SMALLMONEY OUTPUT,
	@spositiontaking_10 SMALLMONEY OUTPUT,
	
	@slivepositiontaking_1 SMALLMONEY OUTPUT,
	@slivepositiontaking_3 SMALLMONEY OUTPUT,
	@slivepositiontaking_7 SMALLMONEY OUTPUT,
	@slivepositiontaking_8 SMALLMONEY OUTPUT,
	
	@auto_spositiontaking_1 SMALLMONEY = 0,
	@auto_spositiontaking_2 SMALLMONEY = 0,
	@auto_spositiontaking_3 SMALLMONEY = 0,
	@auto_spositiontaking_4 SMALLMONEY = 0,
	@auto_spositiontaking_5 SMALLMONEY= 0,
	@auto_spositiontaking_6 SMALLMONEY = 0,
	@auto_spositiontaking_7 SMALLMONEY = 0,
	@auto_spositiontaking_8 SMALLMONEY = 0,
	@auto_spositiontaking_9 SMALLMONEY = 0,
	@auto_spositiontaking_10 SMALLMONEY = 0,
	
	@auto_slivepositiontaking_1 SMALLMONEY = 0,
	@auto_slivepositiontaking_3 SMALLMONEY = 0,
	@auto_slivepositiontaking_7 SMALLMONEY = 0,
	@auto_slivepositiontaking_8 SMALLMONEY = 0,
	
	--i1
	@isauto_spositiontaking_1 BIT = 0,
	@isauto_spositiontaking_2 BIT = 0,
	@isauto_spositiontaking_3 BIT = 0,
	@isauto_spositiontaking_4 BIT = 0,
	@isauto_spositiontaking_5 bit= 0,
	@isauto_spositiontaking_6 BIT = 0,
	@isauto_spositiontaking_7 BIT = 0,
	@isauto_spositiontaking_8 BIT = 0,
	@isauto_spositiontaking_9 BIT = 0,
	@isauto_spositiontaking_10 BIT = 0,
	
	@isauto_slivepositiontaking_1 BIT = 0,
	@isauto_slivepositiontaking_3 BIT = 0,
	@isauto_slivepositiontaking_7 BIT = 0,
	@isauto_slivepositiontaking_8 BIT = 0,
	
	--i3
	@isauto_smpositiontaking_1 BIT = 0,
	@isauto_smpositiontaking_2 BIT = 0,
	@isauto_smpositiontaking_3 BIT = 0,
	@isauto_smpositiontaking_4 BIT = 0,
	@isauto_smpositiontaking_5 bit= 0,
	@isauto_smpositiontaking_6 BIT = 0,
	@isauto_smpositiontaking_7 BIT = 0,
	@isauto_smpositiontaking_8 BIT = 0,
	@isauto_smpositiontaking_9 BIT = 0,
	@isauto_smpositiontaking_10 BIT = 0,
	
	@isauto_smlivepositiontaking_1 BIT = 0,
	@isauto_smlivepositiontaking_3 BIT = 0,
	@isauto_smlivepositiontaking_7 BIT = 0,
	@isauto_smlivepositiontaking_8 BIT = 0,
	
	@language varchar(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120528@Elodie
Task : Super edits Position taking of Soccer for Member 
DB: DBTrans.bodb02
Original: Acc_CustomerUpdMember_Super

Revisions:

Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

DECLARE @startRun DATETIME
DECLARE @ENDRun DATETIME
DECLARE @duration INT
SET @startRun = getdate()

DECLARE @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @mrecommEND int, @recommEND int,	@srecommEND int

SELECT @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

SELECT @srecommEND = srecommEND, @mrecommEND = mrecommEND, @recommEND = recommEND, @username = username 
FROM custinfo WITH (NOLOCK) 
Where custid = @custid

DECLARE 
	@mpositiontaking_1 SMALLMONEY,
	@mpositiontaking_2 SMALLMONEY,
	@mpositiontaking_3 SMALLMONEY,
	@mpositiontaking_4 SMALLMONEY,
	@mpositiontaking_5 SMALLMONEY,
	@mpositiontaking_6 SMALLMONEY,
	@mpositiontaking_7 SMALLMONEY,
	@mpositiontaking_8 SMALLMONEY,
	@mpositiontaking_9 SMALLMONEY,
	@mpositiontaking_10 SMALLMONEY,
	@mlivepositiontaking_1 SMALLMONEY,
	@mlivepositiontaking_3 SMALLMONEY,
	@mlivepositiontaking_7 SMALLMONEY,
	@mlivepositiontaking_8 SMALLMONEY,
	
	@old_spositiontaking_1 SMALLMONEY,
	@old_spositiontaking_2 SMALLMONEY,
	@old_spositiontaking_3 SMALLMONEY,
	@old_spositiontaking_4 SMALLMONEY,
	@old_spositiontaking_5 SMALLMONEY,
	@old_spositiontaking_6 SMALLMONEY,
	@old_spositiontaking_7 SMALLMONEY,
	@old_spositiontaking_8 SMALLMONEY,
	@old_spositiontaking_9 SMALLMONEY,
	@old_spositiontaking_10 SMALLMONEY,
	@old_slivepositiontaking_1 SMALLMONEY,
	@old_slivepositiontaking_3 SMALLMONEY,
	@old_slivepositiontaking_7 SMALLMONEY,
	@old_slivepositiontaking_8 SMALLMONEY,
		
	@apositiontaking_1 SMALLMONEY,
	@apositiontaking_2 SMALLMONEY,
	@apositiontaking_3 SMALLMONEY,
	@apositiontaking_4 SMALLMONEY,
	@apositiontaking_5 SMALLMONEY,
	@apositiontaking_6 SMALLMONEY,
	@apositiontaking_7 SMALLMONEY,
	@apositiontaking_8 SMALLMONEY,
	@apositiontaking_9 SMALLMONEY,
	@apositiontaking_10 SMALLMONEY,
	@alivepositiontaking_1 SMALLMONEY,
	@alivepositiontaking_3 SMALLMONEY,
	@alivepositiontaking_7 SMALLMONEY,
	@alivepositiontaking_8 SMALLMONEY,
	
		
	@spositiontaking_1_max SMALLMONEY,
	@spositiontaking_2_max SMALLMONEY,
	@spositiontaking_3_max SMALLMONEY,
	@spositiontaking_4_max SMALLMONEY,
	@spositiontaking_5_max SMALLMONEY,
	@spositiontaking_6_max SMALLMONEY,
	@spositiontaking_7_max SMALLMONEY,
	@spositiontaking_8_max SMALLMONEY,
	@spositiontaking_9_max SMALLMONEY,
	@spositiontaking_10_max SMALLMONEY,
	@slivepositiontaking_1_max SMALLMONEY,
	@slivepositiontaking_3_max SMALLMONEY,
	@slivepositiontaking_7_max SMALLMONEY,
	@slivepositiontaking_8_max SMALLMONEY,
		
	--Old u1,i1
	@old_auto_spositiontaking_1 SMALLMONEY ,
	@old_auto_spositiontaking_2 SMALLMONEY ,
	@old_auto_spositiontaking_3 SMALLMONEY ,
	@old_auto_spositiontaking_4 SMALLMONEY ,
	@old_auto_spositiontaking_5 SMALLMONEY,
	@old_auto_spositiontaking_6 SMALLMONEY ,
	@old_auto_spositiontaking_7 SMALLMONEY ,
	@old_auto_spositiontaking_8 SMALLMONEY ,
	@old_auto_spositiontaking_9 SMALLMONEY ,
	@old_auto_spositiontaking_10 SMALLMONEY ,
	@old_auto_slivepositiontaking_1 SMALLMONEY ,
	@old_auto_slivepositiontaking_3 SMALLMONEY ,
	@old_auto_slivepositiontaking_7 SMALLMONEY ,
	@old_auto_slivepositiontaking_8 SMALLMONEY ,
		
	@old_isauto_spositiontaking_1 BIT ,
	@old_isauto_spositiontaking_2 BIT ,
	@old_isauto_spositiontaking_3 BIT ,
	@old_isauto_spositiontaking_4 BIT ,
	@old_isauto_spositiontaking_5 bit,
	@old_isauto_spositiontaking_6 BIT ,
	@old_isauto_spositiontaking_7 BIT ,
	@old_isauto_spositiontaking_8 BIT ,
	@old_isauto_spositiontaking_9 BIT ,
	@old_isauto_spositiontaking_10 BIT ,
	@old_isauto_slivepositiontaking_1 BIT ,
	@old_isauto_slivepositiontaking_3 BIT ,
	@old_isauto_slivepositiontaking_7 BIT ,
	@old_isauto_slivepositiontaking_8 BIT 
		
DECLARE @ErrType varchar(1000) 
------------------------------------------------------------------------
-- Check param
DECLARE @IsValid bit
SELECT @IsValid = 1

--Check Old_PT <> New_PT
SELECT @apositiontaking_1 = apositiontaking, @alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @old_spositiontaking_1 = spositiontaking, @old_slivepositiontaking_1 = slivepositiontaking, @old_auto_spositiontaking_1 = autopositiontaking, @old_auto_slivepositiontaking_1 = autolivepositiontaking, @old_isauto_spositiontaking_1 = isautopositiontaking, @old_isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1
SELECT @apositiontaking_3 = apositiontaking, @alivepositiontaking_3 = alivepositiontaking,@mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @old_spositiontaking_3 = spositiontaking, @old_slivepositiontaking_3 = slivepositiontaking, @old_auto_spositiontaking_3 = autopositiontaking, @old_auto_slivepositiontaking_3 = autolivepositiontaking, @old_isauto_spositiontaking_3 = isautopositiontaking, @old_isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1
SELECT @apositiontaking_7 = apositiontaking, @alivepositiontaking_7 = alivepositiontaking,@mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @old_spositiontaking_7 = spositiontaking, @old_slivepositiontaking_7 = slivepositiontaking, @old_auto_spositiontaking_7 = autopositiontaking, @old_auto_slivepositiontaking_7 = autolivepositiontaking, @old_isauto_spositiontaking_7 = isautopositiontaking, @old_isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1
SELECT @apositiontaking_8 = apositiontaking, @alivepositiontaking_8 = alivepositiontaking,@mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @old_spositiontaking_8 = spositiontaking, @old_slivepositiontaking_8 = slivepositiontaking, @old_auto_spositiontaking_8 = autopositiontaking, @old_auto_slivepositiontaking_8 = autolivepositiontaking, @old_isauto_spositiontaking_8 = isautopositiontaking, @old_isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

SELECT @apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @old_spositiontaking_2 = spositiontaking, @old_auto_spositiontaking_2 = autopositiontaking, @old_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
SELECT @apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @old_spositiontaking_4 = spositiontaking, @old_auto_spositiontaking_4 = autopositiontaking, @old_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
SELECT @apositiontaking_5 = apositiontaking, @mpositiontaking_5 = mpositiontaking, @old_spositiontaking_5 = spositiontaking, @old_auto_spositiontaking_5 = autopositiontaking, @old_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
SELECT @apositiontaking_6 = apositiontaking, @mpositiontaking_6 = mpositiontaking, @old_spositiontaking_6 = spositiontaking, @old_auto_spositiontaking_6 = autopositiontaking, @old_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
SELECT @apositiontaking_9 = apositiontaking, @mpositiontaking_9 = mpositiontaking, @old_spositiontaking_9 = spositiontaking, @old_auto_spositiontaking_9 = autopositiontaking, @old_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
SELECT @apositiontaking_10 = apositiontaking, @mpositiontaking_10 = mpositiontaking, @old_spositiontaking_10 = spositiontaking, @old_auto_spositiontaking_10 = autopositiontaking, @old_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1

IF  @spositiontaking_1 = @old_spositiontaking_1 AND
	@spositiontaking_2 = @old_spositiontaking_2 AND
	@spositiontaking_3 = @old_spositiontaking_3 AND
	@spositiontaking_4 = @old_spositiontaking_4 AND
	@spositiontaking_5 = @old_spositiontaking_5 AND
	@spositiontaking_6 = @old_spositiontaking_6 AND
	@spositiontaking_7 = @old_spositiontaking_7 AND
	@spositiontaking_8 = @old_spositiontaking_8 AND
	@spositiontaking_9 = @old_spositiontaking_9 AND
	@spositiontaking_10 = @old_spositiontaking_10 AND
	@slivepositiontaking_1 = @old_slivepositiontaking_1 AND
	@slivepositiontaking_3 = @old_slivepositiontaking_3 AND
	@slivepositiontaking_7 = @old_slivepositiontaking_7 AND
	@slivepositiontaking_8 = @old_slivepositiontaking_8 AND

	@auto_spositiontaking_1 = @old_auto_spositiontaking_1 AND
	@auto_spositiontaking_2 = @old_auto_spositiontaking_2 AND
	@auto_spositiontaking_3 = @old_auto_spositiontaking_3 AND
	@auto_spositiontaking_4 = @old_auto_spositiontaking_4 AND
	@auto_spositiontaking_5 = @old_auto_spositiontaking_5 AND
	@auto_spositiontaking_6 = @old_auto_spositiontaking_6 AND
	@auto_spositiontaking_7 = @old_auto_spositiontaking_7 AND
	@auto_spositiontaking_8 = @old_auto_spositiontaking_8 AND
	@auto_spositiontaking_9 = @old_auto_spositiontaking_9 AND
	@auto_spositiontaking_10 = @old_auto_spositiontaking_10 AND
	@auto_slivepositiontaking_1 = @old_auto_slivepositiontaking_1 AND
	@auto_slivepositiontaking_3 = @old_auto_slivepositiontaking_3 AND
	@auto_slivepositiontaking_7 = @old_auto_slivepositiontaking_7 AND
	@auto_slivepositiontaking_8 = @old_auto_slivepositiontaking_8 AND
	
	@isauto_spositiontaking_1 = @old_isauto_spositiontaking_1 AND
	@isauto_spositiontaking_2 = @old_isauto_spositiontaking_2 AND
	@isauto_spositiontaking_3 = @old_isauto_spositiontaking_3 AND
	@isauto_spositiontaking_4 = @old_isauto_spositiontaking_4 AND
	@isauto_spositiontaking_5 = @old_isauto_spositiontaking_5 AND
	@isauto_spositiontaking_6 = @old_isauto_spositiontaking_6 AND
	@isauto_spositiontaking_7 = @old_isauto_spositiontaking_7 AND
	@isauto_spositiontaking_8 = @old_isauto_spositiontaking_8 AND
	@isauto_spositiontaking_9 = @old_isauto_spositiontaking_9 AND
	@isauto_spositiontaking_10 = @old_isauto_spositiontaking_10 AND
	@isauto_slivepositiontaking_1 = @old_isauto_slivepositiontaking_1 AND
	@isauto_slivepositiontaking_3 = @old_isauto_slivepositiontaking_3 AND
	@isauto_slivepositiontaking_7 = @old_isauto_slivepositiontaking_7 AND
	@isauto_slivepositiontaking_8 = @old_isauto_slivepositiontaking_8
BEGIN
	SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	return
END 


if 
	   @spositiontaking_1  <0 OR @spositiontaking_1  >0.9
	OR @spositiontaking_2  <0 OR @spositiontaking_2  >0.9
	OR @spositiontaking_3  <0 OR @spositiontaking_3  >0.9
	OR @spositiontaking_4  <0 OR @spositiontaking_4  >0.9
	OR @spositiontaking_5  <0 OR @spositiontaking_5  >0.9
	OR @spositiontaking_6  <0 OR @spositiontaking_6  >0.9
	OR @spositiontaking_7  <0 OR @spositiontaking_7  >0.9
	OR @spositiontaking_8  <0 OR @spositiontaking_8  >0.9
	OR @spositiontaking_9  <0 OR @spositiontaking_9  >0.9
	OR @spositiontaking_10 <0 OR @spositiontaking_10 >0.9
	OR @slivepositiontaking_1  <0 OR @slivepositiontaking_1  >0.9
	OR @slivepositiontaking_3  <0 OR @slivepositiontaking_3  >0.9
	OR @slivepositiontaking_7  <0 OR @slivepositiontaking_7  >0.9
	OR @slivepositiontaking_8  <0 OR @slivepositiontaking_8  >0.9
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

SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
from custoverride AS co with (NOLOCK) 
	inner join
		(
					SELECT 1 AS sporttype, 1 AS bettype, @auto_spositiontaking_1 AS autopositiontaking, @isauto_spositiontaking_1 AS isautopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking, @isauto_slivepositiontaking_1 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 3 AS bettype, @auto_spositiontaking_3 AS autopositiontaking, @isauto_spositiontaking_3 AS isautopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking, @isauto_slivepositiontaking_3 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 7 AS bettype, @auto_spositiontaking_7 AS autopositiontaking, @isauto_spositiontaking_7 AS isautopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking, @isauto_slivepositiontaking_7 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 8 AS bettype, @auto_spositiontaking_8 AS autopositiontaking, @isauto_spositiontaking_8 AS isautopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking, @isauto_slivepositiontaking_8 AS isautolivepositiontaking

		UNION ALL	SELECT 1 AS sporttype, 2 AS bettype, @auto_spositiontaking_2 AS autopositiontaking, @isauto_spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 4 AS bettype, @auto_spositiontaking_4 AS autopositiontaking, @isauto_spositiontaking_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 5 AS bettype, @auto_spositiontaking_5 AS autopositiontaking, @isauto_spositiontaking_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 6 AS bettype, @auto_spositiontaking_6 AS autopositiontaking, @isauto_spositiontaking_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 9 AS bettype, @auto_spositiontaking_9 AS autopositiontaking, @isauto_spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		UNION ALL	SELECT 1 AS sporttype, 10 AS bettype, @auto_spositiontaking_10 AS autopositiontaking, @isauto_spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		) 
	AS b on co.sporttype=b.sporttype and co.bettype=b.bettype
	INNER JOIN sports with (nolock) 
			on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) 
			on b.bettype = bettype.typeid
where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

if @ErrType <>''
BEGIN
	SELECT @isvalid = 0, @ErrCode_cur = 2
	SELECT @ErrMsg_cur = 	case @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								WHEN 'CS' THEN N'占成数不正确(公司设给最低/高占成) ('+@ErrType+').'
								WHEN 'CT' THEN N'佔成數不正確(公司設給最低/高佔成) ('+@ErrType+').'
								WHEN 'TH' THEN N'การกำหนดไม่ถูกต้อง (สูงสุด หรือ ต่ำสุด อ้างอิงจากข้อมูลบริษัท) ('+@ErrType+').'
								WHEN 'J' THEN N'Wrong position taking (min/max set by company) ('+@ErrType+').'
								WHEN 'KO' THEN N'거래 조건이 잘못 되었습니다 (ibc가 설정한 최소값/최대값) ('+@ErrType+').'
								ELSE N'Wrong position taking (min/max set by company) ('+@ErrType+').'
							END
	select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END

--Check u1<=s4
SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
+ CASE WHEN b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
from custsetting AS cs with (NOLOCK) inner join
	(
				SELECT 1 AS bettype, 1 AS sporttype, @auto_spositiontaking_1 AS autopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking
	UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @auto_spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @auto_spositiontaking_3 AS autopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking
	UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @auto_spositiontaking_4 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @auto_spositiontaking_5 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @auto_spositiontaking_6 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @auto_spositiontaking_7 AS autopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking
	UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @auto_spositiontaking_8 AS autopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking
	UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @auto_spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @auto_spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
	) 
	AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend
	and 
	((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and cs.slivepositiontaking<b.autolivepositiontaking))
	
if @ErrType <>''
BEGIN
	SELECT @ErrMsg_cur =	@UserName + ': '+
						case @Language 
							WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
							WHEN 'CS' THEN N'自动占成数不正确.<br>'+@ErrType
							WHEN 'CT' THEN N'自動佔成數不正確.<br>'+@ErrType
							WHEN 'TH' THEN N'การปรับยอดเงินที่ผิดพลาดอันเนื่องมาจากระบบ.<br>'+@ErrType
							WHEN 'J' THEN N'Wrong auto position taking.<br>'+@ErrType
							WHEN 'KO' THEN N'자동 거래조건이 잘못 되었습니다.<br>'+@ErrType
							ELSE N'Wrong auto position taking.<br>'+@ErrType
						END, @ErrCode_cur = 7							
	SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END				

--Check s1<=s4
SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
+ CASE WHEN b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
from custsetting AS cs with (NOLOCK) inner join
	(
				SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS positiontaking, @slivepositiontaking_1 AS livepositiontaking
	UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS positiontaking, @slivepositiontaking_3 AS livepositiontaking
	UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS positiontaking, @slivepositiontaking_7 AS livepositiontaking
	UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS positiontaking, @slivepositiontaking_8 AS livepositiontaking
	UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
	) 
	AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend
	and 
	((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and cs.slivepositiontaking<b.livepositiontaking))
	
if @ErrType <>''
BEGIN
	SELECT @ErrMsg_cur =	@UserName + ': '+
						case @Language 
							WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
							WHEN 'CS' THEN N'占成数不正确.<br>'+@ErrType
							WHEN 'CT' THEN N'佔成數不正確.<br>'+@ErrType
							WHEN 'TH' THEN N'การกำหนดไม่ถูกต้อง.<br>'+@ErrType
							WHEN 'J' THEN N'Wrong  position taking.<br>'+@ErrType
							WHEN 'KO' THEN N'거래 조건이 잘못 되었습니다.<br>'+@ErrType
							ELSE N'Wrong  position taking.<br>'+@ErrType
						END, @ErrCode_cur = 8							
	select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END

SELECT @spositiontaking_1_max = spositiontaking, @slivepositiontaking_1_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=1
SELECT @spositiontaking_3_max = spositiontaking, @slivepositiontaking_3_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=1
SELECT @spositiontaking_7_max = spositiontaking, @slivepositiontaking_7_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=7 and sporttype=1
SELECT @spositiontaking_8_max = spositiontaking, @slivepositiontaking_8_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=8 and sporttype=1

SELECT @spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=1
SELECT @spositiontaking_4_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=4 and sporttype=1
SELECT @spositiontaking_5_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=5 and sporttype=1
SELECT @spositiontaking_6_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=6 and sporttype=1
SELECT @spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=1
SELECT @spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=1

SELECT 
	@spositiontaking_1 = CASE WHEN @spositiontaking_1+@mpositiontaking_1+@apositiontaking_1>@spositiontaking_1_max THEN @spositiontaking_1_max-@mpositiontaking_1-@apositiontaking_1 ELSE @spositiontaking_1 END,
	@spositiontaking_2 = CASE WHEN @spositiontaking_2+@mpositiontaking_2+@apositiontaking_2>@spositiontaking_2_max THEN @spositiontaking_2_max-@mpositiontaking_2-@apositiontaking_2 ELSE @spositiontaking_2 END,
	@spositiontaking_3 = CASE WHEN @spositiontaking_3+@mpositiontaking_3+@apositiontaking_3>@spositiontaking_3_max THEN @spositiontaking_3_max-@mpositiontaking_3-@apositiontaking_3 ELSE @spositiontaking_3 END,
	@spositiontaking_4 = CASE WHEN @spositiontaking_4+@mpositiontaking_4+@apositiontaking_4>@spositiontaking_4_max THEN @spositiontaking_4_max-@mpositiontaking_4-@apositiontaking_4 ELSE @spositiontaking_4 END,
	@spositiontaking_5 = CASE WHEN @spositiontaking_5+@mpositiontaking_5+@apositiontaking_5>@spositiontaking_5_max THEN @spositiontaking_5_max-@mpositiontaking_5-@apositiontaking_5 ELSE @spositiontaking_5 END,
	@spositiontaking_6 = CASE WHEN @spositiontaking_6+@mpositiontaking_6+@apositiontaking_6>@spositiontaking_6_max THEN @spositiontaking_6_max-@mpositiontaking_6-@apositiontaking_6 ELSE @spositiontaking_6 END,
	@spositiontaking_7 = CASE WHEN @spositiontaking_7+@mpositiontaking_7+@apositiontaking_7>@spositiontaking_7_max THEN @spositiontaking_7_max-@mpositiontaking_7-@apositiontaking_7 ELSE @spositiontaking_7 END,
	@spositiontaking_8 = CASE WHEN @spositiontaking_8+@mpositiontaking_8+@apositiontaking_8>@spositiontaking_8_max THEN @spositiontaking_8_max-@mpositiontaking_8-@apositiontaking_8 ELSE @spositiontaking_8 END,
	@spositiontaking_9 = CASE WHEN @spositiontaking_9+@mpositiontaking_9+@apositiontaking_9>@spositiontaking_9_max THEN @spositiontaking_9_max-@mpositiontaking_9-@apositiontaking_9 ELSE @spositiontaking_9 END,
	@spositiontaking_10 = CASE WHEN @spositiontaking_10+@mpositiontaking_10+@apositiontaking_10>@spositiontaking_10_max THEN @spositiontaking_10_max-@mpositiontaking_10-@apositiontaking_10 ELSE @spositiontaking_10 END,

	@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1+@mlivepositiontaking_1+@alivepositiontaking_1>@slivepositiontaking_1_max THEN @slivepositiontaking_1_max-@mlivepositiontaking_1-@alivepositiontaking_1 ELSE @slivepositiontaking_1 END,
	@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3+@mlivepositiontaking_3+@alivepositiontaking_3>@slivepositiontaking_3_max THEN @slivepositiontaking_3_max-@mlivepositiontaking_3-@alivepositiontaking_3 ELSE @slivepositiontaking_3 END,
	@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7+@mlivepositiontaking_7+@alivepositiontaking_7>@slivepositiontaking_7_max THEN @slivepositiontaking_7_max-@mlivepositiontaking_7-@alivepositiontaking_7 ELSE @slivepositiontaking_7 END,
	@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8+@mlivepositiontaking_8+@alivepositiontaking_8>@slivepositiontaking_8_max THEN @slivepositiontaking_8_max-@mlivepositiontaking_8-@alivepositiontaking_8 ELSE @slivepositiontaking_8 END

SELECT 
	@spositiontaking_1 = CASE WHEN @spositiontaking_1<0 THEN 0 ELSE @spositiontaking_1 END,
	@spositiontaking_2 = CASE WHEN @spositiontaking_2<0 THEN 0 ELSE @spositiontaking_2 END,
	@spositiontaking_3 = CASE WHEN @spositiontaking_3<0 THEN 0 ELSE @spositiontaking_3 END,
	@spositiontaking_4 = CASE WHEN @spositiontaking_4<0 THEN 0 ELSE @spositiontaking_4 END,
	@spositiontaking_5 = CASE WHEN @spositiontaking_5<0 THEN 0 ELSE @spositiontaking_5 END,
	@spositiontaking_6 = CASE WHEN @spositiontaking_6<0 THEN 0 ELSE @spositiontaking_6 END,
	@spositiontaking_7 = CASE WHEN @spositiontaking_7<0 THEN 0 ELSE @spositiontaking_7 END,
	@spositiontaking_8 = CASE WHEN @spositiontaking_8<0 THEN 0 ELSE @spositiontaking_8 END,
	@spositiontaking_9 = CASE WHEN @spositiontaking_9<0 THEN 0 ELSE @spositiontaking_9 END,
	@spositiontaking_10 = CASE WHEN @spositiontaking_10<0 THEN 0 ELSE @spositiontaking_10 END,

	@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1<0 THEN 0 ELSE @slivepositiontaking_1 END,
	@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3<0 THEN 0 ELSE @slivepositiontaking_3 END,
	@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7<0 THEN 0 ELSE @slivepositiontaking_7 END,
	@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8<0 THEN 0 ELSE @slivepositiontaking_8 END

--don't update s1 for member under master was set i3=1(normal)
UPDATE cs WITH (ROWLOCK, UPDLOCK)
SET
	cs.spositiontaking = CASE cs.sporttype WHEN 1 THEN case cs.bettype 
														WHEN 1 THEN @spositiontaking_1 
														WHEN 2 THEN @spositiontaking_2 
														WHEN 3 THEN @spositiontaking_3 
														WHEN 4 THEN @spositiontaking_4 
														WHEN 5 THEN @spositiontaking_5 
														WHEN 6 THEN @spositiontaking_6 
														WHEN 7 THEN @spositiontaking_7 
														WHEN 8 THEN @spositiontaking_8 
														WHEN 9 THEN @spositiontaking_9 
														WHEN 10 THEN @spositiontaking_10 
														ELSE 0 END
											ELSE cs.spositiontaking END
FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
	INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
WHERE cs.custid = @custid and c.roleid = 1 and scs.isautopositiontaking = 0

--don't update s1 for member under master was set i3=1(live)
UPDATE cs with (ROWLOCK, UPDLOCK)
SET
	cs.slivepositiontaking = case cs.sporttype WHEN 1 THEN case cs.bettype 
															WHEN 1 THEN @slivepositiontaking_1 
															WHEN 3 THEN @slivepositiontaking_3 
															WHEN 7 THEN @slivepositiontaking_7 
															WHEN 8 THEN @slivepositiontaking_8 
															ELSE cs.slivepositiontaking END 
												ELSE cs.slivepositiontaking END
FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
	INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
where cs.custid=@custid and c.roleid = 1 and scs.isautolivepositiontaking = 0

EXEC dbo.Acc_CustomerUpdMember_AutoPositiontaking_1
			@custid = @custid,

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
			
			@isauto_spositiontaking_1 = @isauto_spositiontaking_1,
			@isauto_spositiontaking_2 = @isauto_spositiontaking_2,
			@isauto_spositiontaking_3 = @isauto_spositiontaking_3,
			@isauto_spositiontaking_4 = @isauto_spositiontaking_4,
			@isauto_spositiontaking_5 = @isauto_spositiontaking_5,
			@isauto_spositiontaking_6 = @isauto_spositiontaking_6,
			@isauto_spositiontaking_7 = @isauto_spositiontaking_7,
			@isauto_spositiontaking_8 = @isauto_spositiontaking_8,
			@isauto_spositiontaking_9 = @isauto_spositiontaking_9,
			@isauto_spositiontaking_10 = @isauto_spositiontaking_10,
			@isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
			@isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
			@isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
			@isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
			
			@language = @language,
			@userid = @userid

EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking_1
	@custid = @custid, 
	@recommEND = @recommEND, 
	@mrecommEND = @mrecommEND, 
	@srecommEND = @srecommEND,
	@updautosuper = 0
	
SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)

DECLARE @LogSPData varchar(4000), @TrackingValue2 varchar(4000)

SELECT @LogSPData = '<Acc_CustomerUpdMember_PositionTaking_Super_1><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
'spt_6="'+ coalesce(cast(@spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 AS varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMember_PositionTaking_Super_1>'

SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_PositionTaking_Super_1><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 AS varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMember_PositionTaking_Super_1>'

SET @ENDRun = getdate()
SET @duration  = datediff (millisecond,@startRun,@ENDRun)

--Log positiontaking
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 404,
	@TrackingValue = @LogSPData,
	@TrackingValue2 = @TrackingValue2,
	@duration = @duration

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_1] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_1] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_1] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_1] TO [vnteam] 