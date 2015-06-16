ALTER PROCEDURE [dbo].Acc_CustomerUpdMember_PositionTaking_Super_8
	@CustID INT,--memberid
	@UserID int,

	@v8spositiontaking_1 SMALLMONEY OUTPUT,
	@v8spositiontaking_3 SMALLMONEY OUTPUT,
	@v8spositiontaking_20 SMALLMONEY OUTPUT,

	@auto_v8spositiontaking_1 SMALLMONEY = 0,
	@auto_v8spositiontaking_3 SMALLMONEY = 0,
	@auto_v8spositiontaking_20 SMALLMONEY = 0,

	@isauto_v8spositiontaking_1 BIT = 0,
	@isauto_v8spositiontaking_3 BIT = 0,
	@isauto_v8spositiontaking_20 BIT = 0,

	@isauto_v8smpositiontaking_1 BIT = 0,
	@isauto_v8smpositiontaking_3 BIT = 0,
	@isauto_v8smpositiontaking_20 BIT = 0,

	@language varchar(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20120528@Elodie
Task : Super edits Position taking of Baseball for Member 
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
	@v8mpositiontaking_1 SMALLMONEY,
	@v8mpositiontaking_3 SMALLMONEY,
	@v8mpositiontaking_20 SMALLMONEY,

	@old_v8spositiontaking_1 SMALLMONEY,
	@old_v8spositiontaking_3 SMALLMONEY,
	@old_v8spositiontaking_20 SMALLMONEY,

	@v8apositiontaking_1 SMALLMONEY,
	@v8apositiontaking_3 SMALLMONEY,
	@v8apositiontaking_20 SMALLMONEY,

	@v8spositiontaking_1_max SMALLMONEY,
	@v8spositiontaking_3_max SMALLMONEY,
	@v8spositiontaking_20_max SMALLMONEY,

	@old_auto_v8spositiontaking_1 SMALLMONEY,
	@old_auto_v8spositiontaking_3 SMALLMONEY,
	@old_auto_v8spositiontaking_20 SMALLMONEY,

	@old_isauto_v8spositiontaking_1 BIT,
	@old_isauto_v8spositiontaking_3 BIT,
	@old_isauto_v8spositiontaking_20 BIT

DECLARE @ErrType varchar(1000) 
----------------------------------------------------------
-- Check param
DECLARE @IsValid bit
SELECT @IsValid = 1

--Check Old_PT <> New_PT
SELECT @v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @old_v8spositiontaking_1 = spositiontaking, @old_auto_v8spositiontaking_1 = autopositiontaking, @old_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
SELECT @v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @old_v8spositiontaking_3 = spositiontaking, @old_auto_v8spositiontaking_3 = autopositiontaking, @old_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
SELECT @v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @old_v8spositiontaking_20 = spositiontaking, @old_auto_v8spositiontaking_20 = autopositiontaking, @old_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8


IF
	@v8spositiontaking_1 = @old_v8spositiontaking_1 AND
	@v8spositiontaking_3 = @old_v8spositiontaking_3 AND
	@v8spositiontaking_20 = @old_v8spositiontaking_20 AND
	
	@auto_v8spositiontaking_1 = @old_auto_v8spositiontaking_1 AND
	@auto_v8spositiontaking_3 = @old_auto_v8spositiontaking_3 AND
	@auto_v8spositiontaking_20 = @old_auto_v8spositiontaking_20 AND
	
	@isauto_v8spositiontaking_1 = @old_isauto_v8spositiontaking_1 AND
	@isauto_v8spositiontaking_3 = @old_isauto_v8spositiontaking_3 AND
	@isauto_v8spositiontaking_20 = @old_isauto_v8spositiontaking_20
BEGIN
	SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	return
END 

if 
	   @v8spositiontaking_1 <0 OR @v8spositiontaking_1 >0.9
	OR @v8spositiontaking_3 <0 OR @v8spositiontaking_3 >0.9
	OR @v8spositiontaking_20 <0	OR @v8spositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
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

SELECT @ErrType = ''
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
from custoverride AS co with (NOLOCK) 
inner join
	(
				SELECT 8 AS sporttype, 1 AS bettype, @auto_v8spositiontaking_1 AS autopositiontaking, @isauto_v8spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	UNION ALL	SELECT 8 AS sporttype, 3 AS bettype, @auto_v8spositiontaking_3 AS autopositiontaking, @isauto_v8spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	UNION ALL	SELECT 8 AS sporttype, 20 AS bettype, @auto_v8spositiontaking_20 AS autopositiontaking, @isauto_v8spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
	) AS b on co.sporttype=b.sporttype and co.bettype=b.bettype
INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where co.custid = @srecommend and b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking

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
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10)) + '<br>'
from custsetting AS cs with (NOLOCK) inner join
	(
				SELECT 1 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
	UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
	) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend and cs.spositiontaking<b.autopositiontaking
	
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
SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10)) + '<br>'
from custsetting AS cs with (NOLOCK) inner join
	(
				SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
	UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
	) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
	INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
