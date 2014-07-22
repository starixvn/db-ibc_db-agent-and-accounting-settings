ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_Com]
	@Custid int output
	,@UserName varchar(30)
	,@Userpwd varchar(40)
	,@FirstName nvarchar(50)
	,@LastName nvarchar(50)
	,@Phone nvarchar(50)
	,@MobilePhone nvarchar(50)
	,@Site nvarchar(50)
	,@Fax nvarchar(50)
	,@Credit money	
	,@IsInternal BIT
	,@ExistingCustid int
	,@Creator int	
	,@Language varchar(2)= 'E'
	,@IP varchar(15)=''		
	,@ErrCode int = 0 output
	,@ErrMsg nvarchar(4000) = '' output
AS
/*  
 Created by: Elodie  
 Date:20131025
 Original: 
 Task: Add new super from existing super [Redmine:#5456]
 DB: DBTXN/CustDB  
  
 History:  
	- 20131113@Johnson: Apply execrep when insert setting into CustSetting/CustSetting3rd/...
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184) [Redmine:#7234]
	- 20140304@Patrick	: Add more sport: 202 for Keno
	- 20140402@Dom	: Add more sport: 183,185 for Virtual sport
	- 20140609@Elodie: Not allow create a new customer by using search & copy function from a existed account which is disabled [Redmine:#17366]
 Explanation's Param:  
	• @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	• @ErrMsg: Error description.	
  
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun datetime
		,@endRun datetime
		,@duration int
		,@srecommend int
				
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

	-- Check role of existing super
	DECLARE @existingUsername varchar(30),@roleid tinyint, @Enabled BIT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @Enabled = ISNULL(Enabled, 0)
	FROM dbo.CustInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	IF @roleid <> 4
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		RETURN		
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
	SELECT @startRun = getdate()
	
	BEGIN TRY
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
			,important
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
			,4 AS roleid
			,0 as srecommend		
			,0 AS mrecommend
			,0 AS recommend 
			,ugroup		
			,@site				
			,NULL
			,0 as important
		FROM dbo.customer WITH(NOLOCK)
		WHERE custid=@ExistingCustid		

		SET @Custid = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language) 
						end
			,@ErrCode = 103			
		RETURN
	END	CATCH
	
	BEGIN TRY
		SET @srecommend = @CustID
		UPDATE Customer WITH (ROWLOCK, UPDLOCK) 
		SET srecommend = @CustID 
		WHERE custId = @CustID  
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end
			,@ErrCode = 104
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.customer With (ROWLOCK) WHERE CustID = @CustID			
		RETURN
	END	CATCH
			
	BEGIN TRY
		-- insert CustSuper info
		INSERT INTO CustSuper(custId, AutoIBCPositionTaking_Tote, AutoIBCPositionTaking_Fixed, AutoIBCPT151_AU, AutoIBCPT152_UK, AutoIBCPT152_AU, AutoIBCPT153_AU, IsInternal, TransferOption, LimitPerIP, SelectedBetting)  
		SELECT	@CustID, AutoIBCPositionTaking_Tote, AutoIBCPositionTaking_Fixed, AutoIBCPT151_AU, AutoIBCPT152_UK, AutoIBCPT152_AU, AutoIBCPT153_AU, @IsInternal, TransferOption, LimitPerIP, SelectedBetting
		FROM CustSuper WITH(NOLOCK)
		WHERE custid=@ExistingCustid		
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = CASE @Language   
		   WHEN 'E' THEN 'Create customer failed. Please try again.'  
		   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
		  END,  
		@ErrCode = 105  

		-- ROLLBACK MANUALLY  
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  		 
		RETURN  
	END CATCH
	
	BEGIN TRY
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
				@CustID
				,@username
				,currency
				,4 AS roleid
				,@srecommend
				,0 as mrecommend
				,0 as recommend
				,dangercust
				,0 AS autosuspend
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
				,Enabled           
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
				,doubleCommLosing
				,DisableCasinoBonus
				,DisableHRFixedOdds
				,maxpermatch154
				,HideKeno
		FROM dbo.custinfo WITH(NOLOCK)
		WHERE custid=@ExistingCustid  
	END TRY	
	BEGIN CATCH	
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
					
		-- ROLLBACK MANUALLY			
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	    
		DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID  

		RETURN
	END CATCH
	
	BEGIN TRY
	EXEC dbo.Acc_CustomerInfo_Execrep_02
		@custid = @custid,
		@ExistingCustid = @ExistingCustid,
		@Language = @Language,
		@ErrCode = @ErrCode output,
		@ErrMsg = @ErrMsg output
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
		-- ROLLBACK MANUALLY	
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  
		
		RETURN
	END CATCH
	
	BEGIN TRY
		INSERT INTO dbo.CustLoginInfo(CustID,OldUserPwd,LastChangedPwdDate,isFirstLogin
			,SecurityCodeCount,SecurityCode,isForcedChangeSecurityCode,LastChangedSecurityCodeDate
		)
		VALUES(@custid,NULL,GETDATE(),1
			,0,NULL,0,NULL)
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = case @Language 
								when 'E' then 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							end
				,@ErrCode = 106
			
		-- ROLLBACK MANUALLY
		DELETE FROM dbo.Customer WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM dbo.CustInfo WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID  	
		DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		DELETE FROM Custoverridegame WITH (ROWLOCK) WHERE CustID = @CustID					
		DELETE FROM CustGameType WITH (ROWLOCK) WHERE CustID = @CustID					
		RETURN	
	END CATCH
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	Declare @LogSPData varchar(8000)
	--Log customer general info
	Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
	'site="'+ coalesce(cast(@site as varchar(50)),space(1)) + '" ' +	
	'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +	
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
	'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
	'CopiedFromUsername="'+c.username+'" '+
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
	FROM dbo.customer AS c WITH(NOLOCK) 
	WHERE custid=@ExistingCustid
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 638,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH	
		--Log customer general info
		Select @LogSPData = '<Acc_CustomerInsMember_CloneSetting_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
		'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
		'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
		'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
		'site="'+ coalesce(cast(@site as varchar(50)),space(1)) + '" ' +	
		'credit="'+ coalesce(cast(@Credit as varchar(50)),space(1)) + '" ' +	
		'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +	
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +	
		'CopiedFrom="'+cast(@ExistingCustid as varchar(10))+'" '+
		'CopiedFromUsername="'+c.username+'" '+
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'
		FROM dbo.customer AS c WITH(NOLOCK) 
		WHERE custid=@ExistingCustid
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 638,
			@TrackingValue = @LogSPData,
			@duration = @duration		
	END CATCH
		
	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_CloneSetting_Com] TO [bodbadminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInsMember_CloneSetting_Com] TO [vnteam] AS [dbo]