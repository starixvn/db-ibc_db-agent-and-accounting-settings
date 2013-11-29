ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_09]
	@mrecommend INT = 0,
	@custid int = 0,
	@roleid INT,
	@mode VARCHAR(50)='',
	--super update auto pt on member
	--number game
	@auto_v161spositiontaking_81 smallmoney = 0,
	@auto_v161spositiontaking_83 smallmoney = 0,
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,
	
	@isauto_v161spositiontaking_81 bit = 0,
	@isauto_v161spositiontaking_83 bit = 0,
	@isauto_v161spositiontaking_86 bit = 0,
	@isauto_v161spositiontaking_88 bit = 0,
	@isauto_v161slivepositiontaking_85 bit = 0,
	@isauto_v161slivepositiontaking_86 bit = 0,
	@isauto_v161slivepositiontaking_87 bit = 0,
	@isauto_v161slivepositiontaking_89 bit = 0,
	@isauto_v161slivepositiontaking_90 bit = 0,
	
	--horse racing
	@auto_v151spositiontaking_31 smallmoney = 0,
	@auto_v151spositiontaking_32 smallmoney = 0,
	@auto_v151spositiontaking_41 smallmoney = 0,
	@auto_v151spositiontaking_42 smallmoney = 0,
	@auto_v151spositiontaking_51 smallmoney = 0,
	@auto_v151spositiontaking_52 smallmoney = 0,
	@auto_v152spositiontaking_41 smallmoney = 0,
	@auto_v152spositiontaking_42 smallmoney = 0,
	@auto_v152spositiontaking_51 smallmoney = 0,
	@auto_v152spositiontaking_52 smallmoney = 0,
	@auto_v153spositiontaking_51 smallmoney = 0,
	@auto_v153spositiontaking_52 smallmoney = 0,

	@isauto_v151spositiontaking_31 bit = 0,
	@isauto_v151spositiontaking_32 bit = 0,
	@isauto_v151spositiontaking_41 bit = 0,
	@isauto_v151spositiontaking_42 bit = 0,
	@isauto_v151spositiontaking_51 bit = 0,
	@isauto_v151spositiontaking_52 bit = 0,
	@isauto_v152spositiontaking_41 bit = 0,
	@isauto_v152spositiontaking_42 bit = 0,
	@isauto_v152spositiontaking_51 bit = 0,
	@isauto_v152spositiontaking_52 bit = 0,
	@isauto_v153spositiontaking_51 bit = 0,
	@isauto_v153spositiontaking_52 bit = 0,	
	
	--master update auto pt on member
	--number game
	@auto_v161mpositiontaking_mem_81 smallmoney = 0,
	@auto_v161mpositiontaking_mem_83 smallmoney = 0,
	@auto_v161mpositiontaking_mem_86 smallmoney = 0,
	@auto_v161mpositiontaking_mem_88 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_90 smallmoney = 0,
	
	@isauto_v161mpositiontaking_mem_81 bit = 0,
	@isauto_v161mpositiontaking_mem_83 bit = 0,
	@isauto_v161mpositiontaking_mem_86 bit = 0,
	@isauto_v161mpositiontaking_mem_88 bit = 0,
	@isauto_v161mlivepositiontaking_mem_85 bit = 0,
	@isauto_v161mlivepositiontaking_mem_86 bit = 0,
	@isauto_v161mlivepositiontaking_mem_87 bit = 0,
	@isauto_v161mlivepositiontaking_mem_89 bit = 0,
	@isauto_v161mlivepositiontaking_mem_90 bit = 0,
	
	--horse racing
	@auto_v151mpositiontaking_31 SMALLMONEY = 0,
	@auto_v151mpositiontaking_32 SMALLMONEY = 0,
	@auto_v151mpositiontaking_41 SMALLMONEY = 0,
	@auto_v151mpositiontaking_42 SMALLMONEY = 0,
	@auto_v151mpositiontaking_51 SMALLMONEY = 0,
	@auto_v151mpositiontaking_52 SMALLMONEY = 0,
	@auto_v152mpositiontaking_41 SMALLMONEY = 0,
	@auto_v152mpositiontaking_42 SMALLMONEY = 0,
	@auto_v152mpositiontaking_51 SMALLMONEY = 0,
	@auto_v152mpositiontaking_52 SMALLMONEY = 0,
	@auto_v153mpositiontaking_51 SMALLMONEY = 0,
	@auto_v153mpositiontaking_52 SMALLMONEY = 0,
	
	@auto_v151mpositiontaking_mem_31 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_32 SMALLMONEY = 0,  
	@auto_v151mpositiontaking_mem_41 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_42 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_52 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_41 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_42 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_52 SMALLMONEY = 0,
	@auto_v153mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v153mpositiontaking_mem_52 SMALLMONEY = 0, 
		
	@isauto_v151mpositiontaking_31 bit = 0,
	@isauto_v151mpositiontaking_32 bit = 0,
	@isauto_v151mpositiontaking_41 bit = 0,
	@isauto_v151mpositiontaking_42 bit = 0,
	@isauto_v151mpositiontaking_51 bit = 0,
	@isauto_v151mpositiontaking_52 bit = 0,
	@isauto_v152mpositiontaking_41 bit = 0,
	@isauto_v152mpositiontaking_42 bit = 0,
	@isauto_v152mpositiontaking_51 bit = 0,
	@isauto_v152mpositiontaking_52 bit = 0,
	@isauto_v153mpositiontaking_51 bit = 0,
	@isauto_v153mpositiontaking_52 bit = 0,
	
	@isauto_v151mpositiontaking_mem_31 bit = 0,
	@isauto_v151mpositiontaking_mem_32 bit = 0,
	@isauto_v151mpositiontaking_mem_41 bit = 0,
	@isauto_v151mpositiontaking_mem_42 bit = 0,
	@isauto_v151mpositiontaking_mem_51 bit = 0,
	@isauto_v151mpositiontaking_mem_52 bit = 0,
	@isauto_v152mpositiontaking_mem_41 bit = 0,
	@isauto_v152mpositiontaking_mem_42 bit = 0,
	@isauto_v152mpositiontaking_mem_51 bit = 0,
	@isauto_v152mpositiontaking_mem_52 bit = 0,
	@isauto_v153mpositiontaking_mem_51 bit = 0,
	@isauto_v153mpositiontaking_mem_52 bit = 0,

	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv161 BIT = 1,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1
 AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update auto pt on member
		DB: DBTXN/bodb02
		Original versions:	Acc_CustomerUpdMember_Super
				Acc_CustomerUpdMember_Master
				Acc_CustomerUpdMemberHR_SAg
				Acc_CustomerUpdMemberHR_MAg
				
		Revision:
			- 20131104@Johnson: Add racing
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON 
	
	--DECLARE @IsExistTables tinyint
	--SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	--WHERE	name IN ('custinfo', 'CustSetting3rd', 'CustOverride3rd')
	--		AND xtype = 'U'

	--if @IsExistTables <> 3 RETURN
	
	IF ((SELECT COUNT(1) FROM sysobjects WHERE name IN ('CustSetting3rd','CustOverride3rd', 'custinfo') AND type = 'U') < 3
		AND (SELECT COUNT(1) FROM sysobjects WHERE name IN ('CustSetting3rd','CustOverride3rd', 'custinfo') AND type = 'V') < 3)
		RETURN
		
	Declare @bettype int,
			@maxpos smallmoney,	
			@autov161positiontaking smallmoney,
			@isautov161positiontaking bit, 
			
			@autov161livepositiontaking smallmoney,
			@isautov161livepositiontaking bit, 

			@srecommend int,			
			@recommend int

	IF @roleid = 4
		BEGIN
			IF @mode = 'number'
			BEGIN
				Declare
						@old_autov161positiontaking smallmoney,
						@old_isautov161positiontaking smallmoney,
						
						@old_autov161livepositiontaking smallmoney,
						@old_isautov161livepositiontaking smallmoney		
				declare 
				@old_auto_v161spositiontaking_81 smallmoney,
				@old_auto_v161spositiontaking_83 smallmoney,
				@old_auto_v161spositiontaking_86 smallmoney,
				@old_auto_v161spositiontaking_88 smallmoney,
				@old_auto_v161slivepositiontaking_85 smallmoney,
				@old_auto_v161slivepositiontaking_86 smallmoney,
				@old_auto_v161slivepositiontaking_87 smallmoney,
				@old_auto_v161slivepositiontaking_89 smallmoney,
				@old_auto_v161slivepositiontaking_90 smallmoney,
				
				@old_isauto_v161spositiontaking_81 bit,
				@old_isauto_v161spositiontaking_83 bit,
				@old_isauto_v161spositiontaking_86 bit,
				@old_isauto_v161spositiontaking_88 bit,
				@old_isauto_v161slivepositiontaking_85 bit,
				@old_isauto_v161slivepositiontaking_86 bit,
				@old_isauto_v161slivepositiontaking_87 bit,
				@old_isauto_v161slivepositiontaking_89 bit,
				@old_isauto_v161slivepositiontaking_90 bit,
				
				@master_auto_v161spositiontaking_81 smallmoney,
				@master_auto_v161spositiontaking_83 smallmoney,
				@master_auto_v161spositiontaking_86 smallmoney,
				@master_auto_v161spositiontaking_88 smallmoney,
				@master_auto_v161slivepositiontaking_85 smallmoney,
				@master_auto_v161slivepositiontaking_86 smallmoney,
				@master_auto_v161slivepositiontaking_87 smallmoney,
				@master_auto_v161slivepositiontaking_89 smallmoney,
				@master_auto_v161slivepositiontaking_90 smallmoney,
				
				@master_isauto_v161spositiontaking_81 bit,
				@master_isauto_v161spositiontaking_83 bit,
				@master_isauto_v161spositiontaking_86 bit,
				@master_isauto_v161spositiontaking_88 bit,
				@master_isauto_v161slivepositiontaking_85 bit,
				@master_isauto_v161slivepositiontaking_86 bit,
				@master_isauto_v161slivepositiontaking_87 bit,
				@master_isauto_v161slivepositiontaking_89 bit,
				@master_isauto_v161slivepositiontaking_90 bit
				
				
				select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid

				-- number game
				if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
					BEGIN --UpdatePositiontakingv161
						select 	@old_auto_v161spositiontaking_81	=	autopositiontaking		,	@old_isauto_v161spositiontaking_81	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=81
						select 	@old_auto_v161spositiontaking_83	=	autopositiontaking		,	@old_isauto_v161spositiontaking_83	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=83
						select 	@old_auto_v161spositiontaking_86	=	autopositiontaking		,	@old_isauto_v161spositiontaking_86	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
						select 	@old_auto_v161spositiontaking_88	=	autopositiontaking		,	@old_isauto_v161spositiontaking_88	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=88
						select 	@old_auto_v161slivepositiontaking_85	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_85	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=85
						select 	@old_auto_v161slivepositiontaking_86	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_86	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
						select 	@old_auto_v161slivepositiontaking_87	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_87	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=87
						select 	@old_auto_v161slivepositiontaking_89	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_89	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=89
						select 	@old_auto_v161slivepositiontaking_90	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_90	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=90
					END  --UpdatePositiontakingv161

				--Get Auto PT of member from Master
				if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
					BEGIN --UpdatePositiontakingv161
						select @master_auto_v161spositiontaking_81 = autopositiontaking, @master_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
						select @master_auto_v161spositiontaking_83 = autopositiontaking, @master_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
						select @master_auto_v161spositiontaking_88 = autopositiontaking, @master_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161
						select															 @master_auto_v161slivepositiontaking_85 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
						select @master_auto_v161spositiontaking_86 = autopositiontaking, @master_auto_v161slivepositiontaking_86 = autolivepositiontaking, @master_isauto_v161spositiontaking_86 = isautopositiontaking, @master_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
						select															 @master_auto_v161slivepositiontaking_87 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
						select															 @master_auto_v161slivepositiontaking_89 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
						select															 @master_auto_v161slivepositiontaking_90 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161
					END  --UpdatePositiontakingv161

					--Update Member account (autopositiontaking field) - Number game
				if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
					Begin --@UpdatePositiontakingv161
						update cs3 with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
						from custsetting3rd cs3 inner join 
								(
												select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking,									0	as isautolivepositiontaking
									union all 	select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking,									0	as isautolivepositiontaking
									union all 	select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking,									0	as isautolivepositiontaking
									union all 	select 85 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_85	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_85	as isautolivepositiontaking
									union all 	select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86	as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86	as isautolivepositiontaking
									union all 	select 87 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_87	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_87	as isautolivepositiontaking
									union all 	select 89 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_89	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_89	as isautolivepositiontaking
									union all 	select 90 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_90	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_90	as isautolivepositiontaking					
								) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
						where cs3.custid = @custid
						
					END --@UpdatePositiontakingv161
					--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
					select 
						-- number game
						@auto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @auto_v161spositiontaking_81 else @master_auto_v161spositiontaking_81 end,			
						@auto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @auto_v161spositiontaking_83 else @master_auto_v161spositiontaking_83 end,			
						@auto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @auto_v161spositiontaking_86 else @master_auto_v161spositiontaking_86 end,			
						@auto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @auto_v161spositiontaking_88 else @master_auto_v161spositiontaking_88 end,			
						@auto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @auto_v161slivepositiontaking_85 else @master_auto_v161slivepositiontaking_85 end,			
						@auto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @auto_v161slivepositiontaking_86 else @master_auto_v161slivepositiontaking_86 end,			
						@auto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @auto_v161slivepositiontaking_87 else @master_auto_v161slivepositiontaking_87 end,
						@auto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @auto_v161slivepositiontaking_89 else @master_auto_v161slivepositiontaking_89 end,
						@auto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @auto_v161slivepositiontaking_90 else @master_auto_v161slivepositiontaking_90 end,
						
						-- number game
						@isauto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @isauto_v161spositiontaking_81 else @master_isauto_v161spositiontaking_81 end,
						@isauto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @isauto_v161spositiontaking_83 else @master_isauto_v161spositiontaking_83 end,
						@isauto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @isauto_v161spositiontaking_86 else @master_isauto_v161spositiontaking_86 end,
						@isauto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @isauto_v161spositiontaking_88 else @master_isauto_v161spositiontaking_88 end,
						@isauto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @isauto_v161slivepositiontaking_85 else @master_isauto_v161slivepositiontaking_85 end,
						@isauto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @isauto_v161slivepositiontaking_86 else @master_isauto_v161slivepositiontaking_86 end,
						@isauto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @isauto_v161slivepositiontaking_87 else @master_isauto_v161slivepositiontaking_87 end,
						@isauto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @isauto_v161slivepositiontaking_89 else @master_isauto_v161slivepositiontaking_89 end,
						@isauto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @isauto_v161slivepositiontaking_90 else @master_isauto_v161slivepositiontaking_90 end


					--Update member account
					--Using Cursor (spositiontaking field)
					DECLARE CUR CURSOR FOR 
							select 81 as bettype, @isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking								, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
				union all  	select 83 as bettype, @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
				union all  	select 88 as bettype, @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking

				union all  	select 85 as bettype, 0								 as isautov161positiontaking	, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking,							  @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
				union all  	select 86 as bettype, @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking	, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
				union all  	select 87 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
				union all  	select 89 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
				union all  	select 90 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking
					
					OPEN CUR

					FETCH NEXT FROM CUR INTO
						@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
					
					WHILE @@FETCH_STATUS = 0
						BEGIN
							-- Update number game (non-live)
							if @bettype in (81,83,86,88) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
								BEGIN
									if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
										Begin --@UpdatePositiontakingv161
											if @isautov161positiontaking > 0
												BEGIN
													select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
													update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
													from custsetting3rd cs3
													where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
													
												END
										END--@UpdatePositiontakingv161
								END


							-- Update number game (live)
							if @bettype in (85,86,87,89,90) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
								BEGIN
									if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
										Begin --@UpdatePositiontakingv161
											if @isautov161livepositiontaking > 0
												BEGIN
													select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
													update cs3 with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
													from custsetting3rd cs3
													where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
													
												END
										END--@UpdatePositiontakingv161
								END

							FETCH NEXT FROM CUR INTO			
								@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
						END

					CLOSE CUR
					DEALLOCATE CUR
			END
		ELSE IF @mode = 'horse'
				BEGIN					
					update CustSetting3rd with (ROWLOCK, UPDLOCK) 
						set autopositiontaking = case when @UpdateMultiple = 1 
													and (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
														OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
														OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
													then cs.autopositiontaking
												else b.autopositiontaking end,
							isautopositiontaking = case when @UpdateMultiple = 1 
													and (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
														OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
														OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
													then cs.isautopositiontaking
												else b.isautopositiontaking end
					from CustSetting3rd as cs inner join 
							(
											select 31 as bettype, 151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking where @UpdatePositiontakingv151_31 = 1
								union all 	select 32 as bettype, 151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking where @UpdatePositiontakingv151_31 = 1	
								union all	select 41 as bettype, 151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking where @UpdatePositiontakingv151_41 = 1
								union all 	select 42 as bettype, 151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking where @UpdatePositiontakingv151_41 = 1	
								union all	select 51 as bettype, 151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv151_51 = 1
								union all 	select 52 as bettype, 151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv151_51 = 1
								union all	select 41 as bettype, 152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1
								union all 	select 42 as bettype, 152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1
								union all	select 51 as bettype, 152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
								union all 	select 52 as bettype, 152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
								union all	select 51 as bettype, 153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv153_51 = 1
								union all 	select 52 as bettype, 153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv153_51 = 1
							) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
					where cs.custid = @custid
				END	
		END
	ELSE IF @roleid = 3
		BEGIN
			IF @mode = 'number'
				BEGIN			
					declare @auto_v161mpositiontaking_81 smallmoney,
							@auto_v161mpositiontaking_83 smallmoney,
							@auto_v161mpositiontaking_86 smallmoney,
							@auto_v161mpositiontaking_88 smallmoney,
							@auto_v161mlivepositiontaking_85 smallmoney,
							@auto_v161mlivepositiontaking_86 smallmoney,
							@auto_v161mlivepositiontaking_87 smallmoney,
							@auto_v161mlivepositiontaking_89 smallmoney,
							@auto_v161mlivepositiontaking_90 smallmoney,
							
							@isauto_v161mpositiontaking_81 bit,
							@isauto_v161mpositiontaking_83 bit,
							@isauto_v161mpositiontaking_86 bit,
							@isauto_v161mpositiontaking_88 bit,
							@isauto_v161mlivepositiontaking_85 bit,
							@isauto_v161mlivepositiontaking_86 bit,
							@isauto_v161mlivepositiontaking_87 bit,
							@isauto_v161mlivepositiontaking_89 bit,
							@isauto_v161mlivepositiontaking_90 bit
							
					select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend from custinfo with (NOLOCK) where custid = @custid
					
								
					--Get Auto PT of member from agent
					--um2,im2
					select @auto_v161mpositiontaking_81 = autompositiontaking, @isauto_v161mpositiontaking_81 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=81 and sporttype=161
					select @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=83 and sporttype=161
					select @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=88 and sporttype=161
					select @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=85 and sporttype=161
					select @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=86 and sporttype=161
					select @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=87 and sporttype=161
					select @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=89 and sporttype=161
					select @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=90 and sporttype=161

					--Update Member account (autompositiontaking field)
					update cs3 with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autompositiontaking, autolivempositiontaking = b.autolivempositiontaking, isautompositiontaking = b.isautompositiontaking, isautolivempositiontaking = b.isautolivempositiontaking
					from custsetting3rd cs3 inner join 
							(
											select 81 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_81 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_81 as isautompositiontaking, 0				as isautolivempositiontaking
								union all 	select 83 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_83 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_83 as isautompositiontaking, 0				as isautolivempositiontaking
								union all 	select 88 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_88 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_88 as isautompositiontaking, 0				as isautolivempositiontaking
								union all 	select 85 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_85 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_85	as isautolivempositiontaking
								union all 	select 86 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_86 as autompositiontaking, @auto_v161mlivepositiontaking_mem_86 	as autolivempositiontaking, @isauto_v161mpositiontaking_mem_86 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_86	as isautolivempositiontaking
								union all 	select 87 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_87 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_87	as isautolivempositiontaking
								union all 	select 89 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_89 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_89	as isautolivempositiontaking
								union all 	select 90 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_90 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_90	as isautolivempositiontaking
								
							) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
					where cs3.custid = @custid	
						
					--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in agent account)
					-- number game
					select
						@auto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @auto_v161mpositiontaking_mem_81 else @auto_v161mpositiontaking_81 end,
						@auto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @auto_v161mpositiontaking_mem_83 else @auto_v161mpositiontaking_83 end,	
						@auto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @auto_v161mpositiontaking_mem_86 else @auto_v161mpositiontaking_86 end,
						@auto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @auto_v161mpositiontaking_mem_88 else @auto_v161mpositiontaking_88 end,
						@auto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @auto_v161mlivepositiontaking_mem_85 else @auto_v161mlivepositiontaking_85 end,
						@auto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @auto_v161mlivepositiontaking_mem_86 else @auto_v161mlivepositiontaking_86 end,
						@auto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @auto_v161mlivepositiontaking_mem_87 else @auto_v161mlivepositiontaking_87 end,
						@auto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @auto_v161mlivepositiontaking_mem_89 else @auto_v161mlivepositiontaking_89 end,
						@auto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @auto_v161mlivepositiontaking_mem_90 else @auto_v161mlivepositiontaking_90 end,

						@isauto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @isauto_v161mpositiontaking_mem_81 else @isauto_v161mpositiontaking_81 end,
						@isauto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @isauto_v161mpositiontaking_mem_83 else @isauto_v161mpositiontaking_83 end,
						@isauto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @isauto_v161mpositiontaking_mem_86 else @isauto_v161mpositiontaking_86 end,
						@isauto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @isauto_v161mpositiontaking_mem_88 else @isauto_v161mpositiontaking_88 end,
						@isauto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @isauto_v161mlivepositiontaking_mem_85 else @isauto_v161mlivepositiontaking_85 end,
						@isauto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @isauto_v161mlivepositiontaking_mem_86 else @isauto_v161mlivepositiontaking_86 end,
						@isauto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @isauto_v161mlivepositiontaking_mem_87 else @isauto_v161mlivepositiontaking_87 end,
						@isauto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @isauto_v161mlivepositiontaking_mem_89 else @isauto_v161mlivepositiontaking_89 end,
						@isauto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @isauto_v161mlivepositiontaking_mem_90 else @isauto_v161mlivepositiontaking_90 end

						--Update member account
						--Using Cursor (mpositiontaking field)
						DECLARE CUR CURSOR FOR 
								SELECT 81 AS bettype	, @isauto_v161mpositiontaking_81 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_81 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
					UNION ALL  	SELECT 83 AS bettype	, @isauto_v161mpositiontaking_83 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_83 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
					UNION ALL  	SELECT 88 AS bettype	, @isauto_v161mpositiontaking_88 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_88 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
					UNION ALL  	SELECT 85 AS bettype	,							   0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_85 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_85 AS autov161livepositiontaking
					UNION ALL  	SELECT 86 AS bettype	, @isauto_v161mpositiontaking_86 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_86 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_86 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_86 AS autov161livepositiontaking
					UNION ALL  	SELECT 87 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_87 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_87 AS autov161livepositiontaking
					UNION ALL  	SELECT 89 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_89 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_89 AS autov161livepositiontaking
					UNION ALL  	SELECT 90 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_90 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_90 AS autov161livepositiontaking
					OPEN CUR

					FETCH NEXT FROM CUR INTO
						@bettype, @isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking


					--m1=min(u,m3-a1)
					WHILE @@FETCH_STATUS = 0
					BEGIN		
						--Update Number game  -- non-live
						if @bettype in (81,83,86,88) 
						BEGIN
							if @isautov161positiontaking >0
							BEGIN
								select @maxpos = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
								update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
								from custsetting3rd cs3
								where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
								
							END
						END
						--Update Number game -- live
						if @bettype in (85,86,87,89,90) 
						BEGIN
							if @isautov161livepositiontaking > 0
							BEGIN

								select @maxpos = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
								update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
								from custsetting3rd cs3
								where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
								
							END	
						END		
						FETCH NEXT FROM CUR INTO
							@bettype, @isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking
					END
					CLOSE CUR
					DEALLOCATE CUR
				END--end mode = 'number'
			ELSE IF @mode = 'horse'
				BEGIN					
					update CustSetting3rd with (ROWLOCK, UPDLOCK) 
					set autompositiontaking =  CASE WHEN @UpdateMultiple = 1 
													AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
														OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
														OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
													THEN  cs.autompositiontaking
												ELSE b.autompositiontaking END, 
						isautompositiontaking = CASE WHEN @UpdateMultiple = 1 
													AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
														OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
														OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
													THEN  cs.isautompositiontaking
												ELSE b.isautompositiontaking END 
					from CustSetting3rd as cs inner join 
							(
											select 31 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_31 as autompositiontaking, @isauto_v151mpositiontaking_mem_31 as isautompositiontaking WHERE @UpdatePositiontakingv151_31 = 1
								union all 	select 32 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_32 as autompositiontaking, @isauto_v151mpositiontaking_mem_32 as isautompositiontaking WHERE @UpdatePositiontakingv151_31 = 1
								union all 	select 41 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_41 as autompositiontaking, @isauto_v151mpositiontaking_mem_41 as isautompositiontaking WHERE @UpdatePositiontakingv151_41 = 1
								union all 	select 42 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_42 as autompositiontaking, @isauto_v151mpositiontaking_mem_42 as isautompositiontaking WHERE @UpdatePositiontakingv151_41 = 1
								union all 	select 51 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_51 as autompositiontaking, @isauto_v151mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv151_51 = 1
								union all 	select 52 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_52 as autompositiontaking, @isauto_v151mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv151_51 = 1
								union all 	select 41 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_41 as autompositiontaking, @isauto_v152mpositiontaking_mem_41 as isautompositiontaking WHERE @UpdatePositiontakingv152_41 = 1
								union all 	select 42 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_42 as autompositiontaking, @isauto_v152mpositiontaking_mem_42 as isautompositiontaking WHERE @UpdatePositiontakingv152_41 = 1
								union all 	select 51 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_51 as autompositiontaking, @isauto_v152mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv152_51 = 1
								union all 	select 52 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_52 as autompositiontaking, @isauto_v152mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv152_51 = 1
								union all 	select 51 as bettype, 153 as sporttype, @auto_v153mpositiontaking_mem_51 as autompositiontaking, @isauto_v153mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv153_51 = 1
								union all 	select 52 as bettype, 153 as sporttype, @auto_v153mpositiontaking_mem_52 as autompositiontaking, @isauto_v153mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv153_51 = 1
							
							) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
					where cs.custid = @custid
					
						
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
						BEGIN --@UpdatePositiontakingv151 	
							if @isauto_v151mpositiontaking_31 >0 and @UpdatePositiontakingv151_31 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 31
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_31 then @auto_v151mpositiontaking_31 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 31 and cs.sporttype = 151
									
								END

							if @isauto_v151mpositiontaking_32 >0 and @UpdatePositiontakingv151_31 = 1 
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 32
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_32 then @auto_v151mpositiontaking_32 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 32 and cs.sporttype = 151
									
								END
							if @isauto_v151mpositiontaking_41 >0 and @UpdatePositiontakingv151_41 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 41
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_41 then @auto_v151mpositiontaking_41 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 41 and cs.sporttype = 151
									
								END
							if @isauto_v151mpositiontaking_42 >0 and @UpdatePositiontakingv151_41 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 42
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_42 then @auto_v151mpositiontaking_42 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 42 and cs.sporttype = 151
									
								END
							if @isauto_v151mpositiontaking_51 >0 and @UpdatePositiontakingv151_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 51
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_51 then @auto_v151mpositiontaking_51 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 51 and cs.sporttype = 151
																	
								END
							if @isauto_v151mpositiontaking_52 >0 and @UpdatePositiontakingv151_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 52
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_52 then @auto_v151mpositiontaking_52 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 52 and cs.sporttype = 151
									
								END
						END --@UpdatePositiontakingv151 	

					if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
						BEGIN --@UpdatePositiontakingv152
							if @isauto_v152mpositiontaking_41 >0 and @UpdatePositiontakingv152_41 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 41
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_41 then @auto_v152mpositiontaking_41 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 41 and cs.sporttype = 152
									
								END
							if @isauto_v152mpositiontaking_42 >0 and @UpdatePositiontakingv152_41 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 42
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_42 then @auto_v152mpositiontaking_42 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 42 and cs.sporttype = 152
									
								END
							if @isauto_v152mpositiontaking_51 >0 and @UpdatePositiontakingv152_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 51
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_51 then @auto_v152mpositiontaking_51 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 51 and cs.sporttype = 152
									
								END
							if @isauto_v152mpositiontaking_52 >0 and @UpdatePositiontakingv152_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 52
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_52 then @auto_v152mpositiontaking_52 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 52 and cs.sporttype = 152
									
								END
						END --@UpdatePositiontakingv152

					if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
						BEGIN --@UpdatePositiontakingv153
							if @isauto_v153mpositiontaking_51 >0 and @UpdatePositiontakingv153_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 51
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_51 then @auto_v153mpositiontaking_51 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 51 and cs.sporttype = 153
									
								END
							if @isauto_v153mpositiontaking_52 >0 and @UpdatePositiontakingv153_51 = 1
								BEGIN
									select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 52
									update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_52 then @auto_v153mpositiontaking_52 else @maxpos - apositiontaking end
									from CustSetting3rd as cs
									where custid = @custid and cs.bettype = 52 and cs.sporttype = 153
									
								END
						END--@UpdatePositiontakingv153
				END--end mode = 'horse'				
		END--end roleid = 3	
END