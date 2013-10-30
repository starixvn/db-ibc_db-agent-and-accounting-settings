  ALTER PROCEDURE [dbo].[Acc_CustSetting_05]
	@srecommend INT = 0,
	@mrecommend INT =0,
	@recommend INT = 0,
	@roleid INT,
	--update auto pt on master
	@isauto_spositiontaking_1 bit = 0, 
	@isauto_spositiontaking_2 bit = 0,
	@isauto_spositiontaking_3 bit = 0,
	@isauto_spositiontaking_4 bit = 0,
	@isauto_spositiontaking_5 bit = 0,
	@isauto_spositiontaking_6 bit = 0, 
	@isauto_spositiontaking_7 bit = 0, 
	@isauto_spositiontaking_8 bit = 0, 
	@isauto_spositiontaking_9 bit = 0,  
	@isauto_spositiontaking_10 bit = 0, 
	@isauto_slivepositiontaking_1 bit = 0, 
	@isauto_slivepositiontaking_3 bit = 0, 
	@isauto_slivepositiontaking_7 bit = 0, 
	@isauto_slivepositiontaking_8 bit = 0, 
	
	@isauto_v2spositiontaking_1 bit = 0,
	@isauto_v2spositiontaking_2 bit = 0,
	@isauto_v2spositiontaking_3 bit = 0,
	@isauto_v2spositiontaking_7 bit = 0,
	@isauto_v2spositiontaking_8 bit = 0,
	@isauto_v2spositiontaking_20 bit = 0,
	
	@isauto_v3spositiontaking_1 bit = 0,
	@isauto_v3spositiontaking_2 bit = 0,
	@isauto_v3spositiontaking_3 bit = 0,
	@isauto_v3spositiontaking_20 bit = 0,

	@isauto_v5spositiontaking_1 bit = 0,
	@isauto_v5spositiontaking_2 bit = 0,
	@isauto_v5spositiontaking_3 bit = 0,
	@isauto_v5spositiontaking_20 bit = 0,

	@isauto_v8spositiontaking_1 bit = 0,
	@isauto_v8spositiontaking_3 bit = 0,
	@isauto_v8spositiontaking_20 bit = 0,

	@isauto_v10spositiontaking_1 bit = 0,
	@isauto_v10spositiontaking_2 bit = 0,
	@isauto_v10spositiontaking_3 bit = 0,
	@isauto_v10spositiontaking_20 bit = 0,

	@isauto_v11spositiontaking_1 bit = 0,
	@isauto_v11spositiontaking_20 bit = 0,

	@isauto_v99spositiontaking_1 bit = 0,
	@isauto_v99spositiontaking_2 bit = 0,
	@isauto_v99spositiontaking_3 bit = 0,
	@isauto_v99spositiontaking_20 bit = 0,

	-- mixed sports
	@isauto_v99spositiontaking_9 bit = 0,
	
	@old_isauto_spositiontaking_1 bit = 0, 
	@old_isauto_spositiontaking_2 bit = 0, 
	@old_isauto_spositiontaking_3 bit = 0,
	@old_isauto_spositiontaking_4 bit = 0, 
	@old_isauto_spositiontaking_5 bit = 0, 
	@old_isauto_spositiontaking_6 bit = 0, 
	@old_isauto_spositiontaking_7 bit = 0, 
	@old_isauto_spositiontaking_8 bit = 0, 
	@old_isauto_spositiontaking_9 bit = 0,  
	@old_isauto_spositiontaking_10 bit = 0, 
	@old_isauto_slivepositiontaking_1 bit = 0, 
	@old_isauto_slivepositiontaking_3 bit = 0, 
	@old_isauto_slivepositiontaking_7 bit = 0, 
	@old_isauto_slivepositiontaking_8 bit = 0, 
	
	@old_isauto_v2spositiontaking_1 bit = 0,
	@old_isauto_v2spositiontaking_2 bit = 0,
	@old_isauto_v2spositiontaking_3 bit = 0,
	@old_isauto_v2spositiontaking_7 bit = 0,
	@old_isauto_v2spositiontaking_8 bit = 0,
	@old_isauto_v2spositiontaking_20 bit = 0,
	
	@old_isauto_v3spositiontaking_1 bit = 0,
	@old_isauto_v3spositiontaking_2 bit = 0,
	@old_isauto_v3spositiontaking_3 bit = 0,
	@old_isauto_v3spositiontaking_20 bit = 0,

	@old_isauto_v5spositiontaking_1 bit = 0,
	@old_isauto_v5spositiontaking_2 bit = 0,
	@old_isauto_v5spositiontaking_3 bit = 0,
	@old_isauto_v5spositiontaking_20 bit = 0,

	@old_isauto_v8spositiontaking_1 bit = 0,
	@old_isauto_v8spositiontaking_3 bit = 0,
	@old_isauto_v8spositiontaking_20 bit = 0,

	@old_isauto_v10spositiontaking_1 bit = 0,
	@old_isauto_v10spositiontaking_2 bit = 0,
	@old_isauto_v10spositiontaking_3 bit = 0,
	@old_isauto_v10spositiontaking_20 bit = 0,

	@old_isauto_v11spositiontaking_1 bit = 0,
	@old_isauto_v11spositiontaking_20 bit = 0,

	@old_isauto_v99spositiontaking_1 bit = 0,
	@old_isauto_v99spositiontaking_2 bit = 0,
	@old_isauto_v99spositiontaking_3 bit = 0,
	@old_isauto_v99spositiontaking_20 bit = 0,

	-- mixed sports
	@old_isauto_v99spositiontaking_9 bit = 0,
	
	@auto_spositiontaking_1 smallmoney = 0, 
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney = 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
	@auto_v2spositiontaking_1 smallmoney = 0,
	@auto_v2spositiontaking_2 smallmoney = 0,
	@auto_v2spositiontaking_3 smallmoney = 0,
	@auto_v2spositiontaking_7 smallmoney = 0,
	@auto_v2spositiontaking_8 smallmoney = 0,
