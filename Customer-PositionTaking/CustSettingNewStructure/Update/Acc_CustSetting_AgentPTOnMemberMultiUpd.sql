/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTOnMemberMultiUpd] 
	  @CustIDList	VARCHAR(MAX)
	, @PT			VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @UserID		INT				= 0
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(4000)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-08
		Task: Agent multiple update member's PT
		DB: DBCUST/CustDB

		Parameter's Explanation:	
		• @PT:
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
--******************************************VARIABLE DECLARATION*************************************** 
	--Logs
	DECLARE @StartRun	DATETIME
		, @EndRun		DATETIME
		, @Duration		INT
		, @Old_PT_XML	VARCHAR(MAX)
		
	--Temp variables for PT adjustment
	DECLARE @mpos SMALLMONEY
		, @apos SMALLMONEY
		, @spos SMALLMONEY
		, @mapos1 SMALLMONEY
		, @mapos2 SMALLMONEY
		, @mapos SMALLMONEY
		, @maxspos SMALLMONEY
		, @maxmapos SMALLMONEY
	
	--Temp variables for PT adjustment		
	DECLARE @ErrType		NVARCHAR(4000)
		, @AgentID			INT
		, @MasterID			INT
		, @SuperID			INT
		, @RepresentCustID	INT
		, @RoleID			INT
	
	--List of customers		
	DECLARE @tblCust TABLE (CustID INT)
	
	--Temp table variables being used for calculation
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

--******************************************PERMISSION CHECKING*************************************** 			
	--Check if XML is null or empty
	IF @PT IS NULL
		OR @PT = ''
		OR @CustIDList IS NULL
		OR @CustIDList = ''
		RETURN

	SET @StartRun = GETDATE()

	SELECT @ErrCode = 0
		, @MsgType = 0
		, @ErrMsg = ''


	--Parse affected Customer
	DECLARE @XML XML
	SET @XML = N'<root><r>' + REPLACE(@CustIDList, ',', '</r><r>') + '</r></root>'
	
	INSERT INTO @tblCust (CustID)
	SELECT r.value('.','INT')
	FROM @xml.nodes('//root/r') AS RECORDS(r)

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
	
--******************************************PREPARE SETTING FOR UPDATE*************************************** 		
	--Parse XML	
	INSERT @NewPTTble
	SELECT SportType
			,BetType
			,IsLive
			,0,0,AgentPT,0,0,0,0,0,0
	FROM dbo.f_DCS_PT_XMLParse(@PT)
			
	--Get line infor : SMA accounts
	SELECT TOP 1 @RepresentCustID=CustID
	FROM @tblCust
	
	SELECT @SuperID = srecommend
			, @MasterID = mrecommend
			, @AgentID = recommend
	FROM custinfo ci WITH(NOLOCK)
	WHERE ci.custid = @RepresentCustID
	
	--Get another member settings used for PT calcualtion
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
	
	--Backup old settings for logs
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

--******************************************VALIDATE PT VALUES*************************************** 					
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
						@CustID = @RepresentCustID
						, @RoleID		= 2
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @PT = @PT
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		
	
--******************************************ADJUST PT SETTINGS*************************************** 		
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
	
