ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentKeno]
	@custid INT
AS
/*
	Created: 20140319@Patrick
	Task: Master edits agent's Keno setting
	DB: DBAGE/BODB02
	
	Revisions:
	
	Parameters Explanation
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @mrecommend INT, @srecommend INT
	SELECT @mrecommend = mrecommend, @srecommend = srecommend FROM dbo.CustInfo WITH (NOLOCK) WHERE CustId = @custid

	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)
	INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
	SELECT GameTypeID, IBCBetTypeID FROM dbo.GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

	--Check downline?
	DECLARE @hasDownline BIT = 0
	SELECT @hasDownline = CASE WHEN EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid = 1) THEN 1 ELSE 0 END

	--Get downlines
	DECLARE @DisableDownlinesKeno TABLE (GameTypeID INT, DisableDownlines BIT)
	INSERT INTO @DisableDownlinesKeno (GameTypeID, DisableDownlines)
	SELECT cg.GameTypeID, CASE WHEN SUM(CASE WHEN cg.IsDisabled = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON cg.CustID = ci.CustID
	WHERE ci.recommend = @custid AND ci.roleid = 1
	GROUP BY cg.GameTypeID

	DECLARE @MasterDisabled TABLE (gametypeid INT, IsDisabled BIT)
	INSERT INTO @MasterDisabled (gametypeid, IsDisabled)
	SELECT cg.gametypeid, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.CustID = @mrecommend

	--Get Min, Max, Max PerMatch of upline
	DECLARE @MasterSetting TABLE (GameTypeID INT, MinBet_Min MONEY, MaxBet_Max MONEY, MaxPerMatch_Max MONEY)
	INSERT INTO @MasterSetting(GameTypeID, MinBet_Min, MaxBet_Max, MaxPerMatch_Max)
	SELECT cg.GameTypeID
		, MAX(ISNULL(cg.MinBet, 0)) AS MinBet_Min
		, MIN(ISNULL(cg.MaxBet, 0)) AS MaxBet_Max
		, MIN(ISNULL(cg.MaxPerGameType, 0)) AS MaxperMatch_Max
	FROM dbo.CustGameType cg WITH(NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
	WHERE cg.custid IN (@srecommend, @mrecommend)
	GROUP BY cg.GameTypeID

	--Get custinfo
	SELECT username, firstname, lastname, phone, mobilephone, fax
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID

	--BetSetting & Enable status
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType
		, ul.MinBet_Min, ul.MaxBet_Max, ul.MaxPerMatch_Max
		, cg.IsDisabled
		, md.IsDisabled AS DisableUplinesKeno
		, CASE WHEN @hasDownline = 0 THEN cg.IsDisabled ELSE ISNULL(d.DisableDownlines, 1) END AS DisableDownlinesKeno
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @MasterSetting ul ON cg.GameTypeID = ul.GameTypeID
		INNER JOIN @MasterDisabled md ON cg.GameTypeID = md.GameTypeID
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		LEFT JOIN @DisableDownlinesKeno d ON cg.GameTypeID = d.GameTypeID
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--PT
	SELECT cs.BetType
		, ISNULL(cs.discount, 0) AS discount
		, ISNULL(mcs.adiscount, 0) AS discount_max
		, cs.apositiontaking AS apositiontaking --a2
		, cs.mpositiontaking AS mpositiontaking --m2
		, mcs.mpositiontaking AS mpositiontaking_max --m3 = u2_max
		, cs.autompositiontaking AS auto_mpositiontaking --u2
		, cs.isautompositiontaking AS isauto_mpositiontaking --i2
		--, mcs.mpositiontaking AS auto_mpositiontaking_max --u2_max
		, co.minpositiontaking AS apositiontaking_min --n2
	FROM dbo.custsettingGame cs WITH(NOLOCK)
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN dbo.custsettingGame mcs WITH(NOLOCK) ON mcs.CustID = @mrecommend AND cs.bettype = mcs.bettype AND cs.Sporttype = mcs.sporttype
		INNER JOIN dbo.custoverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
	WHERE cs.custid = @custid AND cs.bettype BETWEEN 1501 AND 1599 AND cs.sporttype = 202

END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentKeno] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentKeno] TO [bodbExtAccNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentKeno] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditAgentKeno] TO [vnteam] AS [dbo]
GO


