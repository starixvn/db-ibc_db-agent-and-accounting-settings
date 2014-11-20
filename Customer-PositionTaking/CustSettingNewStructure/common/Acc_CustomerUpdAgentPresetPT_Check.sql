SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdAgentPresetPT_Check]
	@PositionTaking_XML VARCHAR(MAX),
	@CustID INT,
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
    
	--a2,m2,um2>=0
	--m2<=Default Max PT
	--m2+a2<=Default Max PT
	IF EXISTS(
		SELECT TOP 1 1
		FROM dbo.ProductSettingDetail pdtl		
		JOIN #newPTTbl tmp ON tmp.sporttype=pdtl.sporttype
							AND tmp.bettype=pdtl.bettype
							AND tmp.islive=pdtl.islive
		WHERE pdtl.SettingType=1
		AND 
		(
			tmp.MasterPT<0 OR tmp.AgentPT <0 OR tmp.AutomPT<0
			OR
			tmp.MasterPT > pdtl.MaxPT
			OR
			tmp.MasterPT+tmp.AgentPT > pdtl.MaxPT
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
	
	--im2=0 ? n3<=m2+a2<=l3 : a2<=l3 and um2+a2>=n3
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN ptm.isLive=0 THEN '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	ELSE  '-MinLive: '+ cast((co.minpositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxpositiontaking) as varchar(10))
	end + '<br>'
    FROM dbo.CustPTSetting3rd_Agent ptm
	JOIN #newPTTbl tmp ON tmp.sporttype=ptm.sporttype
							AND tmp.bettype=ptm.bettype
							AND tmp.islive=ptm.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on ptm.sporttype = s.sporttype
    INNER JOIN bodb02.dbo.bettype bt with (nolock) on ptm.bettype = bt.typeid
	WHERE ptm.custid=@MasterID
	AND
	(
		((tmp.IsAutomPT=0) and (tmp.MasterPT+tmp.AgentPT>ptm.MaxPT or tmp.MasterPT+tmp.AgentPT<ptm.MinPT)) 
		OR 
		(tmp.IsAutomPT=1 and (tmp.AgentPT>ptm.maxPT or tmp.AgentPT + tmp.AutomPT<ptm.MinPT))
	)
	
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pta.IsLive=0 THEN '-Min: '+ cast((pta.MinPT) as varchar(10))+ '-Max: '+ cast((pta.MaxPT) as varchar(10))
	ELSE '-MinLive: '+ cast((pta.MinPT) as varchar(10))+ '-MaxLive: '+ cast((pta.MaxPT) as varchar(10)) end + '<br>'
	FROM dbo.CustPTSetting3rd_Agent pta
	JOIN #newPTTbl tmp ON tmp.sporttype=pta.sporttype
							AND tmp.bettype=pta.bettype
							AND tmp.islive=pta.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	where pta.custid = @CustID 
	AND
	(
		(tmp.AgentPT>pta.MaxPT or tmp.AgentPT<pta.MinPT)
	) 	
	IF @ErrType <>''
	BEGIN
		select @ErrCode = 7
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END 	
	
	--a2<=a4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pts.isLive=0 THEN '-Max: '+ cast((pts.AgentPT) as varchar(10))
	ELSE '-Max: '+ cast((pts.AgentPT) as varchar(10)) end + '<br>'
	FROM dbo.CustPTSetting3rd_Agent pts
	JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	WHERE pts.CustID=@SuperID
	AND tmp.AgentPT>pts.AgentPT
	if @ErrType <>''
	BEGIN
		select @ErrCode = 11
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--m2+a2<=min(m3,m4)
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pts.isLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END+ cast((CASE WHEN pts.MasterPT < ptm.MasterPT THEN pts.MasterPT ELSE ptm.MasterPT END) as varchar(10))
	+ '<br>'
	FROM dbo.CustPTSetting3rd_Agent pts
	JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.sporttype=pts.sporttype
							AND ptm.bettype=pts.bettype
							AND ptm.islive=pts.islive
							AND ptm.CustID=@MasterID
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	WHERE pts.CustID=@SuperID
	AND (tmp.AgentPT+tmp.MasterPT>CASE WHEN pts.MasterPT < ptm.MasterPT THEN pts.MasterPT ELSE ptm.MasterPT END) 	
	
	--if im2=1 then um2<=min(m3,m4,l3)
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + 
	CASE WHEN pts.isLive=0 THEN '-Max: ' ELSE '-MaxLive: ' END+ cast((
		case	
					WHEN ptm.masterPT <= ptm.maxPT AND ptm.masterPT <= pts.masterPT THEN prm.masterPT
					WHEN ptm.maxPT <= ptm.masterPT AND ptm.maxPT <= pts.masterPT THEN ptm.maxPT
					ELSE pts.masterPT
				end
	) as varchar(10))
	+ '<br>'
	FROM dbo.CustPTSetting3rd_Agent pts
	JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.sporttype=pts.sporttype
							AND ptm.bettype=pts.bettype
							AND ptm.islive=pts.islive
							AND ptm.CustID=@MasterID
	INNER JOIN #newPTTbl tmp ON tmp.sporttype=pts.sporttype
							AND tmp.bettype=pts.bettype
							AND tmp.islive=pts.islive
	INNER JOIN bodb02.dbo.sports s with (nolock) on b.sporttype = s.sporttype
	INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid
	WHERE pts.CustID=@SuperID
	AND
	(
		tmp.IsAutomPT = 1 
		AND 
		tmp.AutomPT > 
				case	
					WHEN ptm.masterPT <= ptm.maxPT AND ptm.masterPT <= pts.masterPT THEN prm.masterPT
					WHEN ptm.maxPT <= ptm.masterPT AND ptm.maxPT <= pts.masterPT THEN ptm.maxPT
					ELSE pts.masterPT
				end
	)
	 
	 
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
END