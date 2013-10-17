ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_Commission]
	@custid INT,-- AgentId
	@groupa DECIMAL(9,8),
	@groupb DECIMAL(9,8),
	@groupc DECIMAL(9,8),
	@groupd DECIMAL(9,8),
	@discountcs DECIMAL(9,8),
	@discount1x2 DECIMAL(9,8)=0,
	@discountHRFixedOdds DECIMAL(9,8)=0,
	@discountnumber DECIMAL(9,8),
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
Task : Update Agent's Commission
DB: DBTXN/bodb02
Original:

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.
    - 20090514@PhuongDao: Add 1x2 Commission  
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100909@Lukas: add number game commission 
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write log Old values
	- 20110729@Johnson: remove check bettype for update commission number game
	- 20110930@Johnson: Add more group under Won currency
	- 20120412@Hurri: hardcode not to update commission for member under agent BARM.
	- 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
Param's Explanation:
• @ErrCode:
    = 0: Update commission successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

Declare @Old_groupa DECIMAL(9,8),
	@Old_groupb DECIMAL(9,8),
	@Old_groupc DECIMAL(9,8),
	@Old_groupd DECIMAL(9,8),
	@Old_discountcs DECIMAL(9,8),
	@Old_discount1x2 DECIMAL(9,8),
	@Old_discountHRFixedOdds DECIMAL(9,8),
	@Old_discountnumber DECIMAL(9,8)
	
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
DECLARE @username VARCHAR(40), @mrecommend INT
SELECT @UserName  = username, @mrecommend = mrecommend
FROM customer WITH (NOLOCK) WHERE CustID = @CustID

