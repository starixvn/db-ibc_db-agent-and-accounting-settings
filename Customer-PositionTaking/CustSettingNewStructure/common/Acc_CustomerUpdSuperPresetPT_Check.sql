SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdSuperPresetPT_Check]
	@PositionTaking_XML VARCHAR(MAX),
	@CustID INT,

	@Language varchar(2) = 'E',
	@ErrCode  VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg     NVARCHAR(4000) = '' OUTPUT
AS
	/*
	Created: 20141111@Dominic
	Task : Update Customer's Bet Limits
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @PositionTaking_XML:
		<ROOT>
				<PositionTaking 
						SportType="1" 
						BetType="1" 
						IsLive="1" 
						SuperPT="90" 
						MasterPT="90" 
						AgentPT="90" 
						IsautomPT="0" 
						AutomPT="0"  
						IsautosPT="0" 
						AutosPT="0"
						MinPT="0"
						MaxPT="90"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON
	
	-- ***Check Downline Belonging***
	declare @roleid tinyint, @ErrCode_Cur int, @ErrMsg_Cur nvarchar(4000)
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	EXEC  DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@Username = @Username OUTPUT,
		@roleid = @roleid OUTPUT
		if (@roleid = 0) return

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END

	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PositionTaking_XML
	
	SELECT *
	INTO #newPTTbl
	FROM OPENXML (@iDoc, '/ROOT/PositionTaking',1) 
	WITH(SportType smallint, BetType smallint, IsLive BIT, SuperPT tinyint, MasterPT tinyint,AgentPT tinyint,
		IsautomPT BIT, AutomPT TINYINT,IsautosPT BIT,AutosPT TINYINT,MinPT TINYINT,MaxPT TINYINT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	Declare @ErrAcc nvarchar(4000)
    declare @ErrType varchar(1000)
    
	--Data must be in range
	--s4 >= m4
	--m4 >= a4
	IF EXISTS(
		SELECT TOP 1 1
		FROM dbo.ProductSettingDetail pdtl
		JOIN #newPTTbl tmp ON tmp.sporttype=pdtl.sporttype
							AND tmp.bettype=pdtl.bettype
							AND tmp.islive=pdtl.islive
		WHERE pdtl.SettingType=1
		AND 
		(
			tmp.SuperPT<0 OR tmp.MasterPT <0 OR tmp.AgentPT<0
			OR
			tmp.SuperPT>pdtl.MaxPT OR tmp.MasterPT >pdtl.MaxPT OR tmp.AgentPT>pdtl.MaxPT
			OR
			tmp.SuperPT < tmp.MasterPT 
			OR
			tmp.MasterPT < tmp.AgentPT
		)
		
	)
	BEGIN
        
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end, @ErrCode = 101
        return
    END
	
	--s4 > n4
	select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + 
			CASE WHEN pts.islive=0 THEN '-Min: '+ cast((pts.minPT) as varchar(10))
         ELSE  '-MinLive: '+ cast((pts.minPT) as varchar(10))end + '<br>'
    FROM dbo.CustPTSetting3rd_Agent pts
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on pts.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on pts.bettype = bt.typeid
	WHERE pts.custid=@CustID
	AND tmp.SuperPT < pts.minPT
	
	if @ErrType <>''
	BEGIN
		Select @ErrMsg =     case @Language 
							when 'E' then 'Wrong position taking (min set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
					end, @ErrCode = 102
		return
	END
	
	
	--is3=0 ? s3+m3<=s4 : m3<=s4 && us3<=s4
	select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from custinfo as c with (NOLOCK) 
    inner join dbo.CustPTSetting3rd_Agent ptm with (NOLOCK) on c.custid = ptm.custid	
	AND c.srecommend = @custid and c.roleid = 3
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
	WHERE
	((ptm.isautosPT=0) and (ptm.superPT+ptm.masterPT>tmp.superPT))
	OR
	((ptm.isautosPT=1) and (ptm.masterPT>tmp.superPT))
	OR
	((ptm.isautosPT=1) and (ptm.autosPT>tmp.superPT))
    GROUP BY username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode = 103
        return
    END
    
    
    -- s1+m1+a1<=s4
    -- if is1=1 then us1<=s4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
    FROM custinfo c WITH(NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Member ptmem WITH(NOLOCK) ON c.custid = ptmem.custid
															AND  c.srecommend = @custid
															AND c.roleid     = 1
															AND c.Enabled    = 1
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=ptmem.sporttype
							AND tmp.bettype=ptmem.bettype
							AND tmp.islive=ptmem.islive
	WHERE
	(ptmem.superPT + ptmem.masterPT + ptmem.agentPT > tmp.superPT)
	OR
	(ptmem.isautosPT = 1 AND ptmem.autosPT > tmp.superPT)
	 GROUP BY username
	IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg =
                  CASE @Language
                   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 104
        RETURN
    END
	
	
	--m3<=m4
	select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join dbo.CustPTSetting3rd_Agent ptm with (NOLOCK) on c.custid = ptm.custid
																	AND c.srecommend = @custid
																	and c.roleid = 3
     WHERE
		(ptm.masterPT>tmp.masterPT)    
	 group by username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg =     @UserName + ': '+
            case @Language 
                            when 'E' then 'Existing masters exceeded new master position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20015,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode = 108
        return
    END
        
	
	-- m1+a1<=m4
	SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Member ptmem WITH(NOLOCK) ON c.custid = ptmem.custid
															AND  c.srecommend = @custid
															AND c.roleid     = 1
															AND c.Enabled    = 1
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=ptmem.sporttype
							AND tmp.bettype=ptmem.bettype
							AND tmp.islive=ptmem.islive
	WHERE
	ptmem.masterPT + ptmem.agentPT > tmp.masterPT
	GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @UserName
                       + ': ' + CASE @Language 
                                  WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                                  ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                                END
             , @ErrCode = 108
        RETURN
    END
	
	--a2<=a4
	select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
	inner join dbo.CustPTSetting3rd_Agent pta with (NOLOCK) on c.custid = pta.custid	
	AND c.srecommend = @custid and c.roleid = 2 AND c.Enabled    = 1
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=pta.sporttype
							AND tmp.bettype=pta.bettype
							AND tmp.islive=pta.islive
	WHERE pta.agentPT > tmp.agentPT
	group by username
	if @ErrAcc <> ''
    BEGIN
        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20016, @Language) + ' (' + @ErrAcc + ').'
                         end
             , @ErrCode = 109
        return
    END
	
	--a1<=a4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
    INNER JOIN dbo.CustPTSetting3rd_Member ptmem WITH(NOLOCK) ON c.custid = ptmem.custid
															AND  c.srecommend = @custid
															AND c.roleid     = 1
															AND c.Enabled    = 1
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=ptmem.sporttype
							AND tmp.bettype=ptmem.bettype
							AND tmp.islive=ptmem.islive  
    WHERE ptmem.agentPT > tmp.agentPT  
     GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @UserName + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 109
        RETURN
    END
     
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
END