ALTER PROCEDURE [dbo].[Acc_CustomerSelFIEditCustomer_Com]
	@CustId int
AS

/*
Created by: Phuong Dao
Date: 2009-04-16
Task : COMPANY EDIT SUPER for Finance 
DB: DB05.bodb02
Original: [Acc_CustomerSelCEditCustomer]

Revisions:
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
Param's Explanation:
• @CustID: super ID
*/


SET NOCOUNT ON


declare 
	@maxpermatchv201_min money, --v201
	@DownlineDisableFI bit
	
--to facilitate in Web Interface
Select 	
	@MaxPerMatchv201_Min = 0 --v201

select top 1 @DownlineDisableFI = DisableFinancial from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and disablefinancial = 1

select 
	c.firstname,
	c.lastname,
	c.username,
	isnull(c.phone,'') as phone, 
	isnull(c.mobilephone,'') as mobilephone, 
	isnull(c.fax,'') as fax,
	ci.maxpermatch201 as maxpermatchv201, --v201
	isnull(@DownlineDisableFI,0) as DownlineDisableFI, 
	isnull(ci.DisableFinancial,0) as DisableFinancial,
	max(case when cs.bettype = 3 then cs.minbet else 0 end) as minbetv201, --v201	
	max(case when cs.bettype = 3 then cs.maxbet else 0 end) as maxbetv201, --v201	

	max(case when cs.bettype = 3 then cs.sdiscount else 0 end) as v201discount, --v201
	
	--dbo.[f_Max](0.01, max(case when cs.bettype = 3 and cs.sporttype=201 then cs.sdiscount else 0 end)) as discountcsFinancial_max, --v201
	dbo.[f_Max](0.0025, max(case when cs.bettype = 3 then cs.sdiscount else 0 end)) as v201discount_max, --v201
	---------------------------------------------------------------------
	-- get n4

	--v201
	max(case when co.bettype = 3 then co.minpositiontaking else 0 end) as v201spositiontaking_3_min,
	max(case when co.bettype = 2 then co.minpositiontaking else 0 end) as v201spositiontaking_2_min,

	-- 
	--l4 = s4, so hard code to make s4_max = 0.5 with Finance 
	--v201
	0.5 as v201spositiontaking_3_max,
	0.5 as v201spositiontaking_2_max,

	--v201
	max(case when cs.bettype = 3 then cs.spositiontaking else 0 end) as v201spositiontaking_3,
	max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,
	
	max(case when cs.bettype = 2 then cs.spositiontaking else 0 end) as v201spositiontaking_2,
	max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,

	--v201 
	max(case when cs.bettype = 3 then cs.apositiontaking else 0 end) as v201apositiontaking_3,
	max(case when cs.bettype = 2 then cs.apositiontaking else 0 end) as v201apositiontaking_2,

	isnull(@maxpermatchv201_min, 0) as MaxPerMatchv201_Min --v201
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
where 
	c.roleid=4 and c.custid=@CustID AND cs.sporttype = 201 
group by 
	ci.DisableFinancial,
	c.firstname,
	c.lastname,
	c.roleid,
	c.username,
	c.phone,
	c.mobilephone,
	c.fax,
	ci.maxpermatch201
	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Com] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Com] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditCustomer_Com] TO [vnteam]