SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_AllowMasterPTSelect]   
	@CustID			INT  
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get automasterPT  
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
 • @CustID: Master ID 
   
 */  
BEGIN   	

	--Disable auto master PT  
	SELECT ISNULL(DisableAutoMPT, 0)  
	FROM CustMaster WITH (NOLOCK)  
	WHERE CustID = @CustID 
	

END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbExtAccNet]