ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_Commission]
	@custid INT,-- masterId
	
	@groupa DECIMAL(9,8),
	@groupb DECIMAL(9,8),
	@groupc DECIMAL(9,8),
	@groupd DECIMAL(9,8),
	@discountcs DECIMAL(9,8),
	@discount1x2 DECIMAL(9,8)=0,
	@discountHRFixedOdds DECIMAL(9,8)=0,
	--- number game commission
	@discountnumber decimal(9,8) = 0,

	@updatecomm_old BIT = 1,
	@SubAccID INT = 0, --Sub-AccountID
	
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Update Master's Commission
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdMaster_Commission]

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100903@Lukas: Add number game commission
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write log Old values
	- 20110729@Lukas: Add three new number game's bettypes
	- 20110930@Johnson: Add more group under Won currency
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
Param's Explanation:
• @ErrCode:
    = 0: Update agent's commission successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

declare @Old_groupa DECIMAL(9,8),
	@Old_groupb DECIMAL(9,8),
	@Old_groupc DECIMAL(9,8),
	@Old_groupd DECIMAL(9,8),
	@Old_discountcs DECIMAL(9,8),
	@Old_discount1x2 DECIMAL(9,8),	
	@Old_discountHRFixedOdds DECIMAL(9,8),
	@Old_discountnumber decimal(9,8)
	
--Check Param
IF 
	@discountcs<0 OR @discountcs>0.2
	OR @discount1x2<0 OR @discount1x2>0.2
	OR @discountHRFixedOdds<0 OR @discountHRFixedOdds>0.2
	OR @discountnumber < 0 OR @discountnumber > 0.2
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

---------------------------------------
DECLARE @srecommend INT, @username VARCHAR(40)
SELECT @username = username,
	@srecommend = srecommend
FROM customer WITH (NOLOCK)
WHERE custid = @custid AND roleid = 3

