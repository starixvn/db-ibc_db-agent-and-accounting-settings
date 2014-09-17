ALTER PROCEDURE [dbo].[Acc_CustomerSelRefSport_Bettype]
	 @CustID		INT = NULL
	,@RoleID		INT = 0 
AS 
/*
	Created by: Jamie
	Date: 20140916
	Task: Retrieve Customer Setting Reference 
	DB: DBTXN/bodb02 

	Revision: 

	Param's Explanation: 
		@CustID (Login account): =NULL: Admin ; =NOT NULL: SMA 

	Sample: 
		EXEC [Acc_CustomerSelRefSport_Bettype] @CustID = 8 , @RoleID = 5 

*/
BEGIN
	SET NOCOUNT ON 
	DECLARE	 @DisableHRFixedOdds	BIT = 0
			,@HideKeno				BIT = 0 
			,@DisableKeno			INT = 0 
			,@DisableNumber			BIT = 0 

	IF @RoleID BETWEEN 2 AND 4 
	BEGIN
			SELECT	 @DisableHRFixedOdds = ci.DisableHRFixedOdds
					,@HideKeno			 = ci.HideKeno
					,@DisableNumber		 = ci.DisableNumber
			FROM	dbo.CustInfo ci WITH (NOLOCK) 
			WHERE	ci.CustID = @CustID

			SELECT	@DisableKeno = MIN(CAST(cg.IsDisabled AS INT))
			FROM	CustDB.dbo.CustGameType cg WITH (NOLOCK) 
					LEFT JOIN dbo.GameType g WITH (NOLOCK) ON cg.GameTypeID = g.GameTypeID 
			WHERE	cg.CustID = @CustID
					AND g.IBCBetTypeID IN (1501,1503,1504,1505,1507,1508,1509,1511,1513)	--Keno Bettype 
	END
	
	SELECT	Sporttype, Bettype, SporttypeRef, BettypeRef
	FROM	dbo.CustSettingRef_Sport_Bettype WITH (NOLOCK)
	WHERE	Sporttype NOT IN (
				 CASE WHEN @DisableHRFixedOdds = 1 THEN 154 ELSE 0 END				--HR Fixed Odds
				,CASE WHEN @DisableNumber = 1 THEN 161 ELSE 0 END					--Number Game
				,CASE WHEN  @HideKeno = 1 OR @DisableKeno = 1 THEN 202 ELSE 0 END	--Keno 
			)
	ORDER BY Sporttype, Bettype

END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbAdminNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbExtAccNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelRefSport_Bettype] TO [bodbDownlineNetView] 
GO
