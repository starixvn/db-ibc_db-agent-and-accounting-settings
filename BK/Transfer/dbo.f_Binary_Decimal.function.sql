USE [bodb02]
GO
/****** Object:  UserDefinedFunction [dbo].[f_Binary_Decimal]    Script Date: 11/06/2007 15:48:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[f_Binary_Decimal] 
(
	@BinVal as varchar(8)
)
RETURNS tinyint
AS
BEGIN
	DECLARE @myOctet varchar(8),
	@i int,
	@power int,
	@result tinyint
	
	SET @myOctet = reverse(@BinVal)
	
	SET @power = len(@myOctet) - 1
	SET @i = @power + 1
	SET @result = 0
	WHILE @i >= 1
	BEGIN
		SET @result = @result + substring(@myOctet,@i,1) * Power(2,@power)
		SET @i = @i - 1
		SET @power = @power - 1
	END
	
	RETURN @result
END
