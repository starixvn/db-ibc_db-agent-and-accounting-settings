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
	SELECT [ProductID], CASE WHEN SUBSTRING([Language],12,LEN([Language]) - 11) = '' THEN 'EN' ELSE UPPER(SUBSTRING([Language],12,LEN([Language]) - 11)) END [Language], Name
	FROM 
	   (SELECT [ProductID]  
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
		  FROM [dbo].[Products]  
		  WHERE @ProductID IS NULL OR [ProductID]=@ProductID  ) p
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