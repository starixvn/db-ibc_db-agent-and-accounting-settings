
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelMAgByCom]    Script Date: 01/17/2011 17:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelMAgByCom]
	@Currency int = NULL,
	@Closed bit = NULL,
	@DoubleCommLosing bit = NULL,
	@IsInternal bit = NULL,
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 OUTPUT,
	@TotalItems int=0 OUTPUT
AS
/*
Task : Select Direct Master Agent list
DB: DB052.bodb02
Original: magentsite/account\customerlist.asp

Revisions:
    - @update2008/01/14 search username
    - phuong.nguyen, check customer's currency for Horseracing spottype
    - 20090329@Kiwi: Improve Performance:
					+ At count @TotalPages, remove inner join custsetting, exchange, group by.
					+ Remove un-necessary inner join exchange at selection details.
	- 20090331@Shifu: Remove allowHRCurrency
	- 20090522@PhuongDao: Add 1x2 Commission 
	- 20090807@Simon: Add a column "enabled" in Select and Order by it.	
	- 20101001@Lukas: Get commission for Number Game 
	- 20110117@Steven: get synccasino
	- 20110623@Sophia: add username2
	- 20120525@Dom: exclude licensee customer
	- 20120927@Johnson: - get double comm losing status and upline double comm losing status
						- output total records affect 
	- 20131018@Kathy: Add HR Fixed Odds (154)[Redmine:#6505]
Pattern Explanation:
Search keyword: '%keyword%'
First char
	A: 'A%'
	B: 'B%'
	0-9: '[0-9]%'
	
	- 20090910@Shifu: Add IsInternal
*/

SET NOCOUNT ON

DECLARE @RowCount int, @RowStart int, @RowEnd int 
SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
IF @TotalPages = 0
BEGIN
	SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
	From(
			select m.custid
				FROM 
				customer AS m with (NOLOCK)
				INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
				INNER JOIN CustMaster cm WITH (NOLOCK) ON m.custid = cm.custid
			WHERE m.SRecommend < 100 and m.roleid=3
				and m.currency = case when @Currency is null then m.currency else @Currency end
				and ci.closed = case when @closed is null then ci.closed else @closed end
				AND cm.isinternal = case when @IsInternal is null then cm.isinternal else @IsInternal end
				and m.username like @Keyword and m.username like @FirstChar
				and ci.srecommend NOT IN(SELECT custid from f_DepSuper_1 ('all'))
				and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
		) t
END
Select * From 
(
	SELECT 		
		ci.enabled, 
		ci.closed, 
		ci.roleid,
		ci.reject as suspended,
		m.username, 
		m.custid,
		m.srecommend,
		m.ugroup, 
		m.firstname, 
		m.lastname, 
		m.username2,
		m.phone,
		m.mobilephone,
		ci.matchlimit,
		ci.virtualmultiplier-1 as VirtualMultiplier,
		m.iplogin as lastloginip,
		u.synccasino as SyncCasinoUpline,
		u.doublecommlosing as DoubleCommLosingUpline,
		max(cs.groupa) as groupa, 
		max(cs.groupb) as groupb, 
		max(cs.groupc) as groupc, 
		max(cs.groupd) as groupd, 
		max(case when cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end) as discountcs,
		max(case when cs.bettype = 5 and cs.sporttype=1 then cs.adiscount else 0 end) as discount1x2,
		max(case when cs3.bettype = 81 and cs3.sporttype = 161 then cs3.adiscount else 0 end) as discountnumber,
		max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.adiscount else 0 end) as discountHRFixedOdds,
		m.currency as exchangeid,
		m.currency,
		cm.isinternal,
		ci.synccasino,
		ci.DoubleCommLosing,
		ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
	FROM 
		customer AS m with (NOLOCK)
		INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
		INNER JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid
		INNER JOIN custsetting3rd cs3 with(nolock)on m.custid = cs3.custid
		INNER JOIN CustMaster cm WITH (NOLOCK) ON m.custid = cm.custid	
		INNER JOIN (select synccasino, doublecommlosing, custid from custinfo with (nolock)) u on m.srecommend = u.custid
	WHERE m.SRecommend < 100 and m.roleid=3
		and m.currency = case when @Currency is null then m.currency else @Currency end
		and ci.closed = case when @closed is null then ci.closed else @closed end
		and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
		AND cm.isinternal = case when @IsInternal is null then cm.isinternal else @IsInternal end
		and m.username like @Keyword and m.username like @FirstChar		
		and ci.srecommend NOT IN(SELECT custid from f_DepSuper_1 ('all'))
	group by
		ci.enabled, 
		ci.closed,
		ci.roleid, 
		ci.reject,
		ci.matchlimit,
		ci.virtualmultiplier,
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
		m.srecommend,
		m.currency,
		cm.isinternal,
		u.synccasino,
		u.DoubleCommLosing,
		ci.synccasino,
		ci.DoubleCommLosing
		
) a
WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMAgByCom] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMAgByCom] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMAgByCom] TO [vnteam]


