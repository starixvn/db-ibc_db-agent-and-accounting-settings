USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelSEditCustomer]    Script Date: 02/26/2008 02:17:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerFI]
	@CustId int,
	@SRecommend int
AS

/*
Created: 
Task : SUPER EDIT MASTER
DB: DB05.bodb02

Revisions:
    - 20090317@Phuc: disable FI, HR 	
	- 20090336@PhuongDoan: remove '_1' in SP name
	- 20090407@Lee: add 2 return fields for casino
Param's Explanation:
• @CustID: master ID
  @SRecommend
*/
SET NOCOUNT ON

declare 
	@v201mspositiontaking_3_max smallmoney, ---v201
	@v201mspositiontaking_2_max smallmoney, ---v201

	@v201mspositiontaking_3_min smallmoney, --v201
	@v201mspositiontaking_2_min smallmoney, --v201
	
	@v201mpositiontaking_3_max smallmoney, --v201
	@v201mpositiontaking_2_max smallmoney, --v201
	----------------------------------
	@disFc decimal(9,8)
Declare 
	@MinBetv201_Max money, --v201
	@MaxBetv201_Min money,		
	@MaxPerMatchv201_Min money,	
	@MaxPerMatchv201_Max money,
	
	@SDisableFinancial bit,
	@DisableFI bit, @ADisableFI bit, @ADisableHR bit 
	

-----------------------------------
Select 
	@MinBetv201_Max = MinBet,
	@MaxBetv201_Min = MaxBet
from 
	custsetting as cs WITH (NOLOCK)
where cs.custid = @SRecommend and cs.bettype =  3 and cs.sporttype=201

Select 
	@MaxPerMatchv201_Min = 0, ---v201
	@MaxPerMatchv201_Max = MaxPerMatch201
from 
	custinfo as ci WITH (NOLOCK) 
where ci.custid = @SRecommend


Select
	--get @mpt_max = m4
	@v201mpositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=201 then cs.mpositiontaking else 0 end),--v201	
	@v201mpositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=201 then cs.mpositiontaking else 0 end),--v201	
	-------------------------------------
	--get @mspt_max = min(s4, l4)
	@v201mspositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=201 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end), ---v201
	@v201mspositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=201 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end), ---v201

	@v201mspositiontaking_3_min = max(case when co.bettype = 3 and co.sporttype=201 then co.minpositiontaking else 0 end),	---v201
	@v201mspositiontaking_2_min = max(case when co.bettype = 2 and co.sporttype=201 then co.minpositiontaking else 0 end),	---v201

	@disFc = max(case when cs.bettype = 3 and cs.sporttype=201 then cs.sdiscount else 0 end)
From 
	CustSetting as cs with (NOLOCK)
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @srecommend

select @DisableFI = isnull(DisableFinancial,0) from custinfo with (NOLOCK) WHERE custid = @custid
select top 1 @ADisableFI = DisableFinancial from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and disablefinancial = 1

select 
	isnull(@SDisableFinancial,0) as SDisableFinancial,
	isnull(@DisableFI,0) as DisableFinancial,
	isnull(@ADisableFI,0) as ADisableFinancial,
	c.firstname, c.lastname, c.roleid, c.username,
	exchange.minbet AS defaultminbet, isnull(c.phone, '') as phone, isnull(c.mobilephone, '') as mobilephone, isnull(c.email, '') as email,isnull(c.fax, '') as fax,
	ci.maxpermatch201 as maxpermatchv201,	---v201
	
	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.minbet else 0 end) as minbetv201,---v201
	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.maxbet else 0 end) as maxbetv201,

	
	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.adiscount else 0 end) as discountcsFc,

	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.spositiontaking else 0 end) as v201spositiontaking_3,	--v201
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.spositiontaking else 0 end) as v201spositiontaking_2,	--v201
	
	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,---v201	
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,---v201	

	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_3,---v201	
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_2,---v201	


	@v201mspositiontaking_3_max as v201spositiontaking_3_max,--v201
	@v201mspositiontaking_2_max as v201spositiontaking_2_max,--v201

	@v201mspositiontaking_3_max as auto_v201spositiontaking_3_max, ---v201
	@v201mspositiontaking_2_max as auto_v201spositiontaking_2_max, ---v201
	
	isnull(@MinBetv201_Max, 0) as MinBetv201_Max, ---v201
	isnull(@MaxBetv201_Min, 0) as MaxBetv201_Min,	
	isnull(@MaxPerMatchv201_Min, 0) as MaxPerMatchv201_Min,	
	isnull(@MaxPerMatchv201_Max, 0) as MaxPerMatchv201_Max,
	
	@disFc as discountcsFc_max,

	max(case when cs.bettype = 3 and cs.sporttype=201 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_3,	--v201
	max(case when cs.bettype = 2 and cs.sporttype=201 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_2,	--v201

	@v201mspositiontaking_3_max as v201mspositiontaking_3_max,
	@v201mspositiontaking_2_max as v201mspositiontaking_2_max,
	
	@v201mspositiontaking_3_min as v201mspositiontaking_3_min,
	@v201mspositiontaking_2_min as v201mspositiontaking_2_min,

	-- get n3 to check m3 > n3 on the web
	max(case when co.bettype = 3 and co.sporttype=201 then co.minpositiontaking else 0 end) as v201mpositiontaking_3_min,---v201
	max(case when co.bettype = 2 and co.sporttype=201 then co.minpositiontaking else 0 end) as v201mpositiontaking_2_min,---v201

	--get mpt_max = min(m4, l3), to check m3 <= mpt_max on the web 
	max(case when co.bettype = 3 and co.sporttype=201 then case when @v201mpositiontaking_3_max<co.maxpositiontaking then @v201mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v201mpositiontaking_3_max,---v201
	max(case when co.bettype = 2 and co.sporttype=201 then case when @v201mpositiontaking_2_max<co.maxpositiontaking then @v201mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v201mpositiontaking_2_max
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	INNER JOIN exchange with (NOLOCK) ON c.currency = exchange.exchangeid
where 
	c.roleid=3 and c.custid=@CustID and
	c.srecommend=@SRecommend
group by 
	c.firstname, c.lastname, c.roleid, c.username,
	exchange.minbet, c.phone, c.mobilephone, c.email,c.fax,
	ci.maxpermatch201
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerFI] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerFI] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerFI] TO [bodbDownlineNetView]
