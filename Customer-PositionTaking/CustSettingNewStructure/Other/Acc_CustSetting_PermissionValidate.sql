ALTER PROCEDURE [dbo].[Acc_CustSetting_PermissionValidate]  
	@CustID INT = 0 
	,@TargetCustID INT = 0 
	,@TargetRoleID INT = 0  
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) ='' OUTPUT    
AS  
/*  
	Created: 20140327@Dominic  
	Task: Validate user permission 
	DB: DBAGE.bodb02  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @isEnable BIT, @RoleID INT
	DECLARE @username NVARCHAR(50)
	SELECT @ErrCode=0,@ErrMsg=''

	SELECT @isEnable = ISNULL([enabled],0), @username = username FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @custid   

	--Check if Actor was disabled
	IF @isEnable = 0 or @@ROWCOUNT =0  
	BEGIN  
		SELECT @ErrMsg = 'Account '+@username+' was disabled!'  
		SELECT @ErrCode = 1
		RETURN  
	END  
	
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
	
	IF @RoleID < @TargetCustID or @@ROWCOUNT =0  
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 3
		RETURN  
	END  
	
	--Check if Actor is not in the same line with target customer
	SELECT TOP 1 1
	FROM dbo.custinfo c WITH (NOLOCK)
	WHERE c.custid = @TargetCustID
		and
		(c.srecommend = @CustID or c.mrecommend = @CustID
			or c.recommend = @CustID or c.custid = @CustID
			OR @RoleID >= 5)
			
	IF @@ROWCOUNT =0  
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 4
		RETURN  
	END  
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PermissionValidate] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PermissionValidate] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PermissionValidate] TO [bodbExtAccNet]