ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_BetSetting]
	@CustId INT,
	@Sporttype INT = 202,
	@Bettype INT,

	@UpdateStatus BIT = 0,
	@Disable BIT = 1,
	@DisableDownLines BIT = 1,

	
	@UpdateMinMaxBet BIT = 0,
	@MinBet			MONEY,
	@MaxBet			MONEY,
	@MaxPerMatch	MONEY,
	
	@UserId INT = 0,
	@SubAccID INT = 0,
	@Ip VARCHAR(50) = '',
	@Language VARCHAR(20) = 'E',
	@ErrCode VARCHAR(300) = '' OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Company updates Keno bet setting on super
	DB: DBTXN/CustDB

	Revisions:

	Parameters Explanation:
		+ @ErrCode <0 : update successfully 
			-100: status
			-101: Min max bet			
		  @ErrCode > 0 : update not successfully
	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	---------------------------

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		RETURN
	END
	--end

	--Update status
	IF @UpdateStatus = 1
	BEGIN								
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''		
		EXEC dbo.Acc_CustomerUpdDisableKeno
			@custid					= @custid, 
			@Bettype				= @Bettype,
			@Disable				= @Disable,
			@DisableDownlines		= @DisableDownlines,

			@UserID					= @UserID, 			
			@SubAccID				= @SubAccID,
			@Language				= @Language, 
			@ErrCode				= @ErrCode_Cur output, 
			@ErrMsg					= @ErrMsg_Cur output, 
			@IP						= @IP
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			--return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-100'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END

	IF @UpdateMinMaxBet = 1
	BEGIN
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		DECLARE @VarErrorCode VARCHAR(200) = ''
		EXEC Acc_CustomerUpdSuperKeno_MinMaxBet
			@CustID = @CustID,
			@Sporttype = @Sporttype,
			@Bettype = @Bettype,

			@MinBet = @MinBet,
			@MaxBet = @MaxBet,
			@MaxPerMatch = @MaxPerMatch,

			@UserID = @UserID,
			@Language = @Language,
			@IP = @IP,
			@ErrCode = @VarErrorCode OUTPUT, 
			@ErrMsg	= @ErrMsg_Cur OUTPUT
		
		IF @VarErrorCode <= '0' --> success
		BEGIN
			Select @ErrCode = @ErrCode + '-101' + char(7), @ErrMsg = @ErrMsg + char(7)
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
	END
		
END 


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_BetSetting] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno_BetSetting] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno_BetSetting] TO [vnteam] AS [dbo]
