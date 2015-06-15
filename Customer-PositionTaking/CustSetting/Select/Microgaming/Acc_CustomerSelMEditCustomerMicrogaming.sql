USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelMEditCustomerGoldDeluxe]    Script Date: 05/12/2015 17:09:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerMicrogaming]
	@custid		INT
AS
/*
	Created: 20150608@Winnie
	Task: Master select edits Microgaming PT settings on member
	DB: DBAGE/BODB02
	
	Revisions:

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AgentID							INT,
			@MasterID							INT,
			@SuperID							INT,
			@roleid								TINYINT,			
			@v203mpositiontaking_2001_max		SMALLMONEY,
			@v203mpositiontaking_2001_min		SMALLMONEY,
			@max_v203spositiontaking_2001		SMALLMONEY,	
			@v203mpositiontaking_2005_max		SMALLMONEY,
			@v203mpositiontaking_2005_min		SMALLMONEY,
			@max_v203spositiontaking_2005		SMALLMONEY,	
	
			@DisableMicrogame					BIT,
			@DisableUpline						BIT

	SELECT	@AgentID = recommend,
			@MasterID = mrecommend,
			@SuperId = srecommend,
			@roleid	 = roleid,
			@DisableMicrogame = DisableMicrogame
	FROM	custinfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	IF @roleid <> 1
		RETURN
		
	SELECT	@DisableUpline = DisableMicrogame
	FROM	custinfo WITH(NOLOCK)
	WHERE	custid = @AgentID

	-- get is master auto on agent
	
	SELECT	@v203mpositiontaking_2001_max = mpositiontaking
	FROM	Dep_CustSettingGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	@v203mpositiontaking_2005_max = mpositiontaking
	FROM	Dep_CustSettingGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
			AND sporttype = 203
			AND bettype = 2005

	SELECT	@max_v203spositiontaking_2001 = spositiontaking
	FROM	Dep_custsettingGame WITH(NOLOCK)
	WHERE	custid = @SuperID 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	@max_v203spositiontaking_2005 = spositiontaking
	FROM	Dep_custsettingGame WITH(NOLOCK)
	WHERE	custid = @SuperID 
			AND sporttype = 203
			AND bettype = 2005

	SELECT	@v203mpositiontaking_2001_min = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
			AND sporttype = 203
			AND bettype = 2001		

	SELECT	@v203mpositiontaking_2005_min = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @MasterID 
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
			,@DisableUpline		AS DisableUpline
			,ISNULL(@DisableMicrogame,0) AS DisableMicrogame
			,0 AS Downlines
			,0 AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID  
	
	--PT 
	SELECT 	
			
			mpositiontaking AS v203mpositiontaking_2001,
			apositiontaking	AS V203apositiontaking_2001,
			
			@v203mpositiontaking_2001_max AS auto_v203mpositiontaking_2001_max,
			
			--m1_max = m3 - a1
			@v203mpositiontaking_2001_max - apositiontaking AS v203mpositiontaking_2001_max,

			CASE WHEN @v203mpositiontaking_2001_min - apositiontaking < 0 THEN 0 ELSE @v203mpositiontaking_2001_min - apositiontaking END AS v203mpositiontaking_2001_min
	FROM	Dep_CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001

		SELECT 	
			
			mpositiontaking AS v203mpositiontaking_2005,
			apositiontaking	AS V203apositiontaking_2005,
			
			@v203mpositiontaking_2005_max AS auto_v203mpositiontaking_2005_max,
			
			--m1_max = m3 - a1
			@v203mpositiontaking_2005_max - apositiontaking AS v203mpositiontaking_2005_max,

			CASE WHEN @v203mpositiontaking_2005_min - apositiontaking < 0 THEN 0 ELSE @v203mpositiontaking_2005_min - apositiontaking END AS v203mpositiontaking_2005_min
	FROM	Dep_CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2005
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerMicrogaming] TO [vnteam] AS [dbo]