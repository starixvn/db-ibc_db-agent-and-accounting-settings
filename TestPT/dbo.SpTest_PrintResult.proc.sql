ALTER PROCEDURE [dbo].[SpTest_PrintResult]
	@roleid tinyint,
	
	@s4 smallmoney = 0,
	@m4 smallmoney = 0,
	@a4 smallmoney = 0,
	@n4 smallmoney = 0,	
	@l4 smallmoney = 0,	
	@s3 smallmoney = 0,
	@m3 smallmoney = 0,
	@u3 smallmoney = 0,
	@i3 bit = 0,
	@n3 smallmoney = 0,
	@l3 smallmoney = 0,
	@m2 smallmoney = 0,
	@a2 smallmoney = 0,
	@u2 smallmoney = 0,
	@i2 bit = 0,
	@n2 smallmoney = 0,
	@l2 smallmoney = 0,
	@s1 smallmoney = 0,
	@m1 smallmoney = 0,
	@a1 smallmoney = 0,
	@u1 smallmoney = 0,
	@i1 bit
AS
declare @strPrint1 varchar(100)
declare @strPrint2 varchar(100)
declare @strPrint3 varchar(100)
declare @strPrint4 varchar(100)
declare @strBlank char(10)
declare @strLine varchar(100)
set @strBlank = ' | '
set @strLine = ' -----------------------------------------------------------------------'

PRINT @strLine
if @roleid <=4
BEGIN
	set @strPrint4 =' | s4:' + cast(isnull(@s4, 0) as char(4)) +
					' | m4:' + cast(isnull(@m4, 0) as char(4)) +  			
					' | a4:' + cast(isnull(@a4, 0) as char(4)) +
					@strBlank + @strBlank +			
					' | n4:' + cast(isnull(@n4, 0) as char(4)) +  			
					' | l4:' + cast(isnull(@l4, 0) as char(4))
	PRINT @strPrint4 + @strBlank
	PRINT @strLine
END

if @roleid <=3
BEGIN
	set @strPrint3 =' | s3:' + cast(isnull(@s3, 0) as char(4)) +			
					' | m3:' + cast(isnull(@m3, 0) as char(4)) + 
					@strBlank +  			
					' | u3:' + cast(isnull(@u3, 0) as char(4)) + 
					' | i3:' + cast(isnull(@i3, 0) as char(4)) +  			
					' | n3:' + cast(isnull(@n3, 0) as char(4)) +
					' | l3:' + cast(isnull(@l3, 0) as char(4))
	PRINT @strPrint3 + @strBlank
	PRINT @strLine
	
END					
if @roleid <=2
BEGIN
	set @strPrint2 =@strBlank + 
					' | m2:' + cast(isnull(@m2, 0) as char(4)) +  			
					' | a2:' + cast(isnull(@a2, 0) as char(4)) + 
					' | u2:' + cast(isnull(@u2, 0) as char(4)) + 
					' | i2:' + cast(isnull(@i2, 0) as char(4)) +  						
					' | n2:' + cast(isnull(@n2, 0) as char(4)) +
					' | l2:' + cast(isnull(@l2, 0) as char(4))
	PRINT @strPrint2 + @strBlank 
	PRINT @strLine
END
if @roleid <=1
BEGIN
	set @strPrint1 =' | s1:' + cast(isnull(@s1, 0) as char(4)) +			
					' | m1:' + cast(isnull(@m1, 0) as char(4)) +  
					' | a1:' + cast(isnull(@a1, 0) as char(4)) +  			
					' | u1:' + cast(isnull(@u1, 0) as char(4)) + 
					' | i1:' + cast(isnull(@i1, 0) as char(4))
	PRINT @strPrint1 + @strBlank + @strBlank + @strBlank
	PRINT @strLine
END					
PRINT ''
