ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerOpusCS]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2013-10-09
		DB: DBAGE/bodb02
		Task: Super get Opus casino's setting on member
		
		Revisions:
		
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @CustGameType TABLE (
		GameTypeID INT,
		IBCBetType INT,
		StakeLevelName VARCHAR(100),
		isChecked BIT
	)
			
	DECLARE @GameType TABLE(
		GameTypeID INT,
		StakeLevelID VARCHAR(100),
		UplineStakeLevelList VARCHAR(100),
		isUpdated BIT DEFAULT (0)
	)
	
	DECLARE @StakeLevelID VARCHAR(20)
			,@UplineStakeLevelList VARCHAR(100)
			,@GameTypeID INT
			,@IBCBetTypeID INT
			,@srecommend INT
			,@mrecommend INT
			,@recommend INT
	
	SELECT @srecommend = srecommend	,@mrecommend = mrecommend ,@recommend = recommend
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @custid
	
	INSERT INTO @GameType (GameTypeID,StakeLevelID,UplineStakeLevelList)
	SELECT cg.GameTypeID, cg.StakeLevelList, upline.StakeLevelList
	FROM CustGameType cg WITH(NOLOCK)
		INNER JOIN CustGameType upline WITH(NOLOCK) ON cg.GameTypeID = upline.GameTypeID
	WHERE cg.custid = @custid AND upline.custid = @recommend
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @GameType
		SET isUpdated = 1
			,@GameTypeID = GameTypeID
			,@StakeLevelID = StakeLevelID
			,@UplineStakeLevelList = UplineStakeLevelList
		WHERE isUpdated = 0
	
		IF @@ROWCOUNT =0
			break;
			
		SELECT @IBCBetTypeID = IBCBetTypeID 
		FROM GameType WITH(NOLOCK)
		WHERE GameTypeID = @GameTypeID
		
		INSERT INTO @CustGameType (GameTypeID, IBCBetType, StakeLevelName, isChecked)
		SELECT @GameTypeID, @IBCBetTypeID, A.MinLabel + '-' + A.MaxLabel , CASE WHEN B.StakeLevelID IS NULL THEN 0 ELSE 1 END
		FROM
		 (
				SELECT	StakeLevelID,MinLabel,MaxLabel,MinStake 
				FROM	dbo.StakeLevel WITH (NOLOCK) 
				WHERE	 CHARINDEX('"' + convert(varchar(20),StakeLevelID) + '"','"' + replace(@UplineStakeLevelList,',','","') + '"',0) > 0  
		) A LEFT JOIN 	
		 (
				SELECT	StakeLevelID 
				FROM	dbo.StakeLevel WITH (NOLOCK) 
				WHERE	 convert(varchar(20),StakeLevelID) = @StakeLevelID
		) B ON A.StakeLevelID = B.StakeLevelID
		ORDER BY A.MinStake	
	END		
		
END 

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbDownlineNetView]
