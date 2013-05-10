/****** Object:  StoredProcedure [dbo].[CustAccountSelCreditList_Ag]    Script Date: 02/12/2008 15:15:02 ******/
ALTER PROCEDURE [dbo].[CustAccountSelCreditList_Ag]
	@CustID int	
AS
SET NOCOUNT ON
--Original: agentsite\account\customercreditlist.asp
--AGENT SITE
--UPDATED 02/22/2006: remove refno
--UPDATED 03/20/2006: split table Customer

--Vinh@20080102: add yesterday balance column
SET NOCOUNT ON


select 
	balance.username,
	balance.iplogin, 
	balance.custid, 
	balance.closed, 
	balance.firstname, 
	balance.lastname, 
	balance.outstanding, 
	balance.balance,
	isnull(y_balance.y_balance, 0) yesterday_balance,
	balance.turnover,
	balance.credit,
	balance.lastlogged
from
(
	SELECT 
		c.username,
		isnull(c.iplogin, '')as iplogin, 
		c.custid, 
		ci.closed, 
		c.firstname, 
		c.lastname, 
		isnull(balance.outstanding,0) outstanding, 
		isnull(balance.balance,0) balance,
		isnull(balance.turnover,0) AS turnover,
		isnull(ci.credit, 0) as credit,
		isnull(c.lastlogged, '') as lastlogged
	FROM 
		customer AS c  with (NOLOCK)
		INNER JOIN CustInfo as ci with (NOLOCK) on c.custid = ci.custid
		LEFT JOIN 
			(SELECT
				custid,
				sum(case when ruben=0 then actual_stake else 0 end) outstanding, 
				sum(case when ruben=1 then winlost-actual_stake+playercomm else 0 end) balance,
				IsNull(sum(case when matchid > 0 then actual_stake else 0 end), 0) as turnover 
			FROM bettrans with (NOLOCK)
			WHERE recommend=@CustID
			GROUP BY custid) AS balance 
		ON balance.custid = c.custid
	WHERE c.roleid=1 AND c.recommend=@CustID
) balance
LEFT JOIN
(
	SELECT 
		c.custid, 
		isnull(balance.balance,0) y_balance
	FROM 
		customer AS c  with (NOLOCK)
		LEFT JOIN 
			(SELECT
				custid,
				sum(case when ruben=1 then winlost-actual_stake+playercomm else 0 end) balance
			FROM bettrans with (NOLOCK)
			WHERE recommend=@CustID 
				--AND case when bettype > 100 then winlostdate else transdate end < convert(varchar(10), current_timestamp, 120)  	
				AND winlostdate < convert(varchar(10), current_timestamp, 120)
			GROUP BY custid) AS balance 
		ON balance.custid = c.custid
	WHERE c.roleid=1 AND c.recommend=@CustID
) y_balance ON balance.custid = y_balance.custid
ORDER BY closed, username




GO

GRANT EXECUTE ON [dbo].[CustAccountSelCreditList_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustAccountSelCreditList_Ag] TO [bodbDownlineNetView]
