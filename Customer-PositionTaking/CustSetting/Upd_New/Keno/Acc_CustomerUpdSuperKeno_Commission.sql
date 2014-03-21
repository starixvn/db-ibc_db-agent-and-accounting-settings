ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_Commission]
	@CustID INT,
	@Sporttype INT = 202,
	@Bettype INT,
	@discount DECIMAL(9,8),

	@IP VARCHAR(50) = '',
	@UserID INT = 0,
	@Language VARCHAR(20) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Company update commission on super
	DB: DBTXN/CustDB

	Revisions:

	Parameters Explanation:		
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun     DATETIME,
	        @endRun       DATETIME,
	        @duration     INT,
			@MaxDiscount  DECIMAL(9, 8)

	SELECT @MaxDiscount = Maxsdiscount FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = @Sporttype AND Bettype = @Bettype
	
	SET @startRun = GETDATE()
	
	DECLARE @Old_discount DECIMAL(9, 8)
	
	SELECT @Old_discount = csg.sdiscount
	FROM   CustSettingGame csg WITH (NOLOCK)
	WHERE  csg.CustID = @custid
	       AND csg.Sporttype = @Sporttype
	       AND csg.Bettype = @Bettype
	
	IF @Old_discount = @discount 
	    RETURN
	
	IF @discount < 0 OR @discount > @MaxDiscount
	BEGIN
	    SELECT @ErrMsg = CASE @Language
	                          WHEN 'E' THEN 'Invalid commission rate.'
	                          ELSE dbo.f_Get_MsgNamebyMsgID(1, @Language)
	                     END,
	           @ErrCode = 103
	END
	
	-- Apply exec rep
	EXEC Acc_CustSetting3rd_06_xtest
		@CustId = @CustID,
		@RoleId = 4,
		@mode = 'Keno',
		@Sporttype = @Sporttype,
		@Bettype = @Bettype,
		@Discount = @discount
	
	DECLARE @LogSPData           VARCHAR(MAX),
	        @TrackingValueDB     VARCHAR(4000)
	
	SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Commission Custid ="' + COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'discount="' + COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Userid="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
			'IP="' + COALESCE(CAST(@Ip AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	
	SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperKeno_Commission Custid ="' + COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'discount="' + COALESCE(CAST(@Old_discount AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Userid="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
			'IP="' + COALESCE(CAST(@Ip AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	
	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)
	
	-- Log customer info
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		     @UserID = @UserID,
		     @CustID = @CustID,
		     @ActionID = 233,
		     @TrackingValue = @LogSPData,
		     @TrackingValue2 = @TrackingValueDB,
		     @duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Commission Custid ="' + COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
			'discount="' + COALESCE(CAST(@discount AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Userid="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) + '" ' +
			'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
			'IP="' + COALESCE(CAST(@Ip AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
			'ErrMsg="' + ERROR_MESSAGE() + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		     @UserID = @UserID,
		     @CustID = @CustID,
		     @ActionID = 233,
		     @TrackingValue = @LogSPData,
		     @TrackingValue2 = @TrackingValueDB,
		     @duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Commission]  TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Commission]  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno_Commission]  TO [vnteam]