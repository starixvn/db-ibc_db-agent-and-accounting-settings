ALTER PROCEDURE [dbo].[CustomerSelFinalBalance]
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
	isnull(sum(b.winlost-b.actual_stake+playercomm), 0) as total

from 
	customer with (NOLOCK)
	INNER JOIN CustInfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
	INNER JOIN exchange e  with (NOLOCK) ON e.exchangeid=customer.currency  
	LEFT JOIN bettrans as b with (NOLOCK) ON customer.custid=b.custid and b.ruben=1

where  customer.custid= @CustID

group by customer.username,e.currency,customer.pwdexpiry,customer.lastlogged,ci.credit




GO

GRANT EXECUTE ON [dbo].[CustomerSelFinalBalance] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelFinalBalance] TO [bodbDownlineNetView]

