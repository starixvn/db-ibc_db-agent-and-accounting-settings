USE [bodb02]
GO
/****** Object:  UserDefinedFunction [dbo].[f_Decimal_Binary]    Script Date: 11/06/2007 15:51:54 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER FUNCTION [dbo].[f_Decimal_Binary] (@DecValue tinyint)  
RETURNS varchar(8) AS  
BEGIN 

	DECLARE @Result varchar(8), @BitSize tinyint	
	
	SELECT @Result = '', @BitSize = 8

	IF @DecValue = NULL RETURN NULL

	WHILE(@BitSize > 0)
	BEGIN
		SET @Result = @Result + Cast((@DecValue % 2) AS varchar(1))
		SET @DecValue = @DecValue / 2
		SET @BitSize = @BitSize - 1
	END

	RETURN reverse(@Result)
END





