CREATE FUNCTION [dbo].[f_GetProductStatus] (@bitmap binary(32), @bitmapOrder tinyint)    
 RETURNS BIT AS    
 /*  
  Created: Viet @ 7.OCT.2015  
  DB: DBCust.custDB  
  
  Revision:      
  Param's Explanation:   
 */  
BEGIN     
	RETURN CASE substring(@bitmap, 1+((@bitmapOrder-1)/8), 1) & POWER(2, (@bitmapOrder-1)%8) WHEN 0 THEN 0 ELSE 1 END    
END  