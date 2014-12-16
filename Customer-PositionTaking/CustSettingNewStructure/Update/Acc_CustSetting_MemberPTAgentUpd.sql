/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTAgentUpd] 
	  @CustID		INT
	, @PT_XML		VARCHAR(MAX)
	
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @UserID		INT				= 0
	, @Language		VARCHAR(20)		= 'E'
	, @Username		VARCHAR(30)		= ''
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(4000)	= ''	OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-15
		Task: Agent update member's PT
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
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
	DECLARE @AdjustedPT_XML VARCHAR(MAX)=NULL
		
	DECLARE @ErrType	NVARCHAR(4000)
		, @AgentID		INT
		, @MasterID		INT
		, @SuperID		INT
		, @RoleID		INT
		
	DECLARE @NewPTTble TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, ISLive			BIT
		, AgentPT			TINYINT
		, AgentPT_Max		TINYINT
		, AgentAPT_Max		TINYINT
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
		RETURN

	SET @startRun = GETDATE()

	SELECT @ErrCode = 0
		, @ErrMsg = ''


	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging @SessionCustID = @Userid
		, @Custid = @custid
		, @Username = @Username OUTPUT
		, @roleid = @roleid OUTPUT

	IF (@roleid = 0)
		RETURN

			
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
	, @ErrCode = @ErrCode OUTPUT
	, @ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT_XML

	INSERT @NewPTTble
	SELECT SportType,BetType,IsLive,AgentPT,0,0
			,0,0,0,0,0,0
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType	SMALLINT
			, BetType	SMALLINT
			, IsLive	BIT
			, AgentPT	TINYINT
			)

	EXEC sp_xml_removedocument @iDoc
			
	--get line infor
	SELECT @SuperID = srecommend
			, @MasterID = mrecommend
			, @AgentID = recommend
	FROM custinfo ci WITH(NOLOCK)
	WHERE ci.custid = @CustID
	
	--Get member's setting to be adjusted
	UPDATE main
	SET  main.SuperPT = cs.SuperPT
		, main.MasterPT = cs.MasterPT
		, main.IsAutoSuperPT =cs.IsAutoSuperPT
		, main.AutoSuperPT = cs.AutoSuperPT
		, main.IsAutoMasterPT = cs.IsAutoMasterPT
		, main.AutoMasterPT = cs.AutoMasterPT
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.CustID=@CustID
			
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
	JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.CustID=@CustID	
			
	--Check error		
	EXEC [dbo].Acc_CustSetting_MemberPTUpdCheck 
						@CustID = @CustID
						, @RoleID		= 2
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @PT_XML		= @PT_XML
						, @Language		= @Language
						, @ErrCode		= @ErrCode	OUT
						, @ErrMsg		= @ErrMsg	OUT

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
	
	--Get total members that are different from group
	IF NOT EXISTS (SELECT TOP 1 1
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
	
	
	SELECT @AdjustedPT_XML = (SELECT SportType,BetType,IsLive,SuperPT,MasterPT,AgentPT
	FROM @NewPTTble
	FOR XML RAW ('PT'))

	SELECT @AdjustedPT_XML = '<ROOT>'+@AdjustedPT_XML+'</ROOT>'
	
	--Call execrep to update member PT		
	EXEC dbo.Acc_CustSetting3rd_08
			@CustID = @CustID,
			@roleid = 2,
			@mode = 'Others',
			@AdjustedPT_XML=@AdjustedPT_XML
			
	--Call execrept to correct PT		
	EXEC dbo.Acc_CustSetting3rd_00
		@CustID = @CustID, 
		@recommend = @AgentID, 
		@mrecommend = @MasterID, 
		@srecommend = @SuperID,
		@mode = 'Others'
		
		
	--START LOGGING		
	SET @xml = (
			SELECT @CustID AS '@c'
				, @UserID AS '@u'
				, @IP AS '@i'
				, dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, IsLive AS '@i'
						, AgentPT AS '@apt'
					FROM @OldPTTble
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	SET @xml = (
			SELECT @CustID AS '@c'
				, @UserID AS '@u'
				, dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, IsLive AS '@i'
						, AgentPT AS '@apt'
					FROM @NewPTTble
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= @CustID
						, @ActionID			= 453
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= @CustID
						, @ActionID			= 453
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END CATCH
END
