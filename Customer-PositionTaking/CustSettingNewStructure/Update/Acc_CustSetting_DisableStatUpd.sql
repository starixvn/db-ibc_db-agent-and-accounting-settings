SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableStatUpd] 
	  @CustID			INT
	, @IsDisabled	VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(200)	= ''	OUTPUT
AS
/*
	Created: 20141110@Dominic
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"
						IsDisabledDownline="1"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
	DECLARE @AgentID	INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
		
	DECLARE @NewDisableStatTbl TABLE (
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, IsDisabledDownline	BIT
		)
	DECLARE @OldDisableStatTbl TABLE (
		SportType		SMALLINT
		, BetType		SMALLINT
		, IsDisabled	BIT
		)

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	--Check if XML is null or empty
	IF @IsDisabled IS NULL
		OR @IsDisabled = ''
		RETURN

	SET @startRun = GETDATE()

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END
	

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID
	
	
	--Check belonging
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END
	
	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
												@custid		= @custid
											,	@roleid		= @roleid
											,	@isExecRep	= 1
											,	@Language	= 'E'
											,	@ErrCode	= @ErrCode	OUTPUT
											,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	--Parse XML
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsDisabled

	INSERT @NewDisableStatTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)

	EXEC sp_xml_removedocument @iDoc

	--Validate new disabled status
	EXEC [dbo].[Acc_CustSetting_DisableStatCheck] @IsDisabled = @IsDisabled
		, @RoleID	= @RoleID
		, @AgentID	= @AgentID
		, @MasterID = @MasterID
		, @SuperID	= @SuperID
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	--Get old disabled status
	INSERT INTO @OldDisableStatTbl
	SELECT stt.SportType
		, stt.BetType
		, stt.IsDisabled
	FROM @NewDisableStatTbl tmp
	INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
		ON tmp.SportType	= stt.SportType
			AND tmp.BetType = stt.BetType
	WHERE stt.CustID = @CustID AND stt.SettingType = 4

	--If status did not be changed than return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @NewDisableStatTbl tmp
			INNER JOIN @OldDisableStatTbl stt
				ON tmp.SportType	= stt.SportType
					AND tmp.BetType = stt.BetType
			WHERE tmp.IsDisabled <> stt.IsDisabled
			)
		RETURN

	--Update main table
	UPDATE stt
	SET stt.IsDisabled = tmp.IsDisabled
	FROM dbo.CustProductStatus stt WITH(ROWLOCK,UPDLOCK)
	INNER JOIN @NewDisableStatTbl tmp
		ON tmp.SportType	= stt.SportType
			AND tmp.BetType = stt.BetType
	WHERE stt.CustID		= @CustID
		AND tmp.IsDisabled <> stt.IsDisabled
		AND stt.SettingType = 4

	DECLARE @ProductID INT
	SELECT TOP 1 @ProductID = pdt.ProductID
	FROM dbo.ProductSettingDetail pdt WITH(NOLOCK)
		INNER JOIN @NewDisableStatTbl tmp
			ON tmp.SportType	= pdt.SportType
				AND tmp.BetType = pdt.BetType
	WHERE pdt.SettingType = 4
	
	IF EXISTS(SELECT TOP 1 1
	FROM dbo.CustProductStatus stt WITH(NOLOCK)
	WHERE stt.CustID		= @CustID
		AND stt.SettingType = 4
		AND stt.IsDisabled = 0)
	BEGIN
		UPDATE stt
		SET stt.IsHidden = 0
		FROM dbo.CustProductStatus stt WITH(ROWLOCK,UPDLOCK)
			INNER JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
				ON pdt.SportType	= stt.SportType
					AND pdt.BetType = stt.BetType
					AND pdt.ProductID = @ProductID
					AND pdt.SettingType = stt.SettingType
		WHERE stt.CustID		= @CustID
			AND stt.IsHidden	= 1
			AND stt.SettingType = 5
			
	END


	--call execrept to update downline
	IF @RoleID <> 1 AND EXISTS (
			SELECT TOP 1 1
			FROM @NewDisableStatTbl
			WHERE IsDisabled = 1
				OR (
						IsDisabled				= 0
						AND IsDisabledDownline	= 0
					)
			)
	EXEC dbo.[Acc_ExecRep_Cust_04] @CustID = @CustID
						, @RoleID			= @RoleID
						, @Action			= 'Others'
						, @IsDisabled_XML	= @IsDisabled
	

	--START LOGGING		
	SET @xml = (
			SELECT @CustID	AS '@CustID'
				, @UserID	AS '@UserID'
				, dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName'
				, @IP		AS '@IP'
				, (
					SELECT SportType	AS '@SportType'
						, BetType		AS '@BetType'
						, IsDisabled	AS '@IsDisabled'
						, NULL			AS '@IsDisabledDownline'
					FROM @OldDisableStatTbl
					FOR XML PATH('ProductStatus')
						, TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableStatUpd')
				, TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	SET @xml = (
			SELECT @CustID	AS '@CustID'
				, @UserID	AS '@UserID'
				, dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName'
				, @IP		AS '@IP'
				, (
					SELECT SportType	AS '@SportType'
						, BetType		AS '@BetType'
						, IsDisabled	AS '@IsDisabled'
						, IsDisabledDownline			AS '@IsDisabledDownline'
					FROM @NewDisableStatTbl
					FOR XML PATH('ProductStatus')
						, TYPE
					)
			FOR XML PATH('Acc_CustSetting_DisableStatUpd')
				, TYPE
			)
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1152
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			, @CustID			= @CustID
			, @ActionID			= 1152
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatUpd] TO [bodbExtAccNet]