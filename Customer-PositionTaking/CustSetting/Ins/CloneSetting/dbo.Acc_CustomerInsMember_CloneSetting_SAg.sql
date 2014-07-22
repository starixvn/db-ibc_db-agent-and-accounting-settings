ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_SAg]
	@Custid int output
	,@UserName varchar(30)
	,@Userpwd varchar(40)
	,@FirstName nvarchar(50)
	,@LastName nvarchar(50)
	,@Phone nvarchar(50)
	,@MobilePhone nvarchar(50)
	,@Fax nvarchar(50)
	,@Credit money	
	,@Creator int
	,@srecommend int	
	,@ExistingCustid int
	,@SubAccountID int=0	
	,@Language varchar(2)= 'E'
	,@IP varchar(15)=''		
	,@ErrCode int = 0 output
	,@ErrMsg nvarchar(4000) = '' output
AS
/*  
 Created by: Dan  
 Date:20120207
 Original: dbo.Agm_CustomerInsMember_Ag, Acc_CustomerInsMember_SAg
 Task: Add new master from existing master
	(#436.2 IRP - AgeSite - Search&Copy feature to feature to facilitate downline creation) 
 
 DB: DBTXN/CustDB  
  
 History:  
	- 20120323 @Dan: check roleid and the super of existing master before copying 
	- 20120820@Dan: add 3 fields in custinfo table (VS)
	- 20120829@Dan: isSync status for 3 products - Casino, Bingo and LiveCasino will not be cloned
	- 20120928@Dan: add fields for LCS-win limit
	- 20121012@Johnson: check double comm losing status by upline
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20130220@Johnson: Add virtual horse racing setting (sporttype : 181 , bettype : 1231)
	- 20130328@Jamie: Add CustLoginInfo 
	- 20130423@Jamie: Set isForcedChangeSecurityCode = 1 WHEN Upline's SecurityCode NOT NULL 
	- 20130731@Elodie: Apply progressive bonus
	- 20131017@Kathy: Add HR Fixed Odds [Redmine:#6505]
	- 20131107@Kathy: Separate auto-suspend into Soccer and Other Sport [Redmine:#5520] 
	- 20131113@Johnson: Apply execrep when insert setting into CustSetting/CustSetting3rd/...
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184) [Redmine:#7234]
	- 20140303@Patrick: Add more sport:202 for Keno
	- 20140402@Dom: Add more sport: 183,185 for Virtual sport
	- 20140609@Elodie: Not allow create a new customer by using search & copy function from a existed account which is disabled [Redmine:#17366]
	- 20140619@Johnson: check IP valid to create downlines [RedmineID: #17746]
 Explanation's Param:  
	• @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	• @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON
	
--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP bit
	
	EXEC Acc_CustomerInsMember_CheckIP 
			@IP = @IP,
			@isValid = @isValidIP OUTPUT
	
	IF @isValidIP = 0
	BEGIN
		Select	@ErrMsg = case @Language 
						when 'E' then 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					end,
				@ErrCode = 1001	
		return
	END
--End check IP--------------------------------------------------

	DECLARE @startRun datetime
		,@endRun datetime
		,@duration int
		,@pwdexpiry datetime
		,@mrecommend int
				
	IF EXISTS (SELECT 1 FROM dbo.customer WITH(NOLOCK) WHERE username=@username OR username2=@username
			UNION ALL
				SELECT 1 FROM dbo.custsub WITH(NOLOCK) WHERE username= @username
		)
	BEGIN		
		Select @ErrMsg = case @Language 
								when 'E' then 'This username is not available.'								
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
							end		
				,@ErrCode = 201
		return		

	END	


	-- Check role and master of existing agent
	DECLARE @existingUsername varchar(30),@roleid tinyint, @existingSrecommend int, @Enabled BIT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @existingSrecommend = ISNULL(srecommend,0), @Enabled = ISNULL(Enabled, 0)
	FROM dbo.custInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	IF ( NOT (@roleid = 3 AND @existingSrecommend = @srecommend))
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		return		

	END	

	IF @Enabled = 0
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This account was disabled!' + ' (' + @existingUsername + ')'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60020,@Language) + ' (' + @existingUsername + ')'
								END, 
						@ErrCode = 203
		RETURN		
	END		

	--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)  
	--20081218_By_AhWan: KER - 1238537  
	--20090112_Wan: unblock KM 194354  
	--20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR   
	if @srecommend = 726582  
	BEGIN  
	 Select @ErrMsg = case @Language   
		  when 'E' then 'Sorry, cannot create master.'  
		  ELSE [dbo].[f_Get_MsgNamebyMsgID](40012,@Language) 
		 end,@ErrCode = 100   	  	
	   
	 return  
	END 		

	--CREDIT CHECK

	DECLARE @Credit_AllOtherMaster MONEY, @Credit_SAg MONEY
	SELECT @Credit_AllOtherMaster = ISNULL(SUM(credit), 0) 
	FROM custinfo AS ci WITH (NOLOCK) 
	WHERE srecommend = @srecommend and RoleID = 3  
  
	SELECT @Credit_SAg = ISNULL(credit, 0)		
	FROM CustInfo as ci with (NOLOCK) 
	WHERE CustID = @srecommend

	IF @Credit_AllOtherMaster + @Credit > @Credit_SAg
	BEGIN  
		SET @ErrMsg = case @Language   
		  WHEN 'E' then 'Sorry, credit update is not successful, You have exceeded your super agent credit.'  
		  ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
		 END   
		SELECT @ErrCode = 101  
		RETURN  
	END  

		
	SELECT @pwdexpiry = dateadd(dd, 30, getdate())
		,@startRun = getdate()
	
	--INSERT GENERAL INFORMATION OF CUSTOMER
	INSERT INTO dbo.customer
		(firstname
		,lastname
		,address
		,postal
		,city
		,state
		,country
		,phone
		,mobilephone
		,fax
		,email
		,birthday
		,refcode1
		,refcode2
		,remark
		,creatdate
		,creator
		,username
		,currency
		,userpwd				
		,roleid
		,srecommend 
		,mrecommend
		,recommend
		,ugroup		
		,site		
		,pwdexpiry
		)
	SELECT
		@firstname
		,@lastname
		,'-' AS address
		,'-' AS postal
		,'-' AS city
		,'-' AS state
		,'-' AS country
		,@phone
		,@mobilephone
		,@fax
		,'-' AS email
		,NULL AS birthday
		,NULL AS refcode1
		,NULL AS refcode2
		,NULL AS remark
		,GETDATE() AS creatdate
		,@creator
		,@username
		,currency
		,@userpwd				
		,3 AS roleid
		,srecommend		
		,0 AS mrecommend
		,0 AS recommend 
		,ugroup		
		,site				
		,@pwdexpiry
	FROM dbo.customer WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	SET @Custid = SCOPE_IDENTITY()
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
						end
			,@ErrCode = 103
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
	
	SET @mrecommend = @custid
	UPDATE Customer WITH (ROWLOCK, UPDLOCK) 
	SET mrecommend = @custid 
	WHERE custId = @CustID  
	
	IF @@error <> 0
	BEGIN
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 104
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	
			
	-- insert CustMaster info
	INSERT INTO CustMaster(custId, DisableAutoMPT, IsInternal, TransferOption)  
	SELECT @CustID,
			DisableAutoMPT,
			IsInternal,
			TransferOption
	FROM dbo.CustMaster WITH(NOLOCK)
	WHERE custid=@ExistingCustid		

	IF @@ERROR <> 0  
	BEGIN  
		SELECT @ErrMsg = CASE @Language   
		   WHEN 'E' THEN 'Create customer failed. Please try again.'  
		   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		  END,  
		@ErrCode = 105  

		-- ROLLBACK MANUALLY  

		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  
		 
		RETURN  
	END  

	DECLARE @enableUpline bit, @doubleCommLosingUpline bit
	-- get autosuspend's upline
	Declare @autosuspend BIT,
		@autosuspend2 BIT

	select @enableUpline = isnull(enabled,0), @doubleCommLosingUpline = DoubleCommLosing,
		 @autosuspend = ISNULL(autosuspend, 0),
		 @autosuspend2 = ISNULL(autosuspend2, 0)
	from custinfo with (nolock)
	where custid = @srecommend

	-- insert CustInfo info
	INSERT INTO dbo.custInfo
			(custid
			,username
			,currency
			,roleid
			,srecommend
			,mrecommend
			,recommend
			,dangercust
			,autosuspend
			,autosuspend2
			,reject
			,credit
			,closed
			,MatchLimit
			,VirtualMultiplier
			,maxpermatch
			,maxpermatch2
			,maxpermatch3
			,maxpermatch5
			,maxpermatch8
			,maxpermatch10
			,maxpermatch11
			,maxpermatch12
			,maxpermatch99
			,Enabled           
			,maxpermatch151
			,maxpermatch201
			,DisableHorseRacing
			,DisableFinancial
			,DisableCasino
			,SyncCasino           
			,DisableOutright
			,DisableOpenTote
			,maxpermatch151_OT
			,MaxPerMatch99MP
			,DisableBingo
			,DisableNumber
			,maxpermatch161
			,SyncBingo
			,MaxPerBall161
			,MaxPerMatch151_AU
			,MaxPerMatch152_UK
			,MaxPerMatch152_AU
			,MaxPerMatch153_AU
			,Disable151_AU
			,Disable152_UK
			,Disable152_AU
			,Disable153_AU
			,MaxTransferP2P
			,IsAutoResetP2P
			,DisableP2P
			,DisableFunP2P
			,DisableLiveCasino
			,SyncLiveCasino
			,DisableVirtualSports
			,HideVirtualSports
			,maxpermatch180
			,maxpermatch181
			,maxpermatch183--dom
			,maxpermatch185--dom
			,maxpermatch182
			,maxpermatch184
			,maxpermatch186
			,isAutoResetLiveCasino
			,MaxWinLiveCasino
			,DoubleCommLosing
			,DisableCasinoBonus
			,DisableHRFixedOdds
			,maxpermatch154
			,HideKeno
			)
     SELECT
			@custid
			,@username
			,currency
			,3 AS roleid
			,srecommend
			,@mrecommend
			,0 as recommend
			,0 AS dangercust
			,@autosuspend AS autosuspend
			,@autosuspend2 as autosuspend2
			,reject
			,@Credit AS Credit
			,closed
			,MatchLimit
			,VirtualMultiplier
			,maxpermatch
			,maxpermatch2
			,maxpermatch3
			,maxpermatch5
			,maxpermatch8
			,maxpermatch10
			,maxpermatch11
			,maxpermatch12
			,maxpermatch99
			,@enableUpline as Enabled           
			,maxpermatch151
			,maxpermatch201
			,DisableHorseRacing
			,DisableFinancial
			,DisableCasino
			,0 as SyncCasino           
			,DisableOutright
			,DisableOpenTote
			,maxpermatch151_OT
			,MaxPerMatch99MP
			,DisableBingo
			,DisableNumber
			,maxpermatch161
			,0 as SyncBingo
			,MaxPerBall161
			,MaxPerMatch151_AU
			,MaxPerMatch152_UK
			,MaxPerMatch152_AU
			,MaxPerMatch153_AU
			,Disable151_AU
			,Disable152_UK
			,Disable152_AU
			,Disable153_AU
			,MaxTransferP2P
			,IsAutoResetP2P
			,DisableP2P
			,DisableFunP2P
			,DisableLiveCasino
			,0 as SyncLiveCasino
			,DisableVirtualSports
			,HideVirtualSports
			,maxpermatch180
			,maxpermatch181
			,maxpermatch183--dom
			,maxpermatch185--dom
			,maxpermatch182
			,maxpermatch184
			,maxpermatch186
			,isAutoResetLiveCasino
			,MaxWinLiveCasino
			,@doubleCommLosingUpline as doubleCommLosing
			,1
			,DisableHRFixedOdds
			,maxpermatch154
			,HideKeno
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE custid=@ExistingCustid  
        
	IF @@error <> 0
	BEGIN 	
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
					
		-- ROLLBACK MANUALLY			
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  

		RETURN
	END
	
	EXEC dbo.Acc_CustomerInfo_Execrep_02
			@custid = @custid,
			@ExistingCustid = @ExistingCustid,
			
			@ErrCode = @ErrCode output
	
	IF @ErrCode > 0 
	BEGIN
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end

		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  
		
		RETURN
	END

	DECLARE	 @UplineSecurityCode			VARCHAR(50)
			,@isForcedChangeSecurityCode	BIT
			
	SELECT	@UplineSecurityCode				= NULL
			,@isForcedChangeSecurityCode	= 0

	SELECT	@UplineSecurityCode	= SecurityCode
	FROM	dbo.CustLoginInfo WITH (NOLOCK)
	WHERE	CustID = @SRecommend 
	
	IF	@UplineSecurityCode IS NOT NULL 
		SELECT	@isForcedChangeSecurityCode = 1  -- Force Set Security Code when login

	INSERT INTO dbo.CustLoginInfo(CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin
		,SecurityCodeCount,SecurityCode,isForcedChangeSecurityCode,LastChangedSecurityCodeDate
	)
	VALUES(@custid,NULL,GETDATE(),1
		,0,NULL,@isForcedChangeSecurityCode,NULL
	)
	
	IF @@ERROR<>0
	BEGIN
		--Error occur
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								when 'CS' then N'新增会员不成功，请重新尝试.'
								when 'CT' then N'新增會員不成功,請重新再試.'
								when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
								when 'J' then N'Create customer failed. Please try again.'
								when 'ES' then N'Create customer failed. Please try again.'
								when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
								else N'Create customer failed. Please try again.'
							end,
			@ErrCode = 115
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.CustGameType WITH (ROWLOCK) WHERE CustID =@CustID					
		DELETE FROM dbo.Custoverridegame WITH (ROWLOCK) WHERE CustID =@CustID					
		DELETE FROM custsettingGame with (ROWLOCK) where custid =  @custid
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID				
		DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		
		RETURN	
	END
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	Declare @LogSPData varchar(8000)
	--Log customer general info
	Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
	'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +	
	'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
	'CopiedFomUsername="'+c.username+'" '+
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 630,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH	
		--Log customer general info
		Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
		'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
		'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +

		'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
		'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +	
		'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +	
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
		'CopiedFomUsername="'+c.username+'" '+
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccountID) as varchar(30)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 630,
			@TrackingValue = @LogSPData,
			@duration = @duration		
	END CATCH
		
	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInsMember_CloneSetting_SAg] TO [vnteam] AS [dbo]