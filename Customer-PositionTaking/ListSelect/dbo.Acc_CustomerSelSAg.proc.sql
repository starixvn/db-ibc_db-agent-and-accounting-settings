ALTER PROCEDURE [dbo].[Acc_CustomerSelSAg]
	@Currency int = NULL,
	@Closed bit = NULL,
	@DoubleCommLosing BIT = NULL,
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@IsInternal bit = NULL,
	@System varchar(50) = 'ACCOUNTING',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 OUTPUT,
	@TotalItems int=0 OUTPUT
AS
/*
Task : Select Super Agent list
DB: DBAGE/bodb02, DBTXN/bodb02
Revisions:
    - @update2008/01/14 search username
    - phuong.nguyen, check customer's currency for Horseracing spottype
    - 20090329@Kiwi: At count @TotalPages, remove inner join custsetting, group by.	
    - 20090331@Shifu: Remove allowHRCurrency	
    - 20090522@PhuongDao: Add 1x2 Commission 		
    - 20090807@Simon: Add a column "enabled" in Select and Order by it.
    - 20090905@Shifu: Add IsInternal
	- 20100721@Shifu: Get super list by System
	- 20101001@Jamie: Get commission for Number Game
	- 20101119@Johnson: get super list by site from Acc_CustSite table if system is not Accounting 
	- 20101214@Kevin: add synccasino
	- 20110427@Jamie: 
		+ Remove the condition srecommend > 100 for External Group 
		+ Remove JOIN IN customer in COUNT TOTAL PAGE
	- 20110623@Sophia: add username2
	- 20120525@Dom: exclude licensee customer for accounting site
	- 20120927@Johnson: - Get super list by double comm status
						- output total records affects
	- 20130121@Dan: call to bodb_AGE for Acc_CustGroup
	- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20131029@Elodie: Put link server DBAGE [Redmine:#7261]
Pattern Explanation:
Search keyword: '%keyword%'
First char
A: 'A%'
B: 'B%'
0-9: '[0-9]%'
*/

SET NOCOUNT ON

DECLARE @RowCount int, @RowStart int, @RowEnd int
DECLARE @isAccountingSystem bit
SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
Declare @tbDummySuper table (custid int primary key)
Declare @tbCurrency table (exchangeId int primary key)

IF(@System = 'ACCOUNTING')
BEGIN
	IF @TotalPages = 0
	BEGIN
		SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
		From
		(
			Select m.custid
			FROM 
				Custinfo as m with (NOLOCK)
				INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
			WHERE m.currency = case when @Currency is null then m.currency else @Currency end											
				and m.closed = case when @closed is null then m.closed else @closed end
				and csuper.isinternal = case when @IsInternal is null then csuper.isinternal else @IsInternal end
				and m.roleid=4 and m.custid>100 and m.username like @Keyword and m.username like @FirstChar		
				and m.custid NOT IN(SELECT custid from f_DepSuper_1 ('all'))	
				and m.DoubleCommLosing = case when @DoubleCommLosing is null then m.DoubleCommLosing else @DoubleCommLosing end
		) t
	END

	select * from 
	(
	SELECT 
		ci.enabled, 
		ci.closed, 
		ci.reject as suspended,
		ci.synccasino,
		ci.DoubleCommLosing,
		csuper.isinternal,
		m.username, 
		m.custid, 
		m.ugroup, 
		m.firstname, 
		m.lastname,
		m.username2,
		m.phone,
		m.mobilephone,
		m.iplogin as lastloginip,
		m.currency,
		m.roleid,
		max(cs.groupa) as groupa, 
		max(cs.groupb) as groupb, 
		max(cs.groupc) as groupc, 
		max(cs.groupd) as groupd, 

		max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
		max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
		max(case when cs3rd.bettype = 81 and cs3rd.sporttype = 161 then cs3rd.sdiscount else 0 end) as discountNumber,	
		max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.sdiscount else 0 end) as discountHRFixedOdds,
		ci.matchlimit,
		ci.virtualmultiplier-1 as VirtualMultiplier,
		ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
		
	FROM 
		customer AS m with (NOLOCK)
		INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
		INNER JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid	
		INNER JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
		INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
	WHERE m.currency = case when @Currency is null then m.currency else @Currency end
		and ci.closed = case when @closed is null then ci.closed else @closed end
		and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
		and csuper.isinternal = case when @IsInternal is null then csuper.isinternal else @IsInternal end
		and m.roleid=4 and m.custid>100 and m.username like @Keyword and m.username like @FirstChar
		and m.custid NOT IN(SELECT custid from f_DepSuper_1 ('all'))
	group by
		ci.enabled, 
		ci.closed, 
		ci.reject,
		ci.synccasino,
		ci.DoubleCommLosing,
		csuper.isinternal,
		m.username, 
		m.custid, 
		m.ugroup, 
		m.firstname, 
		m.lastname, 
		m.username2,
		m.roleid,
		m.phone,
		m.mobilephone,
		m.iplogin,
		m.currency, 
		m.roleid,--phuong.nguyen, get currency name	
		ci.matchlimit,
		ci.virtualmultiplier
	--ORDER BY ci.closed, m.username
	) a
	WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd
