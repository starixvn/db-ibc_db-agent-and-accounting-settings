ALTER PROCEDURE [dbo].[Acc_CustomerUpdCommissionFI]
	@custid INT,
	@roleid TINYINT,
	--v201
	@v201discount DECIMAL(9,8),
	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090415@Phuc
Task : Update FI's Commission
DB: DBTRANS.bodb02

Revisions:
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	
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

IF @v201discount<0 OR @v201discount>0.2
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Wrong discount.'
						WHEN 'CS' THEN N'折扣不正确.'
						WHEN 'CT' THEN N'折扣不正確.'
						WHEN 'TH' THEN N'การให้ส่วนลดไม่ถูกต้อง.'
						WHEN 'J' THEN N'Wrong discount.' 
						WHEN 'KO' THEN N'잘못된 수수료'
						ELSE N'Wrong discount.'
				END, @ErrCode = 101
	RETURN
END

DECLARE @username NVARCHAR(20), 
		@srecommend INT, 
		@mrecommend INT, 
		@recommend INT, 
		@v201discount_max DECIMAL(9,8)

SELECT @UserName  = username,
		@recommend = CASE WHEN @RoleID = 1 THEN recommend ELSE 0 END,
		@mrecommend = CASE WHEN @RoleID = 2 THEN mrecommend ELSE 0 END,
		@srecommend = CASE WHEN @RoleID = 3 THEN srecommend ELSE 0 END
FROM custinfo WITH (NOLOCK) 
WHERE CustID = @CustID AND RoleID = @RoleID

