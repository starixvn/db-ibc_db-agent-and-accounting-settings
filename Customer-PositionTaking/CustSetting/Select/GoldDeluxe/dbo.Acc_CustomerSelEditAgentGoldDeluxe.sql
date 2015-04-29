ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentGoldDeluxe]
	@custid		INT,
	@mrecommend INT
AS
/*
	Created: 20150422@Elodie
	Task: Master edits agent's Gold Deluxe setting
	DB: DBAGE/BODB02
	
	Revisions:
	
	Parameters Explanation
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleID INT 

		-- Check Downline Belonging
	EXEC dbo.Age_CustomerSelCheckBelonging  
			@SessionCustID	= @mrecommend, 
			@Custid			= @CustID,
			@roleID			= @roleID OUTPUT

	IF @roleID = 0
		RETURN

	DECLARE @v255adiscount_1701	DECIMAL(9,8),
			@DisableAutoMPT		BIT,
			@max_v255mpositiontaking_1701 SMALLMONEY

	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM custmaster WITH(NOLOCK)
	WHERE custid = @mrecommend
			
	
	--Master Comm	
	SELECT	@v255adiscount_1701 = adiscount,
			@max_v255mpositiontaking_1701 = mpositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 255 AND bettype = 1701

	SELECT 	
		ISNULL(discount,0) AS v255discount_1701,
		ISNULL(@v255adiscount_1701,0) AS v255discount_1701_max,
		ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,		

		--a2
		apositiontaking AS v255apositiontaking_1701,		
		--m2		
		mpositiontaking AS v255mpositiontaking_1701,
		@max_v255mpositiontaking_1701 AS v255mpositiontaking_1701_max,
		--u2
		autompositiontaking AS auto_v255mpositiontaking_1701,		
		--i2
		isautompositiontaking AS isauto_v255mpositiontaking_1701,		
		--u2_max
		@max_v255mpositiontaking_1701 AS auto_v255mpositiontaking_1701_max,
		
		--n2
		co.minpositiontaking as v255apositiontaking_1701_min	
	FROM custsettingGame cs WITH(NOLOCK)
			INNER JOIN custoverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
	WHERE cs.custid = @custid AND cs.sporttype = 255 AND cs.bettype = 1701

END

GO
GRANT VIEW DEFINITION ON [Acc_CustomerSelEditAgentGoldDeluxe] TO vnteam
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentGoldDeluxe] TO bodbAdminNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentGoldDeluxe] TO bodbDownlineNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentGoldDeluxe] TO bodbDownlineNetView
