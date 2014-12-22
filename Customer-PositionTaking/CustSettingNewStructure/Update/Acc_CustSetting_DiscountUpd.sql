SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DiscountUpd] 
	  @CustID				INT
	, @Discount_XML			VARCHAR(MAX)
	, @SubAccID				INT				= 0
	, @UserID				INT
	, @IP					VARCHAR(50)		= ''
	, @Language				VARCHAR(20)		= 'E'
	, @ErrCode				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20141111@Dominic
	Task : Update Customer's Discount
	DB: DBTXN/CustDB
	Original:

	Param's Explanation:
	• @Discount_XML:
		<ROOT>
				<Discount 
						SportType="1" 
						BetType="1" 
						Discount="0.0025"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @iDoc INT
	
	DECLARE @startRun				DATETIME
		,	@endRun					DATETIME
		,	@duration				INT
		,	@CorrectedDiscount_XML	VARCHAR(MAX)
		
	DECLARE @logSpData		NVARCHAR(MAX)
		,	@logSpData_Old	NVARCHAR(MAX)
		,	@xml			XML
		
	DECLARE @AgentID		INT
		,	@MasterID		INT
		,	@SuperID		INT
		,	@RoleID			INT
		
		
	DECLARE @NewDiscountTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9, 8)
		)
		
	DECLARE @oldDiscountTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9, 8)
		)

	--Check if XML is null or empty
	IF @Discount_XML IS NULL
		OR @Discount_XML = ''
		RETURN

	SELECT	@ErrCode		= 0
		,	@ErrMsg			= ''

	SET @startRun = GETDATE()

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN
	

	--Check RoleID
	IF @RoleID NOT IN (1, 2, 3, 4)
	BEGIN
		SELECT @ErrMsg = CASE @Language
						WHEN 'E'
							THEN 'Invalid user!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
					END
			,	@ErrCode = 101

		RETURN
	END

	--Check Allowed downlines	
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines 
												@custid		= @custid
											,	@roleid		= @roleid
											,	@isExecRep	= 1
											,	@Language	= @Language
											,	@ErrCode	= @ErrCode	OUTPUT
											,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
		RETURN
	

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID = srecommend
		, @RoleID = RoleID
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Parse XML
	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @Discount_XML

	INSERT @NewDiscountTbl
	SELECT SportType
		, BetType
		, CAST(Discount AS DECIMAL(9, 8)) AS Discount
	FROM OPENXML(@iDoc, '/ROOT/Discount', 1) WITH (
			SportType SMALLINT
			, BetType SMALLINT
			, Discount VARCHAR(15)
			)

	EXEC sp_xml_removedocument @iDoc

	EXEC [dbo].[Acc_CustSetting_DiscountCheck] 
						@CustID			= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @Discount_XML = @Discount_XML
						, @Language		= @Language
						, @ErrCode		= @ErrCode	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	--Get old comm
	IF @RoleID IN (2, 3, 4)
	BEGIN
		INSERT INTO @oldDiscountTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.Discount
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @oldDiscountTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END

	IF @RoleID = 3
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, super_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dcs.Discount
					THEN tmp.Discount
				ELSE dcs.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH (NOLOCK)
			ON tmp.SportType	= dcs.SportType
				AND tmp.BetType = dcs.BetType
				AND dcs.custid	= @SuperID
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, master_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dcm.Discount
					THEN tmp.Discount
				ELSE dcm.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH (NOLOCK)
			ON tmp.SportType	= dcm.SportType
				AND tmp.BetType = dcm.BetType
				AND dcm.custid	= @MasterID
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, agent_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dca.Discount
					THEN tmp.Discount
				ELSE dca.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH (NOLOCK)
			ON dca.SportType	= tmp.SportType
				AND dca.BetType = tmp.BetType
				AND dca.custid	= @AgentID
	END

	--Return XML result
	SELECT @CorrectedDiscount_XML = (
			SELECT *
			FROM @NewDiscountTbl
			FOR XML RAW('Discount')
			)

	SELECT @CorrectedDiscount_XML = '<ROOT>' + @CorrectedDiscount_XML + '</ROOT>'

	--execrept to update commission
	EXEC dbo.Acc_CustSetting3rd_06 
			@CustId			= @custid
			, @RoleId		= @RoleId
			, @Discount_XML = @CorrectedDiscount_XML
			, @mode			= 'Others'

	--START LOGGING		
	SET @xml = (
			SELECT @CustID AS '@c'
				, @UserID AS '@u'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, Discount AS '@d'
					FROM @oldDiscountTbl
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
						, Discount AS '@d'
					FROM @NewDiscountTbl
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID				= @UserID
			, @CustID			= @CustID
			, @ActionID			= 237
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID				= @UserID
			, @CustID			= @CustID
			, @ActionID			= 237
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DiscountUpd] TO [bodbExtAccNet]