--------------------------------------------------------------------------
-----------------------------  Member  -----------------------------------
--------------------------------------------------------------------------
IF @roleid = 1
BEGIN
	--Get a2
	SELECT @v201discount_max = discount
	FROM CustSetting3rd WITH (NOLOCK)
	WHERE custid = @recommend AND sporttype = 201 AND bettype = 3

	--@playerdiscount>g2?g2:@playerdiscount 
	--@playerdiscountcs>a2?a2:@playerdiscountcs
	SELECT 
		@v201discount = CASE WHEN @v201discount > @v201discount_max THEN @v201discount_max ELSE @v201discount END
		
	---------------------------------------
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET	
		playerdiscount = @v201discount 
	WHERE custid=@custid 
		AND @recommend <> 52466
		AND sporttype = 201 
		AND bettype IN ( 2, 3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END	, @ErrCode = 102
		RETURN
	END
END


--------------------------------------------------------------------------
-----------------------------  Agent   -----------------------------------
--------------------------------------------------------------------------
IF @roleid = 2
BEGIN

	--Get a2=m3 if a2>m3
	SELECT 	
		@v201discount = CASE WHEN @v201discount > adiscount THEN adiscount ELSE @v201discount END
	FROM CustSetting3rd AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend AND bettype =3  AND sporttype = 201

	---------------------------------------

	---------------------------------------
	--Update @Master: g2, a2
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET
		discount = @v201discount
	WHERE custid=@custid AND sporttype = 201 AND bettype IN (2, 3)
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 102
		RETURN
	END

	---------------------------------------
	--Update a2 at Member level
	UPDATE cs
	SET 	cs.discount = @v201discount 
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
	WHERE ci.recommend = @custid 
		AND ci.recommend <> 52466
		AND ci.roleid = 1 
		AND sporttype = 201 
		AND bettype IN (2, 3)
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								WHEN 'CS' THEN N'更新程序不成功 !'
								WHEN 'CT' THEN N'更新程序不成功 !'
								WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
								WHEN 'J' THEN N'アップデート出来ません。'
								WHEN 'KO' THEN N'업데이트에 실패했습니다.'
								ELSE N'Update process is unsuccessful !'
							END, @ErrCode = 103
		RETURN
	END

	---------------------------------------
	--At member level, update playerdiscount = discount  if playerdiscount > discount
	UPDATE cs
	SET
		cs.playerdiscount = cs.discount 
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.recommend = @custid AND c.roleid = 1 AND cs.playerdiscount > cs.discount AND sporttype = 201 AND bettype IN (2, 3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น.'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 104
		RETURN
	END
END

--------------------------------------------------------------------------
-----------------------------  Master  -----------------------------------
--------------------------------------------------------------------------
IF @roleid = 3
BEGIN
	--Get m3=s4 if m3>s4 for 201 sporttype 
	SELECT @v201discount = CASE WHEN @v201discount > sdiscount THEN sdiscount ELSE @v201discount END
	FROM CustSetting3rd AS cs WITH (NOLOCK) 
	WHERE custid = @srecommend AND bettype =3 AND sporttype = 201
	--Update @Master: g3, m3
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET
		adiscount = @v201discount 
	WHERE custid=@custid 
		AND sporttype = 201 
		AND  bettype IN ( 2,3)
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END	, @ErrCode = 102
		RETURN
	END
	---------------------------------------
	--Update a2 = m3 if a2>m3
	UPDATE cs
	SET 	
		discount = @v201discount 
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 
		AND sporttype = 201 
		AND  bettype IN ( 2,3) 
		AND discount>@v201discount 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 104				 
		
		RETURN
	END
	---------------------------------------
	--Update m3 @ member level
	UPDATE cs
	SET 	
		adiscount = @v201discount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND sporttype = 201 
		AND  bettype IN ( 2,3)
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END	, @ErrCode = 106
		RETURN
	END
	---------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount
	UPDATE cs
	SET 	
		discount = adiscount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.mrecommend = @custid AND c.roleid = 1 AND cs.discount>cs.adiscount AND sporttype = 201 AND  bettype IN ( 2,3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END	, @ErrCode = 107
		RETURN
	END

	---------------------------------------
	--At member level, update playerdiscount = discount if playerdiscount > discount
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		playerdiscount = discount
	FROM CustSetting3rd AS cs INNER JOIN customer AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.mrecommend = @custid AND c.roleid = 1 AND cs.playerdiscount>cs.discount AND sporttype = 201 AND  bettype IN ( 2,3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 108
		RETURN
	END

END

--------------------------------------------------------------------------
-----------------------------  Super   -----------------------------------
--------------------------------------------------------------------------
IF @roleid = 4 
BEGIN
	---------------------------------------------------
	--Update @Super: s4(Financial)
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET
		sdiscount = @v201discount 
	WHERE custid = @custid 
		AND sporttype = 201 
		AND bettype IN (3,2)
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE cs 
	SET 	
		adiscount = @v201discount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 3 
		AND sporttype = 201 
		AND bettype IN (2,3) 
		AND adiscount>@v201discount
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 106	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE cs 
		SET discount = @v201discount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 2  
		AND sporttype = 201 
		AND bettype IN (2, 3) 
		AND discount>@v201discount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 107	
		RETURN
	END

	---------------------------------------------------
	--Update s4 to member level
	UPDATE cs 
	SET 	
		sdiscount =  @v201discount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND sporttype = 201 
		AND bettype IN (2,3)  
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 105	
		RETURN
	END

	---------------------------------------------------
	--At member level, update adiscount = sdiscount  if adiscount > sdiscount
	UPDATE cs
	SET 	
		adiscount = sdiscount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN customer AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND cs.adiscount>cs.sdiscount 
		AND sporttype = 201 
		AND bettype IN (2, 3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 108
		RETURN
	END

	---------------------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount
	UPDATE cs
	SET 	
		discount = adiscount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND cs.discount>cs.adiscount 
		AND sporttype = 201 
		AND bettype IN(2,3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 109	
		RETURN
	END

	---------------------------------------------------
	--At member level, update playerdiscount = discount  if playerdiscount > discount
	UPDATE cs
	SET 	
		playerdiscount = discount
	FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND cs.playerdiscount>cs.discount 
		AND sporttype = 201 
		AND bettype IN (2,3)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
			CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							WHEN 'CS' THEN N'更新程序不成功 !'
							WHEN 'CT' THEN N'更新程序不成功 !'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น !'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful !'
						END, @ErrCode = 110	
		RETURN
	END

END

Declare @LogSPData varchar(5000)
Select @LogSPData = '<Acc_CustomerUpdCommissionFI custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v201discount="'+ coalesce(cast(@v201discount as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log customer info 
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 208,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdCommissionFI] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdCommissionFI] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdCommissionFI] TO vnteam