SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerCheckBetLimit]
	@CustID INT,
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@BetLimit_XML VARCHAR(MAX),

	@Language varchar(2) = 'E',
	@ErrCode  VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg     NVARCHAR(4000) = '' OUTPUT
AS
	/*
	Created: 20141111@Dominic
	Task : Check Customer's Bet Limits
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

	DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML
	
		SELECT *
	INTO #newBetLimitTbl
	FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
	WITH(SportType smallint, BetType smallint, MinBet MONEY, MaxBet MONEY,MaxPerMatch MONEY)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF EXISTS(
		SELECT TOP 1 1 FROM #newBetLimitTbl WHERE MinBet < 0 OR MaxBet < 0 OR MaxPerMatch < 0
		)
	BEGIN
		Select @ErrMsg_Cur = case @Language 
						when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)					
					end, @ErrCode_Cur = 101
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	
	IF EXISTS(
				SELECT TOP 1 1 FROM #newBetLimitTbl
				WHERE
					(MinBet<>0 and MaxBet <> 0 and  MinBet>MaxBet) 
					OR (MaxBet<> 0 and MaxPerMatch <> 0 and MaxBet>MaxPerMatch) 
					OR (MinBet <> 0 and MaxPerMatch <> 0 and MinBet>MaxPerMatch) 
			)
	BEGIN
		SELECT
		@ErrMsg_Cur =	case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
					end, @ErrCode_Cur = 102
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
		
	IF @RoleID=3 
	BEGIN
		INSERT INTO #UplineLimit
		SELECT bl.SportType,bl.BetType,MAX(bl.MinBet) AS MinBet, MIN(bl.MaxBet) AS MaxBet,
					MIN(bl.MaxPerMatch) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN #newBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID
		GROUP BY bl.SportType,bl.BetType
	END
	ELSE IF @RoleID=2
	BEGIN
		INSERT INTO #UplineLimit
		SELECT bl.SportType,bl.BetType,MAX(bl.MinBet) AS MinBet, MIN(bl.MaxBet) AS MaxBet,
					MIN(bl.MaxPerMatch) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN #newBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID OR bl.CustID=@MasterID
		GROUP BY bl.SportType,bl.BetType
	END
	ELSE IF @RoleID=1
	BEGIN
		INSERT INTO #UplineLimit
		SELECT bl.SportType,bl.BetType,MAX(bl.MinBet) AS MinBet, MIN(bl.MaxBet) AS MaxBet,
					MIN(bl.MaxPerMatch) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN #newBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID OR bl.CustID=@MasterID OR bl.CustID=@AgentID
		GROUP BY bl.SportType,bl.BetType
	END
	
	
	IF @RoleID IN (1,2,3)
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newBetLimitTbl tmp
			JOIN #UplineLimit ubl
			ON tmp.SportType=ubl.SportType
			AND tmp.BetType=ubl.BetType
			WHERE
			 (ubl.MinBet>0 and 
				tmp.MinBet>0 and 
				tmp.MinBet<ubl.MinBet)
		)
		BEGIN
			SELECT @ErrMsg_Cur =	
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language)
							end						
							+' (' + convert(varchar(20), @MinMinBet) + ').'
					, @ErrCode_Cur = 103
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newBetLimitTbl tmp
			JOIN #UplineLimit ubl
			ON tmp.SportType=ubl.SportType
			AND tmp.BetType=ubl.BetType
			WHERE(ubl.MaxBet>0 and tmp.MaxBet>0 and sbl.MaxBet>ubl.MaxBet)
		)
		BEGIN
			
			SELECT @ErrMsg_Cur =	
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language)
							end						
							+' (' + convert(varchar(20), @MinMinBet) + ').'
					, @ErrCode_Cur = 103
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		
		IF EXISTS(
			SELECT TOP 1 1 
			FROM #newBetLimitTbl tmp
			JOIN #UplineLimit ubl
			ON tmp.SportType=ubl.SportType
			AND tmp.BetType=ubl.BetType
			WHERE (ubl.MaxPerMatch>0 and tmp.MaxPerMatch>0 and tmp.MaxPerMatch>ubl.MaxPerMatch)
		)
		BEGIN
			SELECT @ErrMsg_Cur =	
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language)
							end						
							+' (' + convert(varchar(20), @MinMinBet) + ').'
					, @ErrCode_Cur = 103
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
	END
	
	
	IF OBJECT_ID('tempdb..#UplineLimit') IS NOT NULL
		DROP TABLE #UplineLimit
	IF OBJECT_ID('tempdb..#newBetLimitTbl') IS NOT NULL
		DROP TABLE #newBetLimitTbl
END