ALTER PROCEDURE[dbo].[Acc_CustomerSelEditSuperGoldDeluxe]    
	@custid  INT    
AS    
 /*    
  Created: Kathy    
  Date: 20150424    
  Task: Company edits super's live casino setting    
  DB: DBAGE.BODB02    
      
  Revisions:    
  
  Parameters Explanations:    
       
 */    
BEGIN
		
	SET NOCOUNT ON    
	    
	DECLARE @min_spositiontaking SMALLMONEY    
	    
	SELECT	@min_spositiontaking = minpositiontaking    
	FROM	CustOverrideGame WITH(NOLOCK)    
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701    	    
	     
	 SELECT	ISNULL(@min_spositiontaking,0)	AS v255spositiontaking_1701_min,    
		    gs.MaxPositiontaking			AS v255spositiontaking_1701_max,    
		    cs.spositiontaking				AS v255spositiontaking_1701,    
		    cs.sdiscount					AS v255sdiscount_1701,    
		    gs.Maxsdiscount					AS v255sdicount_1701_max    
	 FROM	CustSettingGame cs WITH(NOLOCK)
	 INNER JOIN ProductGlobalSetting gs
		ON	gs.Sporttype =  cs.Sporttype 
			AND gs.IsDep = 0
	 WHERE custid = @custid 
			AND cs.sporttype = 255 
			AND cs.bettype = 1101    
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperGoldDeluxe] TO [vnteam] AS [dbo]