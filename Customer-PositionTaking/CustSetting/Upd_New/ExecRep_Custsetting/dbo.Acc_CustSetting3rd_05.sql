ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_05] 
	@srecommend INT = 0,
	@mrecommend INT =0,
	@recommend INT = 0,
	@roleid INT,
	@mode VARCHAR(50),
	--update auto pt on master
	-- number game	
	@isauto_v161spositiontaking_81 bit = 0,
	@isauto_v161spositiontaking_83 bit = 0,	
	@isauto_v161spositiontaking_86 bit = 0,
	@isauto_v161spositiontaking_88 bit = 0,
	
	@isauto_v161slivepositiontaking_85 bit = 0,
	@isauto_v161slivepositiontaking_86 bit = 0,
	@isauto_v161slivepositiontaking_87 bit = 0,
	@isauto_v161slivepositiontaking_89 bit = 0,
	@isauto_v161slivepositiontaking_90 bit = 0,
	
	@old_isauto_v161spositiontaking_81 bit = 0,
	@old_isauto_v161spositiontaking_83 bit = 0,	
	@old_isauto_v161spositiontaking_86 bit = 0,
	@old_isauto_v161spositiontaking_88 bit = 0,
	
	@old_isauto_v161slivepositiontaking_85 bit = 0,
	@old_isauto_v161slivepositiontaking_86 bit = 0,
	@old_isauto_v161slivepositiontaking_87 bit = 0,
	@old_isauto_v161slivepositiontaking_89 bit = 0,
	@old_isauto_v161slivepositiontaking_90 bit = 0,
	
	@auto_v161spositiontaking_81 smallmoney = 0,
	@auto_v161spositiontaking_83 smallmoney = 0,	
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,
	
	@old_auto_v161spositiontaking_81 smallmoney = 0,
	@old_auto_v161spositiontaking_83 smallmoney = 0,	
	@old_auto_v161spositiontaking_86 smallmoney = 0,
	@old_auto_v161spositiontaking_88 smallmoney = 0,
	
	@old_auto_v161slivepositiontaking_85 smallmoney = 0,
	@old_auto_v161slivepositiontaking_86 smallmoney = 0,
	@old_auto_v161slivepositiontaking_87 smallmoney = 0,
	@old_auto_v161slivepositiontaking_89 smallmoney = 0,
	@old_auto_v161slivepositiontaking_90 smallmoney = 0,
	
	--virtual sports
	@vs_sporttype INT = 0,
	@vs_bettype INT = 0,
	
	@vs_isauto_spositiontaking bit = 0,--is3
	@old_vs_isauto_spositiontaking bit = 0,--is3_old
	
	@vs_auto_spositiontaking smallmoney = 0,--us3
	
	--Live Casino
	@isauto_v162spositiontaking_1101 bit = 0,
	@old_isauto_v162spositiontaking_1101 bit = 0,
	
	@auto_v162spositiontaking_1101 smallmoney = 0,	
	
	------------------------------------------------------------------------
	--update auto pt on agent
	--number game
	@isauto_v161mpositiontaking_81 bit = 0,
	@isauto_v161mpositiontaking_83 bit = 0,
	@isauto_v161mpositiontaking_86 bit = 0,
	@isauto_v161mpositiontaking_88 bit = 0,
	@isauto_v161mlivepositiontaking_85 bit = 0,
	@isauto_v161mlivepositiontaking_86 bit = 0,
	@isauto_v161mlivepositiontaking_87 bit = 0,
	@isauto_v161mlivepositiontaking_89 bit = 0,
	@isauto_v161mlivepositiontaking_90 bit = 0,
	
	@old_isauto_v161mpositiontaking_81 bit = 0,
	@old_isauto_v161mpositiontaking_83 bit = 0,
	@old_isauto_v161mpositiontaking_86 bit = 0,
	@old_isauto_v161mpositiontaking_88 bit = 0,
	@old_isauto_v161mlivepositiontaking_85 bit = 0,
	@old_isauto_v161mlivepositiontaking_86 bit = 0,
	@old_isauto_v161mlivepositiontaking_87 bit = 0,
	@old_isauto_v161mlivepositiontaking_89 bit = 0,
	@old_isauto_v161mlivepositiontaking_90 bit = 0,
	
	@auto_v161mpositiontaking_81 smallmoney = 0,
	@auto_v161mpositiontaking_83 smallmoney = 0,
	--@auto_v161mpositiontaking_85 smallmoney = 0,
	@auto_v161mpositiontaking_86 smallmoney = 0,
	@auto_v161mpositiontaking_88 smallmoney = 0,
	
	@auto_v161mlivepositiontaking_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_90 smallmoney = 0,
	
	@old_auto_v161mpositiontaking_81 smallmoney = 0,
	@old_auto_v161mpositiontaking_83 smallmoney = 0,
	--@old_auto_v161mpositiontaking_85 smallmoney = 0,
	@old_auto_v161mpositiontaking_86 smallmoney = 0,
	@old_auto_v161mpositiontaking_88 smallmoney = 0,
	
	@old_auto_v161mlivepositiontaking_85 smallmoney = 0,
	@old_auto_v161mlivepositiontaking_86 smallmoney = 0,
	@old_auto_v161mlivepositiontaking_87 smallmoney = 0,
	@old_auto_v161mlivepositiontaking_89 smallmoney = 0,
	@old_auto_v161mlivepositiontaking_90 smallmoney = 0,
		
	--virtual sports
	@vs_mpositiontaking_max smallmoney = 0, --m3
	@vs_auto_mpositiontaking smallmoney = 0, --um2
	
	@vs_isauto_mpositiontaking bit = 0, --im2
	@old_vs_isauto_mpositiontaking bit = 0, --old_im2
	
	--Live Casino
	@auto_v162mpositiontaking_1101 smallmoney = 0,
	
	@isauto_v162mpositiontaking_1101 bit = 0,
	@old_isauto_v162mpositiontaking_1101 bit = 0,
	
	@updatepositiontakingv161 bit = 1,		
	@updateautopositiontakingvs bit = 1,
	@updateallmembers bit = 0,
	@updatemultiple bit = 0,
	@newspositiontaking smallmoney =0 ,
	@newmpositiontaking smallmoney =0

