ALTER PROCEDURE [dbo].[Acc_CustSetting_SameLineCheck]  
	@CustID INT = 0 
	,@TargetCustID INT = 0  
AS  
/*  
	Created: 20140327@Dominic  
	Task: Check if customer are not in the same line
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @RoleID INT

	SELECT @RoleID = ISNULL(RoleID,0) 
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @CustID
	
	--Check if Actor is not in the same line with target customer		
	IF NOT EXISTS(
		SELECT TOP 1 1
		FROM dbo.custinfo c WITH (NOLOCK)
		WHERE c.custid = @TargetCustID
			and
			(c.srecommend = @CustID or c.mrecommend = @CustID
				or c.recommend = @CustID or c.custid = @CustID
				OR @RoleID >= 5)
	)
	BEGIN  
		SELECT 0 AS IsSameLine
		RETURN
	END  
	
	SELECT 1 AS IsSameLine
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbExtAccNet]