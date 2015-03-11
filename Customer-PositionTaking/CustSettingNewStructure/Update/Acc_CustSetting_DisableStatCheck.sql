SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableStatCheck] 
	  @IsDisabled	VARCHAR(MAX)
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20141110@Dominic
	Task : Validate enabled status
	DB: DBTXN/CustDB
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

	DECLARE @NewDisableStatTbl TABLE (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
		)
	DECLARE @ErrorSportTypeTbl TABLE (
			SportType SMALLINT
			, BetType SMALLINT
		)
	DECLARE @xml		XML

	SELECT @ErrCode = 0
		, @ErrMsg	= ''

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

	--Get error data
	IF @RoleID = 3
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType
			, stt.BetType
		FROM @NewDisableStatTbl tmp
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON tmp.SportType	= stt.SportType
				AND tmp.BetType = stt.BetType
				AND stt.CustID	= @SuperID
		WHERE stt.IsDisabled	= 1
			AND tmp.IsDisabled	= 0
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType
			, stt.BetType
		FROM @NewDisableStatTbl tmp
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON tmp.SportType	= stt.SportType
				AND tmp.BetType = stt.BetType
				AND stt.CustID	= @MasterID
		WHERE stt.IsDisabled	= 1
			AND tmp.IsDisabled	= 0
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType
			, stt.BetType
		FROM @NewDisableStatTbl tmp
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			ON tmp.SportType	= stt.SportType
				AND tmp.BetType = stt.BetType
				AND stt.CustID	= @SuperID
		WHERE stt.IsDisabled	= 1
			AND tmp.IsDisabled	= 0
	END

	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
			)
		RETURN

	IF EXISTS(SELECT TOP 1 1 FROM @ErrorSportTypeTbl)
	BEGIN
		SET @xml = (
				SELECT 60031 AS '@MsgID'
					, 'Account disabled for this product. Unable to edit downlines.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
						FROM @ErrorSportTypeTbl
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 101
		
		RETURN
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableStatCheck] TO [bodbExtAccNet]