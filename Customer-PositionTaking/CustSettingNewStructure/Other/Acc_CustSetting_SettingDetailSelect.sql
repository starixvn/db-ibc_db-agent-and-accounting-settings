SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_SettingDetailSelect] 
	  @ProductID TINYINT
AS
/*
	Created: 20150304@Dominic
	Task : Get sport/bet types that belong to a specified product
	DB:  DBAGE/bodb02
	Original:

	Param's Explanation:
	• @ProductID: ID of a product
	
	*/
BEGIN
	SELECT [SettingType]
      ,[SportType]
      ,[BetType]
      ,[IsLive]
  FROM [dbo].[ProductSettingDetail]
  WHERE[ProductID]=@ProductID

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbExtAccNet]