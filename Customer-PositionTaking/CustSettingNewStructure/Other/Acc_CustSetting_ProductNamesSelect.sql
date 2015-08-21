ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductNamesSelect]   
   @ProductID TINYINT = NULL,
   @LanguageKey CHAR(2) = '' 
AS  
/*  
 Created: 20150226@Dominic  
 Task : Get names in multi-language of one or all products  
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
 • @ProductID: ID of a product, NULL to get all products  
   
 */  
BEGIN  
	DECLARE @DCSProducts TABLE(ProductID TINYINT)
	INSERT @DCSProducts
	SELECT DISTINCT ProductID
	FROM DBCUST.Custdb.dbo.ProductSettingDetail
	WHERE SettingStatus < 2

	SELECT [ProductID], CASE WHEN SUBSTRING([Language],12,LEN([Language]) - 11) = '' THEN 'EN' ELSE UPPER(SUBSTRING([Language],12,LEN([Language]) - 11)) END [Language], Name
	FROM 
	   (SELECT p.[ProductID]  
			  ,CAST([ProductName]   AS NVARCHAR(50)) [ProductName]
			  ,[ProductNameCh]  
			  ,[ProductNameCs]  
			  ,[ProductNameJp]  
			  ,[ProductNameIt]  
			  ,[ProductNameTh]  
			  ,[ProductNameKo]  
			  ,[ProductNameES]  
			  ,[ProductNameVN]  
			  ,[ProductNameEL]  
			  ,[ProductNameRU]  
			  ,[ProductNameID]  
		  FROM [dbo].[Products] p 
		  INNER JOIN @DCSProducts f ON f.ProductID = p.ProductID
		  WHERE @ProductID IS NULL OR p.[ProductID]=@ProductID  ) p
	UNPIVOT
	   (Name FOR [Language] IN 
		  ([ProductName],[ProductNameCh]  
			  ,[ProductNameCs]  
			  ,[ProductNameJp]  
			  ,[ProductNameIt]  
			  ,[ProductNameTh]  
			  ,[ProductNameKo]  
			  ,[ProductNameES]  
			  ,[ProductNameVN]  
			  ,[ProductNameEL]  
			  ,[ProductNameRU]  
			  ,[ProductNameID])
	)AS unpvt
	WHERE SUBSTRING([Language],12,LEN([Language]) - 11) = @LanguageKey
		OR (SUBSTRING([Language],12,LEN([Language]) - 11) = '' AND @LanguageKey='EN')
	;
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbExtAccNet]