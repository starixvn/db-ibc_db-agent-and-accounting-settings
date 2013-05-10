ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_CommissionHR]
	@custid INT,-- masterId
	@v151discount_31 DECIMAL(9,8),--commission for tote.
	@v151discount_41 DECIMAL(9,8),--commission for OT.
	@v151discount_51 DECIMAL(9,8)=0, --comm for HR AU
	@v152discount_41 DECIMAL(9,8)=0, --comm for Greyhound UK
	@v152discount_51 DECIMAL(9,8)=0, --comm for Greyhound AU
	@v153discount_51 DECIMAL(9,8)=0, --comm for Harness AU
	
	@UpdateMultiple BIT = 0,
	@Updatediscountv151_31 BIT = 1,
	@Updatediscountv151_41 BIT = 1,
	@Updatediscountv151_51 BIT = 1,
	@Updatediscountv152_41 BIT = 1,
	@Updatediscountv152_51 BIT = 1,	
	@Updatediscountv153_51 BIT = 1,	
		
	@SubAccID INT = 0, --Sub-AccountID
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20081023@VinhTruong
Task : Update Master's commission for Horseracing
DB: DBTXN/bodb02

Revisions:
	- 20090515@Phuc: commission for tote and fixed odds.
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20110113@Henry: Update Comm for Greyhound and Harness
	- 20110509@Johnson: Update error message for Thai Version
	- 20110516@Johnson: write log for old setting
	- 20111104@TOM: Apply Multiple Edit Racing PT.
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: write log on DBTXN if DBLOG failure
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

--Check Param
if (@UpdateMultiple = 0 or @Updatediscountv151_31 = 1 or @Updatediscountv151_41 = 1 or @Updatediscountv151_51 = 1)
BEGIN --@Updatediscountv151
	IF (@v151discount_31 < 0 OR @v151discount_31 > 0.01) and @Updatediscountv151_31 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (SA Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](2,@Language)
					END, @ErrCode = 101
		RETURN
	END

	IF (@v151discount_41 < 0 OR @v151discount_41 > 0.01) and @Updatediscountv151_41 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (UK/Irish Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](3,@Language)
					END, @ErrCode = 101
		RETURN
	END
	IF (@v151discount_51 < 0 OR @v151discount_51 > 0.01) and @Updatediscountv151_51 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Tote).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](4,@Language)
					END, @ErrCode = 101
		RETURN
	END
END--@Updatediscountv151

if (@UpdateMultiple = 0 or @Updatediscountv152_41 = 1 or @Updatediscountv152_51 = 1)
BEGIN --@Updatediscountv152
	IF (@v152discount_41 < 0 OR @v152discount_41 > 0.01) and @Updatediscountv152_41 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (UK/Irish Greyhounds).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](5,@Language)
					END, @ErrCode = 101
		RETURN
	END
	IF (@v152discount_51 < 0 OR @v152discount_51 > 0.01) and @Updatediscountv152_51 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Greyhound).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](6,@Language)
					END, @ErrCode = 101
		RETURN
	END
END--@Updatediscountv152

if (@UpdateMultiple = 0 or @Updatediscountv153_51 = 1)
BEGIN --@Updatediscountv153
	IF (@v153discount_51 < 0 OR @v153discount_51 > 0.01) and @Updatediscountv153_51 = 1
	BEGIN		
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate (Aust Harness).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](7,@Language)
					END, @ErrCode = 101
		RETURN
	END
END --@Updatediscountv153



---------------------------------------
DECLARE @srecommend INT, @username VARCHAR(40), 
	@db_v151discount_31 DECIMAL(9,8), @db_v151discount_41 DECIMAL(9,8),
	@db_v151discount_51 DECIMAL(9,8), @db_v152discount_41 DECIMAL(9,8),
	@db_v152discount_51 DECIMAL(9,8), @db_v153discount_51 DECIMAL(9,8)
SELECT @username = username,
	@srecommend = srecommend
FROM custinfo WITH (NOLOCK)
WHERE custid = @custid AND roleid = 3

if (@UpdateMultiple = 0 or @Updatediscountv151_31 = 1 or @Updatediscountv151_41 = 1 or @Updatediscountv153_51 = 1)
BEGIN --@@Updatediscountv151
	if (@Updatediscountv151_31 = 1)
		SELECT @db_v151discount_31 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 31 and sporttype = 151
	if (@Updatediscountv151_41 = 1)
		SELECT @db_v151discount_41 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 and sporttype = 151
	if (@Updatediscountv151_51 = 1)
		SELECT @db_v151discount_51 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 and sporttype = 151
END --@@Updatediscountv151

