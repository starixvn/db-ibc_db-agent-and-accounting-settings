SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTCheck] 
	  @CustID			INT 
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @PT_XML			VARCHAR(MAX)
	
	, @Language			VARCHAR(2)		= 'E'
	, @ErrCode			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(4000)	= ''	OUTPUT
AS
/*
	Created: 20141210@Dominic
	Task : Check Member's PT when SMA update member
	DB: DBTXN/CustDB
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

	DECLARE @ErrType	NVARCHAR(4000)
		
	SELECT @ErrCode = 0
		, @ErrMsg = ''
		
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
		, AutoSuperPT		TINYINT)
		
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

	EXEC sp_xml_removedocument @iDoc
	
	SELECT @IsGrouped=IsGrouped
	FROM dbo.CustSettingMode3rd WITH(NOLOCK)
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
			JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
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
			JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
	
		--Check range		
		--Get error sport
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
					+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName + ','
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
						END
		FROM @NewPTTble mempt
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType=mempt.SportType
				AND pdt.BetType=mempt.BetType
				AND pdt.IsLive=mempt.IsLive
				AND pdt.SettingType = 1
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.AgentPT < 0 OR mempt.AgentPT > pdt.MaxPT
			
		if @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 101
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) 
						end
						+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
			
		
		--check n2<=a1<=l2
		SELECT @ErrType = ''
		select @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+  CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
				+ cast((apt.MinPT) as varchar(10))
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((apt.MaxPT) as varchar(10))
				+ ','

		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType=mempt.SportType
					AND apt.BetType=mempt.BetType
					AND apt.IsLive=mempt.IsLive
					AND apt.CustID=@AgentID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.AgentPT > apt.MaxPT OR mempt.AgentPT < apt.MinPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 102
			
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (min/max set by company).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language)
								end
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
		
		--check a1<=min(a2,a4)
		SELECT @ErrType = ''
		select @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((spt.AgentPT) as varchar(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType=mempt.SportType
				AND spt.BetType=mempt.BetType
				AND spt.IsLive=mempt.IsLive
				AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE  mempt.AgentPT > spt.AgentPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 103
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (max set by company).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language)
								end
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
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
		JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType=main.SportType
				AND apt.BetType=main.BetType
				AND apt.IsLive=main.IsLive
				AND apt.CustID=@AgentID 
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
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
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType=main.SportType
				AND spt.BetType=main.BetType
				AND spt.IsLive=main.IsLive
				AND spt.CustID=@SuperID
		
		--Get a1_max
		UPDATE @NewPTTble
		SET AgentPT_Max = CASE WHEN AgentPT_Max <= AgentAPT_Max THEN AgentPT_Max ELSE AgentAPT_Max END
		
		
		--check a1 <= min(a4,a2,l2, im2=1|im1=1 ? a2 : is1=1|is3=1 ? m3-m1 : min(m3-m1, s4-s1-m1))
		select @ErrType = ''
		select @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=1 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((mempt.AgentPT_Max) as varchar(10))
				+ ','
		FROM @NewPTTble mempt 
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.AgentPT > mempt.AgentPT_Max
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 104
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (max set by upline).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language)
								end
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
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
			JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
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
			JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
		
		
		--Check range		
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
					+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName + ','
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
						END
		FROM @NewPTTble mempt
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.MasterPT < 0 OR mempt.MasterPT > pdt.MaxPT
			OR mempt.AutoMasterPT < 0 OR mempt.AutoMasterPT > pdt.MaxPT
			
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 105
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								end
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
		
		--if im1=1 then um1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ CAST((mpt.MaxPT) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoMasterPT = 1
				AND mempt.AutoMasterPT > mpt.MaxPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 106
			
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language)
							END
							+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			RETURN
		END
		
		--if im1=1 then um1<=min(m3,m4)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ CAST((CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoMasterPT = 1 
			AND mempt.AutoMasterPT > CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
			
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 107
			
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language)
								END		
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END								
			RETURN
		END
		
		--if im1=1 then um1>= max(n3 - a1,0)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
				+ CAST((CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType=mempt.SportType
				AND mpt.BetType=mempt.BetType
				AND mpt.IsLive=mempt.IsLive
				AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoMasterPT=1 
			AND mempt.AutoMasterPT<CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 108
			
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language)
								END		
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END		
			RETURN
		END
		
		--m1<=min(m3,m4)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+  CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ CAST((CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.MasterPT>CASE WHEN mpt.MasterPT < spt.MasterPT THEN mpt.MasterPT ELSE spt.MasterPT END
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 109
			
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END		
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END									
			RETURN
		END
			
			
		--m1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+  CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
					+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
					+ CAST((mpt.MaxPT) AS VARCHAR(10))
					+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.MasterPT>mpt.MaxPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 110
			
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language)
								END
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			RETURN
		END
		
		
		--if im1=0 and im2=0 then m1<=m3-a1
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ CAST((mpt.MasterPT - mempt.AgentPT) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType=mempt.SportType
					AND apt.BetType=mempt.BetType
					AND apt.IsLive=mempt.IsLive
					AND apt.CustID=@AgentID
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.MasterPT > mpt.MasterPT - mempt.AgentPT and mempt.IsAutoMasterPT = 0 and apt.IsAutoMasterPT = 0
		
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 111
			
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END							
							+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			RETURN
		END
			
		--if im2=0 and im1=0 then m1>=max(n3 - a1,0)	
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
				+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) 
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
				+ CAST((CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END) AS VARCHAR(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent apt WITH (NOLOCK)
			ON apt.SportType=mempt.SportType
					AND apt.BetType=mempt.BetType
					AND apt.IsLive=mempt.IsLive
					AND apt.CustID=@AgentID
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.MasterPT < CASE WHEN mpt.MinPT - mempt.AgentPT < 0 THEN 0 ELSE mpt.MinPT - mempt.AgentPT END 
			and mempt.IsAutoMasterPT = 0 and apt.IsAutoMasterPT = 0	
			
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 112
			
			SELECT @ErrMsg = CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END							
							+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			RETURN
		END
		
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
			JOIN dbo.CustPTGroupSetting3rd_Member cs WITH (NOLOCK)
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
			JOIN dbo.CustPTSetting3rd_Member cs WITH (NOLOCK)
			ON cs.SportType=main.SportType
					AND cs.BetType=main.BetType
					AND cs.IsLive=main.IsLive
					AND cs.CustID=@CustID
		END
		
		--Check range
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
						+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName + ','
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
						END
		FROM @NewPTTble mempt
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.SuperPT < 0 OR mempt.SuperPT > pdt.MaxPT
			OR mempt.AutoSuperPT < 0 OR mempt.AutoSuperPT > pdt.MaxPT
			
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 113
			
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								end
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
		
		
		--if is1=1 then us1<=l4
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
			+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName + ','
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) + ','
						END
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoSuperPT = 1 AND mempt.AutoSuperPT > spt.MaxPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 114
			
			SELECT @ErrMsg =case @Language 
									WHEN 'E' THEN 'Wrong auto position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language)
								END			
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END		
			return
		END
			
		--if is1=1 then us1<=s4
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
			+CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((spt.SuperPT) AS varchar(10)) 
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoSuperPT = 1 AND mempt.AutoSuperPT > spt.SuperPT 
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 115
			
			SELECT @ErrMsg =case @Language 
									WHEN 'E' THEN 'Wrong auto position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language)
								END		
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END				
			return
		END
		
		--if is1=1 then us1>=max(n4-m1-a1,0)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
			+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END	
				+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
				+ cast((CASE WHEN spt.SuperPT-mempt.MasterPT-mempt.AgentPT > 0 
												THEN spt.SuperPT-mempt.MasterPT-mempt.AgentPT 
												ELSE 0
												END) AS varchar(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoSuperPT = 1 
			AND mempt.AutoSuperPT < CASE WHEN spt.SuperPT-mempt.MasterPT-mempt.AgentPT > 0 
											THEN spt.SuperPT-mempt.MasterPT-mempt.AgentPT 
											ELSE 0
											END	
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 116
			
			SELECT @ErrMsg =
								case @Language 
									WHEN 'E' THEN 'Wrong auto position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language)
								END		
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END		
			return
		END	
		
		
		--s1<=s4
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
					+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END	
					+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
					+ cast((spt.SuperPT) AS varchar(10))
					+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.SuperPT > spt.SuperPT
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 117
			
			SELECT @ErrMsg =	
								case @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
		
		--if is1=0 AND is3=0 then s1<=max(min(s4,l4) - m3,max(n4-m1-a1,0))
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
			+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END	
				+ CASE WHEN mempt.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END
				+ cast((CASE 
						WHEN CASE 
								WHEN spt.SuperPT < spt.MaxPT
									THEN spt.SuperPT
								ELSE spt.MaxPT
								END - mpt.MasterPT > CASE 
								WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
									THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
								ELSE 0
								END
							THEN CASE 
									WHEN spt.SuperPT < spt.MaxPT
										THEN spt.SuperPT
									ELSE spt.MaxPT
									END - mpt.MasterPT
						ELSE CASE 
								WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
									THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
								ELSE 0
								END
					END) AS varchar(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoSuperPT = 0 AND mempt.IsAutoSuperPT = 0
			AND mempt.SuperPT >  
				CASE 
					WHEN CASE 
							WHEN spt.SuperPT < spt.MaxPT
								THEN spt.SuperPT
							ELSE spt.MaxPT
							END - mpt.MasterPT > CASE 
							WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
								THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
							ELSE 0
							END
						THEN CASE 
								WHEN spt.SuperPT < spt.MaxPT
									THEN spt.SuperPT
								ELSE spt.MaxPT
								END - mpt.MasterPT
					ELSE CASE 
							WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
								THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
							ELSE 0
							END
				END
		
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 118
			
			SELECT @ErrMsg =
								case @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
		
		--if is1=0 AND is3=0 then s1>=max(n4-m1-a1,0)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
			+ CASE WHEN pdt.ErrMsgLevel = 1 THEN ''
							WHEN pdt.ErrMsgLevel = 2
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
							WHEN pdt.ErrMsgLevel = 3
									THEN bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
							WHEN pdt.ErrMsgLevel = 4
									THEN p.ProductName 
							WHEN pdt.ErrMsgLevel = 5
									THEN [dbo].[f_Get_SportNameBySporttype](mempt.SportType, @Language)
										+ ' - '
										+ bodb02.[dbo].[F_Get_BetNameByTypeID](mempt.BetType, @Language) 
						END	
				+ CASE WHEN mempt.IsLive=0 THEN '-Min: ' ELSE '-MinLive: ' END
				+ cast((CASE 
								WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
									THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
								ELSE 0
								END ) AS varchar(10))
				+ ','
		FROM @NewPTTble mempt
		JOIN dbo.CustPTSetting3rd_Agent spt WITH (NOLOCK)
			ON spt.SportType=mempt.SportType
					AND spt.BetType=mempt.BetType
					AND spt.IsLive=mempt.IsLive
					AND spt.CustID=@SuperID
		JOIN dbo.CustPTSetting3rd_Agent mpt WITH (NOLOCK)
			ON mpt.SportType=mempt.SportType
					AND mpt.BetType=mempt.BetType
					AND mpt.IsLive=mempt.IsLive
					AND mpt.CustID=@MasterID
		JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
			ON pdt.SportType = mempt.SportType
				AND pdt.BetType = mempt.BetType
				AND pdt.IsLive = mempt.IsLive
				AND pdt.SettingType = 1		
		JOIN bodb02.dbo.Products p WITH (NOLOCK)
			ON p.ProductID = pdt.ProductID
		WHERE mempt.IsAutoSuperPT = 0 AND mempt.IsAutoSuperPT = 0
			AND mempt.SuperPT < CASE 
									WHEN spt.MinPT - mempt.MasterPT - mempt.AgentPT > 0
										THEN spt.MinPT - mempt.MasterPT - mempt.AgentPT
									ELSE 0
								END 
		IF @@ROWCOUNT > 0
		BEGIN
			IF @ErrType <>''
				SET @ErrType = LEFT(@ErrType, LEN(@ErrType) - 1)
			select @ErrCode = 119
			
			SELECT @ErrMsg =	
								case @Language 
									WHEN 'E' THEN 'Wrong  position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END
								+ CASE WHEN @ErrType <> '' THEN ' (' + @ErrType + ')' ELSE '' END
			return
		END
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCheck] TO [bodbExtAccNet]