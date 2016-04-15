ALTER FUNCTION	dbo.f_CustSetting_ProductStatusSel (
					@bitmap			BINARY(32)
				,	@bitmapOrder	TINYINT
				)  
RETURNS TABLE
AS
/*
	Created:	20160415@Billy
	Database:	DBCUST/CustDB
	
	Revision:
	Param's Explanation:
*/
RETURN
	SELECT	CAST	(	CASE SUBSTRING(@bitmap, 1 + ((@bitmapOrder - 1) / 8), 1) & POWER(2, (@bitmapOrder - 1) % 8)
							WHEN 0 THEN 0 
							ELSE 1 
						END AS BIT
					) value