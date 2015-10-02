USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelRefSport_Bettype]    Script Date: 06/06/2015 14:30:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerSelRefSport_Bettype    Script Date: 9/29/2014 12:50:42 PM ******/

ALTER PROCEDURE  [dbo].[Acc_CustomerSelRefSport_Bettype]
	 @CustID		INT = NULL
	,@RoleID		INT = 0 
	,@isShowAll		BIT = 1 
AS 
/*
	Created by: Jamie
	Date: 20140916
	Task: Retrieve Customer Setting Reference 
	DB: DBTXN/bodb02 

	Revision: 
		- 20150606@Kathy: Change link server DBTXN.CustDB to DBCust.CustDB [Redmine:#36216]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		

	Param's Explanation: 
		@CustID (Login account): =NULL: Admin ; =NOT NULL: SMA 
		@isShowAll: 0: Show Active Bettype, 1: Show ALL 

	Sample: 
				EXEC [Acc_CustomerSelRefSport_Bettype_testH] @CustID = 19096909 , @RoleID = 2 

*/
BEGIN
	SET NOCOUNT ON 
	DECLARE	 @DisableHRFixedOdds	BIT = 0
			,@HideKeno				BIT = 0 
			,@DisableKeno			INT = 0 
			,@DisableNumber			BIT = 0 
			,@IsMyanmarOdds BIT = 0
			,@recommend INT = 0
	
	IF @RoleID BETWEEN 2 AND 4 
	BEGIN
			SELECT	 @DisableHRFixedOdds = ci.DisableHRFixedOdds
					,@HideKeno			 = ci.HideKeno
					,@DisableNumber		 = ci.DisableNumber
					
			FROM	CustDB.dbo.CustInfo ci WITH (NOLOCK) 
			WHERE	ci.CustID = @CustID

			SELECT	@DisableKeno = MIN(CAST(cg.IsDisabled AS INT))
			FROM	DBCUST.CustDB.dbo.CustGameType cg WITH (NOLOCK) 
					LEFT JOIN dbo.GameType g WITH (NOLOCK) ON cg.GameTypeID = g.GameTypeID 
			WHERE	cg.CustID = @CustID
					AND g.IBCBetTypeID IN (1501,1503,1504,1505,1507,1508,1509,1511,1513)	--Keno Bettype 
			
			SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@Custid)
			

	END
	
	IF @RoleID = 1
	BEGIN
		
		SET @recommend = (SELECT recommend FROM DBCUST.CustDB.dbo.CustInfo WITH (NOLOCK) WHERE custid=@CustID)
		SET @IsMyanmarOdds = CustDB.dbo.fn_IsMyanmarOdds(@recommend)
		
				
	END
	
	SELECT	Sporttype, Bettype, SporttypeRef, BettypeRef,ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds
	FROM	dbo.Sport_Bettype_Reference WITH (NOLOCK)
	WHERE	Sporttype NOT IN (
				 CASE WHEN @DisableHRFixedOdds = 1 THEN 154 ELSE 0 END				--HR Fixed Odds
				,CASE WHEN @DisableNumber = 1 THEN 161 ELSE 0 END					--Number Game
				,CASE WHEN @HideKeno = 1 OR @DisableKeno = 1 THEN 202 ELSE 0 END	--Keno 
				,CASE WHEN @IsMyanmarOdds = 0 AND Bettype IN (301,302,303,304) THEN 1 ELSE 0 END -- MyanmarOdds
			)
			AND isLicensee = 0 
			AND isActive = CASE WHEN @isShowAll = 0 THEN 1 ELSE isActive END 
	ORDER BY Sporttype, Bettype, SporttypeRef, BettypeRef

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbExtAccNet] AS [dbo]

