
ALTER PROCEDURE [dbo].Acc_CustomerUpdColossusBet
(    
    @custid        INT,          
    
    -- Update Flags 
    @IsUpdateCommission BIT = NULL,
    @IsUpdateCashInShare BIT = NULL,
    @IsUpdateDisable BIT = NULL,
        
    -- updated Value for Commission & Cash In Share
    @v204Commission_18001 SMALLMONEY = NULL,  
    @v204CashInShare_18002 SMALLMONEY = NULL,  
    @EnableDownlines BIT = 0,
 
    @IP         VARCHAR(50)  = '',      
    @UserID        INT    = 0,  
    @Language       VARCHAR(20)  = 'E',          
    
    @ErrCode       VARCHAR(300) = '' OUTPUT,  
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT  
      
)
AS  
/*  
    Created: Helen  
    Date: 20150821
    Task: Updating Colossus Bet Module: Disable/Commission/Cash In Share (Redmine: #42208)
    DB: DBCUST / CustDB
    
    
	Revisions:
	
	Parameters Explanation
	
*/ 
BEGIN  
	SET NOCOUNT ON   

	DECLARE @roleid  TINYINT  
		,@ErrCode_Cur INT  
		,@ErrMsg_Cur NVARCHAR(4000)  
		,@ErrAcc  NVARCHAR(4000)  

	SELECT @ErrCode_Cur = 0  
		,@ErrMsg_Cur = ''  
		,@ErrCode = ''  
		,@ErrMsg = ''  

	---------------------------  
	-- ***Check Downline Belonging***  
	EXEC Age_CustomerSelCheckBelongingByCustID   
		@SessionCustID = @Userid,   
		@Custid   = @custid,  
		@roleid   = @roleid OUTPUT  

	IF (@roleid = 0 OR @roleid = 1)   
		RETURN  
	
	--Check disable user  
	EXEC Acc_CustomerSelCheckEnable   
		@custid  = @custid  
		,@ErrCode = @ErrCode_Cur OUTPUT  
		,@ErrMsg = @ErrMsg_Cur OUTPUT  

	IF @ErrCode_Cur > 0  
	BEGIN  
		SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)  
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
	  
		RETURN  
	END  

	-- Find parent
	DECLARE @ParentCustID INT = NULL
	
	IF @roleid <> 4
	BEGIN
		SELECT @ParentCustID = CASE 
									WHEN @roleid = 2 THEN mrecommend
									WHEN @roleid = 3 THEN srecommend
								END	
		FROM custInfo WITH (NOLOCK)
		WHERE custid = @custid
	END 	
	
	-- Reset discount value in case its value > upline
	IF @ParentCustID IS NOT NULL
	BEGIN
		-- Commission
		SELECT @v204Commission_18001 = CASE 
											WHEN @v204Commission_18001 > commRate THEN commRate
											ELSE @v204Commission_18001   
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @ParentCustID   
			AND sporttype = 204   
			AND bettype = 18001  
		
		-- Cash In Share
		SELECT @v204CashInShare_18002 = CASE 
											WHEN @v204CashInShare_18002 > commRate THEN commRate
											ELSE @v204CashInShare_18002   
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @ParentCustID   
			AND sporttype = 204   
			AND bettype = 18002  	
		
	
	END
	-- Update Comission Processing
	IF @IsUpdateCommission = 1  
	BEGIN          
		EXEC Acc_CustomerUpdColossusBet_Commission  
			@custid    = @custid  
			,@roleid = @roleid
			,@DiscountValue = @v204Commission_18001
			,@DiscountType =  18001
			,@ActionID = 242
			,@IP    = @IP 
			,@UserID   = @userid  
			,@Language   = @Language  
			,@ErrCode   = @ErrCode_Cur OUTPUT  
			,@ErrMsg   = @ErrMsg_Cur OUTPUT  
	   
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		END  
		ELSE  
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)          
	END  

	-- Update Cash In Share Processing 
	IF @IsUpdateCashInShare = 1  
	BEGIN
		  
		-- Reset discount value
		/*
		SELECT @v204discountValue = CASE WHEN @v204discountValue > sdiscount THEN sdiscount   
			  ELSE @v255discount_1701   
			 END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @srecommend   
			AND sporttype = 204   
			AND bettype = 18001  
		*/
	          
		EXEC Acc_CustomerUpdColossusBet_Commission  
			@custid    = @custid  
			,@DiscountValue = @v204CashInShare_18002
			,@DiscountType =  18002
			,@ActionID = 243
			,@UserID   = @userid  
			,@Language   = @Language  
			,@ErrCode   = @ErrCode_Cur OUTPUT  
			,@ErrMsg   = @ErrMsg_Cur OUTPUT  
		   
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
			
		END  
		ELSE  
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)          
	END  
	
	-- Update Disable Colossus Bet Product
	IF @IsUpdateDisable = 1
	BEGIN
		
		EXEC Acc_CustomerUpdDisableColossusBet @custid=@custid,@Disable=@IsUpdateDisable,@EnableDownlines=@EnableDownlines,@UserID=@UserID,@SubAccID=default,@IP=@IP,@Language='E',@ErrCode=@ErrCode_Cur OUTPUT,@ErrMsg=@ErrMsg_Cur OUTPUT  
		
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		      
		END  
		ELSE  
		
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)   
		
		
	END
	
	SET NOCOUNT OFF
  
END

