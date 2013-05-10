/****** Object:  StoredProcedure [dbo].[BetTransSelBetSlip]    Script Date: 03/11/2008 18:18:07 ******/
ALTER PROCEDURE [dbo].[BetTransSelBetSlip]
@RefNo bigint,
@Language varchar(2) = 'E',
@SessionCustID int = NULL	

AS
SET NOCOUNT ON
--Original: \account\betslip.asp
--\phonebetting\betslip.asp
--\agentsite\betslip.asp
--MEMBER SITE
--ADMIN SITE
--UPDATED 02/22/2006: remove refno
--UPDATED 03/10/2006: remove odds depend
--Revision:
	--20111229@Jim: remove function : f_GetChoice 
declare @custid int
select @custid = custid from bettrans with (nolock) where transid= @refno


if exists(select 1 from bettrans where transid = @refno)
	select 
		customer.username,bettrans.bettype,bettrans.transid,
		match.matchcode, 
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
		bettrans.hdp1,bettrans.hdp2,bettrans.odds,bettrans.transid as refno, bettrans.winlostdate,
		bettrans.status,bettrans.stake,bettrans.transdate,
		bettrans.betteam, 
		--dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
		bettrans.livehomescore,bettrans.liveawayscore,match.finalhomescore, match.finalawayscore,
		match.hthomescore, match.htawayscore, bettrans.winlost,bettrans.liveindicator 
	from 	
		bettrans with (nolock)
		INNER JOIN customer with (nolock) ON customer.custid=bettrans.custid 
	--	LEFT JOIN odds with (nolock) ON odds.oddsid=bettrans.oddsid
		LEFT JOIN match with (nolock) ON bettrans.matchid=match.matchid
		LEFT JOIN team a with (nolock) ON a.teamid=match.homeid
		LEFT JOIN team b with (nolock) ON b.teamid=match.awayid
	where
		bettrans.transid= @refno
	--order by bettrans.transid desc
else
	select 
		customer.username,bettrans14.bettype,bettrans14.transid,
		match.matchcode, 
		case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
		case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
		bettrans14.hdp1,bettrans14.hdp2,bettrans14.odds,bettrans14.transid as refno, bettrans14.winlostdate,
		bettrans14.status,bettrans14.stake,bettrans14.transdate,
		bettrans.betteam, 
		--dbo.f_GetChoice(bettrans14.betteam, bettrans14.bettype, @Language) betteam,
		bettrans14.livehomescore,bettrans14.liveawayscore,match.finalhomescore, match.finalawayscore,
		match.hthomescore, match.htawayscore, bettrans14.winlost,bettrans14.liveindicator 
	from 	
		bettrans14 with (nolock)
		INNER JOIN customer with (nolock) ON customer.custid=bettrans14.custid 
	--	LEFT JOIN odds with (nolock) ON odds.oddsid=bettrans14.oddsid
		LEFT JOIN match with (nolock) ON bettrans14.matchid=match.matchid
		LEFT JOIN team a with (nolock) ON a.teamid=match.homeid
		LEFT JOIN team b with (nolock) ON b.teamid=match.awayid
	where
		bettrans14.transid= @refno



GO

GRANT EXECUTE ON [dbo].[BetTransSelBetSlip] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetTransSelBetSlip] TO [bodbDownlineNetView]

