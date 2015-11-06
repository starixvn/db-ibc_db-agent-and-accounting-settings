USE CustDB
GO

ALTER PROCEDURE dbo.Acc_3rdProductSelSuperStatus @ProductID INT
	, @CustID INT
	, @SupperStatus BIT = 0 OUTPUT
	, @DownlineStatus BIT = 0 OUTPUT
AS
/*
	Created: 20150313@Winne
	Task: select 3rd product status of super ( 12 GoldDeluxe)
	DB: DBCUST/CustDB
	Original:
	Revisions:
		- 20150612@Winnie: Add Microgaming
		- 20151105@Patrick: Support RnG Game & rename field named DisableMicroGame to DisableMicroGameLC

	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	IF @ProductID IN (14,17) -- Microgaming
	BEGIN
		DECLARE @RoleId INT

		SELECT @SupperStatus = CASE WHEN @ProductID = 14 THEN ISNULL(~ DisableMicrogameLC, 0)
									WHEN @ProductID = 17 THEN ISNULL(~ DisableMicrogameRNG, 0)
									END
			, @RoleId = RoleId
		FROM CustInfo WITH (NOLOCK)
		WHERE CustID = @CustID

		CREATE TABLE #CustList14 (CustID INT)

		IF @RoleId = 4
		BEGIN
			INSERT INTO #CustList14 (CustID)
			SELECT rm.CustID
			FROM Customer rm WITH (NOLOCK)
				INNER JOIN Customer ag WITH (NOLOCK)
				ON rm.recommend = ag.Custid
			WHERE rm.srecommend = @CustID
				AND rm.custid <> @CustID
				AND ag.Username NOT LIKE '%' + ag.site + 'ACC%'
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #CustList14 (CustID)
			SELECT rm.CustID
			FROM Customer rm WITH (NOLOCK)
				INNER JOIN Customer ag WITH (NOLOCK)
				ON rm.recommend = ag.Custid
			WHERE rm.mrecommend = @CustID
				AND rm.custid <> @CustID
				AND ag.Username NOT LIKE '%' + ag.site + 'ACC%'
		END
		ELSE
		BEGIN
			INSERT INTO #CustList14 (CustID)
			SELECT rm.CustID
			FROM Customer rm WITH (NOLOCK)
				INNER JOIN Customer ag WITH (NOLOCK)
				ON rm.recommend = ag.Custid
			WHERE rm.recommend = @CustID
				AND rm.custid <> @CustID
				AND ag.Username NOT LIKE '%' + ag.site + 'ACC%'
		END
		--for Microgaming LC
		IF @ProductID = 14
		BEGIN
			IF EXISTS (SELECT TOP 1 1
					FROM CustInfo a WITH (NOLOCK)
						INNER JOIN #CustList14 b ON a.CustID = b.CustID
					WHERE ISNULL(a.DisableMicrogameLC, 1) = 1)
				AND EXISTS (SELECT TOP 1 1 FROM #CustList14 b)
			BEGIN
				SELECT @DownlineStatus = 0
			END
			ELSE
			BEGIN
				SELECT @DownlineStatus = 1
			END
		END
		ELSE IF @ProductID = 17--for Microgaming RNG
		BEGIN
			IF EXISTS (
					SELECT TOP 1 1
					FROM CustInfo a WITH (NOLOCK)
						INNER JOIN #CustList14 b ON a.CustID = b.CustID
					WHERE ISNULL(a.DisableMicrogameRNG, 1) = 1)
				AND EXISTS (SELECT TOP 1 1 FROM #CustList14 b)
			BEGIN
				SELECT @DownlineStatus = 0
			END
			ELSE
			BEGIN
				SELECT @DownlineStatus = 1
			END
		END

		RETURN
	END

	---
	SELECT @SupperStatus = IsEnabled
	FROM Dep_SupperProductSetting WITH (NOLOCK)
	WHERE CustID = @CustID
		AND ProductId = @ProductId

	CREATE TABLE #CustList (CustID INT)

	INSERT INTO #CustList (CustID)
	SELECT rm.CustID
	FROM Customer rm WITH (NOLOCK)
		INNER JOIN Customer ag WITH (NOLOCK)
		ON rm.recommend = ag.Custid
	WHERE rm.srecommend = @CustID
		AND rm.roleid = 1
		AND ag.Username NOT LIKE '%' + ag.site + 'ACC%'

	IF EXISTS (
			SELECT TOP 1 1
			FROM Dep_CustProductSetting a WITH (NOLOCK)
				INNER JOIN #CustList b
				ON a.CustID = b.CustID
			WHERE a.ProductId = @ProductId
				AND a.IsEnabled = 1
			)
		SELECT @DownlineStatus = 1
	ELSE
		SELECT @DownlineStatus = 0
END
GO

GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbadminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_3rdProductSelSuperStatus] TO [vnteam] AS [dbo]
