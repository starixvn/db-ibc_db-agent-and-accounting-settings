ALTER FUNCTION	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency (
					@CustID			INT
				,	@ProductID		TINYINT
				)
RETURNS TABLE
AS
RETURN (
	SELECT	c.custid
		,	psd.ProductID
		,	psd.SportType
		,	psd.BetType
		,	c.currency
		,	CASE	WHEN EXISTS (SELECT 1 FROM dbo.ProductStatusSiteCurrency AS sc WHERE sc.SportType = psd.SportType)
						THEN dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) & ISNULL(pssc.IsHidden, psd.IsHidden)
					ELSE 0
			END IsHidden
	FROM		dbo.Customer AS c WITH (NOLOCK)
	INNER JOIN	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
			ON	psd.SettingType = 4
	INNER JOIN	dbo.Site AS s WITH (NOLOCK)
			ON	s.site = c.site
	LEFT JOIN	dbo.ProductStatusSiteCurrency AS pssc WITH (NOLOCK)
			ON	pssc.SportType = psd.SportType
			AND	pssc.BetType = psd.BetType
			AND	(	pssc.Currency = c.currency
				OR	s.siteid = pssc.SiteID
			)
	INNER JOIN	dbo.ProductStatusProfile AS psp WITH (NOLOCK)
			ON	psp.Sporttype = psd.SportType
			AND	psp.Bettype = psd.BetType
	LEFT JOIN	dbo.CustProductStatus AS cps WITH (NOLOCK)
			ON	cps.CustID = c.custid
	WHERE	c.custid = @CustID
		AND	psd.ProductID = ISNULL(@ProductID, psd.ProductID)
);
GO