END
ELSE -- Others system
BEGIN

	--INSERT INTO @tbCurrency
	--SELECT exchangeid FROM dbo.f_CurrencyBySystem(@System)

	IF @TotalPages = 0
	BEGIN
		SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
		From
		(
			Select m.custid
			FROM 
				Custinfo as m with (NOLOCK)
				INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
			WHERE	
				m.custid IN (SELECT custid FROM DBAGE.bodb_AGE.dbo.Acc_CustGroup WITH (NOLOCK) WHERE GroupName = @System)
				AND m.roleid=4 
				AND csuper.IsInternal = 0	
				AND m.closed = case when @closed is null then m.closed else @closed end
				AND m.username like @Keyword and m.username like @FirstChar			
				and m.DoubleCommLosing = case when @DoubleCommLosing is null then m.DoubleCommLosing else @DoubleCommLosing end
		) t
	END

	select * from 
	(
	SELECT 
		ci.enabled, 
		ci.closed, 
		ci.reject as suspended,
		ci.synccasino,
		ci.DoubleCommLosing,
		csuper.isinternal,
		m.username, 
		m.custid, 
		m.ugroup, 
		m.firstname, 
		m.lastname, 
		m.username2,
		m.phone,
		m.mobilephone,
		m.iplogin as lastloginip,
		m.currency,
		m.roleid,
		max(cs.groupa) as groupa, 
		max(cs.groupb) as groupb, 
		max(cs.groupc) as groupc, 
		max(cs.groupd) as groupd, 

		max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
		max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
		max(case when cs3rd.bettype = 81 and cs3rd.sporttype = 161 then cs3rd.sdiscount else 0 end) as discountNumber,		
		max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.sdiscount else 0 end) as discountHRFixedOdds,
		ci.matchlimit,
		ci.virtualmultiplier-1 as VirtualMultiplier,
		ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
	FROM 
		customer AS m with (NOLOCK)
		INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
		INNER JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid	
		INNER JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
		INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
	WHERE	
			m.custid IN (SELECT custid FROM DBAGE.bodb_AGE.dbo.Acc_CustGroup WITH (NOLOCK) WHERE groupname = @system AND roleid = 4)
			AND m.roleid=4 
			AND csuper.IsInternal = 0
			AND ci.closed = case when @closed is null then ci.closed else @closed end
			and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
			AND m.username like @Keyword and m.username like @FirstChar			
	group by
		ci.enabled, 
		ci.closed, 
		ci.reject,
		ci.synccasino,
		ci.DoubleCommLosing,
		csuper.isinternal,
		m.username, 
		m.custid, 
		m.ugroup, 
		m.firstname, 
		m.lastname, 
		m.phone,
		m.username2,
		m.roleid,
		m.mobilephone,
		m.iplogin,
		m.currency, 
		m.roleid,--phuong.nguyen, get currency name	
		ci.matchlimit,
		ci.virtualmultiplier
	) a
	WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd
END



	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAg] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSAg] TO [vnteam]
