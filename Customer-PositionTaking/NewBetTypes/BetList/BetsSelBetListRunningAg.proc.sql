
ALTER PROCEDURE [dbo].[BetsSelBetListRunningAg]
	@CustID int=null,
	@FromDate datetime,
	@ToDate datetime,
	@Language varchar(2) = 'E',
	@username varchar(50) = NULL -- for API
	

AS
--AGENT SITE
--UPDATED 02/22/2006: remove refno
--UPDATED 03/10/2006: remove odds depend
--update@phuc 2007/12/11 for API
SET NOCOUNT ON

if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

select 	
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	convert(nvarchar,bettrans.transid) AS refno,bettrans.bettype,bettrans.transid,match.matchcode,
	case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
	case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
	convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,
	dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
	bettrans.comstatus, bettrans.apositiontaking, bettrans.mpositiontaking, bettrans.spositiontaking,
	'' as leaguename
	, bettrans.liveindicator, bettrans.livehomescore, bettrans.liveawayscore, bettrans.ip
from 
	bettrans with (NOLOCK)
--	INNER JOIN odds with (NOLOCK) ON odds.oddsid=bettrans.oddsid 
	INNER JOIN bettype with (NOLOCK) ON bettype.typeid=bettrans.bettype 
	INNER JOIN match with (NOLOCK) ON bettrans.matchid=match.matchid 
	INNER JOIN team a with (NOLOCK) ON a.teamid=match.homeid
	INNER JOIN team b  with (NOLOCK) ON b.teamid=match.awayid 
	inner join league as l with (nolock) on match.leagueid = l.leagueid
where
	bettrans.transdate>=@FromDate  and bettrans.transdate<=@ToDate and 
	bettrans.custid=@CustID and bettrans.status='running' 
UNION ALL
select 	
	case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	convert(nvarchar,bettrans.transid) AS refno,bettrans.bettype,bettrans.transid,match.matchcode,
	case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
	'' as away,
	bettrans.hdp1,bettrans.hdp2,bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,bettrans.betteam,bettrans.comstatus, bettrans.apositiontaking, bettrans.mpositiontaking, bettrans.spositiontaking,
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename,
	0, 0, 0, bettrans.ip
from 
	bettrans with (NOLOCK)
	INNER JOIN bettype with (NOLOCK) ON bettype.typeid=bettrans.bettype 
	INNER JOIN outright as match with (NOLOCK) ON bettrans.matchid=match.orid 
	INNER JOIN team a with (NOLOCK) ON a.teamid=match.teamid 
	inner join league as l with (nolock) on l.leagueid = match.leagueid
where
	bettrans.bettype=10 and bettrans.transdate>=@FromDate  and bettrans.transdate<=@ToDate and 
	bettrans.custid=@CustID and bettrans.status='running' 
UNION ALL
select 	
	case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	convert(nvarchar,bettrans.transid) AS refno,bettrans.bettype,bettrans.transid,'' as matchcode,
	'' as home,
	'' as away,
	0 as hdp1, 0 as hdp2, bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,bettrans.betteam,bettrans.comstatus, bettrans.apositiontaking, bettrans.mpositiontaking, bettrans.spositiontaking,
	'' as leaguename,
	0, 0, 0, bettrans.ip
from 
	bettrans with (NOLOCK)
--	INNER JOIN odds with (NOLOCK) ON odds.oddsid=bettrans.oddsid 
	INNER JOIN bettype with (NOLOCK) ON bettype.typeid=bettrans.bettype 
where
	bettrans.transdate>=@FromDate  and bettrans.transdate<=@ToDate and 
	bettrans.custid=@CustID and bettrans.status='running' 
	and bettrans.bettype=9
order by bettrans.transid


GO

GRANT EXECUTE ON [dbo].[BetsSelBetListRunningAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListRunningAg] TO [bodbDownlineNetView]
