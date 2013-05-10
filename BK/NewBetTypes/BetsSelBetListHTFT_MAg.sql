ALTER PROCEDURE [dbo].[BetsSelBetListHTFT_MAg]
	@custid int,
	@Language varchar(2) = 'E'
AS

SET NOCOUNT ON

SELECT   
	bettrans.matchid, bettrans.oddsid,bettrans.liveindicator, bettrans.bettype,
	case @Language when 'E' then h1.teamname when 'J' then isnull(h1.teamnamej, h1.teamname) else isnull(h1.teamnamec_uni, h1.teamname) end as home,
	case @Language when 'E' then a1.teamname when 'J' then isnull(a1.teamnamej, a1.teamname) else isnull(a1.teamnamec_uni, a1.teamname) end as away,
	case @Language when 'E' then l1.leaguename when 'J' then isnull(l1.leaguenamej, l1.leaguename) else isnull(l1.leaguenamec_uni, l1.leaguename) end as leaguename,
	m.showtime,
	matchcode,	
	--sum((Case betteam when 'HH'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHH,
	--sum((Case betteam when 'HD'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHD,
	--sum((Case betteam when 'HA'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHA,
	--sum((Case betteam when 'DH'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDH,
	
	--sum((Case betteam when 'DD'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDD,
	--sum((Case betteam when 'DA'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDA,
	--sum((Case betteam when 'AH'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAH,
	--sum((Case betteam when 'AD'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAD,
	--sum((Case betteam when 'AA'  then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAA
	
	sum((Case when hdp1 = 1 and hdp2 = 1 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHH,
	sum((Case when hdp1 = 1 and hdp2 = 0 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHD,
	sum((Case when hdp1 = 1 and hdp2 = 2 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalHA,
	sum((Case when hdp1 = 0 and hdp2 = 1 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDH,
	
	sum((Case when hdp1 = 0 and hdp2 = 0 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDD,
	sum((Case when hdp1 = 0 and hdp2 = 2 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalDA,
	sum((Case when hdp1 = 2 and hdp2 = 1 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAH,
	sum((Case when hdp1 = 2 and hdp2 = 0 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAD,
	sum((Case when hdp1 = 2 and hdp2 = 2 then (stake*odds)-stake else -stake end )*(bettrans.mpositiontaking)) AS totalAA
	
	
FROM  bettrans with (nolock)
	inner join match m with (nolock) on m.matchid = bettrans.matchid 
	inner join team h1 with (nolock) on h1.teamid = m.homeid 
	inner join team a1 with (nolock) on a1.teamid = m.awayid 
	inner join league l1 with (nolock) on l1.leagueid = m.leagueid 
WHERE    
	bettrans.bettype = 16 AND m.eventstatus='running'
	and bettrans.mrecommend=@custid and oddsid > 0
	
group by bettrans.matchid,bettrans.oddsid,bettrans.liveindicator, bettrans.bettype, h1.teamname , a1.teamname,h1.teamnamec_uni, a1.teamnamec_uni,l1.leaguename,  m.showtime, h1.teamnamej , a1.teamnamej, l1.leaguenamej,
	matchcode, l1.leaguenamec_uni
order by m.matchcode,bettrans.oddsid

GO
GRANT EXECUTE ON [dbo].[BetsSelBetListHTFT_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListHTFT_MAg] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListHTFT_MAg] TO [bodbSuperNet]