 ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,    
    @Language	VARCHAR(2) = 'E',
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update pt on super
		DB: DBTXN/CustDB
		
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
		SELECT cs.sporttype AS '@s'
			,cs.bettype AS '@b'
			,cs.isLive AS '@i'
			,cs.SuperPT AS '@s4'
			,cs.MasterPT AS '@m4'
			,cs.AgentPT AS '@a4'
			,cs.MinPT AS '@n4'
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType AND cs.bettype = t.BetType AND cs.isLive = t.IsLive
		WHERE custid = @custid
		FOR XML PATH('p'), ROOT('r')
	)
	
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)
		
    --Check Param
    DECLARE @ErrAcc NVARCHAR(4000)
			,@ErrType VARCHAR(1000)
	
	IF EXISTS(SELECT TOP 1 1 
			FROM @tblPT t
				INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype AND t.BetType = ps.bettype AND t.IsLive = ps.IsLive
		WHERE ps.SettingType = 1--PT
			AND (t.SuperPT < 0 OR t.SuperPT > ps.MaxPT
				OR t.MasterPT < 0 OR t.MasterPT > ps.MaxPT
				OR t.AgentPT < 0 OR t.AgentPT > 0
				OR t.SuperPT < t.MasterPT 
				OR t.MasterPT < t.AgentPT
			))
	 BEGIN
        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    END, @ErrCode = 101
        RETURN
    END		
	
	--check PT change or not	
	IF NOT EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType AND cs.bettype = t.BetType AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND (cs.SuperPT <> t.SuperPT
			OR cs.MasterPT <> t.MasterPT
			OR cs.AgentPT <> t.AgentPT
		)
	)
	BEGIN
		--PT no change
		RETURN
	END
	
	--check n4<=s4
	 SELECT @ErrType = ''
     
     SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + 
		CASE WHEN t.IsLive = 0 THEN '-Min: '+ CAST((t.SuperMinPT) AS VARCHAR(10))
			WHEN t.IsLive = 1 THEN '-MinLive: '+ CAST((t.SuperMinPT) AS VARCHAR(10)) ELSE '' END + '<br>'        
     FROM @tblPT t
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.SportType = s.sporttype
        INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid
	WHERE SuperPT < SuperMinPT	
	ORDER BY t.SportType, t.BetType, t.IsLive
		
	IF @ErrType <>''
    BEGIN
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking (min set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
                    END, @ErrCode = 102
        RETURN
    END
	
	--check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
	SELECT @ErrAcc = ''
    SELECT top 100 @ErrAcc = @ErrAcc + username +', '
    FROM 
        custinfo as c WITH (NOLOCK) 
        INNER JOIN CustPTSetting3rd_Agent AS cs WITH (NOLOCK) ON c.custid = cs.custid
        INNER JOIN @tblPT as b on cs.sporttype=b.sporttype AND cs.bettype = b.BetType AND cs.isLive = b.IsLive
    where c.srecommend = @custid AND c.roleid = 3 AND (
                            ((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) 
                        )
    group by username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg_Cur = @username + ': ' +
                    case @Language 
                            when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode_cur = 103
        
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return        
    END
	
END
GO
