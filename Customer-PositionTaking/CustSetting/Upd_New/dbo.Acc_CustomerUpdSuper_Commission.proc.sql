ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_Commission]
	@custid INT,-- superid
	
	@groupa DECIMAL(9,8),
	@groupb DECIMAL(9,8),
	@groupc DECIMAL(9,8),
	@groupd DECIMAL(9,8),
	@discountcs DECIMAL(9,8),	
	@discount1x2 DECIMAL(9,8)=0,
	@discountHRFixedOdds DECIMAL(9,8)=0,
	@discountnumber DECIMAL(9,8)=0,
	@updatecomm_old BIT =1,
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Update Super's Commission
DB: DBTXN/bodb02
Original:[Acc_CustomerUpdSuper_Commission]

Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100901@Henry: Update commission for Number Game
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write log Old values
	- 20110930@Johnson: Add more group under Won currency
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
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

declare @err1 int, @err2 int

declare @Old_groupa DECIMAL(9,8),
	@Old_groupb DECIMAL(9,8),
	@Old_groupc DECIMAL(9,8),
	@Old_groupd DECIMAL(9,8),
	@Old_discountcs DECIMAL(9,8),	
	@Old_discount1x2 DECIMAL(9,8),
	@Old_discountHRFixedOdds DECIMAL(9,8),
	@Old_discountnumber DECIMAL(9,8)

IF 
	@discountcs<0 OR @discountcs>0.2
		OR @discount1x2<0 OR @discount1x2>0.2
		OR @discountHRFixedOdds<0 OR @discountHRFixedOdds>0.2
		OR @discountnumber<0 OR @discountnumber>0.2
		OR @groupa<0 OR @groupa>0.2
		OR @groupb<0 OR @groupb>0.2
		OR @groupc<0 OR @groupc>0.2
		OR @groupd<0 OR @groupd>0.2
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
				END, @ErrCode = 101
	RETURN
END

