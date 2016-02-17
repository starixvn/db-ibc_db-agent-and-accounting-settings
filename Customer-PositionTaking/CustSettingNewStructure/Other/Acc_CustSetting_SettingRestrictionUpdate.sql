CREATE PROCEDURE [dbo].[Acc_CustSetting_SettingRestrictionUpdate]  
	@IsAllowed BIT = 0
AS  
/*  
	Created: 20160217@Dominic  
	Task: Not Allow to update setting on Alpha
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  

	IF @IsAllowed = 1
	BEGIN
		UPDATE dbo.ProductSettingUpdateRestriction
		SET RestrictionMode = 2 --Read Only
	END
	ELSE
	BEGIN
		UPDATE dbo.ProductSettingUpdateRestriction
		SET RestrictionMode = 1 --Read & Write
	END
	
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbExtAccNet]