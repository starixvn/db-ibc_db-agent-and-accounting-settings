 ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTUpd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	@updateallmembers	BIT = 0,
	@newMasterPT		SMALLINT = 0,	
	
	@SubAccID			INT = 0,
	@UserID				INT = 0,    
    @Language			VARCHAR(2) = 'E',
    @IP					VARCHAR(15)='',
    @ErrCode			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2014-12-09
		Task: Update pt on Agent
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" AgentMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" AgentMinPT="0"/>
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
			,@AutoPT		VARCHAR(MAX)
			,@sports		VARCHAR(500)	
			,@UpdateMinPT	BIT
			,@UpdatePresetPT BIT		
			,@xml			XML
	  SET @startRun = GETDATE()
			
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
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
		RETURN
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 2
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
    
    DECLARE @username VARCHAR(40), @srecommend INT, @mrecommend INT
    
    SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend         
	FROM custinfo with (NOLOCK)         
	WHERE CustID = @CustID 
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLINT,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLINT,
				AgentPT			SMALLINT,				
				AgentMinPT		SMALLINT
				)	
				
	-- For read xml
	DECLARE @DocHandler INT    
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @PT
	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				MasterPT,
				IsAutoMasterPT,
				AutoMasterPT,
				AgentPT,								
				AgentMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.MasterPT,
		Data.isAutoMasterPT,
		Data.AutoMasterPT,	
		Data.AgentPT,			
		Data.AgentMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType		SMALLINT,
		BetType			SMALLINT,
		IsLive			BIT,
		MasterPT		SMALLINT,
		IsAutoMasterPT	BIT,
		AutoMasterPT	SMALLINT,
		AgentPT			SMALLINT,			
		AgentMinPT		SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	 --log old data
	SET @xml =(
		SELECT @custid AS '@ci'
				,f_GetSubUsername(@SubAccID) AS '@su'
				,@userid AS '@ui'
				,@language AS '@l'
				,@IP AS '@Ip'
				,@updateallmembers AS '@ua'
				,@newMasterPT AS '@m1'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.MasterPT AS '@m2'
						,cs.isAutoMasterPT AS '@im2'
						,cs.AutoMasaterPT AS '@um2'	
						,cs.AgentPT AS '@a2'										
						,cs.MinPT AS '@n2'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('pt'), TYPE
				)
		FOR XML PATH('r'), TYPE
	)
	SET @AutoPT =(
		SELECT cs.sporttype AS '@SportType'
			,cs.bettype AS '@BetType'
			,cs.isLive AS '@IsLive'						
			,t.isAutoMasterPT AS '@IsAutoMasterPT'
			,cs.isAutoMasterPT AS '@IsAutoMasterPTOld'
			,t.AutoMasterPT AS '@AutoMasterPT'			
			,CASE WHEN t.IsAutoMasterPT = cs.IsAutoMasterPT AND t.AutoMasterPT = cs.AutoMasterPT THEN 0 ELSE 1 END AS '@IsUpdateAutoPT'			
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
		WHERE custid = @custid
		FOR XML PATH('PT'), ROOT('ROOT')
	 )
	 
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)    
    	    
    SELECT @sports = ''
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
		AND (cs.MasterPT <> t.MasterPT
			OR cs.IsAutoMasterPT <> t.IsAutoMasterPT
			OR cs.AutoMasterPT <> t.AutoMasterPT
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
		AND cs.MinPT <> t.AgentMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	EXEC Acc_CustSetting_AgentPTCheck
		@custid		= @custid,
		@username	= @username,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		
		@PT			= @PT,
		@UpdateMinPT = @UpdateMinPT,
		@UpdatePresetPT = @UpdatePresetPT,
		
		@Language	= @Language,	
		@ErrCode	= @ErrCode OUTPUT,
		@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN
	
	 --update data change into db
	 UPDATE cs
	SET cs.MasterPT = b.MasterPT
		,cs.IsAutoMasterPT = b.IsAutoMasterPT
		,cs.AutoMasterPT = b.AutoMasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.AgentMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.MasterPT <> b.MasterPT
			OR cs.isAutoMasterPT <> b.isAutoMasterPT
			OR cs.AutoMasterPT <> b.AutoMasterPT			
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.AgentMinPT					
		)
	
	IF @UpdateMinPT = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_04 
			@recommend = @custid
			,@mrecommend = @mrecommend
			,@srecommend = @srecommend
			,@mode = 'Others'
			,@roleid = 2
			,@sports = @sports

		-- The minimum position taking value of agent was modified by agent's upline
		EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID 
	END
	
	IF @UpdatePresetPT = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_05
            ,@mrecommend = @mrecommend
			,@recommend = @custid
			,@roleid = 2
			,@mode = 'Others'
            
            ,@PT = @AutoPT
                                        
            ,@updateallmembers = @updateallmembers
            ,@newmpositiontaking = @newMasterPT
            
       EXEC dbo.Acc_CustSetting3rd_07 
			@recommend = @custid
			,@roleid = 2
			,@mode = 'Others'
			,@sports = @sports
	END	
	
	 -- Write log after update
	SET @xml = (
			SELECT @custid AS '@ci'
				,f_GetSubUsername(@SubAccID) AS '@su'
				,@userid AS '@ui'
				,@language AS '@l'
				,@IP AS '@Ip'
				,@updateallmembers AS '@ua'
				,@newMasterPT AS '@m1'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.MasterPT AS '@m2'
						,cs.isAutoMasterPT AS '@im2'
						,cs.AutoMasaterPT AS '@um2'	
						,cs.AgentPT AS '@a2'										
						,cs.MinPT AS '@n2'
					FROM @tblPT cs	
					)
			FOR XML PATH('r'),TYPE				
	)
	
	SET @logSPData = CONVERT(VARCHAR(MAX), @xml)	
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	BEGIN TRY
		DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 450,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 450,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 
    
    
				
END
 GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbExtAccNet]
GO 	