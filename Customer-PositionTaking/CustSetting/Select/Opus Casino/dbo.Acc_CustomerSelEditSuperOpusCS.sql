ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperOpusCS]
	@custid INT
AS 
	/*
		Created: Johnson
		Date: 2013-09-30
		Task[redmine:#5670]: Select Super's OPus casino settings
		DB: DBAGE/bodb02
		
		Revisions:
		
		Paramter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @CustGameType TABLE (
		GameTypeID INT,
		IBCBetType INT,
		StakeLevelName VARCHAR(100)
	)		
	
	DECLARE @GameType TABLE(
		GameTypeID INT,
		StakeLevelList VARCHAR(100),
		isUpdated BIT DEFAULT (0)
	)
	
	DECLARE @min_spositiontaking	SMALLMONEY
			,@DisableOpusCasinoDownlines BIT
			,@StakeLevelList VARCHAR(100)
			,@GameTypeID INT
			,@IBCBetTypeID INT
			
	INSERT INTO @GameType (GameTypeID,StakeLevelList)
	SELECT GameTypeID, StakeLevelList
	FROM CustGameType WITH(NOLOCK)
	WHERE custid = @custid
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP 1 @GameType
		SET isUpdated = 1
			,@GameTypeID = GameTypeID,
			,@StakeLevelList = StakeLevelList
		WHERE isUpdated = 0
		
		IF @@ROWCOUNT =0
			break;
		
		SELECT @IBCBetTypeID = IBCBetTypeID 
		FROM GameType WITH(NOLOCK)
		WHERE GameTypeID = @GameTypeID
		
		INSERT INTO @CustGameType (GameTypeID, IBCBetType, StakeLevelName)
		SELECT @GameTypeID, @IBCBetTypeID, B.MinLabel + '-' + B.MaxLabel 
		FROM (
				SELECT	StakeLevelID,MinLabel,MaxLabel,MinStake 
				FROM	dbo.StakeLevel WITH (NOLOCK) 
				WHERE	 CHARINDEX('"' + convert(varchar(20),StakeLevelID) + '"','"' + replace(@StakeLevelList,',','","') + '"',0) > 0  
		) B
		ORDER BY B.MinStake		
	END
	
	SELECT @min_spositiontaking = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 163 AND bettype = 1401
	
	SELECT @DisableOpusCasinoDownlines = ISNULL(MAX(DisableOpusCasino),0)
	FROM custinfo WITH(NOLOCK)
	WHERE srecommend = @custid AND roleid < 4
	
	SELECT c.username
		,c.username2
		,c.firstname
		,c.lastname
		,c.phone 
		,c.mobilephone
		,c.fax
		,ci.DisableOpusCasino
		,CASE WHEN ci.DisableOpusCasino = 1 THEN 1 ELSE @DisableOpusCasinoDownlines END as DisableOpusCasinoDownlines
		,ci.isAutoResetOpusCasino
		,ci.MaxTransferOpusCasino
		,@min_spositiontaking as v163_spositiontaking_1401_min
		,cg.spositiontaking as v163_spositiontaking_1401
		,0.9 as v163_spositiontaking_1401_max
		,cg.sdiscount as v163_sdiscount_1401
		,0.01 as v163_sdiscount_14101_max		
	FROM custinfo ci with(NOLOCK)
		INNER JOIN customer c WITH(NOLOCK) ON ci.custid = c.custid
		INNER JOIN custsettinggame cg WITH(NOLOCK) ON cg.custid = ci.custid AND cg.sporttype = 163 AND cg.bettype = 1401
	WHERE ci.custid = @custid
	
	SELECT * FROM @CustGameType	
END






GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperOpusCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperOpusCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperOpusCS] TO [bodbDownlineNetView]
