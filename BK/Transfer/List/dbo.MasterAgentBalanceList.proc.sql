ALTER PROCEDURE [dbo].[MasterAgentBalanceList]
	@masterid as int,
	@Closed bit = 0
AS
--Vinh@20080102: add yesterday balance columns

select 	c.username, 
	c.custid,
	IsNull(credit.agentCredit, 0) AS agentCredit, 
	credit.agentUsedCredit, 
	IsNull(balance.agentOutstanding,0) AS agentOutstanding, 	
	IsNull(balance.agentCashBalance,0) AS agentCashBalance, 
	IsNull(balance.agentBalance + balance.agentCashBalance,0) agentBalance, 
	
	IsNull(y_balance.y_agentCashBalance,0) AS yesterday_agentCashBalance, 
	IsNull(y_balance.y_agentBalance + y_balance.y_agentCashBalance, 0) yesterday_agentBalance, 	
	
	c.firstname, 
	c.lastname, 
	credit.agentClosedAccountCredit, 
	credit.accountCount 
from
	(SELECT c.custid, c.username, c.firstname, c.lastname FROM customer AS c with (nolock) INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid WHERE c.mrecommend = @masterid AND c.roleid = 2 and ci.closed = @closed) AS c
	INNER JOIN
	(
		SELECT c.recommend,
			isnull(SUM(CASE WHEN roleid = 2 THEN credit ELSE 0 END), 0) AS agentCredit,			
			isnull(SUM(CASE WHEN roleid = 1 THEN credit ELSE 0 END), 0) AS agentUsedCredit,
			isnull(SUM(CASE WHEN roleid = 1 AND closed = 1 THEN credit ELSE 0 END), 0) AS agentClosedAccountCredit,
			isnull(SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END), 0) AS accountCount
		FROM custinfo as c (nolock)
		WHERE mrecommend = @masterid AND roleid < 3
		GROUP BY c.recommend
	) credit ON c.custid = credit.recommend
	LEFT OUTER JOIN
	(
		select 	recommend, 
			isnull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end), 0) AS agentCashBalance, 
			isnull(sum(case when custid<>recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end), 0) AS agentBalance, 
			isnull(sum(case when custid<>recommend and ruben=0 then apositiontaking*actual_stake else 0 end), 0) AS agentOutstanding 
		from bettrans with(nolock)
		where mrecommend = @masterid  
		group by recommend
	) balance ON c.custid = balance.recommend
	LEFT OUTER JOIN
	(
		select 	recommend, 
			isnull(sum(case when custid=recommend then winlost-actual_stake else awinlost+comm-playercomm end), 0) AS y_agentCashBalance, 
			isnull(sum(case when custid<>recommend and ruben=1 then winlost-actual_stake+playercomm else 0 end), 0) AS y_agentBalance
		from bettrans with(nolock)
		where mrecommend = @masterid
		--Get Data of Yesterdays only
		--and case when bettype > 100 then bettrans.winlostdate else transdate end < convert(varchar(10), current_timestamp, 120)  
		and bettrans.winlostdate < convert(varchar(10), current_timestamp, 120)  
		group by recommend
	) y_balance ON c.custid = y_balance.recommend
		
order by c.username



GO

GRANT EXECUTE ON [dbo].[MasterAgentBalanceList] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[MasterAgentBalanceList] TO [bodbDownlineNetView]
