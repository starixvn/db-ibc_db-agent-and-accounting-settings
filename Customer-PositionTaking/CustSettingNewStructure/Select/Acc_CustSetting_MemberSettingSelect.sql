SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @RoleID		INT
AS
/*
	Created: 20141104@Dominic
	Task : Get all Member'setting values of a product
	DB:  DBAGE/bodb02
	Original:

	Param's Explanation:
	• @CustID: Member's ID
	• @RoleID: 	2-Agent select
				3-Master select
				4-Super select
	
	*/
BEGIN
	IF @RoleID NOT IN (2, 3, 4)
		RETURN

	DECLARE @DisableAutoMPT BIT
	DECLARE @MemberPT TABLE (
		  SportType		SMALLINT
		, BetType		SMALLINT
		, IsLive		BIT
		, IsGroupedPT	BIT
		, S1			TINYINT
		, M1			TINYINT
		, A1			TINYINT
		, IS1			BIT
		, US1			TINYINT
		, IM1			BIT
		, UM1			TINYINT
		)

	DECLARE @SuperID INT, @MasterID INT, @AgentID	INT
	
	SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend , @AgentID = ci.recommend
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID
	
	--Get member setting from Group OR Individual Settings	
	INSERT INTO @MemberPT
	SELECT pdt.SportType
		, pdt.BetType
		, pdt.IsLive
		, mode.IsGrouped
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.SuperPT
			ELSE ptgr.SuperPT
			END AS S1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.MasterPT
			ELSE ptgr.MasterPT
			END AS M1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.AgentPT
			ELSE ptgr.AgentPT
			END AS A1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.IsAutoSuperPT
			ELSE ptgr.IsAutoSuperPT
			END AS IS1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.AutoSuperPT
			ELSE ptgr.AutoSuperPT
			END AS US1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.IsAutoMasterPT
			ELSE ptgr.IsAutoMasterPT
			END AS IM1
		, CASE 
			WHEN mode.IsGrouped = 0
				THEN pt.AutoMasterPT
			ELSE ptgr.AutoMasterPT
			END AS UM1
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustSettingMode3rd mode
		ON mode.CustID = @CustID
	LEFT JOIN dbo.CustPTSetting3rd_Member pt WITH (NOLOCK)
		ON pdt.SportType = pt.sporttype
			AND pdt.BetType = pt.bettype
			AND pdt.IsLive = pt.islive
			AND pt.custid = @CustID
	LEFT JOIN CustPTGroupSetting3rd_Member ptgr WITH (NOLOCK)
		ON pdt.SportType = ptgr.sporttype
			AND pdt.BetType = ptgr.bettype
			AND pdt.IsLive = ptgr.islive
			AND ptgr.AgentID = @AgentID
	WHERE pdt.ProductID = @ProductID
		AND pdt.SettingType = 1

	IF @RoleID = 4
	BEGIN
		--Cusinfo
		SELECT c.username
			, c.username2
			, c.firstname
			, c.lastname
			, c.phone
			, c.mobilephone
			, c.email
			, c.fax
			, c.roleid
		FROM Customer c WITH (NOLOCK)
		WHERE c.custID = @CustID

		--PT SETTING
		SELECT mb.IsGroupedPT
			, mb.A1
			, mb.M1
			, mb.S1
			, mb.IS1
			, mb.US1
			, masterpt.IsAutoSuperPT AS IS3
			,
			-- us1_max=S4
			superpt.SuperPT AS US1_Max
			,
			-- s1_max= Max(N4-M1-A1, S4-M3)
			CASE 
				WHEN superpt.SuperPT - masterpt.MasterPT > superpt.MinPT - (mb.M1 + mb.A1)
					THEN superpt.SuperPT - masterpt.MasterPT
				ELSE superpt.MinPT - (mb.M1 + mb.A1)
				END AS S1_MAX
			,
			-- s1_min = Max(0, N4-M1-A1)
			CASE 
				WHEN superpt.MinPT - (mb.M1 + mb.A1) < 0
					THEN 0
				ELSE superpt.MinPT - (mb.M1 + mb.A1)
				END AS S1_MIN
		FROM @MemberPT mb
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)
			ON mb.SportType = masterpt.sporttype
				AND mb.BetType = masterpt.bettype
				AND mb.IsLive = masterpt.islive
				AND masterpt.custid = @MasterID
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
			ON mb.SportType = superpt.sporttype
				AND mb.BetType = superpt.bettype
				AND mb.IsLive = superpt.islive
				AND superpt.custid = @SuperID

		--Bet Limit Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			ON pdt.SportType = bl.sporttype
				AND pdt.BetType = bl.bettype
				AND bl.custid = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 2

		--Discount Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, dc.PlayerDiscount
			, dc.AgentDiscount
			, dc.MasterDiscount
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON pdt.SportType = dc.sporttype
				AND pdt.BetType = dc.bettype
				AND dc.custid = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 3

		--Product Status
		SELECT stt.SportType
			, stt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, ISNULL(stt.IsHidden, 0) IsHidden
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON stt.SportType = pdt.SportType
				AND stt.BetType = pdt.BetType
				AND stt.CustID = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 4
	END
	ELSE IF @RoleID = 3
	BEGIN
		--Disable auto master PT
		SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
		FROM CustMaster WITH (NOLOCK)
		WHERE CustID = @MasterID

		DECLARE @MasterMaxPT TABLE (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, M1_Max TINYINT
			, M1_Min TINYINT
			)

		--Get Min/Max of presets
		INSERT INTO @MasterMaxPT
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.IsLive
			,
			--min(m3,l3,m4)
			CASE 
				WHEN masterpt.MasterPT < masterpt.MaxPT
					THEN CASE 
							WHEN masterpt.MasterPT < superpt.MasterPT
								THEN masterpt.MasterPT
							ELSE superpt.MasterPT
							END
				ELSE CASE 
						WHEN masterpt.MaxPT < superpt.MasterPT
							THEN masterpt.MaxPT
						ELSE superpt.MasterPT
						END
				END
			, masterpt.MinPT
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)
			ON pdt.SportType = masterpt.sporttype
				AND pdt.BetType = masterpt.bettype
				AND pdt.IsLive = masterpt.islive
				AND masterpt.custid = @MasterID
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
			ON pdt.SportType = superpt.sporttype
				AND pdt.BetType = superpt.bettype
				AND pdt.IsLive = superpt.islive
				AND superpt.custid = @SuperID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 1

		--Cusinfo
		SELECT c.username
			, c.username2
			, c.firstname
			, c.lastname
			, c.phone
			, c.mobilephone
			, c.email
			, c.fax
			, @DisableAutoMPT AS DisableAutoMPT
		FROM Customer c WITH (NOLOCK)
		WHERE c.custID = @CustID

		--PT SETTING
		SELECT mb.IsGroupedPT
			, mb.A1
			, mb.M1
			, agentpt.IsAutoMasterPT IM2
			, mb.IM1
			, mb.UM1
			, mpt.M1_Max - mb.A1 AS M1_Max
			, --min(m3,l3,m4)-a1
			CASE 
				WHEN mpt.M1_Min - mb.A1 < 0
					THEN 0
				ELSE mpt.M1_Min - mb.A1
				END AS M1_MIN
			,
			-- um1_min = [Max(0, N3-A1)
			CASE 
				WHEN mpt.M1_Min - mb.A1 < 0
					THEN 0
				ELSE mpt.M1_Min - mb.A1
				END AS UM1_MIN
			,
			--um1_max =  Min(M3, M4)
			ISNULL(mpt.M1_Max, 0) AS UM1_MAX
		FROM @MemberPT mb
		INNER JOIN @MasterMaxPT mpt
			ON mb.SportType = mpt.sporttype
				AND mb.BetType = mpt.bettype
				AND mb.IsLive = mpt.islive
		INNER JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)
			ON mb.SportType = agentpt.sporttype
				AND mb.BetType = agentpt.bettype
				AND mb.IsLive = agentpt.islive
				AND agentpt.custid = @AgentID

		--Bet Limit Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			ON pdt.SportType = bl.sporttype
				AND pdt.BetType = bl.bettype
				AND bl.custid = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 2

		--Discount Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, dc.PlayerDiscount
			, dc.AgentDiscount
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON pdt.SportType = dc.sporttype
				AND pdt.BetType = dc.bettype
				AND dc.custid = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 3

		--Product Status
		SELECT stt.SportType
			, stt.BetType
			, pdt.SettingType
			, pdt.IsLive
			, ISNULL(stt.IsHidden, 0) IsHidden
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON stt.SportType = pdt.SportType
				AND stt.BetType = pdt.BetType
				AND stt.CustID = @CustID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 4
	END
	ELSE IF @RoleID = 2
	BEGIN
		DECLARE @AgentMaxPT TABLE (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, A1_Max TINYINT
			, A1_Min TINYINT
			)
		DECLARE @AgentMaxPTWithAuto TABLE (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, A1_Max TINYINT
			)

		--Get Min/Max of presets
		INSERT INTO @AgentMaxPT
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.IsLive
			,
			--min(a2,l2,a4)
			CASE 
				WHEN agentpt.agentPT < agentpt.maxPT
					THEN CASE 
							WHEN agentpt.agentPT < superpt.agentPT
								THEN agentpt.agentPT
							ELSE superpt.agentPT
							END
				ELSE CASE 
						WHEN agentpt.maxPT < superpt.agentPT
							THEN agentpt.maxPT
						ELSE superpt.agentPT
						END
				END
			, agentpt.MinPT
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)
			ON pdt.SportType = agentpt.sporttype
				AND pdt.BetType = agentpt.bettype
				AND pdt.IsLive = agentpt.islive
				AND agentpt.custid = @AgentID
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
			ON pdt.SportType = superpt.sporttype
				AND pdt.BetType = superpt.bettype
				AND pdt.IsLive = superpt.islive
				AND superpt.custid = @SuperID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 1

		--Get Min/Max base on autoPT settings
		INSERT INTO @AgentMaxPTWithAuto
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.IsLive
			,
			--iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
			CASE 
				WHEN (
						agentPT.IsAutoMasterPT = 1
						OR IM1 = 1
						)
					THEN agentPT.agentPT
				ELSE CASE 
						WHEN NOT (
								IS1 = 0
								AND masterpt.IsAutoSuperPT = 0
								)
							THEN masterpt.masterPT - M1
						ELSE CASE 
								WHEN masterpt.masterPT - M1 <= superpt.superPT - S1 - M1
									THEN masterpt.masterPT - M1
								ELSE superpt.superPT - S1 - M1
								END
						END
				END
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)
			ON pdt.SportType = agentpt.sporttype
				AND pdt.BetType = agentpt.bettype
				AND pdt.IsLive = agentpt.islive
				AND agentpt.custid = @AgentID
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)
			ON pdt.SportType = masterpt.sporttype
				AND pdt.BetType = masterpt.bettype
				AND pdt.IsLive = masterpt.islive
				AND masterpt.custid = @MasterID
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
			ON pdt.SportType = superpt.sporttype
				AND pdt.BetType = superpt.bettype
				AND pdt.IsLive = superpt.islive
				AND superpt.custid = @SuperID
		INNER JOIN @MemberPT mb
			ON pdt.SportType = mb.sporttype
				AND pdt.BetType = mb.bettype
				AND pdt.IsLive = mb.islive
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 1

		--Cusinfo
		SELECT c.username
			, c.username2
			, c.firstname
			, c.lastname
			, c.phone
			, c.mobilephone
			, c.email
			, c.fax
		FROM Customer c WITH (NOLOCK)
		WHERE c.custID = @CustID

		--PT Setting
		SELECT mb.IsGroupedPT
			, mb.A1
			, apt.A1_Min
			, CASE 
				WHEN apt.A1_Max <= apt_auto.A1_Max
					THEN apt.A1_Max
				ELSE apt_auto.A1_Max
				END AS A1_Max
		FROM @MemberPT mb
		INNER JOIN @AgentMaxPT apt
			ON mb.SportType = apt.sporttype
				AND mb.BetType = apt.bettype
				AND mb.IsLive = apt.islive
		INNER JOIN @AgentMaxPTWithAuto apt_auto
			ON mb.SportType = apt_auto.sporttype
				AND mb.BetType = apt_auto.bettype
				AND mb.IsLive = apt_auto.islive

		--Bet Limit Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, CASE 
				WHEN sbl.minbet >= mbl.minbet
					AND sbl.minbet >= abl.minbet
					AND sbl.minbet >= pdt.Min_MinBet
					THEN sbl.minbet
				WHEN mbl.minbet >= sbl.minbet
					AND mbl.minbet >= abl.minbet
					AND mbl.minbet >= pdt.Min_MinBet
					THEN mbl.minbet
				WHEN abl.minbet >= sbl.minbet
					AND abl.minbet >= mbl.minbet
					AND abl.minbet >= pdt.Min_MinBet
					THEN abl.minbet
				WHEN pdt.Min_MinBet >= sbl.minbet
					AND pdt.Min_MinBet >= mbl.minbet
					AND pdt.Min_MinBet >= abl.minbet
					THEN pdt.Min_MinBet
				END AS MinBet_Min
			, CASE 
				WHEN sbl.maxbet <= mbl.maxbet
					AND sbl.maxbet <= abl.maxbet
					THEN sbl.maxbet
				WHEN mbl.maxbet <= sbl.maxbet
					AND mbl.maxbet <= abl.maxbet
					THEN mbl.maxbet
				WHEN abl.maxbet <= sbl.maxbet
					AND abl.maxbet <= mbl.maxbet
					THEN abl.maxbet
				END AS MaxBet_Max
			, CASE 
				WHEN sbl.maxpermatch <= mbl.maxpermatch
					AND sbl.maxpermatch <= abl.maxpermatch
					THEN sbl.maxpermatch
				WHEN mbl.maxpermatch <= sbl.maxpermatch
					AND mbl.maxpermatch <= abl.maxpermatch
					THEN mbl.maxpermatch
				WHEN abl.maxpermatch <= sbl.maxpermatch
					AND abl.maxpermatch <= mbl.maxpermatch
					THEN abl.maxpermatch
				END AS MaxPerMatch_Max
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
			ON pdt.SportType = bl.sporttype
				AND pdt.BetType = bl.bettype
				AND bl.custid = @CustID
		INNER JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK)
			ON pdt.SportType = abl.sporttype
				AND pdt.BetType = abl.bettype
				AND abl.custid = @AgentID
		INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK)
			ON pdt.SportType = mbl.sporttype
				AND pdt.BetType = mbl.bettype
				AND mbl.custid = @MasterID
		INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)
			ON pdt.SportType = sbl.sporttype
				AND pdt.BetType = sbl.bettype
				AND sbl.custid = @SuperID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 2

		--Discount Setting
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.SettingType
			, dc.PlayerDiscount
			, adc.Discount AS maxDiscount
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON pdt.SportType = dc.sporttype
				AND pdt.BetType = dc.bettype
				AND dc.custid = @CustID
		INNER JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK)
			ON pdt.SportType = adc.sporttype
				AND pdt.BetType = adc.bettype
				AND adc.custid = @AgentID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 3

		--Product Status
		SELECT stt.SportType
			, stt.BetType
			, pdt.SettingType
			, ISNULL(stt.IsDisabled, 0) IsDisabled
			, ISNULL(stt.IsHidden, 0) IsHidden
			, ISNULL(stt.IsSync, 0) IsSync
			, ISNULL(Agentstt.IsDisabled, 0) AS DisableUpline
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON stt.SportType = pdt.SportType
				AND stt.BetType = pdt.BetType
				AND stt.CustID = @CustID
		INNER JOIN dbo.CustProductStatus Agentstt WITH (NOLOCK)
			ON Agentstt.SportType = pdt.SportType
				AND Agentstt.BetType = pdt.BetType
				AND Agentstt.CustID = @AgentID
		WHERE pdt.ProductID = @ProductID
			AND pdt.SettingType = 4
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberSettingSelect] TO [bodbExtAccNet]