SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerInsDefaultProductStatus]
	@RoleID INT,
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT
AS
	/*
	Created: 20141104@Dominic
	Task : Insert default product status for customer
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @RoleID: Created level
	• @CustID: Created customer ID
	
	*/
BEGIN
	IF @RoleID = 4
	BEGIN
		INSERT INTO dbo.CustProductStatus
		(CustID,SportType,BetType,IsDisabled,IsHidden,IsSync)
		SELECT @CustID,SportType,BetType,IsDisabled,IsHidden,IsSync
		FROM dbo.ProductSettingDetail
		WHERE SettingType = 4
	END
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO dbo.CustProductStatus
		(CustID,SportType,BetType,IsDisabled,IsHidden,IsSync)
		SELECT @CustID,SportType,BetType,IsDisabled,IsHidden,IsSync
		FROM dbo.CustProductStatus
		WHERE CustID=@SuperID
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO dbo.CustProductStatus
		(CustID,SportType,BetType,IsDisabled,IsHidden,IsSync)
		SELECT @CustID,SportType,BetType,IsDisabled,IsHidden,IsSync
		FROM dbo.CustProductStatus
		WHERE CustID=@MasterID
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO dbo.CustProductStatus
		(CustID,SportType,BetType,IsDisabled,IsHidden,IsSync)
		SELECT @CustID,SportType,BetType,IsDisabled,IsHidden,IsSync
		FROM dbo.CustProductStatus
		WHERE CustID=@AgentID
	END
END