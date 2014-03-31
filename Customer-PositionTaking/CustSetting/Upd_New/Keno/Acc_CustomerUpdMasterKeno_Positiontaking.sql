ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking]
(
	@CustId INT
	, @SportType INT = 202
	, @BetType INT

	, @SPositionTaking SMALLMONEY --s3
	, @Auto_SPositionTaking SMALLMONEY --us3
	, @IsAuto_SPositionTaking BIT = 0 --is3
	, @MPositionTaking SMALLMONEY --m3
	, @MPositiontaking_Min SMALLMONEY --n3
	
	, @UpdateAllMembers	BIT = 0
	, @NewSPositionTaking SMALLMONEY = 0 --s1
	
	, @UpdatePositionTaking BIT = 0
	, @UpdateAutoPositionTaking	BIT = 0
	, @UpdateMinPositionTaking	BIT = 0
	
	, @SubAccID INT = 0 --Sub-AccountID		
	, @UserID	INT = 0
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(15) = ''
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140326@Patrick
	Task: Super/Admin edit positiontaking on master
	DB: DBTXN/CustDB
		
	Revisions:

	Parameters Explanation:
		@ErrCode is 0 update successful
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
		, @UserName NVARCHAR(50), @mrecommend INT, @srecommend INT, @roleid TINYINT
		, @ErrAcc VARCHAR(4000), @ErrType VARCHAR(4000)

	SELECT @ErrCode = 0, @ErrMsg = '', @ErrAcc = '', @ErrType = '', @startRun = GETDATE()
	
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid = @custid
		, @roleid = 3
		, @isExecRep = 1
		, @isUpdatePT = 1
		, @Sporttype = 1
		, @Language = 'E'
		, @ErrMsg = @ErrMsg OUTPUT
		, @ErrCode = @ErrCode OUTPUT
	IF	@ErrCode <> 0 
		RETURN 
	
	DECLARE @Old_SPositionTaking SMALLMONEY, @Old_MPositionTaking SMALLMONEY,
		@Old_IsAuto_SPositionTaking BIT, @Old_Auto_SPositionTaking SMALLMONEY
	
	SELECT @Old_SPositionTaking = spositiontaking
		, @Old_MPositionTaking = mpositiontaking
		, @Old_IsAuto_SPositionTaking = isautopositiontaking
		, @Old_Auto_SPositionTaking = autopositiontaking
	FROM dbo.CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

	SELECT @username = username , @srecommend = srecommend
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @custid

	--check if not change value
	IF(@Old_SPositionTaking = @SPositionTaking
		AND @Old_MPositionTaking = @MPositionTaking
		AND @Old_IsAuto_SPositionTaking = @IsAuto_SPositionTaking
		AND @Old_Auto_SPositionTaking = @Auto_SPositionTaking)
		RETURN

	IF (@SPositionTaking < 0 OR @MPositionTaking < 0
		OR @SPositionTaking + @MPositionTaking > 1
		OR @Auto_SPositionTaking < 0 OR @Auto_SPositionTaking > 1)
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
			, @ErrCode = 100
		RETURN
	END

	SELECT @ErrType = ''
	--check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
	--m3<=s4 and u3+m3>=n4 if i3 = 1
	SELECT @ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.bettype = co.bettype AND cs.sporttype = co.sporttype 
	WHERE cs.custid = @srecommend 
		AND cs.bettype = @BetType
		AND cs.sporttype = @SportType
		AND ((@IsAuto_SPositionTaking > 0 
				AND (@MPositionTaking + @Auto_SPositionTaking < co.minpositiontaking 
					OR @MPositionTaking > cs.spositiontaking))
			OR (@IsAuto_SPositionTaking = 0 
				AND (@SPositionTaking + @MPositionTaking < co.minpositiontaking 
					OR @SPositionTaking + @MPositionTaking > cs.spositiontaking 
					OR @SPositionTaking > cs.spositiontaking)))

	IF @ErrType <> ''
	BEGIN	
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType END
				, @ErrCode = 101
		RETURN
	END

	--a2+m2<=m3
	SELECT @ErrAcc = ''
	SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid = 2
		 AND cs.bettype = @BetType AND cs.sporttype = @SportType
		AND cs.mpositiontaking + cs.apositiontaking > @MPositionTaking

	IF @ErrAcc <> ''
	BEGIN		
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ') .'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').' END
			, @ErrCode = 102
		RETURN
	END

	--a1+m1<=m3
	SELECT @ErrAcc = ''
	SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid = 1
		AND cs.bettype = @BetType AND cs.sporttype = @SportType
		AND cs.mpositiontaking + cs.apositiontaking > @MPositionTaking 

	IF @ErrAcc <> ''
	BEGIN	
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' ('+@ErrAcc+').' END
			, @ErrCode = 103
		RETURN
	END

	--m3>=u2
	SELECT @ErrAcc = ''
	SELECT TOP 100 @ErrAcc = @ErrAcc + Username + ', '
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid = 2
		AND cs.bettype = @BetType AND cs.sporttype = @SportType
		AND cs.isautompositiontaking = 1 AND cs.autompositiontaking > @MPositionTaking

	IF @ErrAcc <> ''
	BEGIN		
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ').' END
			, @ErrCode = 104
		RETURN
	END	

	--check u3<=s4
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + 'Max: ' + CAST (cs.spositiontaking AS VARCHAR(10)) + '<br>'
	FROM dbo.CustSettingGame cs WITH(NOLOCK)		
	WHERE custid = @srecommend
		AND cs.bettype = @BetType AND cs.sporttype = @SportType
		AND @Auto_SPositionTaking > spositiontaking 

	IF @ErrType <> ''	
	BEGIN
		SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
								WHEN 'E' THEN 'Wrong auto position taking.<br>' + @ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) + '<br>' + @ErrType END
			, @ErrCode = 105
		RETURN
	END

	IF @UpdatePositionTaking = 1
	BEGIN
		UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
		SET spositiontaking = @SPositionTaking, mpositiontaking = @MPositionTaking
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType 

		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 106				 
			RETURN
		END
	END

	IF @UpdateAutoPositionTaking = 1
	BEGIN
		--Update Master Agent account (autopositiontaking field)
		UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
		SET autopositiontaking = @Auto_SPositionTaking, isautopositiontaking = @IsAuto_SPositionTaking
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType 
	
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Error updating auto position taking'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) END	
				,  @ErrCode = 201
			RETURN
		END
	
		EXEC dbo.Acc_CustSetting3rd_05_xtest
			@srecommend = @srecommend
			, @mrecommend = @custid
			, @roleid = 3
			, @mode = 'Keno'

			, @IsAuto_KenoSPositionTaking = @IsAuto_SPositionTaking
			, @Old_IsAuto_KenoSPositionTaking = @Old_IsAuto_SPositionTaking
			, @Auto_KenoSPositionTaking = @Auto_SPositionTaking
		
			, @Updateallmembers = @Updateallmembers
			, @newspositiontaking = @NewSPositionTaking
			, @KenoBetType = @BetType
	END

	IF @UpdateAutoPositionTaking = 1 OR @UpdatePositionTaking = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_07_xtest 
			@srecommend = @srecommend,
			@mrecommend = @custid,
			@roleid = 3,
			@mode = 'Keno'
		
		IF (@@ERROR <> 0)
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+ CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END
				, @ErrCode = 107			 
			RETURN
		END
	END
	
	--SELECT @ErrCode = -103

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)
	SELECT @LogSPData = '<Acc_CustomerUpdMasterKeno_Positiontaking CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SPositionTaking="' + COALESCE(CAST(@SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking="' + COALESCE(CAST(@IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking="' + COALESCE(CAST(@Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST (@UpdateAllMembers AS VARCHAR(3)), SPACE(1))
		+ '" ' + 'NewSPositionTaking="' + COALESCE(CAST (@NewSPositionTaking AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserId="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterKeno_Positiontaking CustId ="' + COALESCE(CAST(@CustId AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SPositionTaking="' + COALESCE(CAST(@Old_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking="' + COALESCE(CAST(@Old_IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking="' + COALESCE(CAST(@Old_Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdateAllMembers="' + COALESCE(CAST (@UpdateAllMembers AS VARCHAR(3)), SPACE(1))
		+ '" ' + 'NewSPositionTaking="' + COALESCE(CAST (@NewSPositionTaking AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserId="' + COALESCE(CAST(@userid AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)
	--Log customer info 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 443,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 443,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterKeno_Positiontaking] TO [vnteam] AS [dbo]