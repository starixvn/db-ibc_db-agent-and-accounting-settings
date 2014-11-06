SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerInsMemberPT_Execrep_00]
	@PT_XML VARCHAR(MAX),
	@CustID INT,
	@AgentID INT
AS
	/*
	Created: 20141105@Dominic
	Task : Execrep Insert PT settings of a specific member
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Member ID
	• @PT_XML: PT setting of a member
	*/
BEGIN
	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN (
				'AgentPTGroupSetting_3rd',
				'CustSettingMode_3rd',
				'CustPTSetting3rd_Member')
			AND xtype = 'U'

	if @IsExistTables <> 3  RETURN
		
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PT_XML	
	
	SELECT *
	INTO #memberPTTbl
	FROM OPENXML (@iDoc, '/ROOT/PositionTaking',1) 
	WITH(SportType smallint, BetType smallint, Islive bit, SuperPT tinyint, 
	MasterPT tinyint, AgentPT tinyint, IsAutoMPT bit,AutoMPT tinyint,IsautoSPT bit,AutoSPT tinyint)	
	
	EXEC sp_xml_removedocument @iDoc
			
	--If this is the first member,insert into Group Setting
	INSERT INTO dbo.AgentPTGroupSetting_3rd
	(	AgentID,SportType,BetType,Islive,
		SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsautoSPT,AutoSPT)
	SELECT 
		@AgentID,SportType,BetType,Islive,
		SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsautoSPT,AutoSPT
	FROM #memberPTTbl
	WHERE NOT EXISTS(SELECT TOP 1 1 FROM dbo.AgentPTGroupSetting_3rd WHERE AgentID=@AgentID)
		
	IF @@ROWCOUNT<>0
	BEGIN
		--It this is the fist member,just insert IsgroupedPT=1
		INSERT INTO dbo.CustSettingMode_3rd(CustID,AgentID,IsGroupedPT)
		SELECT @CustID,@AgentID,1
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1
				FROM dbo.AgentPTGroupSetting_3rd apt
				JOIN #memberPTTbl tmp ON tmp.SportType = apt.SportType
										AND tmp.BetType = apt.BetType
										AND tmp.Islive = apt.Islive
				WHERE apt.AgentID = @AgentID
				AND (
					tmp.SuperPT <> apt.SuperPT
					OR
					tmp.MasterPT <> apt.MasterPT
					OR
					tmp.AgentPT <> apt.AgentPT
					OR
					tmp.IsAutoMPT <> apt.IsAutoMPT
					OR
					tmp.AutoMPT <> apt.AutoMPT
					OR
					tmp.IsautoSPT <> apt.IsautoSPT
					OR
					tmp.AutoSPT <> apt.AutoSPT
				))
		BEGIN
			--If this member's PT setting are diffrent from Group PT Setting
			INSERT INTO dbo.CustPTSetting3rd_Member
			(custid,sporttype,bettype,islive,
				superPT,masterPT,agentPT,isautomPT,automPT,isautosPT,autosPT)
			SELECT 
			@CustID,SportType,BetType,Islive,
				SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsautoSPT,AutoSPT
			FROM #memberPTTbl
			
			INSERT INTO dbo.CustSettingMode_3rd(CustID,AgentID,IsGroupedPT)
			SELECT @CustID,@AgentID,0
		END
		ELSE
		BEGIN
			INSERT INTO dbo.CustSettingMode_3rd(CustID,AgentID,IsGroupedPT)
			SELECT @CustID,@AgentID,1
		END
	END
	
	DROP TABLE #memberPTTbl
END