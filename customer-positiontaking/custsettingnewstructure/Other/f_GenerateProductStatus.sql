USE [CustDB]
GO
ALTER FUNCTION [dbo].[f_GenerateProductStatus] (@bitmap binary(32), @bitmapOrder tinyint, @newStatusValue bit)
	RETURNS binary(32) AS
	/*
		Created: Viet @ 7.OCT.2015
		DB: DBCust.custDB

		Revision:				
		Param's Explanation:	
	*/
BEGIN
	DECLARE @byte_pos tinyint = 1+((@bitmapOrder-1)/8)
	DECLARE @col_pos tinyint = 1+((@bitmapOrder-1)%8) 

	DECLARE @sub_bitmap binary(1) = substring(@bitmap, @byte_pos, 1)
	DECLARE @oldStatusValue bit = CASE @sub_bitmap & POWER(2, @col_pos-1) WHEN POWER(2, @col_pos-1) THEN 1 ELSE 0 END

	IF @oldStatusValue = @newStatusValue RETURN @bitmap

	SET @sub_bitmap += POWER(2, @col_pos-1) * CASE WHEN @oldStatusValue>@newStatusValue THEN -1 ELSE 1 END

	RETURN CONVERT(binary(32), STUFF(CONVERT(varchar(MAX), @bitmap, 2), (@byte_pos*2)-1, 2, CONVERT(varchar(MAX), @sub_bitmap, 2)), 2)	
END

GO
