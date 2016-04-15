ALTER FUNCTION	f_CustSetting_ProductSettingsSelect (
					@ProductID		TINYINT
				,	@SettingType	SMALLINT
				) 
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT	psd.ProductID, psd.SportType, psd.BetType, psd.IsLive, psd.SettingType
	FROM	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
	WHERE	psd.ProductID = ISNULL(@ProductID, psd.ProductID)
		AND	psd.SettingType = ISNULL(@SettingType, psd.SettingType)
		AND	psd.SettingStatus <=	CASE	WHEN	(	OBJECT_NAME(@@PROCID) LIKE '%[_]xtest%'
													OR	OBJECT_NAME(@@PROCID) LIKE '%[_]xpre%'
													OR	OBJECT_NAME(@@PROCID) LIKE '%[_]uat[1-9]%'
													)
												THEN 1
											ELSE 0
									END;
GO

GRANT SELECT ON f_CustSetting_ProductSettingsSelect TO bodbDownlineNet;
GO