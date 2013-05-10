ALTER PROCEDURE [dbo].[CustomerSelBalance_MAg]
	@CustID int,
	@UserName varchar(20) = '' OUTPUT ,
	@CashBalance money = 0 OUTPUT,
	@Yesterday_CashBalance money = 0 OUTPUT,
	@TotalBalance money = 0 OUTPUT,
	@Yesterday_TotalBalance money = 0 OUTPUT,	
	@MasterOutstanding money = 0 OUTPUT,
	@TotalOutstanding money = 0 OUTPUT,
	@MasterCredit money = 0 OUTPUT,
	@TotalAgentCredit money = 0 OUTPUT, 
	@TotalMemberCredit money = 0 OUTPUT,
	@TotalAgentActive int = 0 OUTPUT,
	@TotalAgentClosed int = 0 OUTPUT,
	@TotalMemberActive int = 0 OUTPUT,
	@TotalMemberClosed int = 0 OUTPUT
AS
--Date created: 02/25/2006
--Get Master Agent Balance
--UPDATED 03/20/2006: split table Customer
--Origianl:CustomerSelBalance_MAg
SET NOCOUNT ON
Select 
	@UserName = customer.UserName,
	@MasterCredit = isnull(ci.Credit, 0)
From 
	Customer with (NOLOCK)
	INNER JOIN CustInfo as ci with (NOLOCK) on Customer.Custid = ci.custid
Where customer.CustID = @CustID

Select 
	@TotalAgentCredit = isnull(sum(case when RoleID = 2 then Credit else 0 end), 0), 
	@TotalMemberCredit = isnull(sum(case when RoleID = 1 then Credit else 0 end), 0),
	@TotalAgentActive = isnull(sum(case when RoleID = 2 and Closed = 0 then 1 else 0 end), 0),
	@TotalAgentClosed = isnull(sum(case when RoleID = 2 and Closed = 1 then 1 else 0 end), 0),
	@TotalMemberActive = isnull(sum(case when RoleID = 1 and Closed = 0 then 1 else 0 end), 0),
	@TotalMemberClosed = isnull(sum(case when RoleID = 1 and Closed = 1 then 1 else 0 end), 0)
From Custinfo with (NOLOCK)
Where MRecommend = @CustID

SELECT 
	@CashBalance=IsNull(sum(case when custid=mrecommend then winlost-actual_stake else mwinlost+acomm-comm end),0),  
	@MasterOutstanding=IsNull(sum (case when ruben=0 then actual_stake * mpositiontaking else 0 end),0),  
	@TotalOutstanding=IsNull(sum(case when custid <> recommend and custid <> mrecommend and ruben=0 then actual_stake else 0 end),0),
	@TotalBalance = 
				IsNull(sum(case when custid=mrecommend then winlost-actual_stake else mwinlost+acomm-comm end),0)
				+ IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0)
				+ IsNull(sum(case when custid <> recommend and custid <> mrecommend and ruben=1 then winlost-actual_stake+playercomm else 0 end),0)

FROM bettrans WITH (NOLOCK, index=bettrans16)  
WHERE mrecommend=@CustID

SELECT 
	@Yesterday_CashBalance=IsNull(sum(case when custid=mrecommend then winlost-actual_stake else mwinlost+acomm-comm end),0),  
	@Yesterday_TotalBalance = 
				IsNull(sum(case when custid=mrecommend then winlost-actual_stake else mwinlost+acomm-comm end),0)
				+ IsNull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end),0)
				+ IsNull(sum(case when custid <> recommend and custid <> mrecommend and ruben=1 then winlost-actual_stake+playercomm else 0 end),0)

FROM bettrans WITH (NOLOCK, index=bettrans16)  
WHERE mrecommend=@CustID 
	--and case when bettype > 100 then bettrans.winlostdate else transdate end < convert(varchar(10), CURRENT_TIMESTAMP, 120)
	and bettrans.winlostdate < convert(varchar(10), CURRENT_TIMESTAMP, 120)




GO
GRANT EXECUTE ON [dbo].[CustomerSelBalance_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelBalance_MAg] TO [bodbDownlineNetView]
