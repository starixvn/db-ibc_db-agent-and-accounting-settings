

ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_All]	
	@custid								INT,
	@mrecommend							INT,
	@v162mpositiontaking_1101			SMALLMONEY,
	@auto_v162mpositiontaking_1101		SMALLMONEY,
	@isauto_v162mpositiontaking_1101	BIT,

	@v162apositiontaking_1101			SMALLMONEY,
	@min_v162apositiontaking_1101		SMALLMONEY,
	@v162discount_1101					SMALLMONEY,	
	
	@v162UpdatePositiontaking_1101		BIT = 1,
	@v162UpdateAutoPositiontaking_1101  BIT = 1,
	@v162UpdateMinPositiontaking_1101	BIT = 1,
	@v162UpdateCommission_1101			BIT = 1,
	
	@updateallmembers					BIT = 0,
	@newmpositiontaking					SMALLMONEY = 0,--equals max(m+a) - chosen(a)

	@userid								INT,
	@SubAccID							INT = 0, --Sub-AccountID
	@Language							VARCHAR(2) = 'E',
	@IP									VARCHAR(19),	
	@ErrCode							VARCHAR(300) = '' OUTPUT,
	@ErrMsg								NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20111227@Lukas
	Task: master edit live casino PT setting on agent
	DB: DBTXN/BODB02
	
	Revisions:
		-20120405@Johnson: Check m2,n2 if not synchronized
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
		- 20130301@Johnson: change linked server DB053 to DBAGE
	Parameters Explanation:
*/
BEGIN

	SET NOCOUNT ON 

	DECLARE @roleid			TINYINT, 
			@SyncLiveCasino BIT,
			@ErrCode_Cur	INT, 
			@ErrMsg_Cur		NVARCHAR(4000), 
			@ErrAcc			NVARCHAR(4000)
			
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID = @mrecommend, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF @roleid = 0 RETURN
	---------------------------

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END



	--update commission
	IF @v162UpdateCommission_1101 = 1
	BEGIN

		EXEC dbo.Acc_CustomerUpdAgentLiveCS_Commission
					@custid				= @custid,
					@v162discount_1101	= @v162discount_1101,
					@UserID				= @UserID, 
					@SubAccID			= @SubAccID,
					@Language			= @Language, 
					@IP					= @IP,  
					@ErrCode			= @ErrCode_Cur OUTPUT, 
					@ErrMsg				= @ErrMsg_Cur OUTPUT


		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			
			RETURN
		END
		ELSE
		BEGIN 
		 	SELECT	@ErrCode =  @ErrCode + '-101' + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

		END
	END
	
	SELECT @SyncLiveCasino = SyncLiveCasino
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
		

	--check min/max pt set by company if not synchronize
	IF @SyncLiveCasino = 0
	BEGIN
		--check n3<=m2+a2  if im2 = 0, 
		--a2<=l3 and um2+a2>=n3 if im2 = 1
		SELECT @ErrMsg_Cur = ''
		SELECT @ErrMsg_Cur = @ErrMsg_Cur + '-Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10))+ '<br>'
		FROM custoverrideGame co WITH(NOLOCK)
			INNER JOIN 
				(
					SELECT 1101 AS bettype, 162 AS sporttype, @v162apositiontaking_1101 AS apositiontaking, @v162mpositiontaking_1101 AS mpositiontaking, @isauto_v162mpositiontaking_1101 AS isauto_mpositiontaking, @auto_v162mpositiontaking_1101 AS auto_mpositiontaking
				) b ON co.sporttype = b.sporttype AND co.bettype = b.bettype			
		WHERE co.custid = @mrecommend AND (	
							((b.isauto_mpositiontaking = 0) AND (b.mpositiontaking + b.apositiontaking < co.minpositiontaking)) or 
							(b.isauto_mpositiontaking > 0 AND (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking))
						)
		IF @ErrMsg_Cur <>''
		BEGIN
			SELECT @ErrCode_Cur = 100
			
			SELECT @ErrMsg = @ErrMsg + CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrMsg_Cur
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrMsg_Cur
						END + CHAR(7),
				@ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7)
			RETURN
		END
	END
		
	IF @v162UpdateMinPositiontaking_1101 = 1 
	BEGIN
		EXEC Acc_CustOverrideUpdLiveCS 
				@custid						= @custid, 
				@UplineID					= @mrecommend,
				@min_v162positiontaking_1101= @min_v162apositiontaking_1101, 
				@IP							= @IP, 
				@UserID						= @UserID, 
				@SubAccID					= @SubAccID,
				@Language					= @Language, 
				@ErrCode					= @ErrCode, 
				@ErrMsg						= @ErrMsg

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			
			RETURN
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END

	-- update positiontaking
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

		EXEC dbo.Acc_CustomerUpdAgentLiveCS_PositionTaking 
					@custid								= @custid,
					
					@v162mpositiontaking_1101			= @v162mpositiontaking_1101,
					@auto_v162mpositiontaking_1101		= @auto_v162mpositiontaking_1101,
					@isauto_v162mpositiontaking_1101	= @isauto_v162mpositiontaking_1101,
					@v162apositiontaking_1101			= @v162apositiontaking_1101,
					@min_v162apositiontaking_1101		= @min_v162apositiontaking_1101,					
					@updateallmembers					= @updateallmembers,
					@newmpositiontaking					= @newmpositiontaking,
					
					@v162UpdatePositiontaking_1101		= @v162UpdatePositiontaking_1101,
					@v162UpdateAutoPositiontaking_1101	= @v162UpdateAutoPositiontaking_1101,
					
					@SubAccID							= @SubAccID,
					@UserID								= @UserID,
					@Language							= @Language,
					@IP									= @IP,
					@ErrCode							= @ErrCode_Cur OUTPUT,
					@ErrMsg								= @ErrMsg_Cur OUTPUT			
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		END
		ELSE
		BEGIN
			SELECT @ErrCode = @ErrCode + '-103'+ CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		END
	END

END




GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentLiveCS_All]	 TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_All]	 TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_All]	 TO [bodbDownlineNet]