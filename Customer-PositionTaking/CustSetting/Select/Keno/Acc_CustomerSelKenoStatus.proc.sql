ALTER PROCEDURE [dbo].[Acc_CustomerSelKenoStatus] 
	@custid INT
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

	DECLARE @custid INT = 1
		,@roleid INT = 4
		,@srecommend INT
		,@mrecommend INT
		,@recommend INT;
	DECLARE @kenoGameType TABLE (
		gametypeid INT
		,isdisabled BIT DEFAULT 0
		)

	INSERT INTO @kenoGameType (gametypeid)
	SELECT gametypeid from dbo.GameType
	WHERE gametypeid <= 9
	ORDER BY gametypeid
	
	SELECT TOP(1) @roleid = roleid
		,@srecommend = srecommend
		,@mrecommend = mrecommend
		,@recommend = recommend
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @custid

	--downline
	SELECT *
	INTO #kenoDownlines
	FROM @kenoGameType

	IF @roleid = 4
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
			-- update GameTypeID=1
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 1
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=2
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 2
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=3
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 3
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=4
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 4
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=5
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 5
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=6
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 6
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=7
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 7
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=8
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 8
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=9
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 9
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE srecommend = @custid
							AND roleid = 3
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			UPDATE k
			SET isdisabled = 0
			FROM #kenoDownlines k
			WHERE gametypeid = 9
		END
	END

	IF @roleid = 3
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
			-- update GameTypeID=1
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 1
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=2
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 2
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=3
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 3
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=4
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 4
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=5
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 5
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=6
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 6
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=7
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 7
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=8
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 8
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=9
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 9
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE mrecommend = @custid
							AND roleid = 2
						)
				) t
				ON k.GameTypeID = t.GameTypeID
		END
	END

	IF @roleid = 2
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
			-- update GameTypeID=1
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 1
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=2
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 2
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=3
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 3
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=4
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 4
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=5
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 5
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=6
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 6
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=7
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 7
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=8
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 8
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID

			-- update GameTypeID=9
			UPDATE k
			SET isdisabled = ISNULL(t.isdisabled, 1)
			FROM #kenoDownlines k
				LEFT JOIN (
				SELECT TOP 1 GameTypeID
					,isdisabled
				FROM dbo.CustGameType
				WHERE gametypeid = 9
					AND isdisabled = 1
					AND custid = (
						SELECT custid
						FROM custInfo c WITH (NOLOCK)
						WHERE recommend = @custid
							AND roleid = 1
						)
				) t
				ON k.GameTypeID = t.GameTypeID
		END
	END;;;;

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
		WHERE c.custid = CASE @roleid
				WHEN 3 THEN @srecommend
				WHEN 2 THEN @srecommend
				WHEN 1 THEN @recommend
				ELSE 0
				END
		)
		-- customer
		,kenoCustomer
	AS (
		SELECT 202 AS SportType
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
	SELECT c.SportType
		,c.GameTypeID
		,c.IBCBetTypeID
		,c.IsDisabled
		,isnull(u.IsDisabled, 0) AS DisableUplines
		,isnull(d.IsDisabled, 0) AS DisableDownlines
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
