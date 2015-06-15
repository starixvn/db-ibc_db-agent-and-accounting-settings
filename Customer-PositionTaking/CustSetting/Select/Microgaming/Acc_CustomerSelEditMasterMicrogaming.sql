USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditMasterGoldDeluxe]    Script Date: 05/12/2015 17:01:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Acc_CustomerSelEditMasterMicrogaming]
	@custid INT,
	@srecommend INT
AS
	/*
		Created: Winnie
		Date: 20150608
		Task: Super edits master's Microgaming setting
		DB: DBAGE.BODB02
		
		Revisions:
		
		Parameters Explanation
	*/
BEGIN
	SET NOCOUNT ON
		
	DECLARE	@min_mpositiontaking2001	SMALLMONEY
			,@min_mpositiontaking2005	SMALLMONEY
			,@max_spositiontaking2001	SMALLMONEY
			,@max_spositiontaking2005	SMALLMONEY
			,@DisableAutoMPT			BIT
			,@Downlines					BIT	= 1
			,@DisableDownlines			BIT = 0
			,@DisableMicrogame			BIT
			,@DisableUpline				BIT = 0
			
	--Disable auto master PT
	SELECT	@DisableAutoMPT = DisableAutoMPT 
	FROM	CustMaster WITH(NOLOCK) 
	WHERE	CustID = @custid
			
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 2)
		SET @Downlines = 0	-- dont have any downlines
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND DisableMicrogame = 1)
		SET @DisableDownlines = 1
		
	SELECT	@DisableMicrogame = DisableMicrogame
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableMicrogame
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @srecommend

	SELECT	@min_mpositiontaking2001 = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001
	
	SELECT	@min_mpositiontaking2005 = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2005

	SELECT	@max_spositiontaking2001 = spositiontaking			
	FROM	CustSettingGame cs WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	@max_spositiontaking2005 = spositiontaking			
	FROM	CustSettingGame cs WITH(NOLOCK)
	WHERE	custid = @srecommend 
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
	
	 --PT & commission
	SELECT	ISNULL(@DisableAutoMPT,0)		AS DisableAutoMPT, 
			isautopositiontaking			AS isauto_v203spositiontaking_2001, --i3
			autopositiontaking				AS auto_v203spostiontaking_2001,--u3
			spositiontaking					AS v203spositiontaking_2001,--s3
			mpositiontaking					AS v203mpositiontaking_2001,--m3				
			ISNULL(@max_spositiontaking2001,0)	AS v203spositiontaking_2001_max,--s4
			ISNULL(@min_mpositiontaking2001,0)	AS  v203mpositiontaking_2001_min,--n3	
			ISNULL(@max_spositiontaking2001,0)	AS auto_v203spositiontaking_2001_max--u3_max	
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001

	SELECT	ISNULL(@DisableAutoMPT,0)		AS DisableAutoMPT, 
			isautopositiontaking			AS isauto_v203spositiontaking_2005, --i3
			autopositiontaking				AS auto_v203spostiontaking_2005,--u3
			spositiontaking					AS v203spositiontaking_2005,--s3
			mpositiontaking					AS v203mpositiontaking_2005,--m3				
			ISNULL(@max_spositiontaking2005,0)	AS v203spositiontaking_2005_max,--s4
			ISNULL(@min_mpositiontaking2005,0)	AS  v203mpositiontaking_2005_min,--n3	
			ISNULL(@max_spositiontaking2005,0)	AS auto_v203spositiontaking_2005_max--u3_max	
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2005
	

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterMicrogaming] TO [vnteam] AS [dbo]