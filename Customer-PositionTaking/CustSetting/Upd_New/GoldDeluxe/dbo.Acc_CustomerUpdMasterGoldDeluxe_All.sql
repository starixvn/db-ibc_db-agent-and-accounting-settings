USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All]    Script Date: 04/24/2015 14:14:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All]
    @custid								INT,
    @srecommend							INT,
    @v255spositiontaking_1701			SMALLMONEY,
    @v255mpositiontaking_1701			SMALLMONEY,
    
    @isauto_v255spositiontaking_1701	BIT,
    @auto_v255spositiontaking_1701		SMALLMONEY,
    @v255mpositiontaking_1701_min		SMALLMONEY,
    @v255discount_1701					SMALLMONEY,
    
    @v255UpdatePositiontaking_1701		BIT				= 1,
    @v255UpdateMinPositiontaking_1701	BIT				= 1,
    @v255UpdateAutoPositiontaking_1701	BIT				= 1,
    @v255UpdateCommission_1701			BIT				= 1,
    
    @updateallmembers					BIT				= 0,
    @newspositiontaking					SMALLMONEY		= 0,
    
    @SubAccID							INT				= 0,
    @userid								INT,
    @IP									VARCHAR(50)		= '',
    @Language							VARCHAR(20)		= 'E',        
    @ErrCode							VARCHAR(300)	= '' OUTPUT,
    @ErrMsg								NVARCHAR(4000)	= '' OUTPUT
    

AS
    /*
        Created: Kathy
        Date: 20150424
        DB: DBTXN/custdb
        Task: Super edits live casino settings on master
        
        Revisions:
           
        Parameters Explanation:
    */
BEGIN
	SET NOCOUNT ON

	DECLARE @roleid				TINYINT
			,@SyncLiveCasino	BIT
			,@ErrCode_Cur		INT
			,@ErrMsg_Cur		NVARCHAR(4000)
			,@ErrAcc			NVARCHAR(4000)
			
	SELECT	@ErrCode_Cur	= 0
			,@ErrMsg_Cur	= ''
			,@ErrCode		= ''
			,@ErrMsg		= ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid, 
		@Custid			= @custid,
		@roleid			= @roleid OUTPUT
		
		IF (@roleid = 0) RETURN
	---------------------------

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode_Cur	OUTPUT
		,@ErrMsg	= @ErrMsg_Cur	OUTPUT
		
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
				
		RETURN
	END

	IF @v255UpdateCommission_1701 = 1
	BEGIN
		EXEC Acc_CustomerUpdMasterGoldDeluxe_Commission
			@custid				= @custid, 
			@v255discount_1701	= @v255discount_1701, 
			@SubAccID           = @SubAccID, 
			@IP                 = @IP, 
			@UserID             = @UserID, 
			@Language           = @Language, 
			@ErrCode            = @ErrCode_Cur	OUTPUT, 
			@ErrMsg             = @ErrMsg_Cur	OUTPUT
	    
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN    
		END
		ELSE
			SELECT	@ErrCode = @ErrCode + '-101' + CHAR(7)
					,@ErrMsg = @ErrMsg + CHAR(7)        
	END

	-- check n3<= m3
	IF @v255mpositiontaking_1701 < @v255mpositiontaking_1701_min
	BEGIN
		SELECT	@ErrMsg_Cur = CASE @Language 
								WHEN 'E' THEN 'Wrong position taking .<br>'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
							 END 
							 ,@ErrCode_Cur = 100
	    
		SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	            
		RETURN    
	END

	IF @v255UpdateMinPositiontaking_1701 = 1
	BEGIN
		EXEC Acc_CustOverrideUpdGoldDeluxe
			@custid							= @custid
			,@UplineID						= @srecommend 
			,@min_v255positiontaking_1701	= @v255mpositiontaking_1701_min
			,@SubAccID						= @SubAccID
			,@IP							= @IP
			,@UserID						= @UserID 
			,@Language						= @Language
			,@ErrCode						= @ErrCode_Cur OUTPUT
			,@ErrMsg						= @ErrMsg_Cur OUTPUT
	    
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT	@ErrCode	= @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
					,@ErrMsg	= @ErrMsg + @ErrMsg_Cur + CHAR(7)
			
			RETURN    
		END
		ELSE
			SELECT	@ErrCode = @ErrCode + '-102' + CHAR(7)
					,@ErrMsg = @ErrMsg + CHAR(7)        
	END

	IF @v255UpdatePositiontaking_1701 = 1 OR @v255UpdateAutoPositiontaking_1701 = 1
	BEGIN
		EXEC Acc_CustomerUpdMasterGoldDeluxe_Positiontaking 
			@custid								= @custid	        
			,@v255spositiontaking_1701			= @v255spositiontaking_1701
			,@v255mpositiontaking_1701			= @v255mpositiontaking_1701
			,@isauto_v255spositiontaking_1701	= @isauto_v255spositiontaking_1701
			,@auto_v255spositiontaking_1701		= @auto_v255spositiontaking_1701
			,@v255UpdatePositiontaking_1701		= @v255UpdatePositiontaking_1701 
			,@v255UpdateAutoPositiontaking_1701 = @v255UpdateAutoPositiontaking_1701 
			,@updateallmembers					= @updateallmembers
			,@newspositiontaking                = @newspositiontaking
	        ,@SubAccID							= @SubAccID 
			,@IP								= @IP
			,@UserID							= @UserID 
			,@Language							= @Language
			,@ErrCode							= @ErrCode_Cur	OUTPUT
			,@ErrMsg							= @ErrMsg_Cur	OUTPUT
	    
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
					,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
					
			RETURN    
		END
		ELSE
			SELECT	@ErrCode = @ErrCode + '-103' + CHAR(7)
					,@ErrMsg = @ErrMsg + CHAR(7)        

	END

END





GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_All] TO [vnteam] AS [dbo]