if (@UpdateMultiple = 0 or @Updatediscountv152_41 = 1 or @Updatediscountv152_51 = 1)
BEGIN --@@Updatediscountv152
	if (@Updatediscountv152_41 = 1)
		SELECT @db_v152discount_41 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 and sporttype = 152
	if (@Updatediscountv152_51 = 1)
		SELECT @db_v152discount_51 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 and sporttype = 152
END --@@Updatediscountv152

if (@UpdateMultiple = 0 or @Updatediscountv153_51 = 1)
BEGIN --@@Updatediscountv153
	if (@Updatediscountv152_41 = 1)
		SELECT @db_v153discount_51 = adiscount	FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 and sporttype = 153
END --@@Updatediscountv153

-- Check whether user edits commission or not - If not - RETURN 
--20090305: Thien comment out the make sure the commission is updated correctly
--IF @db_UKComm = @UKComm and @db_OtherComm = @OtherComm 
--	RETURN 

---------------------------------------

---------------------------------------
if (@UpdateMultiple = 0 or @Updatediscountv151_31 = 1 or @Updatediscountv151_41 = 1 or @Updatediscountv151_51 = 1)
BEGIN --@Updatediscountv151
	IF (@db_v151discount_31 <> @v151discount_31) and @Updatediscountv151_31 = 1
	BEGIN
		--Get g3=g4 if g3>g4
		SELECT @v151discount_31 = CASE WHEN @v151discount_31 >sdiscount THEN sdiscount ELSE @v151discount_31 END
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype=31 AND sporttype = 151
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v151discount_31
		WHERE custid=@custid AND bettype IN(31,32) AND sporttype = 151
		IF (@@ERROR <> 0)
		BEGIN
		
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 102
			RETURN
		END
		---------------------------------------
		--Update g2 = g3 if g2>g3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v151discount_31 
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(31,32) AND cs.sporttype = 151 AND discount> @v151discount_31
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 103					 
			
			RETURN
		END

		---------------------------------------
		--Update g3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET adiscount = @v151discount_31
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 	
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(31,32) 
			AND cs.sporttype = 151
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 105	
			
			RETURN
		END
	END 

	IF (@db_v151discount_41 <> @v151discount_41)and  @Updatediscountv151_41 = 1
	BEGIN 
		--Get m3=s4 if m3>s4
		SELECT @v151discount_41 = CASE WHEN @v151discount_41 > sdiscount THEN sdiscount ELSE @v151discount_41 END 
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 41 AND sporttype = 151 
		
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v151discount_41 
		WHERE custid=@custid AND bettype IN(41,42) AND sporttype = 151 
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END
		---------------------------------------
		--Update a2 = m3 if a2>m3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v151discount_41
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(41,42) AND cs.sporttype = 151 AND discount>@v151discount_41
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104				 
			
			RETURN
		END
		
		
		
		---------------------------------------
		--Update m3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    adiscount = @v151discount_41
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(41,42) 
			AND cs.sporttype = 151
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106
			RETURN
		END
	END 
	---------------------------------------
	IF (isnull(@db_v151discount_51,0) <> @v151discount_51) and @Updatediscountv151_51 = 1
	BEGIN 
		--Get m3=s4 if m3>s4
		SELECT @v151discount_51 = CASE WHEN @v151discount_51 > sdiscount THEN sdiscount ELSE @v151discount_51 END 
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 51 AND sporttype = 151 
		
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v151discount_51 
		WHERE custid=@custid AND bettype IN(51,52) AND sporttype = 151 
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END
		---------------------------------------
		--Update a2 = m3 if a2>m3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v151discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 151 AND discount>@v151discount_51
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104				 
			
			RETURN
		END
		
		
		
		---------------------------------------
		--Update m3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    adiscount = @v151discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(51,52) 
			AND cs.sporttype = 151
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106
			RETURN
		END
	END 
END --@Updatediscountv151	
	------------------------------------------
