SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdBetLimit]
	@CustID INT,
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@Discount_XML VARCHAR(MAX)
AS
	/*
	Created: 20141111@Dominic
	Task : Update Customer's Discount
	DB: CUSTDB
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
	DECLARE @startRun datetime, 
			@endRun datetime, 
			@duration int
			
	set @startRun = getdate()

	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Discount_XML
	
	SELECT *
	INTO #newDiscountTbl
	FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
	WITH(SportType smallint, BetType smallint, Discount Decimal)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF @RoleID=4
	BEGIN
		UPDATE dcs
		SET 
			dcs.discounta = tmp.Discount
		FROM dbo.CustDiscount3rd_Agent dcs
		JOIN #newDiscountTbl tmp ON tmp.SportType=dcs.SportType AND tmp.BetType=dcs.BetType
		WHERE dcs.CustID=@CustID
	END
	ELSE IF @RoleID=3
	BEGIN
		UPDATE dcm
		SET 
			dcm.discounta = CASE WHEN tmp.Discount < dcs.discounta THEN tmp.Discount ELSE dcs.discounta END
		FROM dbo.CustDiscount3rd_Agent dcm
		JOIN dbo.CustDiscount3rd_Agent dcs
			ON dcm.SportType=dcs.SportType AND dcm.BetType=dcs.BetType AND dcs.custid=@SuperID
		JOIN #newDiscountTbl tmp 
			ON tmp.SportType=dcs.SportType AND tmp.BetType=dcs.BetType
		WHERE dcm.CustID=@CustID
	END
	ELSE IF @RoleID=2
	BEGIN
		UPDATE dca
		SET 
			dca.discounta = CASE WHEN tmp.Discount < dcm.discounta THEN tmp.Discount ELSE dcm.discounta END
		FROM dbo.CustDiscount3rd_Agent dca
		JOIN dbo.CustDiscount3rd_Agent dcm
			ON dca.SportType=dcm.SportType AND dca.BetType=dcm.BetType AND dcm.custid=@MasterID
		JOIN #newDiscountTbl tmp 
			ON tmp.SportType=dcm.SportType AND tmp.BetType=dcm.BetType
		WHERE dca.CustID=@CustID
	END
	ELSE IF @RoleID=1
	BEGIN
		UPDATE dcmem
		SET 
			dcmem.playerdiscount = CASE WHEN tmp.Discount < dca.discounta THEN tmp.Discount ELSE dca.discounta END
		FROM dbo.CustDiscount3rd_Member dcmem
		JOIN dbo.CustDiscount3rd_Agent dca
			ON dca.SportType=dca.SportType AND dca.BetType=dca.BetType AND dca.custid=@AgentID
		JOIN #newDiscountTbl tmp 
			ON tmp.SportType=dca.SportType AND tmp.BetType=dca.BetType
		WHERE dcmem.CustID=@CustID
	END
	
	IF OBJECT_ID('tempdb..#newDiscountTbl') IS NOT NULL
		DROP TABLE #newDiscountTbl
END