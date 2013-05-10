/****** Object:  StoredProcedure [dbo].[CustomerSelUserName]    Script Date: 05/03/2008 14:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CustomerSelUserName]
@CustID int
AS
--Original: account\customerlist.asp
--AGENT SITE
SET NOCOUNT ON
SELECT username 
from customer with (nolock) 
where custid = @CustID


GO

GRANT EXECUTE ON [dbo].[CustomerSelUserName] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[CustomerSelUserName] TO [bodbDownlineNetView]
GO

