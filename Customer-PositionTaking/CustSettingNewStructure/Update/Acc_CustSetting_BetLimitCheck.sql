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
	
	DECLARE @ErrorSportTypeTbl TABLE (
		SportType SMALLINT,
		MinBet MONEY,
		MaxBet MONEY,
		MaxPerMatch MONEY,
		MinMinBet MONEY ,
		MaxMaxBet MONEY ,
		MaxMaxPerMatch MONEY 
	)
			
	DECLARE @ErrSport VARCHAR(4000)	= ''
	
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

	
	IF @BetLimit_XML IS NULL OR @BetLimit_XML='' RETURN
	
	SELECT @ErrCode='',@ErrMsg=''
	
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
	INSERT INTO @ErrorSportTypeTbl
	SELECT 
			ISNULL(ubl.SportType,0),
			tmp.MinBet,
			tmp.MaxBet,
			tmp.MaxPerMatch,
			ISNULL(ubl.MinBet,0),
			ISNULL(ubl.MaxBet,0),
			ISNULL(ubl.MaxPerMatch,0)
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
		 (ubl.MaxBet>0 and tmp.MaxBet>0 and tmp.MaxBet>ubl.MaxBet)
		OR
		 (ubl.MaxPerMatch>0 and tmp.MaxPerMatch>0 and tmp.MaxPerMatch>ubl.MaxPerMatch)
	
	
	
	
	--IF there's no error data then return
	IF NOT EXISTS ( 
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
	)
	RETURN
	
	
	--Check all setting >=0
	SELECT @ErrSport = @ErrSport + [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) + ','
	FROM @ErrorSportTypeTbl tmp
	WHERE tmp.MinBet < 0 OR tmp.MaxBet < 0 OR tmp.MaxPerMatch < 0

	
	
	IF @ErrSport <> ''
	BEGIN
		SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
						END
						+ ' (' + @ErrSport + ')'
						, @ErrCode = 101
		RETURN
	END
	
	
	--Check MinBet<=MaxBet<=MaxPerMatch	
	SELECT @ErrSport = @ErrSport + [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) + ','
	FROM @ErrorSportTypeTbl tmp
	WHERE ((tmp.MinBet<>0 OR tmp.MaxBet <> 0) AND  tmp.MinBet>tmp.MaxBet) 
		OR 
		((tmp.MaxBet<> 0 OR tmp.MaxPerMatch <> 0) and tmp.MaxBet>tmp.MaxPerMatch) 
		OR 
		((tmp.MinBet <> 0 OR tmp.MaxPerMatch <> 0) and tmp.MinBet>tmp.MaxPerMatch) 
	
	IF @ErrSport <> ''
	BEGIN
		SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						END
						+ ' (' + @ErrSport + ')'
						, @ErrCode = 102
		RETURN
	END
	
	
	IF @RoleID IN (1,2,3)
	BEGIN
	
		--Check if MAX(upper.minbet) > 0 and minbet>0 then minbet>=MAX(upper.minbet)
		SELECT @ErrSport = @ErrSport 
					+ [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) 
					+ ':'
					+ convert(varchar(20), tmp.MinMinBet)
					+ ','
		FROM @ErrorSportTypeTbl tmp
		WHERE tmp.MinMinBet>0 and tmp.MinBet>0 and tmp.MinBet<tmp.MinMinBet
		
		IF @ErrSport <> ''
		BEGIN
			SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 
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
													END
													,@Language)
							END
							+ ' (' + @ErrSport + ')'
							, @ErrCode = 103
			RETURN
		END
		
	
	
	
		--Check if MIN(upper.maxbet) > 0 and maxbet>0 then maxbet<=MIN(upper.maxbet)
		SELECT @ErrSport = @ErrSport 
					+ [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) 
					+ ':'
					+ convert(varchar(20), tmp.MaxMaxBet)
					+ ','
		FROM @ErrorSportTypeTbl tmp
		WHERE tmp.MaxMaxBet>0 and tmp.MaxBet>0 and tmp.MaxBet>tmp.MaxMaxBet
		
		IF @ErrSport <> ''
		BEGIN
			SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 
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
													END
													,@Language)
							END
							+ ' (' + @ErrSport + ')'
							, @ErrCode = 104
			RETURN
		END
	
	

		
		--Check if MIN(upper.maxpermatch)> 0 and maxpermatch>0 then maxpermatch<=MIN(upper.maxpermatch)
		SELECT @ErrSport = @ErrSport 
					+ [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) 
					+ ':'
					+ convert(varchar(20), tmp.MaxMaxPerMatch)
					+ ','
		FROM @ErrorSportTypeTbl tmp
		WHERE tmp.MaxMaxPerMatch>0 and tmp.MaxPerMatch>0 and tmp.MaxPerMatch>tmp.MaxMaxPerMatch
		
		IF @ErrSport <> ''
		BEGIN
			SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 
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
													END
													,@Language)
							END
							+ ' (' + @ErrSport + ')'
							, @ErrCode = 105
			RETURN
		END
		
		
	END
END