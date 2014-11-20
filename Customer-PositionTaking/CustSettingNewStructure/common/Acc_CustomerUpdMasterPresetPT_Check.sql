SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdMasterPresetPT_Check]
	@PositionTaking_XML VARCHAR(MAX),
	@CustID INT,
	@SuperID INT,

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
    
	--s3,m3,us3 > 0
	--s3+m3 <= Default Max PT
	--us3 <= Default Max PT
	IF EXISTS(
		SELECT TOP 1 1
		FROM ddbo.ProductSettingDetail pdtl		
		JOIN #newPTTbl tmp ON tmp.sporttype=pdtl.sporttype
							AND tmp.bettype=pdtl.bettype
							AND tmp.islive=pdtl.islive
		WHERE pdtl.SettingType=1
		AND 
		(
			tmp.SuperPT<0 OR tmp.MasterPT <0 OR tmp.AutosPT<0
			OR
			tmp.SuperPT + tmp.MasterPT > pdtl.MaxPT
			OR
			tmp.AutosPT > pdtl.MaxPT
		)
		
	)
	BEGIN
        SELECT @ErrCode = 5

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Wrong position taking (for Soccer).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
                 END
        RETURN
    END
	
	
	--is3=0 ? n4<s3+m3<=l4 : m3<=l4 && us3+m3>=n4
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
	WHERE pts.custid=@SuperID
	AND
	(tmp.IsautosPT = 0
             AND (tmp.SuperPT + tmp.MasterPT > pts.maxPT
                  OR tmp.SuperPT + tmp.MasterPT < pts.minPT
                 )
            )
            OR (tmp.IsautosPT = 1
                AND (tmp.MasterPT > pts.maxPT
                     OR tmp.MasterPT + tmp.AutosPT < pts.minPT
                    )
               )
	
	if @ErrType <> ''
    BEGIN
        SELECT @ErrCode = 6

        SELECT @ErrMsg = CASE @Language 
                           WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                          END
        RETURN
    END
	
	
	--n3<=m3<=l3
	SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + sportname + '-' + typenamee + 
			CASE WHEN tmp.IsLive=0 THEN '-Min: '
                    + CAST((ptm.minPT) AS VARCHAR(10)) + '-Max: '
                    + CAST((ptm.maxPT) AS VARCHAR(10))
                    ELSE '-MinLive: '
                    + CAST((ptm.minPT) AS VARCHAR(10)) + '-MaxLive: '
                    + CAST((ptm.maxPT) AS VARCHAR(10))
                      END + '<br>'
	FROM dbo.CustPTSetting3rd_Agent ptm
	JOIN #newPTTbl tmp ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on ptm.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on ptm.bettype = bt.typeid
	WHERE ptm.custid=@CustID
	AND(
		tmp.MasterPT > ptm.maxPT
            or tmp.MasterPT < ptm.minPT
	)
	
	
	--a2+m2<=m3
	select @ErrAcc = ''
	select top 100 @ErrAcc = @ErrAcc + username + ', '
    from custinfo c with (NOLOCK)
	INNER JOIN dbo.CustPTSetting3rd_Agent pta with (NOLOCK) on c.custid = pta.custid
						AND c.mrecommend = @custid
						AND c.Enabled    = 1
						and c.roleid     = 2
	JOIN #newPTTbl tmp ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
	WHERE pta.agentPT + pta.masterPT > ptm.masterPT
	group by username
	
	if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 8

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                           end
        return
    END


	--a1+m1<=m3
	SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
    FROM custinfo c WITH(NOLOCK) 
	INNER JOIN dbo.CustPTSetting3rd_Member ptmem with (NOLOCK) on c.custid = ptmem.custid
						AND c.mrecommend = @custid
						AND c.Enabled    = 1
						and c.roleid     = 1
	JOIN #newPTTbl tmp ON tmp.sporttype=ptmem.sporttype
							AND tmp.bettype=ptmem.bettype
							AND tmp.islive=ptmem.islive
	WHERE ptmem.agentPT + ptmem.masterPT > tmp.MasterPT
	GROUP BY username
	
	IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 9

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                  END
        RETURN
    END
	
	--m3<=m4
	select @ErrType = ''

    select TOP 100 @ErrType = @ErrType + sportname + '-' + typenamee + 
				CASE WHEN tmp.IsLive=0 THEN '-Max: '
                    + cast((pts.masterPT) as varchar(10))
                    ELSE '-MaxLive: '
                    + cast((pts.masterPT) as varchar(10))
                      END + '<br>'
    FROM dbo.CustPTSetting3rd_Agent pts
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with(nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with(nolock) on b.bettype = bt.typeid
	WHERE pts.custid=@SuperID
	AND pts.masterPT < tmp.MasterPT
	
	if @ErrType <>''
    BEGIN
        select @ErrCode = 10
        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                         end
        return
    END
	
	
	-- if im2=1 then m3>=um2
	select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username + ', '
    from custinfo c with(NOLOCK)
	INNER JOIN dbo.CustPTSetting3rd_Agent ptm with (NOLOCK) on c.custid = ptm.custid
						AND c.mrecommend = @custid
						AND c.Enabled    = 1
						and c.roleid     = 2
	JOIN #newPTTbl tmp ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
	WHERE 
	(ptm.automPT > tmp.MasterPT
             and ptm.isautomPT = 1
            )
	group by username
	
	 if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                         end
        return
    END
	
	--us3<=s4
	select @ErrType = ''
    select TOP 100 @ErrType = @ErrType + sportname + '-'+ typenamee + 
		CASE WHEN pts.isLive=0 THEN '-Max: '+ cast((pts.superPT) as varchar(10))
		ELSE '-MaxLive: '+ cast((pts.superPT) as varchar(10)) end + '<br>'
    FROM dbo.CustPTSetting3rd_Agent pts with (NOLOCK)
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	WHERE pts.custID=@SuperID
	AND (pts.superPT<tmp.AutosPT)
	if @ErrType <>''    
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end    , @ErrCode = 101
        return
    END
    
    
    --s3<=s4, s3+m3<=s4
	select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + 
		CASE WHEN pts.isLive=0 THEN '-Max: '+ cast((pts.superPT) as varchar(10))
		ELSE '-MaxLive: '+ cast((pts.superPT) as varchar(10)) end + '<br>'
	FROM dbo.CustPTSetting3rd_Agent pts with (NOLOCK)
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
    WHERE pts.custID=@SuperID
	AND (
		(pts.superPT<tmp.SuperPT)
		OR
		(pts.superPT<tmp.SuperPT+tmp.MasterPT)
	)
	if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end    , @ErrCode = 102
        return
    END
	
	
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
END