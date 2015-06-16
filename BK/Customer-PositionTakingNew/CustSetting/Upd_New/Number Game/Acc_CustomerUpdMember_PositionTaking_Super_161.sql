ALTER PROCEDURE [dbo].Acc_CustomerUpdMember_PositionTaking_Super_161
	@CustID INT,--memberid
	@UserID int,

	@v161spositiontaking_81 SMALLMONEY OUTPUT,
	@v161spositiontaking_83 SMALLMONEY OUTPUT,
	@v161spositiontaking_86 SMALLMONEY OUTPUT,
	@v161spositiontaking_88 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_85 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_86 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_87 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_89 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_90 SMALLMONEY = 0 OUTPUT,
	
	@auto_v161spositiontaking_81 SMALLMONEY = 0,
	@auto_v161spositiontaking_83 SMALLMONEY = 0,
	@auto_v161spositiontaking_86 SMALLMONEY = 0,
	@auto_v161spositiontaking_88 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_85 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_86 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_87 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_89 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_90 SMALLMONEY = 0,

	@isauto_v161spositiontaking_81 BIT = 0,	
	@isauto_v161spositiontaking_83 BIT = 0,	
	@isauto_v161spositiontaking_86 BIT = 0,	
	@isauto_v161spositiontaking_88 BIT = 0,	
	@isauto_v161slivepositiontaking_85 BIT = 0,	
	@isauto_v161slivepositiontaking_86 BIT = 0,	
	@isauto_v161slivepositiontaking_87 BIT = 0,	
	@isauto_v161slivepositiontaking_89 BIT = 0,
	@isauto_v161slivepositiontaking_90 BIT = 0,

	@isauto_v161smpositiontaking_81 BIT = 0,		
	@isauto_v161smpositiontaking_83 BIT = 0,		
	@isauto_v161smpositiontaking_86 BIT = 0,		
	@isauto_v161smpositiontaking_88 BIT = 0,		
	@isauto_v161smlivepositiontaking_85 BIT = 0,		
	@isauto_v161smlivepositiontaking_86 BIT = 0,		
	@isauto_v161smlivepositiontaking_87 BIT = 0,		
	@isauto_v161smlivepositiontaking_89 BIT = 0,
	@isauto_v161smlivepositiontaking_90 BIT = 0,

	@language varchar(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120528@Elodie
Task : Super edits Position taking of Number Games for Member 
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
SELECT	@v161slivepositiontaking_90 = 0,
		@auto_v161slivepositiontaking_90 = 0,
		@isauto_v161slivepositiontaking_90 = 0,
		@isauto_v161smlivepositiontaking_90 = 0

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
	@v161mpositiontaking_81 SMALLMONEY,
	@v161mpositiontaking_83 SMALLMONEY,
	@v161mpositiontaking_86 SMALLMONEY,
	@v161mpositiontaking_88 SMALLMONEY,
	@v161mlivepositiontaking_85 SMALLMONEY,
	@v161mlivepositiontaking_86 SMALLMONEY,
	@v161mlivepositiontaking_87 SMALLMONEY,
	@v161mlivepositiontaking_89 SMALLMONEY,
	@v161mlivepositiontaking_90 SMALLMONEY,

	@old_v161spositiontaking_81 SMALLMONEY,
	@old_v161spositiontaking_83 SMALLMONEY,
	@old_v161spositiontaking_86 SMALLMONEY,
	@old_v161spositiontaking_88 SMALLMONEY,
	@old_v161slivepositiontaking_85 SMALLMONEY,
	@old_v161slivepositiontaking_86 SMALLMONEY,
	@old_v161slivepositiontaking_87 SMALLMONEY,
	@old_v161slivepositiontaking_89 SMALLMONEY,
	@old_v161slivepositiontaking_90 SMALLMONEY,

	@v161apositiontaking_81 SMALLMONEY,
	@v161apositiontaking_83 SMALLMONEY,
	@v161apositiontaking_86 SMALLMONEY,
	@v161apositiontaking_88 SMALLMONEY,
	@v161alivepositiontaking_85 SMALLMONEY,
	@v161alivepositiontaking_86 SMALLMONEY,
	@v161alivepositiontaking_87 SMALLMONEY,
	@v161alivepositiontaking_89 SMALLMONEY,
	@v161alivepositiontaking_90 SMALLMONEY,

	@v161spositiontaking_81_max SMALLMONEY,
	@v161spositiontaking_83_max SMALLMONEY,
	@v161spositiontaking_86_max SMALLMONEY,
	@v161spositiontaking_88_max SMALLMONEY,
	@v161slivepositiontaking_85_max SMALLMONEY,
	@v161slivepositiontaking_86_max SMALLMONEY,
	@v161slivepositiontaking_87_max SMALLMONEY,
	@v161slivepositiontaking_89_max SMALLMONEY,
	@v161slivepositiontaking_90_max SMALLMONEY,

	@old_auto_v161spositiontaking_81 SMALLMONEY ,
	@old_auto_v161spositiontaking_83 SMALLMONEY ,
	@old_auto_v161spositiontaking_86 SMALLMONEY ,
	@old_auto_v161spositiontaking_88 SMALLMONEY ,
	@old_auto_v161slivepositiontaking_85 SMALLMONEY ,
	@old_auto_v161slivepositiontaking_86 SMALLMONEY ,
	@old_auto_v161slivepositiontaking_87 SMALLMONEY ,
	@old_auto_v161slivepositiontaking_89 SMALLMONEY ,
	@old_auto_v161slivepositiontaking_90 SMALLMONEY ,

	@old_isauto_v161spositiontaking_81 BIT ,
	@old_isauto_v161spositiontaking_83 BIT ,
	@old_isauto_v161spositiontaking_86 BIT ,
	@old_isauto_v161spositiontaking_88 BIT ,
	@old_isauto_v161slivepositiontaking_85 BIT ,
	@old_isauto_v161slivepositiontaking_86 BIT ,
	@old_isauto_v161slivepositiontaking_87 BIT ,
	@old_isauto_v161slivepositiontaking_89 BIT ,
	@old_isauto_v161slivepositiontaking_90 BIT

DECLARE @ErrType varchar(1000) 
----------------------------------------------------------
-- Check param
DECLARE @IsValid bit
SELECT @IsValid = 1

--Check Old_PT <> New_PT
SELECT @v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @old_v161spositiontaking_81 = spositiontaking, @old_auto_v161spositiontaking_81 = autopositiontaking, @old_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
SELECT @v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @old_v161spositiontaking_83 = spositiontaking, @old_auto_v161spositiontaking_83 = autopositiontaking, @old_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
SELECT @v161apositiontaking_86 = apositiontaking, @v161mpositiontaking_86 = mpositiontaking, @old_v161spositiontaking_86 = spositiontaking, @old_auto_v161spositiontaking_86 = autopositiontaking, @old_isauto_v161spositiontaking_86 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
SELECT @v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @old_v161spositiontaking_88 = spositiontaking, @old_auto_v161spositiontaking_88 = autopositiontaking, @old_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
SELECT @v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161slivepositiontaking_85 = slivepositiontaking, @old_auto_v161slivepositiontaking_85 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
SELECT @v161alivepositiontaking_86 = alivepositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161slivepositiontaking_86 = slivepositiontaking, @old_auto_v161slivepositiontaking_86 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
SELECT @v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161slivepositiontaking_87 = slivepositiontaking, @old_auto_v161slivepositiontaking_87 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
SELECT @v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161slivepositiontaking_89 = slivepositiontaking, @old_auto_v161slivepositiontaking_89 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
SELECT @v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161slivepositiontaking_90 = slivepositiontaking, @old_auto_v161slivepositiontaking_90 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161

IF
	@v161spositiontaking_81 = @old_v161spositiontaking_81 AND
	@v161spositiontaking_83 = @old_v161spositiontaking_83 AND
	@v161spositiontaking_86 = @old_v161spositiontaking_86 AND
	@v161spositiontaking_88 = @old_v161spositiontaking_88 AND
	@v161slivepositiontaking_85 = @old_v161slivepositiontaking_85 AND
	@v161slivepositiontaking_86 = @old_v161slivepositiontaking_86 AND
	@v161slivepositiontaking_87 = @old_v161slivepositiontaking_87 AND
	@v161slivepositiontaking_89 = @old_v161slivepositiontaking_89 AND
	@v161slivepositiontaking_90 = @old_v161slivepositiontaking_90 AND
	
	@auto_v161spositiontaking_81 = @old_auto_v161spositiontaking_81 AND
	@auto_v161spositiontaking_83 = @old_auto_v161spositiontaking_83 AND
	@auto_v161spositiontaking_86 = @old_auto_v161spositiontaking_86 AND
	@auto_v161spositiontaking_88 = @old_auto_v161spositiontaking_88 AND
	@auto_v161slivepositiontaking_85 = @old_auto_v161slivepositiontaking_85 AND
	@auto_v161slivepositiontaking_86 = @old_auto_v161slivepositiontaking_86 AND
	@auto_v161slivepositiontaking_87 = @old_auto_v161slivepositiontaking_87 AND
	@auto_v161slivepositiontaking_89 = @old_auto_v161slivepositiontaking_89 AND
	@auto_v161slivepositiontaking_90 = @old_auto_v161slivepositiontaking_90 AND
	
	@isauto_v161spositiontaking_81 = @old_isauto_v161spositiontaking_81 AND
	@isauto_v161spositiontaking_83 = @old_isauto_v161spositiontaking_83 AND
	@isauto_v161spositiontaking_86 = @old_isauto_v161spositiontaking_86 AND
	@isauto_v161spositiontaking_88 = @old_isauto_v161spositiontaking_88 AND
	@isauto_v161slivepositiontaking_85 = @old_isauto_v161slivepositiontaking_85 AND
	@isauto_v161slivepositiontaking_86 = @old_isauto_v161slivepositiontaking_86 AND
	@isauto_v161slivepositiontaking_87 = @old_isauto_v161slivepositiontaking_87 AND
	@isauto_v161slivepositiontaking_89 = @old_isauto_v161slivepositiontaking_89 AND
	@isauto_v161slivepositiontaking_90 = @old_isauto_v161slivepositiontaking_90 
BEGIN
	SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	return
END 

if 
	   @v161spositiontaking_81 <0 OR @v161spositiontaking_81 >0.9	
	OR @v161spositiontaking_83 <0 OR @v161spositiontaking_83 >0.9	
	OR @v161spositiontaking_86 <0 OR @v161spositiontaking_86 >0.9	
	OR @v161spositiontaking_88 <0 OR @v161spositiontaking_88 >0.9	
	OR @v161slivepositiontaking_85 <0 OR @v161slivepositiontaking_85 >0.9	
	OR @v161slivepositiontaking_86 <0 OR @v161slivepositiontaking_86 >0.9	
	OR @v161slivepositiontaking_87 <0 OR @v161slivepositiontaking_87 >0.9	
	OR @v161slivepositiontaking_89 <0 OR @v161slivepositiontaking_89 >0.9	
	OR @v161slivepositiontaking_90 <0 OR @v161slivepositiontaking_90 >0.9	
BEGIN
	select @ErrCode = 8
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

--Check u1<=l4
SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
from custoverride3rd AS co3 with (NOLOCK) inner join
	(
				SELECT 161 AS sporttype, 81 AS bettype, @auto_v161spositiontaking_81 AS autopositiontaking, @isauto_v161spositiontaking_81 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 83 AS bettype, @auto_v161spositiontaking_83 AS autopositiontaking, @isauto_v161spositiontaking_83 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 88 AS bettype, @auto_v161spositiontaking_88 AS autopositiontaking, @isauto_v161spositiontaking_88 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 85 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking, @isauto_v161slivepositiontaking_85 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 86 AS bettype, @auto_v161spositiontaking_86 AS autopositiontaking, @isauto_v161spositiontaking_86 AS isautopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking, @isauto_v161slivepositiontaking_86 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 87 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking, @isauto_v161slivepositiontaking_87 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 89 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking, @isauto_v161slivepositiontaking_89 AS isautolivepositiontaking
	UNION ALL	SELECT 161 AS sporttype, 90 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking, @isauto_v161slivepositiontaking_90 AS isautolivepositiontaking
	) AS b on co3.sporttype=b.sporttype and co3.bettype=b.bettype
	INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where co3.custid = @srecommEND and ((b.isautopositiontaking>0 and b.autopositiontaking>co3.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.bettype in (85,86,87) and b.autolivepositiontaking>co3.maxlivepositiontaking))

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

------------------------------------------------------------------------------------------
--Check u1<=s4
SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
+ CASE WHEN b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
from custsetting3rd AS cs3 with (NOLOCK) inner join
	(
					SELECT 81 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_81 AS autopositiontaking, 0 AS autolivepositiontaking
		UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_83 AS autopositiontaking, 0 AS autolivepositiontaking
		UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_88 AS autopositiontaking, 0 AS autolivepositiontaking
		UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking
		UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_86 AS autopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking
		UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking
		UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking
		UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking
	) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs3.custid = @srecommEND and 
	((cs3.spositiontaking<b.autopositiontaking) or (b.bettype in (85,86,87,89,90) and cs3.slivepositiontaking<b.autolivepositiontaking))
	
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
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
+ CASE WHEN b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
from custsetting3rd AS cs3 with (NOLOCK) inner join
	(
					SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS positiontaking, 0 AS livepositiontaking
		UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS positiontaking, 0 AS livepositiontaking
		UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS positiontaking, 0 AS livepositiontaking	
		UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_85 AS livepositiontaking
		UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS positiontaking, @v161slivepositiontaking_86 AS livepositiontaking
		UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_87 AS livepositiontaking
		UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_89 AS livepositiontaking
		UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_90 AS livepositiontaking
	) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
	INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs3.custid = @srecommEND and 
	((cs3.spositiontaking<b.positiontaking) or (b.bettype in (85,86,87,89,90) and cs3.slivepositiontaking<b.livepositiontaking))
	
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

SELECT @v161spositiontaking_81_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=81 and sporttype=161
SELECT @v161spositiontaking_83_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=83 and sporttype=161
SELECT @v161spositiontaking_88_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=88 and sporttype=161
SELECT @v161slivepositiontaking_85_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=85 and sporttype=161
SELECT @v161spositiontaking_86_max = spositiontaking, @v161slivepositiontaking_86_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=86 and sporttype=161
SELECT @v161slivepositiontaking_87_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=87 and sporttype=161
SELECT @v161slivepositiontaking_89_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=89 and sporttype=161
SELECT @v161slivepositiontaking_90_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=90 and sporttype=161

SELECT 
	@v161spositiontaking_81 = CASE WHEN @v161mpositiontaking_81+@v161spositiontaking_81+@v161apositiontaking_81>@v161spositiontaking_81_max THEN @v161spositiontaking_81_max-@v161mpositiontaking_81-@v161apositiontaking_81 ELSE @v161spositiontaking_81 END,
	@v161spositiontaking_83 = CASE WHEN @v161mpositiontaking_83+@v161spositiontaking_83+@v161apositiontaking_83>@v161spositiontaking_83_max THEN @v161spositiontaking_83_max-@v161mpositiontaking_83-@v161apositiontaking_83 ELSE @v161spositiontaking_83 END,		
	@v161spositiontaking_86 = CASE WHEN @v161mpositiontaking_86+@v161spositiontaking_86+@v161apositiontaking_86>@v161spositiontaking_86_max THEN @v161spositiontaking_86_max-@v161mpositiontaking_86-@v161apositiontaking_86 ELSE @v161spositiontaking_86 END,
	@v161spositiontaking_88 = CASE WHEN @v161mpositiontaking_88+@v161spositiontaking_88+@v161apositiontaking_88>@v161spositiontaking_88_max THEN @v161spositiontaking_88_max-@v161mpositiontaking_88-@v161apositiontaking_88 ELSE @v161spositiontaking_88 END,
	@v161slivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85+@v161slivepositiontaking_85+@v161alivepositiontaking_85>@v161slivepositiontaking_85_max THEN @v161slivepositiontaking_85_max-@v161mlivepositiontaking_85-@v161alivepositiontaking_85 ELSE @v161slivepositiontaking_85 END,
	@v161slivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86+@v161slivepositiontaking_86+@v161alivepositiontaking_86>@v161slivepositiontaking_86_max THEN @v161slivepositiontaking_86_max-@v161mlivepositiontaking_86-@v161alivepositiontaking_86 ELSE @v161slivepositiontaking_86 END,
	@v161slivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87+@v161slivepositiontaking_87+@v161alivepositiontaking_87>@v161slivepositiontaking_87_max THEN @v161slivepositiontaking_87_max-@v161mlivepositiontaking_87-@v161alivepositiontaking_87 ELSE @v161slivepositiontaking_87 END,
	@v161slivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89+@v161slivepositiontaking_89+@v161alivepositiontaking_89>@v161slivepositiontaking_89_max THEN @v161slivepositiontaking_89_max-@v161mlivepositiontaking_89-@v161alivepositiontaking_89 ELSE @v161slivepositiontaking_89 END,
	@v161slivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90+@v161slivepositiontaking_90+@v161alivepositiontaking_90>@v161slivepositiontaking_90_max THEN @v161slivepositiontaking_90_max-@v161mlivepositiontaking_90-@v161alivepositiontaking_90 ELSE @v161slivepositiontaking_90 END

SELECT 
	@v161spositiontaking_81 = CASE WHEN @v161spositiontaking_81<0 THEN 0 ELSE @v161spositiontaking_81 END,
	@v161spositiontaking_83 = CASE WHEN @v161spositiontaking_83<0 THEN 0 ELSE @v161spositiontaking_83 END,
	@v161spositiontaking_86 = CASE WHEN @v161spositiontaking_86<0 THEN 0 ELSE @v161spositiontaking_86 END,
	@v161spositiontaking_88 = CASE WHEN @v161spositiontaking_88<0 THEN 0 ELSE @v161spositiontaking_88 END,
	@v161slivepositiontaking_85 = CASE WHEN @v161slivepositiontaking_85<0 THEN 0 ELSE @v161slivepositiontaking_85 END,
	@v161slivepositiontaking_86 = CASE WHEN @v161slivepositiontaking_86<0 THEN 0 ELSE @v161slivepositiontaking_86 END,
	@v161slivepositiontaking_87 = CASE WHEN @v161slivepositiontaking_87<0 THEN 0 ELSE @v161slivepositiontaking_87 END,
	@v161slivepositiontaking_89 = CASE WHEN @v161slivepositiontaking_89<0 THEN 0 ELSE @v161slivepositiontaking_89 END,
	@v161slivepositiontaking_90 = CASE WHEN @v161slivepositiontaking_90<0 THEN 0 ELSE @v161slivepositiontaking_90 END

--don't update s1 for member under master was set i3=1(normal)
UPDATE cs3 with(rowlock,updlock)
SET cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																			WHEN 83 THEN @v161spositiontaking_83
																			WHEN 86 THEN @v161spositiontaking_86
																			WHEN 88 THEN @v161spositiontaking_88
																			ELSE 0 END
											ELSE cs3.spositiontaking END
from custsetting3rd cs3 INNER JOIN custinfo c with(nolock) on cs3.custid = c.custid
	 INNER JOIN custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
where cs3.custid =@custid and c.roleid = 1 and mcs3.isautopositiontaking = 0	

UPDATE cs3 with (ROWLOCK, UPDLOCK)
set
	cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																				WHEN 86 THEN @v161slivepositiontaking_86 
																				WHEN 87 THEN @v161slivepositiontaking_87 
																				WHEN 89 THEN @v161slivepositiontaking_89
																				WHEN 90 THEN @v161slivepositiontaking_90
																				ELSE cs3.slivepositiontaking END 
												 ELSE cs3.slivepositiontaking END
from custsetting3rd cs3 INNER JOIN custinfo c (nolock) on cs3.custid = c.custid
	INNER JOIN custsetting3rd mcs3 (nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
where cs3.custid=@custid and c.roleid = 1 and mcs3.isautolivepositiontaking = 0

EXEC dbo.Acc_CustomerUpdMember_AutoPositiontaking_161
			@custid = @custid,

			@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
			@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
			@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
			@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
			@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
			@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
			@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
			@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
			@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

			@isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
			@isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,
			@isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
			@isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
			@isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
			@isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
			@isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
			@isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
			@isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,

			@language = @language,
			@userid = @userid

EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking_161
	@custid = @custid, 
	@recommEND = @recommEND, 
	@mrecommEND = @mrecommEND, 
	@srecommEND = @srecommEND,
	@updautosuper = 0
	
SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)

DECLARE @LogSPData varchar(4000), @TrackingValue2 varchar(4000)

SELECT @LogSPData = '<Acc_CustomerUpdMember_PositionTaking_Super_161><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

'<au a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMember_PositionTaking_Super_161>'

SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_PositionTaking_Super_161><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

'<au a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) +
'" /></Acc_CustomerUpdMember_PositionTaking_Super_161>'

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_161] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_161] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_161] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_161] TO [vnteam] 