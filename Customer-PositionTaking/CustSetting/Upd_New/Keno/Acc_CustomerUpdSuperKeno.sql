ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno]
	@custid INT,-- superid	
	@sporttype INT = 202,
	@bettype INT,
	
	@spositiontaking SMALLMONEY, --s4
	@Min_Positiontaking SMALLMONEY, --n4
	@Discount DECIMAL(9,8)=0,
			
	@UpdatePositiontaking	BIT = 0,
	@UpdateMinPositiontaking	BIT = 0,
	@UpdateCommission BIT = 0,
	
	@UserID INT = 0,	
	@Language varchar(2) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode VARCHAR(300)  = '' OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140225@Elodie
	Task : Update Keno's Super PT 
	DB: DBTXN/CustDB
	Revisions:
				
	Param's Explanation:
	• @ErrCode:
		= 0: Transaction recorded successfully.
		> 0: Specific Error.
	  
	• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
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
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	--end

	--check n4<=s4
	IF @spositiontaking < @Min_Positiontaking
	BEGIN 
		Select @ErrMsg = 
					case @Language 
							when 'E' then 'Wrong position taking .<br>'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
					end, @ErrCode = 100
		return	
	END

	IF @UpdateCommission = 1
	BEGIN		
		EXEC Acc_CustomerUpdSuperKeno_Commission @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @discount = @discount, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg = @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END


	IF @UpdatePositiontaking = 1
	BEGIN
		EXEC Acc_CustomerUpdSuperKeno_Positiontaking @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @spositiontaking = @spositiontaking, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT, @ErrMsg	= @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END

	IF @UpdateMinPositiontaking = 1
	BEGIN
		EXEC Acc_CustOverrideUpdKeno @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @Min_Positiontaking = @Min_Positiontaking, @IP = @IP ,@UserID = @userid, @Language = @Language, @ErrCode	= @ErrCode_Cur OUTPUT, @ErrMsg	= @ErrMsg_Cur OUTPUT
	
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN	
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)		
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperKeno] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperKeno] TO [vnteam] AS [dbo]