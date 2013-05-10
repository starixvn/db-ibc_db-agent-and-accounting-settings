
ALTER PROCEDURE [dbo].[BetsSelBetListM]
@custid int,
@Language varchar(2) = 'E'

AS
--Original: SP englishagentbetlistm
--AGENT SITE
--UPDATED 02/22/2006: remove refno
SET NOCOUNT ON


select 
	customer.username,
	0, case @Language when 'E' then 'Multiple Bet' when 'C' then (select typenamec_uni from bettype where typeid=9) when 'J' then (select typenamej from bettype where typeid=9) end AS typenamee,
	convert(nvarchar(20),bettrans.transid) AS refno,
--	convert(nvarchar(20),bettrans.refno) AS refno,
	9 AS bettype,bettrans.transid,
	'' matchcode,'' home,'' away,'' hdp1,'' hdp2,bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,bettrans.betteam,bettrans.comstatus,0 livehomescore, 
	0 liveawayscore,0 liveindicator, bettrans.tpositiontaking,bettrans.mpositiontaking,bettrans.apositiontaking, bettrans.ip
from 
	bettrans with (nolock)
	inner join customer with (nolock) on customer.custid=bettrans.custid
where
	bettrans.recommend=@custid and
	bettrans.ruben=0 and bettrans.status='running' and 
	bettrans.matchid=0 and comstatus<>'s'





GO

GRANT EXECUTE ON [dbo].[BetsSelBetListM] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListM] TO [bodbDownlineNetView]
