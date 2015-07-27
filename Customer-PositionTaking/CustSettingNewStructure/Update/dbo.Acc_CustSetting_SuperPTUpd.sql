 ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,       
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @MsgType	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update pt on super
		DB: DBCUST/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
				</ROOT>
				
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleid			TINYINT			
			,@startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT
			,@logSPData		VARCHAR(5000)
			,@logSPDataOld	VARCHAR(5000)
			,@sports		VARCHAR(500)=''
			,@xml			XML
			,@UpdateMinPT BIT
			,@UpdatePresetPT BIT
    
    SET @startRun = GETDATE()
			
	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 4
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
    IF    @ErrCode <> 0 
    BEGIN
		SELECT @MsgType = 101
		RETURN 
	END
    ----------
    
    IF @PT = '' RETURN 

    DECLARE @username VARCHAR(40)
	
	SELECT @username = username 
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	DECLARE @tmpPTGroup TABLE(custid INT)

	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				MasterPT	SMALLINT,
				AgentPT		SMALLINT,
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
				MasterPT,
				AgentPT,
				SuperMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.SuperPT,
		Data.MasterPT,
		Data.AgentPT,
		Data.SuperMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType	SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,
		SuperPT		SMALLINT,
		MasterPT	SMALLINT,
		AgentPT		SMALLINT,
		SuperMinPT	SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	--log old data
	SET @xml =(
		SELECT @custid AS '@custid'
				,@userid AS '@userid'				
				,@IP AS '@Ip'
				,(
					SELECT cs.sporttype 
						,cs.bettype 
						,cs.isLive 
						,cs.SuperPT 
						,cs.MasterPT 
						,cs.AgentPT 
						,cs.MinPT
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('pt'), TYPE
				)
		FOR XML PATH('r'), TYPE
	)
	
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)
	
	SELECT @sports = @sports + CAST(sporttype AS VARCHAR(5)) + ','
	FROM @tblPT
	
	--check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND (cs.SuperPT <> t.SuperPT
			OR cs.MasterPT <> t.MasterPT
			OR cs.AgentPT <> t.AgentPT			
		)
	)
	BEGIN
		SELECT @UpdatePresetPT = 1
	END
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND cs.MinPT <> t.SuperMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	EXEC Acc_CustSetting_SuperPTCheck 
			@custid		= @custid,
			@username	= @username,
			@PT			= @PT,	
			@UpdatePresetPT = @UpdatePresetPT,	
			@MsgType	= @MsgType OUTPUT,		
			@ErrCode	= @ErrCode OUTPUT,
			@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN		
	
	--Update data change
	UPDATE cs
	SET cs.SuperPT = b.SuperPT
		,cs.MasterPT = b.MasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.SuperMinPT
		,cs.MaxPT = b.SuperPT	
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.SuperPT <> b.SuperPT
			OR cs.MasterPT <> b.MasterPT
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.SuperMinPT					
		)
	
	IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg = '<Root MsgID="90001" Msg="Update process is unsuccessful !" />'
                        , @ErrCode = 109                    
						, @MsgType = 100--just return msgID
        RETURN
    END
    
    IF @UpdatePresetPT = 1
    BEGIN
		EXEC dbo.Acc_CustSetting3rd_07 
			@srecommend = @custid
			,@roleid = 4
			,@mode = 'Others'
			,@sports = @sports 
		
		EXEC dbo.Acc_CustSetting3rd_01 
			@srecommend = @custid
			,@mode = 'Others'
			,@sports = @sports 
    END
    
    IF @UpdateMinPT = 1
    BEGIN
		EXEC dbo.Acc_CustSetting3rd_04 
			@srecommend = @custid
			,@roleid = 4
			,@mode = 'Others'
			,@sports = @sports 
    END
    
    -- Write log after update
	SET @xml = (
			SELECT @custid AS '@custid'
					,@userid AS '@userid'					
					,@IP AS '@Ip'
					,(
						SELECT cs.sporttype 
							,cs.bettype
							,cs.isLive
							,cs.SuperPT
							,cs.MasterPT 
							,cs.AgentPT 
							,cs.SuperMinPT					
						FROM @tblPT	cs							
						FOR XML PATH('pt'), Type
					)
			FOR XML PATH('r'),TYPE				
	)
	
	SET @logSPData = CONVERT(VARCHAR(MAX), @xml)	
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 
 
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbExtAccNet]
GO 