where cs.custid = @srecommend and cs.spositiontaking<b.positiontaking
	
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

SELECT @v8spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=8
SELECT @v8spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=8
SELECT @v8spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=8

SELECT 
	@v8spositiontaking_1 = CASE WHEN @v8mpositiontaking_1+@v8spositiontaking_1+@v8apositiontaking_1>@v8spositiontaking_1_max THEN @v8spositiontaking_1_max-@v8mpositiontaking_1-@v8apositiontaking_1 ELSE @v8spositiontaking_1 END,
	@v8spositiontaking_3 = CASE WHEN @v8mpositiontaking_3+@v8spositiontaking_3+@v8apositiontaking_3>@v8spositiontaking_3_max THEN @v8spositiontaking_3_max-@v8mpositiontaking_3-@v8apositiontaking_3 ELSE @v8spositiontaking_3 END,
	@v8spositiontaking_20 = CASE WHEN @v8mpositiontaking_20+@v8spositiontaking_20+@v8apositiontaking_20>@v8spositiontaking_20_max THEN @v8spositiontaking_20_max-@v8mpositiontaking_20-@v8apositiontaking_20 ELSE @v8spositiontaking_20 END

SELECT 
	@v8spositiontaking_1 = CASE WHEN @v8spositiontaking_1<0 THEN 0 ELSE @v8spositiontaking_1 END,
	@v8spositiontaking_3 = CASE WHEN @v8spositiontaking_3<0 THEN 0 ELSE @v8spositiontaking_3 END,
	@v8spositiontaking_20 = CASE WHEN @v8spositiontaking_20<0 THEN 0 ELSE @v8spositiontaking_20 END

--don't update s1 for member under master was set i3=1(normal)
UPDATE cs WITH (ROWLOCK, UPDLOCK)
SET
	cs.spositiontaking = CASE cs.sporttype WHEN 8 THEN case cs.bettype 
																WHEN 1 THEN @v8spositiontaking_1 
																WHEN 3 THEN @v8spositiontaking_3 
																WHEN 20 THEN @v8spositiontaking_20 
																ELSE 0 END
											ELSE cs.spositiontaking END
FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
	INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
WHERE cs.custid=@custid and c.roleid = 1 and scs.isautopositiontaking = 0

EXEC dbo.Acc_CustomerUpdMember_AutoPositiontaking_8
			@custid = @custid,

			@auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
			@auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,
			@auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,

			@isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
			@isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
			@isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,

			@language = @language,
			@userid = @userid

EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking_8
	@custid = @custid, 
	@recommEND = @recommEND, 
	@mrecommEND = @mrecommEND, 
	@srecommEND = @srecommEND,
	@updautosuper = 0
	
SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)

DECLARE @LogSPData varchar(4000), @TrackingValue2 varchar(4000)

SELECT @LogSPData = '<Acc_CustomerUpdMember_PositionTaking_Super_8><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 AS varchar(50)),space(1)) + '" />' +

'<au a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMember_PositionTaking_Super_8>'

SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_PositionTaking_Super_8><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

'<s v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 AS varchar(50)),space(1)) + '" />' +

'<au a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" />' +

--i1
'<ia isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + 
'" /></Acc_CustomerUpdMember_PositionTaking_Super_8>'

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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_8] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_8] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_8] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_PositionTaking_Super_8] TO [vnteam] 