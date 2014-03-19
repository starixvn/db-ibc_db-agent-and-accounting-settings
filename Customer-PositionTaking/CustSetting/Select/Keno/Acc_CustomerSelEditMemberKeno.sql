ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberKeno] 
	@CustID INT

	,@ErrCode VARCHAR(300) = '' OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
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

	---------------------------
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	IF( @ErrCode > 0 ) RETURN

	SELECT TOP 1 @roleId = roleId
		,@mrecommend = srecommend
		,@srecommend = mrecommend
		,@recommend = recommend
	FROM dbo.custinfo WITH (NOLOCK)
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
	FROM dbo.Customer c WITH (NOLOCK)
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
	FROM dbo.CustGameType as cs WITH (NOLOCK) 
	INNER JOIN dbo.GameType gt WITH (NOLOCK) 
		on cs.gametypeid = gt.gametypeid
	JOIN dbo.custinfo as ci WITH (NOLOCK) 
			ON cs.custid=ci.custid		
	WHERE ci.custid IN (@srecommend, @mrecommend, @recommend)
		AND ci.HideKeno = 0
		AND gt.IsDisabled = 0
	group by gt.GameTypeID,
		gt.IBCBettypeID

	--select custgametype setting
	SELECT cg.CustID
		,mm.sporttype
		,gt.IBCBetTypeID  as BetType
		,cg.MinBet
		,cg.MaxBet
		,mm.MinBet_Min
		,mm.Maxbet_Max
		,mm.MaxperMatch_Max
		,cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN dbo.GameType gt WITH (NOLOCK)
		ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @MinMaxBetUpline mm
		ON cg.GameTypeID = mm.gametypeid
	WHERE cg.CustID = @CustID
		AND gt.IBCBetTypeID BETWEEN 1501 AND 1599
		AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID

	--select PT/Comm setting
	SELECT cs.custid
		,cs.bettype
		,cs.apositiontaking AS positiontaking
		,ag.apositiontaking
		,ag.adiscount
		,cs.playerdiscount
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN (
			SELECT bettype
				,apositiontaking
				,adiscount
			FROM CustSettingGame WITH (NOLOCK)
			WHERE CustID = @recommend
		) ag
		ON cs.bettype = ag.bettype
		INNER JOIN (
			SELECT t.IBCBettypeID Bettype
			FROM dbo.CustGameType g WITH (NOLOCK)
			INNER JOIN dbo.GameType t WITH (NOLOCK)
			ON g.gametypeid = t.gametypeid
			WHERE g.custid = @CustID
				AND t.IBCBettypeID BETWEEN 1501 AND 1599
				AND t.IsDisabled = 0
		) gt
		ON cs.Bettype = gt.Bettype
	WHERE cs.CustID = @CustID
		AND cs.Sporttype = 202
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
