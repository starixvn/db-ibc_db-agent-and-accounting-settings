ALTER PROCEDURE [dbo].[Acc_CustSetting_MultiCustEnableCheck] 
	  @CustIDList VARCHAR(MAX) =''
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-08
		Task: Check enabled status for a list of costumers
		DB: DBCUST/CUSTDB
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @IsEnable BIT
			,@UserName NVARCHAR(50)=NULL
			
	DECLARE @tblCust TABLE(CustID INT)
	
	--Parse CustID
	INSERT INTO @tblCust (CustID )
	SELECT CONVERT(INT,val) FROM dbo.strSplit(@CustIDList,',') 


	SELECT @isEnable = ISNULL(ci.enabled, 0)
			,@UserName=ci.username
	FROM custinfo ci WITH (NOLOCK)
	JOIN @tblCust tmp ON tmp.CustID=ci.CustID
	WHERE ISNULL(ci.enabled, 0)=0


	IF @isEnable = 0
		OR @@rowcount = 0
	BEGIN
		SELECT @ErrMsg = 'Some accounts were disabled!'
					+ CASE WHEN @UserName IS NOT NULL AND @UserName <> ''
							THEN '('+@UserName+')'
						ELSE ''
					END
			, @ErrCode = 600

		RETURN
	END
END
