ALTER PROCEDURE [dbo].[BetsSelTotalBets25_Ag]
	@custid int,
	@Language varchar(2) = 'E'
 AS
--Original: SP eagenttotalbet27
--AGENT SITE
--UPDATED 02/22/2006: remove refno
SET NOCOUNT ON
select 
	m.showtime, 
	case @Language when 'E' then league.leaguename when 'J' then isnull(league.leaguenamej, league.leaguename) else isnull(league.leaguenamec_uni, league.leaguename) end as leaguename,
	m.matchcode, a.liveindicator, 
	m.matchid,
	case @Language when 'E' then h.teamname when 'J' then isnull(h.teamnamej, h.teamname) else isnull(h.teamnamec_uni, h.teamname) end as home,
	case @Language when 'E' then a1.teamname when 'J' then isnull(a1.teamnamej, a1.teamname) else isnull(a1.teamnamec_uni, a1.teamname) end as away,
	sum((Case when bettype=2 and betteam = 'h' then (a.apositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS home_odds_OE,
	sum((Case when bettype=2 and betteam = 'a' then (a.apositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS away_odds_OE,
	
	sum((Case when bettype=12 and betteam = 'h' then (a.apositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS home_odds_OE_1st,
	sum((Case when bettype=12 and betteam = 'a' then (a.apositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS away_odds_OE_1st,
	
	league.lcolor,
	sum(Case when bettype=5 and betteam = '1' then  (a.apositiontaking)*stake   else 0 end) AS odds_1,
	sum(Case when bettype=5 and betteam = 'x' then  (a.apositiontaking)*stake   else 0 end) AS odds_x,
	sum(Case when bettype=5 and betteam = '2' then  (a.apositiontaking)*stake   else 0 end) AS odds_2,

	sum(Case when bettype=15 and betteam = '1' then  (a.apositiontaking)*stake   else 0 end) AS odds_1_1st,
	sum(Case when bettype=15 and betteam = 'x' then  (a.apositiontaking)*stake   else 0 end) AS odds_x_1st,
	sum(Case when bettype=15 and betteam = '2' then  (a.apositiontaking)*stake   else 0 end) AS odds_2_1st,

	sum(case when bettype=2 then 1 else 0 end) as BetCount_OE,
	sum(case when bettype=12 then 1 else 0 end) as BetCount_OE_1st,
	sum(case when bettype=5 then 1 else 0 end) as BetCount_1x2,
	sum(case when bettype=15 then 1 else 0 end) as BetCount_1x2_1st
FROM
	bettrans AS a  WITH (NOLOCK)
	INNER JOIN match AS m  WITH (NOLOCK) ON m.matchid       = a.matchid and 	m.eventstatus='running'
	INNER JOIN team AS h  WITH (NOLOCK) ON h.teamid        = m.homeid 
	INNER JOIN team AS a1 WITH (NOLOCK) ON a1.teamid       = m.awayid 
	INNER JOIN league WITH (NOLOCK) ON league.leagueid = m.leagueid
where  	
	a.recommend=@custid and
	m.eventstatus='running'  and
	a.bettype in (2, 5,12, 15)
	and a.ruben = 0
group by a.liveindicator, h.teamname, h.teamnamej, h.teamnamec_uni,
	a1.teamname, a1.teamnamej, a1.teamnamec_uni, m.matchid,
	m.matchcode, league.leaguename, league.leaguenamej,league.leaguenamec_uni, m.showtime,
	league.lcolor
order by m.matchcode, a.liveindicator desc




GO
GRANT EXECUTE ON [dbo].[BetsSelTotalBets25_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelTotalBets25_Ag] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[BetsSelTotalBets25_Ag] TO [bodbSuperNet]