ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperVS]
	@custid		INT
AS
	/*
		Created: Dan
		Date: 09Aug2012
		Task: Company edits super's virtual soccer setting
		DB: DB053.BODB02
		
		Revisions:
			- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
			-20130220@Johnson: get virtual horse racing setting (sporttype : 181, bettype: 1231)								
		Parameters Explanations:
			
	*/
SET NOCOUNT ON

DECLARE 
	@downlines				BIT,	
	@DisableDownlinesVirtualSports		BIT,
	@DisableVirtualSports	BIT,
	@HideVirtualSports		BIT,
	@maxpermatch180_min		MONEY,
	@MaxPerMatch180			MONEY,
	@maxpermatch181_min		MONEY,
	@MaxPerMatch181		 	MONEY,
	@maxpermatch186_min		MONEY,
	@MaxPerMatch186			MONEY

SELECT @downlines = CASE WHEN EXISTS(SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE srecommend = @custid and roleid = 3) THEN 1 ELSE 0 END

SELECT TOP 1 @DisableDownlinesVirtualSports = ISNULL(DisableVirtualSports,0) 
FROM custinfo WITH (NOLOCK) 
WHERE srecommend = @custid and roleid = 3 and DisableVirtualSports = 1
	
--to facilitate in Web Interface
Select 	@MaxPerMatch180_Min = 0, @MaxPerMatch181_Min = 0, @maxpermatch186_min = 0

SELECT @DisableVirtualSports	= ISNULL(DisableVirtualSports,0),
		@HideVirtualSports		= ISNULL(HideVirtualSports,0) ,
		@MaxPerMatch180			= MaxPerMatch180,
		@MaxPerMatch181			= MaxPerMatch181,
		@MaxPerMatch186			= MaxPerMatch186
FROM custinfo WITH(NOLOCK)
WHERE custid = @custid

-- CUSTOMER
SELECT	c.username, 
		c.username2, 
		c.firstname,
		c.lastname,
		c.phone,
		c.mobilephone,
		c.email,
		c.fax,				
		@DisableVirtualSports as DisableVirtualSports,
		@HideVirtualSports as HideVirtualSports,
		CASE WHEN @downlines = 0 then @DisableVirtualSports ELSE ISNULL(@DisableDownlinesVirtualSports,0) END AS DisableDownlinesVirtualSports		
FROM	Customer c WITH (NOLOCK)		
WHERE	c.custID = @CustID 

-- bet setting
SELECT
		cs.sporttype,
		cs.bettype,
		cs.minbet, 
		cs.maxbet,

		CASE cs.sporttype WHEN 180 then @MaxPerMatch180 
							WHEN 181 then @MaxPerMatch181
							WHEN 186 then @MaxPerMatch186 END AS MaxPerMatch,
		CASE cs.sporttype WHEN 180 then @MaxPerMatch180_Min 
							WHEN 181 then @MaxPerMatch181_Min 
							WHEN 186 then @MaxPerMatch186_Min END AS MaxPerMatch_Min,
		
		cs.spositiontaking as s4,
		cs.mpositiontaking as m4,
		cs.apositiontaking as a4,
		co.minpositiontaking as n4
		--0.9 as s4_max		
FROM dbo.CustSetting3rd AS cs WITH (NOLOCK) 
	JOIN dbo.custOverride3rd AS co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
WHERE cs.custid = @custId AND cs.sporttype in (180,181,186) AND cs.bettype in (1201 , 1231, 1220)

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditSuperVS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperVS] TO [bodbExtAccNet]