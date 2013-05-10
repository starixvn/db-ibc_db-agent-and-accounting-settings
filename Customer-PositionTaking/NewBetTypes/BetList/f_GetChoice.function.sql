ALTER FUNCTION [dbo].[f_GetChoice]
(
	@betteam varchar(50),
	@bettype int,
	@Language varchar(2) = 'E'
)
RETURNS nvarchar(20)
AS
BEGIN
	declare @returnVal nvarchar(20)
	
	if @Language = 'C' SELECT @Language = 'CS'
	if @bettype = 14--FGLG
	BEGIN
		declare 
			@HA varchar(1),
			@FGLG varchar(1)
		
		select @HA = left(@betteam, 1)
		select @FGLG = right(@betteam, 1)
		
		select @returnVal =
			case @HA 
				when '1' then 
					case @Language when 'CS' then N'主' when 'CT' then N'主' else 'Home' end 
				when '2' then 
					case @Language when 'CS' then N'客' when 'CT' then N'客' else 'Away' end 
				else 
					case @Language when 'CS' then  N'無' when 'CT' then  N'无' else 'No' end 
			end			
				+
			case @FGLG 
				when '1' then 
					case @Language when 'CS' then N'先' when 'CT' then N'先' else ' FG' end 
				when '2' then
					case @Language when 'CS' then N'後' when 'CT' then N'后' else ' LG' end				
				else case @Language when 'CS' then N'進球' when 'CT' then N'进球' else ' Goal' end 
			end		
	END
	else if @bettype = 16--HTFT
	BEGIN
		declare 
			@home varchar(1),
			@away varchar(1)
		
		select @home = left(@betteam, 1)
		select @away = right(@betteam, 1)
		
		select @returnVal = 
			case @home 
				when '1' then case @Language when 'CS' then N'主' when 'CT' then N'主' else 'H' end
				when '2' then case @Language when 'CS' then N'客' when 'CT' then N'客' else 'A' end
				else case @Language when 'CS' then N'和' when 'CT' then N'和' else 'D' end
			end 
			+ case @away 
				when '1' then case @Language when 'CS' then N'主' when 'CT' then N'主' else 'H' end
				when '2' then case @Language when 'CS' then N'客' when 'CT' then N'客' else 'A' end
				else case @Language when 'CS' then N'和' when 'CT' then N'和' else 'D' end
			end
	END
	else
		select @returnVal = @betteam
	
	return @returnVal
		
END