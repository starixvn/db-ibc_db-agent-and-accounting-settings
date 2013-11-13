ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_02]
	@custid INT =0,
	@ExistingCustid INT = 0,
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT
AS
/*
	Created: Johnson
	Date: 20131106
	Task: Apply execrep when insert into custsetting/custsetting3rd
	DB: DBTXN/bodb02
	
	Revisions:
	
	Parameter's Explanation:
*/ 
BEGIN
	SET NOCOUNT ON
	
	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN ('CustSetting', 'CustOverride','CustSetting3rd', 'CustOverride3rd', 'CustSettingGame','CustOverrideGame')
			AND xtype = 'U'

	if @IsExistTables <> 6 RETURN
	
	-- insert custSetting info
	INSERT INTO dbo.custSetting
	SELECT
		@Custid
		,bettype
		,sporttype
		,apositiontaking
		,mpositiontaking
		,spositiontaking
		,alivepositiontaking
		,mlivepositiontaking
		,slivepositiontaking
		,playerdiscount
		,discount
		,adiscount
		,sdiscount
		,groupa
		,groupb
		,groupc
		,groupd
		,groupe
		,groupf
		,minbet
		,maxbet
		,autopositiontaking
		,autolivepositiontaking
		,isautopositiontaking
		,isautolivepositiontaking
		,autompositiontaking
		,autolivempositiontaking
		,isautompositiontaking
		,isautolivempositiontaking	
	FROM dbo.custSetting WITH(NOLOCK)
	WHERE custid=@ExistingCustid
	
	IF @@error <> 0
	BEGIN 	
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 107
		RETURN				
	END
	
	-- insert custSetting3rd info
	INSERT INTO dbo.CustSetting3rd
	SELECT
		@Custid
		,bettype
		,sporttype
		,apositiontaking
		,mpositiontaking
		,spositiontaking
		,playerdiscount
		,discount
		,adiscount
		,sdiscount
		,minbet
		,maxbet
		,autopositiontaking
		,isautopositiontaking
		,autompositiontaking
		,isautompositiontaking
		,alivepositiontaking
		,mlivepositiontaking
		,slivepositiontaking
		,autolivepositiontaking
		,isautolivepositiontaking
		,autolivempositiontaking
		,isautolivempositiontaking
	FROM dbo.CustSetting3rd WITH(NOLOCK)
	WHERE custid=@ExistingCustid
	
	IF @@error <> 0
	BEGIN 	
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 108
					
		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		RETURN
	END	
	
	-- insert custoverride info
	INSERT INTO [dbo].[custoverride]
		([custid], 
		[bettype], 
		[sporttype], 
		minpositiontaking, 
		maxpositiontaking, 
		minlivepositiontaking, 
		maxlivepositiontaking)
	SELECT @Custid, 
		bettype, 
		sporttype, 
		minpositiontaking, 
		maxpositiontaking, 
		minlivepositiontaking, 
		maxlivepositiontaking
	FROM dbo.custOverride WITH(NOLOCK)
	WHERE custid=@ExistingCustid

	if @@error <> 0
	BEGIN
		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 109
			
		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID				
		
		RETURN
	END	
	
	-- insert custoverride3rd info
	INSERT INTO [dbo].[custoverride3rd]
		([custid], 
		[bettype], 
		[sporttype], 
		minpositiontaking, 
		maxpositiontaking, 
		minlivepositiontaking, 
		maxlivepositiontaking)
	SELECT @Custid, 
		bettype, 
		sporttype, 
		minpositiontaking, 
		maxpositiontaking, 
		minlivepositiontaking, 
		maxlivepositiontaking
	FROM dbo.custOverride3rd WITH(NOLOCK)
	WHERE custid=@ExistingCustid

	IF @@error <> 0
	BEGIN
		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 110
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		
		RETURN
	END
	
	--Insert Into P2P Setting
	INSERT INTO  dbo.P2PGameSetting WITH(ROWLOCK)
		(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
	SELECT @custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5	
	FROM dbo.P2PGameSetting WITH(NOLOCK)
	WHERE custid=@ExistingCustid	

	if @@error <> 0
	BEGIN

		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 111
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
					
		RETURN
	END

	--insert P2PGroupComm
	INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
           (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
	SELECT @custid,groupID,sdiscount,adiscount,discount,playerdiscount
	FROM dbo.P2PGroupComm
	WHERE custid  = @ExistingCustid  

	if @@error <> 0
	BEGIN

		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 112
			
		-- ROLLBACK MANUALLY			
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID
		
		RETURN
	END
	
	--- insert into CustSettingGame
	INSERT INTO custsettingGame
		(CustID, 
		Bettype, 
		Sporttype, 
		apositiontaking, 
		mpositiontaking, 
		spositiontaking, 
		playerdiscount, 
		discount, 
		adiscount, 
		sdiscount, 
		autopositiontaking, 
		isautopositiontaking, 
		autompositiontaking, 
		isautompositiontaking)
	SELECT 
		@custid, 
		Bettype, 
		Sporttype, 
		apositiontaking, 
		mpositiontaking, 
		spositiontaking, 
		playerdiscount, 
		discount, 
		adiscount, 
		sdiscount, 
		autopositiontaking, 
		isautopositiontaking, 
		autompositiontaking, 
		isautompositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @ExistingCustid

	if @@error <> 0
	BEGIN

		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 113
			
		-- ROLLBACK MANUALLY				
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID

		RETURN
	END

	--- insert into Custoverridegame
	INSERT INTO Custoverridegame(CustID, Bettype, Sporttype, minpositiontaking)
	SELECT @CustID, Bettype, Sporttype, minpositiontaking
	FROM Custoverridegame WITH(NOLOCK)
	WHERE custid = @ExistingCustid

	if @@error <> 0
	BEGIN

		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end,
			@ErrCode = 114
			
		-- ROLLBACK MANUALLY		
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
					
		RETURN
	END	
END
GO