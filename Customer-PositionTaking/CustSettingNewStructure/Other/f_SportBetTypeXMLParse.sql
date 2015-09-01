ALTER FUNCTION f_SportBetTypeXMLParse(@SportBetTypeXML	NVARCHAR(MAX), @Mode TINYINT) 
RETURNS @SportBetTypeTbl TABLE (SportType SMALLINT, Bettype SMALLINT, IsLive BIT)
BEGIN 
	DECLARE @XML XML =  @SportBetTypeXML
	
	IF @Mode = 1 -- XML has only 3 columns : SportType,BetType,IsLive
	BEGIN
		INSERT @SportBetTypeTbl
		SELECT r.value('./@SportType','SMALLINT')
				, r.value('./@BetType','SMALLINT')
				, r.value('./@IsLive','BIT')
		FROM @xml.nodes('//ROOT/PT') AS RECORDS(r)
	END
 
	RETURN
END