USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditMemberGoldDeluxe]    Script Date: 05/12/2015 17:06:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Acc_CustomerSelEditMemberMicrogaming]
	@custid		INT,
	@recommend	INT
AS
/*
	Created: 20150608@Winnie
	Task: Agent edits member's Microgaming setting
	DB: DBAGE/BODB02
	
	Revisions:
	
	Parameters Explanation
*/
BEGIN

	SET NOCOUNT ON
		
	DECLARE @roleID INT 

		-- Check Downline Belonging
	EXEC dbo.Age_CustomerSelCheckBelonging  
			@SessionCustID	= @recommend, 
			@Custid			= @CustID,
			@roleID			= @roleID OUTPUT

	IF @roleID = 0
		RETURN

	DECLARE @srecommend 					INT,
			@mrecommend 					INT,
			@max_V203apositiontaking_2001	SMALLMONEY,
			@min_v203apositiontaking_2001	SMALLMONEY,
			@v203discount_2001				DECIMAL(9,8),
			@max_V203apositiontaking_2005	SMALLMONEY,
			@min_v203apositiontaking_2005	SMALLMONEY,
			@v203discount_2005				DECIMAL(9,8),
			
			@v203spt_2001					SMALLMONEY,
			@cs_v203apt_2001				SMALLMONEY,
			@v203spt_2005					SMALLMONEY,
			@cs_v203apt_2005				SMALLMONEY,
			@DisableMicrogame				BIT,
			@DisableUpline					BIT
			
	SELECT	@srecommend = srecommend 
			,@mrecommend = mrecommend 
			,@DisableMicrogame = DisableMicrogame
	FROM	dbo.CustInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableMicrogame
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @recommend
	
	--
	SELECT	@max_V203apositiontaking_2001 = apositiontaking			
	FROM	dbo.custsettingGame WITH(NOLOCK)
	WHERE	custid = @recommend 
			AND sporttype = 203
			AND bettype = 2001
	SELECT	@max_V203apositiontaking_2005 = apositiontaking			
	FROM	dbo.custsettingGame WITH(NOLOCK)
	WHERE	custid = @recommend 
			AND sporttype = 203
			AND bettype = 2005

	SELECT	@min_v203apositiontaking_2001 = minpositiontaking
	FROM	dbo.CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @recommend 
			AND sporttype = 203 
			AND bettype = 2001
	SELECT	@min_v203apositiontaking_2005 = minpositiontaking
	FROM	dbo.CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @recommend 
			AND sporttype = 203 
			AND bettype = 2005
	
	--s4
	SELECT	@v203spt_2001 = spositiontaking
	FROM	dbo.CustSettingGame WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2001
	SELECT	@v203spt_2005 = spositiontaking
	FROM	dbo.CustSettingGame WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2005

	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	SELECT	@cs_v203apt_2001 = CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
									ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
												ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= @v203spt_2001-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v203spt_2001-cs.spositiontaking-cs.mpositiontaking END
											END
										 END 
	FROM	CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) 
			ON	mcs.custid = @mrecommend 
				AND mcs.sporttype = cs.sporttype 
				AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) 
			ON acs.custid = @recommend 
				AND acs.sporttype = cs.sporttype 
				AND acs.bettype = cs.bettype 
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 203
			AND cs.bettype = 2001
	
	SELECT @max_v203apositiontaking_2001 = CASE WHEN @max_v203apositiontaking_2001 <= @cs_v203apt_2001 THEN @max_v203apositiontaking_2001 ELSE @cs_v203apt_2001 END

	--2005
	SELECT	@cs_v203apt_2005 = CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
									ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
												ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= @v203spt_2005-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v203spt_2005-cs.spositiontaking-cs.mpositiontaking END
											END
										 END 
	FROM	CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) 
			ON	mcs.custid = @mrecommend 
				AND mcs.sporttype = cs.sporttype 
				AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) 
			ON acs.custid = @recommend 
				AND acs.sporttype = cs.sporttype 
				AND acs.bettype = cs.bettype 
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 203
			AND cs.bettype = 2005
	
	SELECT @max_v203apositiontaking_2005 = CASE WHEN @max_v203apositiontaking_2005 <= @cs_v203apt_2005 THEN @max_v203apositiontaking_2005 ELSE @cs_v203apt_2005 END
		
		
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
			,0								AS Downlines
			,0								AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	  
	
	--PT & commission
	SELECT		
			apositiontaking AS v203apositiontaking_2001,
			@max_V203apositiontaking_2001 AS v203apositiontaking_2001_max,
			@min_v203apositiontaking_2001 AS v203apositiontaking_2001_min,

			playerdiscount	AS v203playerdiscount_2001,
			@v203discount_2001 AS v203playerdiscount_2001_max
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001	

	SELECT		
			apositiontaking AS v203apositiontaking_2005,
			@max_V203apositiontaking_2005 AS v203apositiontaking_2005_max,
			@min_v203apositiontaking_2005 AS v203apositiontaking_2005_min,

			playerdiscount	AS v203playerdiscount_2005,
			@v203discount_2005 AS v203playerdiscount_2005_max
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2005	

END
/*
exec [dbo].[[Acc_CustomerSelEditMemberMicrogaming]] @custid = 642719,@recommend = 642706
*/

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMemberMicrogaming] TO [vnteam] AS [dbo]