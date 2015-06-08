USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditSuperGoldDeluxe]    Script Date: 05/12/2015 16:58:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE[dbo].[Acc_CustomerSelEditSuperMicrogaming]    
	@custid  INT    
AS    
 /*    
  Created: Winnie
  Date: 20150608    
  Task: Company edits super's Microgaming setting    
  DB: DBAGE.BODB02    
      
  Revisions:    
  
  Parameters Explanations:    
       
 */    
BEGIN
		
	SET NOCOUNT ON    
	    
	DECLARE @min_spositiontaking2001	SMALLMONEY   
			,@min_spositiontaking2005	SMALLMONEY   
			,@Downlines					BIT	= 1
			,@DisableDownlines			BIT = 0
			,@DisableMicrogame			BIT 
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)
		SET @Downlines = 0	
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND roleid = 3 AND DisableMicrogame = 1)
		SET @DisableMicrogame = 1
		
	SELECT	@DisableMicrogame = [DisableMicrogame]
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	    
	SELECT	@min_spositiontaking2001 = minpositiontaking    
	FROM	CustOverrideGame WITH(NOLOCK)    
	WHERE	custid = @custid 
			AND sporttype = 203
			AND bettype = 2001 
	SELECT	@min_spositiontaking2005 = minpositiontaking    
	FROM	CustOverrideGame WITH(NOLOCK)    
	WHERE	custid = @custid 
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
			,0								AS DisableUpline
			,ISNULL(@DisableMicrogame,0)	AS DisableMicrogame
			,@Downlines						AS Downlines
			,@DisableDownlines				AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	    
	     
	 --PT & commission
	 SELECT	ISNULL(@min_spositiontaking2001,0)	AS v203spositiontaking_2001_min,    
		    gs.MaxPositiontaking				AS v203spositiontaking_2001_max,    
		    cs.spositiontaking					AS v203spositiontaking_2001,    
		    cs.sdiscount						AS v203sdiscount_2001,    
		    gs.Maxsdiscount						AS v203sdicount_2001_max    
	 FROM	CustSettingGame cs WITH(NOLOCK)
	 INNER JOIN ProductGlobalSetting gs
		ON	gs.Sporttype =  cs.Sporttype 
			AND gs.IsDep = 1
	 WHERE custid = @custid 
			AND cs.sporttype = 203 
			AND cs.bettype = 2001    
	
	SELECT	ISNULL(@min_spositiontaking2005,0)	AS v203spositiontaking_2005_min,    
	gs.MaxPositiontaking				AS v203spositiontaking_2005_max,    
	cs.spositiontaking					AS v203spositiontaking_2005,    
	cs.sdiscount						AS v203sdiscount_2005,    
	gs.Maxsdiscount						AS v203sdicount_2005_max    
	 FROM	CustSettingGame cs WITH(NOLOCK)
	 INNER JOIN ProductGlobalSetting gs
		ON	gs.Sporttype =  cs.Sporttype 
			AND gs.IsDep = 1
	 WHERE custid = @custid 
			AND cs.sporttype = 203 
			AND cs.bettype = 2005	

		
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperMicrogaming] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperMicrogaming] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperMicrogaming] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperMicrogaming] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperMicrogaming] TO [vnteam] AS [dbo]