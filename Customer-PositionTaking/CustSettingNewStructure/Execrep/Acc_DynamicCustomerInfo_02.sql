ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_02] 
	@CustID				INT		= 0
	, @ExistingCustID	INT		= 0
	, @ErrCode			INT		= 0		OUTPUT
AS
/*
	Created: 20150928@Dominic
	Task : Copy Insert Settings of an existing S/M/A Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	
	Revision
		- 20160108@Elodie: Implementing SMA WinLossLimit Plugin - [Redmine #50082]
		- 20160125@Billy: Implementing Stake Level Settings - [Redmine: #51026]

	*/
BEGIN
	IF @ExistingCustID = 0 RETURN
	
	SELECT @ErrCode = 0

	if dbo.f_CheckRepTable('CustProductStatus') = 1
	BEGIN
		/********************************************* Product Status: SettingType = 4 ************************************/
		--Get sporttype/Bettype for this setting type
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[CustProductStatus] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			BEGIN
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced )
				SELECT @CustID,cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced
				FROM [dbo].[CustProductStatus] cs WITH(NOLOCK)
				WHERE CustID = @ExistingCustID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4
			DELETE FROM CustProductStatus WHERE CustID = @CustID

			RETURN
		END CATCH
	END

	if (dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1	
		AND dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1
		AND dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1
	   )
	BEGIN			
		/********************************************* Position Taking: SettingType = 1 ***********************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustPTSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			INSERT INTO [dbo].[CustPTSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[IsLive]
				   ,[SuperPT]
				   ,[MasterPT]
				   ,[AgentPT]
				   ,[IsAutoMasterPT]
				   ,[AutoMasterPT]
				   ,[IsAutoSuperPT]
				   ,[AutoSuperPT]
				   ,[MinPT]
				   ,[MaxPT])
				SELECT 
					@CustID
				   ,[SportType]
				   ,[BetType]
				   ,[IsLive]
				   ,[SuperPT]
				   ,[MasterPT]
				   ,[AgentPT]
				   ,[IsAutoMasterPT]
				   ,[AutoMasterPT]
				   ,[IsAutoSuperPT]
				   ,[AutoSuperPT]
				   ,[MinPT]
				   ,[MaxPT]
				FROM [dbo].[CustPTSetting3rd_Agent] WITH(NOLOCK)
				WHERE CustID = @ExistingCustID
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 1
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID
			
			RETURN
		END CATCH
	
		/********************************************* Bet Limit : SettingType = 2 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustBetSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			INSERT INTO [dbo].[CustBetSetting3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[MinBet]
					   ,[MaxBet]
					   ,[MaxPerMatch])
			SELECT		@CustID
					   ,[SportType]
					   ,[BetType]
					   ,[MinBet]
					   ,[MaxBet]
					   ,[MaxPerMatch]
			FROM [dbo].[CustBetSetting3rd_Agent]
			WHERE CustID = @ExistingCustID
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 2
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH
	
		/********************************************* Commision : SettingType = 3 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount])
			SELECT		@CustID
					   ,[SportType]
					   ,[BetType]
					   ,[Discount]
			FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK)
			WHERE CustID = @ExistingCustID
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 3
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH

		/********************************************* SMA Win Loss Limit : SettingType = 6 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustWinLossLimit_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			INSERT INTO [dbo].[CustWinLossLimit_Agent]
					   ([CustID]
						,[SportType]
						,[BetType]
						,[MaxWinLimit]
						,[MaxLossLimit]
						,[IsAutoReset])
			SELECT		@CustID
						,SportType
						,BetType
						,MaxWinLimit
						,MaxLossLimit
						,IsAutoReset
			FROM [dbo].[CustWinLossLimit_Agent]
			WHERE CustID = @ExistingCustID
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 6
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH

		
		/****************************** Stake Level Member Single Selection : SettingType = 7 ******************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			INSERT INTO dbo.CustStakeLevel_Agent
					(CustID
				,	SportType
				,	BetType
				,	StakeLevelList)
			SELECT	@CustID
				,	csla.SportType
				,	csla.BetType
				,	csla.StakeLevelList
			FROM dbo.CustStakeLevel_Agent AS csla
			WHERE CustID = @ExistingCustID
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 7
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
			DELETE FROM dbo.CustStakeLevel_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH
	END	
END