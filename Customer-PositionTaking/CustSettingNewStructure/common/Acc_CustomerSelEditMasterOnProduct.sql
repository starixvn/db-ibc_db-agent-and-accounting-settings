SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerSelEditMasterOnProduct]
	@CustID INT,
	@SuperID INT,
	@ProductID TINYINT
AS
	/*
	Created: 20141104@Dominic
	Task : Get all Master'setting values of a product
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Master's ID
	
	*/
BEGIN
	DECLARE @downlines BIT
	SELECT @downlines = CASE 
		WHEN EXISTS(
			SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE mrecommend = @custid and roleid = 2) 
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
			pt.superPT as S3,pt.masterPT AS M3,
			pt.IsAutoSPT AS IS3,pt.AutoSPT AS US3,pt.minPT AS N3,
			superpt.SuperPT AS S4,superpt.MasterPT AS M4,superpt.MinPT AS N4
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
	ON pdt.SportType=pt.sporttype AND pdt.BetType=pt.bettype AND pdt.IsLive=pt.islive AND pt.custid=@CustID
	JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)
	ON pdt.SportType=superpt.sporttype AND pdt.BetType=superpt.bettype AND pdt.IsLive=superpt.islive AND superpt.custid=@SuperID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=1
	
	--Bet Limit Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			bl.minbet,bl.maxbet,bl.maxpermatch,bl.maxperBall,
			sbl.minbet AS MinBet_Min,
			sbl.maxbet AS MaxBet_Max,
			sbl.maxpermatch AS MaxPerMatch_Max,
			sbl.maxperball AS MaxPerBall_Max
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
	ON pdt.SportType=bl.sporttype AND pdt.BetType=bl.bettype AND bl.custid=@CustID
	JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)
	ON pdt.SportType=sbl.sporttype AND pdt.BetType=sbl.bettype AND sbl.custid=@SuperID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=2
	
	--Discount Setting
	SELECT pdt.SportType,pdt.BetType,pdt.SettingType,pdt.IsLive,
			dc.discounta, sdc.discounta AS maxDiscount
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
	ON pdt.SportType=dc.sporttype AND pdt.BetType=dc.bettype AND dc.custid=@CustID
	JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK)
	ON pdt.SportType=sdc.sporttype AND pdt.BetType=sdc.bettype AND sdc.custid=@SuperID
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
				WHERE mrecommend=@CustID AND roleid=2)
			END AS DisableDownlines,
			ISNULL(Superstt.IsDisabled,0)  AS DisableUpline,
			ISNULL(cm.DisableAutoMPT,0) AS DisableAutoMPT
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	JOIN dbo.CustProductStatus stt WITH(NOLOCK)
		ON stt.SportType=pdt.SportType
		AND stt.BetType=pdt.BetType
		AND stt.CustID=@CustID
	JOIN dbo.CustProductStatus Superstt WITH(NOLOCK)
		ON Superstt.SportType=pdt.SportType
		AND Superstt.BetType=pdt.BetType
		AND Superstt.CustID=@SuperID
	JOIN dbo.CustMaster cm WITH(NOLOCK)
		ON cm.CustID=@CustID
	WHERE pdt.ProductID=@ProductID AND pdt.SettingType=4
END