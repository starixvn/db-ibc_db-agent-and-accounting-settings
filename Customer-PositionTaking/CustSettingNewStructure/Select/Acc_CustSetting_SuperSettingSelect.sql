SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20141104@Dominic
	Task : Get all Super'setting values of a product
	DB: DBAGE/bodb02
	Original:

	Param's Explanation:
	• @CustID: Super's ID
	
	*/
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
	FROM dbo.Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID

	--PT Setting
	SELECT pdt.SportType
		, pdt.BetType
		--, pdt.SettingType
		, pdt.IsLive
		, pt.SuperPT	AS S4
		, pt.MasterPT	AS M4
		, pt.AgentPT	AS A4
		, pt.MinPT		AS N4
		--, pt.MaxPT		AS L4
		, pdt.MaxPT		AS DefaultMaxPT
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
		ON pdt.SportType = pt.sporttype
			AND pdt.BetType = pt.bettype
			AND pdt.IsLive = pt.islive
			AND pt.custid = @CustID
	WHERE pdt.ProductID = @ProductID
		AND pdt.SettingType = 1

	--Bet Limit Setting
	SELECT pdt.SportType
		, pdt.BetType
		--, pdt.SettingType
		, bl.MinBet
		, bl.MaxBet
		, bl.MaxPerMatch
		, pbs.MinBet AS MinBet_Min
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		ON pdt.SportType = bl.sporttype
			AND pdt.BetType = bl.bettype
			AND bl.custid = @CustID
	INNER JOIN dbo.ProductBetSetting pbs
		ON pbs.SportType = bl.sporttype
			AND pbs.BetType = bl.bettype
			AND pbs.Currency = @Currency
	WHERE pdt.ProductID = @ProductID
		AND pdt.SettingType = 2

	--Discount Setting
	SELECT pdt.SportType
		, pdt.BetType
		--, pdt.SettingType
		, dc.Discount
		, ISNULL(pdt.MaxDiscount, 0) MaxDiscount
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
		ON pdt.SportType = dc.sporttype
			AND pdt.BetType = dc.bettype
			AND dc.custid = @CustID
	WHERE pdt.ProductID = @ProductID
		AND pdt.SettingType = 3

	--Product Status
	SELECT stt.SportType
		, stt.BetType
		--, pdt.SettingType
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
			END AS DisableDownlines
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
		ON stt.SportType = pdt.SportType
			AND stt.BetType = pdt.BetType
			AND stt.CustID = @CustID
	WHERE pdt.ProductID = @ProductID
		AND pdt.SettingType = 4
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbExtAccNet]