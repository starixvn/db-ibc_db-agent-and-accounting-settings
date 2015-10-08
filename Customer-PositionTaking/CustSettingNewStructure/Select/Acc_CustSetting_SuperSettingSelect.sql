SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingType	SMALLINT
AS
/*
	Created: 20141104@Dominic
	Task : Get Super'setting values of a product
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	• @CustID: Super's ID
	
	*/
BEGIN
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)	
	
	--PT Setting
	IF @SettingType = 1
	BEGIN		
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.IsLive
			, pt.SuperPT	AS S4
			, pt.MasterPT	AS M4
			, pt.AgentPT	AS A4
			, pt.MinPT		AS N4
			, pdt.MaxPT		AS DefaultMaxPT
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
	END
	--Bet Limit Setting
	ELSE IF @SettingType = 2
	BEGIN
		DECLARE @Currency TINYINT
	
		SELECT @Currency = Currency
		FROM dbo.Customer c WITH(NOLOCK)
		WHERE c.custID = @CustID
	
		SELECT pdt.SportType
			, pdt.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, pbs.MinBet AS MinBetMin
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
	END
	--Discount Setting
	ELSE IF @SettingType = 3
	BEGIN
		SELECT pdt.SportType
			, pdt.BetType
			, dc.Discount AS SuperDiscount
			, ISNULL(pdt.MaxDiscount, 0) AS DefaultMaxDiscount
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
	END
	--Product Status
	ELSE IF @SettingType = 4
	BEGIN
		DECLARE @downlines BIT

		SELECT @downlines = CASE 
				WHEN EXISTS (
						SELECT TOP 1 1
						FROM custinfo WITH (NOLOCK)
						WHERE srecommend = @CustID
							AND roleid = 3
						)
					THEN 1
				ELSE 0
				END
			
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
							WHERE srecommend = @CustID
								AND roleid = 3
							), 0)
				END AS IsDisabledDownline
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
	END	
	
	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbExtAccNet]