CREATE PROCEDURE [dbo].[Acc_CustSetting_CustomerRoleSelect]  
	@CustID INT = 0  
AS  
/*  
	Created: 20140327@Dominic  
	Task: Get RoleID
	DB: DBAGE.bodb02  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	
	--Check if roleid of taget cusomer is not consistent
	SELECT ISNULL(RoleID,0)  RoleID
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @CustID   
	 
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbExtAccNet]