SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductProfileSelect]   
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
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL)
	
	SELECT DISTINCT pdt.SettingType, pdt.SettingLevel , pdt.SettingTemplate, pdt.DisplayOrder
	FROM dbo.ProductSettingDetail pdt WITH(NOLOCK)
	INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
	ORDER BY pdt.DisplayOrder
	
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductProfileSelect] TO [bodbExtAccNet]