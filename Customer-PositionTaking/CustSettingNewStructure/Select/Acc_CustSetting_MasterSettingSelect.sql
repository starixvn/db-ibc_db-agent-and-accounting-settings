SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterSettingSelect]   
   @CustID  INT  
 , @ProductID TINYINT  
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get all Master'setting values of a product  
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
 • @CustID: Master's ID  
   
 */  
BEGIN  
 DECLARE @downlines BIT  
  , @DisableAutoMPT BIT  
  
 SELECT @downlines = CASE   
   WHEN EXISTS (  
     SELECT TOP 1 1  
     FROM custinfo WITH (NOLOCK)  
     WHERE mrecommend = @custid  
      AND roleid = 2  
     )  
    THEN 1  
   ELSE 0  
   END  
  
 DECLARE @SuperID INT  
   
 SELECT @SuperID=ci.srecommend  
 FROM dbo.custInfo ci WITH(NOLOCK)  
 WHERE ci.custid=@CustID  
   
 DECLARE @Currency TINYINT  
   
 SELECT @Currency = Currency  
 FROM dbo.Customer c  
 WHERE c.custID = @CustID  
  
 --Cusinfo  
 SELECT c.username AS UserName  
   , c.username2 AS UserName2  
   , c.firstname AS FirstName  
   , c.lastname AS LastName  
   , c.phone AS Phone  
   , c.mobilephone AS MobilePhone  
   , c.email AS Email  
   , c.fax AS Fax  
 FROM Customer c WITH (NOLOCK)  
 WHERE c.custID = @CustID  
  
 --PT Setting  
 SELECT pdt.SportType  
  , pdt.BetType  
  , pdt.IsLive  
  , pt.superPT  AS S3  
  , pt.masterPT  AS M3  
  , pt.IsAutoSuperPT AS IS3  
  , pt.AutoSuperPT AS US3  
  , pt.minPT   AS N3  
  , superpt.SuperPT AS S4  
  , superpt.MasterPT AS M4  
  , superpt.MinPT  AS N4  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)  
  ON pdt.SportType = pt.sporttype  
   AND pdt.BetType = pt.bettype  
   AND pdt.IsLive = pt.islive  
   AND pt.custid = @CustID  
 INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
  ON pdt.SportType = superpt.sporttype  
   AND pdt.BetType = superpt.bettype  
   AND pdt.IsLive = superpt.islive  
   AND superpt.custid = @SuperID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 1  
  
 --Bet Limit Setting  
 SELECT pdt.SportType  
  , pdt.BetType  
  , bl.MinBet  
  , bl.MaxBet  
  , bl.MaxPerMatch  
  , CASE   
   WHEN sbl.minbet > pbs.MinBet  
    THEN sbl.minbet  
   ELSE pbs.MinBet  
   END AS MinBetMin  
  , sbl.maxbet AS MaxBetMax  
  , sbl.maxpermatch AS MaxPerMatchMax  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)  
  ON pdt.SportType = bl.sporttype  
   AND pdt.BetType = bl.bettype  
   AND bl.custid = @CustID  
 INNER JOIN dbo.ProductBetSetting pbs  
  ON pbs.SportType = bl.sporttype  
   AND pbs.BetType = bl.bettype  
   AND pbs.Currency = @Currency    
 INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)  
  ON pdt.SportType = sbl.sporttype  
   AND pdt.BetType = sbl.bettype  
   AND sbl.custid = @SuperID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 2  
  
 --Discount Setting  
 SELECT pdt.SportType  
  , pdt.BetType  
  , dc.Discount AS MasterDiscount  
  , sdc.Discount AS SuperDiscount  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)  
  ON pdt.SportType = dc.sporttype  
   AND pdt.BetType = dc.bettype  
   AND dc.custid = @CustID  
 INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK)  
  ON pdt.SportType = sdc.sporttype  
   AND pdt.BetType = sdc.bettype  
   AND sdc.custid = @SuperID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 3  
  
 --Product Status  
 SELECT stt.SportType  
  , stt.BetType  
  , pdt.SettingType  
  , ISNULL(stt.IsDisabled, 0) IsDisabled  
  , ISNULL(stt.IsHidden, 0) IsHidden  
  , ISNULL(stt.IsSync, 0) IsSync  
  , CASE   
   WHEN @downlines = 0  
    THEN ISNULL(stt.IsDisabled, 0)  
   ELSE ISNULL((  
      SELECT TOP 1 ISNULL(sstt.IsDisabled, 0)  
      FROM dbo.custInfo ci WITH (NOLOCK)  
      INNER JOIN dbo.CustProductStatus sstt  
       ON sstt.CustID = ci.custid  
        AND sstt.SportType = stt.SportType  
        AND sstt.BetType = stt.BetType  
        AND ISNULL(sstt.IsDisabled, 0) = 1  
      WHERE mrecommend = @CustID  
       AND roleid = 2  
      ), 0)  
   END AS IsDisabledDownline  
  , ISNULL(Superstt.IsDisabled, 0) AS IsDisabledUpline  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)  
  ON stt.SportType = pdt.SportType  
   AND stt.BetType = pdt.BetType  
   AND stt.CustID = @CustID  
 INNER JOIN dbo.CustProductStatus Superstt WITH (NOLOCK)  
  ON Superstt.SportType = pdt.SportType  
   AND Superstt.BetType = pdt.BetType  
   AND Superstt.CustID = @SuperID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 4  
    
 --SettingLevel  
 SELECT [1] AS PositionTakingLevel  
   ,[2] AS BetLimitLevel  
   ,[3] AS DiscountLevel  
   ,[4] AS StatusLevel  
 FROM  
 (  
  SELECT DISTINCT SettingType, SettingLevel  
  FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)   
  WHERE pdt.ProductID = @ProductID  
 ) result  
 PIVOT  
 (  
    MAX([SettingLevel]) FOR SettingType IN (  
       [1],[2],[3],[4]  
       )  
 ) AS pvt1  
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbExtAccNet]