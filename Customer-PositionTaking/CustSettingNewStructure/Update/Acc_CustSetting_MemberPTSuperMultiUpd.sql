/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 11/28/2013 14:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTSuperMultiUpd] 
	  @CustIDLst VARCHAR(4000)
	, @PT_XML VARCHAR(MAX)
	, @SubAccID INT = 0
	, @IP VARCHAR(50) = ''
	, @UserID INT = 0
	, @Language VARCHAR(20) = 'E'
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
		Created: Dominic
		Date: 2014-12-10
		Task: Super multiple update grouped member's PT
		DB: DBCUST/CUSTDB

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
		
	DECLARE @ErrCode_Cur INT
		, @ErrMsg_Cur NVARCHAR(4000)
		, @ErrType	NVARCHAR(4000)
		, @AgentID INT
		, @MasterID INT
		, @SuperID INT
		, @RepresentCustID INT
		, @RoleID INT
		, @TotalCount DECIMAL = 0
		, @DiffCount INT = 0
		, @MoveToIndv BIT = 0
	
	DECLARE @Old_PT_XML VARCHAR(MAX)
		
	DECLARE @tblCust TABLE (CustID INT)
	
	DECLARE @NewPTTble TABLE (
		SportType SMALLINT
		, BetType SMALLINT
		, ISLive BIT
		, AgentPT TINYINT
		, SuperPT TINYINT
		, MasterPT TINYINT
		, IsAutoSuperPT BIT
		, AutoSuperPT TINYINT
		, IsAutoMasterPT TINYINT
		, AutoMasterPT TINYINT
		)
	DECLARE @OldPTTble TABLE (
		SportType SMALLINT
		, BetType SMALLINT
		, IsLive BIT
		, SuperPT TINYINT
		, AgentPT TINYINT
		, MasterPT TINYINT
		, IsAutoSuperPT BIT
		, AutoSuperPT TINYINT
		, IsAutoMasterPT TINYINT
		, AutoMasterPT TINYINT
		)

	--Check if XML is null or empty
	IF @PT_XML IS NULL
		OR @PT_XML = ''
		OR @CustIDLst IS NULL
		OR @CustIDLst = ''
		RETURN

	SET @startRun = GETDATE()

	SELECT @ErrCode_Cur = 0
		, @ErrMsg_Cur = ''
		, @ErrCode = ''
		, @ErrMsg = ''


	--Parse affected Customer
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@CustIDLst, ',')

			
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustSetting_MultiCustEnableCheck @CustIDLst = @CustIDLst
		, @ErrCode = @ErrCode_Cur OUTPUT
		, @ErrMsg = @ErrMsg_Cur OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
			, @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

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
			,0
			,MasterPT
			,0
			,0
			,IsAutoMasterPT
			,AutoMasterPT
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, MasterPT TINYINT
			, IsAutoMasterPT BIT
			, AutoMasterPT TINYINT
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
	JOIN dbo.CustPTGroupSetting3rd_Member cs
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
	JOIN dbo.CustPTGroupSetting3rd_Member cs
	ON cs.SportType=main.SportType
			AND cs.BetType=main.BetType
			AND cs.IsLive=main.IsLive
			AND cs.AgentID=@AgentID	
			
			
			
	--Check range
	IF EXISTS(
		SELECT TOP 1 1
		FROM @NewPTTble mempt
		JOIN dbo.ProductSettingDetail pdt
		ON pdt.SportType=mempt.SportType
			AND pdt.BetType=mempt.BetType
			AND pdt.IsLive=mempt.IsLive
		WHERE mempt.MasterPT < 0 OR mempt.MasterPT > pdt.MaxPT)
	BEGIN
		SELECT @ErrMsg_Cur = 
						CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						END, @ErrCode_Cur = 100
						
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		
		RETURN	
	END
	
	--if im1=1 then um1<=l3
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ CAST((mpt.MaxPT) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent mpt
	ON mpt.SportType=mempt.SportType
			AND mpt.BetType=mempt.BetType
			AND mpt.IsLive=mempt.IsLive
			AND mpt.CustID=@MasterID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.IsAutoMasterPT = 1
			AND mempt.AutoMasterPT > mpt.MaxPT
	
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 6,
			   @ErrMsg_cur = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
					END
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

		RETURN
	END
	
	--if im1=1 then um1<=min(m3,m4)
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ CAST((CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
	JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=mempt.SportType
				AND spt.BetType=mempt.BetType
				AND spt.IsLive=mempt.IsLive
				AND spt.CustID=@SuperID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.IsAutoMasterPT = 1 
		AND mempt.AutoMasterPT > CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
		
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 7,
			   @ErrMsg_cur = CASE @Language 
								WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							END		
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
									
		RETURN
	END
	
	--if im1=1 then um1>= max(n3 - a1,0)
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
			+ CAST((CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent mpt
	ON mpt.SportType=mempt.SportType
			AND mpt.BetType=mempt.BetType
			AND mpt.IsLive=mempt.IsLive
			AND mpt.CustID=@MasterID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.IsAutoMasterPT=1 
		AND mempt.AutoMasterPT<CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END
	
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 11,
			   @ErrMsg_cur = CASE @Language 
								WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							END		
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
									
		RETURN
	END
	
	--m1<=min(m3,m4)
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ CAST((CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
	JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=mempt.SportType
				AND spt.BetType=mempt.BetType
				AND spt.IsLive=mempt.IsLive
				AND spt.CustID=@SuperID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.MasterPT>CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
	
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 8,
				@ErrMsg_cur = CASE @Language 
								WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							END							
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
		RETURN
	END
		
		
	--m1<=l3
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ CAST((mpt.MaxPT) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.MasterPT>mpt.MaxPT
	
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 9,
				@ErrMsg_cur = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
					END
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		RETURN
	END
	
	
	--if im1=0 and im2=0 then m1<=m3-a1
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ CAST((mpt.MasterPT - mempt.AgentPT) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent apt
		ON apt.SportType=mempt.SportType
				AND apt.BetType=mempt.BetType
				AND apt.IsLive=mempt.IsLive
				AND apt.CustID=@AgentID
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.MasterPT > mpt.MasterPT - mempt.AgentPT and mempt.IsAutoMasterPT = 0 and apt.IsAutoMasterPT = 0
	
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode_cur = 10,
				@ErrMsg_cur = CASE @Language 
								WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							END							
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
		RETURN
	END
		
	--if im2=0 and im1=0 then m1>=max(n3 - a1,0)	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
			+ CAST((CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END) AS VARCHAR(10))
			+ '<br>'
	FROM @NewPTTble mempt
	JOIN dbo.CustPTSetting3rd_Agent apt
		ON apt.SportType=mempt.SportType
				AND apt.BetType=mempt.BetType
				AND apt.IsLive=mempt.IsLive
				AND apt.CustID=@AgentID
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
	INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
	WHERE mempt.MasterPT < CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END 
		and mempt.IsAutoMasterPT = 0 and apt.IsAutoMasterPT = 0	
		

	
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
							ELSE main.AgentPT
						END
	FROM @NewPTTble main
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
				
				
	--Adjust PT: m1=m1+a1<n3?n3-a1:m1
	UPDATE main
	SET main.MasterPT = CASE WHEN main.MasterPT < mpt.MinPT - main.AgentPT THEN mpt.MinPT - main.AgentPT ELSE main.MasterPT END
	FROM @NewPTTble main
		JOIN dbo.CustPTSetting3rd_Agent mpt
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
	JOIN dbo.CustPTSetting3rd_Agent apt
		ON apt.SportType=main.SportType
				AND apt.BetType=main.BetType
				AND apt.IsLive=main.IsLive
				AND apt.CustID=@AgentID
	JOIN dbo.CustPTSetting3rd_Agent mpt
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
	JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
	JOIN dbo.CustPTSetting3rd_Agent mpt
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
	JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
	JOIN dbo.CustPTSetting3rd_Agent mpt
		ON mpt.SportType=main.SportType
				AND mpt.BetType=main.BetType
				AND mpt.IsLive=main.IsLive
				AND mpt.CustID=@MasterID
	
	
	
	--Get total members that belong to Group
	SELECT @TotalCount = ISNULL(COUNT(1),0)
	FROM dbo.CustSettingMode3rd mode
	JOIN dbo.CustInfo ci ON ci.CustID=mode.CustID
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
		OR npt.IsAutoMasterPT <> opt.IsAutoMasterPT
		OR npt.AutoMasterPT <> opt.AutoMasterPT
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
			@CustIDLst = @CustIDLst,
			@roleid = 3,
			@mode = 'Others',
			@AdjustedPT_XML=@AdjustedPT_XML,
			@MoveToIndv=@MoveToIndv
			
	--Call execrept to correct PT		
	EXEC dbo.Acc_CustSetting3rd_09
		@CustIDLst = @CustIDLst, 
		@recommend = @AgentID, 
		@mrecommend = @MasterID, 
		@srecommend = @SuperID,
		@MoveToIndv=@MoveToIndv,
		@mode = 'Others'
		
	--START LOGGING		

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDLst		= @CustIDLst
			, @ActionID			= 450
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP_MultiCust 
			@UserID				= @UserID
			, @CustIDLst		= @CustIDLst
			, @ActionID			= 450
			, @NewPT_XML		= @PT_XML
			, @OldPT_XML		= @Old_PT_XML
			, @duration			= @duration
	END CATCH
END
