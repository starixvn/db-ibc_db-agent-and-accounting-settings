USE bodb02
GO
ALTER PROCEDURE dbo.Acc_CustomerWinLimitSel @CustId INT
	, @SportType SMALLINT
	, @BetType SMALLINT
AS
/*  
  Created: 20150706@Patrick  
  Task: Calculate winlimit by cust
  DB: DBTXN/bodb02
    
  Revisions:  
  Parameters Explanation:    
 */
BEGIN
	SET NOCOUNT ON	
	DECLARE @Amount MONEY, @CreditAmount MONEY, @RoleId TINYINT, @CreditBalance MONEY, @DebitBalance MONEY
	
	SELECT @CreditBalance = SUM(ISNULL(Balance, 0))
	FROM dbo.BalanceCreditGame WITH (NOLOCK) 
	WHERE CustId = @CustId AND BetType = @BetType

	SELECT @DebitBalance = SUM(ISNULL(Balance, 0))
	FROM dbo.BalanceDebitGame WITH (NOLOCK) 
	WHERE CustId = @CustId AND BetType = @BetType

	IF @CreditBalance IS NULL
		SET @CreditBalance = 0

	IF @DebitBalance IS NULL
		SET @DebitBalance = 0

	SELECT @Amount = @CreditBalance - @DebitBalance

	SELECT @CreditAmount = ISNULL(credit, 0)
		, @RoleId = RoleId
	FROM DBCUST.CustDB.dbo.CustInfo WITH(NOLOCK)
	WHERE CustId = @CustId

	SELECT MaxWinLimit
		, @Amount AS Balance
		, MaxWinLimit * @CreditAmount AS MaxWinCredit
		, CASE WHEN @Amount > 0 AND @CreditAmount = 0 AND MaxWinLimit > 0 THEN @Amount * 100
				WHEN @Amount > 0 AND @CreditAmount > 0 AND MaxWinLimit > 0 THEN @Amount * 100/(MaxWinLimit * @CreditAmount) 
				ELSE 0 END AS WinPercent
	FROM DBCUST.CustDB.dbo.CustWinLimit c WITH(NOLOCK)
	WHERE CustId = @CustId AND @RoleId = 1
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSel] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSel] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSel] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerWinLimitSel] TO [vnteam] AS [dbo]