
ALTER PROCEDURE [dbo].[Acc_CustomerUpdColossusBet_Processing]   
    @custid    INT,  
    @v204discountValue DECIMAL(9,8) = NULL,  
    @v204DiscountType INT = NULL,
    @roleID INT = NULL,  
    @IP     VARCHAR(50)  = '',      
    @UserID    INT    = 0,  
    @Language   VARCHAR(20)  = 'E',          
    @ErrCode   INT    = 0   OUTPUT,  
    @ErrMsg    NVARCHAR(4000) = ''  OUTPUT  
AS 
/*  
    Created: Helen  
    Date: 20150821
    Task: #42208 - Updating: Commission/Cash In Share
    DB: DBCUST / CustDB
    
    
	Revisions:
	
	Parameters Explanation:
		@v204discountValue: New discount value needs to be updated
		@v204DiscountType: to detect commission OR Cash in Share
	
*/ 
 
BEGIN  
  
	SET NOCOUNT ON  

	DECLARE @startRun DATETIME  
		,@endRun DATETIME   
		,@duration INT  

	SET @startRun = GETDATE()  

	DECLARE @ErrCode_Cur INT  
		,@ErrMsg_Cur NVARCHAR(4000)  
		,@ErrAcc  NVARCHAR(4000)  
		 
	SELECT @ErrCode_Cur = 0  
		,@ErrMsg_Cur = ''  
		,@ErrCode = ''  
		,@ErrMsg = ''  

	---------------------------  
	IF (@roleid = 0 OR @roleid = 1) RETURN  
	---------------------------  

	--Check disable user  
	EXEC Acc_CustomerSelCheckEnable   
		@custid  = @custid  
		,@ErrCode = @ErrCode_Cur OUTPUT  
		,@ErrMsg = @ErrMsg_Cur OUTPUT  

	IF @ErrCode_Cur > 0  
	BEGIN  
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
	  
		RETURN  
	END  
	--end  
	/*
	--Check Allowed downlines      
	EXEC Acc_CustomerSelCheckAllowedDownlines      
	@custid  = @custid,  
	@roleid  = @roleid,
	@isExecRep = 1,  
	@isUpdatePT = 0,  
	@Sporttype = 204,  
	@Language ='E',  
	@ErrMsg  = @ErrMsg OUTPUT,  
	@ErrCode = @ErrCode OUTPUT  
	*/

	IF @ErrCode <> 0   
	RETURN   

	DECLARE @LogSPData varchar(MAX), @TrackingValueDB varchar(4000)  
	DECLARE @db_v204discountValue DECIMAL(9,8)  
	DECLARE @v204MaxdiscountValue DECIMAL(9,8)  
	   
	 IF @v204DiscountType IS NOT NULL  
	 BEGIN         
		 SELECT @db_v204discountValue = sdiscount + adiscount + adiscount  
		 FROM CustSettingGame WITH(NOLOCK)  
		 WHERE custid = @custid   
			   AND sporttype = 204   
			   AND bettype = @v204DiscountType
		  
		 IF @db_v204discountValue = @v204discountValue   
			RETURN  
		       
		 SET @v204MaxdiscountValue = (SELECT Maxsdiscount FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 204 AND Bettype = @v204DiscountType) 
		 
		 IF @v204discountValue < 0 OR ( @v204discountValue > @v204MaxdiscountValue)  
		 BEGIN      
			  SELECT @ErrMsg = CASE 
									WHEN @Language = 'E' AND @v204DiscountType = 18001 THEN 'Invalid commission rate.' 
									WHEN @Language = 'E' AND @v204DiscountType = 18002 THEN 'Invalid cash in share rate.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)  
								END  
				   ,@ErrCode = 103  
			  RETURN  
		 END  
		  
		 -- Apply exec rep  
		  EXEC Acc_CustSetting3rd_06  
			   @CustId    = @custid,  
			   @RoleId    = @roleid,  
			   @Discount   = @v204discountValue,  
			   @mode    = 'ColossusBet',  
			   @Sporttype   = 204,  
			   @Bettype   = @v204DiscountType  
	 
		        
		 SELECT @LogSPData = '<Acc_CustomerUpdColossusBet_Processing Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
			  '@v204discountValue="' + COALESCE(CAST(@v204discountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
			  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'  
		  
		 SELECT @TrackingValueDB = '<Acc_CustomerUpdColossusBet_Processing Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
			  '@v204discountValue="' + COALESCE(CAST(@db_v204discountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
			  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'  
		  
		  
		 SET @endRun = GETDATE()  
		 SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)  
		  
		 --Log customer info   
		 BEGIN TRY  
			  EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			   @UserID   = @UserID,  
			   @CustID   = @CustID,  
			   @ActionID  = @v204DiscountType,  
			   @TrackingValue = @LogSPData,  
			   @TrackingValue2 = @TrackingValueDB,  
			   @duration  = @duration  
		 END TRY  
		 BEGIN CATCH  
			  SELECT @LogSPData = '<Acc_CustomerUpdColossusBet_Processing Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
				  '@v204discountValue="' + COALESCE(CAST(@v204discountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
				  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'ErrMsg="'+ ERROR_MESSAGE() + '" />'  
		       
			  EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			   @UserID = @UserID,  
			   @CustID = @CustID,  
			   @ActionID = @v204DiscountType,  
			   @TrackingValue = @LogSPData,  
			   @TrackingValue2 = @TrackingValueDB,  
			   @duration = @duration  
		 END CATCH 
		 
		 END   
		 
	 SET NOCOUNT OFF
	   
END