 ALTER PROCEDURE [dbo].[Acc_CustomerUpdOpusCS_StakeLevel]
	@custid INT,
	@GameTypeID INT,
	@StakeLevelList VARCHAR(100),
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT 
 AS
	/*
		Created: Johnson
		Date: 2013-09-30
		Task[redmine:#5670]: Update opus casino's stake level for customer
		DB: DBTXN/custDB
	*/
BEGIN

END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdOpusCS_StakeLevel] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdOpusCS_StakeLevel] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdOpusCS_StakeLevel] TO [bodbDownlineNetView]