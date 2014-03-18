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

	DECLARE @roleId TINYINT
		,@srecommend INT
		,@mrecommend INT
		,@recommend INT

	SELECT TOP 1 @roleId = roleId
		,@mrecommend = srecommend
		,@srecommend = mrecommend
		,@recommend = recommend
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @CustID

	IF (@roleId <> 1) RETURN;

	-- Customer Info
	SELECT c.custid 
		,c.username
		,c.firstname
		,c.lastname
		,c.phone
		,c.mobilephone
		,c.fax
	FROM Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID

	--calculate min, max for minbet, maxbet, maxpermatch for Web
	DECLARE @MinMaxBetUpline table(
				sporttype int, 
				gametypeid int,
				bettype int, 
				MinBet_Min MONEY,
				Maxbet_Max MONEY,
				MaxperMatch_Max MONEY
			)
	INSERT INTO @MinMaxBetUpline(sporttype,gametypeid, bettype, MinBet_Min, Maxbet_Max, MaxperMatch_Max)
	SELECT 202 AS sporttype,
		gt.GameTypeID,
		gt.IBCBettypeID AS bettype,
		ISNULL(MIN(MinBet), 0) as MinBet_Min,   
		ISNULL(MIN(MaxBet),0) as Maxbet_Max,
		ISNULL(MIN(MaxPerGameType), 0) AS MaxperMatch_Max		
	FROM CustGameType as cs WITH (NOLOCK) 
	inner join GameType gt WITH (NOLOCK) 
		on cs.gametypeid = gt.gametypeid
	JOIN custinfo as ci WITH (NOLOCK) 
			ON cs.custid=ci.custid		
	WHERE ci.custid IN (@srecommend, @mrecommend, @recommend)
	group by gt.GameTypeID,
		gt.IBCBettypeID

	SELECT cg.CustID
		,mm.sporttype
		,gt.IBCBetTypeID  as BetType
		,cg.MinBet
		,cg.MaxBet
		,mm.MinBet_Min
		,mm.Maxbet_Max
		,mm.MaxperMatch_Max
		,cg.IsDisabled
	FROM CustGameType cg WITH (NOLOCK)
		INNER JOIN GameType gt WITH (NOLOCK)
		ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @MinMaxBetUpline mm
		ON cg.GameTypeID = mm.gametypeid
	WHERE cg.CustID = @CustID
		AND gt.IBCBetTypeID BETWEEN 1501 AND 1599
		AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID

	SELECT cs.custid
		,cs.bettype
		,cs.apositiontaking
		,cs.adiscount
		,cs.discount
		,cs.playerdiscount
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN CustOverrideGame co WITH (NOLOCK)
		ON cs.CustID = co.CustID
			AND cs.Bettype = co.Bettype
			AND cs.Sporttype = co.Sporttype
	WHERE cs.Sporttype = 202
		AND cs.Bettype BETWEEN 1501 AND 1599
		AND cs.CustID = @CustID
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
