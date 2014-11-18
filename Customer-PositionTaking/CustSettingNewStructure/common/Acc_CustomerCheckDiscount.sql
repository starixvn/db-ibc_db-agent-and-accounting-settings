SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerCheckDiscount]
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

	DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML
	
		SELECT *
	INTO #newDiscountTbl
	FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
	WITH(SportType smallint, BetType smallint, Discount Decimal)	
	
	EXEC sp_xml_removedocument @iDoc
	
	
	IF EXISTS
	(
	SELECT TOP 1 1
	FROM #newDiscountTbl tmp JOIN dbo.ProductSettingDetail dtl
	ON dtl.SettingType=tmp.SportType AND dtl.BetType=tmp.BetType
	WHERE dtl.SettingType=3 AND dtl.IsLive=0
	AND tmp.Discount < 0 OR tmp > dtl.maxDiscount)
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	END
	
	
	IF OBJECT_ID('tempdb..#newDiscountTbl') IS NOT NULL
		DROP TABLE #newDiscountTbl
END