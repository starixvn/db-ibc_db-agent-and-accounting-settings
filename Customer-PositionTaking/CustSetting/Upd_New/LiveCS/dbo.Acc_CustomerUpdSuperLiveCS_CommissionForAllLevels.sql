ALTER PROCEDURE Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels
	@custid		INT,
	@v162discount_1101		DECIMAL(9,8),
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,	
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20130221@Dan
Task : update live casino commission for super and all downlines
DB: DBTXN/bodb02
Original:

Revisions:	

Param's Explanation:
	• @custid: super id.   
	• @@v162discount_1101: commission to apply

*/
SET NOCOUNT ON

DECLARE @startRun DATETIME
DECLARE @endRun DATETIME
DECLARE @duration INT
SET @startRun = GETDATE()

--Check permission for account site
EXEC DBPOLICY.bodb02.dbo.Acc_Con_CheckPermission @custid=@UserID,@funcname='[UpdateLiveCasinoComm]',@ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
If @ErrCode <> 0
	RETURN
	
--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end

DECLARE @roleid tinyint
SELECT @roleid = roleid
FROM custinfo WITH (NOLOCK)
WHERE custid=@custid

-- check customer is super
IF ISNULL(@RoleID,0) <> 4
BEGIN
	SELECT @ErrMsg = 'Invalid user!', @ErrCode = 101
	RETURN
END

--validate commision
IF (@v162discount_1101<0.02 OR @v162discount_1101 > 0.027)
BEGIN
	SELECT @ErrMsg = 'Invalid commission (from 0.02 to 0.027)!', @ErrCode = 100
	RETURN
END

-- Check Allowed downlines during peak hour at weekend 
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=0,
											@Language='E',
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
if @ErrCode <>0 return 
--End 

DECLARE @db_v162discount_1101 DECIMAL(9,8)

--get old value to write log
SELECT @db_v162discount_1101 = sdiscount 
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

-- update commission for super
UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
SET sdiscount = @v162discount_1101
WHERE custid = @custid 

IF @@ERROR <> 0
BEGIN
		SELECT @ErrMsg = 'Update process is unsuccessful !'
				, @ErrCode = 102
		RETURN
END

-- update commission for master
UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
SET adiscount = @v162discount_1101
WHERE custid IN (SELECT custid 
				FROM custinfo WITH (NOLOCK)
				WHERE srecommend = @custid and roleid=3) 

IF @@ERROR <> 0
BEGIN
		SELECT @ErrMsg = 'Update process is unsuccessful !'
				, @ErrCode = 103
		RETURN
END

-- update commission for agents
UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
SET discount = @v162discount_1101
WHERE custid IN (SELECT custid 
				FROM custinfo WITH (NOLOCK)
				WHERE srecommend = @custid and roleid=2) -- agent

IF @@ERROR <> 0
BEGIN
		SELECT @ErrMsg = 'Update process is unsuccessful !'
				, @ErrCode = 104
		RETURN
END

-- update commission for members
UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
SET sdiscount = @v162discount_1101,
    adiscount = @v162discount_1101,
    discount = @v162discount_1101,
    playerdiscount = @v162discount_1101
WHERE custid IN (SELECT custid 
				FROM custinfo WITH (NOLOCK)
				WHERE srecommend = @custid and roleid=1) 

IF @@ERROR <> 0
BEGIN
		SELECT @ErrMsg = 'Update process is unsuccessful !'
				, @ErrCode = 105
		RETURN
END

-- write log
Declare @LogSPData varchar(8000),
		@TrackingValueDB varchar(8000)
	 
SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

BEGIN TRY
	--Log customer info 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 228,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" />'


	SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" />'

	--Log customer info 
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 228,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH				

GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels  TO [vnteam]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels  TO [bodbAdminNet]

