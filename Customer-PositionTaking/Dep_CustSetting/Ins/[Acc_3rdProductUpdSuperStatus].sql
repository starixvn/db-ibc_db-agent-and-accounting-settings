
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_3rdProductUpdSuperStatus    Script Date: 7/17/2015 10:56:48 AM ******/
ALTER PROCEDURE	[dbo].[Acc_3rdProductUpdSuperStatus] 
	@ProductID			INT,
	@CustID				INT,
	@IsEnable			BIT,
	@ApplyToMember		BIT				= 0,
	@UserID				INT,
	@IP					VARCHAR(40),
	@Langkey			VARCHAR(10)		= 'en-US',	
	@ErrMsg				VARCHAR(100)	= ''	OUTPUT
AS
/*
	Created: 20150309@Winne
	Task: Update 3rd product status of super ( 12 GoldDeluxe)
	DB: DBTXN/CustDB
	Original:
	Revisions:
	-20150612@Winnie: Add Microgaming & bettrade
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun			DATETIME
			,@endRun			DATETIME
			,@duration			INT
			,@LogSPData			VARCHAR(MAX)
			,@TrackingValue2	VARCHAR(MAX)
			,@IsEnabled_Old		BIT	= 0
			,@ProductName		VARCHAR(50)
			,@CurrRow INT = 1
			,@RowPerBatch INT = 10000
			,@RowCount INT = 0
	CREATE TABLE #CustList (RowNo INT IDENTITY(1,1), CustID INT)
	SET @startRun = GETDATE()

	SELECT @ProductName=ProductName FROM DBLIC.bodb_Licensee.dbo.Product3rd WITH (NOLOCK) WHERE @ProductID=ProductID

	

	IF @Productid=14 -- Microgaming
	BEGIN
	DECLARE @RoleId INT
	SELECT @IsEnabled_Old	=	~ISNULL(DisableMicrogame, 1),@RoleId=RoleId
	FROM dbo.custInfo WITH (NOLOCK) 
	WHERE CustID = @CustID 
	UPDATE dbo.custInfo WITH(ROWLOCK)
		SET DisableMicrogame = ~@IsEnable
		WHERE CustID = @CustID		
		IF(@@ERROR<>0)
		BEGIN
		SELECT @ErrMsg='Could not update'
		RETURN
		END
		
			IF @IsEnable = 0
		SET @ApplyToMember = 1

			-- Update Status for all downline members
			IF (@ApplyToMember = 1)
			BEGIN
				
					IF @RoleId=4	
					BEGIN
					INSERT INTO #CustList (CustID)
					SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
					INNER JOIN Customer ag WITH (NOLOCK) ON rm.srecommend=ag.Custid
					WHERE rm.srecommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'	
					END
					ELSE IF @RoleId=3
					BEGIN
					INSERT INTO #CustList (CustID)
					SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
					INNER JOIN Customer ag WITH (NOLOCK) ON rm.srecommend=ag.Custid
					WHERE rm.mrecommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'
					END
					ELSE
					BEGIN
					INSERT INTO #CustList (CustID)
					SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
					INNER JOIN Customer ag WITH (NOLOCK) ON rm.srecommend=ag.Custid
					WHERE rm.recommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'
					END

				SELECT @RowCount = @@rowcount

				WHILE (@CurrRow <= @RowCount)
				BEGIN
					UPDATE dbo.custInfo WITH (ROWLOCK, UPDLOCK)
					SET DisableMicrogame = ~@IsEnable
					WHERE  CustID IN (SELECT CustID FROM #CustList WHERE RowNo BETWEEN @CurrRow AND (@CurrRow + @RowPerBatch - 1))
					IF(@@ERROR<>0)
					BEGIN
					SELECT @ErrMsg='Could not update'
					RETURN
					END				
					SELECT @CurrRow = @CurrRow + @RowPerBatch
					WAITFOR DELAY '00:00:00.300'
				END
				DROP TABLE #CustList
			END
		--end 14
		
	END
	ELSE
	BEGIN
	SELECT @IsEnabled_Old	=	ISNULL(IsEnabled, 0)
	FROM dbo.Dep_SupperProductSetting WITH (NOLOCK) 
	WHERE CustID = @CustID AND ProductId=@ProductId
	-- Update Status for Super
	IF (EXISTS(SELECT 1 FROM dbo.Dep_SupperProductSetting WITH (NOLOCK) WHERE CustID = @CustID AND ProductId=@ProductId ))
	BEGIN
		UPDATE dbo.Dep_SupperProductSetting WITH(ROWLOCK)
		SET IsEnabled = @IsEnable
		WHERE CustID = @CustID
		AND ProductId=@ProductId 
		IF(@@ERROR<>0)
		BEGIN
		SELECT @ErrMsg='Could not update'
		RETURN
		END
	END
	ELSE
	BEGIN
		INSERT INTO dbo.Dep_SupperProductSetting (CustID, ProductId,IsEnabled)
		VALUES (@CustID, @ProductId, @IsEnable)
		IF(@@ERROR<>0)
		BEGIN
		SELECT @ErrMsg='Could not insert'
		RETURN
		END
	END
		
		IF(@ProductId=13) -- bettrade
		BEGIN		 
		 SELECT a.userName+'BetTrade' AS UserName,a.custid AS recommend, a.mrecommend ,a.currency,
			b.[closed]
           ,b.[MatchLimit]
           ,b.[VirtualMultiplier]          
           ,b.[Enabled]
           ,b.[danger]           
           ,b.[DisableHorseRacing]
           ,b.[DisableFinancial]
           ,b.[DisableCasino]
           ,b.[SyncCasino]
           ,b.[danger2]
           ,b.[danger3]
           ,b.[DisableOutright]
           ,b.[DisableOpenTote]
           ,b.[maxpermatch151_OT]
           ,b.[MaxPerMatch99MP]
           ,b.[DisableBingo]
           ,b.[DisableNumber]
           ,b.[maxpermatch161]
           ,b.[SyncBingo]
           ,b.[MaxPerBall161]
           ,b.[MaxPerMatch151_AU]
           ,b.[MaxPerMatch152_UK]
           ,b.[MaxPerMatch152_AU]
           ,b.[MaxPerMatch153_AU]
           ,b.[Disable151_AU]
           ,b.[Disable152_UK]
           ,b.[Disable152_AU]
           ,b.[Disable153_AU]
           ,b.[MaxTransferP2P]
           ,b.[IsAutoResetP2P]
           ,b.[DisableP2P]
           ,b.[DisableFunP2P]
           ,b.[DisableLiveCasino]
           ,b.[SyncLiveCasino]
           ,b.[maxpermatch180]
           ,b.[DisableVirtualSports]
           ,b.[HideVirtualSports]
           ,b.[Abnormal]
           ,b.[isAutoResetLiveCasino]
           ,b.[MaxWinLiveCasino]
           ,b.[DoubleCommLosing]
		 INTO #tempBettrade
		 FROM Customer a (NOLOCK) 
		 INNER JOIN  custInfo b (NOLOCK) ON a.custid=b.custid
		 WHERE a.srecommend=@CustID AND a.roleid=2 AND a.username not like '%'+a.site +'ACC%'
		 AND (NOT EXISTS (select 1 from customer c with (NOLOCK)      
				where c.username2 =   a.userName+'BetTrade'))			  
		 AND (NOT EXISTS (select 1 from customer with(NOLOCK) where username = a.userName+'BetTrade') )
		 AND (NOT exists (select 1 from custsub with(NOLOCK) where username = a.userName+'BetTrade') )

		 --INSERT INTO [dbo].[Customer]
   --        (          
		 --  [username]       
   --        ,[username2]
		 --  ,creatdate
		 --  ,creator
		 --  ,currency
		 --  ,roleid
		 --  ,srecommend
		 --  ,mrecommend
		 --  ,recommend)
		 --  SELECT 	 
		 --  [username]          
   --        ,[username]
		 --  ,GETDATE()	
		 --  ,@UserId
		 --  ,b.Currency
		 --  ,1
		 --  ,@CustId
		 --  ,b.mrecommend
		 --  ,b.recommend
		 --  FROM #tempBettrade b		
		 --  WHERE NOT EXISTS (SELECT TOP 1 1 FROM Customer(NOLOCK)  WHERE username=b.username)
		 --  	IF(@@ERROR<>0)
			--BEGIN
			--SELECT @ErrMsg='Could not insert customer'
			--RETURN
			--END
	

		--INSERT INTO [dbo].[custInfo]
  --         ([username]
  --         ,[custid]
  --         ,[currency]
  --         ,[roleid]
  --         ,[srecommend]
  --         ,[mrecommend]
  --         ,[recommend]         
  --         ,[closed]
  --         ,[MatchLimit]
  --         ,[VirtualMultiplier]          
  --         ,[Enabled]
  --         ,[danger]           
  --         ,[DisableHorseRacing]
  --         ,[DisableFinancial]
  --         ,[DisableCasino]
  --         ,[SyncCasino]
  --         ,[danger2]
  --         ,[danger3]
  --         ,[DisableOutright]
  --         ,[DisableOpenTote]
  --         ,[maxpermatch151_OT]
  --         ,[MaxPerMatch99MP]
  --         ,[DisableBingo]
  --         ,[DisableNumber]
  --         ,[maxpermatch161]
  --         ,[SyncBingo]
  --         ,[MaxPerBall161]
  --         ,[MaxPerMatch151_AU]
  --         ,[MaxPerMatch152_UK]
  --         ,[MaxPerMatch152_AU]
  --         ,[MaxPerMatch153_AU]
  --         ,[Disable151_AU]
  --         ,[Disable152_UK]
  --         ,[Disable152_AU]
  --         ,[Disable153_AU]
  --         ,[MaxTransferP2P]
  --         ,[IsAutoResetP2P]
  --         ,[DisableP2P]
  --         ,[DisableFunP2P]
  --         ,[DisableLiveCasino]
  --         ,[SyncLiveCasino]
  --         ,[maxpermatch180]
  --         ,[DisableVirtualSports]
  --         ,[HideVirtualSports]
  --         ,[Abnormal]
  --         ,[isAutoResetLiveCasino]
  --         ,[MaxWinLiveCasino]
  --         ,[DoubleCommLosing]
  --       )
		-- SELECT 
		--	a.[username]
  --         ,a.[custid]
  --         ,a.[currency]
  --         ,a.[roleid]
  --         ,a.[srecommend]
  --         ,a.[mrecommend]
  --         ,a.[recommend]  
		--   ,b.[closed]
  --         ,b.[MatchLimit]
  --         ,b.[VirtualMultiplier]          
  --         ,b.[Enabled]
  --         ,b.[danger]           
  --         ,b.[DisableHorseRacing]
  --         ,b.[DisableFinancial]
  --         ,b.[DisableCasino]
  --         ,b.[SyncCasino]
  --         ,b.[danger2]
  --         ,b.[danger3]
  --         ,b.[DisableOutright]
  --         ,b.[DisableOpenTote]
  --         ,b.[maxpermatch151_OT]
  --         ,b.[MaxPerMatch99MP]
  --         ,b.[DisableBingo]
  --         ,b.[DisableNumber]
  --         ,b.[maxpermatch161]
  --         ,b.[SyncBingo]
  --         ,b.[MaxPerBall161]
  --         ,b.[MaxPerMatch151_AU]
  --         ,b.[MaxPerMatch152_UK]
  --         ,b.[MaxPerMatch152_AU]
  --         ,b.[MaxPerMatch153_AU]
  --         ,b.[Disable151_AU]
  --         ,b.[Disable152_UK]
  --         ,b.[Disable152_AU]
  --         ,b.[Disable153_AU]
  --         ,b.[MaxTransferP2P]
  --         ,b.[IsAutoResetP2P]
  --         ,b.[DisableP2P]
  --         ,b.[DisableFunP2P]
  --         ,b.[DisableLiveCasino]
  --         ,b.[SyncLiveCasino]
  --         ,b.[maxpermatch180]
  --         ,b.[DisableVirtualSports]
  --         ,b.[HideVirtualSports]
  --         ,b.[Abnormal]
  --         ,b.[isAutoResetLiveCasino]
  --         ,b.[MaxWinLiveCasino]
  --         ,b.[DoubleCommLosing]
		-- FROM Customer(NOLOCK) a 
		-- INNER JOIN #tempBettrade b ON a.username=b.username
		-- WHERE NOT EXISTS (SELECT TOP 1 1 FROM custInfo(NOLOCK) WHERE username=a.username OR custid=a.custid)	
		 --	IF(@@ERROR<>0)
			--BEGIN
			--SELECT @ErrMsg='Could not insert custinfo'
			--DELETE a FROM Customer a(NOLOCK) INNER JOIN  #tempBettrade b ON a.username=b.username
			--DELETE a FROM custInfo a(NOLOCK) INNER JOIN  #tempBettrade b ON a.username=b.username
			--RETURN
			--END
		
		 -- INSERT INTO [dbo].[BetTradeCust]([Custid])
		 -- SELECT 
		 --   b.[Custid]
		 -- 	 FROM #tempBettrade a	
			-- INNER JOIN Customer(NOLOCK) b ON a.username=b.username	
		 --WHERE NOT EXISTS (SELECT TOP 1 1 FROM  [BetTradeCust](NOLOCK) WHERE custid=b.custid)	
		 -- IF(@@ERROR<>0)
			--BEGIN
			--SELECT @ErrMsg='Could not insert BetTradeCust'
			--DELETE a FROM Customer a(NOLOCK) INNER JOIN  #tempBettrade b ON a.username=b.username
			--DELETE a FROM custInfo a(NOLOCK) INNER JOIN  #tempBettrade b ON a.username=b.username			
			--DELETE a FROM [BetTradeCust] a(NOLOCK) 
			--INNER JOIN Customer(NOLOCK) c ON a.custid=c.Custid
			--INNER JOIN  #tempBettrade b ON c.username=b.username
			
			--RETURN
			--END 
		
		DECLARE @bettradeUserName VARCHAR(50), @bettradeCustId INT,@bettradeAgentId INT,@bettradeCurrency INT,@AffilateId INT,@ErrCode int=0,@Cust_ID int=0

		--WHILE EXISTS (SELECT TOP 1 1 FROM #tempBettrade)
		--BEGIN
			
		--SELECT TOP 1 @bettradeUserName=a.UserName,@bettradeCustId=b.custid,@bettradeAgentId=b.recommend,@bettradeCurrency=b.currency,@AffilateId=c.[AffID]
		--FROM #tempBettrade a	
		-- INNER JOIN Customer b WITH(NOLOCK)  ON a.username=b.username	
		-- LEFT JOIN DBAFF12BET.[Affiliate_12BET].[dbo].[AffInfo] c WITH(NOLOCK)  ON b.recommend=c.[AffID]
		--Copy Customer Info to DBLIC.bodb_Licensee.dbo.LicenseeCustinfo
		--EXEC DBLIC.bodb_Licensee.dbo.Lrf_CustomerInfoIns
		--	@CustID		= @bettradeCustId,
		--	@Recommend	= @bettradeAgentId,
		--	@Username	= @bettradeUserName,
		--	@Username2	= @bettradeUserName,
		--	@Currency	= @bettradeCurrency
		
		--END		
		 --end bettrade
		 
		END
	IF @IsEnable = 0
		SET @ApplyToMember = 1

	-- Update Status for all downline members
	IF (@ApplyToMember = 1)
	BEGIN
	
		
		
		INSERT INTO #CustList (CustID)
		SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
		INNER JOIN Customer ag WITH (NOLOCK) ON rm.recommend=ag.Custid
		WHERE rm.srecommend = @CustID AND rm.roleid = 1 AND ag.Username not like '%'+ag.site +'ACC%'

		SELECT @RowCount = @@rowcount

		WHILE (@CurrRow <= @RowCount)
		BEGIN
			UPDATE dbo.Dep_CustProductSetting WITH (ROWLOCK, UPDLOCK)
			SET IsEnabled = @IsEnable
			WHERE ProductId=@ProductId AND CustID IN (SELECT CustID FROM #CustList WHERE RowNo BETWEEN @CurrRow AND (@CurrRow + @RowPerBatch - 1))
			IF(@@ERROR<>0)
			BEGIN
			SELECT @ErrMsg='Could not update'
			RETURN
			END
			INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
			SELECT c.CustID, @ProductId, @IsEnable
			FROM #CustList c
			WHERE NOT EXISTS(SELECT 1 FROM dbo.Dep_CustProductSetting cs WITH (NOLOCK) WHERE cs.CustID = c.CustID AND cs.ProductId=@ProductId)
				AND RowNo BETWEEN @CurrRow AND (@CurrRow + @RowPerBatch - 1)
			IF(@@ERROR<>0)
			BEGIN
			SELECT @ErrMsg='Could not insert'
			RETURN
			END
			SELECT @CurrRow = @CurrRow + @RowPerBatch
			WAITFOR DELAY '00:00:00.300'
		END
		DROP TABLE #CustList
	END
	END

	-- Write log
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF(MILLISECOND,@startRun,@endRun)

	SELECT @LogSPData = '<Acc_3rdProductUpdSuperStatus CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" ' +
						'ProductName="'+ COALESCE(CAST(@ProductName as VARCHAR(50)),SPACE(1)) + '" ' +
						'IsEnable="'+ COALESCE(CAST(@IsEnable as VARCHAR(1)),SPACE(1)) + '" ' +
						'ApplyToMember="'+ COALESCE(CAST(@ApplyToMember as VARCHAR(1)),SPACE(1)) + '" ' +
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(40)),SPACE(1)) + '" ' +
						
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(8000)),SPACE(1))+ '" />'

	SELECT @TrackingValue2 = '<Acc_3rdProductUpdSuperStatus CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" ' +
						'@ProductName="'+ COALESCE(CAST(@ProductName as VARCHAR(50)),SPACE(1)) + '" ' +
						'IsEnable="'+ COALESCE(CAST(@IsEnabled_Old as VARCHAR(1)),SPACE(1)) + '" ' +
						'ApplyToMember=""' +
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(40)),SPACE(1)) + '" ' +
						
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(8000)),SPACE(1))+ '" />'
	
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = 1154,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @TrackingValue2,
				@duration = @duration 
	
END


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_3rdProductUpdSuperStatus] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_3rdProductUpdSuperStatus] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_3rdProductUpdSuperStatus] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_3rdProductUpdSuperStatus] TO [bodbExtAccNet]
GO 
