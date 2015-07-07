ALTER PROCEDURE [dbo].[Acc_custSetting_RoleIDCheck]  
	@CustID INT = 0 
	,@TargetCustID INT = 0 
	,@TargetRoleID INT = 0  
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) ='' OUTPUT    
AS  
/*  
	Created: 20140327@Dominic  
	Task: Check RoleID
	DB: DBAGE.bodb02  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @RoleID INT
	SELECT @ErrCode=0,@ErrMsg=''
	
	--Check if roleid of taget cusomer is not consistent
	SELECT @RoleID = ISNULL(RoleID,0) 
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @TargetCustID   
	
	IF @RoleID <> @TargetRoleID or @@ROWCOUNT =0  
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 2
		RETURN  
	END  
	
	--Check if Actor has roleid smaller than target customer
	SELECT @RoleID = ISNULL(RoleID,0) 
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @CustID
	
	IF @RoleID < @TargetRoleID or @@ROWCOUNT =0  
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 3
		RETURN  
	END  
	 
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_custSetting_RoleIDCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_custSetting_RoleIDCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_custSetting_RoleIDCheck] TO [bodbExtAccNet]