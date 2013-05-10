ALTER PROCEDURE Forecast_Sel14_Ag
	@custid int,
	@Language varchar(2) = 'E'
AS

SET NOCOUNT ON

SELECT
	m.showtime, 
	case @Language when 'E' then league.leaguename when 'J' then isnull(league.leaguenamej, league.leaguename) else isnull(league.leaguenamec_uni, league.leaguename) end as leaguename,
	m.matchcode,
	a.liveindicator,
	m.matchid,
	case @Language when 'E' then h.teamname when 'J' then isnull(h.teamnamej, h.teamname) else isnull(h.teamnamec_uni, h.teamname) end as home,
	case @Language when 'E' then a1.teamname when 'J' then isnull(a1.teamnamej, a1.teamname) else isnull(a1.teamnamec_uni, a1.teamname) end as away,
	a.livehomescore,
	a.liveawayscore,	
	sum(Case when hdp1 = 1 and hdp2 = 1 then stake*(case when odds<0 then 1 else odds-1 end)* apositiontaking else -actual_stake*apositiontaking end) AS WinLost_HomeFG,
	sum(Case when hdp1 = 1 and hdp2 = 2 then stake*(case when odds<0 then 1 else odds-1 end)* apositiontaking else -actual_stake*apositiontaking end) AS WinLost_HomeLG,
	sum(Case when hdp1 = 2 and hdp2 = 1 then stake*(case when odds<0 then 1 else odds-1 end)* apositiontaking else -actual_stake*apositiontaking end) AS WinLost_AwayFG,
	sum(Case when hdp1 = 2 and hdp2 = 2 then stake*(case when odds<0 then 1 else odds-1 end)* apositiontaking else -actual_stake*apositiontaking end) AS WinLost_AwayLG,
	sum(Case when hdp1 = 0 and hdp2 = 0 then stake*(case when odds<0 then 1 else odds-1 end)* apositiontaking else -actual_stake*apositiontaking end) AS WinLost_NoGoal,	
	league.lcolor
FROM
	bettrans 		a  WITH (NOLOCK)
	INNER JOIN match 	m  WITH (NOLOCK) ON m.matchid       = a.matchid 
	INNER JOIN team 	h  WITH (NOLOCK) ON h.teamid        = m.homeid 
	INNER JOIN team 	a1 WITH (NOLOCK) ON a1.teamid       = m.awayid 
	INNER JOIN league 	   WITH (NOLOCK) ON league.leagueid = m.leagueid
WHERE 
	a.recommend = @custid AND
	m.eventstatus = 'running'  AND
	a.bettype = 14 AND
	a.ruben=0 AND
	a.status = 'running' AND
	a.custid <> 0
GROUP BY
	a.liveindicator,
	h.teamname, h.teamnamej, h.teamnamec_uni,
	a1.teamname, a1.teamnamej, a1.teamnamec_uni,
	m.matchid,
	m.matchcode,
	league.leaguename, league.leaguenamej, league.leaguenamec_uni,
	a.livehomescore,
	a.liveawayscore,
	m.showtime,
	league.lcolor
ORDER BY
	m.matchcode, a.liveindicator desc




GO
GRANT EXECUTE ON [dbo].Forecast_Sel14_Ag TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Forecast_Sel14_Ag TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].Forecast_Sel14_Ag TO [bodbSuperNet]