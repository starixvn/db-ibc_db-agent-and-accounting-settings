SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_BetLimitCheck]
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

	DECLARE @ErrCode_Cur INT, 
			@ErrMsg_Cur NVARCHAR(4000),
			@UserName varchar(30)
	
	DECLARE @MinBet MONEY = 0,
			@MaxBet MONEY =0,
			@MaxPerMatch MONEY = 0,
			@MinMinBet MONEY = 0,
			@MaxMaxBet MONEY = 0,
			@MaxMaxPerMatch MONEY = 0,
			@SportType SMALLINT
	
	DECLARE @UplineLimitTbl TABLE(
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
	
	SELECT @UserName = username
	FROM customer WITH (NOLOCK)
	WHERE CustID = @CustID

	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

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
	
	
	IF @BetLimit_XML IS NULL OR @BetLimit_XML='' RETURN
	
	
	--Parse XML data
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @BetLimit_XML
	
	
	INSERT @NewBetLimitTbl
	SELECT *
	FROM OPENXML (@iDoc, '/ROOT/BetLimit',1) 
	WITH(SportType smallint, BetType smallint, MinBet MONEY, MaxBet MONEY,MaxPerMatch MONEY)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF @RoleID=3 
	BEGIN
		--Get super 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT bl.SportType,bl.BetType,
				MAX(case when bl.MinBet = 0 then NULL else bl.MinBet end) AS MinBet, 
				MIN(case when bl.MaxBet = 0 then NULL else bl.MaxBet end) AS MaxBet,
				MIN(case when bl.MaxPerMatch = 0 then NULL else bl.MaxPerMatch end) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN @NewBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID
		GROUP BY bl.SportType,bl.BetType
	END
	ELSE IF @RoleID=2
	BEGIN
		--Get super/master 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT bl.SportType,bl.BetType,
					MAX(case when bl.MinBet = 0 then NULL else bl.MinBet end) AS MinBet, 
					MIN(case when bl.MaxBet = 0 then NULL else bl.MaxBet end) AS MaxBet,
					MIN(case when bl.MaxPerMatch = 0 then NULL else bl.MaxPerMatch end) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN @NewBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID OR bl.CustID=@MasterID
		GROUP BY bl.SportType,bl.BetType
	END
	ELSE IF @RoleID=1
	BEGIN
		--Get super/master 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT bl.SportType,bl.BetType,
					MAX(case when bl.MinBet = 0 then NULL else bl.MinBet end) AS MinBet, 
					MIN(case when bl.MaxBet = 0 then NULL else bl.MaxBet end) AS MaxBet,
					MIN(case when bl.MaxPerMatch = 0 then NULL else bl.MaxPerMatch end) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl
		JOIN @NewBetLimitTbl tmp
		ON tmp.SportType=bl.SportType
		AND tmp.BetType=bl.BetType
		WHERE bl.CustID=@SuperID OR bl.CustID=@MasterID OR bl.CustID=@AgentID
		GROUP BY bl.SportType,bl.BetType
	END
	
	
	--Get 1 error row
	SELECT TOP 1 
			@MinBet=ISNULL(tmp.MinBet,0),
			@MaxBet=ISNULL(tmp.MaxBet,0),
			@MaxPerMatch=ISNULL(tmp.MaxPerMatch,0),
			@MinMinBet = ISNULL(ubl.MinBet,0),
			@MaxMaxBet = ISNULL(ubl.MaxBet,0),
			@MaxMaxPerMatch = ISNULL(ubl.MaxPerMatch,0),
			@SportType = ubl.SportType
	FROM @NewBetLimitTbl tmp
	LEFT JOIN @UplineLimitTbl ubl
	ON tmp.SportType=ubl.SportType
	AND tmp.BetType=ubl.BetType
	WHERE
		  tmp.MinBet < 0 OR tmp.MaxBet < 0 OR tmp.MaxPerMatch < 0
		OR
		 ((tmp.MinBet<>0 OR tmp.MaxBet <> 0) AND  tmp.MinBet>tmp.MaxBet) 
		OR 
		((tmp.MaxBet<> 0 OR tmp.MaxPerMatch <> 0) and tmp.MaxBet>tmp.MaxPerMatch) 
		OR 
		((tmp.MinBet <> 0 OR tmp.MaxPerMatch <> 0) and tmp.MinBet>tmp.MaxPerMatch) 
		OR
		 (ubl.MinBet>0 and tmp.MinBet>0 and tmp.MinBet<ubl.MinBet)
		OR
		 (ubl.MaxBet>0 and tmp.MaxBet>0 and ubl.MaxBet>ubl.MaxBet)
		OR
		 (ubl.MaxPerMatch>0 and tmp.MaxPerMatch>0 and tmp.MaxPerMatch>ubl.MaxPerMatch)
	
	
	
	--Check all setting >=0
	IF (
		@MinBet < 0
		OR @MaxBet < 0
		OR @MaxPerMatch < 0
		)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E'
					THEN 'Wrong Min bet/ Max bet/ Max per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](@SportType, @Language) + ')'
				END
				,@ErrCode = 3
		RETURN
	END
	
	
	
	--Check MinBet<=MaxBet<=MaxPerMatch	
	IF (	
		((@MinBet<>0 OR @MaxBet <> 0) AND  @MinBet>@MaxBet) 
		OR ((@MaxBet<> 0 OR @MaxPerMatch <> 0) and @MaxBet>@MaxPerMatch) 
		OR ((@MinBet <> 0 OR @MaxPerMatch <> 0) and @MinBet>@MaxPerMatch) 
		)
	BEGIN
		SELECT @ErrMsg =	@UserName + ': '+
				CASE @Language
					WHEN 'E'
						THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](@SportType, @Language) + ')'
					END + CHAR(13) + CHAR(10) + convert(VARCHAR(20), @MinBet) + '-' + convert(VARCHAR(20), @MaxBet) + '-' + convert(VARCHAR(20), @MaxPerMatch)	
					,@ErrCode = 109
		RETURN
	END	
	
	
	IF @RoleID IN (1,2,3)
	BEGIN
		--Check if MAX(upper.minbet) > 0 and minbet>0 then minbet>=MAX(upper.minbet)
		IF (
				@MinMinBet > 0
				AND @MinBet > 0
				AND @MinBet < @MinMinBet
		)
		BEGIN
			SELECT @ErrMsg = @UserName + ': ' + CASE @Language
					WHEN 'E'
						THEN 
							CASE 
								WHEN @RoleID=3
									THEN 'Min bet must be equal to or greater than Super Agent min bet' 
								WHEN @RoleID=2
									THEN 'Min bet must be equal to or greater than Master Agent min bet' 
								WHEN @RoleID=1
									THEN 'Min bet must be equal to or greater than Agent min bet'
							END
					ELSE [dbo].[f_Get_MsgNamebyMsgID](
													CASE 
														WHEN @RoleID=3 THEN 10016 
														WHEN @RoleID=2 THEN 10019 
														WHEN @RoleID=2 THEN 10006
													END, 
													@Language) 
							+ ' (' + [dbo].[f_Get_SportNameBySporttype](@SportType, @Language) + ')'
					END + ' (' + convert(VARCHAR(20), @MinMinBet) + ').'
				,@ErrCode = 110

			RETURN
		END
		
		--Check if MIN(upper.maxbet) > 0 and maxbet>0 then maxbet<=MIN(upper.maxbet)
		IF (
				@MaxMaxBet > 0
				AND @MaxBet > 0
				AND @MaxBet > @MaxMaxBet
				)
		BEGIN
			SELECT @ErrMsg = @UserName + ': ' + CASE @Language
					WHEN 'E'
						THEN 
							CASE 
								WHEN @RoleID=3
									THEN 'Max bet must be equal to or less than Super Agent max bet' 
								WHEN @RoleID=2
									THEN 'Max bet must be equal to or less than Master Agent max bet' 
								WHEN @RoleID=1
									THEN 'Max bet must be equal to or less than Agent max bet'
							END
					ELSE [dbo].[f_Get_MsgNamebyMsgID](
													CASE 
														WHEN @RoleID=3 THEN 10017 
														WHEN @RoleID=2 THEN 10020 
														WHEN @RoleID=2 THEN 10007
													END, 
													@Language) 
							+ ' (' + [dbo].[f_Get_SportNameBySporttype](@SportType, @Language) + ')'
					END + ' (' + convert(VARCHAR(20), @MinMinBet) + ').'
				,@ErrCode = 111

			RETURN
		END
		
		--Check if MIN(upper.maxpermatch)> 0 and maxpermatch>0 then maxpermatch<=MIN(upper.maxpermatch)
		IF (
				@MaxMaxPerMatch > 0
				AND @MaxPerMatch > 0
				AND @MaxPerMatch > @MaxMaxPerMatch
				)
		BEGIN
			SELECT @ErrMsg = @UserName + ': ' + CASE @Language
					WHEN 'E'
						THEN 
							CASE 
								WHEN @RoleID=3
									THEN 'Max Per Match must be equal to or less than Super Agent Max Per Match' 
								WHEN @RoleID=2
									THEN 'Max Per Match must be equal to or less than Master Agent Max Per Match' 
								WHEN @RoleID=1
									THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
							END
					ELSE [dbo].[f_Get_MsgNamebyMsgID](
													CASE 
														WHEN @RoleID=3 THEN 10018 
														WHEN @RoleID=2 THEN 10021 
														WHEN @RoleID=2 THEN 10008
													END, 
													@Language) 
							+ ' (' + [dbo].[f_Get_SportNameBySporttype](@SportType, @Language) + ')'
					END + ' (' + convert(VARCHAR(20), @MinMinBet) + ').'
				,@ErrCode = 112

			RETURN
		END
	END
END