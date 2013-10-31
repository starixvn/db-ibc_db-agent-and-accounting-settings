ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperLiveCS_Commission] 
	@custid		INT,
	@v162discount_1101		DECIMAL(9,8),
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 28Dec2011
		Task: Company update commission on super
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120928@Lukas: Hardcode for super SLAM can have 0.02 comm
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20131031@Kathy: Apply exec rep to update commission [Redmine:#3244]
		Parameters Explanation:		 
	*/
SET NOCOUNT ON

DECLARE @startRun DATETIME, @endRun DATETIME ,@duration INT

SET @startRun = GETDATE()

DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

DECLARE @db_v162discount_1101 DECIMAL(9,8)

SELECT @db_v162discount_1101 = sdiscount 
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

IF @db_v162discount_1101 = @v162discount_1101 
	RETURN
	

IF @v162discount_1101 < 0 OR ( @v162discount_1101 > 0.01 AND @custid <> 8156203)
BEGIN	
	SELECT @ErrMsg = 	CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
				END, @ErrCode = 103
	RETURN
END

-- Apply exec rep
	EXEC Acc_CustSetting3rd_06
	@CustId = @custid,
	@RoleId = @roleid,
	@v162discount_1101 = @v162discount_1101,
	@mode = 'LiveCasino'
	
Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
	 
SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

--Log customer info 
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 224,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 224,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH				

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperLiveCS_Commission]  TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_Commission]  TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_Commission]  TO [bodbDownlineNet]