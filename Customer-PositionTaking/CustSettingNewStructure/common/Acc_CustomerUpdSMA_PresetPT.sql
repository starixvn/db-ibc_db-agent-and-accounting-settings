SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdSMA_PresetPT]
	@CustID INT,
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
	
	IF @RoleID=4
	BEGIN
		UPDATE pt
		SET
			pt.superPT=tmp.superPT,
			pt.masterPT=tmp.masterPT,
			pt.agentPT=tmp.agentPT,
			pt.maxPT=tmp.superPT
		FROM dbo.CustPTSetting3rd_Agent pt
		JOIN #newPTTbl tmp ON tmp.sporttype=pt.sporttype
							AND tmp.bettype=pt.bettype
							AND tmp.islive=pt.islive
	END
	ELSE IF @RoleID=3
	BEGIN
		UPDATE pt
		SET
			pt.superPT=tmp.superPT,
			pt.masterPT=tmp.masterPT,
			pt.isautosPT=tmp.isautosPT,
			pt.autosPT=tmp.autosPT
		FROM dbo.CustPTSetting3rd_Agent pt
		JOIN #newPTTbl tmp ON tmp.sporttype=pt.sporttype
							AND tmp.bettype=pt.bettype
							AND tmp.islive=pt.islive
	END
	ELSE IF @RoleID=2
	BEGIN
		UPDATE pt
		SET
			pt.masterPT=tmp.masterPT,
			pt.agentPT=tmp.agentPT,
			pt.isautomPT=tmp.isautomPT,
			pt.automPT=tmp.automPT
		FROM dbo.CustPTSetting3rd_Agent pt
		JOIN #newPTTbl tmp ON tmp.sporttype=pt.sporttype
							AND tmp.bettype=pt.bettype
							AND tmp.islive=pt.islive
	END
	ELSE IF @RoleID=1
	BEGIN
		UPDATE pt
		SET
			pt.agentPT=tmp.agentPT
		FROM dbo.CustPTSetting3rd_Agent pt
		JOIN #newPTTbl tmp ON tmp.sporttype=pt.sporttype
							AND tmp.bettype=pt.bettype
							AND tmp.islive=pt.islive
	END
     
	 	
	IF OBJECT_ID('tempdb..#newPTTbl') IS NOT NULL
		DROP TABLE #newPTTbl
END