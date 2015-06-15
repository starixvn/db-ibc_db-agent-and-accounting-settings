CREATE PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerMicrogaming]
	@custid		INT
AS
/*
	Created: Winnie
	Date: 20150608
	Task: Super edits Microgaming settings on member
	DB: BDAGE/BODB02
		
	Revisions:
		
	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE 	
		@v203spositiontaking_2001			SMALLMONEY,--s4
		@v203spositiontaking_2001_min		SMALLMONEY,--n4
		@v203mpositiontaking_2001			SMALLMONEY,--m3
		@isauto_v203spositiontaking_2001	BIT,--i3
		@v203spositiontaking_2005			SMALLMONEY,--s4
		@v203spositiontaking_2005_min		SMALLMONEY,--n4
		@v203mpositiontaking_2005			SMALLMONEY,--m3
		@isauto_v203spositiontaking_2005	BIT,--i3
		@srecommend							INT, 
		@mrecommend							INT,
		@recommend							INT,
		@DisableMicrogame					BIT,
		@DisableUpline						BIT

	SELECT	@srecommend = srecommend
			,@mrecommend = mrecommend 
			,@recommend = recommend
			,@DisableMicrogame = DisableMicrogame
	FROM	CustInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableMicrogame
	FROM	CustInfo WITH(NOLOCK)
	WHERE	custid = @recommend

	--s4
	SELECT	@v203spositiontaking_2001 = spositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2001
	SELECT	@v203spositiontaking_2005 = spositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2005

	--n4
	SELECT	@v203spositiontaking_2001_min = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)	
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	@v203spositiontaking_2005_min = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)	
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2005

	--i3,m3
	SELECT	@v203mpositiontaking_2001 = mpositiontaking		
			,@isauto_v203spositiontaking_2001 = isautopositiontaking
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @mrecommend 
			AND sporttype = 203
			AND bettype = 2001 

	SELECT	@v203mpositiontaking_2005 = mpositiontaking		
			,@isauto_v203spositiontaking_2005 = isautopositiontaking
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
			,@DisableUpline				AS DisableUpline
			,ISNULL(@DisableMicrogame,0) AS DisableMicrogame
			,0 AS Downlines
			,0 AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	 

	--PT 
	SELECT	spositiontaking as v203spositiontaking_2001,
			mpositiontaking as v203mpositiontaking_2001,
			apositiontaking as v203apositiontaking_2001,
			autopositiontaking as auto_v203spositiontaking_2001_mem,	
			isautopositiontaking as isauto_v203spositiontaking_2001_mem,
			ISNULL(@isauto_v203spositiontaking_2001,0) as isauto_v203spositiontaking_2001, -- i3
			ISNULL(@v203spositiontaking_2001,0) as auto_v203spositiontaking_2001_max,
			--s1_max= Max(n4-(m1+a1), s4 - m3)
			CASE WHEN @v203spositiontaking_2001_min - (mpositiontaking+apositiontaking) > ISNULL(@v203spositiontaking_2001,0) - ISNULL(@v203mpositiontaking_2001,0) THEN @v203spositiontaking_2001_min - (mpositiontaking+apositiontaking) 
			ELSE ISNULL(@v203spositiontaking_2001,0) - ISNULL(@v203mpositiontaking_2001,0) END AS v203spositiontaking_2001_max,
			-- s1_min 
			CASE WHEN ISNULL(@v203spositiontaking_2001_min,0) - (mpositiontaking + apositiontaking) > 0 THEN ISNULL(@v203spositiontaking_2001_min,0) - (mpositiontaking + apositiontaking) ELSE 0 END v203spositiontaking_2001_min	
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	spositiontaking as v203spositiontaking_2005,
			mpositiontaking as v203mpositiontaking_2005,
			apositiontaking as v203apositiontaking_2005,
			autopositiontaking as auto_v203spositiontaking_2005_mem,	
			isautopositiontaking as isauto_v203spositiontaking_2005_mem,
			ISNULL(@isauto_v203spositiontaking_2005,0) as isauto_v203spositiontaking_2005, -- i3
			ISNULL(@v203spositiontaking_2005,0) as auto_v203spositiontaking_2005_max,
			--s1_max= Max(n4-(m1+a1), s4 - m3)
			CASE WHEN @v203spositiontaking_2005_min - (mpositiontaking+apositiontaking) > ISNULL(@v203spositiontaking_2005,0) - ISNULL(@v203mpositiontaking_2005,0) THEN @v203spositiontaking_2005_min - (mpositiontaking+apositiontaking) 
			ELSE ISNULL(@v203spositiontaking_2005,0) - ISNULL(@v203mpositiontaking_2005,0) END AS v203spositiontaking_2005_max,
			-- s1_min 
			CASE WHEN ISNULL(@v203spositiontaking_2005_min,0) - (mpositiontaking + apositiontaking) > 0 THEN ISNULL(@v203spositiontaking_2005_min,0) - (mpositiontaking + apositiontaking) ELSE 0 END v203spositiontaking_2005_min	
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2005
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSEditCustomerMicrogaming] TO [vnteam] AS [dbo]