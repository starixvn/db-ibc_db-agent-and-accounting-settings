SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTUpdCheck] 
	@CustID				INT = NULL
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @PT_XML			VARCHAR(MAX)
	
	, @Language			VARCHAR(2)		= 'E'
	, @ErrCode			VARCHAR(300)	= ''	OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20141210@Dominic
	Task : Check Member's PT when SMA update member
	DB: DBCUST/CUSTDB
	Original:

	Param's Explanation:
	• @PT_XML:
				<ROOT>
						<PT 
								SportType="1" 
								BetType="1" 
								IsLive="1" 
								SuperPT="10"
								MasterPT="10"
								AgentPT="10" 
								IsAutoSuperPT="1"
								AutoSuperPT="10"
								IsAutoMasterPT="1"
								AutoMasterPT="10"
								
						/>
				</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrCode_Cur INT
		, @ErrMsg_Cur NVARCHAR(4000)
		, @ErrType	NVARCHAR(4000)
		
	SELECT @ErrCode_Cur = 0
		, @ErrMsg_Cur = ''
		, @ErrCode = ''
		, @ErrMsg = ''
		
	DECLARE @NewPTTble TABLE (
		SportType SMALLINT
		, BetType SMALLINT
		, IsLive BIT
		, SuperPT TINYINT
		, MasterPT TINYINT
		, AgentPT TINYINT
		, AgentPT_Max TINYINT
		, AgentAPT_Max TINYINT
		, IsAutoMasterPT TINYINT
		, AutoMasterPT TINYINT
		, IsAutoSuperPT BIT
		, AutoSuperPT TINYINT)
		
	DECLARE @IsGrouped BIT = 0
	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT_XML

	INSERT @NewPTTble
	SELECT SportType 
		, BetType 
		, IsLive 
		, SuperPT 
		, MasterPT 
		, AgentPT 
		, 0 
		, 0 
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
	
	SELECT @IsGrouped=IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID=@CustID

			
	IF @RoleID = 2
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.MasterPT = cs.MasterPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
				, main.IsAutoMasterPT = cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
			JOIN dbo.CustPTGroupSetting3rd_Member cs
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.AgentID=@AgentID
		END
		ELSE
		BEGIN
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.MasterPT = cs.MasterPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
				, main.IsAutoMasterPT = cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
			JOIN dbo.CustPTSetting3rd_Member cs
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
	
	
		--Check range
		IF EXISTS(
			SELECT TOP 1 1
			FROM @NewPTTble mempt
			JOIN dbo.ProductSettingDetail pdt
			ON pdt.SportType=mempt.SportType
				AND pdt.BetType=mempt.BetType
				AND pdt.IsLive=mempt.IsLive
			WHERE mempt.AgentPT < 0 OR mempt.AgentPT > pdt.MaxPT)
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
		
		--check n2<=a1<=l2
		SELECT @ErrType = ''
		select @ErrType = @ErrType + sportname + '-'+ typenamee 
			+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
			+ cast((apt.MinPT) as varchar(10))
			+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
			+ cast((apt.MaxPT) as varchar(10))
			+ '<br>'
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent apt
		ON apt.SportType=mempt.SportType
				AND apt.BetType=mempt.BetType
				AND apt.IsLive=mempt.IsLive
				AND apt.CustID=@AgentID
		INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
		INNER JOIN bodb02.dbo.sports s with(nolock) on mempt.sporttype = s.sporttype
		WHERE mempt.AgentPT > apt.MaxPT OR mempt.AgentPT < apt.MinPT
		
		if @ErrType <>''
		BEGIN
			select @ErrCode = 6
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						end
			return
		END
		
		--check a1<=min(a2,a4)
		SELECT @ErrType = ''
		select @ErrType = @ErrType + sportname + '-'+ typenamee 
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((spt.AgentPT) as varchar(10))
				+ '<br>'
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=mempt.SportType
				AND spt.BetType=mempt.BetType
				AND spt.IsLive=mempt.IsLive
				AND spt.CustID=@SuperID
		INNER JOIN bodb02.dbo.sports s with (nolock) on mempt.sporttype = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt with (nolock) on mempt.bettype = bt.typeid
		WHERE  mempt.AgentPT > spt.AgentPT
		
		IF @ErrType <>''
		BEGIN
			select @ErrCode = 7
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
						end
			return
		END
		
		--Get min(a4,a2,l2)
		UPDATE main
		SET AgentPT_Max = CASE
								WHEN apt.AgentPT <= apt.MaxPT AND apt.AgentPT <= spt.AgentPT THEN apt.AgentPT
								WHEN apt.MaxPT <= apt.AgentPT AND apt.MaxPT <= spt.AgentPT THEN apt.MaxPT
								ELSE spt.AgentPT
						END
		FROM @NewPTTble main
		JOIN dbo.CustPTSetting3rd_Agent apt
		ON apt.SportType=main.SportType
				AND apt.BetType=main.BetType
				AND apt.IsLive=main.IsLive
				AND apt.CustID=@AgentID 
		JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
				
		--Get iff(im,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
		UPDATE main
		SET AgentAPT_Max = CASE 
								WHEN (
										apt.IsAutoMasterPT = 1
										OR main.IsAutoMasterPT = 1
										)
									THEN apt.AgentPT
								ELSE CASE 
										WHEN NOT (
												main.IsAutoSuperPT = 0
												AND mpt.IsAutoSuperPT = 0
												)
											THEN mpt.MasterPT - main.MasterPT
										ELSE CASE 
												WHEN mpt.MasterPT - main.MasterPT <= spt.SuperPT - main.SuperPT - main.MasterPT
													THEN mpt.MasterPT - main.MasterPT
												ELSE spt.SuperPT - main.SuperPT - main.MasterPT
												END
										END
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
		JOIN dbo.CustPTSetting3rd_Agent spt
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
		
		--Get a1_max
		UPDATE @NewPTTble
		SET AgentPT_Max = CASE WHEN AgentPT_Max <= AgentAPT_Max THEN AgentPT_Max ELSE AgentAPT_Max END
		
		
		--check a1 <= min(a4,a2,l2, im2=1|im1=1 ? a2 : is1=1|is3=1 ? m3-m1 : min(m3-m1, s4-s1-m1))
		select @ErrType = ''
		select @ErrType = @ErrType + sportname + '-'+ typenamee 
				+ CASE WHEN mpt.IsLive=1 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((mpt.AgentPT_Max) as varchar(10))
				+ '<br>'
		FROM @NewPTTble mpt 
		INNER JOIN bodb02.dbo.sports s with (nolock) on mpt.sporttype = s.sporttype
			INNER JOIN bodb02.dbo.bettype bt with (nolock) on mpt.bettype = bt.typeid
		WHERE mpt.AgentPT > mpt.AgentPT_Max
		
		IF @ErrType <>''
		BEGIN
			select @ErrCode = 100
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
						end
			return
		END
	END
	ELSE IF @RoleID=3
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
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
		END
		ELSE
		BEGIN
			UPDATE main
			SET  main.SuperPT = cs.SuperPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoSuperPT =cs.IsAutoSuperPT
				, main.AutoSuperPT = cs.AutoSuperPT
			FROM @NewPTTble main
			JOIN dbo.CustPTSetting3rd_Member cs
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
		
		
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
	END
	ELSE IF @RoleID = 4
	BEGIN
		--Get member's setting to be adjusted
		IF @IsGrouped = 1
		BEGIN
			UPDATE main
			SET  main.MasterPT = cs.MasterPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoMasterPT =cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
			JOIN dbo.CustPTGroupSetting3rd_Member cs
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.AgentID=@AgentID
		END
		ELSE
		BEGIN
			UPDATE main
			SET  main.MasterPT = cs.MasterPT
				, main.AgentPT = cs.AgentPT
				, main.IsAutoMasterPT =cs.IsAutoMasterPT
				, main.AutoMasterPT = cs.AutoMasterPT
			FROM @NewPTTble main
			JOIN dbo.CustPTSetting3rd_Member cs
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
		
		--Check range
		--Check range
		IF EXISTS(
			SELECT TOP 1 1
			FROM @NewPTTble mempt
			JOIN dbo.ProductSettingDetail pdt
			ON pdt.SportType=mempt.SportType
				AND pdt.BetType=mempt.BetType
				AND pdt.IsLive=mempt.IsLive
			WHERE mempt.SuperPT < 0 OR mempt.SuperPT > pdt.MaxPT)
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
		
		
		--if is1=1 then us1<=l4
		
		
		--us1<=s4
		
		--if is1=1 then us1>=max(n4-m1-a1,0)
		
		--s1<=s4
		
		
		--if is1=0 AND is3=0 then s1<=max(min(s4,l4) - m3,max(n4-m1-a1,0))
		
		
		--if is1=0 AND is3=0 then s1>=max(n4-m1-a1,0)
		
		
	END
END
