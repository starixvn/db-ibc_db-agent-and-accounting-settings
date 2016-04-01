ALTER PROCEDURE [dbo].[Acc_CustSetting_StatusSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT = NULL
	, @SettingType	SMALLINT = 4
	, @RoleID INT = NULL
AS
/*
	Created: 20151012@Helen
	Task : setting values of a product
	DB: DBCUST/CustDB, DBAGE/bodb02
	Original:

	Revisions:
		- 20160114@Helen: Cricket - [Redmine: #50027]
		- 20160330@Elodie: Get more IsSyncedUpline, IsSyncedDownline infomation [Redmine: #49606]

	Param's Explanation:
	• @CustID: 
	
	*/
BEGIN
	
	DECLARE @IsDisabledDownline BIT, @downlines BIT  = 0 
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT , @IsIMBC BIT = 0 
	
	SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend , @AgentID = ci.recommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID 
	
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @SuperID AND [Site] = 'IMBC')
		SET @IsIMBC = 1
		
	SELECT ProductID,SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)

	DELETE sbf
	FROM		#SportBettypeFilter sbf
	INNER JOIN	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(@CustID, @ProductID) AS sbhsc
			ON	sbhsc.ProductID = sbf.ProductID
	WHERE	sbhsc.IsHidden = 1
	
	IF @RoleID = 4
	BEGIN

		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE srecommend = @CustID	AND roleid = 3
					)
		SET @downlines = 1			
			
		SELECT pdt.ProductID, pdt.SportType
			, pdt.BetType
			, CASE WHEN stt.CustID IS NULL THEN 0 ELSE dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) END as IsSync
			
			, CAST(CASE WHEN stt.CustID IS NULL  OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 ELSE 
														(CASE WHEN dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden  
			
			, CASE WHEN stt.CustID IS NULL THEN 1 ELSE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) END as isDisabled
			
			, CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
					ELSE ISNULL((
							SELECT TOP 1 1
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE srecommend = @CustID	AND roleid = 3
								AND dbo.f_GetProductStatus(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) = 1
							), 0)
							
			 END AS IsDisabledDownline
			, CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),1)
					ELSE ISNULL((
							SELECT TOP 1 0
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE srecommend = @CustID	--AND roleid = 3
								AND dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
							), 1)
							
			 END AS IsSyncedDownline
			, 0 AS isDisabledUpline
			, 1 AS isSyncedUpline
			, ISNULL(@downlines,0) As HasDownline
		FROM DBCUST.CUSTDB.dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
												AND pdt.BetType = ft.bettype
												AND pdt.IsLive = ft.islive
												AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			
		WHERE pdt.SettingType = @SettingType
		
	END
	ELSE IF @RoleID = 3
	BEGIN
	
		IF EXISTS (SELECT 1
						FROM custinfo WITH (NOLOCK)
						WHERE mrecommend = @CustID	AND roleid = 2
						)
		SET @downlines = 1	
   
		SELECT pdt.ProductID, pdt.SportType
			, pdt.BetType
			, CASE WHEN stt.CustID IS NULL THEN 0 ELSE dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) END as IsSync
			, CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 ELSE (CASE WHEN dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden  
			, CASE WHEN stt.CustID IS NULL THEN 1 ELSE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) END as isDisabled
			
			, CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
					ELSE ISNULL((
							SELECT TOP 1 1
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE mrecommend = @CustID	AND roleid = 2
								AND dbo.f_GetProductStatus(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) = 1
							), 0)
							
			 END AS IsDisabledDownline
			 , CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),1)
					ELSE ISNULL((
							SELECT TOP 1 0
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE mrecommend = @CustID	--AND roleid = 2
								AND dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
							), 1)
							
			 END AS IsSyncedDownline
			 , dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
			 , dbo.f_GetProductStatus(stt_UPLINE.bitmapHasSynced, PSP.bitmapOrder) as IsSyncedUpline
			 , ISNULL(@downlines,0) As HasDownline
		FROM DBCUST.CUSTDB.dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
												AND pdt.BetType = ft.bettype
												AND pdt.IsLive = ft.islive
												AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			
		WHERE pdt.SettingType = @SettingType
	
	END 		
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS ( SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE recommend = @CustID	AND roleid = 1
					)
			SET @downlines = 1	
   
		SELECT pdt.ProductID, pdt.SportType
			, pdt.BetType
			, CASE WHEN stt.CustID IS NULL THEN 0 ELSE dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) END as IsSync
			, CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 ELSE (CASE WHEN dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden  
			, CASE WHEN stt.CustID IS NULL THEN 1 ELSE  dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder)END  as isDisabled
			
			, CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
					ELSE ISNULL((
							SELECT TOP 1 1
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE recommend = @CustID	--AND roleid = 1
								AND dbo.f_GetProductStatus(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) = 1
							), 0)
							
			 END AS IsDisabledDownline
			 , CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder),1)
					ELSE ISNULL((
							SELECT TOP 1 0
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE recommend = @CustID	AND roleid = 1
								AND dbo.f_GetProductStatus(cps_temp.bitmapHasSynced, PSP.bitmapOrder) = 0
							), 1)
							
			 END AS IsSyncedDownline
			 , dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
			 , dbo.f_GetProductStatus(stt_UPLINE.bitmapHasSynced, PSP.bitmapOrder) as IsSyncedUpline
			, ISNULL(@downlines,0) As HasDownline
		FROM DBCUST.CUSTDB.dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
												AND pdt.BetType = ft.bettype
												AND pdt.IsLive = ft.islive
												AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID
			
		WHERE pdt.SettingType = @SettingType
		
	END	
	ELSE IF @RoleID = 1
	BEGIN
		SELECT pdt.ProductID, pdt.SportType
				, pdt.BetType
				, CASE WHEN stt.CustID IS NULL THEN 0 ELSE dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) END as IsSync
				, CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 ELSE (CASE WHEN dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden  
				, CASE WHEN stt.CustID IS NULL THEN 1 ELSE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) END as isDisabled
				, 0 AS IsDisabledDownline
				, 1 AS IsSyncedDownline
				, dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
				, dbo.f_GetProductStatus(stt_UPLINE.bitmapHasSynced, PSP.bitmapOrder) as IsSyncedUpline
				, 0 As HasDownline
			FROM DBCUST.CUSTDB.dbo.ProductSettingDetail pdt WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
													AND pdt.BetType = ft.bettype
													AND pdt.IsLive = ft.islive
													AND pdt.SettingType = ft.SettingType
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
				LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
				LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
				
			WHERE pdt.SettingType = @SettingType
						
		
	END	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_StatusSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_StatusSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_StatusSettingSelect] TO [bodbExtAccNet]
