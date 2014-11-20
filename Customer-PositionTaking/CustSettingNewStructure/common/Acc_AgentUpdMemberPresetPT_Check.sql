SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_AgentUpdMemberPresetPT_Check]
	@PositionTaking_XML VARCHAR(MAX),
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
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

	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
	@roleid=2,
	@isExecRep=1,
	@isUpdatePT = 1,
	@Sporttype = 1,
	@Language='E',
	@ErrMsg=@ErrMsg output,
	@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 



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
    
	--a1=[0; Default Max PT]
	IF EXISTS(
		SELECT TOP 1 1
		FROM dbo.ProductSettingDetail pdtl		
		JOIN #newPTTbl tmp ON tmp.sporttype=pdtl.sporttype
							AND tmp.bettype=pdtl.bettype
							AND tmp.islive=pdtl.islive
		WHERE pdtl.SettingType=1
		AND 
		(
			tmp.AgentPT <0 OR tmp.AgentPT > pdtl.MaxPT
		)
		
	)
	BEGIN
        select @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Soccer).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
					end
		return
    END
	
	--n2<=a1<=l2
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pta.isLive=0 THEN '-Min: ' ELSE '--MinLive: ' END+ cast((pta.minPT) as varchar(10))+ 
	CASE WHEN pta.isLive=1 THEN '-Max: ' ELSE '--MaxLive: ' END+ cast((pta.maxPT) as varchar(10))
	+ '<br>'
    FROM dbo.CustPTSetting3rd_Agent pta
	JOIN #newPTTbl tmp ON tmp.sporttype=pta.sporttype
							AND tmp.bettype=pta.bettype
							AND tmp.islive=pta.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on pta.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on pta.bettype = bt.typeid
	WHERE pta.custid=@AgentID
	AND
		( (tmp.AgentPT>pta.maxPT or tmp.AgentPT<pta.minPT))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 6
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--a1<=a4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pts.isLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END + cast((pts.agentPT) as varchar(10))
	+ '<br>'
	FROM dbo.CustPTSetting3rd_Agent pts
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on pts.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on pts.bettype = bt.typeid
	WHERE pts.custid=@SuperID
	AND tmp.AgentPT>pts.agentPT
	if @ErrType <>''
	BEGIN
		select @ErrCode = 7
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--a1 <= min(a4,a2,l2, im2=1|im1=1 ? a2 : is1=1|is3=1 ? m3-m1 : min(m3-m1, s4-s1-m1))
	INSERT INTO #a1_max_Tbl
	SELECT tmp.SportType,tmp.BetType,tmp.IsLive,
	CASE WHEN (pta.isautomPT = 1 or tmp.IsAutomPT = 1) 
				THEN pta.agentPT 
		 ELSE 
				CASE WHEN (tmp.isautosPT=1 OR ptm.isautosPT=1 ) 
							THEN ptm.masterPT-tmp.masterPT 
					 ELSE 
							CASE WHEN ptm.masterPT-tmp.masterPT<=pts.superPT-tmp.superPT-tmp.masterPT 
									THEN  ptm.masterPT-tmp.masterPT 
								 ELSE pts.superPT-tmp.superPT-tmp.masterPT 
							END 
					 END 
	END MaxA1_1,
	CASE WHEN pts.agentPT <= pta.agentPT AND pts.agentPT <= pta.maxPT THEN pts.agentPT
		ELSE CASE WHEN pta.agentPT <= pts.agentPT AND pta.agentPT <= pta.maxPT THEN pta.agentPT
		ELSE pta.maxPT END
	END MaxA1_2	
	FROM #newPTTbl tmp 
	INNER JOIN dbo.CustPTSetting3rd_Agent pts ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
							AND pts.CustID=@SuperID
	INNER JOIN dbo.CustPTSetting3rd_Agent ptm ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
							AND ptm.CustID=@MasterID
	INNER JOIN dbo.CustPTSetting3rd_Agent pta ON tmp.sporttype=pta.sporttype
							AND tmp.bettype=pta.bettype
							AND tmp.islive=pta.islive
							AND pta.CustID=@AgentID
	
	
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN tmp.IsLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END + cast((CASE WHEN max_a1.MaxA1_1 < max_a1.MaxA1_2 THEN max_a1.MaxA1_1 ELSE max_a1.MaxA1_2) as varchar(10))
	+ '<br>'
	FROM #newPTTbl tmp 
	INNER JOIN #a1_max_Tbl max_a1 ON tmp.sporttype=max_a1.sporttype
							AND tmp.bettype=max_a1.bettype
							AND tmp.islive=max_a1.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	WHERE tmp.agentPT > CASE WHEN max_a1.MaxA1_1 < max_a1.MaxA1_2 THEN max_a1.MaxA1_1 ELSE max_a1.MaxA1_2 END
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 100
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	
	
	
	IF OBJECT_ID('tempdb..#a1_max_Tbl') IS NOT NULL
		DROP TABLE #a1_max_Tbl
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
		
END