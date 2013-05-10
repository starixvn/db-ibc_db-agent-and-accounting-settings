/****** Object:  StoredProcedure [dbo].[BetsSelBetListDeleted_Ag]    Script Date: 04/09/2008 19:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[BetsSelBetListDeleted_Ag]
@custid int=null,
@username varchar(50) = NULL -- for API


AS
--Original: SP ListDeletedBet_ag
--Updated@Phuc 2007-12-11: add username for calling from API
SET NOCOUNT ON

if @custid is null
	select @custid = custid from customer with (nolock) where username = @username

SELECT c.username, c.custid, count(*) AS betcount
FROM 
	bettrans AS b WITH (nolock)
	INNER JOIN customer AS c (nolock) ON b.custid = c.custid
	INNER JOIN (SELECT matchid,eventdate FROM match WITH (nolock) UNION ALL select matchid, eventdate FROM match14 WITH (nolock))  AS m ON b.matchid = m.matchid
WHERE 
	m.eventdate > DATEADD(day,-3,CURRENT_TIMESTAMP)
	AND c.recommend = @custid
	and b.status IN ('VOID', 'REJECT')
GROUP BY c.username, c.custid




GO

GRANT EXECUTE ON [dbo].[BetsSelBetListDeleted_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[BetsSelBetListDeleted_Ag] TO [bodbDownlineNetView]
