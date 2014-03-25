ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterKeno]
	@CustID		INT
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Select master's Keno setting
	DB: DBAGE/BODB02
		
	Revisions:
										
	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)
	INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
	SELECT GameTypeID, IBCBetTypeID FROM GameType WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

	DECLARE @downlines BIT, @srecommend INT
	SELECT @downlines = CASE WHEN EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3) THEN 1 ELSE 0 END
	
	DECLARE @DisableDownlinesKeno TABLE (GameTypeID INT, DisableDownlines BIT)
	INSERT INTO @DisableDownlinesKeno (GameTypeID, DisableDownlines)
	SELECT cg.GameTypeID, CASE WHEN SUM(CASE WHEN cg.IsDisabled = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON cg.CustID = ci.CustID
	WHERE ci.mrecommend = @CustID AND ci.roleid = 2
	GROUP BY cg.GameTypeID

	--setting upline
	DECLARE  @SuperSetting TABLE(	
			bettype				INT,	
			mpositiontaking		SMALLMONEY,
			spositiontaking		SMALLMONEY,			
			minpositiontaking	SMALLMONEY,
			sdiscount			DECIMAL(9,8),
			adiscount			DECIMAL(9,8),
			MinBet				MONEY,
			MaxBet				MONEY,
			MaxPerGameType		MONEY				
	)
	SELECT @srecommend = srecommend
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE custID = @CustID 

	INSERT INTO @SuperSetting (bettype, mpositiontaking, spositiontaking, minpositiontaking, sdiscount, adiscount, minbet, maxbet, MaxPerGameType)
	SELECT	gt.IBCBetTypeID, 
			cs.mpositiontaking,
			cs.spositiontaking,
			co.minpositiontaking,
			cs.sdiscount,
			cs.adiscount,
			cg.MinBet, 
			cg.MaxBet, 
			cg.MaxPerGameType
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN CustSettingGame cs ON cs.CustID = cg.CustID AND cs.Sporttype = 202 AND cs.Bettype = gt.IBCBetTypeID
		INNER JOIN CustOverrideGame co ON co.CustID = cs.CustID AND co.Sporttype = cs.Sporttype AND co.Bettype = cs.Bettype
	WHERE cg.CustID = @srecommend
	ORDER BY gt.IBCBetTypeID

	--Customer Info
	SELECT firstname, lastname, phone, mobilephone, fax
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID 

	--BetSetting & Enable status
	SELECT	gt.IBCBetTypeID, 
			cg.MinBet, 
			bs.MinBet AS MinBet_Min,			
			cg.MaxBet, 
			cg.MaxPerGameType, 
			cg.IsDisabled, 
			CASE WHEN @downlines = 0 then cg.IsDisabled ELSE d.DisableDownlines END AS DisableDownlinesKeno
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @DisableDownlinesKeno d ON cg.GameTypeID = d.GameTypeID
		INNER JOIN ProductBetSetting bs ON gt.IBCBetTypeID = bs.bettype AND bs.sporttype = 202 AND Currency = @Currency		
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--PT & commission
	SELECT	cs.Bettype,
			cs.spositiontaking, --s4
			co.minpositiontaking, --n4
			gs.MaxPositiontaking, --l4
			cs.sdiscount,
			gs.Maxsdiscount
	FROM dbo.CustSettingGame cs WITH (NOLOCK)
		INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs.CustID = co.CustID AND cs.Bettype = co.Bettype AND cs.Sporttype = co.Sporttype
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN ProductGlobalSetting gs ON gt.IBCBetTypeID = gs.bettype AND gs.sporttype = co.Sporttype 
	WHERE cs.CustID = @CustID AND cs.Bettype BETWEEN 1501 AND 1599 AND cs.Sporttype = 202
	ORDER BY cs.Bettype
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterKeno] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterKeno] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterKeno] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterKeno] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterKeno] TO [vnteam]