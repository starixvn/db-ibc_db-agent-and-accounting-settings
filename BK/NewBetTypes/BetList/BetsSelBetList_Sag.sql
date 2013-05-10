ALTER PROCEDURE [dbo].[BetsSelBetList_SAg]
	@custid int,
	@bettype int,
	@Language varchar(2) = 'E'	
AS
--Original:???
--AGENT SITE
--UPDATED 02/22/2006: remove refno
--Revision:
	--20111229@Jim: remove function : f_GetChoice
SET NOCOUNT ON

	

if @bettype<90 and @bettype <> 10
BEGIN
	select 
	customer.username,
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	convert(nvarchar,bettrans.transid) AS refno,bettrans.bettype,
	bettrans.transid,match.matchcode,
	case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
	case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
	convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,
	bettrans.betteam,
	--dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
	bettrans.comstatus,bettrans.status ,bettrans.spositiontaking ,bettrans.mpositiontaking, bettrans.apositiontaking, bettrans.ip
	from 
		bettrans with (nolock)
		inner join customer with (nolock) on bettrans.custid=customer.custid 
		inner join bettype with (nolock) on bettype.typeid=bettrans.bettype	
		inner join match with (nolock) on  bettrans.matchid=match.matchid 
		inner join team a with (nolock) on a.teamid=match.homeid 
		inner join team b  with (nolock) on  b.teamid=match.awayid
		inner join league as l with (nolock) on match.leagueid = l.leagueid
	where bettrans.srecommend=@custid  and bettrans.status='running' and bettrans.bettype=@bettype
	order by bettrans.status,bettrans.transid
END
else if @bettype=10
BEGIN
	select 
	customer.username,
	case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
	convert(nvarchar,bettrans.transid) AS refno,bettrans.bettype,
	bettrans.transid,match.matchcode,
	case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
	'' as away,
	convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,
	bettrans.betteam,bettrans.comstatus,bettrans.status ,bettrans.spositiontaking ,bettrans.mpositiontaking ,bettrans.apositiontaking,
	case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename,
	bettrans.ip
	from 
		bettrans with (nolock)
		inner join customer with (nolock) on bettrans.custid=customer.custid 
		inner join bettype with (nolock) on bettype.typeid=bettrans.bettype	
		inner join outright as match with (nolock) on  bettrans.matchid=match.orid 
		inner join team a with (nolock) on a.teamid=match.teamid
		inner join league as l with (nolock) on l.leagueid = match.leagueid
	where @bettype=10 and bettrans.srecommend=@custid  and bettrans.status='running' and bettrans.bettype=@bettype
	order by bettrans.status,bettrans.transid
END

GO
GRANT EXECUTE ON [dbo].[BetsSelBetList_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetList_SAg] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetList_SAg] TO [bodbSuperNet]