SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DiscountCheck]
	@CustID INT,
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@Discount_XML VARCHAR(MAX),

	@Language varchar(2) = 'E',
	@ErrCode  VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg     NVARCHAR(4000) = '' OUTPUT
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
			
	DECLARE @NewDiscountTbl TABLE(
		SportType SMALLINT,
		BetType SMALLINT,
		Discount Decimal(9,8)
	)
	

	
	IF @Discount_XML IS NULL OR @Discount_XML='' RETURN
	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Discount_XML
	
	INSERT @NewDiscountTbl
	SELECT SportType,BetType,CAST(Discount AS DECIMAL(9,8)) AS Discount
	FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
	WITH(SportType smallint, BetType smallint, Discount VARCHAR(15))	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF EXISTS (
			SELECT TOP 1 1
			FROM @NewDiscountTbl tmp
				INNER JOIN dbo.ProductSettingDetail dtl 
					ON dtl.SportType = tmp.SportType
					AND dtl.BetType = tmp.BetType
			WHERE dtl.SettingType = 3
				AND dtl.IsLive = 0
				AND tmp.Discount < 0
				OR tmp.Discount > dtl.maxDiscount
			)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Invalid commission rate.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](1, @Language)
				END
				,@ErrCode = 1

		RETURN
	END
		

END