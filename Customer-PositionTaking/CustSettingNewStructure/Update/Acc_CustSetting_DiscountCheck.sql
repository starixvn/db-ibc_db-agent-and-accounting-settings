SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DiscountCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @Discount_XML		VARCHAR(MAX)
	, @Language			VARCHAR(2)		= 'E'
	, @ErrCode			VARCHAR(300)	= ''	OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20141111@Dominic
	Task : Check Customer's Discount
	DB: DBCUST/CUSTDB
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

	DECLARE @NewDiscountTbl TABLE (
		SportType	SMALLINT
		, BetType	SMALLINT
		, Discount	DECIMAL(9, 8)
		)
	DECLARE @ErrSport VARCHAR(4000) = ''

	IF @Discount_XML IS NULL
		OR @Discount_XML = ''
		RETURN

	SELECT	@ErrCode	= ''
		,	@ErrMsg		= ''

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
					, @Discount_XML

	INSERT @NewDiscountTbl
	SELECT SportType
		, BetType
		, CAST(Discount AS DECIMAL(9, 8)) AS Discount
	FROM OPENXML(@iDoc, '/ROOT/Discount', 1) WITH (
				SportType	SMALLINT
				, BetType	SMALLINT
				, Discount	VARCHAR(15)
			)

	EXEC sp_xml_removedocument @iDoc

	SELECT @ErrSport = @ErrSport 
						+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
						WHEN pdt.ErrMsgLevel = 2
								THEN [dbo].[f_Get_SportNameBySporttype](tmp.SportType, @Language) + ','
						WHEN pdt.ErrMsgLevel = 3
								THEN [dbo].[dbo.F_Get_BetNameByTypeID](tmp.BetType, @Language) + ','
						WHEN pdt.ErrMsgLevel = 4
								THEN p.ProductName + ','
						WHEN pdt.ErrMsgLevel = 5
								THEN [dbo].[f_Get_SportNameBySporttype](tmp.SportType, @Language)
									+ ' - '
									+ [dbo].[dbo.F_Get_BetNameByTypeID](tmp.BetType, @Language) + ','
					END
	FROM @NewDiscountTbl tmp
	INNER JOIN dbo.ProductSettingDetail dtl
		ON dtl.SportType	= tmp.SportType
			AND dtl.BetType = tmp.BetType
			AND dtl.SettingType = 3
			AND dtl.IsLive		= 0
	JOIN dbo.Products p
		ON p.ProductID = pdt.ProductID
	WHERE 
	(	tmp.Discount		< 0
		OR	tmp.Discount	> dtl.maxDiscount
	)

	IF @@ROWCOUNT > 0
	BEGIN
		IF @ErrSport <> ''
			SET @ErrSport = LEFT(@ErrSport, LEN(@ErrSport) - 1)

		SELECT @ErrMsg = CASE @Language
					WHEN 'E'
						THEN 'Invalid commission rate.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](1, @Language)
				END 
				+ CASE WHEN @ErrSport <> '' THEN  ' (' + @ErrSport + ')' ELSE '' END
			, @ErrCode = 101
	END
END
