/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTSuperMultiUpd] 
	  @CustIDList	VARCHAR(MAX)
	, @PT_XML		VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @UserID		INT				= 0
	, @Language		VARCHAR(20)		= 'E'
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(4000)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-10
		Task: Super multiple update grouped member's PT
		DB: DBTXN/CustDB

		Parameter's Explanation:	
		• @PT_XML:
					<ROOT>
						<PT 
							SportType="1" 
							BetType="1" 
							IsLive="1" 
							MasterPT="10" 
							IsAutoMasterPT="1" 
							AutoMasterPT="10" 
						/>
					</ROOT>
	*/
BEGIN
	SET NOCOUNT ON
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
		, @endRun DATETIME
		, @duration INT
		
	DECLARE @AdjustedPT_XML VARCHAR(MAX)=NULL
		
	DECLARE 
		 @ErrType			NVARCHAR(4000)
		, @AgentID			INT
		, @MasterID			INT
		, @SuperID			INT
		, @RepresentCustID	INT
		, @RoleID			INT
		, @TotalCount		DECIMAL = 0
		, @DiffCount		INT		= 0
		, @MoveToIndv		BIT		= 0
	
	DECLARE @Old_PT_XML VARCHAR(MAX)
		
	DECLARE @tblCust TABLE (CustID INT)
	
	DECLARE @NewPTTble TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, ISLive			BIT
		, AgentPT			TINYINT
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		)
	DECLARE @OldPTTble TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT
		, SuperPT			TINYINT
		, AgentPT			TINYINT
		, MasterPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		)

	--Check if XML is null or empty
	IF @PT_XML IS NULL
		OR @PT_XML = ''
		OR @CustIDList IS NULL
		OR @CustIDList = ''
		RETURN

	SET @startRun = GETDATE()

	SELECT @ErrCode = 0
		, @ErrMsg = ''


	--Parse affected Customer
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@CustIDList, ',')

			
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustSetting_MultiCustEnableCheck @CustIDList = @CustIDList
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		RETURN
	END
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT_XML

	INSERT @NewPTTble
	SELECT SportType
			,BetType
			,IsLive
			,0
			,SuperPT
			,0
			,IsAutoSuperPT
			,AutoSUperPT
			,0
			,0
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType		SMALLINT
			, BetType		SMALLINT
			, IsLive		BIT
			, SuperPT		TINYINT
			, IsAutoSuperPT BIT
			, AutoSUperPT	TINYINT
			)

	EXEC sp_xml_removedocument @iDoc
			
	--get line infor
	SELECT TOP 1 @RepresentCustID=CustID
	FROM @tblCust
	
	SELECT @SuperID = srecommend
			, @MasterID = mrecommend
			, @AgentID = recommend
	FROM custinfo ci WITH(NOLOCK)
	WHERE ci.custid = @RepresentCustID
	
	--Get member's setting to be adjusted
	UPDATE main
	SET  main.MasterPT = cs.MasterPT
		, main.AgentPT = cs.AgentPT
		, main.IsAutoMasterPT =cs.IsAutoMasterPT
		, main.AutoMasterPT = cs.AutoMasterPT
	FROM @NewPTTble main
	JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.AgentID=@AgentID
			
	--Get old settings for logs
	INSERT @OldPTTble
	SELECT 
			cs.SportType 
			, cs.BetType 
			, cs.IsLive 
			, cs.SuperPT 
			, cs.AgentPT 
			, cs.MasterPT 
			, cs.IsAutoSuperPT 
			, cs.AutoSuperPT 
			, cs.IsAutoMasterPT 
			, cs.AutoMasterPT 
	FROM @NewPTTble main
	JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.AgentID=@AgentID	
			
			
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTUpdCheck 
						@CustID = @RepresentCustID
						, @RoleID		= 4
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @PT_XML = @PT_XML
						, @Language		= @Language
						, @ErrCode		= @ErrCode	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT
	IF @ErrCode <> 0
		RETURN		

	--AdjustPT: s1= s1+m1+ a1> s4?s4-m1-a1:s1
	UPDATE main
	SET main.SuperPT = spt.SuperPT - main.MasterPT-main.AgentPT
	FROM @NewPTTble main
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=main.SportType
					AND spt.BetType=main.BetType
					AND spt.IsLive=main.IsLive
					AND spt.CustID=@SuperID
	WHERE main.SuperPT+main.MasterPT+main.AgentPT > spt.SuperPT
	
	--AdjustPT: s1=s1<0?:0:s1
	UPDATE main
	SET main.SuperPT = CASE WHEN main.SuperPT > 0 THEN main.SuperPT ELSE 0 END
	FROM @NewPTTble main
	WHERE main.SuperPT < 0
	
	
	
	--Get total members that belong to Group
	SELECT @TotalCount = ISNULL(COUNT(1),0)
	FROM dbo.CustSettingMode3rd mode WITH (NOLOCK)
	JOIN dbo.CustInfo ci WITH (NOLOCK) ON ci.CustID=mode.CustID 
	WHERE ci.recommend=@AgentID AND mode.IsGrouped=1
	
	--Get total members that are different from group
	IF EXISTS (SELECT TOP 1 1
	FROM @NewPTTble npt
	JOIN @OldPTTble opt
	ON npt.SportType=opt.SportType
	AND npt.BetType=opt.BetType
	AND npt.IsLive=opt.IsLive
	WHERE (
		npt.SuperPT				<> opt.SuperPT
		OR npt.MasterPT			<> opt.MasterPT
		OR npt.IsAutoMasterPT	<> opt.IsAutoMasterPT
		OR npt.AutoMasterPT		<> opt.AutoMasterPT
	))
	BEGIN
		SELECT @DiffCount = ISNULL((SELECT COUNT(1) FROM @tblCust),0)
	END
	ELSE
		RETURN
	
	IF ISNULL(@TotalCount,0) = 0  SET @TotalCount=1
		
	SELECT @MoveToIndv = 1
	WHERE ISNULL(@DiffCount,0)/ISNULL(@TotalCount,1) < 0.5
	
	SELECT @AdjustedPT_XML = (
			SELECT SportType
					,BetType
					,IsLive
					,MasterPT
					,IsAutoMasterPT
					,AutoMasterPT
	FROM @NewPTTble
	FOR XML RAW ('PT'))

	SELECT @AdjustedPT_XML = '<ROOT>'+@AdjustedPT_XML+'</ROOT>'
	
	
	SELECT @Old_PT_XML = (
			SELECT SportType
					,BetType
					,IsLive
					,MasterPT
					,IsAutoMasterPT
					,AutoMasterPT
	FROM @OldPTTble
	FOR XML RAW ('PT'))

	SELECT @Old_PT_XML = '<ROOT>'+@Old_PT_XML+'</ROOT>'
	
	--Call execrep to update member PT		
	EXEC dbo.Acc_CustSetting3rd_08
			@CustIDList = @CustIDList,
			@roleid = 3,
			@mode = 'Others-MultiUpd',
			@AdjustedPT_XML=@AdjustedPT_XML,
			@MoveToIndv=@MoveToIndv
			
	--Call execrept to correct PT		
	EXEC dbo.Acc_CustSetting3rd_09
		@CustIDList = @CustIDList, 
		@recommend = @AgentID, 
		@mrecommend = @MasterID, 
		@srecommend = @SuperID,
		@MoveToIndv=@MoveToIndv,
		@mode = 'Others-MultiUpd'
		
	--START LOGGING		

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 452
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 452
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH
END