IF @updatecomm_old = 1
BEGIN
	
	SELECT 		
		@Old_groupa = groupa, 
		@Old_groupb = groupb, 
		@Old_groupc = groupc, 
		@Old_groupd = groupd 
	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
	
	SELECT @Old_discountcs = discount FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 4
	SELECT @Old_discount1x2 = discount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 1 AND bettype = 5
	SELECT @Old_discountHRFixedOdds = discount	FROM custsetting AS cs WITH (NOLOCK) WHERE custid = @custid AND sporttype = 154 AND bettype = 20		
	SELECT @Old_discountnumber = discount FROM custsetting3rd AS cs3 WITH (NOLOCK) WHERE custid = @custid AND sporttype = 161 AND bettype = 81
	
	--Get g2=g3 if g2>g3
	SELECT 
		@groupa = CASE WHEN @groupa>groupa THEN groupa ELSE @groupa END, 
		@groupb = CASE WHEN @groupb>groupb THEN groupb ELSE @groupb END, 
		@groupc = CASE WHEN @groupc>groupc THEN groupc ELSE @groupc END, 
		@groupd = CASE WHEN @groupd>groupd THEN groupd ELSE @groupd END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend AND bettype=1 AND sporttype=1

	--Get a2=m3 if a2>m3
	SELECT 	
		@discountcs = CASE WHEN @discountcs > adiscount THEN adiscount ELSE @discountcs END		
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend AND sporttype = 1 AND bettype = 4

	---------------------------------------
	--Get a2=m3 if a2>m3  - 1x2 
	SELECT 	
		@discount1x2 = CASE WHEN @discount1x2 > adiscount THEN adiscount ELSE @discount1x2 END		
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend AND sporttype = 1 AND bettype = 5
	
	---------------------------------------
	--Get a2=m3 if a2>m3 --HR Fixed Odds
	SELECT @discountHRFixedOdds = CASE WHEN @discountHRFixedOdds > adiscount THEN adiscount ELSE @discountHRFixedOdds END
	FROM custsetting AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend AND bettype = 20 AND sporttype = 154

	---------------------------------------	
	--Get a2=m3 if a2>m3  - number game 
	SELECT 	
		@discountnumber = CASE WHEN @discountnumber > adiscount THEN adiscount ELSE @discountnumber END		
	FROM custsetting3rd AS cs3 WITH (NOLOCK) 
	WHERE custid = @mrecommend AND sporttype = 161 AND bettype = 81
	---------------------------------------
	--Update @Agent: g2, a2
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
	SET
		groupa = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa ELSE groupa END,
		groupb = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupb ELSE groupb END,
		groupc = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupc ELSE groupc END,
		groupd = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupd ELSE groupd END,
		discount = CASE WHEN bettype IN (4,6,9,10,20,21,22) AND sporttype <> 154 THEN @discountcs WHEN bettype =5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds ELSE discount END
	WHERE custid=@custid
	
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 102
		RETURN
	END

	-- number game commission
	Update custsetting3rd with(rowlock,updlock) 
	set discount = @discountnumber
	where custid = @custid and sporttype = 161
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 201
		RETURN
	END
	---------------------------------------
	--Update g2, a2 at Member level
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	custsetting.discount = CASE WHEN customer.ugroup IN ('a','hka','dea') THEN @groupa 
										WHEN customer.ugroup IN ('b','hkb','deb') THEN @groupb 
										WHEN customer.ugroup IN ('c','hkc','dec') THEN @groupc 
										WHEN customer.ugroup IN ('d','hkd','ded') THEN @groupd 
										ELSE @groupa 
									END  
	FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
	WHERE customer.recommend = @custid 
		AND customer.recommend <> 52466
		AND customer.roleid = 1 
		AND bettype IN (1,2,3,7,8) 
	
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	custsetting.discount = @discountcs
	FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
	WHERE customer.recommend = @custid
		AND customer.recommend <> 52466
		AND customer.roleid = 1 
		AND bettype IN (4,6,9,10,20,21,22)
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 103
		RETURN
	END

	--1x2 
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	custsetting.discount = @discount1x2
	FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
	WHERE customer.recommend = @custid 
		AND customer.recommend <> 52466
		AND customer.roleid = 1 
		AND bettype = 5
	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 201
		RETURN
	END
	
	---------------------------------------
	--HRFixedOdds
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
	SET 	
		discount = @discountHRFixedOdds
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.recommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND bettype = 20 and sporttype = 154
	IF (@@ERROR <> 0)
	BEGIN

		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 105
		RETURN
	END
	
	--- number game
	UPDATE cs3 WITH (ROWLOCK, UPDLOCK) 
	SET 	cs3.discount = @discountnumber
	FROM custsetting3rd cs3 INNER JOIN customer c WITH (NOLOCK) ON cs3.custid = c.custid
	WHERE c.recommend = @custid 
		AND c.recommend <> 52466
		AND c.roleid = 1 
		AND cs3.sporttype = 161
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
	--At member level, update playerdiscount = discount  if playerdiscount > discount
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
	SET
		custsetting.playerdiscount = custsetting.discount 
	FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
	WHERE c.recommend = @custid 
		AND c.roleid = 1 
		AND custsetting.playerdiscount > custsetting.discount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 104
		RETURN
	END

	-- number game
	UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
	SET
		cs3.playerdiscount = cs3.discount 
	FROM custsetting3rd cs3 INNER JOIN customer AS c WITH (NOLOCK) ON cs3.custid = c.custid
	WHERE c.recommend = @custid 
		AND c.roleid = 1 
		AND cs3.playerdiscount > cs3.discount
	IF (@@ERROR <> 0)
	BEGIN
		
		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 203
		RETURN
	END
END



Declare @LogSPData varchar(8000)
Declare @TrackingValue2 varchar(8000)
Select @LogSPData = '<Acc_CustomerUpdAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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

Select @TrackingValue2 = '<Acc_CustomerUpdAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 206,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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

	Select @TrackingValue2 = '<Acc_CustomerUpdAgent_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 206,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
		
END CATCH	


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_Commission] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_Commission] TO [vnteam] AS [dbo]