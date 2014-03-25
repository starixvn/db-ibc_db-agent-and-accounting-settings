ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberKeno] 
	@CustID INT
	,@Sporttype INT = 202
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
		,@spositiontaking SMALLMONEY

	---------------------------
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	IF (@ErrCode > 0) RETURN

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
	DECLARE @MinMaxBetUpline TABLE (
		sporttype INT
		,gametypeid INT
		,bettype INT
		,MinBet_Min MONEY
		,Maxbet_Max MONEY
		,MaxperGame_Max MONEY
		)

	INSERT INTO @MinMaxBetUpline (
		sporttype
		,gametypeid
		,bettype
		,MinBet_Min
		,Maxbet_Max
		,MaxperGame_Max
		)
	SELECT @sporttype AS sporttype
		,gt.GameTypeID
		,gt.IBCBettypeID AS bettype
		,ISNULL(MIN(MinBet), 0) AS MinBet_Min
		,ISNULL(MIN(MaxBet), 0) AS Maxbet_Max
		,ISNULL(MIN(MaxPerGameType), 0) AS MaxperGame_Max
	FROM dbo.CustGameType AS cs WITH (NOLOCK)
		INNER JOIN dbo.GameType gt WITH (NOLOCK)
		ON cs.gametypeid = gt.gametypeid
		INNER JOIN dbo.custinfo AS ci WITH (NOLOCK)
		ON cs.custid = ci.custid
	WHERE ci.custid IN (@srecommend, @mrecommend, @recommend)
		AND ci.HideKeno = 0
		AND gt.IsDisabled = 0
	GROUP BY gt.GameTypeID
		,gt.IBCBettypeID

	--select custgametype setting
	SELECT gt.IBCBetTypeID
		,cg.MinBet
		,cg.MaxBet
		,cg.MaxPerGameType
		,ISNULL(mm.MinBet_Min, 0.00) MinBet_Min
		,ISNULL(mm.MaxBet_Max, 0.00) MaxBet_Max
		,ISNULL(mm.MaxperGame_Max, 0.00) MaxPerMatch_Max
		,cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN dbo.GameType gt WITH (NOLOCK)
		ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @MinMaxBetUpline mm
		ON cg.GameTypeID = mm.gametypeid
	WHERE cg.CustID = @CustID
		AND gt.IBCBetTypeID BETWEEN 1501 AND 1509
		AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID
		--check auto PT
		;

	WITH SuperPT
	AS (
		SELECT sporttype
			,bettype
			,spositiontaking
		FROM CustSettingGame WITH (NOLOCK)
		WHERE custid = @srecommend
			AND sporttype = @Sporttype
			AND Bettype BETWEEN 1501 AND 1509
		)
		,AutoPT
	AS (
		--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
		SELECT cs.Bettype
			,CASE 
				WHEN (
						acs.isautompositiontaking = 1
						OR cs.isautompositiontaking = 1
						) THEN acs.apositiontaking
				ELSE CASE 
						WHEN NOT (
								cs.isautopositiontaking = 0
								AND mcs.isautopositiontaking = 0
								) THEN mcs.mpositiontaking - cs.mpositiontaking
						ELSE CASE 
								WHEN mcs.mpositiontaking - cs.mpositiontaking <= st.spositiontaking - cs.spositiontaking - cs.mpositiontaking THEN mcs.mpositiontaking - cs.mpositiontaking
								ELSE st.spositiontaking - cs.spositiontaking - cs.mpositiontaking
								END
						END
				END AutoPT --US1
		FROM CustSettingGame cs WITH (NOLOCK)
			INNER JOIN CustSettingGame mcs WITH (NOLOCK)
			ON mcs.custid = @mrecommend
				AND mcs.sporttype = cs.sporttype
				AND mcs.bettype = cs.bettype
			INNER JOIN CustSettingGame acs WITH (NOLOCK)
			ON acs.custid = @recommend
				AND acs.sporttype = cs.sporttype
				AND acs.bettype = cs.bettype
			INNER JOIN SuperPT st
			ON cs.sporttype = st.sporttype
				AND cs.bettype = st.bettype
		WHERE cs.custid = @custid
			AND cs.sporttype = @Sporttype
			AND cs.Bettype BETWEEN 1501 AND 1509
		)
	--select PT/Comm setting
	SELECT cs.bettype
		,cs.apositiontaking --a1
		,ag.minpositiontaking AS apositiontaking_min--n2/MinPT
		,CASE 
			WHEN ag.apositiontaking <= at.AutoPT THEN ag.apositiontaking
			ELSE at.AutoPT
		END apositiontaking_max --l2/MaxPT
		,cs.playerdiscount --commission
		,ag.discount AS playerdiscount_max --maxcommission
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN (
		SELECT cg.Bettype
			,apositiontaking
			,discount
			,co.minpositiontaking
		FROM CustSettingGame cg WITH (NOLOCK)
			INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK)
			ON cg.CustID = co.CustID
				AND cg.Sporttype = co.Sporttype
				AND cg.Bettype = co.Bettype
		WHERE cg.CustID = @recommend
			AND cg.Bettype BETWEEN 1501 AND 1509
			AND cg.Sporttype = @Sporttype
		) ag
		ON cs.bettype = ag.bettype
		INNER JOIN (
		SELECT t.IBCBettypeID Bettype
		FROM dbo.CustGameType g WITH (NOLOCK)
			INNER JOIN dbo.GameType t WITH (NOLOCK)
			ON g.gametypeid = t.gametypeid
		WHERE g.custid = @CustID
			AND t.IBCBettypeID BETWEEN 1501 AND 1509
			AND t.IsDisabled = 0
		) gt
		ON cs.Bettype = gt.Bettype
		LEFT JOIN AutoPT at
		ON cs.Bettype = at.Bettype
	WHERE cs.CustID = @CustID
		AND cs.Sporttype = @Sporttype
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