--Check modify group(other) or financial
IF @updatecomm_old = 1
BEGIN

	SELECT 		
		@Old_groupa = groupa, 
		@Old_groupb = groupb, 
		@Old_groupc = groupc, 
		@Old_groupd = groupd 
	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
	
	SELECT @Old_discountcs = sdiscount FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 4
	SELECT @Old_discount1x2 = sdiscount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 5
	SELECT @Old_discountHRFixedOdds = sdiscount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 154 AND bettype = 20
	SELECT @Old_discountnumber = sdiscount FROM custsetting3rd AS cs3 WITH (NOLOCK) WHERE custid = @custid AND sporttype = 161 AND bettype = 81
	
	---------------------------------------------------
	--Update @Super: g4, s4
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
	SET
		groupa = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa ELSE groupa END,
		groupb = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupb ELSE groupb END,
		groupc = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupc ELSE groupc END,
		groupd = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupd ELSE groupd END,
		sdiscount = CASE WHEN bettype IN (4,6,9,10,20,21,22) and sporttype <> 154 THEN @discountcs WHEN bettype = 5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds ELSE sdiscount END
	WHERE custid = @custid 
	
	SELECT @err1 = @@ERROR
		
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
	SET
		sdiscount = @discountnumber
	WHERE custid = @custid and sporttype = 161
	
	SELECT @err2 = @@ERROR
	

	IF (@err1 <> 0 or @err2 <> 0)
	BEGIN	
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 102
		RETURN
	END
	
	---------------------------------------------------
	--Update g3=g4 if g3>g4
	--		 g2=g4 if g2>g4
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		groupa = @groupa 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid IN (2,3) 
		AND custsetting.bettype IN(1,2,3,7,8) 
		AND groupa>@groupa
	
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		groupb = @groupb 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid IN (2,3) 
		AND custsetting.bettype IN(1,2,3,7,8) 
		AND groupb>@groupb
	
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		groupc = @groupc 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid IN (2,3) 
		AND custsetting.bettype IN(1,2,3,7,8) 
		AND groupc>@groupc
	
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		groupd = @groupd 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid IN (2,3) 
		AND custsetting.bettype IN(1,2,3,7,8) 
		AND groupd>@groupd
		
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 103
		RETURN
	END
	---------------------------------------------------
	--Update g4 to Member level
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		sdiscount = CASE WHEN c.ugroup IN ('a','hka','dea') THEN @groupa 
						 WHEN c.ugroup IN ('b','hkb','deb') THEN @groupb 
						 WHEN c.ugroup IN ('c','hkc','dec') THEN @groupc 
						 WHEN c.ugroup IN ('d','hkd','ded') THEN @groupd ELSE @groupa END 
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND custsetting.bettype IN(1,2,3,7,8) 

	IF (@@ERROR <> 0) 
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 104	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		sdiscount =  @discountcs 
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND bettype IN(4,6,9,10,20,21,22) and sporttype <> 154
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 105	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level --1x2
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		sdiscount =  @discount1x2 
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND bettype = 5
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 105	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level --HRFixedOdds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		sdiscount =  @discountHRFixedOdds
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND bettype = 20  and sporttype = 154
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 105	
		RETURN
	END
	
	---------------------------------------------------
	--Update s4 to member level --number game
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
	SET 
		sdiscount = @discountnumber
	FROM custsetting3rd INNER JOIN customer AS c WITH (NOLOCK) ON custsetting3rd.custid = c.custid	
	WHERE c.srecommend = @custid
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND sporttype = 161
		
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 105	
		RETURN
	END
	
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discountcs 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 3 
		AND bettype IN(4,6,9,10,20,21,22) and sporttype <> 154
		AND adiscount>@discountcs 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 106	
		RETURN
	END
	
	---------------------------------------------------
	--Update m3=s4 if m3>s4  --1x2
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discount1x2
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 3 
		AND bettype = 5 
		AND adiscount>@discount1x2 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 106	
		RETURN
	END

	---------------------------------------------------
	--Update m3=s4 if m3>s4  --HR Fixed Odds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discountHRFixedOdds
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 3 
		AND bettype = 20 and sporttype = 154
		AND adiscount>@discountHRFixedOdds 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 106	
		RETURN
	END
		
	---------------------------------------------------
	--Update m3=s4 if m3>s4  --number game
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discountnumber
	FROM custsetting3rd INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting3rd.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 3 
		AND sporttype = 161 
		AND adiscount>@discountnumber
		
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 106	
		RETURN
	END	
		 
	
	---------------------------------------------------
	--Update a2=s4 if a2>s4
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = @discountcs 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 2  
		AND bettype IN(4,6,9,10,20,21,22) and sporttype <> 154
		AND discount>@discountcs
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 107	
		RETURN
	END
	
	---------------------------------------------------
	--Update a2=s4 if a2>s4  --1x2
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = @discount1x2
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 2  
		AND bettype = 5 
		AND discount>@discount1x2
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 107	
		RETURN
	END

	---------------------------------------------------
	--Update a2=s4 if a2>s4  --HR Fixed Odds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = @discountHRFixedOdds
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 2  
		AND bettype = 20 and sporttype = 154
		AND discount>@discountHRFixedOdds
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 107	
		RETURN
	END
	
	---------------------------------------------------
	--Update a2=s4 if a2>s4  --number game
	
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = @discountnumber
	FROM custsetting3rd INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting3rd.custid = ci.custid
	WHERE ci.srecommend = @custid 
		AND ci.roleid = 2  
		AND sporttype = 161
		AND discount>@discountnumber
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 107	
		RETURN
	END
	

	---------------------------------------------------
	--At member level, update adiscount = sdiscount  if adiscount > sdiscount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = sdiscount
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting.adiscount>custsetting.sdiscount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 108
		RETURN
	END
	
	---------------------------------------------------
	--At member level, update adiscount = sdiscount  if adiscount > sdiscount  (Number Game)
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = sdiscount
	FROM custsetting3rd INNER JOIN customer AS c WITH (NOLOCK) ON custsetting3rd.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting3rd.adiscount>custsetting3rd.sdiscount
		AND custsetting3rd.sporttype = 161
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 108
		RETURN
	END
	
	
	

	---------------------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = adiscount
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting.discount>custsetting.adiscount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 109	
		RETURN
	END
	
	---------------------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount -- Number Game
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = adiscount
	FROM custsetting3rd INNER JOIN customer AS c WITH (NOLOCK) ON custsetting3rd.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting3rd.discount>custsetting3rd.adiscount
		AND custsetting3rd.sporttype = 161
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 109	
		RETURN
	END

	---------------------------------------------------
	--At member level, update playerdiscount = discount  if playerdiscount > discount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		playerdiscount = discount
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting.playerdiscount>custsetting.discount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 110	
		RETURN
	END
	
	---------------------------------------------------
	--At member level, update playerdiscount = discount  if playerdiscount > discount --Number Game
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		playerdiscount = discount
	FROM custsetting3rd INNER JOIN customer AS c WITH (NOLOCK) ON custsetting3rd.custid = c.custid
	WHERE c.srecommend = @custid 
		AND c.roleid = 1 
		AND custsetting3rd.playerdiscount>custsetting3rd.discount
		AND custsetting3rd.sporttype = 161
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 110	
		RETURN
	END
END			
	
--204	Acc_CustomerUpdSuper_Commission	Update Sportsbook Commission for super
Declare @LogSPData varchar(8000)
Declare @TrackingValue2 varchar(8000)
Select @LogSPData = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

Select @TrackingValue2 = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'


set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	--Log customer info 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 204,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

	Select @TrackingValue2 = '<Acc_CustomerUpdSuper_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

	--Log customer info 
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 204,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration	
END CATCH
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_Commission] TO [vnteam] AS [dbo]