ALTER PROCEDURE [dbo].[XYZ]
	@custid INT,
	@closed bit = 0
AS
SET NOCOUNT ON
--Remove custaccount
--UPDATED 03/20/2006: split table Customer
--Vinh@20080102: add yesterday balance columns
/*
Joe :
what's "oustxn" doing now?
Does interface still uses this value?

why need to have 2 values of recommend/mrecommend
anything going to be different for member_recommend/mrecommend -vs- agent_recommend/mrecommend

be consider, if LEFT JOIN direct to table. should compare with doing sub-query for performance
*/

select  
	username,
	balance.custid,
	closed,
	firstname,
	lastname,
	outstanding,
	oustxn,
	balance,
	isnull(y_balance.y_balance, 0) yesterday_balance,
	credit,
	member_recommend,
	member_mrecommend,
	agent_recommend,
	agent_mrecommend
from
(
	SELECT
		c.username,
		c.custid,
		ci.closed,
		c.firstname,
		c.lastname,
		b.outstanding,
		0 oustxn,
		IsNull(b.balance, 0) balance,
		ci.credit,
		ci.recommend as member_recommend,
		ci.mrecommend as member_mrecommend,
		ci.recommend as agent_recommend,
		ci.mrecommend as agent_mrecommend
	FROM
		dbo.customer c (nolock)
		INNER JOIN dbo.custinfo ci (nolock) ON c.custid = ci.custid
		LEFT OUTER JOIN
	(SELECT
		custid,
		SUM(CASE ruben WHEN 0 THEN actual_stake ELSE 0 END) outstanding,
		SUM(CASE ruben WHEN 1 THEN winlost-actual_stake+playercomm ELSE 0 END) balance
	FROM
		bettrans (nolock)
	WHERE
		recommend = @custid
	GROUP by
		custid) b ON ci.custid = b.custid
	WHERE
		ci.recommend = @custid
		AND ci.closed = @closed
		AND ci.roleid = 1
) balance 
LEFT OUTER JOIN
(
	SELECT
		ci.custid,
		IsNull(b.y_balance, 0) y_balance
	FROM
		dbo.custinfo ci (nolock)
	LEFT JOIN
	(SELECT
		custid,
		SUM(CASE ruben WHEN 1 THEN winlost-actual_stake+playercomm ELSE 0 END) y_balance
	FROM
		dbo.bettrans (nolock)
	WHERE
		recommend = @custid AND winlostdate < convert(varchar(10), current_timestamp, 120)
	GROUP BY
		custid) b ON ci.custid = b.custid
	WHERE
		ci.recommend = @custid
		AND ci.closed = @closed
		AND ci.roleid = 1
) y_balance ON balance.custid = y_balance.custid
ORDER BY closed, username







