SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentSettingSelect]   
   @CustID INT  
 , @ProductID TINYINT  
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get all Agent'setting values of a product  
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
 • @CustID: Agent's ID  
   
 */  
BEGIN  
 DECLARE @downlines  BIT  
  , @DisableAutoMPT BIT  
  
 SELECT @downlines = CASE   
   WHEN EXISTS (  
     SELECT TOP 1 1  
     FROM custinfo WITH (NOLOCK)  
     WHERE recommend = @custid  
      AND roleid = 1  
     )  
    THEN 1  
   ELSE 0  
   END  
  
 DECLARE @SuperID INT, @MasterID INT  
   
 SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend  
 FROM dbo.custInfo ci WITH(NOLOCK)  
 WHERE ci.custid=@CustID  
   
 DECLARE @Currency TINYINT  
   
 SELECT @Currency = Currency  
 FROM dbo.Customer c  
 WHERE c.custID = @CustID  
   
 --Disable auto master PT  
 SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)  
 FROM CustMaster WITH (NOLOCK)  
 WHERE CustID = @MasterID  
  
 --Cusinfo  
 SELECT c.username AS UserName  
   , c.username2 AS UserName2  
   , c.firstname AS FirstName  
   , c.lastname AS LastName  
   , c.phone AS Phone  
   , c.mobilephone AS MobilePhone  
   , c.email AS Email  
   , c.fax AS Fax  
  , @DisableAutoMPT AS DisableAutoMPT  
 FROM Customer c WITH (NOLOCK)  
 WHERE c.custID = @CustID  
  
 --PT Setting  
 SELECT pdt.SportType  
  , pdt.BetType  
  , pdt.IsLive  
  , pt.masterPT AS M2  
  , pt.agentPT AS A2  
  , pt.IsAutoMasterPT AS IM2  
  , pt.AutoMasterPT AS UM2  
  , pt.minPT AS N2  
  , CASE   
   WHEN masterpt.masterPT < masterpt.maxPT  
    THEN masterpt.masterPT  
   ELSE masterpt.maxPT  
   END AS M3  
  , masterpt.minPT AS N3  
  , superpt.agentPT AS A4
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)  
  ON pdt.SportType = pt.sporttype  
   AND pdt.BetType = pt.bettype  
   AND pdt.IsLive = pt.islive  
   AND pt.custid = @CustID  
 INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
  ON pdt.SportType = masterpt.sporttype  
   AND pdt.BetType = masterpt.bettype  
   AND pdt.IsLive = masterpt.islive  
   AND masterpt.custid = @MasterID  
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
   WHEN sbl.minbet >= mbl.minbet  
    AND sbl.minbet >= pbs.MinBet  
    THEN sbl.minbet  
   WHEN mbl.minbet >= sbl.minbet  
    AND mbl.minbet >= pbs.MinBet  
    THEN mbl.minbet  
   WHEN pbs.MinBet >= sbl.minbet  
    AND pbs.MinBet >= mbl.minbet  
    THEN pbs.MinBet  
   END AS MinBetMin  
  , CASE   
   WHEN (sbl.maxbet < mbl.maxbet OR mbl.maxbet = 0) AND sbl.maxbet <> 0  
    THEN sbl.maxbet  
   ELSE mbl.maxbet  
   END AS MaxBetMax  
  , CASE   
   WHEN (sbl.MaxPerMatch < mbl.MaxPerMatch OR mbl.MaxPerMatch = 0) AND sbl.MaxPerMatch <> 0  
    THEN sbl.MaxPerMatch  
   ELSE mbl.MaxPerMatch  
   END AS MaxPerMatchMax  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)  
  ON pdt.SportType = bl.sporttype  
   AND pdt.BetType = bl.bettype  
   AND bl.custid = @CustID  
 INNER JOIN dbo.ProductBetSetting pbs  
  ON pbs.SportType = bl.sporttype  
   AND pbs.BetType = bl.bettype  
   AND pbs.Currency = @Currency   
 INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK)  
  ON pdt.SportType = mbl.sporttype  
   AND pdt.BetType = mbl.bettype  
   AND mbl.custid = @MasterID  
 INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)  
  ON pdt.SportType = sbl.sporttype  
   AND pdt.BetType = sbl.bettype  
   AND sbl.custid = @SuperID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 2  
  
 --Discount Setting  
 SELECT pdt.SportType  
  , pdt.BetType  
  , dc.Discount AS AgentDiscount  
  , mdc.Discount AS MasterDiscount  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)  
  ON pdt.SportType = dc.sporttype  
   AND pdt.BetType = dc.bettype  
   AND dc.custid = @CustID  
 INNER JOIN dbo.CustDiscount3rd_Agent mdc WITH (NOLOCK)  
  ON pdt.SportType = mdc.sporttype  
   AND pdt.BetType = mdc.bettype  
   AND mdc.custid = @MasterID  
 WHERE pdt.ProductID = @ProductID  
  AND pdt.SettingType = 3  
  
 --Product Status  
 SELECT stt.SportType  
  , stt.BetType  
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
      WHERE recommend = @CustID  
       AND roleid = 1  
      ), 0)  
   END AS IsDisabledDownline  
  , ISNULL(Masterstt.IsDisabled, 0) AS IsDisabledUpline  
 FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
 INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)  
  ON stt.SportType = pdt.SportType  
   AND stt.BetType = pdt.BetType  
   AND stt.CustID = @CustID  
 INNER JOIN dbo.CustProductStatus Masterstt WITH (NOLOCK)  
  ON Masterstt.SportType = pdt.SportType  
   AND Masterstt.BetType = pdt.BetType  
   AND Masterstt.CustID = @MasterID  
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
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbExtAccNet]