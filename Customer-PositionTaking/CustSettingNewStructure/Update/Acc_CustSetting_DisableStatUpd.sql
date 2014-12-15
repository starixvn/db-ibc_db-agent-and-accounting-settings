SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableStatUpd] 
	  @CustID			INT
	, @IsDisabled_XML	VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @Language			VARCHAR(20)		= 'E'
	, @ErrCode			VARCHAR(300)	= '' OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= '' OUTPUT
AS
/*
	Created: 20141110@Dominic
	Task : Validate enabled status
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @IsDisabled_XML
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
		
	DECLARE @ErrCode_Cur	INT
		, @ErrMsg_Cur		NVARCHAR(4000)
		
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

	SELECT @ErrCode_Cur = 0
		, @ErrMsg_Cur	= ''
		, @ErrCode		= ''
		, @ErrMsg		= ''

	--Check if XML is null or empty
	IF @IsDisabled_XML IS NULL
		OR @IsDisabled_XML = ''
		RETURN

	SET @startRun = GETDATE()

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
								, @ErrCode	= @ErrCode_Cur	OUTPUT
								, @ErrMsg	= @ErrMsg_Cur	OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode 
							+ cast(@ErrCode_cur AS VARCHAR(300)) 
							+ CHAR(7)
			,	@ErrMsg = @ErrMsg 
							+ @ErrMsg_Cur 
							+ CHAR(7)

		RETURN
	END

	--Check RoleID
	IF @RoleID NOT IN (1, 2, 3, 4)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Invalid user!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
				END
			, @ErrCode = 101

		RETURN
	END

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Parse XML
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsDisabled_XML

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
	EXEC [dbo].[Acc_CustSetting_DisableStatCheck] @IsDisabled_XML = @IsDisabled_XML
		, @RoleID	= @RoleID
		, @AgentID	= @AgentID
		, @MasterID = @MasterID
		, @SuperID	= @SuperID
		, @ErrCode	= @ErrCode	OUTPUT
		, @ErrMsg	= @ErrMsg	OUTPUT

	IF @ErrCode <> ''
		RETURN

	--Get old disabled status
	INSERT INTO @OldDisableStatTbl
	SELECT stt.SportType
		, stt.BetType
		, stt.IsDisabled
	FROM @NewDisableStatTbl tmp
	INNER JOIN dbo.CustProductStatus stt
		ON tmp.SportType	= stt.SportType
			AND tmp.BetType = stt.BetType
	WHERE stt.CustID = @CustID

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

	--Check Allowed downlines	
	IF EXISTS (
			SELECT TOP 1 1
			FROM @NewDisableStatTbl
			WHERE IsDisabled = 1
				OR (
					IsDisabled = 0
					AND IsDisabledDownline = 0
					)
			)
	BEGIN
		EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid = @custid
			, @roleid		= @roleid
			, @isExecRep	= 1
			, @Language		= @Language
			, @ErrCode		= @ErrCode_Cur OUTPUT
			, @ErrMsg		= @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode 
								+ cast(@ErrCode_cur AS VARCHAR(300)) 
								+ CHAR(7)
				,	@ErrMsg = @ErrMsg 
								+ @ErrMsg_Cur 
								+ CHAR(7)

			RETURN
		END
	END

	--Update main table
	UPDATE stt
	SET stt.IsDisabled = tmp.IsDisabled
	FROM dbo.CustProductStatus stt
	INNER JOIN @NewDisableStatTbl tmp
		ON tmp.SportType	= stt.SportType
			AND tmp.BetType = stt.BetType
	WHERE stt.CustID		= @CustID
		AND tmp.IsDisabled <> stt.IsDisabled

	UPDATE stt
	SET stt.IsHidden = 0
	FROM dbo.CustProductStatus stt
	INNER JOIN @NewDisableStatTbl tmp
		ON tmp.SportType	= stt.SportType
			AND tmp.BetType = stt.BetType
	WHERE stt.CustID		= @CustID
		AND stt.IsHidden	= 1
		AND tmp.IsDisabled	= 0

	IF (@@error <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Update process is unsuccessful.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			, @ErrCode = 102

		RETURN
	END

	--call execrept to update downline
	IF EXISTS (
			SELECT TOP 1 1
			FROM @NewDisableStatTbl
			WHERE IsDisabled = 1
				OR (
						IsDisabled				= 0
						AND IsDisabledDownline	= 0
					)
			)
	BEGIN TRY
		EXEC dbo.[Acc_ExecRep_Cust_04] @CustID = @CustID
						, @RoleID			= @RoleID
						, @Action			= 'Others'
						, @IsDisabled_XML	= @IsDisabled_XML
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Update process is unsuccessful.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END

		IF @RoleID = 4
			SELECT @ErrCode = 103
		ELSE IF @RoleID = 3
			SELECT @ErrCode = 104
		ELSE IF @RoleID = 2
			SELECT @ErrCode = 105

		RETURN
	END CATCH

	--START LOGGING		
	SET @xml = (
			SELECT @CustID	AS '@c'
				, @UserID	AS '@u'
				, @IP		AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType	AS '@s'
						, BetType		AS '@b'
						, IsDisabled	AS '@i'
						, NULL			AS '@d'
					FROM @OldDisableStatTbl
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	SET @xml = (
			SELECT @CustID	AS '@c'
				, @UserID	AS '@u'
				, dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP		AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType			AS '@s'
						, BetType				AS '@b'
						, IsDisabled			AS '@i'
						, IsDisabledDownline	AS '@d'
					FROM @NewDisableStatTbl
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