--Check modify group(other) or financial
IF @updatecomm_old = 1
BEGIN

	SELECT 		
		@Old_groupa = groupa, 
		@Old_groupb = groupb, 
		@Old_groupc = groupc, 
		@Old_groupd = groupd 
	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
	
	SELECT @Old_discountcs = adiscount FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 4
	SELECT @Old_discount1x2 = adiscount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 5
	SELECT @Old_discountHRFixedOdds = adiscount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 154 AND bettype = 20	
	SELECT @Old_discountnumber = adiscount FROM custsetting3rd AS cs3 WITH (NOLOCK) WHERE custid = @custid AND sporttype = 161 AND bettype = 81
	
	--Get g3=g4 if g3>g4
	SELECT 
		@groupa = CASE WHEN @groupa>groupa THEN groupa ELSE @groupa END, 
		@groupb = CASE WHEN @groupb>groupb THEN groupb ELSE @groupb END, 
		@groupc = CASE WHEN @groupc>groupc THEN groupc ELSE @groupc END, 
		@groupd = CASE WHEN @groupd>groupd THEN groupd ELSE @groupd END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @srecommend AND bettype=1 AND sporttype=1  

	--Get m3=s4 if m3>s4
	SELECT @discountcs = CASE WHEN @discountcs > sdiscount THEN sdiscount ELSE @discountcs END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @srecommend AND bettype = 4 AND sporttype = 1
	---------------------------------------
	--Get m3=s4 if m3>s4 --1x2 
	SELECT @discount1x2 = CASE WHEN @discount1x2 > sdiscount THEN sdiscount ELSE @discount1x2 END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @srecommend AND bettype = 5 AND sporttype = 1
	
	---------------------------------------
	--Get m3=s4 if m3>s4 --HR Fixed Odds
	SELECT @discountHRFixedOdds = CASE WHEN @discountHRFixedOdds > sdiscount THEN sdiscount ELSE @discountHRFixedOdds END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @srecommend AND bettype = 20 AND sporttype = 154
	
	---------------------------------------
	--Get m3=s4 if m3>s4 --number game
	SELECT @discountnumber = case when @discountnumber > sdiscount then sdiscount else @discountnumber end
	FROM custsetting3rd as cs3 with(nolock)
	WHERE custid = @srecommend AND bettype = 81 AND sporttype = 161
	---------------------------------------
	--Update @Master: g3, m3
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
	SET
		groupa = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa ELSE groupa END ,
		groupb = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupb ELSE groupb END ,
		groupc = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupc ELSE groupc END ,
		groupd = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupd ELSE groupd END ,
		adiscount = CASE WHEN bettype IN (4,6,9,10,20,21,22) AND sporttype <> 154 THEN @discountcs WHEN bettype = 5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds ELSE adiscount END
	WHERE custid=@custid 

	IF (@@ERROR <> 0) 
	BEGIN 
		
		SELECT @ErrMsg = @UserName + ': '+ 
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !' 
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 102 
		RETURN 
	END 

	-- number game commission - update master discount
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
	SET	adiscount = @discountnumber
	WHERE custid=@custid and sporttype = 161

	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 201
		RETURN
	END

	---------------------------------------
	--Update g2 = g3 if g2>g3
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		groupa = CASE WHEN groupa>@groupa THEN @groupa ELSE groupa END,
		groupb = CASE WHEN groupb>@groupb THEN @groupb ELSE groupb END,
		groupc = CASE WHEN groupc>@groupc THEN @groupc ELSE groupc END,
		groupd = CASE WHEN groupd>@groupd THEN @groupd ELSE groupd END
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 
		AND custsetting.bettype IN (1,2,3,7,8) 
		
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
	--Update a2 = m3 if a2>m3
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = CASE WHEN discount>@discountcs THEN @discountcs ELSE discount END 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 
		AND custsetting.bettype IN (4,6,9,10,20,21,22) and sporttype <> 154
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
	--Update a2 = m3 if a2>m3 --1x2
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = CASE WHEN discount>@discount1x2 THEN @discount1x2 ELSE discount END 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 
		AND custsetting.bettype = 5
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 109			 
		
		RETURN
	END

	---------------------------------------
	--Update a2 = m3 if a2>m3 --HR Fixed Odds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = CASE WHEN discount>@discountHRFixedOdds THEN @discountHRFixedOdds ELSE discount END 
	FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 
		AND custsetting.bettype = 20 and sporttype = 154
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 109			 
		
		RETURN
	END
		
	-- number game - update agent discount
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = CASE WHEN discount>@discountnumber THEN @discountnumber ELSE discount END 
	FROM custsetting3rd cs3 INNER JOIN custinfo AS ci WITH (NOLOCK) ON cs3.custid = ci.custid
	WHERE ci.mrecommend = @custid 
		AND ci.roleid = 2 AND sporttype = 161
		
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 202		 
		
		RETURN
	END
	---------------------------------------
	--Update g3 @ member level
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = CASE WHEN c.ugroup IN ('a','hka','dea') THEN @groupa 
						 WHEN c.ugroup IN ('b','hkb','deb') THEN @groupb 
						 WHEN c.ugroup IN ('c','hkc','dec') THEN @groupc 
						 WHEN c.ugroup IN ('d','hkd','ded') THEN @groupd ELSE @groupa END 
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND custsetting.bettype IN (1,2,3,7,8) 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 105	
		
		RETURN
	END

	---------------------------------------
	--Update m3 @ member level
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discountcs
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND custsetting.bettype IN (4,6,9,10,20,21,22) and sporttype <> 154
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 106
		RETURN
	END

	---------------------------------------
	--Update m3 @ member level --1x2 
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discount1x2
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND custsetting.bettype = 5
	IF (@@ERROR <> 0)
	BEGIN

		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 110
		RETURN
	END		

	---------------------------------------
	--Update m3 @ member level --HRFixedOdds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		adiscount = @discountHRFixedOdds
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND custsetting.bettype = 20 and sporttype = 154
	IF (@@ERROR <> 0)
	BEGIN

		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 110
		RETURN
	END	
	-- number game - update master-discount on member
	UPDATE cs3 WITH(ROWLOCK,UPDLOCK)
	SET	cs3.adiscount = @discountnumber
	FROM custsetting3rd cs3 INNER JOIN customer c WITH(NOLOCK) ON  cs3.custid = c.custid
	WHERE c.mrecommend = @custid
		  AND c.recommend <> 52466
		  AND c.roleid = 1
		  AND cs3.sporttype = 161

	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 203
		RETURN
	END

	---------------------------------------
	--At member level, update discount = adiscount  if discount > adiscount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = adiscount
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.roleid = 1 
		AND custsetting.discount>custsetting.adiscount 
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 107
		RETURN
	END

	--- number game - update agent discount on member
	UPDATE cs3 WITH(ROWLOCK,UPDLOCK)
	SET cs3.discount = cs3.adiscount
	FROM custsetting3rd cs3 INNER JOIN customer c WITH(NOLOCK) ON cs3.custid = c.custid
	WHERE c.mrecommend = @custid
		AND c.roleid = 1
		AND cs3.sporttype = 161
		AND cs3.discount > cs3.adiscount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 204
		RETURN
	END

	---------------------------------------
	--At member level, update playerdiscount = discount if playerdiscount > discount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		playerdiscount = discount
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.mrecommend = @custid 
		AND c.roleid = 1 
		AND custsetting.playerdiscount>custsetting.discount 
	IF (@@ERROR <> 0)
	BEGIN
	
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 108
		RETURN
	END
	
	--- number game - update agent discount on member
	UPDATE cs3 WITH(ROWLOCK,UPDLOCK)
	SET cs3.playerdiscount = cs3.discount
	FROM custsetting3rd cs3 INNER JOIN customer c WITH(NOLOCK) ON cs3.custid = c.custid
	WHERE c.mrecommend = @custid
		AND c.roleid = 1
		AND cs3.sporttype = 161
		AND cs3.playerdiscount > cs3.discount
		
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 204
		RETURN
	END
END



Declare @LogSPData varchar(8000)
Declare @TrackingValue2 varchar(8000)

Select @LogSPData = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

Select @TrackingValue2 = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	--Log customer info 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 205,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

	Select @TrackingValue2 = '<Acc_CustomerUpdMaster_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@Old_groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@Old_groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@Old_groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@Old_groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@Old_discountcs as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@Old_discount1x2 as varchar(50)),space(1)) + '" ' +
	'discountHRFixedOdds="'+ coalesce(cast(@Old_discountHRFixedOdds as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@Old_discountnumber as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'

	--Log customer info 
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 205,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration	
END CATCH	
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_Commission] TO [vnteam] AS [dbo]