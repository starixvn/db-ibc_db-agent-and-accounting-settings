ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] 
	@CustID				INT
	, @ExistingCustID	INT		
	, @SubAccID			INT				= 0
	, @IP				VARCHAR(50)		= ''
	, @UserID			INT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20151030@Elodie
	Task : Copy Insert Settings of an existing member Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	Revision

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xmlPT XML, @xmlBetLimit XML, @xmlDiscount XML, @xmlStatus XML

	SELECT @ErrCode = 0
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	DECLARE @NewPTTble TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, AgentPT			TINYINT
			UNIQUE CLUSTERED (SportType, BetType, IsLive)
		)
	
	DECLARE @SettingMode BIT, @AgentID INT
	--Get setting mode
	SELECT @SettingMode = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @ExistingCustID

	SELECT @AgentID = recommend FROM CustInfo WITH (NOLOCK) WHERE custid = @CustID

	IF @SettingMode = 0
	BEGIN
		INSERT INTO @NewPTTble (
					SportType
					, BetType
					, Islive
					, AgentPT
					)
				SELECT mcs.SportType
					, mcs.BetType
					, mcs.IsLive
					, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END
				FROM dbo.CustPTSetting3rd_Member mcs WITH (NOLOCK)
					INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
				WHERE mcs.custid = @ExistingCustID AND acs.custid = @AgentID
	END
	ELSE
	BEGIN
		----check a1<a2
		--IF EXISTS (SELECT 1
		--		FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
		--			INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
		--		WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID AND mcs.agentPT > acs.agentPT)
		--	SET @SettingMode = 0

		INSERT INTO @NewPTTble (
					SportType
					, BetType
					, Islive
					, AgentPT
					)
				SELECT mcs.SportType
					, mcs.BetType
					, mcs.IsLive
					, CASE WHEN mcs.agentPT > acs.agentPT THEN acs.agentPT ELSE mcs.agentPT END
				FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
					INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
				WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID		
	END
	
	SET @xmlPT = ( SELECT
						(
						SELECT SportType	AS '@SportType'
							, BetType		AS '@BetType'
							, IsLive		AS '@IsLive'
							, AgentPT		AS '@AgentPT'
						FROM @NewPTTble
						FOR XML PATH('PT')
							, TYPE
						)
					FOR XML PATH('ROOT')
						, TYPE
					)
	
	EXEC Acc_CustSetting_AgentPTOnMemberUpd
		@CustID = @CustID
		, @PT = @xmlPT
		, @SubAccID = @SubAccID
		, @IP = @IP
		, @UserID = @UserID
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	DECLARE @NewBetLimitTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, MinBet			MONEY
		, MaxBet			MONEY
		, MaxPerMatch		MONEY
		)

	INSERT INTO @NewBetLimitTbl
	SELECT bl.SportType
		, bl.BetType
		, bl.MinBet
		, bl.MaxBet
		, bl.MaxPerMatch
	FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)		
	WHERE bl.custid = @ExistingCustID

	SET @xmlBetLimit = (SELECT (
								SELECT SportType	AS '@SportType'
									, BetType		AS '@BetType'
									, MinBet		AS '@MinBet'
									, MaxBet		AS '@MaxBet'
									, MaxPerMatch	AS '@MaxPerMatch'
								FROM @NewBetLimitTbl
								FOR XML PATH('BetLimit')
									, TYPE
								)
						FOR XML PATH('ROOT')
							, TYPE
						)
	
	EXEC Acc_CustSetting_BetLimitUpd 
		  @CustID = @CustID
		, @BetLimit = @xmlBetLimit
		, @SubAccID = @SubAccID
		, @IP = @IP
		, @UserID = @UserID
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	/********************************************* Commision : SettingType = 3 ****************************************/
	DECLARE @NewDiscountTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Discount	DECIMAL(9, 8)
		)
	
	INSERT INTO @NewDiscountTbl
	SELECT dc.SportType
		, dc.BetType
		, dc.PlayerDiscount
	FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
	WHERE dc.CustID	= @ExistingCustID

	SET @xmlDiscount = ( SELECT (
								SELECT SportType AS '@SportType'
									, BetType AS '@BetType'
									, Discount AS '@Discount'
								FROM @NewDiscountTbl
								FOR XML PATH('Discount')
									, TYPE
								)
						FOR XML PATH('ROOT')
							, TYPE
						)

	EXEC Acc_CustSetting_DiscountUpd 		
		  @CustID = @CustID
		, @Discount = @xmlDiscount
		, @SubAccID = @SubAccID
		, @IP = @IP
		, @UserID = @UserID
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	/********************************************* Product Status: SettingType = 4 ************************************/
	DECLARE @NewDisableStatTbl TABLE(
		SportType				SMALLINT
		, BetType				SMALLINT
		, IsDisabled			BIT
		, IsDisabledDownline	BIT
		)
	
	INSERT INTO @NewDisableStatTbl (SportType,BetType,IsDisabled,IsDisabledDownline)
	SELECT psp.SportType
		, psp.BetType		
		, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
		, 0 AS IsDisabledDownline
	FROM dbo.CustProductStatus stt WITH (NOLOCK) 
		CROSS JOIN ProductStatusProfile PSP WITH (NOLOCK) 
	WHERE stt.CustID = @CustID

	SET @xmlStatus = (SELECT (
							SELECT SportType	AS '@SportType'
								, BetType		AS '@BetType'
								, IsDisabled	AS '@IsDisabled'
								, IsDisabledDownline AS '@IsDisabledDownline'
							FROM @NewDisableStatTbl
							FOR XML PATH('ProductStatus')
								, TYPE
							)
					FOR XML PATH('ROOT')
						, TYPE
					)

	EXEC Acc_CustSetting_DisableStatUpd
		  @CustID = @CustID
		, @IsDisabled = @xmlStatus
		, @SubAccID = @SubAccID
		, @IP = @IP
		, @UserID = @UserID
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [vnteam]