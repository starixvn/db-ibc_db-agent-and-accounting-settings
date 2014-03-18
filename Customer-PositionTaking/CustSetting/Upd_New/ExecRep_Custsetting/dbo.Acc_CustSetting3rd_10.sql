ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_10] 
	@Custid			INT
	,@RoleID		TINYINT
	,@Action		VARCHAR(30) = ''
	,@DisableKeno	BIT = 0
	,@GameTypeID	INT = 0
AS
/*
	Created: Bobby
	Date: 2014-03-18
	Task: Apply execrep update keno setting - disable
	DB: DBTXN/custDB
	Original versions:	[Acc_ExecRep_Cust_04]
				
	Revision:
		- 20140228@Bobby: Update Keno status [Redmine:#12474]

	Parameter's Explanation:
		+ 'DisableKeno' : Disable Keno gaming
		+ 'GameTypeID' : Keno game ID
*/
BEGIN
	SET NOCOUNT ON
	IF (
			NOT EXISTS (
				SELECT *
				FROM sys.objects
				WHERE NAME = 'custgametype'
					AND type = 'U'
				)
			) RETURN

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
END
GO


GRANT EXECUTE ON [dbo].[Acc_Custsetting3rd_10] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Custsetting3rd_10] TO [vnteam] AS [dbo]
