SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerSelEditSuperOnProduct]
	@CustID INT,
	@ProductID TINYINT
AS
	/*
	Created: 20141104@Dominic
	Task : Get all Super'setting values of a product
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Super's ID
	
	*/
BEGIN
	DECLARE @downlines BIT

	SELECT @downlines = CASE 
		WHEN EXISTS(
			SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE srecommend = @custid and roleid = 3) 
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
			pt.superPT AS S4,pt.masterPT AS M4,pt.agentPT AS A4,
			pt.minPT AS N4,pt.maxPT AS L4
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
	ON pdt.SportType=pt.sporttype AND pdt.BetType=pt.bettype AND pdt.IsLive=pt.islive AND pt.custid=@CustID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=1
	
	--Bet Limit Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			bl.minbet,bl.maxbet,bl.maxpermatch,bl.maxperBall
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
	ON pdt.SportType=bl.sporttype AND pdt.BetType=bl.bettype AND bl.custid=@CustID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=2
	
	--Discount Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			dc.discounta, 0.0025 AS maxDiscount
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
	ON pdt.SportType=dc.sporttype AND pdt.BetType=dc.bettype AND dc.custid=@CustID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=3
	
	--Product Status
	SELECT stt.SportType,stt.BetType,stt.IsDisabled,stt.IsHidden,stt.IsSync,
			CASE WHEN @downlines=0 THEN ISNULL(stt.IsDisabled,0) 
			ELSE	
				(SELECT TOP 1 ISNULL(sstt.IsDisabled,0) FROM dbo.custInfo ci WITH(NOLOCK)
				JOIN dbo.CustProductStatus sstt
				ON sstt.CustID=ci.custid
				AND sstt.SportType=stt.SportType
				AND sstt.BetType=stt.BetType AND ISNULL(sstt.IsDisabled,0) = 1
				WHERE srecommend=@CustID AND roleid=3)
			END as DisableDownlines
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustProductStatus stt WITH(NOLOCK)
		ON stt.SportType=pdt.SportType
		AND stt.BetType=pdt.BetType
		AND stt.CustID=@CustID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=4
END