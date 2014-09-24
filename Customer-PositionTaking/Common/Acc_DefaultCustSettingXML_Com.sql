CREATE PROCEDURE [dbo].[Acc_DefaultCustSettingXML_Com]
	@ProductID TINYINT,
	@SettingTypes VARCHAR(50),
	@DefaultSettingXML VARCHAR(MAX) OUTPUT
AS
/*
	Returned XML format
		<CustSetting>
			<SportType>180</SportType>
			<BetType>1201</BetType>
			<SettingType>1</SettingType>
			<IsLive>0</IsLive>
			<ProductID>5</ProductID>
			<SettingType>1</SettingType>
		</CustSetting>
*/
BEGIN
	DECLARE @SettingTypeTbl TABLE(SettingType SMALLINT)
	
	INSERT INTO @SettingTypeTbl
	SELECT CONVERT(INT,val) FROM dbo.strSplit(@SettingTypes,',')

	SET @DefaultSettingXML = (SELECT * FROM
	dbo.ProductSettingDetail p
	JOIN @SettingTypeTbl s ON p.SettingType = s.SettingType
	WHERE p.ProductID = @ProductID
	FOR XML RAW ('CustSetting'), ELEMENTS)
END

