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
	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)
	INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
	SELECT GameTypeID, IBCBetTypeID FROM GameType WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

	DECLARE @downlines BIT
	SELECT @downlines = CASE WHEN EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3) THEN 1 ELSE 0 END
	
	DECLARE @DisableDownlinesKeno TABLE (GameTypeID INT, DisableDownlines BIT)
	INSERT INTO @DisableDownlinesKeno (GameTypeID, DisableDownlines)
	SELECT cg.GameTypeID, CASE WHEN SUM(CASE WHEN cg.IsDisabled = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON cg.CustID = ci.srecommend
	WHERE cg.CustID = @CustID AND ci.roleid = 3
	GROUP BY cg.GameTypeID

	--Customer Info
	SELECT firstname, lastname, phone, mobilephone, fax
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID 

	--BetSetting & Enable status
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType, cg.IsDisabled
		, CASE WHEN @downlines = 0 then cg.IsDisabled ELSE d.DisableDownlines END AS DisableDownlinesKeno
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @DisableDownlinesKeno d ON cg.GameTypeID = d.GameTypeID
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--PT
	SELECT cs.spositiontaking, co.minpositiontaking
	FROM dbo.CustSettingGame cs WITH (NOLOCK)
		INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs.CustID = co.CustID AND cs.Bettype = co.Bettype AND cs.Sporttype = co.Sporttype
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID
	WHERE cs.CustID = @CustID AND cs.Bettype BETWEEN 1501 AND 1599 AND cs.Sporttype = 202
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