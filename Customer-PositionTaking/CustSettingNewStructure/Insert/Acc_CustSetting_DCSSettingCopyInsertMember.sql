ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] 
	@CustID				INT
	, @ProductID		TINYINT = NULL
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
		- 20160104@Dominic: Implementing Charge Commission Plugin - Redmine #49689
		- 20160115@Dominic: Do not update setting when there is no data Redmine: #50937

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xmlPT XML, @xmlBetLimit XML, @xmlDiscount XML, @xmlStatus XML
	DECLARE @xmlStr VARCHAR(MAX)
	SELECT @ErrCode = 0
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1))
	BEGIN
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
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
						INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1) fil ON fil.SportType = mcs.SportType AND fil.BetType = mcs.BetType AND fil.IsLive = mcs.IsLive
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
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlPT)
		
		IF EXISTS (SELECT TOP 1 1 FROM @NewPTTble)
		BEGIN
			EXEC Acc_CustSetting_AgentPTOnMemberUpd
				@CustID = @CustID
				, @PT = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
	END
	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2))
	BEGIN
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2) fil ON fil.SportType = bl.SportType AND fil.BetType = bl.BetType		
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
	
		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlBetLimit)

		IF EXISTS(SELECT TOP 1 1 FROM @NewBetLimitTbl)
		BEGIN
			EXEC Acc_CustSetting_BetLimitUpd 
				  @CustID = @CustID
				, @BetLimit = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
	END
	/********************************************* Commision : SettingType = 3 ****************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,3))
	BEGIN
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
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

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

		IF EXISTS(SELECT TOP 1 1 FROM @NewDiscountTbl)
		BEGIN
			EXEC Acc_CustSetting_DiscountUpd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
	END
	/*********************************************Charge Commision : SettingType = 5 ****************************************/
	DECLARE @NewChargeCommTbl TABLE (
					SportType	SMALLINT
				,	BetType		SMALLINT
				,	Discount	DECIMAL(9, 8)
			)
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5))
	BEGIN
	
		INSERT INTO @NewChargeCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dc WITH(NOLOCK)
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5) fil ON fil.SportType = dc.SportType AND fil.BetType = dc.BetType
		WHERE dc.CustID	= @ExistingCustID

		SET @xmlDiscount = ( SELECT (
									SELECT SportType AS '@SportType'
										, BetType AS '@BetType'
										, Discount AS '@Discount'
									FROM @NewChargeCommTbl
									FOR XML PATH('Discount')
										, TYPE
									)
							FOR XML PATH('ROOT')
								, TYPE
							)

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlDiscount)

		IF EXISTS(SELECT TOP 1 1 FROM @NewChargeCommTbl)
		BEGIN
			EXEC Acc_CustSetting_DiscountUpd 		
				  @CustID = @CustID
				, @Discount = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @SettingType = 5
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT
		END
	END
	/********************************************* Product Status: SettingType = 4 ************************************/
	IF EXISTS (SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4))
	BEGIN
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
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4) fil ON fil.SportType = PSP.SportType AND fil.BetType = PSP.BetType 
		WHERE stt.CustID = @ExistingCustID

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

		SELECT @xmlStr = CONVERT(VARCHAR(MAX),@xmlStatus)

		IF EXISTS(SELECT TOP 1 1 FROM @NewDisableStatTbl)
		BEGIN
			EXEC Acc_CustSetting_DisableStatUpd
				  @CustID = @CustID
				, @IsDisabled = @xmlStr
				, @SubAccID = @SubAccID
				, @IP = @IP
				, @UserID = @UserID
				, @ErrCode = @ErrCode OUTPUT
				, @ErrMsg = @ErrMsg OUTPUT	
		END
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember] TO [vnteam]