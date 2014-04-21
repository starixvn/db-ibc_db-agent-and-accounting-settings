ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerKeno]
	@custid		INT
AS
/*
	Created: 20140317@Patrick	
	Task: Master edit setting of Keno on member
	DB: DBAGE/BODB02
	
	Revisions:
	
	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @srecommend INT, @mrecommend INT, @recommend INT
	--Customer Info
	SELECT username, firstname, lastname, phone, mobilephone, fax
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID

	--BetSetting
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN dbo.GameType gt WITH (NOLOCK) ON cg.GameTypeID = gt.GameTypeID
	WHERE cg.CustID = @CustID and gt.IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID
	
	--PT
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
	FROM dbo.custinfo WITH (NOLOCK) WHERE custid = @custid

	--Get master PT value
	SELECT cs.bettype
		, cs.apositiontaking AS APositionTaking --a1
		, cs.mpositiontaking AS MPositionTaking --m1
		, cs.isautompositiontaking AS IsAuto_MPositionTaking_Mem --im1
		, cs.autompositiontaking AS Auto_MPositionTaking_Mem --um1

		, csa.isautompositiontaking  AS IsAuto_MPositionTaking --im2
		, csm.mpositiontaking AS Auto_MPositionTaking_Max --um1_max=min(m3,m4)

		, CASE WHEN NOT (cs.isautopositiontaking = 0 AND csm.isautopositiontaking = 0)
			THEN csm.mpositiontaking - cs.apositiontaking 
			ELSE CASE WHEN csm.mpositiontaking - cs.apositiontaking <= css.spositiontaking - cs.spositiontaking - cs.apositiontaking 
				THEN csm.mpositiontaking - cs.apositiontaking 
				ELSE css.spositiontaking - cs.spositiontaking - cs.apositiontaking END 
			END AS MPositionTaking_Max --!(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)--> m1_max
		, CASE WHEN sco.minpositiontaking - cs.apositiontaking < 0 THEN 0 
			ELSE sco.minpositiontaking - cs.apositiontaking END AS MPositionTaking_Min --m1_min=um1_min=Max(0, N3-A1)
	FROM dbo.CustSettingGame AS cs WITH (NOLOCK)
		INNER JOIN dbo.GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN dbo.CustSettingGame csa WITH (NOLOCK) ON csa.custid = @recommend AND csa.bettype = cs.bettype AND csa.sporttype = cs.sporttype 
		INNER JOIN dbo.CustSettingGame csm WITH (NOLOCK) ON csm.custid = @mrecommend AND csm.bettype = cs.bettype AND csm.sporttype = cs.sporttype 
		INNER JOIN dbo.CustSettingGame css WITH (NOLOCK) ON css.custid = @srecommend AND css.bettype = cs.bettype AND css.sporttype = cs.sporttype 
		INNER JOIN dbo.CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @mrecommend AND sco.bettype = cs.bettype AND sco.sporttype = cs.sporttype
	WHERE cs.custid = @custId 
		AND cs.bettype BETWEEN 1501 AND 1599
		AND cs.sporttype = 202
		AND IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

END



GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbDownlineNetView] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [vnteam] AS [dbo]
GO


