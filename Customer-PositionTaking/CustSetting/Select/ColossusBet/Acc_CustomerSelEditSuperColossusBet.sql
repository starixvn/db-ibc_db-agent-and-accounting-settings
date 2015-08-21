IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Acc_CustomerSelEditSuperColossusBet]') AND type in (N'P', N'PC'))
		DROP PROCEDURE [dbo].[Acc_CustomerSelEditSuperColossusBet]

GO

 /*  
    Created By: Helen  
    Created Date: Aug 18, 2015
    Description: # Colossus Bet Product
    
    DB: DBCUST / CustDB
*/ 

CREATE PROCEDURE [dbo].[Acc_CustomerSelEditSuperColossusBet]      
(
    @custid  INT      
)
AS      
BEGIN  
          
    SET NOCOUNT ON      
          
    DECLARE @Downlines BIT    = 1  
            ,@DisableDownlines BIT = 0  
            ,@DisableColossusBet BIT   
          
    IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)  
        SET @Downlines = 0      
    ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND DisableColossusBet = 1)  
        SET @DisableDownlines = 1  
          
    SELECT  @DisableColossusBet = @DisableColossusBet  
    FROM    dbo.custInfo WITH(NOLOCK)  
    WHERE   custid = @custid  
          
     
    --Customer Info  
    SELECT    username  
            ,username2 AS nickname  
            ,firstname  
            ,lastname  
            ,phone  
            ,mobilephone  
            ,fax  
            ,0 AS DisableUpline  
            ,ISNULL(@DisableColossusBet,1) AS DisableColossusBet  
            ,@Downlines AS Downlines  
            ,@DisableDownlines AS DisableDownlines  
    FROM  dbo.Customer WITH (NOLOCK)  
    WHERE custID = @CustID             
           
     -- Commission 
     
     SELECT  cs.sdiscount AS v204sdiscount_18001
			, gs.Maxsdiscount AS v204sdicount_18001_max      
     FROM    CustSettingGame cs WITH (NOLOCK)  
		JOIN ProductGlobalSetting gs WITH (NOLOCK) ON gs.Sporttype =  cs.Sporttype AND gs.IsDep = 0  
     WHERE custid = @custid 
			AND cs.sporttype = 204   
            AND cs.bettype = 18001      
            
    -- Cash In Share          
    SELECT  cs.sdiscount AS v204sdiscount_18002,      
            gs.Maxsdiscount AS v204sdicount_18002_max      
     FROM    CustSettingGame cs WITH (NOLOCK)  
		JOIN ProductGlobalSetting gs WITH (NOLOCK) ON gs.Sporttype =  cs.Sporttype AND gs.IsDep = 0  
     WHERE custid = @custid   
            AND cs.sporttype = 204   
            AND cs.bettype = 18002      
     
	SET NOCOUNT OFF
          
END