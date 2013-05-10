CREATE PROCEDURE [dbo].[CustomerSelBalance_Ag]
	@CustID int,
	@UserName varchar(20) = '' OUTPUT ,
	@CashBalance money = 0 OUTPUT,
	@Yesterday_CashBalance money = 0 OUTPUT,
	@TotalBalance money = 0 OUTPUT,
	@Yesterday_TotalBalance money = 0 OUTPUT,
	@AgentOutstanding money = 0 OUTPUT,
	@TotalOutstanding money = 0 OUTPUT,
	@AgentCredit money = 0 OUTPUT,
	@TotalMemberCredit money = 0 OUTPUT,
	@TotalMemberActive int = 0 OUTPUT,
	@TotalMemberClosed int = 0 OUTPUT
AS
--AGENT SITE
--Date created: 03/01/2006
--Get  Agent Balance
--UPDATED 03/20/2006: split table Customer
SET NOCOUNT ON
Select 
	@UserName = Customer.UserName,
	@AgentCredit = isnull(ci.Credit, 0)
From 
	Customer with (NOLOCK)
	INNER JOIN CustInfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
Where Customer.CustID = @CustID

Select 
	@TotalMemberCredit = isnull(sum(Credit), 0),
	@TotalMemberActive = isnull(sum(case when Closed = 0 then 1 else 0 end), 0),
	@TotalMemberClosed = isnull(sum(case when Closed = 1 then 1 else 0 end), 0)
From CustInfo with (NOLOCK)
Where Recommend = @CustID and RoleID=1

SELECT 
	@CashBalance=IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0),  
	@AgentOutstanding=IsNull(sum (case when ruben=0 then actual_stake * apositiontaking else 0 end),0),  
	@TotalOutstanding=IsNull(sum(case when custid <> recommend and ruben=0 then actual_stake else 0 end),0),
	@TotalBalance = 
				IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0)
				+ IsNull(sum(case when custid <> recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end),0)
FROM bettrans WITH (NOLOCK)  
WHERE recommend=@CustID

SELECT 
	@Yesterday_CashBalance=IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0),  
	@Yesterday_TotalBalance = 
				IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0)
				+ IsNull(sum(case when custid <> recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end),0)
FROM bettrans WITH (NOLOCK)  
WHERE recommend=@CustID 
	--and case when bettype > 100 then bettrans.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)
	and bettrans.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)



GO
GRANT EXECUTE ON [dbo].[CustomerSelBalance_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelBalance_Ag] TO [bodbDownlineNetView]
