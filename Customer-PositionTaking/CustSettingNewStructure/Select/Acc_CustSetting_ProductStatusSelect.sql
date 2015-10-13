SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--Acc_CustSetting_ProductSelect_ALL @custid=1176070

CREATE PROCEDURE [dbo].[Acc_CustSetting_ProductStatusSelect]   
	@CustID	INT = NULL
AS  
/*  
 Created: 20150702@Dominic  
 Task : Get Product Profile  
 DB:  DBCUST/custdb  
 Original:  
  
 Param's Explanation:  
   
 */  
BEGIN
    SELECT DISTINCT P.productID,P.ProductName,psd.SettingLevel
		, dbo.f_GetProductStatus(cps.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
		, dbo.f_GetProductStatus(cps.bitmapIsHidden, PSP.bitmapOrder) AS IsHidden
    FROM DBAGE.bodb02.dbo.Products P WITH (NOLOCK)
		INNER JOIN dbo.ProductSettingDetail psd WITH(NOLOCK)  ON P.productID = PSD.ProductID
		INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON psp.Sporttype = psd.SportType AND psp.Bettype = psd.BetType
		INNER JOIN CustProductStatus cps  WITH (NOLOCK) ON cps.CustID = @CustID
	WHERE psd.SettingType = 4	
END  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductStatusSelect] TO [bodbExtAccNet]



