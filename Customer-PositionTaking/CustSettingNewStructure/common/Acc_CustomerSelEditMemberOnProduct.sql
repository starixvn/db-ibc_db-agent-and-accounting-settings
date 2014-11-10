SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerSelEditMemberOnProduct]
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@ProductID TINYINT
AS
	/*
	Created: 20141104@Dominic
	Task : Get all Member'setting values of a product
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Member's ID
	
	*/
BEGIN
	DECLARE @downlines BIT
	SELECT @downlines = CASE 
		WHEN EXISTS(
			SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE recommend = @custid and roleid = 1) 
		THEN 1 ELSE 0 END
	
	--Cusinfo
	SELECT	c.username, 
			c.username2, 
			c.firstname,
			c.lastname,
			c.phone,
			c.mobilephone,
			c.email,
			c.fax
	FROM	Customer c WITH (NOLOCK)			
	WHERE	c.custID = @CustID 
	
	--PT Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			pt.agentPT AS A1,
			CASE WHEN agentpt.agentPT<agentpt.maxPT 
				THEN CASE WHEN agentpt.agentPT<superpt.agentPT
					THEN agentpt.agentPT
					ELSE superpt.agentPT 
				END
			ELSE CASE WHEN agentpt.maxPT < superpt.agentPT
					THEN agentpt.maxPT
					ELSE superpt.agentPT 
				END
			END AS A2,
			CASE 
			WHEN (
					agentPT.isautoMPT = 1
					OR pt.isautoMPT = 1
					)
				THEN agentPT.agentPT
			ELSE CASE 
					WHEN NOT (
							pt.isautoSPT = 0
							AND masterpt.isautoSPT = 0
							)
						THEN masterpt.masterPT - pt.masterPT
					ELSE CASE 
							WHEN masterpt.masterPT - pt.masterPT <= superpt.superPT - pt.superPT - pt.masterPT
								THEN masterpt.masterPT - pt.masterPT
							ELSE superpt.superPT - pt.superPT - pt.masterPT
							END
					END
			END AS A1,
			agentpt.minPT AS A1_Min,
			CASE WHEN A2 <= A1 THEN A2 ELSE A1 END AS A1_Max
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
	ON pdt.SportType=pt.sporttype AND pdt.BetType=pt.bettype AND pdt.IsLive=pt.islive AND pt.custid=@CustID
	JOIN dbo.CustPTSetting3rd_Agent agentpt WITH (NOLOCK)
	ON pdt.SportType=agentpt.sporttype AND pdt.BetType=agentpt.bettype AND pdt.IsLive=agentpt.islive AND agentpt.custid=@AgentID
	JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)
	ON pdt.SportType=masterpt.sporttype AND pdt.BetType=masterpt.bettype AND pdt.IsLive=masterpt.islive AND masterpt.custid=@MasterID
	JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
	ON pdt.SportType=superpt.sporttype AND pdt.BetType=superpt.bettype AND pdt.IsLive=superpt.islive AND superpt.custid=@SuperID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=1
	
	--Bet Limit Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			bl.minbet,bl.maxbet,bl.maxpermatch,bl.maxperBall,
			CASE 
				WHEN sbl.minbet >= mbl.minbet AND sbl.minbet >= abl.minbet THEN sbl.minbet 
				WHEN mbl.minbet >= sbl.minbet AND mbl.minbet >= abl.minbet THEN mbl.minbet
				WHEN abl.minbet >= sbl.minbet AND abl.minbet >= mbl.minbet THEN abl.minbet END,
			CASE 
				WHEN sbl.maxbet <= mbl.maxbet AND sbl.maxbet <= abl.maxbet THEN sbl.maxbet 
				WHEN mbl.maxbet <= sbl.maxbet AND mbl.maxbet <= abl.maxbet THEN mbl.maxbet
				WHEN abl.maxbet <= sbl.maxbet AND abl.maxbet <= mbl.maxbet THEN abl.maxbet END,
			CASE 
				WHEN sbl.maxpermatch <= mbl.maxpermatch AND sbl.maxpermatch <= abl.maxpermatch THEN sbl.maxpermatch 
				WHEN mbl.maxpermatch <= sbl.maxpermatch AND mbl.maxpermatch <= abl.maxpermatch THEN mbl.maxpermatch
				WHEN abl.maxpermatch <= sbl.maxpermatch AND abl.maxpermatch <= mbl.maxpermatch THEN abl.maxpermatch END,
			CASE 
				WHEN sbl.maxperBall <= mbl.maxperBall AND sbl.maxperBall <= abl.maxperBall THEN sbl.maxperBall 
				WHEN mbl.maxperBall <= sbl.maxperBall AND mbl.maxperBall <= abl.maxperBall THEN mbl.maxperBall
				WHEN abl.maxperBall <= sbl.maxperBall AND abl.maxperBall <= mbl.maxperBall THEN abl.maxperBall END
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
	ON pdt.SportType=bl.sporttype AND pdt.BetType=bl.bettype AND bl.custid=@CustID
	JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK)
	ON pdt.SportType=abl.sporttype AND pdt.BetType=abl.bettype AND abl.custid=@AgentID
	JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK)
	ON pdt.SportType=mbl.sporttype AND pdt.BetType=mbl.bettype AND mbl.custid=@MasterID
	JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)
	ON pdt.SportType=sbl.sporttype AND pdt.BetType=sbl.bettype AND sbl.custid=@SuperID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=2
	
	--Discount Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			dc.discounta, mdc.discounta AS maxDiscount
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
	ON pdt.SportType=dc.sporttype AND pdt.BetType=dc.bettype AND dc.custid=@CustID
	JOIN dbo.CustDiscount3rd_Agent adc WITH (NOLOCK)
	ON pdt.SportType=adc.sporttype AND pdt.BetType=adc.bettype AND adc.custid=@AgentID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=3
	
	--Product Status
	SELECT stt.SportType,stt.BetType,stt.IsDisabled,stt.IsHidden,stt.IsSync,
			ISNULL(Agentstt.IsDisabled,0)  AS DisableUpline
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustProductStatus stt WITH(NOLOCK)
		ON stt.SportType=pdt.SportType
		AND stt.BetType=pdt.BetType
		AND stt.CustID=@CustID
	JOIN dbo.CustProductStatus Agentstt WITH(NOLOCK)
		ON Masterstt.SportType=pdt.SportType
		AND Masterstt.BetType=pdt.BetType
		AND Masterstt.CustID=@AgentID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=4
END