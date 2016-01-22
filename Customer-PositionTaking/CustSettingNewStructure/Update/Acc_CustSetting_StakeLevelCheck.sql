SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_StakeLevelCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @StakeLevel		VARCHAR(MAX)
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160118@Billy
	Task : Check Customer's Stake Level Settings
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
		@StakeLevel:
		<ROOT>
				<StakeLevel 
						SportType="211" 
						BetType="2401" 
						StakeLevelList="1,2,3,4,5"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE	#tmpStake (
						ID				INT IDENTITY (1,1)
					,	SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelList	VARCHAR(200)
					,	isValidated		BIT DEFAULT 0
					,	PRIMARY KEY CLUSTERED (SportType, BetType)
					);
	
	DECLARE	@iDoc					INT;

	DECLARE	@BetType				INT
		,	@StakeLevelList			VARCHAR(100)
		,	@UplineStakeLevelList	VARCHAR(100)
		,	@invalidStakeLevelID	VARCHAR(100);

	IF @StakeLevel IS NULL OR @StakeLevel = ''
		RETURN;

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= '';


	EXEC sys.sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel;

	INSERT INTO #tmpStake
		(	SportType   , BetType   , StakeLevelList)
	SELECT	ox.SportType, ox.BetType, ox.StakeLevelList
	FROM OPENXML (@iDoc, '/ROOT/StakeLevel', 1) 
	WITH (
		SportType		SMALLINT
	,	BetType			INT
	,	StakeLevelList	VARCHAR(200)	
	) AS ox;

	EXEC sys.sp_xml_removedocument @iDoc;

	IF @RoleID < 4
	BEGIN
	    WHILE (0 = 0)
		BEGIN
		    SELECT TOP(1)	@BetType		= BetType
						,	@StakeLevelList = StakeLevelList   
			FROM #tmpStake  
			WHERE isValidated = 0;  

			IF @@ROWCOUNT = 0
				BREAK;  

			IF	@RoleID = 3  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @SuperID
					AND	BetType = @BetType;
			END;           
			ELSE IF	@RoleID = 2  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @MasterID
					AND	BetType = @BetType;
			END;           
			ELSE IF	@RoleID = 1  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @AgentID
					AND	BetType = @BetType;
			END;

			SELECT TOP(1) @invalidStakeLevelID = ISNULL(val,0)    
			FROM dbo.strSplit(@StakeLevelList,',')  
			WHERE val NOT IN (SELECT val FROM dbo.strSplit(@UplineStakeLevelList,','));  

			IF @invalidStakeLevelID > 0  
			BEGIN  
				--Return Data  
				SELECT @ErrCode = 1000;  
				BEGIN TRY  
					 SELECT @ErrMsg = 'This user''s upline does not have Stake Level for ' + typenamee   
					 FROM DBAGE.bodb02.dbo.bettype WITH(NOLOCK)  
					 WHERE typeid = @BetType;  
				END TRY  
				BEGIN CATCH  
					 SELECT @ErrMsg = 'This user''s upline does not have Stake Level for ' + typenamee   
					 FROM DBTXN.bodb02.dbo.bettype WITH(NOLOCK)  
					 WHERE typeid = @BetType;  
				END CATCH;   
				RETURN;   
			END;   

			UPDATE	#tmpStake  
			SET		isValidated = 1  
			WHERE	BetType = @BetType;
		END;
	END;

END;
GO

GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbAdminNet];
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbDownlineNet];
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbExtAccNet];