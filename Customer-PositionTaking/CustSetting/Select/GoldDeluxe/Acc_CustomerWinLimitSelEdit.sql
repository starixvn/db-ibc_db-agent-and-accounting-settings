USE CustDB
GO
ALTER PROCEDURE dbo.Acc_CustomerWinLimitSelEdit @CustId INT
	, @SportType SMALLINT
	, @BetType SMALLINT
AS
/*  
  Created: 20150706@Patrick  
  Task: get win limit to edit
  DB: DBCUST/CustDB  
    
  Revisions:  
  Parameters Explanation:    
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @UplineId INT, @UplineIsAutoReset BIT, @UplineMaxWinLimit SMALLMONEY
	SELECT @UplineId = CASE WHEN roleid = 1 THEN recommend 
						 WHEN roleid = 2 THEN mrecommend
						 WHEN roleid = 3 THEN srecommend
						 ELSE 0 END
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @CustId

	IF ISNULL(@UplineId, 0) <> 0
	BEGIN
		SELECT @UplineIsAutoReset = IsAutoReset,
			@UplineMaxWinLimit = MaxWinLimit
		FROM dbo.CustWinLimit WITH(NOLOCK)
		WHERE CustId = @UplineId AND SportType = @SportType AND BetType = @BetType
	END

	SELECT CustId
		, IsAutoReset
		, MaxWinLimit
		, ISNULL(@UplineIsAutoReset, 0) AS 'UplineIsAutoReset'
		, ISNULL(@UplineMaxWinLimit, 0) AS 'UplineMaxWinLimit'
	FROM dbo.CustWinLimit c WITH(NOLOCK)
	WHERE CustId = @CustId AND SportType = @SportType AND BetType = @BetType
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSelEdit] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSelEdit] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerWinLimitSelEdit] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerWinLimitSelEdit] TO [vnteam] AS [dbo]
GO
