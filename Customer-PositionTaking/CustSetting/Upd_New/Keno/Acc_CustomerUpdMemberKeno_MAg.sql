ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_MAg]
(
	@custid INT
	, @SportType INT = 202 
	, @BetType INT

	, @MPositionTaking SMALLMONEY --m1
	, @Auto_MPositionTaking_Mem SMALLMONEY --um1
	, @IsAuto_MPositionTaking_Mem BIT --im1
	, @IsAuto_MPositionTaking BIT --im2

	, @UpdatePositiontaking BIT = 1
	, @UpdateAutoPositiontaking BIT = 1
	
	, @UserId INT
	, @SubAccID	INT = 0 --Sub-AccountID
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(19) = ''
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20140318@Patrick
	Task: Master edit Keno PT setting on member
	DB: DBTXN/CustDB
	Revisions:
	Parameters Explanation:
	• @ErrCode:  
		<= 0: Update successfully.  
		> 0: Specific Error.
*/
BEGIN

	SET NOCOUNT ON 
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT, @ErrType VARCHAR(1000), @roleid TINYINT, @ErrCode_Cur INT
		, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000), @recommend INT, @srecommend INT, @mrecommend INT, @UserName VARCHAR(50)

	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = '', @startRun = GETDATE()

	--Check downline belongin
	EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @mrecommend
														, @Custid = @custid
														, @roleid = @roleid OUTPUT
	IF @roleid = 0 RETURN

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
													, @ErrCode = @ErrCode_Cur OUTPUT
													, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300), @ErrCode_cur) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	
	SELECT @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend 
	FROM dbo.customer WITH (NOLOCK) WHERE custid = @custid

	IF @UpdatePositiontaking = 1 AND (@MPositionTaking < 0 OR @MPositionTaking > 1
												OR @Auto_MPositionTaking_Mem < 0 OR @Auto_MPositionTaking_Mem > 1)
	BEGIN
		SELECT @ErrCode_cur = 5
		SELECT @ErrMsg_cur = @UserName + ': ' +	CASE @Language WHEN 'E' THEN 'Wrong position taking.' ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	
	DECLARE @APositionTaking SMALLMONEY--a1
		, @APositionTaking_Max SMALLMONEY--a2
		, @Old_MPositionTaking SMALLMONEY--old_m1
		, @Old_Auto_MPositionTaking_Mem SMALLMONEY--old_um1
		, @Old_IsAuto_MPositionTaking_Mem BIT--old_im1
		, @SPositionTaking_Max SMALLMONEY--s4
		, @SPositionTaking SMALLMONEY
		, @Auto_SPositionTaking_Mem SMALLMONEY--u1
		, @IsAuto_SPositionTaking_Mem BIT--i1
		, @Auto_SPositionTaking SMALLMONEY--u3
		, @IsAuto_SPositionTaking BIT--i3
		, @Auto_MPositionTaking SMALLMONEY--um2
		, @IsAuto_MPositionTaking_BK bit-- backup to write log

		, @MPositionTaking_Max SMALLMONEY
		, @MPositionTaking_Min SMALLMONEY
	
	--DB adjust value @IsAuto_MPositionTaking
	SELECT @IsAuto_MPositionTaking = isautompositiontaking
	FROM dbo.CustSettingGame WITH (NOLOCK)
	WHERE custid = @recommend AND bettype = @BetType AND sporttype = @SportType

	-- backup
	SELECT @IsAuto_MPositionTaking_BK = @IsAuto_MPositionTaking
	--s1,a1,old_m1,u1,i1
	IF (@UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1)
	BEGIN
		SELECT	@SPositionTaking = spositiontaking --s1
			, @APositionTaking = apositiontaking --a1
			, @Auto_SPositionTaking_Mem = autopositiontaking
			, @IsAuto_SPositionTaking_Mem = isautopositiontaking
			, @Old_MPositionTaking = mpositiontaking
			, @Old_Auto_MPositionTaking_Mem = autompositiontaking
			, @Old_IsAuto_MPositionTaking_Mem = isautompositiontaking
		FROM dbo.CustSettingGame WITH (NOLOCK)
		WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType
	END

	--Check if old_PT = new_PT RETURN
	IF (@MPositionTaking = @Old_MPositionTaking
		AND	@Auto_MPositionTaking_Mem = @Old_Auto_MPositionTaking_Mem
		AND @IsAuto_MPositionTaking_Mem = @Old_IsAuto_MPositionTaking_Mem)
	BEGIN	
		SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		RETURN
	END
	
	IF @UpdateAutoPositiontaking = 1 
	BEGIN
		--Check um1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-' + typenamee + '-Max: '+ CAST(mcs.mpositiontaking AS VARCHAR(10))
		FROM dbo.CustSettingGame AS mcs WITH (NOLOCK) 
			INNER JOIN
			(
				SELECT @SportType AS sporttype, @BetType AS bettype, @Auto_MPositionTaking_Mem AS autopositiontaking
					, @IsAuto_MPositionTaking_Mem AS isautopositiontaking
			) AS b ON mcs.sporttype = b.sporttype AND mcs.bettype = b.bettype
			INNER JOIN bodb02.dbo.sports s WITH (NOLOCK) ON b.sporttype = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
		WHERE mcs.custid = @mrecommend AND b.isautopositiontaking > 0 AND b.autopositiontaking > mcs.mpositiontaking

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7
					, @ErrMsg_cur = @UserName + ': '+ CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) + '<br>' + @ErrType END							
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
	END

	IF (@UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1)
	BEGIN
		--m3,u3,i3
		SELECT @MPositionTaking_Max = mpositiontaking, @Auto_SPositionTaking = autopositiontaking, @IsAuto_SPositionTaking = isautopositiontaking 
		FROM dbo.CustSettingGame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType
		
		--n3
		SELECT @MPositionTaking_Min = minpositiontaking 
		FROM dbo.CustOverrideGame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType

		--s4
		SELECT @SPositionTaking_Max = spositiontaking 
		FROM dbo.CustSettingGame WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype = @BetType AND sporttype = @SportType
	END

	--um2
	SELECT @Auto_MPositionTaking = MAX(acs.autompositiontaking), @APositionTaking_Max = MAX(acs.apositiontaking) --a2
	FROM dbo.CustSettingGame acs WITH(NOLOCK)
	WHERE acs.custid = @recommend AND acs.bettype = @BetType AND acs.sporttype = @SportType
			
	IF (@UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1)
	BEGIN	
		--Check m1<= max(0, min(m3,m4)-a1)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))
		FROM 
		(
			SELECT @SportType AS sporttype, @BetType AS bettype, @MPositionTaking AS mpositiontaking
				, @MPositionTaking_Max AS maxmpositiontaking, @APositionTaking AS apositiontaking
		)b
			INNER JOIN bodb02.dbo.sports s WITH (NOLOCK) ON b.sporttype = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
		WHERE b.mpositiontaking > b.maxmpositiontaking - b.apositiontaking

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrCode_cur = 8, @ErrMsg_cur = @UserName + ': '+ CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END							
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
				
		--Check m1+a1>=n3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Min: ' + CAST(@MPositionTaking_Min AS VARCHAR(10))  
		WHERE @APositionTaking + @MPositionTaking < @MPositionTaking_Min
		
		IF @ErrType <> ''
		BEGIN
			SELECT @ErrCode_cur = 9, @ErrMsg_cur = CASE @Language
						WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType 
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT @MPositionTaking = CASE WHEN @APositionTaking + @MPositionTaking > @MPositionTaking_Max 
									THEN @MPositionTaking_Max - @APositionTaking ELSE @MPositionTaking END
		SELECT @MPositionTaking = CASE WHEN @MPositionTaking < 0 THEN 0 ELSE @MPositionTaking END
			
		--Must include code for auto master
			--++um=im1>0?um1:um2
			--++im=im1>0?im1:im2
			--++m1=im>0?min(um,m3-a1):m1
			--++auto master
			--++um=im1>0?um1:um2
		SELECT @Auto_MPositionTaking = CASE WHEN @IsAuto_MPositionTaking_Mem > 0 THEN @Auto_MPositionTaking_Mem ELSE @Auto_MPositionTaking END
			--im=im1>0?im1:im31
			, @IsAuto_MPositionTaking = CASE WHEN @IsAuto_MPositionTaking_Mem > 0 THEN @IsAuto_MPositionTaking_Mem ELSE @IsAuto_MPositionTaking END

		--Use auto position taking
		--m1=im>0?min(um,m3-a1):m1
		SELECT @MPositionTaking = CASE WHEN ISNULL(@IsAuto_MPositionTaking, 0) <= 0 
				THEN @MPositionTaking 
				ELSE CASE WHEN @Auto_MPositionTaking < @MPositionTaking_Max - @APositionTaking 
					THEN @Auto_MPositionTaking 
					ELSE @MPositionTaking_Max - @APositionTaking END 
				END
		--Choose member autopositiontaking if member is set auto (regardless of the setting in master account)
		SELECT @Auto_SPositionTaking = CASE WHEN @IsAuto_SPositionTaking_Mem > 0 THEN @Auto_SPositionTaking_Mem ELSE @Auto_SPositionTaking END
			, @IsAuto_SPositionTaking = CASE WHEN @IsAuto_SPositionTaking_Mem > 0 THEN @IsAuto_SPositionTaking_Mem ELSE @IsAuto_SPositionTaking END		

		--Use auto position taking
		SELECT @SPositionTaking = CASE WHEN ISNULL(@IsAuto_SPositionTaking, 0) < = 0 
				THEN @SPositionTaking 
				ELSE CASE WHEN @Auto_SPositionTaking < @SPositionTaking_Max - @MPositionTaking - @APositionTaking 
					THEN @Auto_SPositionTaking 
					ELSE @SPositionTaking_Max - @MPositionTaking - @APositionTaking END
				END
		
		----max_s1=isauto?s4:s4-m2
		SELECT @SPositionTaking_Max = CASE WHEN ISNULL(@IsAuto_SPositionTaking, 0) > 0 
				THEN @SPositionTaking_Max 
				ELSE @SPositionTaking_Max - @MPositionTaking_Max END
			--s1=s1>maxs1?maxs1:s1
			, @SPositionTaking = CASE WHEN @SPositionTaking > @SPositionTaking_Max THEN @SPositionTaking_Max ELSE @SPositionTaking END
	END

	--don't update m1,s1 for member under agent was set im2=1
	UPDATE cs WITH (ROWLOCK, UPDLOCK)
	SET mpositiontaking = @MPositionTaking, spositiontaking = @SPositionTaking
	FROM dbo.CustSettingGame cs
		INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
		INNER JOIN dbo.CustSettingGame acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.bettype = acs.bettype AND cs.sporttype = acs.sporttype 
	WHERE c.custid = @custid AND cs.BetType = @BetType  AND cs.sporttype = @SportType AND c.roleid = 1 AND acs.isautompositiontaking = 0
		
	--Update auto PT
	--Update Member account (autompositiontaking field)
	UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK) 
	SET autompositiontaking =  b.autompositiontaking, 
		isautompositiontaking = b.isautompositiontaking 
	FROM dbo.CustSettingGame AS cs
		INNER JOIN 
		(
			SELECT @BetType AS bettype, @SportType AS sporttype, @Auto_MPositionTaking_Mem AS autompositiontaking
				, @IsAuto_MPositionTaking_Mem AS isautompositiontaking
		) AS b ON b.bettype = cs.bettype AND b.sporttype = cs.sporttype
	WHERE cs.custid = @custid

	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrCode_cur = 101, @ErrMsg_cur =  CASE @Language 
							WHEN 'E' THEN 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010, @Language) END	
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	
	DECLARE @maxpos SMALLMONEY
	IF @IsAuto_MPositionTaking > 0
	BEGIN
		SELECT @maxpos = mpositiontaking 
		FROM dbo.CustSettingGame WITH (NOLOCK)
		WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType

		UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK) 
		SET mpositiontaking = CASE WHEN @maxpos - apositiontaking > @Auto_MPositionTaking THEN @Auto_MPositionTaking ELSE @maxpos - apositiontaking END
		FROM dbo.CustSettingGame AS cs
		WHERE custid = @custid AND cs.bettype = @BetType AND cs.sporttype = @SportType

		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode_cur = 110, @ErrMsg_cur = CASE @Language WHEN 'E' 
								THEN 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99, @Language) + ')' END
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
	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MAg CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_BK="' + COALESCE(CAST(@IsAuto_MPositionTaking_BK AS VARCHAR(50)),SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_Mem="' + COALESCE(CAST(@IsAuto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_MPositionTaking_Mem="' + COALESCE(CAST(@Auto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />' 

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_MAg CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPositionTaking="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_BK="' + COALESCE(CAST(@IsAuto_MPositionTaking_BK AS VARCHAR(50)),SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_Mem="' + COALESCE(CAST(@Old_IsAuto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Auto_MPositionTaking_Mem="' + COALESCE(CAST(@Old_Auto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />' 
	
	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 446
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 446
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_MAg] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_MAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_MAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_MAg] TO [vnteam] AS [dbo]