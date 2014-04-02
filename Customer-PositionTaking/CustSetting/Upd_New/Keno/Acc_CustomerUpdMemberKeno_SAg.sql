ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_SAg] 
(
	@CustID INT
	, @SportType TINYINT
	, @BetType INT
	, @SPositionTaking SMALLMONEY = 0 --s1
	, @Auto_SPositionTaking SMALLMONEY = 0 --us1
	, @IsAuto_SPositionTaking BIT = 0 -- is1
	
	, @UpdatePositiontaking BIT = 0
	, @UpdateAutoPositiontaking BIT = 0

	, @SubAccID	INT = 0
	, @IP VARCHAR(50) = ''
	, @UserID INT = 0
	, @Language VARCHAR(20) = 'E'
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT  
)
AS  
/*  
	Created: 20140318@Patrick  
	Task : Super edits Member (Keno)  
	DB: DBTXN/CustDB
	Original: Acc_CustomerUpdSuper_Member  
	Revisions:  
		 
	Param's Explanation:  
	• @ErrCode:  
		<= 0: Update successfully.  
		> 0: Specific Error.  
	    
	• @ErrMsg: Error description.  
*/  
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT, @ErrCode_cur INT, @ErrMsg_cur NVARCHAR(4000), @roleid TINYINT
		, @mrecommend INT, @recommend INT, @srecommend INT, @ErrType VARCHAR(1000), @Username VARCHAR(50)
		, @SPositionTaking_Max SMALLMONEY, @MPositionTaking SMALLMONEY, @APositionTaking SMALLMONEY
		, @Old_SPositionTaking SMALLMONEY, @Old_IsAuto_SPositionTaking SMALLMONEY, @Old_Auto_SPositionTaking SMALLMONEY 
	SELECT @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = '', @startRun = GETDATE()

	--Check downline belongin
	EXEC dbo.Age_CustomerSelCheckBelonging   
		 @SessionCustID = @Userid
		 , @Custid = @custid
		 , @Username = @Username OUTPUT
		 , @roleid = @roleid OUTPUT
	IF (@roleid <> 1) RETURN-- RETURN IF not member  
  
	--Check disable user  
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
			, @ErrCode = @ErrCode_Cur OUTPUT
			, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0  
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		RETURN
	END  
   
    IF (@UpdatePositiontaking = 0 AND @UpdateAutoPositiontaking = 0)
		RETURN

	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username   
	FROM dbo.customer WITH (NOLOCK) WHERE custid = @custid  
  
	SELECT @SPositionTaking_Max = spositiontaking --s4
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
	WHERE custid = @srecommend AND bettype = @BetType AND sporttype = @SportType

	SELECT @MPositionTaking = mpositiontaking, @APositionTaking = apositiontaking
		, @Old_SPositionTaking = spositiontaking, @Old_IsAuto_SPositionTaking = isautopositiontaking, @Old_Auto_SPositionTaking = autopositiontaking
	FROM dbo.CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

	SELECT @ErrType = ''  
	IF (@UpdateAutoPositiontaking = 1)  
	BEGIN
		IF @SPositionTaking < 0
		BEGIN
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong position taking.' ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
				, @ErrCode_Cur = 100
			
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END

		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: ' + CAST(@SPositionTaking_Max AS VARCHAR(10)) 
		WHERE @SPositionTaking > @SPositionTaking_Max
		
		IF @ErrType <> ''
		BEGIN 
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 101
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN	
		END

		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: ' + CAST(@SPositionTaking_Max - @MPositionTaking - @APositionTaking AS VARCHAR(10)) 
		WHERE @SPositionTaking + @MPositionTaking + @APositionTaking > @SPositionTaking_Max
	
		IF @ErrType <> ''
		BEGIN 
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 102
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END
	END
	IF @UpdateAutoPositiontaking = 1
	BEGIN
		SELECT @ErrType = ''
	
		SELECT @ErrType	= @ErrType + 'Max: ' + CAST(@SPositionTaking_Max AS VARCHAR(10)) 
		WHERE @Auto_SPositionTaking > @SPositionTaking_Max
	
		IF @ErrType <> ''
		BEGIN
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong auto position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 201
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END
	END


	IF @UpdatePositiontaking = 1
	BEGIN
		--don't update s1 for member under master was set i3 = 1(normal)
		UPDATE cs WITH (ROWLOCK, UPDLOCK)
		SET cs.spositiontaking = @SPositionTaking
		FROM dbo.CustSettingGame cs
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
			INNER JOIN dbo.CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		WHERE cs.custid = @custid AND cs.bettype = @BetType AND cs.sporttype = @SportType AND mcs.isautopositiontaking = 0

		IF (@@ERROR <> 0)  
		BEGIN  
			SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !' ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END 
				, @ErrCode_Cur = 105  
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)      
			RETURN
		END
	END

	IF @UpdateAutoPositiontaking = 1
	BEGIN
		UPDATE dbo.CustSettingGame WITH (UPDLOCK, ROWLOCK)
		SET isautopositiontaking = @IsAuto_SPositionTaking
			, autopositiontaking = @Auto_SPositionTaking
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
	
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrMsg_Cur =  @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Error updating auto position taking' 
															ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) END
				, @ErrCode_Cur = 202	
		
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END
	END
	
	--Call execrep
	EXEC dbo.Acc_CustSetting3rd_00_xtest
		@custid = @custid
		, @recommend = @recommend
		, @mrecommend = @mrecommend
		, @srecommend = @srecommend
		, @mode = 'Keno'
		, @sporttype = @SportType
		, @BetType = @BetType

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(5000)
		
	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_SAg CustId = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SPositionTaking = "' + COALESCE(CAST(@SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_SPositionTaking = "' + COALESCE(CAST(@IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking ="' + COALESCE(CAST(@Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositiontaking ="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositiontaking ="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_SAg CustId = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SPositionTaking = "' + COALESCE(CAST(@Old_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_SPositionTaking = "' + COALESCE(CAST(@Old_IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_SPositionTaking ="' + COALESCE(CAST(@Old_Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositiontaking ="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositiontaking ="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND, @startRun, @endRun)
	--select * from DBLOG.bodb_CustomerLog.dbo.LogAction where actionid = 447
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 447
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 447
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_SAg] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_SAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_SAg] TO [vnteam] AS [dbo]