AS
	/*
		Created: Johnson
		Date: 2013-10-29
		Task: Apply execrep when update auto pt on master , agent, member levels
		DB: DBTXN/bodb02
		Original versions: Acc_CustomerUpdMaster_AutoPositiontaking
					Acc_CustomerUpdAgent_AutoPositiontaking					
					Acc_CustomerUpdMasterVS_Positiontaking
					Acc_CustomerUpdAgentVS_PositionTaking
					Acc_CustomerUpdMasterLiveCS_Positiontaking
					Acc_CustomerUpdAgentLiveCS_PositionTaking
		Revision:
		
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN ('custinfo', 'CustSetting3rd', 'CustOverride3rd')
			AND xtype = 'U'

	if @IsExistTables <> 3 RETURN
	
	Declare
		@bettype int,
		@maxpos smallmoney,
		@autov161positiontaking smallmoney,
		@autov161livepositiontaking smallmoney,
		
		@old_autov161positiontaking smallmoney,
		@old_autov161livepositiontaking smallmoney,
		
		@isautov161positiontaking bit,
		@isautov161livepositiontaking bit,
		
		@old_isautov161positiontaking smallmoney,
		@old_isautov161livepositiontaking smallmoney
		
	--Update min/max pt on master
	IF @roleid = 3
	BEGIN
		IF @mode = 'number'
		BEGIN				
			
			Declare CUR CURSOR FOR 
				select 81 as bettype, @isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking								, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
			union all  	select 83 as bettype, @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking										, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
			union all  	select 88 as bettype, @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking										, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
			union all  	select 85 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
			union all  	select 86 as bettype, @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking	, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
			union all  	select 87 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
			union all  	select 89 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
			union all  	select 90 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking

			OPEN CUR

			FETCH NEXT FROM CUR INTO
				@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				---------------------------------
				--Update Number game
				if @bettype in (81,83,86,88) and (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov161positiontaking > 0
					BEGIN
						select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
						update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
						
					END
					else if @isautov161positiontaking <> @old_isautov161positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs3.spositiontaking<@newspositiontaking then mcs3.spositiontaking else @newspositiontaking end
							from custsetting3rd cs3 inner join customer as c with (NOLOCK) on cs3.custid = c.custid
							inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = @mrecommend and cs3.sporttype=mcs3.sporttype and cs3.bettype=mcs3.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 and cs3.isautopositiontaking=0
							
						END
					END					
				END
				--- number game live        
				if @bettype in (85,86,87,89,90) and (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov161livepositiontaking > 0
					BEGIN
						select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
						update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
						from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0
						
					END
					else if @isautov161livepositiontaking <> @old_isautov161livepositiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting3rd with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
							from custsetting3rd inner join customer as c with (NOLOCK) on custsetting3rd.custid = c.custid
							inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting3rd.sporttype=mcs.sporttype and custsetting3rd.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting3rd.bettype = @bettype and custsetting3rd.sporttype=161 and custsetting3rd.isautolivepositiontaking=0				
							
						END
					END 
				END		---- end live
				FETCH NEXT FROM CUR INTO
					@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
			END
			CLOSE CUR
			DEALLOCATE CUR
		END
		ELSE IF @mode = 'virtual-sports'
		BEGIN
			IF @updateautopositiontakingvs = 1
			BEGIN
				IF @vs_isauto_spositiontaking >0 --auto PT is used
				BEGIN
					--Update use Auto_SPT at master for all members only when:
						--(autoSPT at master changes AND isauto at master = 1
						--OR isauto at master changes from 0 to 1)
						--AND isauto at member = 0
					
					
					SELECT @maxpos = spositiontaking 
					FROM CustSetting3rd with (NOLOCK) 
					WHERE custid = @srecommend and sporttype= @vs_sporttype and bettype = @vs_bettype
					
					UPDATE cs
					SET cs.spositiontaking = CASE WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @vs_auto_spositiontaking THEN @vs_auto_spositiontaking ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking END
					FROM CustSetting3rd cs WITH(NOLOCK)
						INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
					WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 
						AND cs.sporttype = @vs_sporttype AND cs.bettype = @vs_bettype
						AND cs.isautopositiontaking = 0 -- only update members without AutoSPT at member
								
				END
				ELSE IF @vs_isauto_spositiontaking <> @old_vs_isauto_spositiontaking  --auto PT is NOT used
				BEGIN
					IF @Updateallmembers = 1
					BEGIN
					--Update a specific SPT for all members only when:
								-- @updateallmembers = 1
								-- isauto at master = 0
								--AND isauto at master change from 1 to 0
								--AND isauto at member = 0
									
						SELECT @maxpos = spositiontaking 
						FROM CustSetting3rd with (NOLOCK) 
						WHERE custid = @srecommend and sporttype= @vs_sporttype and bettype = @vs_bettype
					
						UPDATE cs
						SET cs.spositiontaking = CASE WHEN @newspositiontaking > @maxpos - mcs.mpositiontaking THEN @maxpos - mcs.mpositiontaking ELSE @newspositiontaking END
						FROM CustSetting3rd cs
							INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
							INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
						WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1
							AND cs.sporttype = @vs_sporttype AND cs.bettype = @vs_bettype
							AND cs.isautopositiontaking = 0
											
					END
				END	
			END
			ELSE
			BEGIN
				UPDATE cs 
				SET spositiontaking = b.spositiontaking
				FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
					INNER JOIN custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @mrecommend and ci.roleid = 1
					INNER JOIN 
						(
							select @vs_sporttype as sporttype, @vs_bettype as bettype, @vs_isauto_spositiontaking as isautopositiontaking, @old_vs_isauto_spositiontaking as oldisautopositiontaking, @newspositiontaking as spositiontaking
						) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
				WHERE b.isautopositiontaking = 0 --and b.oldisautopositiontaking = 0 
					and cs.isautopositiontaking = 0
			END
		END
		ELSE IF @mode = 'LiveCasino'
		BEGIN
			 IF @isauto_v162spositiontaking_1101 >0 --auto PT is used
			BEGIN
				--Update use Auto_SPT at master for all members only when:
					--(autoSPT at master changes AND isauto at master = 1
					--OR isauto at master changes from 0 to 1)
					--AND isauto at member = 0			
				
				SELECT @maxpos = spositiontaking 
				FROM CustSettingGame with (NOLOCK) 
				WHERE custid = @srecommend and sporttype=162 and bettype = 1101
				
				UPDATE cs
				SET cs.spositiontaking = CASE WHEN @maxpos - cs.mpositiontaking - cs.apositiontaking > @auto_v162spositiontaking_1101 THEN @auto_v162spositiontaking_1101 ELSE @maxpos - cs.mpositiontaking - cs.apositiontaking END
				FROM CustSettingGame cs 
					INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
					AND cs.sporttype = 162 AND cs.bettype = 1101 
					AND cs.isautopositiontaking = 0 -- only update members without AutoSPT at member
								
			END
			ELSE IF @isauto_v162spositiontaking_1101 <> @old_isauto_v162spositiontaking_1101  --auto PT is NOT used
			BEGIN
				IF @Updateallmembers = 1
				BEGIN
				--Update a specific SPT for all members only when:
							-- @updateallmembers = 1
							-- isauto at master = 0
							--AND isauto at master change from 1 to 0
							--AND isauto at member = 0
							
					UPDATE cs
					SET cs.spositiontaking = CASE WHEN mcs.spositiontaking < @newspositiontaking THEN mcs.spositiontaking ELSE @newspositiontaking END
					FROM CustSettingGame cs
						INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
						INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
					WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
						AND cs.sporttype = 162 AND cs.bettype = 1101 
						AND cs.isautopositiontaking = 0
				END
			END
		END
	END
	ELSE IF @roleid = 2
	BEGIN
		IF @mode = 'number'
		BEGIN
					Declare CUR CURSOR FOR 
						select 81 as bettype	,	@isauto_v161mpositiontaking_81 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_81 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_81  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_81  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	
			union all 	select 83 as bettype	,	@isauto_v161mpositiontaking_83 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_83 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_83  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_83  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	
			union all  	select 85 as bettype	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_85 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_85 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_85 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_85 as old_isautov161livepositiontaking	
			union all 	select 86 as bettype	,	@isauto_v161mpositiontaking_86 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_86 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_86 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_86 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_86  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_86 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_86  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_86 as old_isautov161livepositiontaking	
			union all 	select 87 as bettype	,								0  as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_87 as isautov161livepositiontaking	,								0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_87 as autov161livepositiontaking	,									   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_87 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_87 as old_isautov161livepositiontaking	
			union all 	select 88 as bettype	,	@isauto_v161mpositiontaking_88 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_88 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_88  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_88  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	
			union all  	select 89 as bettype	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_89 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_89 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_89 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_89 as old_isautov161livepositiontaking
			union all  	select 90 as bettype	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_90 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_90 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_90 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_90 as old_isautov161livepositiontaking	
			
			OPEN CUR

			FETCH NEXT FROM CUR INTO
				@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking			
			
			
			--Update use Auto_MPT at agent for all members only when:
			--(autoMPT at agent changes AND isauto at agent = 1
			--OR isauto at agent changes from 0 to 1)
			-- m1=min(m3-a1,u2)
			
			--Update a specific MPT for all members only when:
			--@updateallmembers = 1
			--AND isauto at agent = 0
			--AND isauto at agent change from 1 to 0
			--m1=min(m2,@newmpositiontaking)
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				---------------------------------
					--Update Number game
					if @bettype in (81,83,86,88) and (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
					BEGIN
						if @isautov161positiontaking >0 --Use AUTO MPT
						BEGIN 				
							--m1=min(m3-a1,u2)
							select @maxpos = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
							update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
							from custsetting3rd cs3  inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
							where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161
							
						END
						else if @isautov161positiontaking <> @old_isautov161positiontaking --Not use AUTO MPT
						BEGIN
							if @updateallmembers = 1 --All member
							BEGIN
								--m1=min(m2,@newmpositiontaking)
								update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs3.mpositiontaking<@newmpositiontaking then acs3.mpositiontaking else @newmpositiontaking end
								from custsetting3rd  cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
								inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = @recommend and cs3.sporttype=acs3.sporttype and cs3.bettype=acs3.bettype
								where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161
								
							END
						END
					END		
				
					--Update number game LIVE
					if @bettype in (85,86,87,89,90) and (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
					BEGIN
						if @isautov161livepositiontaking >0 --Use AUTO_MPT
						BEGIN
							--m1=min(m3-a1,u2)
							select @maxpos = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
							update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
							from custsetting3rd cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
							where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 
							
						END
						else if @isautov161livepositiontaking <> @old_isautov161livepositiontaking --Not use AUTO_PT
						BEGIN
							if @updateallmembers = 1--Update all member
							BEGIN
								--m1=min(m2,@newmpositiontaking)
								update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when acs3.mlivepositiontaking<@newmpositiontaking then acs3.mlivepositiontaking else @newmpositiontaking end
								from custsetting3rd cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
								inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = @recommend and cs3.sporttype=acs3.sporttype and cs3.bettype=acs3.bettype
								where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 			
								
							END
						END
					END
					-------------
					FETCH NEXT FROM CUR INTO
						@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
				END
			CLOSE CUR
			DEALLOCATE CUR
		END
	END	
	ELSE IF @mode = 'virtual-sports'
	BEGIN
		IF @updateautopositiontakingvs = 1
		BEGIN
			IF @vs_isauto_mpositiontaking >0 --Use AUTO MPT        
			BEGIN        
			   --m1=min(m3-a1,u2)        
			   SELECT @maxpos = mpositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend and sporttype=@vs_sporttype and bettype = @vs_bettype        
			   
			   UPDATE cs         
			   SET mpositiontaking = case when @maxpos - apositiontaking> @vs_auto_mpositiontaking then @vs_auto_mpositiontaking else @maxpos -apositiontaking end        
			   FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)        
					INNER JOIN custinfo AS c WITH (NOLOCK) on cs.custid = c.custid        
			   WHERE c.recommend = @recommend and c.roleid = 1 and cs.sporttype=@vs_sporttype and cs.bettype = @vs_bettype        
			END
			ELSE IF @vs_isauto_mpositiontaking <> @old_vs_isauto_mpositiontaking --Not use AUTO MPT        
			BEGIN        
				IF @updateallmembers = 1 --all member        
				BEGIN                  
					--m1=min(m3-a2,@m1)
					UPDATE cs             
					SET mpositiontaking = case when @vs_mpositiontaking_max - acs.mpositiontaking < @newmpositiontaking then @vs_mpositiontaking_max - acs.mpositiontaking else @newmpositiontaking end        
					FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)         
						 INNER JOIN custinfo as c with (NOLOCK) on cs.custid = c.custid        
						 INNER JOIN CustSetting3rd as acs with (NOLOCK) on acs.custid = @recommend and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype        
					where c.recommend = @recommend and c.roleid = 1 and cs.bettype = @vs_bettype and cs.sporttype=@vs_sporttype        
				END        
			END  
		END
		ELSE 
		BEGIN
			 UPDATE cs        
			 SET mpositiontaking = b.mpositiontaking        
			 FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)        
				  INNER JOIN custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @recommend and ci.roleid = 1        
				  INNER JOIN         
				   (        
					select @vs_sporttype as sporttype, @vs_bettype as bettype, @vs_isauto_mpositiontaking as isautopositiontaking, @old_vs_isauto_mpositiontaking as oldisautopositiontaking, @newmpositiontaking as mpositiontaking        
				   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype        
			 WHERE b.isautopositiontaking = 0 -- and b.oldisautopositiontaking = 0          
				AND cs.isautompositiontaking = 0 
		END
	END	
	ELSE IF @mode = 'LiveCasino'
	BEGIN
		if @isauto_v162mpositiontaking_1101 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,u2)
			select @maxpos = mpositiontaking from CustSettingGame with (NOLOCK) where custid = @mrecommend and sporttype=162 and bettype = 1101
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking > @auto_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @maxpos -apositiontaking end
			from CustSettingGame as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @recommend and c.roleid = 1 and c.SyncLiveCasino = 1
				and cs.bettype = 1101 and cs.sporttype=162
			
		END
		else if @isauto_v162mpositiontaking_1101 <> @old_isauto_v162mpositiontaking_1101 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs 
					set mpositiontaking = case when acs.mpositiontaking < @newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSettingGame as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSettingGame as acs with (NOLOCK) on acs.custid = @recommend and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @recommend and c.roleid = 1 and c.SyncLiveCasino = 1
					and cs.bettype = 1101 and cs.sporttype = 162
				
			END
		END
	END
END
