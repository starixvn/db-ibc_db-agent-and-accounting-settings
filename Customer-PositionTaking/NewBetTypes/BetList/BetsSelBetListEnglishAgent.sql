ALTER PROCEDURE [dbo].[BetsSelBetListEnglishAgent]
	@custid int,
	@bettype int,
	@Language varchar(2) = 'E'
AS
--Original: EnglishAgentBetList
--AGENT SITE
--UPDATED 02/22/2006: remove refno
--UPDATED 03/10/2006: remove odds depend
SET NOCOUNT ON

	

if @bettype<90 and @bettype <> 10
BEGIN
	select 
		customer.username,
		case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
		convert(nvarchar(20),bettrans.transid) AS refno,bettrans.bettype,
		bettrans.transid,match.matchcode,
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
		convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
		bettrans.status,bettrans.stake,bettrans.transdate,
		dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
		bettrans.comstatus,bettrans.apositiontaking, bettrans.ip
	from 
		bettrans with (nolock)
		INNER JOIN match with (nolock) ON bettrans.matchid=match.matchid 
		INNER JOIN customer with (nolock) ON bettrans.custid=customer.custid 
		INNER JOIN bettype with (nolock) ON bettype.typeid=bettrans.bettype 
		INNER JOIN team a with (nolock) ON a.teamid=match.homeid 
		INNER JOIN team b  with (nolock) ON b.teamid=match.awayid 
		inner join league as l with (nolock) on match.leagueid = l.leagueid
	where
		bettrans.recommend=@custid  and bettrans.status='running' and bettrans.bettype=@bettype
	order by 
		bettrans.status,bettrans.transid
END
else if @bettype=10
BEGIN
	select 
		customer.username,
		case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
		convert(nvarchar(20),bettrans.transid) AS refno,bettrans.bettype,
		bettrans.transid,match.matchcode,
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		'' as away,
		convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
		bettrans.status,bettrans.stake,bettrans.transdate,
		bettrans.betteam,bettrans.comstatus,bettrans.apositiontaking,
		case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename,
		bettrans.ip
	from 
		bettrans with (nolock)
		INNER JOIN outright as match with (nolock) ON bettrans.matchid=match.orid 
		INNER JOIN customer with (nolock) ON bettrans.custid=customer.custid 
		INNER JOIN bettype with (nolock) ON bettype.typeid=bettrans.bettype 
		INNER JOIN team a with (nolock) ON a.teamid=match.teamid 
		inner join league as l with (nolock) on l.leagueid = match.leagueid
	where
		bettrans.recommend=@custid  and bettrans.status='running' and bettrans.bettype=@bettype
	order by 
		bettrans.status,bettrans.transid
END

GO

GRANT EXECUTE ON [dbo].[BetsSelBetListEnglishAgent] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListEnglishAgent] TO [bodbDownlineNetView]
