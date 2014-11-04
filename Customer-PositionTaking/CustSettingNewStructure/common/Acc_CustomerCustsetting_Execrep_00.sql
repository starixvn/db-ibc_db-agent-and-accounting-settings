SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerCustsetting_Execrep_00]
	@RoleID INT,
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT
AS
	/*
	Created: 20141104@Dominic
	Task : Insert default PT/BetLimiet/Discount for customer
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @RoleID: Created level
	• @CustID: Created customer ID
	*/
BEGIN
	--Insert default PT for customer
	IF @RoleID <> 1
	BEGIN
		INSERT INTO dbo.CustPTSetting3rd_Agent
		(custid,sporttype,bettype,islive,
			superPT,masterPT,agentPT,isautomPT,automPT,isautosPT,autosPT,minPT,maxPT)
		SELECT 
		@CustID,SportType,BetType,IsLive,
			0,0,0,0,0,0,0,0,MaxPT
		FROM dbo.ProductSettingDetail
		WHERE SettingType = 1
	END
	ELSE
	BEGIN
		INSERT INTO dbo.CustPTSetting3rd_Member
		(custid,sporttype,bettype,islive,
			superPT,masterPT,agentPT,isautomPT,automPT,isautosPT,autosPT)
		SELECT 
		@CustID,acs.SportType,acs.BetType,acs.IsLive,
			mcs.superPT,acs.masterPT,acs.agentPT,0,0,0,0
		FROM dbo.CustPTSetting3rd_Agent acs
		JOIN dbo.CustPTSetting3rd_Agent mcs 
					ON acs.sporttype = mcs.sporttype
					AND acs.bettype = mcs.bettype
					AND acs.islive = mcs.islive
					AND mcs.custid = @MasterID
		WHERE acs.custid=@AgentID
	END
	
	--Insert default Bet Limit for customer
	IF @RoleID=4
	BEGIN
		INSERT INTO dbo.CustBetSetting3rd_Agent
		(custid,sporttype,bettype,minbet,maxbet,maxpermatch,maxperBall)
		SELECT
		@CustID,SportType,BetType,0,0,0,0
		FROM dbo.ProductSettingDetail
		WHERE SettingType = 2
	END
	ELSE IF @RoleID=3
	BEGIN
		INSERT INTO dbo.CustBetSetting3rd_Agent
		(custid,sporttype,bettype,minbet,maxbet,maxpermatch)
		SELECT
		@CustID,SportType,BetType,minbet,maxbet,maxpermatch
		FROM dbo.CustBetSetting3rd_Agent
		WHERE custid=@SuperID
	END
	ELSE IF @RoleID=2
	BEGIN
		INSERT INTO dbo.CustBetSetting3rd_Agent
		(custid,sporttype,bettype,minbet,maxbet,maxpermatch)
		SELECT
		@CustID,scs.SportType,scs.BetType,
			CASE WHEN scs.minbet > mcs.minbet THEN scs.minbet ELSE mcs.minbet END,
			CASE WHEN scs.maxbet < mcs.maxbet THEN scs.maxbet ELSE mcs.maxbet END,
			CASE WHEN scs.maxpermatch < mcs.maxpermatch THEN scs.maxpermatch ELSE mcs.maxpermatch END
		FROM dbo.CustBetSetting3rd_Agent scs
		JOIN dbo.CustBetSetting3rd_Agent mcs
					ON scs.sporttype = mcs.sporttype
					AND scs.bettype = mcs.bettype
					AND mcs.custid = @MasterID
		WHERE scs.custid=@SuperID
	END
	ELSE IF @RoleID=1
	BEGIN
		INSERT INTO dbo.CustBetSetting3rd_Agent
		(custid,sporttype,bettype,minbet,maxbet,maxpermatch)
		SELECT
		@CustID,scs.SportType,scs.BetType,
			CASE 
				WHEN scs.minbet > mcs.minbet AND scs.minbet > acs.minbet THEN scs.minbet 
				WHEN mcs.minbet > scs.minbet AND mcs.minbet > acs.minbet THEN mcs.minbet
				WHEN acs.minbet > scs.minbet AND acs.minbet > mcs.minbet THEN acs.minbet END,
			CASE 
				WHEN scs.maxbet < mcs.maxbet AND scs.maxbet < acs.maxbet THEN scs.maxbet 
				WHEN mcs.maxbet < scs.maxbet AND mcs.maxbet < acs.maxbet THEN mcs.maxbet
				WHEN acs.maxbet < scs.maxbet AND acs.maxbet < mcs.maxbet THEN acs.maxbet END,
			CASE 
				WHEN scs.maxpermatch < mcs.maxpermatch AND scs.maxpermatch < acs.maxpermatch THEN scs.maxpermatch 
				WHEN mcs.maxpermatch < scs.maxpermatch AND mcs.maxpermatch < acs.maxpermatch THEN mcs.maxpermatch
				WHEN acs.maxpermatch < scs.maxpermatch AND acs.maxpermatch < mcs.maxpermatch THEN acs.maxpermatch END
		FROM dbo.CustBetSetting3rd_Agent scs
		JOIN dbo.CustBetSetting3rd_Agent mcs
					ON scs.sporttype = mcs.sporttype
					AND scs.bettype = mcs.bettype
					AND mcs.custid = @MasterID
		JOIN dbo.CustBetSetting3rd_Agent acs
					ON scs.sporttype = acs.sporttype
					AND scs.bettype = acs.bettype
					AND acs.custid = @AgentID
		WHERE scs.custid=@SuperID
	END
	
	--Insert default Discount for customer
	IF @RoleID<>1
	BEGIN
		INSERT INTO dbo.CustDiscount3rd_Agent
		(custid,sporttype,bettype,discounta)
		SELECT 
		@CustID,SportType,BetType,0
		FROM dbo.ProductSettingDetail
		WHERE SettingType = 3
	END
	ELSE
	IF @RoleID=1
	BEGIN
		INSERT INTO dbo.CustDiscount3rd_Member
		(custid,sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
		SELECT 
		@CustID,acs.SportType,acs.BetType,0,acs.discounta,mcs.discounta,scs.discounta
		FROM dbo.CustDiscount3rd_Agent acs
		JOIN dbo.CustDiscount3rd_Agent mcs 
					ON acs.sporttype = mcs.sporttype
					AND acs.bettype = mcs.bettype
					AND mcs.custid = @MasterID
		JOIN dbo.CustDiscount3rd_Agent scs 
					ON acs.sporttype = scs.sporttype
					AND acs.bettype = scs.bettype
					AND scs.custid = @SuperID
		WHERE acs.custid=@AgentID
	END
END