if (@UpdateMultiple = 0 or @Updatediscountv152_41 = 1 or @Updatediscountv152_51 = 1)
BEGIN --@Updatediscountv152	
	IF (isnull(@db_v152discount_41,0) <> @v152discount_41) and @Updatediscountv152_41 = 1
	BEGIN 
		--Get m3=s4 if m3>s4
		SELECT @v152discount_41 = CASE WHEN @v152discount_41 > sdiscount THEN sdiscount ELSE @v152discount_41 END 
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 41 AND sporttype = 152 
		
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v152discount_41 
		WHERE custid=@custid AND bettype IN(41,42) AND sporttype = 152 
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END
		---------------------------------------
		--Update a2 = m3 if a2>m3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v152discount_41
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(41,42) AND cs.sporttype = 152 AND discount>@v152discount_41
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104				 
			
			RETURN
		END
		
		
		
		---------------------------------------
		--Update m3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    adiscount = @v152discount_41
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(41,42) 
			AND cs.sporttype = 152
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106
			RETURN
		END
	END 
	
	-----------------------------------------
	
	IF (isnull(@db_v152discount_51,0) <> @v152discount_51) and @Updatediscountv152_51 = 1
	BEGIN 
		--Get m3=s4 if m3>s4
		SELECT @v152discount_51 = CASE WHEN @v152discount_51 > sdiscount THEN sdiscount ELSE @v152discount_51 END 
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 51 AND sporttype = 152 
		
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v152discount_51 
		WHERE custid=@custid AND bettype IN(51,52) AND sporttype = 152 
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END
		---------------------------------------
		--Update a2 = m3 if a2>m3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v152discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 152 AND discount>@v152discount_51
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104				 
			
			RETURN
		END
		
		
		
		---------------------------------------
		--Update m3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    adiscount = @v152discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(51,52) 
			AND cs.sporttype = 152
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106
			RETURN
		END
	END 
END--@Updatediscountv152		
	------------------------------------------

if (@UpdateMultiple = 0 or @Updatediscountv153_51 = 1)
BEGIN --@Updatediscountv153
	IF (isnull(@db_v153discount_51,0) <> @v153discount_51) and @Updatediscountv153_51 = 1
	BEGIN 
		--Get m3=s4 if m3>s4
		SELECT @v153discount_51 = CASE WHEN @v153discount_51 > sdiscount THEN sdiscount ELSE @v153discount_51 END 
		FROM CustSetting3rd AS cs WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = 51 AND sporttype = 153 
		
		--Update @Master: g3, m3
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET    adiscount = @v153discount_51 
		WHERE custid=@custid AND bettype IN(51,52) AND sporttype = 153 
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 109
			RETURN
		END
		---------------------------------------
		--Update a2 = m3 if a2>m3 at agent
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    discount = @v153discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs.custid = ci.custid
		WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND cs.bettype IN(51,52) AND cs.sporttype = 153 AND discount>@v153discount_51
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104				 
			
			RETURN
		END
		
		
		
		---------------------------------------
		--Update m3 @ member level
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
		SET    adiscount = @v153discount_51
		FROM CustSetting3rd AS cs
		INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
		WHERE c.mrecommend = @custid 
			AND c.recommend <> 52466
			AND c.roleid = 1 
			AND cs.bettype IN(51,52) 
			AND cs.sporttype = 153
		IF (@@ERROR <> 0)
		BEGIN
			
			SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 106
			RETURN
		END
	END 
END --@Updatediscountv153	
	
	------------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = CASE WHEN @UpdateMultiple = 1 
								OR (	(cs.sporttype=151 AND @Updatediscountv151_31 = 0 AND @Updatediscountv151_41 = 0 AND @Updatediscountv151_51 = 0) 
									OR  (cs.sporttype=152 AND @Updatediscountv152_41 = 0 AND @Updatediscountv152_51 = 0) 
									OR  (cs.sporttype=153 AND @Updatediscountv153_51 = 0))
								THEN discount 		
						ELSE adiscount END
	FROM CustSetting3rd AS cs
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.mrecommend = @custid AND c.roleid = 1 AND cs.discount>cs.adiscount AND sporttype IN (151,152,153)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 107
		RETURN
	END

	---------------------------------------
	--At member level, update playerdiscount = discount  if playerdiscount > discount
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		playerdiscount = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @Updatediscountv151_31 = 0 AND @Updatediscountv151_41 = 0 AND @Updatediscountv151_51 = 0) 
									OR  (cs.sporttype=152 AND @Updatediscountv152_41 = 0 AND @Updatediscountv152_51 = 0) 
									OR  (cs.sporttype=153 AND @Updatediscountv153_51 = 0))
								THEN playerdiscount
							ELSE discount END
	FROM CustSetting3rd AS cs
	INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
	WHERE c.mrecommend = @custid AND c.roleid = 1 AND cs.playerdiscount>cs.discount AND sporttype in (151,152,153)
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 108
		RETURN
	END


Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)

Select @LogSPData = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +

'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValueDB = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@db_v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@db_v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@db_v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@db_v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@db_v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@db_v153discount_51 as varchar(50)),space(1)) + '" ' +

'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
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
		@ActionID = 210,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
	'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
	'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
	'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
	'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
	'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +

	'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
	'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 210,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [vnteam]