--	@auto_v2spositiontaking_9 smallmoney = 0,
	@auto_v2spositiontaking_20 smallmoney = 0,
	
	@auto_v3spositiontaking_1 smallmoney = 0,
	@auto_v3spositiontaking_2 smallmoney = 0,
	@auto_v3spositiontaking_3 smallmoney = 0,
	@auto_v3spositiontaking_20 smallmoney = 0,

	@auto_v5spositiontaking_1 smallmoney = 0,
	@auto_v5spositiontaking_2 smallmoney = 0,
	@auto_v5spositiontaking_3 smallmoney = 0,
	@auto_v5spositiontaking_20 smallmoney = 0,

	@auto_v8spositiontaking_1 smallmoney = 0,
	@auto_v8spositiontaking_3 smallmoney = 0,
	@auto_v8spositiontaking_20 smallmoney = 0,

	@auto_v10spositiontaking_1 smallmoney = 0,
	@auto_v10spositiontaking_2 smallmoney = 0,
	@auto_v10spositiontaking_3 smallmoney = 0,
	@auto_v10spositiontaking_20 smallmoney = 0,

	@auto_v11spositiontaking_1 smallmoney = 0,
	@auto_v11spositiontaking_20 smallmoney = 0,

	@auto_v99spositiontaking_1 smallmoney = 0,
	@auto_v99spositiontaking_2 smallmoney = 0,
	@auto_v99spositiontaking_3 smallmoney = 0,
	@auto_v99spositiontaking_20 smallmoney = 0,

	--- mixed sports
	@auto_v99spositiontaking_9 smallmoney = 0,

	@old_auto_spositiontaking_1 smallmoney = 0, 
	@old_auto_spositiontaking_2 smallmoney = 0,
	@old_auto_spositiontaking_3 smallmoney = 0,
	@old_auto_spositiontaking_4 smallmoney = 0,
	@old_auto_spositiontaking_5 smallmoney = 0,
	@old_auto_spositiontaking_6 smallmoney = 0,
	@old_auto_spositiontaking_7 smallmoney = 0,
	@old_auto_spositiontaking_8 smallmoney = 0,
	@old_auto_spositiontaking_9 smallmoney = 0,
	@old_auto_spositiontaking_10 smallmoney = 0,
	@old_auto_slivepositiontaking_1 smallmoney = 0,
	@old_auto_slivepositiontaking_3 smallmoney = 0,
	@old_auto_slivepositiontaking_7 smallmoney = 0,
	@old_auto_slivepositiontaking_8 smallmoney = 0,
	
	@old_auto_v2spositiontaking_1 smallmoney = 0,
	@old_auto_v2spositiontaking_2 smallmoney = 0,
	@old_auto_v2spositiontaking_3 smallmoney = 0,
	@old_auto_v2spositiontaking_7 smallmoney = 0,
	@old_auto_v2spositiontaking_8 smallmoney = 0,
