ALTER PROCEDURE [dbo].[CustomerSelMultipleTransfer]
	@custid INT,
	@closed bit = 0
AS
SET NOCOUNT ON
--Remove custaccount
--UPDATED 03/20/2006: split table Customer
--Vinh@20080102: add yesterday balance columns
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
		c.closed,
		c.firstname,
		c.lastname,
		SUM(CASE WHEN ruben=0 THEN b.winlost-b.actual_stake END) outstanding,
		SUM(CASE b.comstatus WHEN 's' THEN b.actual_stake ELSE 0 END) oustxn,
		isnull(SUM(CASE WHEN ruben=1 THEN b.winlost-b.actual_stake+playercomm END), 0) balance,
		c.credit AS credit,
		member_recommend,
		member_mrecommend,
		@CustID as agent_recommend,
		(select mrecommend from customer with (NOLOCK) where CustID = @CustID) as agent_mrecommend
	FROM 
		 (	
			SELECT 
				customer.custid, 
				customer.username, 
				ci.closed, 
				customer.firstname, 
				customer.lastname,
				ci.credit,
				@custid as member_recommend,
				customer.mrecommend as member_mrecommend
			FROM 
				customer WITH (NOLOCK)
				INNER JOIN CustInfo as ci with (NOLOCK) on Customer.CustID = ci.custid
			WHERE 
				customer.recommend = @custid AND
				ci.closed=@closed AND
				customer.roleid = 1

		) AS c 
	LEFT JOIN bettrans as b WITH (NOLOCK) ON c.custid = b.custid
	GROUP BY c.custid, c.username, c.closed, c.firstname, c.lastname, c.credit, member_recommend, member_mrecommend
) balance 
LEFT OUTER JOIN
(
	SELECT 
		c.custid,
		isnull(SUM(CASE WHEN ruben=1 THEN b.winlost-b.actual_stake+playercomm END), 0) y_balance
		--isnull(SUM(b.winlost-b.actual_stake+playercomm), 0) y_balance
	FROM 
		 (	
			SELECT customer.custid
			FROM customer WITH (NOLOCK) INNER JOIN CustInfo as ci with (NOLOCK) on Customer.CustID = ci.custid
			WHERE 
				customer.recommend = @custid AND
				ci.closed=@closed AND
				customer.roleid = 1
		) AS c 
	LEFT JOIN bettrans as b WITH (NOLOCK) ON c.custid = b.custid
	WHERE b.winlostdate < convert(varchar(10), current_timestamp, 120)
	--WHERE case when bettype > 100 then b.winlostdate else transdate end < convert(varchar(10), current_timestamp, 120)
	GROUP BY c.custid
) y_balance ON balance.custid = y_balance.custid
ORDER BY closed, username








GO

GRANT EXECUTE ON [dbo].[CustomerSelMultipleTransfer] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelMultipleTransfer] TO [bodbDownlineNetView]
GO
