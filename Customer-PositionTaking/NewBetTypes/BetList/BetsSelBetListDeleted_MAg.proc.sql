/****** Object:  StoredProcedure [dbo].[BetsSelBetListDeleted_MAg]    Script Date: 04/09/2008 19:14:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BetsSelBetListDeleted_MAg]
	@custid int=null,
	@username varchar(50) = NULL -- for API	

AS
--Original: ListDeletedBet_ma
--AGENT SITE
--Updated@Thien 2007-12-11: add username for calling from API

SET NOCOUNT ON

if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

Declare @bc TABLE (custid int, betcount int)

INSERT INTO @bc (custid, betcount)
SELECT c.recommend, count(*) AS betcount
FROM 
	bettrans AS b WITH (nolock)
	INNER JOIN customer AS c WITH (nolock) ON b.custid = c.custid
	INNER JOIN (SELECT matchid,eventdate FROM match WITH (nolock) UNION ALL select matchid, eventdate FROM match14 WITH (nolock)) AS m ON b.matchid = m.matchid
WHERE 
	m.eventdate > DATEADD(day,-3,CURRENT_TIMESTAMP)
	AND c.mrecommend = @custid
	and b.status IN ('VOID', 'REJECT')
GROUP BY c.recommend

SELECT c.username, c.custid, betcount 
FROM
	customer AS c WITH (nolock) 
	INNER JOIN @bc AS b ON c.custid = b.custid
WHERE c.roleid = 2
ORDER BY c.username




GO

GRANT EXECUTE ON [dbo].[BetsSelBetListDeleted_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListDeleted_MAg] TO [bodbDownlineNetView]
