SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_BetLimitUpd]
	@CustID INT,
	@RoleID INT,
	@BetLimit_XML VARCHAR(MAX),

	@UserID		INT,
	@IP			VARCHAR(50)= '',
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
	Created: 20141111@Dominic
	Task : Update Customer's Bet Limits
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @BetLimit_XML:
		<ROOT>
				<BetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
						MaxPerMatch="1000000"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
	DECLARE @logSpData NVARCHAR(MAX)
			,@logSpData_Old NVARCHAR(MAX)
			,@xml XML
	DECLARE @ErrCode_Cur	INT 
			,@ErrMsg_Cur		NVARCHAR(4000)
			,@AgentID INT
			,@MasterID INT
			,@SuperID INT
			
	DECLARE @OldBetLimitTbl TABLE
				(
					SportType SMALLINT,
					BetType SMALLINT,
					MinBet MONEY,
					MaxBet MONEY,
					MaxPerMatch MONEY
				)
				
	DECLARE @NewBetLimitTbl TABLE(
		SportType SMALLINT,
		BetType SMALLINT,
		MinBet MONEY,
		MaxBet MONEY,
		MaxPerMatch Money
	)
	
	--Check if XML is null or empty
	IF @BetLimit_XML IS NULL OR @BetLimit_XML= '' RETURN
	
	SET @startRun = GETDATE()
			
	
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''
	
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid
	,@ErrCode = @ErrCode_Cur OUTPUT
	,@ErrMsg = @ErrMsg_Cur OUTPUT

	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
			,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

		RETURN
	END
	
	--Check RoleID
	IF @RoleID not in (1,2,3,4)
	BEGIN
		Select @ErrMsg = case @Language 
							when 'E' then 'Invalid user!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						end, @ErrCode = 101	
		return
	END
	
	--Get line information
	SELECT @AgentID=recommend,@MasterID=mrecommend,@SuperID=srecommend
	FROM dbo.custInfo  WITH(NOLOCK)
	WHERE custid=@CustID
	
	--Parse XML	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML

	INSERT @NewBetLimitTbl
	SELECT *
	FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
	WITH(SportType smallint, BetType smallint, MinBet MONEY, MaxBet MONEY,MaxPerMatch MONEY)	
	
	EXEC sp_xml_removedocument @iDoc
	
	--Validate new bet settings
	EXEC [dbo].[Acc_CustSetting_BetLimitCheck]
									@CustID = @CustID,
									@RoleID = @RoleID,
									@AgentID = @AgentID,
									@MasterID = @MasterID,
									@SuperID = @SuperID,
									@BetLimit_XML = @BetLimit_XML,
									@Language = @Language,
									@ErrCode  = @ErrCode OUT,
									@ErrMsg   = @ErrMsg OUT

	IF @ErrCode <> '' RETURN
	
		
	IF @RoleID=1
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType,bl.BetType,bl.MinBet,bl.MaxBet,bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member bl
				INNER JOIN @NewBetLimitTbl tmp
					ON tmp.SportType=bl.sporttype
					AND tmp.BetType=bl.bettype
		WHERE bl.custid=@CustID
		
		--update new settings
		UPDATE main
		SET
			main.minbet = tmp.MinBet,
			main.maxbet = tmp.MaxBet,
			main.maxpermatch = tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Member main
			INNER JOIN @NewBetLimitTbl tmp
				ON tmp.SportType=main.sporttype
				AND tmp.BetType=main.bettype
		WHERE main.custid=@CustID
		AND (
			main.minbet <> tmp.MinBet
			OR
			main.maxbet <> tmp.MaxBet
			OR
			main.maxpermatch <> tmp.MaxperMatch
		)
		
	END
	ELSE IF @RoleID IN (2,3,4)
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType,bl.BetType,bl.MinBet,bl.MaxBet,bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
			INNER JOIN @NewBetLimitTbl tmp
				ON tmp.SportType=bl.sporttype
					AND tmp.BetType=bl.bettype
		WHERE bl.custid=@CustID
		
		--update new settings
		UPDATE main
		SET
			main.minbet = tmp.MinBet,
			main.maxbet = tmp.MaxBet,
			main.maxpermatch = tmp.MaxperMatch
		FROM dbo.CustBetSetting3rd_Agent main
			INNER JOIN @NewBetLimitTbl tmp
				ON tmp.SportType=main.sporttype
					AND tmp.BetType=main.bettype
		WHERE main.custid=@CustID
		AND (
			main.minbet <> tmp.MinBet
			OR
			main.maxbet <> tmp.MaxBet
			OR
			main.maxpermatch <> tmp.MaxperMatch
		)
	END

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg_Cur = CASE @Language
				WHEN 'E'
					THEN 'Update process is unsuccessful !'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			,@ErrCode_cur = 106

		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

			RETURN
		END
	END
	
	--START LOGGING		
	SET @xml = (
			SELECT @CustID AS '@c'
				, @RoleID AS '@r'
				, @UserID AS '@u'
				, @IP AS '@i'
				, @Language AS '@l'
				, (SELECT SportType AS '@s'
					, BetType AS '@b'
					, MinBet AS '@mib'
					, MaxBet AS '@mab'
					, MaxPerMatch AS '@mam'
				FROM @OldBetLimitTbl
				FOR XML PATH('x'), TYPE)
			FOR XML PATH('r'), TYPE)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	SET @xml = (
			SELECT @CustID AS '@c'
				, @RoleID AS '@r'
				, @UserID AS '@u'
				, @IP AS '@i'
				, @Language AS '@l'
				, (SELECT SportType AS '@s'
					, BetType AS '@b'
					, MinBet AS '@mib'
					, MaxBet AS '@mab'
					, MaxPerMatch AS '@mam'
				FROM @NewBetLimitTbl
				FOR XML PATH('x'), TYPE)
		FOR XML PATH('r'), TYPE)
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)
	

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 384,
			@TrackingValue = @logSpData,
			@TrackingValue2 = @logSpData_Old,
			@duration = @duration
	END TRY
	BEGIN CATCH		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 384,
			@TrackingValue = @logSpData,
			@TrackingValue2 = @logSpData_Old,
			@duration = @duration		
	END CATCH	
END