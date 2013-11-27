ALTER PROCEDURE [dbo].[Dot_BalanceInsCreditGame]
	@custid [int],
	@winlostdate SMALLDATETIME
WITH EXECUTE AS CALLER
AS
/*
	Created: Elodie
	Date: 2013-08-08
	Task: Insert into BalanceCreditGame
	DB: DBTXN/BODB02

	Revisions:

	Parameters Explanation:		
	
*/
Declare @Retry int, @Success bit
SET @Retry = 0

TryAgain:

BEGIN TRY
	SET @Retry = @Retry + 1
	SET @Success = 1	
	INSERT INTO dbo.BalanceCreditGame (custid, winlostdate, balance) VALUES (@custid, @winlostdate, 0)			
END TRY
BEGIN CATCH
	SET @Success = 0	
END CATCH

IF @Success = 0 AND @Retry < 3 GOTO TryAgain



GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsCreditGame] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Dot_BalanceInsCreditGame] TO [bodbDownlineNet] AS [dbo]