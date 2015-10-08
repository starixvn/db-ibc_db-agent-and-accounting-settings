SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterSettingSelect]   
	@CustID			INT  
	, @ProductID	TINYINT  
	, @SettingType	SMALLINT
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get Master'setting values of a product  
 DB:  DBCUST/CustDB  
 Original:  
  
 Param's Explanation:  
 • @CustID: Master's ID  
   
 */  
BEGIN  
	DECLARE @SuperID INT  

	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	SELECT @SuperID=ci.srecommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID  
	
	--PT Setting 
	IF @SettingType = 1
	BEGIN 
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
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
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
	END
	--Bet Limit Setting
	ELSE IF @SettingType = 2
	BEGIN 
		DECLARE @Currency TINYINT  

		SELECT @Currency = Currency  
		FROM dbo.Customer c  
		WHERE c.custID = @CustID  
 
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
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType 
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
	END 
	--Discount Setting  
	ELSE IF @SettingType = 3
	BEGIN 
		SELECT pdt.SportType  
			, pdt.BetType  
			, dc.Discount AS MasterDiscount  
			, sdc.Discount AS SuperDiscount  
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
		INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)  
			ON pdt.SportType = dc.sporttype  
			AND pdt.BetType = dc.bettype  
			AND dc.custid = @CustID  
		INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK)  
			ON pdt.SportType = sdc.sporttype  
			AND pdt.BetType = sdc.bettype  
			AND sdc.custid = @SuperID  
	END
	--Product Status  
	ELSE IF @SettingType = 4
	BEGIN 
		DECLARE @downlines BIT  

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
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)  
			ON stt.SportType = pdt.SportType  
			AND stt.BetType = pdt.BetType  
			AND stt.CustID = @CustID  
		INNER JOIN dbo.CustProductStatus Superstt WITH (NOLOCK)  
			ON Superstt.SportType = pdt.SportType  
			AND Superstt.BetType = pdt.BetType  
			AND Superstt.CustID = @SuperID  
	END    
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbExtAccNet]