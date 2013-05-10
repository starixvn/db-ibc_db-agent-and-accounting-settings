ALTER PROCEDURE BetsSelTotalBets20_MAg
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
	sum((Case when betteam = 'h' then (a.mpositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS home_odds,
	sum((Case when betteam = 'a' then (a.mpositiontaking)*stake else 0 end)*(case when abs(odds) <1 then 1 else abs(odds) end)) AS away_odds,
	
	sum(Case when betteam = 'h' then stake*(case when odds<0 then 1 else odds end)* mpositiontaking else -actual_stake*mpositiontaking end) AS WinLost_home,
	sum(Case when betteam = 'a' then stake*(case when odds<0 then 1 else odds end)* mpositiontaking else -actual_stake*mpositiontaking end) AS WinLost_away,
	
	league.lcolor
FROM
	bettrans 		a  WITH (NOLOCK)
	INNER JOIN match 	m  WITH (NOLOCK) ON m.matchid       = a.matchid 
	INNER JOIN team 	h  WITH (NOLOCK) ON h.teamid        = m.homeid 
	INNER JOIN team 	a1 WITH (NOLOCK) ON a1.teamid       = m.awayid 
	INNER JOIN league 	   WITH (NOLOCK) ON league.leagueid = m.leagueid
WHERE 
	a.mrecommend = @custid AND
	m.eventstatus = 'running'  AND
	a.bettype = 20 AND
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






--SELECT
	--m.showtime, 
	--case @Language when 'E' then league.leaguename when 'J' then isnull(league.leaguenamej, league.leaguename) else isnull(league.leaguenamec_uni, league.leaguename) end as leaguename,
	--m.matchcode,
	--b.liveindicator,
	--m.matchid,
	--case @Language when 'E' then h.teamname when 'J' then isnull(h.teamnamej, h.teamname) else isnull(h.teamnamec_uni, h.teamname) end as home,
	--case @Language when 'E' then a1.teamname when 'J' then isnull(a1.teamnamej, a1.teamname) else isnull(a1.teamnamec_uni, a1.teamname) end as away,
	--b.livehomescore,
	--b.liveawayscore,
	--sum(Case when betteam = 'h' then Stake else 0 End) AS home_odds,
	--sum(Case when betteam = 'a' then Stake else 0 End) AS away_odds,
	--sum(Case when betteam = 'h' then -Stake else 0 End)* 
	 
	
	
	--league.lcolor
--FROM
	--(SELECT
		--matchid, bettype, betteam, 
		--liveindicator, livehomescore, liveawayscore,
		--SUM(apositiontaking * stake * case when abs(odds) <1 then 1 else abs(odds) end) Stake
	--FROM bettrans (nolock)
	--WHERE
			--bettype = 20
			--AND recommend = @custid
			--AND ruben = 0
	--GROUP BY matchid, bettype, betteam, liveindicator, livehomescore, liveawayscore) as b
	--INNER JOIN match 	m  WITH (NOLOCK) ON m.matchid       = b.matchid 
	--INNER JOIN team 	h  WITH (NOLOCK) ON h.teamid        = m.homeid 
	--INNER JOIN team 	a1 WITH (NOLOCK) ON a1.teamid       = m.awayid 
	--INNER JOIN league 	   WITH (NOLOCK) ON league.leagueid = m.leagueid
--WHERE 	
	--m.eventstatus = 'running'
--GROUP BY
	--b.liveindicator,
	--h.teamname, h.teamnamej, h.teamnamec_uni,
	--a1.teamname, a1.teamnamej, a1.teamnamec_uni,
	--m.matchid,
	--m.matchcode,
	--league.leaguename, league.leaguenamej, league.leaguenamec_uni,
	--b.livehomescore,
	--b.liveawayscore,
	--m.showtime,
	--league.lcolor
--ORDER BY
	--m.matchcode, b.liveindicator desc

GO
GRANT EXECUTE ON [dbo].BetsSelTotalBets20_MAg TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].BetsSelTotalBets20_MAg TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].BetsSelTotalBets20_MAg TO [bodbSuperNet]