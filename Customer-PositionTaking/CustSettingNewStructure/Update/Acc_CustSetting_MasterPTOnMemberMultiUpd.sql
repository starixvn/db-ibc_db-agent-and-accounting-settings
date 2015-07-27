/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTOnMemberMultiUpd] 
	  @CustIDList		VARCHAR(MAX)
	, @PT			VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @IP				VARCHAR(50)		= ''
	, @UserID			INT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-09
		Task: master multiple update grouped member's PT
		DB: DBCUST/CustDB

		Parameter's Explanation:	
		• @PT:
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
		
	DECLARE @ErrType		NVARCHAR(4000)
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
		, IsLive			BIT
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		)
	DECLARE @OldPTTble TABLE (
		   SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		)

	DECLARE @CorrectedPT_XML VARCHAR(MAX)
			,@AdjustedPT_XML VARCHAR(MAX)
			
	DECLARE @RemainCustTbl TABLE (CustID INT)
			
	--Check if XML is null or empty
	IF @PT IS NULL
		OR @PT = ''
		OR @CustIDList IS NULL
		OR @CustIDList = ''
		RETURN

	SET @startRun = GETDATE()

	SELECT @ErrCode = 0
		, @MsgType = 0
		, @ErrMsg = ''


	--Parse affected Customer
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@CustIDList, ',')

			
	-- ***Check Downline Belonging***
	EXEC dbo.Acc_CustSetting_BelongingMultiCustCheck @SessionCustID = @Userid
		, @Custid = @CustIDList
		, @roleid = @roleid OUTPUT

	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END

			
	--Check disable user
	EXEC dbo.Acc_CustSetting_MultiCustEnableCheck @CustIDList = @CustIDList
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN
	
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT

	INSERT @NewPTTble
	SELECT SportType
			,BetType
			,IsLive
			,0
			,MasterPT
			,0
			,IsAutoMasterPT
			,AutoMasterPT
			,0
			,0
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, MasterPT			TINYINT
			, IsAutoMasterPT	BIT
			, AutoMasterPT		TINYINT
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
	SET  main.SuperPT = cs.SuperPT
		, main.AgentPT = cs.AgentPT
		, main.IsAutoSuperPT =cs.IsAutoSuperPT
		, main.AutoSuperPT = cs.AutoSuperPT
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
			, cs.MasterPT
			, cs.AgentPT  
			, cs.IsAutoMasterPT 
			, cs.AutoMasterPT 
			, cs.IsAutoSuperPT 
			, cs.AutoSuperPT 
	FROM @NewPTTble main
	JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.AgentID=@AgentID	
			
			
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
						@CustID = @RepresentCustID
						, @RoleID		= 3
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @PT		= @PT
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType  OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT
	IF @ErrCode <> 0
		RETURN		

	
	--Adjust PT: m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1
	UPDATE main
	SET main.MasterPT = CASE 
							WHEN main.MasterPT > CASE 
													WHEN mpt.MasterPT < spt.MasterPT
														THEN mpt.MasterPT
													ELSE spt.MasterPT
												END - main.AgentPT
								THEN CASE 
											WHEN mpt.MasterPT < spt.MasterPT
												THEN mpt.MasterPT
											ELSE spt.MasterPT
										END - main.AgentPT
							ELSE main.MasterPT
						END
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
				
				
	--Adjust PT: m1=m1+a1<n3?n3-a1:m1
	UPDATE main
	SET main.MasterPT = CASE WHEN main.MasterPT < mpt.MinPT + (-1)*main.AgentPT THEN mpt.MinPT - main.AgentPT ELSE main.MasterPT END
	FROM @NewPTTble main
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=main.SportType
					AND mpt.BetType=main.BetType
					AND mpt.IsLive=main.IsLive
					AND mpt.CustID=@MasterID
	
	
	--Adjust PT: m1=m1>0?m1:0
	UPDATE main
	SET main.MasterPT = CASE WHEN main.MasterPT < 0 THEN 0 ELSE main.MasterPT END
	FROM @NewPTTble main
	
	
	--Adjust PT: m1=im1/im2=1 ? min(um1/um2,m3-a1):m1
	UPDATE main
	SET main.MasterPT = CASE 
							WHEN CASE 
										WHEN main.IsAutoMasterPT = 1
											THEN main.AutoSuperPT
										ELSE apt.AutoMasterPT
									END < mpt.MasterPT - main.AgentPT
								THEN CASE 
										WHEN main.IsAutoMasterPT = 1
											THEN main.AutoSuperPT
										ELSE apt.AutoMasterPT
									END
							ELSE mpt.MasterPT - main.AgentPT
						END				
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType=main.SportType
				AND apt.BetType=main.BetType
				AND apt.IsLive=main.IsLive
				AND apt.CustID=@AgentID
	JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	WHERE main.IsAutoMasterPT = 1 OR apt.IsAutoMasterPT = 1
	
	--Adjust PT : s1=(is=0?s1:min(us,s4-m1-a1))
	UPDATE main
	SET main.SuperPT = CASE 
							WHEN CASE 
										WHEN main.IsAutoSuperPT = 1
											THEN main.AutoSuperPT
										ELSE mpt.AutoSuperPT
									END < spt.SuperPT - main.MasterPT - main.AgentPT
								THEN CASE 
										WHEN main.IsAutoSuperPT = 1
											THEN main.AutoSuperPT
										ELSE mpt.AutoSuperPT
									END
							ELSE spt.SuperPT - main.MasterPT - main.AgentPT
						END				
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
	JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	WHERE main.IsAutoSuperPT = 1 OR spt.IsAutoSuperPT = 1
	
	
	--Adjust PT : s1=s1>(isauto?s4:s4-m3)?(isauto?s4:s4-m3):s1
	UPDATE main
	SET main.SuperPT = CASE 
							WHEN main.SuperPT > CASE 
										WHEN main.IsAutoSuperPT = 1
											OR mpt.IsAutoSuperPT = 1
											THEN spt.SuperPT
										ELSE spt.SuperPT - mpt.MasterPT
									END
								THEN CASE 
											WHEN main.IsAutoSuperPT = 1
												OR mpt.IsAutoSuperPT = 1
												THEN spt.SuperPT
											ELSE spt.SuperPT - mpt.MasterPT
										END
							ELSE main.SuperPT
						END
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
	JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	
	
	
	--**START CORRECTING PT**
	SELECT @AdjustedPT_XML = (
			SELECT 
				SportType 
				, BetType 
				, IsLive 
				, SuperPT 
				, MasterPT 
				, AgentPT 
				, IsAutoMasterPT 
				, AutoMasterPT 
				, IsAutoSuperPT 
				, AutoSuperPT 
			FROM @NewPTTble
			FOR XML RAW('PT')
			)

	SELECT @AdjustedPT_XML = '<ROOT>' + @AdjustedPT_XML + '</ROOT>'		
	
	EXEC dbo.Acc_CustSetting_MemberPTCorrect @AgentID = @AgentID
								, @MasterID = @MasterID
								, @SuperID = @SuperID
								, @PT = @AdjustedPT_XML
								, @CorrectedPT_XML = @CorrectedPT_XML OUTPUT
			
								
	DELETE FROM @NewPTTble
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @CorrectedPT_XML

	INSERT @NewPTTble
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, SuperPT TINYINT
			, MasterPT TINYINT
			, AgentPT TINYINT
			, IsAutoMasterPT TINYINT
			, AutoMasterPT TINYINT
			, IsAutoSuperPT BIT
			, AutoSuperPT TINYINT
			)

	EXEC sp_xml_removedocument @iDoc
		
	--**START UPDATING DB**--	
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
		npt.SuperPT <> opt.SuperPT
		OR npt.MasterPT <> opt.MasterPT
		OR npt.AgentPT <> opt.AgentPT
		OR npt.IsAutoMasterPT <> opt.IsAutoMasterPT
		OR npt.AutoMasterPT <> opt.AutoMasterPT
	))
	BEGIN
		SELECT @DiffCount = ISNULL((SELECT COUNT(1) FROM @tblCust),0)
	END
	ELSE
		RETURN
	
	IF ISNULL(@TotalCount,0) = 0  SET @TotalCount=1
		
	--Move group setting to individual setting ?	
	SELECT @MoveToIndv = 1
	WHERE ISNULL(@DiffCount,0)/ISNULL(@TotalCount,1) < 0.5
				
	--Get remaining CustIDs in group
	INSERT @RemainCustTbl
	SELECT ci.CustID
	FROM dbo.Custinfo ci WITH(NOLOCK)
	JOIN dbo.CustSettingMode3rd cm WITH(NOLOCK)
	ON cm.CustID=ci.CustID
	LEFT JOIN @tblCust cust ON cust.CustID=ci.CustID
	WHERE ci.roleID=1 AND ci.recommend=@AgentID
	AND cm.IsGrouped=1
	AND cust.CustID IS NULL
		
	IF @MoveToIndv=1
	BEGIN
		--Insert Individual Setting for affected custIDs
		INSERT INTO dbo.CustPTSetting3rd_Member
		SELECT
				cust.CustID,
				grpt.SportType,
				grpt.BetType,
				grpt.IsLive,
				grpt.SuperPT,
				grpt.MasterPT,
				grpt.AgentPT,
				grpt.IsAutoMasterPT,
				grpt.AutoMasterPT,
				grpt.IsAutoSuperPT,
				grpt.AutoSuperPT
		FROM @tblCust cust
		CROSS JOIN dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
		LEFT JOIN dbo.CustPTSetting3rd_Member mempt
		ON cust.CustID=mempt.CustID
		AND grpt.SportType=mempt.SportType
		AND grpt.BetType=mempt.BetType
		AND grpt.IsLive=mempt.IsLive
		WHERE grpt.AgentID=@AgentID AND mempt.CustID IS NULL
		
		--Update Adjusted PT for indiviual setting
		UPDATE main
		SET main.SuperPT=npt.SuperPT,
			main.MasterPT=npt.MasterPT,
			main.AgentPT=npt.AgentPT,
			main.IsAutoMasterPT=npt.IsAutoMasterPT,
			main.AutoMasterPT=npt.AutoMasterPT
		FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		JOIN @tblCust cust ON main.CustID=cust.CustID
		JOIN @NewPTTble npt ON  npt.SportType=main.SportType
		AND npt.BetType=main.BetType
		AND npt.IsLive=main.IsLive
		WHERE 
		npt.SuperPT <> main.SuperPT
		OR npt.MasterPT <> main.MasterPT
		OR npt.AgentPT <> main.AgentPT
		OR npt.IsAutoMasterPT <> main.IsAutoMasterPT
		OR npt.AutoMasterPT <> main.AutoMasterPT
		
		
		--Update setting mode for affected CustIDs
		UPDATE main
		SET main.IsGrouped=0
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
		JOIN @tblCust cust
		ON cust.CustID=main.CustID
		
		--Update setting mode for reamining CustIDs
		UPDATE main
		SET main.IsGrouped=1
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
		JOIN @RemainCustTbl cust
		ON cust.CustID=main.CustID
	END
	ELSE
	BEGIN				
		--Insert Individual Setting for ramaining CustIDs
		INSERT INTO dbo.CustPTSetting3rd_Member
		SELECT
				cust.CustID,
				grpt.SportType,
				grpt.BetType,
				grpt.IsLive,
				grpt.SuperPT,
				grpt.MasterPT,
				grpt.AgentPT,
				grpt.IsAutoMasterPT,
				grpt.AutoMasterPT,
				grpt.IsAutoSuperPT,
				grpt.AutoSuperPT
		FROM @RemainCustTbl cust
		CROSS JOIN dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
		LEFT JOIN dbo.CustPTSetting3rd_Member mempt
		ON cust.CustID=mempt.CustID
		AND grpt.SportType=mempt.SportType
		AND grpt.BetType=mempt.BetType
		AND grpt.IsLive=mempt.IsLive
		WHERE grpt.AgentID=@AgentID AND mempt.CustID IS NULL
		
		--Update Adjusted PT for group setting
		UPDATE main
		SET main.SuperPT=npt.SuperPT,
			main.MasterPT=npt.MasterPT,
			main.AgentPT=npt.AgentPT,
			main.IsAutoMasterPT=npt.IsAutoMasterPT,
			main.AutoMasterPT=npt.AutoMasterPT
		FROM dbo.CustPTGroupSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		JOIN @NewPTTble npt ON  npt.SportType=main.SportType
		AND npt.BetType=main.BetType
		AND npt.IsLive=main.IsLive
		WHERE main.AgentID=@AgentID
		AND
		(
			npt.SuperPT <> main.SuperPT
			OR npt.MasterPT <> main.MasterPT
			OR npt.AgentPT <> main.AgentPT
			OR npt.IsAutoMasterPT <> main.IsAutoMasterPT
			OR npt.AutoMasterPT <> main.AutoMasterPT
		)
		
		--Update setting mode for remaing Grouped CustIDs
		UPDATE main
		SET main.IsGrouped=0
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
		JOIN @RemainCustTbl cust
		ON cust.CustID=main.CustID
		
		--Update setting mode for affected CustIDs
		UPDATE main
		SET main.IsGrouped=1
		FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
		JOIN @tblCust cust
		ON cust.CustID=main.CustID
	END
	
		
	--**START LOGGING**--
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

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 451
			, @NewPT_XML		= @PT
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 451
			, @NewPT_XML		= @PT
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberMultiUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberMultiUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberMultiUpd] TO [bodbExtAccNet]