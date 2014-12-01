SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_BetLimitUpd]
	@CustID INT,
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@BetLimit_XML VARCHAR(MAX),

	@Language varchar(2) = 'E',
	@ErrCode  VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg     NVARCHAR(4000) = '' OUTPUT
AS
	/*
	Created: 20141111@Dominic
	Task : Update Customer's Bet Limits
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @BetLimit_XML:
		<ROOT>
				<BetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
						MaxPerMatch="1000000"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON
	
	SELECT @ErrCode='',@ErrMsg=''

	IF @BetLimit_XML IS NULL OR @BetLimit_XML= '' RETURN
	
	--Parse XML	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML

	SELECT *
	INTO #newBetLimitTbl
	FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
	WITH(SportType smallint, BetType smallint, MinBet MONEY, MaxBet MONEY,MaxPerMatch MONEY)	
	
	EXEC sp_xml_removedocument @iDoc
	
	EXEC [dbo].[Acc_CustSetting_BetLimitCheck]
									@CustID = @CustID,
									@RoleID = @RoleID,
									@AgentID = @AgentID,
									@MasterID = @MasterID,
									@SuperID = @SuperID,
									@BetLimit_XML = @BetLimit_XML,
									@Language = @Language,
									@ErrCode  = @ErrCode OUT,
									@ErrMsg   = @ErrMsg OUT

	IF @ErrCode <> '' RETURN
	
	IF @RoleID=1
	BEGIN
		UPDATE main
		SET
			main.minbet = tmp.MinBet,
			main.maxbet = tmp.MaxBet,
			main.maxpermatch = tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Member main
		JOIN #newBetLimitTbl tmp
		ON tmp.SportType=main.sporttype
		AND tmp.BetType=main.bettype
		WHERE main.custid=@CustID
	END
	ELSE IF @RoleID IN (2,3,4)
	BEGIN
		UPDATE main
		SET
			main.minbet = tmp.MinBet,
			main.maxbet = tmp.MaxBet,
			main.maxpermatch = tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Agent main
		JOIN #newBetLimitTbl tmp
		ON tmp.SportType=main.sporttype
		AND tmp.BetType=main.bettype
		WHERE main.custid=@CustID
	END

END