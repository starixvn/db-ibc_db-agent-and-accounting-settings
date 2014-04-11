ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberKeno] 
	@CustID INT
AS
/*
	Created: Bobby
	Date: 20140225
	Task: Select member's Keno setting
	DB: DBAGE/BODB02
		
	Revisions:
										
	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)
	INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
	SELECT GameTypeID, IBCBetTypeID FROM GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

	DECLARE @srecommend INT, @mrecommend INT, @recommend INT
	SELECT @mrecommend = srecommend, @srecommend = mrecommend, @recommend = recommend
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE custid = @CustID

	DECLARE @AgentDisabled TABLE (gametypeid INT, IsDisabled BIT)
	INSERT INTO @AgentDisabled (gametypeid, IsDisabled)
	SELECT cg.gametypeid, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.CustID = @recommend

	--calculate min, max for minbet, maxbet, maxpermatch
	DECLARE @AgentSetting TABLE (
		gametypeid INT
		,MinBet_Min MONEY
		,Maxbet_Max MONEY
		,MaxPerMatch_Max MONEY
		)

	INSERT INTO @AgentSetting (
		Gametypeid
		,MinBet_Min
		,Maxbet_Max
		,MaxPerMatch_Max
		)
	SELECT gt.GameTypeID
		,MAX(ISNULL(MinBet, 0)) AS MinBet_Min
		,MIN(ISNULL(MaxBet, 0)) AS Maxbet_Max
		,MIN(ISNULL(MaxPerGameType, 0)) AS MaxPerMatch_Max
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.custid IN (@srecommend, @mrecommend, @recommend)
	GROUP BY gt.GameTypeID

	-- Customer Info
	SELECT c.custid
		,c.username
		,c.firstname
		,c.lastname
		,c.phone
		,c.mobilephone
		,c.fax
	FROM dbo.Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID

	--select custgametype setting
	SELECT gt.IBCBetTypeID
		,cg.MinBet
		,cg.MaxBet
		,cg.MaxPerGameType
		,acs.MinBet_Min
		,acs.MaxBet_Max
		,acs.MaxPerMatch_Max
		,cg.IsDisabled
		,ad.IsDisabled AS DisableUplinesKeno
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @AgentSetting acs ON cg.GameTypeID = acs.GameTypeID
		INNER JOIN @AgentDisabled ad ON cg.GameTypeID = ad.GameTypeID
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--select PT/Comm setting
	SELECT cs.bettype
		,cs.apositiontaking --a1
		,aco.minpositiontaking AS apositiontaking_min--n2/MinPT
		,acs.apositiontaking AS apositiontaking_max --l2/MaxPT
		,cs.playerdiscount --commission
		,acs.discount AS playerdiscount_max --maxcommission
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID 
		INNER JOIN CustSettingGame acs WITH (NOLOCK) ON acs.CustID = @recommend AND cs.bettype = acs.bettype AND cs.Sporttype = acs.sporttype
		INNER JOIN dbo.CustOverrideGame aco WITH (NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype		 
	WHERE cs.CustID = @CustID AND cs.bettype BETWEEN 1501 AND 1599 AND cs.sporttype = 202
	ORDER BY cs.Bettype

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberKeno] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberKeno] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberKeno] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberKeno] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMemberKeno] TO [vnteam]
