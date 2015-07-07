ALTER PROCEDURE [dbo].[Acc_CustSetting_EnabledAccountCheck]  
	@CustID INT = 0 
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) ='' OUTPUT    
AS  
/*  
	Created: 20140327@Dominic  
	Task: Check if the account was disabled 
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
	
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_EnabledAccountCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_EnabledAccountCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_EnabledAccountCheck] TO [bodbExtAccNet]