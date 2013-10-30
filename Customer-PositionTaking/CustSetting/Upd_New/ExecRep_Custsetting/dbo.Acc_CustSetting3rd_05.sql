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
	
	@updatepositiontakingv161 bit = 1,
	@updateallmembers bit = 0,
	@updatemultiple bit = 0,
	@newspositiontaking smallmoney

AS
	/*
		Created: Johnson
		Date: 2013-10-29
		Task: Apply execrep when update auto pt on master , agent, member levels
		DB: DBTXN/bodb02
		
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
	
	--Update min/max pt on master
	IF @roleid = 3
	BEGIN
		IF @mode = 'number'
		BEGIN		
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
	END
END
