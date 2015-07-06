ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_10] 
	@Custid			INT = 0
	,@RoleID		TINYINT = 0
	,@Action		VARCHAR(30) = ''
	,@DisableKeno	BIT = 0
	,@GameTypeID	INT = 0
	,@BetSettings	VARCHAR(MAX) = ''
AS
/*
	Created: Bobby
	Date: 2014-03-18
	Task: Apply execrep update keno setting - disable
	DB: DBCUST/custDB
	Original versions:	[Acc_ExecRep_Cust_04]
				
	Revision:
		- 20140228@Bobby: Update Keno status [Redmine:#12474]
		- 20150427@Johnson: update bet settings for Gold Deluxe 
	     - 20150610@Daniel: 
	      + Improve medthod check table existing in subscribers	
	      + Separate custDB to new server DBCUST  
		
	Parameter's Explanation:
		+ 'DisableKeno' : Disable Keno gaming
		+ 'GameTypeID' : Keno game ID
		+ @BetSettings = '<ROOT>
							<Row ID="12984" Stake="1,2,3" />
							<Row ID="12956" Stake="1,2" />
							<Row ID="12476" Stake="1,3" />
						 </ROOT>	
						'
		
*/
BEGIN
	SET NOCOUNT ON
	
	if dbo.f_CheckRepTable('custgametype') = 0
<<<<<<< HEAD
	   	RETURN              
    	
=======
	   	RETURN                  	

>>>>>>> 8ae9143d127b5c21ad393dfff253b58c1bf4f493
	IF @Action = 'UpdKeno-Disable'
	BEGIN
		IF (@RoleID = 4)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.SRecommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END

		IF (@RoleID = 3)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.MRecommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END

		IF (@RoleID = 2)
		BEGIN
			UPDATE g
			SET IsDisabled = @DisableKeno
			FROM dbo.CustGameType g WITH (ROWLOCK, UPDLOCK)
				INNER JOIN dbo.CustInfo c WITH (NOLOCK)
				ON g.custid = c.custid
			WHERE c.CustID <> @CustID
				AND c.Recommend = @CustID
				AND g.GameTypeID = @GameTypeID
		END
	END
	IF @Action = 'GoldDeluxe'
	BEGIN
		CREATE TABLE #StakeLevel (custid INT, StakeLevelList VARCHAR(300))
		DECLARE @DocHandler INT
		
		-- For read xml					
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @BetSettings
		
		INSERT INTO #StakeLevel(
						CustID,
						StakeLevelList
					)
			SELECT
				Data.ID,
				Data.Stake			
			FROM OPENXML (@DocHandler, '/ROOT/Row',1) 
			WITH (
				ID			INT,
				Stake		VARCHAR(200)	
			) AS Data

		EXEC sp_xml_removedocument @DocHandler
		-- end read xml
		
		UPDATE cg
		SET cg.StakeLevelList = t.StakeLevelList
		FROM CustGameType cg WITH(UPDLOCK,ROWLOCK)
			INNER JOIN #StakeLevel t ON cg.CustID = t.custid
		WHERE cg.GameTypeID = @GameTypeID
		
		DROP TABLE #StakeLevel		
	END
END
GO


GRANT EXECUTE ON [dbo].[Acc_Custsetting3rd_10] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Custsetting3rd_10] TO [vnteam] AS [dbo]
