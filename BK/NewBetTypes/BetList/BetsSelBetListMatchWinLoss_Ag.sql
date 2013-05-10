ALTER PROCEDURE [dbo].[BetsSelBetListMatchWinLoss_Ag]
	@matchid int,
	@custid int=null, --agentID
	@bettype int,
	@Language varchar(2) = 'E',
	@username varchar(50) = NULL -- for API
	
AS
--Original: RRIS #104
--AGENT SITE
--Update@Phuc 2007/12/11 For API
--Vinh@20070111: add HT/FT, money line bet type
--20111229@Jim:remove function :f_GetChoice
SET NOCOUNT ON

if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

if @bettype<90 and @bettype <> 10
BEGIN
	SELECT
		customer.username,
		case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
		convert(nvarchar,bettrans.transid) AS refno,
		bettrans.bettype,
		bettrans.transid,
		match.matchcode,
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
		convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, 
		bettrans.odds,
		bettrans.status,
		bettrans.stake,
		(bettrans.winlost-case when bettrans.odds>0 then bettrans.stake else bettrans.stake*abs(bettrans.odds) end) winlost,
		bettrans.playercomm,
		bettrans.transdate,
		bettrans.betteam,
		--dbo.f_GetChoice(bettrans.betteam, bettrans.bettype, @Language) betteam,
		bettrans.comstatus ,
		bettrans.apositiontaking,
		bettrans.mpositiontaking,
		bettrans.spositiontaking,		
		bettrans.liveindicator,
		bettrans.livehomescore,
		bettrans.liveawayscore,
		bettrans.ip
	FROM
		bettrans with (nolock) 
		inner join customer with (nolock) on bettrans.custid=customer.custid 
--		inner join odds with (nolock) on odds.oddsid=bettrans.oddsid 
		inner join bettype with (nolock) on bettype.typeid=bettrans.bettype 
		inner join match with (nolock) on bettrans.matchid=match.matchid 
		inner join team a with (nolock) on a.teamid=match.homeid 
		inner join team b  with (nolock) on b.teamid=match.awayid 
		inner join league as l with (nolock) on match.leagueid = l.leagueid
	WHERE
		bettrans.matchid=@matchid and 
		bettrans.recommend=@custid  and 		
		bettrans.bettype=@bettype
	ORDER BY
		bettrans.status, bettrans.transid
END
else if @bettype = 10
BEGIN
	SELECT
		customer.username,
		case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
		convert(nvarchar,bettrans.transid) AS refno,
		bettrans.bettype,
		bettrans.transid,
		match.matchcode,
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		'' as away,
		bettrans.hdp1,
		bettrans.hdp2,
		bettrans.odds,
		bettrans.status,
		bettrans.stake,
		(bettrans.winlost-case when bettrans.odds>0 then bettrans.stake else bettrans.stake*abs(bettrans.odds) end) winlost,
		bettrans.playercomm,
		bettrans.transdate,
		bettrans.betteam,
		bettrans.comstatus ,
		bettrans.apositiontaking,
		bettrans.mpositiontaking,
		bettrans.spositiontaking,		
		bettrans.liveindicator,
		bettrans.livehomescore,
		bettrans.liveawayscore,
		case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end as leaguename, 
		bettrans.ip
	FROM
		bettrans with (nolock) 
		inner join customer with (nolock) on bettrans.custid=customer.custid 
		inner join bettype with (nolock) on bettype.typeid=bettrans.bettype 
		inner join outright as match with (nolock) on bettrans.matchid=match.orid
		inner join team a with (nolock) on a.teamid=match.teamid 
		inner join league as l with (nolock) on l.leagueid = match.leagueid
	WHERE
		bettrans.matchid=@matchid and 
		bettrans.recommend=@custid  and 		
		bettrans.bettype=@bettype
	ORDER BY
		bettrans.status, bettrans.transid
END



GO
GRANT EXECUTE ON [dbo].[BetsSelBetListMatchWinLoss_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListMatchWinLoss_Ag] TO [bodbDownlineNetView]