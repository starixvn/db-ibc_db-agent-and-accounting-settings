ALTER PROCEDURE [dbo].[Acc_CustomerSelDisableHR]
	@CustID int
AS
/*
Created: 20100514@Terry
Task : Get Status for HorseRacing
DB: DB05.bodb02

Revisions:   
	-- 20110225@Lukas: Add more partner & racing game
*/
SET NOCOUNT ON

select	isnull(DisableHorseracing,0) as Disable151_31,
		isnull(DisableOpenTote,0) as Disable151_41,
		isnull(Disable151_AU,0) as Disable151_51,
		isnull(Disable152_UK,0) as Disable152_41,
		isnull(Disable152_AU,0) as Disable152_51,
		isnull(Disable153_AU,0) as Disable153_51
from custinfo with (nolock)
where CustID = @CustID


GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelDisableHR] TO [bodbDownlineNetView]
GO
