ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableKeno] @CustID INT
	,@Bettype INT
	,@Disable BIT			
	,@DisableDownLines BIT = 1

	,@SubAccID INT = 0
	,@UserID INT
	,@Language VARCHAR(2) = 'E'
	,@Errcode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
	,@IP VARCHAR(15) = ''
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Update Keno status for customer
	DB: DBTXN/CustDB
	Original: 
	Revisions:
		20140227@Bobby: Implement upd disabled keno gaming for customer

	Param's Explanation:
		• @custid: customer id.   
		• @Disable: status of HideKeno
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = GETDATE()

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	IF (@ErrCode <> 0) RETURN

	--end
	DECLARE @RoleID TINYINT
		,@UplineHideKeno BIT = 0
		,@Old_HideKeno BIT
		,@HideKeno BIT;

	SET @HideKeno = @Disable;

	SELECT @RoleID = RoleID
		, @Old_HideKeno = ISNULL(HideKeno, 0)
	FROM dbo.CustInfo WITH (NOLOCK)
	WHERE CustID = @CustID

	IF (@RoleID NOT IN (1, 2, 3, 4))
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Invalid user!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)
				END
			,@ErrCode = 100

		RETURN
	END

	IF (@Old_HideKeno = @HideKeno) RETURN --no need to update

	IF (@HideKeno = 0) -- check status upline
	BEGIN
		IF (@RoleID = 4) -- super
			SET @UplineHideKeno = 0 --not checking the upline when the customer is the super
		ELSE
		BEGIN
			SELECT @UplineHideKeno = ISNULL(HideKeno, 0)
			FROM dbo.CustInfo WITH (NOLOCK)
			WHERE custid = (
					SELECT CASE @RoleID
						WHEN 3 THEN SRecommend	-- master
						WHEN 2 THEN MRecommend	-- agent
						WHEN 1 THEN Recommend	-- member
					END
					FROM dbo.Custinfo WITH (NOLOCK)
					WHERE custid = @CustID
						AND roleid = @RoleID
					)
		END

		IF @UplineHideKeno = 1
		BEGIN
			SELECT @ErrMsg = CASE @Language
					WHEN 'E' THEN 'Account disabled for Keno. Unable to edit downlines.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](60015, @Language)
					END
				,@ErrCode = 105

			RETURN
		END
	END

	--Update Keno status
	UPDATE CustInfo WITH (ROWLOCK, UPDLOCK)
	SET HideKeno = @HideKeno
	WHERE CustID = @CustID

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Update process is unsuccessful.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			,@ErrCode = 101

		RETURN
	END

	--Check condition for update all downline
	IF (
			@HideKeno = 1
			OR (
				@HideKeno = 0
				AND @DisableDownlines = 0
				)
			)
	BEGIN
		EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid = @custid
			,@roleid = @roleid
			,@isExecRep = 1
			,@Language = @Language
			,@ErrMsg = @ErrMsg OUTPUT
			,@ErrCode = @ErrCode OUTPUT

		IF @ErrCode <> 0 RETURN

		--Disable all downline or enable all downline
		BEGIN TRY
			EXEC [Acc_ExecRep_Cust_04] @CustID = @CustID
				,@RoleID = @RoleID
				,@Action = 'UpdKenoStatus'
				,@KenoStatus = @HideKeno
		END TRY
		BEGIN CATCH
			SELECT @ErrMsg = CASE @Language
					WHEN 'E' THEN 'Update process is unsuccessful.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
					END

			IF @RoleID = 4
				SELECT @ErrCode = 102
			ELSE IF @RoleID = 3
				SELECT @ErrCode = 103
			ELSE IF @RoleID = 2
				SELECT @ErrCode = 104

			RETURN
		END CATCH
	END
	
	-- write runSP log
	DECLARE @LogSPData VARCHAR(2000)

	SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' + 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' + 'DisableDownlines="' + coalesce(cast(@DisableDownlines AS VARCHAR(50)), space(1)) + '" ' + 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' + 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' + 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' + 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' + 'ErrMsg="' + coalesce(cast(@ErrMsg AS VARCHAR(400)), space(1)) + '" ' + 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(millisecond, @startRun, @endRun)

	/*1148	Acc_CustomerUpdDisableKeno	Update Enabled/Disabled Keno status*/
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 1148
			,@TrackingValue = @LogSPData
			,@duration = @duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdDisableKeno CustID="' + coalesce(cast(@CustID AS VARCHAR(50)), space(1)) + '" ' + 'Disable="' + coalesce(cast(@Disable AS VARCHAR(50)), space(1)) + '" ' + 'DisableDownlines="' + coalesce(cast(@DisableDownlines AS VARCHAR(50)), space(1)) + '" ' + 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' + 'UserID="' + coalesce(cast(@UserID AS VARCHAR(50)), space(1)) + '" ' + 'Language="' + coalesce(cast(@Language AS VARCHAR(2)), space(1)) + '" ' + 'ErrCode="' + coalesce(cast(@ErrCode AS VARCHAR(50)), space(1)) + '" ' + 'ErrMsg="' + ERROR_MESSAGE() + '" ' + 'IP="' + coalesce(cast(@IP AS VARCHAR(15)), space(1)) + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 1148
			,@TrackingValue = @LogSPData
			,@duration = @duration
	END CATCH

	RETURN
END
GO
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableKeno] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdDisableKeno] TO [bodbDownlineNet] AS [dbo]