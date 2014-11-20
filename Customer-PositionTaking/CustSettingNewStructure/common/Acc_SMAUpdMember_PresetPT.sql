SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_SMAUpdMember_PresetPT]
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@RoleID INT,
	@PositionTaking_XML VARCHAR(MAX)
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

	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PositionTaking_XML
	
	SELECT *
	INTO #newPTTbl
	FROM OPENXML (@iDoc, '/ROOT/PositionTaking',1) 
	WITH(SportType smallint, BetType smallint, IsLive BIT, SuperPT tinyint, MasterPT tinyint,AgentPT tinyint,
		IsautomPT BIT, AutomPT TINYINT,IsautosPT BIT,AutosPT TINYINT,MinPT TINYINT,MaxPT TINYINT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	UPDATE tmp
	SET
		tmp.SuperPT = ptmem.superPT,
		tmp.MasterPT = ptmem.masterPT,
		
		tmp.IsautomPT = ptmem.IsautomPT,
		tmp.AutomPT = ptmem.AutomPT,
		tmp.IsautosPT = ptmem.IsautosPT,
		tmp.AutosPT = ptmem.AutosPT
	FROM #newPTTbl tmp
	JOIN dbo.CustPTSetting3rd_Member ptmem ON ptmem.SportType=tmp.SportType
										AND ptmem.BetType=tmp.BetType
										AND ptmem.IsLive=tmp.IsLive
	WHERE ptmem.CustID=@CustID
	
	IF @RoleID=2
	BEGIN
		--a1=min(a1,m3)
		UPDATE tmp
		SET tmp.AgentPT= CASE WHEN tmp.AgentPT <  ptm.masterPT THEN  tmp.AgentPT ELSE ptm.masterPT END
		FROM #newPTTbl tmp
		JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.SportType=tmp.SportType
										AND ptm.BetType=tmp.BetType
										AND ptm.IsLive=tmp.IsLive
										AND ptm,Custid=@MasterID
										
		--a1= if(im1=0 && im2=0 && m1+a1>m3) then m3-m1
		UPDATE tmp
		SET tmp.AgentPT= CASE WHEN tmp.MasterPT + tmp.AgentPT >  ptm.masterPT THEN  ptm.masterPT - tmp.MasterPT ELSE tmp.AgentPT END
		FROM #newPTTbl tmp
		JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.SportType=tmp.SportType
										AND ptm.BetType=tmp.BetType
										AND ptm.IsLive=tmp.IsLive
										AND ptm,Custid=@MasterID
		JOIN dbo.CustPTSetting3rd_Agent pta ON pta.SportType=tmp.SportType
										AND pta.BetType=tmp.BetType
										AND pta.IsLive=tmp.IsLive
										AND pta,Custid=@AgentID
		WHERE tmp.IsAutomPT=0 AND pta.isautomPT=0
		
		--a1=Max(a1,0)
		UPDATE tmp
		SET tmp.AgentPT= CASE WHEN tmp.AgentPT >  0 THEN  tmp.AgentPT ELSE 0 END
		FROM #newPTTbl tmp
		
		--m1= (im2=1 || im1=1 ? min(im1?um1:um2,m3-a1):m1)
		UPDATE tmp
		SET tmp.MasterPT = CASE WHEN ptm.masterPT-tmp.AgentPT < 
										CASE WHEN tmp.IsAutomPT=1 THEN tmp.automPT ELSE pta.automPT END
										THEN
										ptm.masterPT-tmp.AgentPT
							ELSE
								CASE WHEN tmp.IsAutomPT=1 THEN tmp.automPT ELSE pta.automPT END
							END
		FROM #newPTTbl tmp
		JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.SportType=tmp.SportType
										AND ptm.BetType=tmp.BetType
										AND ptm.IsLive=tmp.IsLive
										AND ptm,Custid=@MasterID
		JOIN dbo.CustPTSetting3rd_Agent pta ON pta.SportType=tmp.SportType
										AND pta.BetType=tmp.BetType
										AND pta.IsLive=tmp.IsLive
										AND pta,Custid=@AgentID
		WHERE tmp.IsAutomPT=1 OR pta.isautomPT=1
		
		
		--s1= (is3=1 || is1=1 ? min(is1?us1:us3,s4-m1-a1))
		UPDATE tmp
		SET tmp.SuperPT = CASE WHEN pts.superPT -tmp.MasterPT-tmp.AgentPT < 
										CASE WHEN tmp.IsAutosPT=1 THEN tmp.autosPT ELSE ptm.autosPT END
										THEN
										pts.superPT-tmp.MasterPT-tmp.AgentPT
							ELSE
								CASE WHEN tmp.IsAutosPT=1 THEN tmp.autosPT ELSE ptm.autosPT END
							END
		FROM #newPTTbl tmp
		JOIN dbo.CustPTSetting3rd_Agent ptm ON ptm.SportType=tmp.SportType
										AND ptm.BetType=tmp.BetType
										AND ptm.IsLive=tmp.IsLive
										AND ptm,Custid=@MasterID
		JOIN dbo.CustPTSetting3rd_Agent pts ON pts.SportType=tmp.SportType
										AND pts.BetType=tmp.BetType
										AND pts.IsLive=tmp.IsLive
										AND pts,Custid=@SuperID
		WHERE tmp.IsAutosPT=1 OR ptm.isautosPT=1
		
		
		
		
	END
	
	
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
END