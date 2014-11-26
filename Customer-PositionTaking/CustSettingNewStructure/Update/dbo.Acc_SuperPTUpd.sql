 ALTER PROCEDURE [dbo].[Acc_SuperPTUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,    
    @Language	VARCHAR(2) = 'E',
    @IP			VARCHAR(15)='',
    @ErrCode	VARCHAR(300) = '' OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update pt on super
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <Root>
					<PT sporttype="1" bettype="1" isLive="0" SuperPT="50" SuperMinPT="0" />
					<PT sporttype="1" bettype="1" isLive="1" SuperPT="50" SuperMinPT="0" />
				</Root>
				
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleid TINYINT
			,@ErrCode_Cur INT
			,@ErrMsg_Cur NVARCHAR(4000)
			
	SELECT @ErrCode_Cur = 0
			,@ErrMsg_Cur = ''
			,@ErrCode = ''
			,@ErrMsg = ''
	
	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode_Cur OUTPUT
		,@ErrMsg	= @ErrMsg_Cur OUTPUT
		
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 4
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
    IF    @ErrCode <> 0 
		RETURN 
    ----------
    
    IF @PT = '' RETURN 
    
	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				SuperMinPT	SMALLINT
				)	
				
	-- For read xml
	DECLARE @DocHandler INT    
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @PT
	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				SuperMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.SuperPT,
		Data.SuperMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType	SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,
		SuperPT		SMALLINT,
		SuperMinPT	SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	
END
GO
