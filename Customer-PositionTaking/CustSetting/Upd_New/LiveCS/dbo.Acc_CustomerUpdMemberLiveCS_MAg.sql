

ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_MAg]
	@custid									INT,		

	@v162mpositiontaking_1101				SMALLMONEY,	
	@auto_v162mpositiontaking_mem_1101			SMALLMONEY,
	@isauto_v162mpositiontaking_mem_1101		BIT,
	--im2
	@isauto_v162mpositiontaking_1101			BIT,

	@v162UpdatePositiontaking_1101			BIT = 1,	
	@v162UpdateAutoPositiontaking_1101		BIT = 1,

	@userid									INT,
	@SubAccID								INT = 0, --Sub-AccountID
	@Language								VARCHAR(2) = 'E',
	@IP										VARCHAR(19),
	@Username								NVARCHAR(50) = '' OUTPUT,	
	@ErrCode								VARCHAR(300) = '' OUTPUT,
	@ErrMsg									NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20120111@Lukas
	Task: Master edit live casino PT setting on member
	DB: DBTXN/BODB02
	
	Revisions:
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
		- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
		- 20130516@Lukas: allow PT = 100%
	Parameters Explanation:
*/
BEGIN

	SET NOCOUNT ON 

	declare @startRun datetime,
			@endRun datetime,
			@duration int

	set @startRun = getdate()

	DECLARE @ErrType varchar(1000), @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000),
			@recommend INT,	@srecommend INT, @mrecommend INT
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID = @mrecommend, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	---------------------------

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END

	
	select @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend 
	from customer with (NOLOCK) where custid = @custid

	IF (@v162mpositiontaking_1101 < 0 OR @v162mpositiontaking_1101 > 1
		OR @auto_v162mpositiontaking_mem_1101 < 0 OR @auto_v162mpositiontaking_mem_1101 > 1)
		AND @v162UpdatePositiontaking_1101 = 1
	BEGIN
		select @ErrCode_cur = 5
		Select @ErrMsg_cur = 	@UserName + ': ' +
			case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	DECLARE 
	--a1
	@v162apositiontaking_1101 SMALLMONEY,
	--a2
	@max_v162apositiontaking_1101 SMALLMONEY,
	--old_m1	
	@old_v162mpositiontaking_1101 SMALLMONEY,
	--old_um1
	@old_auto_v162mpositiontaking_mem_1101 SMALLMONEY,
	--old_im1
	@old_isauto_v162mpositiontaking_mem_1101 BIT,
	--s4
	@max_v162spositiontaking_1101 SMALLMONEY,
	@v162spositiontaking_1101 SMALLMONEY,
	--u1
	@auto_v162spositiontaking_mem_1101 SMALLMONEY,
	--i1
	@isauto_v162spositiontaking_mem_1101 BIT,
	--u3
	@auto_v162spositiontaking_1101 SMALLMONEY,
	--i3
	@isauto_v162spositiontaking_1101 BIT,
	--um2
	@auto_v162mpositiontaking_1101 SMALLMONEY,
	---- backup to write log
	@isauto_v162mpositiontaking_agent_1101 bit
	
	DECLARE
	@max_v162mapositiontaking_1101 SMALLMONEY,	
	@min_v162mapositiontaking_1101 SMALLMONEY
	
	
	-- backup
	SELECT 
	@isauto_v162mpositiontaking_agent_1101 = @isauto_v162mpositiontaking_1101
	--s1,a1,old_m1,u1,i1
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN
		SELECT	@v162spositiontaking_1101 = spositiontaking, 
				@v162apositiontaking_1101 = apositiontaking, 
				@auto_v162spositiontaking_mem_1101 = autopositiontaking, 
				@isauto_v162spositiontaking_mem_1101 = isautopositiontaking, 
				@old_v162mpositiontaking_1101 = mpositiontaking , 
				@old_auto_v162mpositiontaking_mem_1101 = autompositiontaking , 
				@old_isauto_v162mpositiontaking_mem_1101 = isautompositiontaking 
		FROM CustSettingGame WITH (NOLOCK) 
		WHERE custid = @custid AND bettype=1101 AND sporttype=162
	END

	--Check if old_PT = new_PT return
	IF @v162mpositiontaking_1101 = @old_v162mpositiontaking_1101 AND
		--um1
		@auto_v162mpositiontaking_mem_1101 = @old_auto_v162mpositiontaking_mem_1101 AND
		--im1
		@isauto_v162mpositiontaking_mem_1101 = @old_isauto_v162mpositiontaking_mem_1101
		
	BEGIN	
		Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)
		RETURN 
	END

	
	IF @v162UpdateAutoPositiontaking_1101 = 1 
	BEGIN
		--Check um1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-' + typenamee
		+ '-Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10))
		FROM CustSettingGame AS mcs WITH (NOLOCK) INNER JOIN
			(
				SELECT 162 AS sporttype, 1101 AS bettype, @auto_v162mpositiontaking_mem_1101 AS autopositiontaking, @isauto_v162mpositiontaking_mem_1101 AS isautopositiontaking
			) AS b ON mcs.sporttype=b.sporttype AND mcs.bettype=b.bettype
		INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype
		INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid
		WHERE mcs.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
	END

	--m3,u3,i3	
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN
		SELECT @max_v162mapositiontaking_1101 = mpositiontaking, @auto_v162spositiontaking_1101 = autopositiontaking, @isauto_v162spositiontaking_1101 = isautopositiontaking 
		FROM CustSettingGame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND bettype=1101 AND sporttype=162
		
		--n3
		SELECT @min_v162mapositiontaking_1101 = minpositiontaking 
		FROM CustOverrideGame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND bettype=1101 AND sporttype=162
		--s4
		SELECT @max_v162spositiontaking_1101 = spositiontaking 
		FROM CustSettingGame WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype=1101 AND sporttype=162
	END

	--um2
	SELECT 
		@auto_v162mpositiontaking_1101 = MAX(acs.autompositiontaking),
		--a2	
		@max_v162apositiontaking_1101 = MAX(acs.apositiontaking)
		
	FROM CustSettingGame acs WITH(NOLOCK)
	WHERE acs.custid = @recommend
			and acs.sporttype = 162 AND acs.bettype = 1101
			
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN	
		--Check m1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType 
		 + 'Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))
		FROM (
				SELECT 162 AS sporttype	,	 1101 AS bettype	,	 @v162mpositiontaking_1101 AS mpositiontaking	,	 @max_v162mapositiontaking_1101 AS maxmpositiontaking						
			)b 	
			INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype
			INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid
		WHERE (b.mpositiontaking>b.maxmpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
				
		--Check m1 + a1 >= n3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Min: ' + CAST(@min_v162mapositiontaking_1101 AS VARCHAR(10))  WHERE @v162apositiontaking_1101+@v162mpositiontaking_1101<@min_v162mapositiontaking_1101
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
					@ErrMsg_cur = CASE @Language 
						WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
				END
										
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT 
			@v162mpositiontaking_1101 = CASE WHEN @v162apositiontaking_1101+@v162mpositiontaking_1101>@max_v162mapositiontaking_1101 THEN @max_v162mapositiontaking_1101-@v162apositiontaking_1101 ELSE @v162mpositiontaking_1101 END

		--m1=m1+a1<n3?n3-a1:m1
		--SELECT 
		--	@v162mpositiontaking_1101 = CASE WHEN @v162apositiontaking_1101+@v162mpositiontaking_1101<@min_v162mapositiontaking_1101 THEN @min_v162mapositiontaking_1101-@v162apositiontaking_1101 ELSE @v162mpositiontaking_1101 END		

		SELECT 
			@v162mpositiontaking_1101 = CASE WHEN @v162mpositiontaking_1101<0 THEN 0 ELSE @v162mpositiontaking_1101 END
			
			
		--Must include code for auto master
			--um=im1>0?um1:um2
			--im=im1>0?im1:im2
			--m1=im>0?min(um,m3-a1):m1
			----------------------------------------------------------------------------------------------------------------------------
			--auto master

			--um=im1>0?um1:um2
			SELECT 
				@auto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_mem_1101>0 THEN @auto_v162mpositiontaking_mem_1101 ELSE @auto_v162mpositiontaking_1101 END,		
				
				--im=im1>0?im1:im31
				@isauto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_mem_1101>0 THEN @isauto_v162mpositiontaking_mem_1101 ELSE @isauto_v162mpositiontaking_1101 END			
			---------------------------------------------------------------------------------------------------------------------------------------------
		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @v162mpositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162mpositiontaking_1101, 0)<=0 THEN @v162mpositiontaking_1101 ELSE CASE WHEN @auto_v162mpositiontaking_1101 < @max_v162mapositiontaking_1101 - @v162apositiontaking_1101 THEN @auto_v162mpositiontaking_1101 ELSE @max_v162mapositiontaking_1101 - @v162apositiontaking_1101 END END
		-------------------------------------------------------------------------------
		
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_mem_1101>0 THEN @auto_v162spositiontaking_mem_1101 ELSE @auto_v162spositiontaking_1101 END,
			@isauto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_mem_1101>0 THEN @isauto_v162spositiontaking_mem_1101 ELSE @isauto_v162spositiontaking_1101 END		
		-----------------------------------------------------------------------------------------------------------------------------------------------

		------------------***Use Auto Position Taking***----------------------------------
		SELECT @v162spositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162spositiontaking_1101, 0)<=0 THEN @v162spositiontaking_1101 ELSE CASE WHEN @auto_v162spositiontaking_1101 < @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 - @v162apositiontaking_1101 THEN @auto_v162spositiontaking_1101 ELSE @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 - @v162apositiontaking_1101 END END
		
		---------------------------------------------------------------------------------
		----maxs1=isauto?s4:s4-m2
		SELECT @max_v162spositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162spositiontaking_1101, 0)>0 THEN @max_v162spositiontaking_1101 ELSE @max_v162spositiontaking_1101-@max_v162mapositiontaking_1101 END
		----s1=s1>maxs1?maxs1:s1
		SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 > @max_v162spositiontaking_1101 THEN @max_v162spositiontaking_1101 ELSE @v162spositiontaking_1101 END
				
	END
	--don't update m1,s1 for member under agent was set im2=1
	UPDATE cs WITH (ROWLOCK, UPDLOCK)
	SET
		mpositiontaking = CASE	WHEN cs.bettype = 1101 and cs.sporttype = 162 THEN @v162mpositiontaking_1101 
							ELSE cs.mpositiontaking END,
		spositiontaking = CASE WHEN cs.bettype = 1101 and cs.sporttype = 162 THEN @v162spositiontaking_1101 
							ELSE cs.spositiontaking END
	FROM CustSettingGame cs 
		INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
	WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 AND cs.sporttype = 162

	
	--Update auto PT
	--------------------------------------------------------
	--Update Member account (autompositiontaking field)
	update CustSettingGame with (ROWLOCK, UPDLOCK) 
	set autompositiontaking =  b.autompositiontaking, 
		isautompositiontaking = b.isautompositiontaking 
	from CustSettingGame as cs inner join 
			(
				--select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
				select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
			 ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
	where cs.custid = @custid
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrCode_cur = 101,
				@ErrMsg_cur =  
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
		SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	declare @maxpos smallmoney
	if @isauto_v162mpositiontaking_1101 >0 
	BEGIN
		select @maxpos = mpositiontaking from CustSettingGame with (NOLOCK) where custid = @mrecommend and sporttype=162 and bettype = 1101
		update CustSettingGame with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @maxpos - apositiontaking end
		from CustSettingGame as cs
		where custid = @custid and cs.bettype = 1101 and cs.sporttype = 162
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	
	--- modify late
	EXEC dbo.Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend


	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(5000)

	Select @LogSPData = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
	'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +	
	'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

	
	
	Select @TrackingValueDB = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v162mpositiontaking_1101="'+ coalesce(cast(@old_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
	'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@old_isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@old_auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

	
	
	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 429,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
		'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
		'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
		'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +	
		'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
		'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
		'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
		
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 429,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH


	Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)

END

GO
GRANT VIEW DEFINITION ON [Acc_CustomerUpdMemberLiveCS_MAg] TO vnteam
GO
GRANT EXEC ON [Acc_CustomerUpdMemberLiveCS_MAg] TO bodbAdminNet
GO
GRANT EXEC ON [Acc_CustomerUpdMemberLiveCS_MAg] TO bodbDownlineNet


