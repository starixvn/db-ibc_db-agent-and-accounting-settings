USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditAgentGoldDeluxe]    Script Date: 05/11/2015 09:17:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

	DECLARE @v255adiscount_1701				DECIMAL(9,8)
			,@DisableAutoMPT				BIT
			,@max_v255mpositiontaking_1701 SMALLMONEY
			,@Downlines						BIT	= 1
			,@DisableDowlines				BIT = 0
			,@DisableGoldDeluxe				BIT

	SELECT	@DisableAutoMPT = DisableAutoMPT
	FROM	custmaster WITH(NOLOCK)
	WHERE	custid = @mrecommend
			
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 1)
		SET @Downlines = 0	-- dont have any downlines
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 1 AND DisableGoldDeluxe = 1)
		SET @DisableDowlines = 1
	
	--Master Comm	
	SELECT	@v255adiscount_1701 = adiscount,
			@max_v255mpositiontaking_1701 = mpositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @mrecommend 
			AND sporttype = 255 
			AND bettype = 1701
	
	--Customer Info
	SELECT	username
			,firstname
			,lastname
			,phone
			,mobilephone
			,fax
			,ISNULL(@DisableGoldDeluxe,0)	AS DisableGoldDeluxe
			,@Downlines						AS Downlines
			,@DisableDowlines				AS DisableDowlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	  
	
	--PT & commission
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
	FROM	custsettingGame cs WITH(NOLOCK)
		INNER JOIN custoverrideGame co WITH(NOLOCK) 
			ON cs.custid = co.custid 
				AND cs.sporttype = co.sporttype 
				AND cs.bettype = co.bettype
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 255 
			AND cs.bettype = 1701
	
	-- bet setting
	EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
		@custid		= @custid
		,@UplineId	= @mrecommend

END




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentGoldDeluxe] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentGoldDeluxe] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentGoldDeluxe] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditAgentGoldDeluxe] TO [vnteam] AS [dbo]