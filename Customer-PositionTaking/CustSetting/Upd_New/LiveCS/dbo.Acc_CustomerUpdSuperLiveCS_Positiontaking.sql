ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperLiveCS_Positiontaking]
	@custid		INT,
	@v162spositiontaking_1101 SMALLMONEY,
	
	@UserID		INT = 0	,
	@IP			VARCHAR(50)= '',	
	@Language	VARCHAR(20) = 'E',		
	
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 28Dec2011
		Task: Company update positiontaking on super
		DB: DBTXN/BODB02
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
		Parameters Explanation:
		
		Note:
			- Check synchronize status off member before update
	*/
SET NOCOUNT ON

DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT

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


DECLARE @db_v162spositiontaking_1101 SMALLMONEY

SELECT @db_v162spositiontaking_1101 = spositiontaking 
FROM CustSettingGame WITH(NOLOCK)
WHERE Custid = @custid AND sporttype = 162 AND bettype = 1101

--check if not change value
IF @db_v162spositiontaking_1101 = @v162spositiontaking_1101
	RETURN

--check all s3+m3<=s4 if i3 = 0,
--m3<=s4 and u3<=s4 if i3=1
SELECT @ErrAcc = ''

SELECT TOP 100 @ErrAcc = @ErrAcc + ci.username + ', '
FROM CustSettingGame cs WITH(NOLOCK)
	INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
WHERE ci.srecommend = @custid AND ci.roleid = 3
	AND cs.sporttype = 162 AND bettype = 1101
	AND ((cs.isautopositiontaking = 0 AND cs.spositiontaking + cs.mpositiontaking > @v162spositiontaking_1101)
		OR (cs.isautopositiontaking = 1 AND (cs.mpositiontaking > @v162spositiontaking_1101 OR cs.autopositiontaking > @v162spositiontaking_1101)))


IF @ErrAcc<>''
BEGIN
	Select @ErrMsg =
				case @Language 
						when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
				end, @ErrCode = 103
	return
END

--check all s1+m1+a1 <= s4
--check all u1<=s4 if i1=1
SELECT @ErrAcc = ''

SELECT @ErrAcc = @ErrAcc + ci.username + ', '	
FROM CustSettingGame cs WITH(NOLOCK)
	INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
WHERE ci.srecommend = @custid AND ci.roleid = 1
	AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > @v162spositiontaking_1101
		OR (cs.isautopositiontaking = 1 AND cs.autopositiontaking > @v162spositiontaking_1101))

IF @ErrAcc <> ''
BEGIN
	SELECT @ErrMsg =
				CASE @Language 
						WHEN 'E' THEN 'Existing members exceeded new super position taking ('+@ErrAcc+').'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20014,@Language) + ' ('+@ErrAcc+').'
				end, @ErrCode = 104
	RETURN
END


UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
SET spositiontaking = @v162spositiontaking_1101
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

IF (@@ERROR <> 0)
BEGIN
	SELECT @ErrMsg =
					CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END	, @ErrCode = 105					 
	
	RETURN
END

--u = (i3 or i1)?(u3 or u1)
--s1 = min(s4-m1-a1, u)
UPDATE cs 
SET spositiontaking = CASE WHEN @v162spositiontaking_1101 - cs.mpositiontaking - cs.apositiontaking >
							 CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
							(CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) 
						ELSE @v162spositiontaking_1101 - cs.mpositiontaking - cs.apositiontaking 
					END							
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON ci.custid = cs.custid
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
	--INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @custid AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
WHERE ci.srecommend = @custid AND roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101 
	AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)	 

IF (@@ERROR <> 0)
BEGIN
	SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					END	, @ErrCode = 105					 
	
	RETURN
END

Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
	 
SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162spositiontaking_1101="' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162spositiontaking_1101="' + COALESCE(CAST(@db_v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
		@ActionID = 424,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v162spositiontaking_1101="' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 424,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperLiveCS_Positiontaking] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_Positiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_Positiontaking] TO [bodbDownlineNet]
