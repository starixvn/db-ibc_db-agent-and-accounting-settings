ALTER PROCEDURE [dbo].[Acc_CustSetting_SameLineCheck]  
	@CustID INT = 0 
	,@TargetCustID INT = 0 
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) ='' OUTPUT    
AS  
/*  
	Created: 20140327@Dominic  
	Task: Check if customer are not in the same line
	DB: DBAGE.bodb02  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @RoleID INT
	SELECT @ErrCode=0,@ErrMsg=''

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
		SELECT @ErrMsg = 'Customers are not in the same line!' 
		SELECT @ErrCode = 4
		RETURN  
	END  
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SameLineCheck] TO [bodbExtAccNet]