SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductNamesSelect] 
	  @ProductID TINYINT = NULL
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
	SELECT [ProductID]
      ,[ProductName]
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
  FROM [bodb02].[dbo].[Products]
  WHERE @ProductID IS NULL OR [ProductID]=@ProductID
  ORDER BY [ProductID]
END