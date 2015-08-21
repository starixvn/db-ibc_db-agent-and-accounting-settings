
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Acc_CustomerUpdColossusBet_Main]') AND type in (N'P', N'PC'))
		DROP PROCEDURE [dbo].[Acc_CustomerUpdColossusBet_Main]

GO

/*  
    Created By: Helen  
    Created Date: Aug 18, 2015
    Description: Colossus Bet Product
    
    DB: DBCUST/CUSTDB  
*/  

CREATE PROCEDURE [dbo].Acc_CustomerUpdColossusBet_Main
(    
    @custid        INT,          
    
    -- Update Flags 
    @IsUpdateCommission_18001 BIT = NULL,
    @IsUpdateCashInShare_18002 BIT = NULL,
    @IsUpdateDisable BIT = NULL,
    @IsUpdateCustInfo BIT = NULL,
    
    -- updated Value for Commission & Cash In Share
    @v204Commission_18001 SMALLMONEY = NULL,  
    @v204CashInShare_18002 SMALLMONEY = NULL,  
    
    -- Cust Info
    @disCasino bit = 0,      
    @firstname NVARCHAR(50),  
    @lastname NVARCHAR(50),  
    @phone NVARCHAR(50),      
    @mobilephone NVARCHAR(50),  
    @email NVARCHAR(50) = '',  
    @fax NVARCHAR(50), 
    @SubAccID       int = 0, --Sub-AccountID   
    
 
    @IP         VARCHAR(50)  = '',      
    @UserID        INT    = 0,  
    @Language       VARCHAR(20)  = 'E',          
    
    @ErrCode       VARCHAR(300) = '' OUTPUT,  
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT  
      
)
AS  

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

	IF (@roleid = 0)   
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

	-- Update Comission Processing
	IF @IsUpdateCommission_18001 = 1  
	BEGIN          
		EXEC Acc_CustomerUpdColossusBet_Processing  
			@custid    = @custid  
			,@v204discountValue = @v204Commission_18001
			,@v204DiscountType =  18001
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
	IF @IsUpdateCashInShare_18002 = 1  
	BEGIN          
		EXEC Acc_CustomerUpdColossusBet_Processing  
			@custid    = @custid  
			,@v204discountValue = @v204CashInShare_18002
			,@v204DiscountType =  18002
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

