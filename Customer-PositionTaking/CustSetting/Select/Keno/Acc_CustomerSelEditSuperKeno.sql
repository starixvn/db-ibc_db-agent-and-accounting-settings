ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperKeno]
	@CustID		INT
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Select super's Keno setting
	DB: DBAGE/BODB02
		
	Revisions:
										
	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @downlines BIT
	SELECT @downlines = CASE WHEN EXISTS(SELECT TOP 1 1 FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID and roleid = 3) THEN 1 ELSE 0 END
	
	DECLARE @DisableDownlinesKeno TABLE (GameTypeID INT, DisableDownlines BIT)
	INSERT INTO @DisableDownlinesKeno (GameTypeID, DisableDownlines)
	SELECT cg.GameTypeID, CASE WHEN count(1) > 0 THEN 1 ELSE 0 END
	FROM CustGameType cg WITH (NOLOCK)
		INNER JOIN GameType gt WITH (NOLOCK) ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN custInfo c WITH (NOLOCK) ON cg.CustID = c.srecommend
	WHERE cg.CustID = @CustID and c.roleid = 3 and cg.IsDisabled = 1 and gt.IBCBetTypeID BETWEEN 1501 AND 1599
	GROUP BY cg.GameTypeID

	-- Customer Info
	SELECT	c.firstname,
			c.lastname,
			c.phone,
			c.mobilephone,
			c.fax
	FROM	Customer c WITH (NOLOCK)		
	WHERE	c.custID = @CustID 

	SELECT	gt.IBCBetTypeID, 
			cg.MinBet,
			cg.MaxBet,
			cg.MaxPerGameType,
			cg.IsDisabled,
			CASE WHEN @downlines = 0 then cg.IsDisabled ELSE d.DisableDownlines END AS DisableDownlinesKeno
	FROM CustGameType cg WITH (NOLOCK)
		INNER JOIN GameType gt WITH (NOLOCK) ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @DisableDownlinesKeno d ON cg.GameTypeID = d.GameTypeID
	WHERE cg.CustID = @CustID and gt.IBCBetTypeID BETWEEN 1501 AND 1599
	ORDER BY gt.IBCBetTypeID

	SELECT cs.spositiontaking, co.minpositiontaking, cs.sdiscount
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN CustOverrideGame co WITH (NOLOCK) ON cs.CustID = co.CustID AND cs.Bettype = co.Bettype AND cs.Sporttype = co.Sporttype
	WHERE cs.Sporttype = 202 AND cs.Bettype BETWEEN 1501 AND 1599 and cs.CustID = @CustID
	ORDER BY cs.Bettype
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperKeno] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperKeno] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperKeno] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperKeno] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperKeno] TO [vnteam]