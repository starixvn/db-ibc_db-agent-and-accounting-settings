ALTER PROCEDURE [dbo].[Acc_CustomerSelKenoStatus] 
	@custid INT
	, @roleid INT = NULL
	, @uplineId INT = NULL
AS
/*
	Created: Bobby
	Date: 2014-03-04
	DB: DB052.bodb02
	Task: get disable status of Keno
	
	Revisions:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @custRoleid INT
		,@srecommend INT
		,@mrecommend INT
		,@recommend INT;

	DECLARE @kenoGameType TABLE (
		gametypeid INT
		,isdisabled BIT DEFAULT 0
		)


	SELECT TOP (1) @custRoleid = roleid
		,@srecommend = srecommend
		,@mrecommend = mrecommend
		,@recommend = recommend
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @custid

	--check belong to
	IF((@roleid > 0 AND @roleid <> @custRoleid)
		OR (@uplineId > 0 AND @uplineId <> CASE @custRoleid
				WHEN 3 THEN @srecommend
				WHEN 2 THEN @srecommend
				WHEN 1 THEN @recommend END)
		OR (@custRoleid NOT IN (1,2,3,4))) RETURN;

	INSERT INTO @kenoGameType (gametypeid)
	SELECT gametypeid
	FROM dbo.GameType
	WHERE gametypeid <= 9
	ORDER BY gametypeid

	--downline
	SELECT *
	INTO #kenoDownlines
	FROM @kenoGameType

	IF (@custRoleid = 4)
	BEGIN
		IF (
				EXISTS (
					SELECT TOP 1 1
					FROM custInfo c WITH (NOLOCK)
					WHERE srecommend = @custid
						AND roleid = 3
						AND hidekeno = 1
					)
				)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT DISTINCT g.gametypeid
					,g.IsDisabled
				FROM dbo.CustGameType g WITH (NOLOCK)
					INNER JOIN custInfo c WITH (NOLOCK)
					ON g.CustID = c.custid
				WHERE c.srecommend = @custid
					AND c.roleid = 3
					AND g.IsDisabled = 1
				) t
				ON k.gametypeid = t.GameTypeID
		END
	END

	IF (@custRoleid = 3)
	BEGIN
		IF (
				EXISTS (
					SELECT TOP 1 1
					FROM custInfo c WITH (NOLOCK)
					WHERE mrecommend = @custid
						AND roleid = 2
						AND hidekeno = 1
					)
				)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT DISTINCT g.gametypeid
					,g.IsDisabled
				FROM dbo.CustGameType g WITH (NOLOCK)
					INNER JOIN custInfo c WITH (NOLOCK)
					ON g.CustID = c.custid
				WHERE c.mrecommend = @custid
					AND c.roleid = 2
					AND g.IsDisabled = 1
				) t
				ON k.gametypeid = t.GameTypeID
		END
	END

	IF (@custRoleid = 2)
	BEGIN
		IF (
				EXISTS (
					SELECT TOP 1 1
					FROM custInfo c WITH (NOLOCK)
					WHERE recommend = @custid
						AND roleid = 1
						AND hidekeno = 1
					)
				)
		BEGIN
			UPDATE #kenoDownlines
			SET isdisabled = 1
		END
		ELSE
		BEGIN
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT DISTINCT g.gametypeid
					,g.IsDisabled
				FROM dbo.CustGameType g WITH (NOLOCK)
					INNER JOIN custInfo c WITH (NOLOCK)
					ON g.CustID = c.custid
				WHERE c.recommend = @custid
					AND c.roleid = 1
					AND g.IsDisabled = 1
				) t
				ON k.gametypeid = t.GameTypeID
		END
	END;

	WITH kenoUpline
	AS (
		--upline
		SELECT g.GameTypeID
			,IsDisabled = CASE 
				WHEN c.HideKeno = 0
					AND g.IsDisabled = 0 THEN 0
				ELSE 1
				END
		FROM [dbo].[custInfo] c
			CROSS APPLY (
			SELECT t.GameTypeID
				,isnull(g1.isdisabled, 1) isdisabled
			FROM @kenoGameType t
				LEFT JOIN (
				SELECT GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE custid = c.custid
				) g1
				ON t.gametypeid = g1.GameTypeID
			) g
		WHERE c.custid = CASE @custRoleid
				WHEN 3 THEN @srecommend
				WHEN 2 THEN @srecommend
				WHEN 1 THEN @recommend
				ELSE 0
				END
		)
		-- customer
		,kenoCustomer
	AS (
		SELECT UserName
			,202 AS SportType
			,g.GameTypeID
			,gt.IBCBetTypeID
			,IsDisabled = CASE 
				WHEN c.HideKeno = 0
					AND g.IsDisabled = 0 THEN 0
				ELSE 1
				END
		FROM [dbo].[custInfo] c
			CROSS JOIN (
			SELECT t.GameTypeID
				,isnull(g1.isdisabled, 1) isdisabled
			FROM @kenoGameType t
				LEFT JOIN (
				SELECT GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE custid = @custid
				) g1
				ON t.gametypeid = g1.GameTypeID
			) g
			LEFT JOIN dbo.gametype gt
			ON g.GameTypeID = gt.GameTypeID
		WHERE c.custid = @custid
		)
	SELECT c.UserName
		,c.SportType
		,c.GameTypeID
		,c.IBCBetTypeID
		,c.IsDisabled
		,isnull(u.IsDisabled, 1) AS DisableUplines
		,isnull(d.IsDisabled, 1) AS DisableDownlines
	FROM kenoCustomer c
		LEFT JOIN kenoUpline u
		ON c.GameTypeID = u.GameTypeID
		LEFT JOIN #kenoDownlines d
		ON c.GameTypeID = d.GameTypeID;

	DROP TABLE #kenoDownlines
END
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelKenoStatus] TO [bodbadminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelKenoStatus] TO [bodbDownlineNet] AS [dbo]
