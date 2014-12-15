ALTER PROCEDURE [dbo].[Acc_CustSetting_SyncStatUpd] 
	  @custid		INT
	, @IsSync_XML	VARCHAR(MAX)	= NULL
	, @UserID		INT				= 0
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(20)		= ''
	, @Language		VARCHAR(2)		= 'E'
	, @ErrCode		INT				= 0 OUTPUT
	, @ErrMsg		VARCHAR(4000)	= '' OUTPUT
AS
/*  
  Created: Dominic  
  Date: 2014-12-04  
  DB: DBCUST/CUSTDB  
  Task: Update synchronize status on a product 
    
  Parameters Explanation:  
	* @IsSync_XML:	   <ROOT>
								<ProductStatus
										SportType="1" 
										BetType="1" 
										IsSync="1"
								/>
						</ROOT> 
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun		DATETIME
		, @endRun			DATETIME
		, @duration			INT
		, @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
	DECLARE @RoleID			TINYINT
		, @UplineCustID		INT
		
	DECLARE @ErrSport		VARCHAR(4000) = ''
	
	DECLARE @ErrCode_Cur	INT
		, @ErrMsg_Cur		NVARCHAR(4000)
		
	DECLARE @SyncStatusTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, IsSync		BIT
			, OldSync		BIT
			, UplineSync	BIT
			, Allow2Update	BIT
		)

	SELECT @ErrCode_Cur = 0
		, @ErrMsg_Cur	= ''
		, @ErrCode		= ''
		, @ErrMsg		= ''

	IF @IsSync_XML IS NULL
		OR @IsSync_XML = ''
		RETURN

	SET @startRun = GETDATE()

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
				, @ErrCode	= @ErrCode_Cur OUTPUT
				, @ErrMsg	= @ErrMsg_Cur OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode 
							+ cast(@ErrCode_cur AS VARCHAR(300)) 
			, @ErrMsg = @ErrMsg 
							+ @ErrMsg_Cur
		RETURN
	END

	--Parse xml
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsSync_XML

	INSERT @SyncStatusTbl
	SELECT SportType
		, BetType
		, IsSync
		, 0 AS OldSync
		, 0 AS UplineSync
		, 1 AS Allow2Update
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsSync	BIT
			)

	EXEC sp_xml_removedocument @iDoc


	--Get roleid
	SELECT @RoleID = RoleID
	FROM dbo.custinfo(NOLOCK)
	WHERE custid = @custid

	--Validate roleid
	IF (
			@RoleID IS NULL
			OR @roleid > 4
			)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Account does not exist or invalid customer account'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](40019, @Language)
				END
			, @ErrCode = 101

		RETURN
	END

	--Get old value
	UPDATE main
	SET main.OldSync = stt.IsSync
	FROM @SyncStatusTbl main
		INNER JOIN dbo.CustProductStatus stt
			ON main.SportType = stt.SportType
				AND main.BetType = stt.BetType
				AND stt.CustID = @custid

	--Get upline CustID
	SELECT @UplineCustID = CASE 
			WHEN roleid = 1
				THEN recommend
			WHEN roleid = 2
				THEN mrecommend
			WHEN roleid = 3
				THEN srecommend
			END
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE custid = @custid

	IF @roleid IN (1, 2, 3)
	BEGIN
		--Get upline's sync status
		UPDATE main
		SET main.UplineSync = stt.IsSync
		FROM @SyncStatusTbl main
			INNER JOIN dbo.CustProductStatus stt
				ON main.SportType = stt.SportType
					AND main.BetType = stt.BetType
					AND stt.CustID = @UplineCustID

		--Update Allow2Update
		UPDATE @SyncStatusTbl
		SET Allow2Update = UplineSync
	END

	--Get error sport
	SELECT @ErrSport = ''
	SELECT @ErrSport = @ErrSport + p.ProductName + ','
	FROM @SyncStatusTbl tmp
	JOIN dbo.ProductSettingDetail pdt
		ON pdt.SportType = tmp.SportType
			AND pdt.BetType = tmp.BetType
			AND pdt.IsLive = 0
			AND pdt.SettingType = 4
	JOIN dbo.Products p
		ON p.ProductID = pdt.ProductID
	WHERE tmp.ALlow2Update = 0

	IF @@ROWCOUNT > 0
	BEGIN
		IF @ErrSport <> ''
			SET @ErrSport = LEFT(@ErrSport, LEN(@ErrSport) - 1)
			
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Cannot synchronize this product because this account''s upline not synchronize setting.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](6032, @Language)
				END 
				+ 
				CASE WHEN @ErrSport <> '' THEN  ' (' + @ErrSport + ')' ELSE '' END
			, @ErrCode = 102

		RETURN
	END

	--Update data
	UPDATE main
	SET main.IsSync = tmp.IsSync
	FROM dbo.CustProductStatus main
	INNER JOIN @SyncStatusTbl tmp
		ON main.SportType = tmp.SportType
			AND main.BetType = tmp.BetType
	WHERE main.CustID = @CustID

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language
				WHEN 'E'
					THEN 'Update process is unsuccessful !'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			, @ErrCode_cur = 103

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300))
				, @ErrMsg = @ErrMsg + @ErrMsg_Cur

			RETURN
		END
	END

	--START LOGGING		
	SET @xml = (
			SELECT @CustID AS '@c'
				, @UserID AS '@u'
				, dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, OldSync AS '@i'
					FROM @SyncStatusTbl
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	SET @xml = (
			SELECT @CustID AS '@c'
				, @UserID AS '@u'
				, dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, IsSync AS '@i'
					FROM @SyncStatusTbl
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 1153
			, @TrackingValue = @logSpData
			, @TrackingValue2 = @logSpData_Old
			, @duration = @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 1153
			, @TrackingValue = @logSpData
			, @TrackingValue2 = @logSpData_Old
			, @duration = @duration
	END CATCH
END
