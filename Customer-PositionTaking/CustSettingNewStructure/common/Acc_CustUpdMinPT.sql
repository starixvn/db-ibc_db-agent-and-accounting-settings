SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustUpdMinPT]
	@CustID INT,
	@RoleID INT,
	@MasterID INT,
	@SuperID INT,
	@PT_XML VARCHAR(MAX),
	
	@language varchar(2) = 'E',
    @UserID int = 0,
    @SubAccID int = 0,
    @WriteLog bit = 1,
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
	/*
	Created: 20141110@Dominic
	Task : Update SMA'MinPT on Sporttype/bettype
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Super's ID
	• @PT_XML:
			<ROOT>
				<PositionTaking 
						SportType="1" 
						BetType="1" 
						IsLive="1" 
						MinPT="0"
				/>
			</ROOT>
	*/
BEGIN
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = getdate()

	DECLARE @maxpos SMALLMONEY
	DECLARE @roleid INT
		,@srecommend INT
		,@mrecommend INT
		,@recommend INT

	SELECT @roleid = roleid
		,@srecommend = srecommend
		,@mrecommend = mrecommend
		,@recommend = recommend
	FROM customer WITH (NOLOCK)
	WHERE custid = @custid


	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode <> 0
		RETURN

	--Check Allowed downlines    
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid = @custid
		,@roleid = @roleid
		,@isExecRep = 1
		,@isUpdatePT = 1
		,@Sporttype = 1
		,@Language = 'E'
		,@ErrMsg = @ErrMsg OUTPUT
		,@ErrCode = @ErrCode OUTPUT

	IF @ErrCode <> 0
		RETURN


	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @PT_XML
	
	SELECT *
	INTO #newPTTbl
	FROM OPENXML (@iDoc, '/ROOT/PositionTaking',1) 
	WITH(SportType smallint, BetType smallint, Islive bit, SuperPT tinyint, 
	MasterPT tinyint, AgentPT tinyint, MinPT tinyint,IsUpdateMinPT BIT,IsUpdatePresetPT BIT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	DELETE FROM #newPTTbl main
	JOIN dbo.CustPTSetting3rd_Agent pt
	ON main.SportType=pt.SportType 
	AND main.BetType=pt.BetType
	AND main.Islive=pt.Islive
	AND pt.CustID=@CustID
	WHERE main.MinPT=pt.MinPT
	
	--Check Old_min = New_min
	IF (NOT EXISTS(SELECT TOP 1 1 FROM #newPTTbl))
	BEGIN
		RETURN
	END
	
	--Check n4 <= MIN(l4,s4)
	IF @RoleID = 4
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newPTTbl main
			JOIN dbo.CustPTSetting3rd_Agent pt
			ON main.SportType=pt.SportType 
			AND main.BetType=pt.BetType
			AND main.Islive=pt.Islive
			AND pt.CustID=@CustID
			WHERE main.MinPT > pt.SuperPT OR main.MinPT > pt.MaxPT)
		BEGIN
			Select @ErrCode = 101
			Select @ErrMsg =     case @Language 
								when 'E' then 'Wrong min position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](30001,@Language)
						end
			return
		END
	END
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newPTTbl main
			JOIN dbo.CustPTSetting3rd_Agent pt
			ON main.SportType=pt.SportType 
			AND main.BetType=pt.BetType
			AND main.Islive=pt.Islive
			AND pt.CustID=@CustID
			JOIN dbo.CustPTSetting3rd_Agent spt
			ON main.SportType=spt.SportType 
			AND main.BetType=spt.BetType
			AND main.Islive=spt.Islive
			AND spt.CustID=@SuperID
			WHERE main.MinPT > pt.masterPT OR main.MinPT > pt.MaxPT OR main.MinPT > spt.masterPT)
		BEGIN
			Select @ErrCode = 101
			Select @ErrMsg =     case @Language 
								when 'E' then 'Wrong min position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](30001,@Language)
						end
			return
		END
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newPTTbl main
			JOIN dbo.CustPTSetting3rd_Agent pt
			ON main.SportType=pt.SportType 
			AND main.BetType=pt.BetType
			AND main.Islive=pt.Islive
			AND pt.CustID=@CustID
			JOIN dbo.CustPTSetting3rd_Agent spt
			ON main.SportType=spt.SportType 
			AND main.BetType=spt.BetType
			AND main.Islive=spt.Islive
			AND spt.CustID=@SuperID
			WHERE main.MinPT > pt.agentPT OR main.MinPT > pt.MaxPT OR main.MinPT > spt.agentPT)
		BEGIN
			Select @ErrCode = 101
			Select @ErrMsg =     case @Language 
								when 'E' then 'Wrong min position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](30001,@Language)
						end
			return
		END
	END
	
	if @ErrCode <> 0
	BEGIN
		return
	END
	
	UPDATE main
	SET main.MinPT = tmp.MinPT
	FROM dbo.CustPTSetting3rd_Agent main
	JOIN #newPTTbl tmp
	ON main.SportType=tmp.SportType 
		AND main.BetType=tmp.BetType
		AND main.Islive=tmp.Islive
	WHERE main.CustID=@CustID
	
	
	EXEC dbo.Acc_CorrectUpdMinPT_Execrep_04 
		@CustID =@CustID
		,@RoleID=@RoleID
		,@recommend = @recommend
		,@mrecommend = @mrecommend
		,@srecommend = @srecommend
		
	IF @roleid = 2
	BEGIN    
		-- The minimum position taking value of agent was modified by agent's upline
		EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID    
	END

END