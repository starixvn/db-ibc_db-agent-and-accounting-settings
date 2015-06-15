ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_04]
	@custid int,
	@roleid tinyint,
	@action varchar(30) = '',
	@EnableVirtualrate BIT = 0,
	@virtualmultiplier VARCHAR(MAX) = '',
	@Suspended	BIT =0,
	@Closed		BIT =0,
	@disabledCS BIT =0,
	@DisableLiveCasino BIT = 0,
	@DisableHRFixedOdds BIT = 0,
	@DisableVS BIT = 0,
	@EnableVS BIT = 0,
	@DisableNumberGame BIT = 0,
	@DisableGoldDeluxe BIT = 0,
	@BingoStatus BIT = 0,
	@AutoSuspendSoccer BIT = 0,
	@AutoSuspendOtherSports BIT = 0
AS 
/*
Created: Jamie
Date: 20141125
Task : Update customer/custinfo settings
DB: DBCUST/CustDB
Original: Acc_ExecRep_Cust_04
Replication Info: Inlcude in exec rep from DBCUST.custDB -> DB06/DB04x/DBTP.bodb02

Revisions:
	- 20141230@Johnson: separate virtual rate by sporttype and bettype
	- 20150424@Johnson: add Gold Deluxe
	- 20150603@Daniel: 
	  + Separate custDB to new server DBCUST: Split update custinfo into execrep SP Acc_ExecRep_Cust_10
	  + Improve medthod check table existing in subscribers
	  

Param's Explanation:
	@Action: 
		+ 'VirtualMultiplier': Virtual Rate [@virtualmultiplier]
		+ 'Suspended': Suspended/Reject		[@Suspended]
		+ 'Closed': Closed					[@Closed]
		+ 'disabledCS': RNG Casino Status	[@disabledCS]
		+ 'DisableLiveCasino': Live Casino status [@DisableLiveCasino]
		+ 'DisableVS': Disable Virtual Sport [@DisableVS]
		+ 'EnableVS': Enable Virtual Sport [@EnableVS]
		+ 'DisableNumberGame': Number game status [@DisableNumberGame]
		+ 'DisableHRFixedOdds': HR Fixed Odds status [@DisableHRFixedOdds]
		+ 'BingoStatus': Bingo status [@BingoStatus]
		+ 'AutoSuspend': Auto suspend all: Soccer and Other Sports [@AutoSuspendSoccer, @AutoSuspendOtherSports]
		+ 'AutoSuspendSoccer': Auto suspend for Soccer[@AutoSuspendSoccer]
		+ 'AutoSuspendOther': Auto suspend for Other Sports [@AutoSuspendOtherSports]
		+ 'UpdKeno-Hide' : Hide Keno gaming
   
*/
SET NOCOUNT ON 

	
if @action = 'VirtualMultiplier'
BEGIN
	DECLARE @tblVirtualrate TABLE (
									SportType INT
									,BetType INT
									,IsLive	BIT
									,VirtualMultiplier SMALLMONEY	
								)
								
	DECLARE @DocHandler INT, 
			@EnableVirtualrateOld BIT
	
	IF @virtualmultiplier <> ''
	BEGIN			
		-- For read xml					
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @virtualmultiplier

		INSERT INTO @tblVirtualrate(
					SportType,
					BetType,
					IsLive,
					VirtualMultiplier
				)
		SELECT
			Data.SportType,
			Data.BetType,
			Data.IsLive,
			Data.VirtualMultiplier
		FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
		WITH (
			SportType	SMALLINT,
			BetType		SMALLINT,
			IsLive		BIT,
			VirtualMultiplier SMALLMONEY	
		) AS Data

		EXEC sp_xml_removedocument @DocHandler
		-- end read xml
	END	
	
	SELECT @EnableVirtualrateOld = virtualmultiplier
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF (@EnableVirtualrateOld <> @EnableVirtualrate AND dbo.f_CheckRepTable('custinfo') = 1)
	BEGIN
	   EXEC [dbo].[Acc_ExecRep_Cust_10]
		   @custid = @custid,
		   @roleid = @roleid,
		   @action = @action,
		   @EnableVirtualrate = @EnableVirtualrate,
		   @Suspended =@Suspended,
		   @Closed = @Closed,
		   @disabledCS =@disabledCS,
		   @DisableLiveCasino = @DisableLiveCasino,
		   @DisableHRFixedOdds = @DisableHRFixedOdds,
		   @DisableVS = @DisableVS,
		   @EnableVS = @EnableVS,
		   @DisableNumberGame = @DisableNumberGame,
		   @DisableGoldDeluxe = @DisableGoldDeluxe,
		   @BingoStatus = @BingoStatus,
		   @AutoSuspendSoccer = @AutoSuspendSoccer,
		   @AutoSuspendOtherSports = @AutoSuspendOtherSports
	END
	
	IF (@EnableVirtualrate = 1 AND dbo.f_CheckRepTable('CustVirtualrate') = 1)	
	BEGIN
		if @roleid = 4
		BEGIN
			UPDATE cs
			SET virtualmultiplier = t.VirtualMultiplier
			FROM CustVirtualrate cs WITH(UPDLOCK,ROWLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN @tblVirtualrate t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType
												AND cs.isLive = t.IsLive
			WHERE ci.srecommend = @custid
				AND t.VirtualMultiplier <> cs.VirtualMultiplier
		END
		ELSE IF @roleid = 3
		BEGIN
			UPDATE cs
			SET virtualmultiplier = t.VirtualMultiplier
			FROM CustVirtualrate cs WITH(UPDLOCK,ROWLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN @tblVirtualrate t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType
												AND cs.isLive = t.IsLive
			WHERE ci.mrecommend = @custid
				AND t.VirtualMultiplier <> cs.VirtualMultiplier
		END
		ELSE IF @roleid = 2
		BEGIN
			UPDATE cs
			SET virtualmultiplier = t.VirtualMultiplier
			FROM CustVirtualrate cs WITH(UPDLOCK,ROWLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN @tblVirtualrate t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType
												AND cs.isLive = t.IsLive
			WHERE ci.recommend = @custid
				AND t.VirtualMultiplier <> cs.VirtualMultiplier
		END
		ELSE IF @roleid = 1
		BEGIN
			UPDATE cs
			SET virtualmultiplier = t.VirtualMultiplier
			FROM CustVirtualrate cs WITH(UPDLOCK,ROWLOCK)				
				INNER JOIN @tblVirtualrate t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType
												AND cs.isLive = t.IsLive
			WHERE custid = @custid
				AND t.VirtualMultiplier <> cs.VirtualMultiplier
		END
	END
	
END
ELSE
   EXEC [dbo].[Acc_ExecRep_Cust_10]
	   @custid = @custid,
	   @roleid = @roleid,
	   @action = @action,
	   @EnableVirtualrate = @EnableVirtualrate,
	   @Suspended =@Suspended,
	   @Closed = @Closed,
	   @disabledCS =@disabledCS,
	   @DisableLiveCasino = @DisableLiveCasino,
	   @DisableHRFixedOdds = @DisableHRFixedOdds,
	   @DisableVS = @DisableVS,
	   @EnableVS = @EnableVS,
	   @DisableNumberGame = @DisableNumberGame,
	   @DisableGoldDeluxe = @DisableGoldDeluxe,
	   @BingoStatus = @BingoStatus,
	   @AutoSuspendSoccer = @AutoSuspendSoccer,
	   @AutoSuspendOtherSports = @AutoSuspendOtherSports
