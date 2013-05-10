
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_CommissionHR]
	@custid INT,-- superid
	@v151discount_31 DECIMAL(9,8),--commission for tote.
	@v151discount_41 DECIMAL(9,8),--commission for FO.	

	@v151discount_51 DECIMAL(9,8) = 0,
	@v152discount_41 DECIMAL(9,8) = 0,
	@v152discount_51 DECIMAL(9,8) = 0,
	@v153discount_51 DECIMAL(9,8) = 0,

	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS

/*
Created: 20081023@VinhTruong
Task : Update Super's commission for Horseracing.
DB: DBTXN/bodb02

Revisions:
	- 20090515@Phuc: commission for tote and fixed odds.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20110111@Lukas: Add setting
						+ AU Horse racing
						+ UK, AU Greyhound racing
						+ AU Harness racing
	- 20110509@Lukas: Add message translation(Thai version)
	- 20110511@Johnson: Write log for old setting values
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: write log on DBTXN if DBLOG failure
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

IF @v151discount_31 <0 OR @v151discount_31 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (SA Tote).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](2,@Language)
				END, @ErrCode = 101
	RETURN
END
IF @v151discount_41 <0 OR @v151discount_41 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (UK/Irish Tote).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](3,@Language)
				END, @ErrCode = 102
	RETURN
END
IF @v151discount_51 < 0 OR @v151discount_51 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (Aust Tote).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](4,@Language)
				END, @ErrCode = 103
	RETURN
END
IF @v152discount_41 < 0 OR @v152discount_41 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (UK/Irish Greyhounds).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](5,@Language)
				END, @ErrCode = 104
	RETURN
END
IF @v152discount_51 < 0 OR @v152discount_51 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (Aust Greyhound).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](6,@Language)
				END, @ErrCode = 105
	RETURN
END
IF @v153discount_51 < 0 OR @v153discount_51 > 0.01
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate (Aust Harness).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](7,@Language)
				END, @ErrCode = 106
	RETURN
END

DECLARE @db_v151discount_31 DECIMAL(9,8) , 
		@db_v151discount_41 DECIMAL(9,8),
		@db_v151discount_51 DECIMAL(9,8),
		@db_v152discount_41 DECIMAL(9,8),
		@db_v152discount_51 DECIMAL(9,8),
		@db_v153discount_51 DECIMAL(9,8)

SELECT @db_v151discount_31 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 31 AND sporttype = 151
SELECT @db_v151discount_41 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 AND sporttype = 151
SELECT @db_v151discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 151
SELECT @db_v152discount_41 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 AND sporttype = 152
SELECT @db_v152discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 152
SELECT @db_v153discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 153

-- Check whether user updates or not - RETURN if not change commission
IF	@db_v151discount_31 = @v151discount_31 
	AND 
	@db_v151discount_41 = @v151discount_41 
	AND 
	@db_v151discount_51 = @v151discount_51
	AND 
	@db_v152discount_41 = @v152discount_41
	AND 
	@db_v152discount_51 = @v152discount_51
	AND 
	@db_v153discount_51 = @v153discount_51
	
	RETURN 

---------------------------------------------------
--Update @Super: g4, s4
UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
SET
	sdiscount = CASE WHEN bettype IN (31,32) AND sporttype = 151 THEN @v151discount_31 
					 WHEN bettype IN (41,42) AND sporttype = 151 THEN @v151discount_41 
					 WHEN bettype IN (51,52) AND sporttype = 151 THEN @v151discount_51 
					 WHEN bettype IN (41,42) AND sporttype = 152 THEN @v152discount_41
					 WHEN bettype IN (51,52) AND sporttype = 152 THEN @v152discount_51
					 WHEN bettype IN (51,52) AND sporttype = 153 THEN @v153discount_51
					 ELSE sdiscount END
WHERE custid=@custid 
		and sporttype in (151,152,153)

IF (@@ERROR <> 0)
BEGIN	
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END	, @ErrCode = 107
	RETURN
END
--Update commission (tote).
IF @db_v151discount_31 <> @v151discount_31
BEGIN
	---------------------------------------------------
	--Update g3=g4 if g3>g4 

	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v151discount_31 THEN @v151discount_31 ELSE adiscount END
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN(31,32) AND cs.sporttype = 151
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 108
		RETURN
	END

	---------------------------------------------------
	--Update g2=g4 if g2>g4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET discount = CASE WHEN cs.discount > @v151discount_31  THEN  @v151discount_31 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(31,32) AND cs.sporttype = 151
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 109
		RETURN
	END

	---------------------------------------------------


	--Update g4 at Member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET sdiscount = @v151discount_31
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(31,32) 
		AND cs.sporttype = 151
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 110	
		RETURN
	END
END

IF @db_v151discount_41 <> @v151discount_41--(fixed odds) 
BEGIN
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v151discount_41 THEN @v151discount_41 ELSE adiscount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (41,42) AND cs.sporttype = 151 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 111	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	discount = CASE WHEN cs.discount>@v151discount_41 THEN @v151discount_41 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(41,42) AND cs.sporttype = 151 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 112	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	 sdiscount = @v151discount_41
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(41,42) 
		AND cs.sporttype = 151
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 113	
		RETURN
	END
END
--- AU Horse racing
IF @db_v151discount_51 <> @v151discount_51
BEGIN	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v151discount_51 THEN @v151discount_51 ELSE adiscount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 151 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 114	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	discount = CASE WHEN cs.discount>@v151discount_51 THEN @v151discount_51 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 151 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 115
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	 sdiscount = @v151discount_51
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(51,52) 
		AND cs.sporttype = 151
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 116	
		RETURN
	END
END

---UK Greyhound racing
IF @db_v152discount_41 <> @v152discount_41
BEGIN
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v152discount_41 THEN @v152discount_41 ELSE adiscount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (41,42) AND cs.sporttype = 152 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 117	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	discount = CASE WHEN cs.discount>@v152discount_41 THEN @v152discount_41 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(41,42) AND cs.sporttype = 152 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 118	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	 sdiscount = @v152discount_41
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(41,42) 
		AND cs.sporttype = 152
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 119	
		RETURN
	END
END
---AU Greyhound racing
IF @db_v152discount_51 <> @v152discount_51
BEGIN
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v152discount_51 THEN @v152discount_51 ELSE adiscount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 152 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 120	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	discount = CASE WHEN cs.discount>@v152discount_51 THEN @v152discount_51 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 152 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 121	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	 sdiscount = @v152discount_51
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(51,52) 
		AND cs.sporttype = 152
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 122	
		RETURN
	END
END

-- AU Harness racing
IF @db_v153discount_51 <> @v153discount_51
BEGIN
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET adiscount = CASE WHEN cs.adiscount>@v153discount_51 THEN @v153discount_51 ELSE adiscount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 153 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 123	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	discount = CASE WHEN cs.discount>@v153discount_51 THEN @v153discount_51 ELSE discount END 
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid AND c.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 153 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 124	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET	 sdiscount = @v153discount_51
	FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs.bettype IN(51,52) 
		AND cs.sporttype = 153
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRANSACTION
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 125	
		RETURN
	END
END
---------------------------------------------------
--At member level, update adiscount = sdiscount  if adiscount > sdiscount
UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
SET adiscount = CASE WHEN cs.adiscount>cs.sdiscount THEN cs.sdiscount ELSE adiscount END 
FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
WHERE c.srecommend = @custid AND c.roleid = 1 AND sporttype IN (151,152,153)
--and cs.adiscount>cs.sdiscount
IF (@@ERROR <> 0)
BEGIN
	ROLLBACK TRANSACTION
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END, @ErrCode = 126
	RETURN
END

---------------------------------------------------
--At member level, update discount = adiscount  if discount > adiscount
UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
SET    discount = CASE WHEN cs.discount>cs.adiscount THEN adiscount ELSE discount END 
FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
WHERE c.srecommend = @custid AND c.roleid = 1 AND sporttype IN (151,152,153)
--and cs.discount>cs.adiscount
IF (@@ERROR <> 0)
BEGIN
	ROLLBACK TRANSACTION
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END, @ErrCode = 127	
	RETURN
END

---------------------------------------------------
--At member level, update playerdiscount = discount  if playerdiscount > discount
UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
SET    playerdiscount = CASE WHEN cs.playerdiscount>cs.discount THEN discount ELSE playerdiscount END 
FROM CustSetting3rd AS cs INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
WHERE c.srecommend = @custid AND c.roleid = 1  AND sporttype IN (151,152,153)
-- and cs.playerdiscount>cs.discount
IF (@@ERROR <> 0)
BEGIN
	ROLLBACK TRANSACTION
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END, @ErrCode = 128	
	RETURN
END



Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

SELECT @TrackingValueDB = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@db_v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@db_v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@db_v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@db_v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@db_v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@db_v153discount_51 as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'


set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log customer info 
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 209,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
	'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
	'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
	'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
	'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
	'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 209,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	
	
	

	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_CommissionHR] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_CommissionHR] TO [vnteam]



