ALTER PROCEDURE [dbo].[BetsSelMTeamList]
@refno  bigint,
@Language varchar(2) = 'E',
@SessionCustID int = NULL
 AS
--Original: SP mteamlist
--AGENT SITE
--UPDATED 02/22/2006: remove refno
SET NOCOUNT ON
/*
-- ***Check Downline Belonging***
declare @custid int
select @custid = custid from bettrans with (nolock) where transid= @refno

declare @roleid tinyint
EXEC Age_CustomerSelCheckBelonging 
@SessionCustID = @SessionCustID, 
@CustID = @CustID,
@roleid = @roleid OUTPUT
if (@roleid = 0) return
*/
Declare @trefno bigint

Select @trefno = refno from bettrans with (NOLOCK) where transid = @refno
if @trefno is NULL
BEGIN
	Select @trefno = refno from bettrans14 with (NOLOCK) where transid = @refno
END

--select @trefno = @refno
select
bettrans.oddsid,
case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
bettrans.transid as refno,bettrans.bettype ,
bettrans.transid,match.matchcode,
case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
convert(float, bettrans.hdp1) as hdp1, convert(float, bettrans.hdp2) as hdp2, bettrans.odds,
bettrans.status,bettrans.stake,bettrans.transdate,
dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
bettrans.comstatus,bettrans.livehomescore,bettrans.liveawayscore,bettrans.liveindicator,bettrans.statuswinlost


from 	(select * from bettransm with (nolock) where refno=@trefno ) AS bettrans
	inner join bettype with (nolock) on bettype.typeid=bettrans.bettype 
	inner join match with (nolock) on bettrans.matchid=match.matchid 
	inner join team b with (nolock)on b.teamid=match.awayid
	inner join team a with (nolock)on a.teamid=match.homeid 
	inner join league as l with (nolock) on match.leagueid = l.leagueid

UNION ALL

select
bettrans.oddsid,
case @Language when 'E' then l.leaguename when 'J' then isnull(l.leaguenamej, l.leaguename) else isnull(l.leaguenamec_uni, l.leaguename) end + N'<br>' + case @Language when 'E' then bettype.typenamee when 'J' then isnull(bettype.typenamej, bettype.typenamee) else isnull(bettype.typenamec_uni, bettype.typenamee) end as typenamee,
bettrans.transid as refno,bettrans.bettype ,
bettrans.transid,match.matchcode,
case @Language when 'E' then a.teamname when 'J' then isnull(a.teamnamej, a.teamname) else isnull(a.teamnamec_uni, a.teamname) end as home,
case @Language when 'E' then b.teamname when 'J' then isnull(b.teamnamej, b.teamname) else isnull(b.teamnamec_uni, b.teamname) end as away,
bettrans.hdp1,bettrans.hdp2,bettrans.odds,
bettrans.status,bettrans.stake,bettrans.transdate,
dbo.f_GetChoice(bettrans.betteam, bettrans.bettype,@Language) betteam,
bettrans.comstatus,bettrans.livehomescore,bettrans.liveawayscore,bettrans.liveindicator,bettrans.statuswinlost
from 	(select * from bettransm14 with (nolock) where refno=@trefno ) AS bettrans
	inner join bettype with (nolock) on bettype.typeid=bettrans.bettype 
	inner join match14 as match with (nolock) on bettrans.matchid=match.matchid 
	inner join team b with (nolock)on b.teamid=match.awayid
	inner join team a with (nolock)on a.teamid=match.homeid
	inner join league as l with (nolock) on match.leagueid = l.leagueid



GO

GRANT EXECUTE ON [dbo].[BetsSelMTeamList] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelMTeamList] TO [bodbDownlineNetView]
