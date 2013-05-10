/****** Object:  StoredProcedure [dbo].[BetsSelBetListM_SAg]    Script Date: 04/09/2008 19:24:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE [dbo].[BetsSelBetListM_SAg]
@custid int,
@Language varchar(2) = 'E'	
AS
SET NOCOUNT ON

--Original: SP emagentbetlistm
--AGENT SITE
--UPDATED 02/22/2006: remove refno
select 
	customer.username,0,
	case @Language when 'E' then 'Multiple Bet' when 'C' then (select typenamec_uni from bettype where typeid=9) when 'J' then (select typenamej from bettype where typeid=9) end AS typenamee,
	convert(nvarchar,bettrans.transid) AS refno,
	--convert(nvarchar,bettrans.refno) AS refno,
	9 AS bettype,
	bettrans.transid,'' matchcode,'' home,'' away,'' hdp1,'' hdp2,bettrans.odds,
	bettrans.status,bettrans.stake,bettrans.transdate,bettrans.betteam,bettrans.comstatus,0 AS livehomescore, 
	0 AS liveawayscore,0 AS liveindicator ,bettrans.tpositiontaking,bettrans.spositiontaking,bettrans.mpositiontaking,bettrans.apositiontaking, bettrans.ip
from bettrans with (nolock)
	inner join customer with (nolock) on customer.custid=bettrans.custid
where
	bettrans.srecommend=@custid and 
	bettrans.ruben=0 and 
	bettrans.matchid=0 and comstatus<>'s'
order by customer.username





GO
GRANT EXECUTE ON [dbo].[BetsSelBetListM_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListM_SAg] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListM_SAg] TO [bodbSuperNet]