ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking]
	@custid INT,-- superid	
	@sporttype INT = 202,
	@bettype INT,
	
	@spositiontaking SMALLMONEY, --s4
		
	@UserID INT = 0,	
	@Language varchar(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT  = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140225@Elodie
	Task : Update Keno's Super PT 
	DB: DBTXN/CustDB
	Revisions:
				
	Param's Explanation:
	• @ErrCode is:
			= 0: Transaction recorded successfully.
			> 0: Specific Error.
	  
	• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT

	SET @startRun = GETDATE()

	DECLARE @roleid TINYINT

	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN
	---------------------------

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode <> 0
		RETURN
	--end

	---- Checking total downlines before UPDATEs 
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	
		@custid=@custid,
		@roleid=4,
		@isExecRep=1,
		@isUpdatePT = 1,
		@Sporttype = 1,
		@Language='E',
		@ErrMsg=@ErrMsg output,
		@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 

	DECLARE @old_spositiontaking SMALLMONEY

	SELECT @old_spositiontaking = spositiontaking 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE Custid = @custid AND sporttype = @sporttype AND bettype = @bettype

	--check if not change value
	IF @old_spositiontaking = @spositiontaking
		RETURN

	Declare @ErrAcc nvarchar(4000)
	--check all s3+m3<=s4 if i3 = 0,
	--m3<=s4 and u3<=s4 if i3=1
	SELECT @ErrAcc = ''

	SELECT TOP 100 @ErrAcc = @ErrAcc + ci.username + ', '
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN custinfo ci WITH(NOLOCK) ON ci.custid = cs.custid 
	WHERE ci.srecommend = @custid AND ci.roleid = 3
		AND cs.sporttype = @sporttype AND bettype = @bettype
		AND ((cs.isautopositiontaking = 0 AND cs.spositiontaking + cs.mpositiontaking > @spositiontaking)
			OR (cs.isautopositiontaking = 1 AND (cs.mpositiontaking > @spositiontaking OR cs.autopositiontaking > @spositiontaking)))
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
		AND cs.sporttype = @sporttype AND bettype = @bettype
		AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > @spositiontaking
			OR (cs.isautopositiontaking = 1 AND cs.autopositiontaking > @spositiontaking))

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
	SET spositiontaking = @spositiontaking
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype

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
	EXEC dbo.Acc_CustSetting3rd_07_xtest @srecommend = @custid , @roleid = 4, @mode = 'Keno', @sporttype = @sporttype, @bettype = @bettype
	
	Declare @LogSPData varchar(MAX),
			@TrackingValueDB varchar(4000)
	 
	SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'spositiontaking="' + COALESCE(CAST(@spositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
	'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


	SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
	'spositiontaking="' + COALESCE(CAST(@old_spositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
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
			@ActionID = 442,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdSuperKeno_Positiontaking Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'spositiontaking="' + COALESCE(CAST(@spositiontaking AS VARCHAR(50)),SPACE(1)) + '" ' +
		'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 442,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking]  TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno_Positiontaking] TO [vnteam] AS [dbo]
