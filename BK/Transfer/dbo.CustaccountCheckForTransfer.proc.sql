ALTER PROCEDURE [dbo].[CustaccountCheckForTransfer]
	@custid INT	
AS

--Original:CustaccountCheckForTransfer
--AGENT SITE
--UPDATED 05/03/2008: remove fromtime, totime
Declare @fromtime DATETIME
set @fromtime = cast(datediff(dd,0,getdate()) as datetime)
Declare @totime DATETIME
set @totime = cast(datediff(dd,0,getdate()) as datetime) +'09:59:59'

SELECT
	custid
FROM 
	bettrans WITH (NOLOCK)
WHERE 
	custid=@custid AND
	bettype in (103, 104) AND
	(transdate BETWEEN @fromtime AND @totime)


GO
GRANT EXECUTE ON [dbo].[CustaccountCheckForTransfer] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustaccountCheckForTransfer] TO [bodbDownlineNetView]