--	@old_auto_v2spositiontaking_9 smallmoney = 0,
	@old_auto_v2spositiontaking_20 smallmoney = 0,
	
	@old_auto_v3spositiontaking_1 smallmoney = 0,
	@old_auto_v3spositiontaking_2 smallmoney = 0,
	@old_auto_v3spositiontaking_3 smallmoney = 0,
	@old_auto_v3spositiontaking_20 smallmoney = 0,

	@old_auto_v5spositiontaking_1 smallmoney = 0,
	@old_auto_v5spositiontaking_2 smallmoney = 0,
	@old_auto_v5spositiontaking_3 smallmoney = 0,
	@old_auto_v5spositiontaking_20 smallmoney = 0,

	@old_auto_v8spositiontaking_1 smallmoney = 0,
	@old_auto_v8spositiontaking_3 smallmoney = 0,
	@old_auto_v8spositiontaking_20 smallmoney = 0,

	@old_auto_v10spositiontaking_1 smallmoney = 0,
	@old_auto_v10spositiontaking_2 smallmoney = 0,
	@old_auto_v10spositiontaking_3 smallmoney = 0,
	@old_auto_v10spositiontaking_20 smallmoney = 0,

	@old_auto_v11spositiontaking_1 smallmoney = 0,
	@old_auto_v11spositiontaking_20 smallmoney = 0,

	@old_auto_v99spositiontaking_1 smallmoney = 0,
	@old_auto_v99spositiontaking_2 smallmoney = 0,
	@old_auto_v99spositiontaking_3 smallmoney = 0,
	@old_auto_v99spositiontaking_20 smallmoney = 0,

	--- mixed sports
	@old_auto_v99spositiontaking_9 smallmoney = 0,

	--update auto pt on agent 
	
	@updatemultiple bit = 0,
	@updatepositiontaking bit = 1,
	
	@updatepositiontakingv2 bit = 1,
	@updatepositiontakingv3 bit = 1,
	@updatepositiontakingv5 bit = 1,
	@updatepositiontakingv8 bit = 1,
	@updatepositiontakingv10 bit = 1,
	@updatepositiontakingv11 bit = 1,
	@updatepositiontakingv99 bit = 1,

	-- mixed sports
	@updatepositiontakingv99mp bit = 1,
	-- number game
	@updatepositiontakingv161 bit = 1,
	
	@updateallmembers bit = 0,
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
	WHERE	name IN ('custinfo', 'CustSetting', 'CustOverride')
			AND xtype = 'U'

	if @IsExistTables <> 3 RETURN
	
	--Update min/max pt on master
	IF @roleid = 3
	BEGIN
		
		Declare
			@bettype int,
			@autopositiontaking smallmoney,
			@autolivepositiontaking smallmoney,
			
			@autov2positiontaking smallmoney,
			@autov3positiontaking smallmoney,
			@autov5positiontaking smallmoney,
			@autov8positiontaking smallmoney,
			@autov10positiontaking smallmoney,
			@autov11positiontaking smallmoney,
			@autov99positiontaking smallmoney,
			-- mixed sports
			@autov99mppositiontaking smallmoney,

			@old_autopositiontaking smallmoney,
			@old_autolivepositiontaking smallmoney,

			@old_autov2positiontaking smallmoney,
			@old_autov3positiontaking smallmoney,
			@old_autov5positiontaking smallmoney,
			@old_autov8positiontaking smallmoney,
			@old_autov10positiontaking smallmoney,
			@old_autov11positiontaking smallmoney,
			@old_autov99positiontaking smallmoney,
			
			-- mixed sports
			@old_autov99mppositiontaking smallmoney,


			@maxpos smallmoney,
			@isautopositiontaking bit, 
			@isautolivepositiontaking bit, 
			
			@isautov2positiontaking bit,
			@isautov3positiontaking bit,
			@isautov5positiontaking bit,
			@isautov8positiontaking bit,
			@isautov10positiontaking bit,
			@isautov11positiontaking bit,
			@isautov99positiontaking bit,

			-- mixed sports
			@isautov99mppositiontaking bit,

			@old_isautopositiontaking smallmoney, 
			@old_isautolivepositiontaking smallmoney, 
	
			@old_isautov2positiontaking smallmoney,
			@old_isautov3positiontaking smallmoney,
			@old_isautov5positiontaking smallmoney,
			@old_isautov8positiontaking smallmoney,
			@old_isautov10positiontaking smallmoney,
			@old_isautov11positiontaking smallmoney,
			@old_isautov99positiontaking smallmoney,
	
			-- mixed sports
			@old_isautov99mppositiontaking smallmoney
			
				Declare CUR CURSOR FOR 
					select 1 as bettype	,	   @isauto_spositiontaking_1 as isautopositiontaking	,	  @isauto_slivepositiontaking_1 as isautolivepositiontaking	,	  @auto_spositiontaking_1 as autopositiontaking	,	   @auto_slivepositiontaking_1 as autolivepositiontaking	,	  @old_auto_spositiontaking_1 as old_autopositiontaking	    ,	   @old_auto_slivepositiontaking_1 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_1 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_1 as isautov2positiontaking	,	   @auto_v2spositiontaking_1 as autov2positiontaking	,	   @old_auto_v2spositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_1 as isautov3positiontaking	,	   @auto_v3spositiontaking_1 as autov3positiontaking	,	   @old_auto_v3spositiontaking_1 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_1 as isautov5positiontaking	,	   @auto_v5spositiontaking_1 as autov5positiontaking	,	   @old_auto_v5spositiontaking_1 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_1 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_1 as isautov8positiontaking	,	   @auto_v8spositiontaking_1 as autov8positiontaking	,	   @old_auto_v8spositiontaking_1 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_1 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_1 as isautov10positiontaking	,	   @auto_v10spositiontaking_1 as autov10positiontaking	,	   @old_auto_v10spositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_1 as isautov11positiontaking	,	   @auto_v11spositiontaking_1 as autov11positiontaking	,	   @old_auto_v11spositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_1 as isautov99positiontaking	,		@auto_v99spositiontaking_1 as autov99positiontaking	,	   @old_auto_v99spositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 2 as bettype	,	   @isauto_spositiontaking_2 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_2 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_2 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_2 as old_isautopositiontaking    	,										0 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_2 as isautov2positiontaking	,	   @auto_v2spositiontaking_2 as autov2positiontaking	,	     @old_auto_v2spositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_2 as isautov3positiontaking	,	   @auto_v3spositiontaking_2 as autov3positiontaking	,	   @old_auto_v3spositiontaking_2 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_2 as isautov5positiontaking	,	   @auto_v5spositiontaking_2 as autov5positiontaking	,	   @old_auto_v5spositiontaking_2 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_2 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_2 as isautov10positiontaking	,	   @auto_v10spositiontaking_2 as autov10positiontaking	,	   @old_auto_v10spositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_2 as isautov99positiontaking	,		@auto_v99spositiontaking_2 as autov99positiontaking	,	   @old_auto_v99spositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all 	select 3 as bettype	,	   @isauto_spositiontaking_3 as isautopositiontaking	,	  @isauto_slivepositiontaking_3 as isautolivepositiontaking	,	  @auto_spositiontaking_3 as autopositiontaking	,	   @auto_slivepositiontaking_3 as autolivepositiontaking	,		@old_auto_spositiontaking_3 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_3 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_3 as old_isautopositiontaking	    ,		@old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_3 as isautov2positiontaking	,	   @auto_v2spositiontaking_3 as autov2positiontaking	,	   @old_auto_v2spositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_3 as isautov3positiontaking	,	   @auto_v3spositiontaking_3 as autov3positiontaking	,	   @old_auto_v3spositiontaking_3 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_3 as isautov5positiontaking	,	   @auto_v5spositiontaking_3 as autov5positiontaking	,	   @old_auto_v5spositiontaking_3 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_3 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_3 as isautov8positiontaking	,	   @auto_v8spositiontaking_3 as autov8positiontaking	,	   @old_auto_v8spositiontaking_3 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_3 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_3 as isautov10positiontaking	,	   @auto_v10spositiontaking_3 as autov10positiontaking	,	   @old_auto_v10spositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_3 as isautov99positiontaking	,		@auto_v99spositiontaking_3 as autov99positiontaking	,	   @old_auto_v99spositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 4 as bettype	,	   @isauto_spositiontaking_4 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_4 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_4 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_4 as old_isautopositiontaking	,										 0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									    0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all 	select 5 as bettype	,	   @isauto_spositiontaking_5 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_5 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_5 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_5 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 6 as bettype	,	   @isauto_spositiontaking_6 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_6 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_6 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_6 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								 0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,						     0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,						      0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,						             0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 7 as bettype	,	   @isauto_spositiontaking_7 as isautopositiontaking	,	  @isauto_slivepositiontaking_7 as isautolivepositiontaking	,	  @auto_spositiontaking_7 as autopositiontaking	,	   @auto_slivepositiontaking_7 as autolivepositiontaking	,		@old_auto_spositiontaking_7 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_7 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_7 as old_isautopositiontaking	    ,		 @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking	,		@isauto_v2spositiontaking_7 as isautov2positiontaking	,	   @auto_v2spositiontaking_7 as autov2positiontaking	,	   @old_auto_v2spositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 8 as bettype	,	   @isauto_spositiontaking_8 as isautopositiontaking	,	  @isauto_slivepositiontaking_8 as isautolivepositiontaking	,	  @auto_spositiontaking_8 as autopositiontaking	,	   @auto_slivepositiontaking_8 as autolivepositiontaking	,		@old_auto_spositiontaking_8 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_8 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_8 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_8 as isautov2positiontaking	,	   @auto_v2spositiontaking_8 as autov2positiontaking	,	   @old_auto_v2spositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 9 as bettype	,	   @isauto_spositiontaking_9 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_9 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_9 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_9 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,	/*@isauto_v2spositiontaking_9*/ 0 as isautov2positiontaking	,	/*@auto_v2spositiontaking_9*/ 0 as autov2positiontaking	,	/*@old_auto_v2spositiontaking_9*/ 0 as old_autov2positiontaking	,	/*@old_isauto_v2spositiontaking_9*/ 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	, 	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, @isauto_v99spositiontaking_9 as isautov99mppositiontaking	, @auto_v99spositiontaking_9 as autov99mppositiontaking	, @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking	, @old_auto_v99spositiontaking_9	as old_autov99mppositiontaking	
		union all  	select 10 as bettype,	   @isauto_spositiontaking_10 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_10 as autopositiontaking,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_10 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_10 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									  0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all 	select 20 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking  	,		@isauto_v2spositiontaking_20 as isautov2positiontaking	,	   @auto_v2spositiontaking_20 as autov2positiontaking	,	   @old_auto_v2spositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_20 as isautov3positiontaking	,	   @auto_v3spositiontaking_20 as autov3positiontaking	,	   @old_auto_v3spositiontaking_20 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_20 as isautov5positiontaking	,	   @auto_v5spositiontaking_20 as autov5positiontaking	,	   @old_auto_v5spositiontaking_20 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_20 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_20 as isautov8positiontaking	,	   @auto_v8spositiontaking_20 as autov8positiontaking	,	   @old_auto_v8spositiontaking_20 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_20 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_20 as isautov10positiontaking,		@auto_v10spositiontaking_20 as autov10positiontaking,	   @old_auto_v10spositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_20 as isautov11positiontaking,	   @auto_v11spositiontaking_20 as autov11positiontaking	,	   @old_auto_v11spositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_20 as isautov99positiontaking,		@auto_v99spositiontaking_20 as autov99positiontaking,	   @old_auto_v99spositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 21 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,							       0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								    0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		union all  	select 22 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								,								0	as old_autov99mppositiontaking
		
			OPEN CUR

			FETCH NEXT FROM CUR INTO
				@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
				@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,	
				@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,	
				@isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,	
				@isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,	
				@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
				@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
				@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
				@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking
				
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				if (@autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking) and (@updatepositiontaking = 1 or @updatemultiple=0)
				BEGIN
					if @isautopositiontaking >0 --auto PT is used
					BEGIN
						--Update use Auto_SPT at master for all members only when:
							--(autoSPT at master changes AND isauto at master = 1
							--OR isauto at master changes from 0 to 1)
							--AND isauto at member = 0
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where
							c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1
							and custsetting.isautopositiontaking=0 -- only update members without AutoSPT at member
						
					END
					else if @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
					BEGIN
						if @updateallmembers = 1 -- Update All Member option is used
						BEGIN
							--Update a specific SPT for all members only when:
								--@updateallmembers = 1
								--AND isauto at master = 0
								--AND isauto at master change from 1 to 0
								--AND isauto at member = 0
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautopositiontaking=0				
							
						END
					END
				END
				---------------------------------
				--Update LIVE
				if @bettype in (1,3,7,8) and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking ) and (@updatepositiontaking = 1 or @updatemultiple=0)
				BEGIN
					if @isautolivepositiontaking >0
					BEGIN
						select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0						
					END
					else if @isautolivepositiontaking <> @old_isautolivepositiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when mcs.slivepositiontaking<@newspositiontaking then mcs.slivepositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 and custsetting.isautolivepositiontaking=0				
														
						END
					END
				END
				---------------------------------
				--Update Basketball
				if @bettype in (1,2,3,7,8,9,20) and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking ) and (@updatepositiontakingv2 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov2positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov2positiontaking <> @old_isautov2positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 and custsetting.isautopositiontaking=0
							
						END
					END
				END	
				
						---------------------------------
				--Update Football
				if @bettype in (1,2,3,20) and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking ) and (@updatepositiontakingv3 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov3positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=3 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov3positiontaking <> @old_isautov3positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 and custsetting.isautopositiontaking=0
							
						END
					END
				END	

				---------------------------------
				--Update Tennis
				if @bettype in (1,2,3,20) and (@autov5positiontaking <> @old_autov5positiontaking or @isautov5positiontaking <> @old_isautov5positiontaking ) and (@updatepositiontakingv5 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov5positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=5 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov5positiontaking <> @old_isautov5positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5 and custsetting.isautopositiontaking=0
							
						END
					END
				END	

				---------------------------------
				--Update Baseball
				if @bettype in (1,3,20) and (@autov8positiontaking <> @old_autov8positiontaking or @isautov8positiontaking <> @old_isautov8positiontaking ) and (@updatepositiontakingv8 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov8positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=8 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov8positiontaking <> @old_isautov8positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 and custsetting.isautopositiontaking=0
							
						END
					END
				END	

				---------------------------------
				--Update Golf
				if @bettype in (1,2,3,20) and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking ) and (@updatepositiontakingv10 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov10positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov10positiontaking <> @old_isautov10positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
							
						END
					END
				END	

				---------------------------------
				--Update Motorsports
				if @bettype in (1,20) and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking ) and (@updatepositiontakingv11 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov11positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov11positiontaking <> @old_isautov11positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 and custsetting.isautopositiontaking=0
							
						END
					END
				END	
				---------------------------------
				--Update Other sports
				if @bettype in (1,2,3,20) and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking ) and (@updatepositiontakingv99 = 1 or @updatemultiple=0)
				BEGIN
					if @isautov99positiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov99positiontaking <> @old_isautov99positiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
							
						END
					END
				END			
				
				---------------------------------
				--Update Mixed sports
				if @bettype =9 and (@autov99mppositiontaking <> @old_autov99mppositiontaking or @isautov99mppositiontaking <> @old_isautov99mppositiontaking ) and (@updatepositiontakingv99mp = 1 or @updatemultiple=0)
				BEGIN
					if @isautov99mppositiontaking >0
					BEGIN
						select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking > @autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
						from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
						where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
						
					END
					else if @isautov99mppositiontaking <> @old_isautov99mppositiontaking
					BEGIN
						if @updateallmembers = 1
						BEGIN
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
							from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
							inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
							where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 and custsetting.isautopositiontaking=0
							
						END
					END
				END---- end live
			
			FETCH NEXT FROM CUR INTO
					@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
					@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,	
					@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,	
					@isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,	
					@isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,	
					@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
					@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
					@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
					@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking		
		END

		CLOSE CUR
		DEALLOCATE CUR
	END
END	