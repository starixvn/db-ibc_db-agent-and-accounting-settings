/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] 
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
		Date: 2014-12-08
		Task: Agent multiple update member's PT
		DB: DBTXN/CustDB

		Parameter's Explanation:	
		• @PT_XML:
					<ROOT>
							<PT 
									SportType="1" 
									BetType="1" 
									IsLive="1" 
									AgentPT="10" 
							/>
					</ROOT>
	*/
BEGIN
	SET NOCOUNT ON
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
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
		, AgentPT_Max		TINYINT
		, AgentAPT_Max		TINYINT
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

	-- ***Check Downline Belonging***
	EXEC dbo.Acc_CustSetting_BelongingMultiCustCheck @SessionCustID = @Userid
		, @Custid = @CustIDList
		, @roleid = @roleid OUTPUT

	IF (@roleid = 0)
		RETURN

			
	--Check disable user
	EXEC dbo.Acc_CustSetting_MultiCustEnableCheck @CustIDList = @CustIDList
		, @ErrCode = @ErrCode OUTPUT
		, @ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN
	
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT_XML

	INSERT @NewPTTble
	SELECT SportType
			,BetType
			,IsLive
			,0,0,AgentPT,0,0,0,0,0,0
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsLive	BIT
			, AgentPT	TINYINT
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
		, main.MasterPT = cs.MasterPT
		, main.IsAutoSuperPT =cs.IsAutoSuperPT
		, main.AutoSuperPT = cs.AutoSuperPT
		, main.IsAutoMasterPT = cs.IsAutoMasterPT
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
						, @RoleID		= 2
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @PT_XML = @PT_XML
						, @Language		= @Language
						, @ErrCode		= @ErrCode	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		
	
	
	--Adjust PT: a1=min(a1,m3)
	UPDATE main
	SET main.AgentPT = CASE WHEN main.AgentPT > mpt.MasterPT THEN mpt.MasterPT ELSE main.AgentPT  END
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
	ON mpt.SportType=main.SportType
			AND mpt.BetType=main.BetType
			AND mpt.IsLive=main.IsLive
			AND mpt.CustID=@MasterID
	--Adjust PT: a1= if(im1=0 && im2=0 && m1+a1>m3) then m3-m1
	UPDATE main
	SET main.AgentPT = CASE 
						WHEN apt.IsAutoMasterPT = 1 OR main.IsAutoMasterPT=1
							THEN main.AgentPT
						ELSE CASE 
								WHEN main.AgentPT + main.MasterPT > mpt.MasterPT
									THEN mpt.MasterPT - main.MasterPT
								ELSE main.AgentPT
								END
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
	
	--Adjust PT: a1=max(a1,0)
	UPDATE @NewPTTble
	SET AgentPT = 0 
	WHERE AgentPT < 0
	
	--Adjust PT: m1= (im2=0 ? m1 : min(um2,m3-a1))
	UPDATE main
	SET main.MasterPT = CASE 
							WHEN main.IsAutoMasterPT = 0 AND apt.IsAutoMasterPT = 0
								THEN main.MasterPT
							ELSE CASE 
									WHEN 
										CASE 
												WHEN main.IsAutoMasterPT = 1 THEN main.AutoMasterPT
												WHEN apt.IsAutoMasterPT = 1 THEN apt.AutoMasterPT
											END  < mpt.MasterPT - main.AgentPT
										THEN 
											CASE 
												WHEN main.IsAutoMasterPT = 1 THEN main.AutoMasterPT
												WHEN apt.IsAutoMasterPT = 1 THEN apt.AutoMasterPT
											END
										ELSE mpt.MasterPT - main.AgentPT
									END
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
			
	--Adjust PT: s1=min((is3=is1=0 ? s1 : min(is1=1 ? us1 : us3,s4-m1-a1)))
	UPDATE main
	SET main.SuperPT = CASE 
							WHEN main.IsAutoSuperPT = 0 AND mpt.IsAutoSuperPT = 0
								THEN main.SuperPT
							ELSE CASE 
									WHEN 
										CASE 
												WHEN main.IsAutoSuperPT = 1 THEN main.AutoSuperPT
												WHEN mpt.IsAutoSuperPT = 1 THEN mpt.AutoSuperPT
											END  < spt.SuperPT - main.MasterPT - main.AgentPT
										THEN 
											CASE 
												WHEN main.IsAutoSuperPT = 1 THEN main.AutoSuperPT
												WHEN mpt.IsAutoSuperPT = 1 THEN mpt.AutoSuperPT
											END
										ELSE spt.SuperPT - main.MasterPT - main.AgentPT
									END
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
	
	--Adjust PT : Update s1 = min (s1, (is3=1||is1=1) ? s4 : s4-m1-a1)
	UPDATE main
	SET main.SuperPT =
						CASE WHEN
								CASE 
									WHEN main.IsAutoSuperPT = 0 AND mpt.IsAutoSuperPT = 0
										THEN spt.SuperPT - main.MasterPT - main.AgentPT
									ELSE 
										spt.SuperPT
								END > main.SuperPT
								THEN main.SuperPT
								ELSE
									CASE 
									WHEN main.IsAutoSuperPT = 0 AND mpt.IsAutoSuperPT = 0
										THEN spt.SuperPT - main.MasterPT - main.AgentPT
									ELSE 
										spt.SuperPT
								END
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
								, @PT_XML = @AdjustedPT_XML
								, @CorrectedPT_XML = @CorrectedPT_XML OUTPUT
			
								
	DELETE FROM @NewPTTble
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @CorrectedPT_XML

	INSERT @NewPTTble
			(SportType 
			, BetType 
			, IsLive 
			, SuperPT 
			, MasterPT 
			, AgentPT 
			, IsAutoMasterPT 
			, AutoMasterPT 
			, IsAutoSuperPT 
			, AutoSuperPT )
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
			main.AgentPT=npt.AgentPT
		FROM dbo.CustPTSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		JOIN @tblCust cust ON main.CustID=cust.CustID
		JOIN @NewPTTble npt ON  npt.SportType=main.SportType
		AND npt.BetType=main.BetType
		AND npt.IsLive=main.IsLive
		WHERE 
		npt.SuperPT <> main.SuperPT
		OR npt.MasterPT <> main.MasterPT
		OR npt.AgentPT <> main.AgentPT
		
		
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
			main.AgentPT=npt.AgentPT
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
	SELECT @Old_PT_XML = (SELECT SportType,BetType,IsLive,AgentPT
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
			, @ActionID			= 450
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 450
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] TO [bodbExtAccNet]