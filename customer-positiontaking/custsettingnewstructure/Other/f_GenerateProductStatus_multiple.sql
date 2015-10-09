USE [CustDB]
GO
ALTER FUNCTION [dbo].[f_GenerateProductStatus_multiple] (@bitmap binary(32), @xmlStr varchar(max))
	RETURNS binary(32) AS
	/*
		Created: Viet @ 7.OCT.2015
		DB: DBCust.custDB

		Revision:				
		Param's Explanation:	
			@xmlStr: 
				+ FORMAT: <root><r b="" s="" /></root>
				+ r: row
				+ b: bitmapOrder
				+ s: statusValue
			
	*/
BEGIN
	DECLARE @xml XML = CONVERT(XML, @xmlStr)
	DECLARE @temp AS TABLE (bytepos tinyint, bm_colPos binary(1), bm_statusValue binary(1), rn tinyint)
		
	;WITH s AS (
		SELECT bitmapOrder = T.C.value('./@b', 'tinyint')
			,statusValue = T.C.value('./@s', 'bit')
		FROM @xml.nodes('/root/r') as [T](C) --T: table, C: column
	)
	INSERT INTO @temp(bytepos, bm_colPos, bm_statusValue, rn)
	SELECT 1+((bitmapOrder-1)/8) --bytepos		
		,SUM(POWER(2, 1+((bitmapOrder-1)%8)-1))
		,SUM(CASE statusValue WHEN 1 THEN POWER(2, 1+((bitmapOrder-1)%8)-1) ELSE 0 END)		
		,ROW_NUMBER() OVER (ORDER BY 1+((bitmapOrder-1)/8))
	FROM s
	GROUP BY 1+((bitmapOrder-1)/8)

	DECLARE @bytepos tinyint, @bm_colPos binary(1), @bm_statusValue binary(1), @sub_bitmap binary(1)

	DECLARE @current_rn tinyint = 0
	WHILE (1 = 1)
	BEGIN
		SET @current_rn += 1
		
		SELECT @bytepos = bytepos, @bm_colPos = bm_colPos, @bm_statusValue = bm_statusValue
		FROM @temp
		WHERE rn = @current_rn
		IF @@ROWCOUNT = 0 BREAK
		
		SET @sub_bitmap = substring(@bitmap, @bytePos, 1)
		
		;WITH s AS (
			SELECT c1 = CASE @sub_bitmap & 1 WHEN 1 THEN 1 ELSE 0 END
				,c2 = CASE @sub_bitmap & 2 WHEN 2 THEN 2 ELSE 0 END
				,c3 = CASE @sub_bitmap & 4 WHEN 4 THEN 4 ELSE 0 END
				,c4 = CASE @sub_bitmap & 8 WHEN 8 THEN 8 ELSE 0 END
				,c5 = CASE @sub_bitmap & 16 WHEN 16 THEN 16 ELSE 0 END
				,c6 = CASE @sub_bitmap & 32 WHEN 32 THEN 32 ELSE 0 END
				,c7 = CASE @sub_bitmap & 64 WHEN 64 THEN 64 ELSE 0 END
				,c8 = CASE @sub_bitmap & 128 WHEN 128 THEN 128 ELSE 0 END
				,n1 = CASE @bm_statusValue & 1 WHEN 1 THEN 1 ELSE 0 END
				,n2 = CASE @bm_statusValue & 2 WHEN 2 THEN 2 ELSE 0 END
				,n3 = CASE @bm_statusValue & 4 WHEN 4 THEN 4 ELSE 0 END
				,n4 = CASE @bm_statusValue & 8 WHEN 8 THEN 8 ELSE 0 END
				,n5 = CASE @bm_statusValue & 16 WHEN 16 THEN 16 ELSE 0 END
				,n6 = CASE @bm_statusValue & 32 WHEN 32 THEN 32 ELSE 0 END
				,n7 = CASE @bm_statusValue & 64 WHEN 64 THEN 64 ELSE 0 END
				,n8 = CASE @bm_statusValue & 128 WHEN 128 THEN 128 ELSE 0 END
		)				
		SELECT @sub_bitmap = @sub_bitmap
			+ CASE @bm_colPos & 1 WHEN 1 THEN 1 ELSE 0 END * CASE WHEN c1 = n1 THEN 0 WHEN c1 > n1 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 2 WHEN 2 THEN 2 ELSE 0 END * CASE WHEN c2 = n2 THEN 0 WHEN c2 > n2 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 4 WHEN 4 THEN 4 ELSE 0 END * CASE WHEN c3 = n3 THEN 0 WHEN c3 > n3 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 8 WHEN 8 THEN 8 ELSE 0 END * CASE WHEN c4 = n4 THEN 0 WHEN c4 > n4 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 16 WHEN 16 THEN 16 ELSE 0 END * CASE WHEN c5 = n5 THEN 0 WHEN c5 > n5 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 32 WHEN 32 THEN 32 ELSE 0 END * CASE WHEN c6 = n6 THEN 0 WHEN c6 > n6 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 64 WHEN 64 THEN 64 ELSE 0 END * CASE WHEN c7 = n7 THEN 0 WHEN c7 > n7 THEN -1 ELSE 1 END
			+ CASE @bm_colPos & 128 WHEN 128 THEN 128 ELSE 0 END * CASE WHEN c8 = n8 THEN 0 WHEN c8 > n8 THEN -1 ELSE 1 END
		FROM s	
				
		SET @bitmap = CONVERT(binary(32), STUFF(CONVERT(varchar(MAX), @bitmap, 2), (@bytePos*2)-1, 2, CONVERT(varchar(MAX), @sub_bitmap, 2)), 2)		
	END	
	RETURN @bitmap
END

GO

