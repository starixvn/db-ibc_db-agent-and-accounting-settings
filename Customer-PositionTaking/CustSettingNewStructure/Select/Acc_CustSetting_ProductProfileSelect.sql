SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_ProductProfileSelect]   
	@ProductID	TINYINT  
AS  
/*  
 Created: 20150702@Dominic  
 Task : Get Product Profile  
 DB:  DBCUST/custdb  
 Original:  
  
 Param's Explanation:  

   
 */  
BEGIN   
	SELECT DISTINCT SettingType, SettingLevel , SettingTemplate
	FROM dbo.ProductSettingDetail WITH(NOLOCK)
	WHERE ProductID = @ProductID
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbExtAccNet]