/****** Object:  StoredProcedure [dbo].[CustAccountSelCreditList_MAg]    Script Date: 02/12/2008 16:12:09 ******/
ALTER PROCEDURE [dbo].[CustAccountSelCreditList_MAg]
	@CustID int
AS
SET NOCOUNT ON
--Original: agentsite\account\customercreditlist.asp
--AGENT SITE
--UPDATED 02/22/2006: remove refno
--UPDATED 03/20/2006: split table Customer

--Vinh@20080102: add yesterday balance column



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
		isnull(balance.outstanding,0) AS outstanding, 
		isnull(balance.balance,0) AS balance, 
		isnull(balance.turnover,0) AS turnover,
		ci.credit,
		isnull(c.lastlogged, '') as lastlogged
	FROM 
		customer AS c  with (NOLOCK)
		INNER JOIN CustInfo as ci with (NOLOCK) on c.custid = ci.custid
		LEFT JOIN 
			(SELECT
				recommend as custid,
				IsNull(sum (case when ruben=0 then actual_stake * apositiontaking else 0 end),0) AS outstanding, 
				IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0) AS balance,
				IsNull(sum(case when matchid > 0 then actual_stake else 0 end), 0) as turnover 
			FROM bettrans with (NOLOCK)
			WHERE mrecommend=@CustID
			GROUP BY recommend) AS balance 
		ON balance.custid = c.custid
	WHERE c.roleid=2 AND c.mrecommend=@CustID
) balance
LEFT JOIN
(
	SELECT 
		c.custid, 
		isnull(balance.balance,0) AS y_balance
	FROM 
		customer AS c  with (NOLOCK)
		LEFT JOIN 
			(SELECT
				recommend as custid,
				IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0) AS balance
			FROM bettrans with (NOLOCK)
			WHERE mrecommend=@CustID 
				--AND case when bettype > 100 then bettrans.winlostdate else transdate end < convert(varchar(10), current_timestamp, 120)  	
				AND bettrans.winlostdate < convert(varchar(10), current_timestamp, 120)  	
			GROUP BY recommend) AS balance 
		ON balance.custid = c.custid
	WHERE c.roleid=2 AND c.mrecommend=@CustID
) y_balance ON balance.custid = y_balance.custid

ORDER BY closed, username






GO
GRANT EXECUTE ON [dbo].[CustAccountSelCreditList_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustAccountSelCreditList_MAg] TO [bodbDownlineNetView]
