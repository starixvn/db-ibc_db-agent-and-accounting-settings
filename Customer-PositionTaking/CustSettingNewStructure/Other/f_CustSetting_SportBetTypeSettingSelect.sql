ALTER FUNCTION f_CustSetting_SportBetTypeSettingSelect(@ProductID TINYINT, @SettingType SMALLINT) 
RETURNS @SportBetTypeSetting TABLE (SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT)
BEGIN 
	DECLARE @isTest BIT,@SQL NVARCHAR(100) = OBJECT_NAME(@@PROCID)

	IF  (@SQL like '%_xtest%' OR  @SQL like '%_xpre%' )
	BEGIN
		SELECT @isTest = 1
	END
	ELSE
	BEGIN
		SELECT @isTest = 0
	END
	
	IF @SettingType IS NULL
	BEGIN
		INSERT @SportBetTypeSetting
		SELECT DISTINCT SportType,Bettype,IsLive, SettingType FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE ProductID = @ProductID 
				AND SettingStatus <= CASE WHEN @isTest = 1 THEN 1 ELSE 0 END
	END
	ELSE
	BEGIN
		INSERT @SportBetTypeSetting
		SELECT DISTINCT SportType,Bettype,IsLive, SettingType FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE ProductID = @ProductID AND SettingType = @SettingType 
				AND SettingStatus <= CASE WHEN @isTest = 1 THEN 1 ELSE 0 END
	END
	
	RETURN
END