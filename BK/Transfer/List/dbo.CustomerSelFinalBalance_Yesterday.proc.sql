ALTER PROCEDURE [dbo].[CustomerSelFinalBalance_Yesterday]
	@CustID int
AS
SET NOCOUNT ON
--Original: phonebetting\finalbalance.asp
--agentsite\finalbalance.asp
--masteragentsite\finalbalance.asp

--Remove custaccount

select 
	customer.lastlogged,customer.pwdexpiry,e.currency AS curr,customer.username,
	ci.credit as cdttotal,
	isnull(sum(b.winlost-b.actual_stake+playercomm), 0)  as total
	--isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0) total
from 
	customer with (NOLOCK)
	INNER JOIN CustInfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
	INNER JOIN exchange e  with (NOLOCK) ON e.exchangeid=customer.currency  
	LEFT JOIN bettrans as b with (NOLOCK) ON customer.custid=b.custid
where
	customer.custid= @CustID
	--Get Data of Yesterdays only
	--AND case when bettype > 100 then b.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)
	AND b.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)
	and b.ruben=1
group by customer.username,e.currency,customer.pwdexpiry,customer.lastlogged,ci.credit



GO
GRANT EXECUTE ON [dbo].[CustomerSelFinalBalance_Yesterday] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelFinalBalance_Yesterday] TO [bodbDownlineNetView]