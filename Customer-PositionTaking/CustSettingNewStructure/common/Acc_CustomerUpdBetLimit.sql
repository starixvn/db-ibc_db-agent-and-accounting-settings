SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdBetLimit]
	@CustID INT,
	@RoleID INT,
	@BetLimit_XML VARCHAR(MAX)
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
	DECLARE @startRun datetime, 
			@endRun datetime, 
			@duration int
			
	set @startRun = getdate()

	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML
	
	SELECT *
	INTO #newBetLimitTbl
	FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
	WITH(SportType smallint, BetType smallint, MinBet MONEY, MaxBet MONEY,MaxPerMatch MONEY)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF @RoleID<>1
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
	ELSE IF @RoleID=1
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
	
	IF OBJECT_ID('tempdb..#newBetLimitTbl') IS NOT NULL
		DROP TABLE #newBetLimitTbl
END