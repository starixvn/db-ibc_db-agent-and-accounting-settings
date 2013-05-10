ALTER PROCEDURE [dbo].[Acc_CustomerSelDisableFI]
	@CustID int
AS
/*
Created: 20090411@nqminh
Task : Select financial status
DB: DB05.bodb02
Original: Acc_CustomerSelDisableFI

Revisions:
    - 20090122@[Reviewer]: [Description of revision]    
*/

SET NOCOUNT ON

select isnull(DisableFinancial,0) as DisableFinancial
from custinfo with (nolock)
where CustID = @CustID

GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableFI] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableFI] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableFI] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelDisableFI] TO [vnteam]
GO