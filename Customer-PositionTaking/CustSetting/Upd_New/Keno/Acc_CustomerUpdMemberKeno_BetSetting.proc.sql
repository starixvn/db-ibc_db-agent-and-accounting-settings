ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] 
	@custid INT
	,@bettype		INT
	
	,@Disable BIT = NULL

	--min/max/maxpermatch
	,@MinBet MONEY
	,@MaxBet MONEY
	,@MaxPerMatch MONEY
	,@IsUpdateMinMaxBet BIT = 0

	--pt setting
	,@aPositiontaking SMALLMONEY = NULL

	--commision
	,@discount DECIMAL(9, 8) = NULL

	,@SubAccID INT = 0
	,@IP VARCHAR(50) = ''
	,@UserID INT = 0
	,@Language VARCHAR(20) = 'E'
	,@ErrCode VARCHAR(300) = '' OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: Bobby
	Date: 17Jan2012
	Task: Admin/Agent update setting keno on member
	DB: DBTXN/BODB02
		
	Revisions:
		
	Parameters Explanation:
		+@Disable: Status of bettype (0: enable,1: disable, NULL:nothing)
		+@IsUpdateMinMaxBet: check to update min/max (0:nothing, 1:update)
		+@aPositiontaking: check to update PT (NULL:nothing, else:update)
		+@discount: check to upate commision (NULL:nothing, else:update)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @roleid TINYINT
		,@ErrCode_Cur INT
		,@ErrMsg_Cur NVARCHAR(4000)
		,@ErrAcc NVARCHAR(4000)

	SELECT @ErrCode_Cur = 0
		,@ErrMsg_Cur = ''
		,@ErrCode = ''
		,@ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelonging @SessionCustID = @Userid
		,@Custid = @custid
		,@roleid = @roleid OUTPUT

	IF (@roleid = 0) RETURN

	---------------------------
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode_Cur OUTPUT
		,@ErrMsg = @ErrMsg_Cur OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
			,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

		RETURN
	END

	--update status
	IF(@Disable IS NOT NULL)
	BEGIN
		EXEC [Acc_CustomerUpdDisableKeno] 
			@CustID = @custid
			,@Bettype = @bettype
			,@Disable = @Disable			
			,@DisableDownLines = 0
			,@SubAccID = @SubAccID
			,@UserID = @UserID
			,@Language = @Language
			,@IP = @IP
			,@Errcode = @ErrCode_Cur OUTPUT
			,@ErrMsg  = @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END

	--update min/max/maxpermatch
	IF(@IsUpdateMinMaxBet = 1)
	BEGIN
		EXEC [Acc_CustomerUpdMemberKeno_MinMaxBet] 
			@custid = @custid
			,@bettype = @bettype

			,@MinBet	= @MinBet
			,@MaxBet	= @MaxBet
			,@MaxPerMatch = @MaxPerMatch

			,@SubAccID = @SubAccID
			,@IP = @IP
			,@UserID = @UserID
			,@IsValidated = 1
			,@Language = @Language
			,@ErrCode = @ErrCode_Cur OUTPUT
			,@ErrMsg = @ErrMsg_Cur OUTPUT

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END

	--update PT
	IF(@aPositiontaking IS NOT NULL)
	BEGIN
		EXEC [Acc_CustomerUpdMemberKeno_Positiontaking]
			@custid = @custid
			,@bettype = @bettype

			,@apositiontaking	= @apositiontaking

			,@SubAccID = @SubAccID
			,@IP = @IP
			,@UserID = @UserID
			,@Language = @Language
			,@ErrCode = @ErrCode_Cur OUTPUT
			,@ErrMsg = @ErrMsg_Cur OUTPUT
			,@IsValidated = 1
	
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END
	--Update commision
	IF(@discount IS NOT NULL)
	BEGIN
		EXEC [Acc_CustomerUpdMemberKeno_Commission]
			@custid = @custid
			,@bettype = @bettype

			,@discount	= @discount

			,@SubAccID = @SubAccID
			,@IP = @IP
			,@UserID = @UserID
			,@Language = @Language
			,@ErrCode = @ErrCode_Cur OUTPUT
			,@ErrMsg = @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-104' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END
	RETURN
END
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberKeno_BetSetting] TO [vnteam] AS [dbo]
GO