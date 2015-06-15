USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditAgentGoldDeluxe]    Script Date: 05/12/2015 17:03:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Acc_CustomerSelEditAgentMicrogaming]
	@custid		INT,
	@mrecommend INT
AS
/*
	Created: 20150608@Winnie
	Task: Master edits agent's Microgaming setting
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

	DECLARE 
			 @DisableAutoMPT				BIT
			,@max_v203mpositiontaking_2001 SMALLMONEY
			,@max_v203mpositiontaking_2005 SMALLMONEY
			,@Downlines						BIT	= 1
			,@DisableDownlines				BIT = 0
			,@DisableMicrogame				BIT
			,@DisableUpline					BIT = 0

	SELECT	@DisableAutoMPT = DisableAutoMPT
	FROM	custmaster WITH(NOLOCK)
	WHERE	custid = @mrecommend
			
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid = 1)
		SET @Downlines = 0	-- dont have any downlines
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND roleid = 1 AND DisableMicrogame = 1)
		SET @DisableDownlines = 1
	
	SELECT	@DisableMicrogame = DisableMicrogame
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableMicrogame
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @mrecommend
	
	--Master Comm	
	SELECT	@max_v203mpositiontaking_2001 = mpositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @mrecommend 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	@max_v203mpositiontaking_2005 = mpositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @mrecommend 
			AND sporttype = 203
			AND bettype = 2005
	
	--Customer Info
	SELECT	username
			,username2 AS nickname
			,firstname
			,lastname
			,phone
			,mobilephone
			,fax
			,@DisableUpline					AS DisableUpline
			,ISNULL(@DisableMicrogame,0)	AS DisableMicrogame
			,@Downlines						AS Downlines
			,@DisableDownlines				AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	  
	
	--PT
	SELECT 	
			ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,	
			--a2
			apositiontaking AS v203apositiontaking_2001,		
			--m2		
			mpositiontaking AS v203mpositiontaking_2001,
			@max_v203mpositiontaking_2001 AS v203mpositiontaking_2001_max,
			--u2
			autompositiontaking AS auto_v203mpositiontaking_2001,		
			--i2
			isautompositiontaking AS isauto_v203mpositiontaking_2001,		
			--u2_max
			@max_v203mpositiontaking_2001 AS auto_v203mpositiontaking_2001_max,			
			--n2
			co.minpositiontaking as v203apositiontaking_2001_min	
	FROM	custsettingGame cs WITH(NOLOCK)
		INNER JOIN custoverrideGame co WITH(NOLOCK) 
			ON cs.custid = co.custid 
				AND cs.sporttype = co.sporttype 
				AND cs.bettype = co.bettype
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 203
			AND cs.bettype = 2001

	SELECT 	
			ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,	
			--a2
			apositiontaking AS v203apositiontaking_2005,		
			--m2		
			mpositiontaking AS v203mpositiontaking_2005,
			@max_v203mpositiontaking_2005 AS v203mpositiontaking_2005_max,
			--u2
			autompositiontaking AS auto_v203mpositiontaking_2005,		
			--i2
			isautompositiontaking AS isauto_v203mpositiontaking_2005,		
			--u2_max
			@max_v203mpositiontaking_2005 AS auto_v203mpositiontaking_2005_max,			
			--n2
			co.minpositiontaking as v203apositiontaking_2005_min	
	FROM	custsettingGame cs WITH(NOLOCK)
		INNER JOIN custoverrideGame co WITH(NOLOCK) 
			ON cs.custid = co.custid 
				AND cs.sporttype = co.sporttype 
				AND cs.bettype = co.bettype
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 203
			AND cs.bettype = 2005


END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditAgentMicrogaming] TO [vnteam] AS [dbo]