--***************************************CORRECT PT SETTINGS*******************************************	
	--if a1<n2 then a1 = n2,
	--m1 = max(m3-n2,m1)
	UPDATE main
	SET main.AgentPT = apt.MinPT
		, main.MasterPT = CASE 
			WHEN main.MasterPT + apt.MinPT > mpt.MasterPT
				THEN mpt.MasterPT - apt.MinPT
			ELSE main.MasterPT
			END
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
		INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType = main.SportType
				AND apt.BetType = main.BetType
				AND apt.IsLive = main.IsLive
				AND apt.CustID = @AgentID
	WHERE main.AgentPT < apt.MinPT

	--if a1 > l2 then a1 = l2
	UPDATE main
	SET main.AgentPT = apt.MaxPT
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType = main.SportType
				AND apt.BetType = main.BetType
				AND apt.IsLive = main.IsLive
				AND apt.CustID = @AgentID
	WHERE main.AgentPT > apt.MaxPT

	--if im2|im1 then
	--m1 = min(min(m3,m4) - a1, im1=1?um1:um2)
	UPDATE main
	SET main.MasterPT = CASE 
			WHEN spt.MasterPT > mpt.MasterPT
				THEN CASE 
						WHEN mpt.MasterPT - main.AgentPT > (
								CASE 
									WHEN main.IsAutoMasterPT = 1
										THEN main.AutoMasterPT
									ELSE apt.AutoMasterPT
									END
								)
							THEN (
									CASE 
										WHEN main.IsAutoMasterPT = 1
											THEN main.AutoMasterPT
										ELSE apt.AutoMasterPT
										END
									)
						ELSE mpt.MasterPT - main.AgentPT
						END
			ELSE CASE 
					WHEN spt.MasterPT - main.AgentPT > (
							CASE 
								WHEN main.IsAutoMasterPT = 1
									THEN main.AutoMasterPT
								ELSE apt.AutoMasterPT
								END
							)
						THEN (
								CASE 
									WHEN main.IsAutoMasterPT = 1
										THEN main.AutoMasterPT
									ELSE apt.AutoMasterPT
									END
								)
					ELSE spt.MasterPT - main.AgentPT
					END
			END
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType = main.SportType
				AND apt.BetType = main.BetType
				AND apt.IsLive = main.IsLive
				AND apt.CustID = @AgentID
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
		INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType = main.SportType
				AND spt.BetType = main.BetType
				AND spt.IsLive = main.IsLive
				AND spt.CustID = @SuperID
	WHERE apt.IsAutoMasterPT = 1
		OR main.IsAutoMasterPT = 1

	--if m1+a1 < n3 then m1=n3-a1
	UPDATE main
	SET main.MasterPT = mpt.MinPT - main.AgentPT
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
	WHERE main.AgentPT + main.MasterPT < mpt.MinPT

	--if a1+m1>l3 then
	--m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	UPDATE main
	SET @maxmapos = CASE 
			WHEN mpt.MasterPT > mpt.MaxPT
				THEN mpt.MaxPT
			ELSE mpt.MasterPT
			END
		, @mpos = CASE 
			WHEN @maxmapos - main.AgentPT < 0
				THEN 0
			ELSE @maxmapos - main.AgentPT
			END
		, main.MasterPT = @mpos
		, @apos = CASE 
			WHEN main.AgentPT + @mpos > @maxmapos
				THEN @maxmapos - @mpos
			ELSE main.AgentPT
			END
		, main.AgentPT = CASE 
			WHEN @apos < apt.MinPT
				THEN apt.MinPT
			ELSE @apos
			END
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
		INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType = main.SportType
				AND apt.BetType = main.BetType
				AND apt.IsLive = main.IsLive
				AND apt.CustID = @AgentID
	WHERE main.AgentPT + main.MasterPT > mpt.MaxPT

	--if is1= 1 or is3 = 1 then
	--s1 = min(s4-m1-a1,is1?us1:us3)
	UPDATE main
	SET main.SuperPT = CASE 
			WHEN spt.SuperPT - main.MasterPT - main.AgentPT > (
					CASE 
						WHEN main.IsAutoSuperPT = 1
							THEN main.AutoSuperPT
						ELSE mpt.AutoSuperPT
						END
					)
				THEN (
						CASE 
							WHEN main.IsAutoSuperPT = 1
								THEN main.AutoSuperPT
							ELSE mpt.AutoSuperPT
							END
						)
			ELSE spt.SuperPT - main.MasterPT - main.AgentPT
			END
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
		INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType = main.SportType
				AND spt.BetType = main.BetType
				AND spt.IsLive = main.IsLive
				AND spt.CustID = @SuperID
	WHERE (
			main.IsAutoSuperPT = 1
			OR mpt.IsAutoSuperPT = 1
			)

	--if s1+ m1 + a1< n4 then s1= n4-m1-a1
	UPDATE main
	SET main.SuperPT = spt.MinPT - main.MasterPT - main.AgentPT
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType = main.SportType
				AND spt.BetType = main.BetType
				AND spt.IsLive = main.IsLive
				AND spt.CustID = @SuperID
	WHERE 1*main.AgentPT + main.MasterPT + main.SuperPT < spt.MinPT--*1 to ignore sql exception

	--if s1+ m1 + a1> s4 then
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=MAX(iif(m1_new+a1>@mapos,@mapos-m1_new,a1), n2)
	UPDATE main
	SET @spos = CASE 
			WHEN spt.SuperPT - main.MasterPT - main.AgentPT < 0
				THEN 0
			ELSE spt.SuperPT - main.MasterPT - main.AgentPT
			END
		, SuperPT = @spos
		, @mapos1 = CASE 
			WHEN @spos + main.MasterPT + main.AgentPT > spt.SuperPT
				THEN spt.SuperPT - @spos
			ELSE main.MasterPT + main.AgentPT
			END
		, @maxmapos = CASE 
			WHEN mpt.MasterPT > mpt.MaxPT
				THEN mpt.MaxPT
			ELSE mpt.MasterPT
			END
		, @mapos2 = CASE 
			WHEN @mapos1 > @maxmapos
				THEN @maxmapos
			ELSE @mapos1
			END
		, @mapos = CASE 
			WHEN @mapos2 < mpt.MinPT
				THEN mpt.MinPT
			ELSE @mapos2
			END
		, @mpos = CASE 
			WHEN @mapos - main.AgentPT < 0
				THEN 0
			ELSE @mapos - main.AgentPT
			END
		, MasterPT = @mpos
		, @apos = CASE 
			WHEN main.AgentPT + @mpos > @mapos
				THEN @mapos - @mpos
			ELSE main.AgentPT
			END
		, AgentPT = CASE 
			WHEN @apos < apt.MinPT
				THEN apt.MinPT
			ELSE @apos
			END
	FROM @NewPTTble main
		INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType = main.SportType
				AND apt.BetType = main.BetType
				AND apt.IsLive = main.IsLive
				AND apt.CustID = @AgentID
		INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType = main.SportType
				AND mpt.BetType = main.BetType
				AND mpt.IsLive = main.IsLive
				AND mpt.CustID = @MasterID
		INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType = main.SportType
				AND spt.BetType = main.BetType
				AND spt.IsLive = main.IsLive
				AND spt.CustID = @SuperID
	WHERE 1*main.SuperPT + main.AgentPT + main.MasterPT > spt.SuperPT
	
--***************************************UPDATE PT SETTINGS*******************************************	
	--**START UPDATING DB**--	
	--Get total members that are different from group
	IF NOT EXISTS (
		SELECT TOP 1 1
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
		RETURN
	
	
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
	
--***************************************WRITE LOGS*******************************************			
	--**START LOGGING**--
	SELECT @Old_PT_XML = (SELECT SportType,BetType,IsLive,AgentPT
	FROM @OldPTTble
	FOR XML RAW ('PT'))

	SELECT @Old_PT_XML = '<ROOT>'+@Old_PT_XML+'</ROOT>'
	
	SELECT @EndRun	= GETDATE()
		, @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 450
			, @NewPT_XML		= @PT
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDList		= @CustIDList
			, @SubAccID			= @SubAccID
			, @ActionID			= 450
			, @NewPT_XML		= @PT
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