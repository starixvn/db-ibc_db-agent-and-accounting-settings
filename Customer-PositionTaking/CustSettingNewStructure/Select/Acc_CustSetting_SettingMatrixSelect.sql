DECLARE --CREATE PROCEDURE [dbo].[Acc_CustSetting_SettingMatrixSelect] 
	@UserName VARCHAR(50) = 'S33TA101000'
	, @Sporttype SMALLINT = 1
	, @Bettype SMALLINT = 1
	, @IsLive BIT = 0
	, @HasComm BIT = 1
	, @ErrCode INT = 0
	, --OUTPUT,
	@ErrMsg VARCHAR(100) = '' --OUTPUT
	--AS
	/*
	Created: Dominic
	Date: 20150416
	Task : View PT, commission in a visualable way
	DB: DBEXT.bodb02

	Revisions:


	Param's Explanation:
		• @HasComm: view Comm or view PT
			+ 0: View PT (default)
			+ 1: View Commission

*/

--Begin
	SET NOCOUNT ON

	DECLARE @PT TABLE (
			[RoleID] TINYINT
			, [CustID] INT
			, [SportType] SMALLINT
			, [BetType] SMALLINT
			, [IsLive] BIT
			, S TINYINT
			, M TINYINT
			, A TINYINT
			, IM BIT
			, UM TINYINT
			, [IS] BIT
			, US TINYINT
			, N TINYINT
			, L TINYINT
		)

	
	DECLARE @CustID INT
		, @RoleID INT
		, @SAg VARCHAR(20)
		, @MAg VARCHAR(20)
		, @Ag VARCHAR(20)
		, @DisableAutoMPT BIT
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT
		, @curBettype SMALLINT
		, @curSporttype SMALLINT
		, @curtypename VARCHAR(20)
		, @curSportname VARCHAR(50)
		, @currency TINYINT

	SELECT @CustID = CustID
		, @currency = currency
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName

	SELECT @UserName = UserName
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @CustID

	SELECT @SAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @SRecommend

	SELECT @MAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @MRecommend

	SELECT @Ag = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @Recommend

	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM CustMaster WITH (NOLOCK)
	WHERE custid = @MRecommend

	SELECT @CustID CustID
		, @UserName UserName
		, @RoleID RoleID
		, @currency currency
		, @SRecommend SAgID
		, @MRecommend MAgID
		, @Recommend AgID
		, @SAg SAg
		, @MAg MAg
		, @Ag Ag
		, @DisableAutoMPT DisableAutoMPT

	IF @@rowcount = 0
	BEGIN
		SELECT @ErrCode = 101
			, @ErrMsg = 'Invalid UserName!'

		RETURN
	END
	
	--Return Position Taking
	INSERT @PT(RoleID)
	SELECT 1
	UNION ALL
	SELECT 2
	UNION ALL
	SELECT 3
	UNION ALL
	SELECT 4
	
	select * from @PT
	ORDER BY RoleID
--End
