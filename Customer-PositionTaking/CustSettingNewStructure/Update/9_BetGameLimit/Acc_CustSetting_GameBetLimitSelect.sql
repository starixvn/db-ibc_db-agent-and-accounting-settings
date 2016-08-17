ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetLimitSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20160108@Elodie
	Task : Get SMA Game Bet Limit setting values of a product
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
		
*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	SELECT SportType,Bettype 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID
			
	IF @RoleID = 4
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerNumber,				
				pbs.MinBet AS MinBetMin,
				pbs.MaxBet AS MaxBetMax,
				pbs.MaxPerMatch AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID

	ELSE IF @RoleID = 3
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerNumber,
				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN 0 
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  
				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN 0 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (sbl.MaxBet)) AS t(MaxBet)) END AS MaxBetMax,  
				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN 0 
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (sbl.MaxPerMatch)) AS t(MaxPerMatch)) END AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
	ELSE IF @RoleID = 2
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerNumber,

				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MinBet
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  

				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MaxBet
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (sbl.MaxBet), (mbl.MaxBet)) AS t(MaxBet)) END AS MaxBetMax,  

				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MaxPerMatch
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (sbl.MaxPerMatch), (mbl.MaxPerMatch)) AS t(MaxPerMatch)) END AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID
	ELSE IF @RoleID = 1
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerNumber,

				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 AND abl.MinBet = 0 AND abl.MaxBet = 0 AND abl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN abl.MinBet 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MinBet
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet), (abl.MinBet)) AS t(MinBet)) END AS MinBetMin, 
						 
				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 AND abl.MinBet = 0 AND abl.MaxBet = 0 AND abl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN abl.MaxBet 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MaxBet
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (sbl.MaxBet), (mbl.MaxBet), (abl.MaxBet)) AS t(MaxBet)) END AS MaxBetMax,  

				CASE	WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 AND abl.MinBet = 0 AND abl.MaxBet = 0 AND abl.MaxPerMatch = 0 THEN 0 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 AND mbl.MinBet = 0 AND mbl.MaxBet = 0 AND mbl.MaxPerMatch = 0 THEN abl.MaxPerMatch 
						WHEN sbl.MinBet = 0 AND sbl.MaxBet = 0 AND sbl.MaxPerMatch = 0 THEN mbl.MaxPerMatch
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (sbl.MaxPerMatch), (mbl.MaxPerMatch), (abl.MaxPerMatch)) AS t(MaxPerMatch)) END AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK) ON ft.SportType = abl.sporttype AND ft.BetType = abl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID AND abl.CustID = @AgentID

	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitSelect] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitSelect] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitSelect] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_GameBetLimitSelect] TO [vnteam] AS [dbo]