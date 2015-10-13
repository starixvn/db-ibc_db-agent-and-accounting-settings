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
 DECLARE @col_val tinyint = POWER(2, (@bitmapOrder-1)%8)  
  
 DECLARE @sub_bitmap binary(1) = substring(@bitmap, @byte_pos, 1)  
 DECLARE @oldStatusValue tinyint = CASE @sub_bitmap & @col_val WHEN 0 THEN 0 ELSE 1 END  
  
 IF @oldStatusValue = @newStatusValue RETURN @bitmap  
  
 SET @sub_bitmap += @col_val *(@newStatusValue-@oldStatusValue)  
  
 RETURN CONVERT(binary(32), STUFF(@bitmap, @byte_pos, 1, @sub_bitmap))  
END