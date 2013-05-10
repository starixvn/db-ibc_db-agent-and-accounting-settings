ALTER PROCEDURE [dbo].[Acc_CustomerSelFIEditCustomer_SAg]
	@CustId int,
	@SRecommend int
AS

/*
Created by: Phuong Dao 
Date: 2009-04-16 
Task : SUPER EDIT MASTER for Finance 
DB: DB05.bodb02
Orginal: Acc_CustomerSelSEditCustomer

Revisions:
	- 20090701@Phuc: allow super disable auto MPT.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
Param's Explanation:
• @CustID: master ID
  @SRecommend
*/
SET NOCOUNT ON

DECLARE 
	---Finance 
	@v201mspositiontaking_3_max smallmoney, ---v201
	@v201mspositiontaking_2_max smallmoney, ---v201
	@v201mspositiontaking_3_min smallmoney, --v201
	@v201mspositiontaking_2_min smallmoney, --v201

	--Declare @mpt_max = m4
	@v201mpositiontaking_3_max smallmoney, --v201
	@v201mpositiontaking_2_max smallmoney, --v201
	
	----------------------------------
	@disFc decimal(9,8),

	@MinBetv201_Max money, --v201
	@MaxBetv201_Min money,		
	@MaxPerMatchv201_Min money,	
	@MaxPerMatchv201_Max money,

	@UplineDisableFI bit,
	@DisableFI bit, 
	@DownlineDisableFI bit,
	@DisableAutoMPT bit
-----------------------------------
Select 
	@MinBetv201_Max = MinBet,
	@MaxBetv201_Min = MaxBet
from 
	CustSetting3rd as cs WITH (NOLOCK)
where cs.custid = @SRecommend and cs.bettype =  3 and cs.sporttype=201

/*
--Revert MPM
Select 	
	@MaxPerMatch_Max = isnull(max(isnull(sci.MaxPerMatch, 0)), 0) - isnull(sum(ci.MaxPerMatch), 0),
	@MaxPerMatchv2_Max = isnull(max(isnull(sci.MaxPerMatchv2, 0)), 0) - isnull(sum(ci.MaxPerMatchv2), 0)
from 
	custinfo as sci WITH (NOLOCK) 
	LEFT JOIN custinfo as ci WITH (NOLOCK) on (sci.CustID = ci.sRecommend)  and ci.custid<>@custid and ci.roleid=3
where sci.custid=@srecommend


Select 	
	@MaxPerMatch_Min = sum(ci.maxpermatch), 
	@MaxPerMatchv2_Min = sum(ci.MaxPerMatchv2)
from 
	custinfo as ci WITH (NOLOCK) 
where ci.mrecommend=@custid and ci.roleid=2
*/
Select 
	@MaxPerMatchv201_Min = 0, ---v201
	@MaxPerMatchv201_Max = MaxPerMatch201
from 
	custinfo as ci WITH (NOLOCK) 
where ci.custid = @SRecommend

Select
	--get @mpt_max = m4
	@v201mpositiontaking_3_max = max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end),--v201	
	@v201mpositiontaking_2_max = max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end),--v201

	-------------------------------------
	--get @mspt_max = min(s4, l4)
	@v201mspositiontaking_3_max = max(case when cs.bettype = 3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end), ---v201
	@v201mspositiontaking_2_max = max(case when cs.bettype = 2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end), ---v201
	
	@v201mspositiontaking_3_min = max(case when co.bettype = 3 then co.minpositiontaking else 0 end),	---v201
	@v201mspositiontaking_2_min = max(case when co.bettype = 2 then co.minpositiontaking else 0 end),	---v201

	@disFc = max(case when cs.bettype = 3 then cs.sdiscount else 0 end)	
From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @srecommend AND co.sporttype = 201 

select @UplineDisableFI = DisableFinancial from custinfo with (NOLOCK) where custid = @srecommend
select @DisableFI = isnull(DisableFinancial,0) from custinfo with (NOLOCK) WHERE custid = @custid
select top 1 @DownlineDisableFI = DisableFinancial from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and disablefinancial = 1
--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @CustID

select 
	isnull(@UplineDisableFI,0) as UplineDisableFI,
	isnull(@DisableFI,0) as DisableFinancial,
	isnull(@DownlineDisableFI,0) as DownlineDisableFI,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	c.firstname, 
	c.lastname, 
	c.roleid, c.username,
	isnull(c.phone, '') as phone, 
	isnull(c.mobilephone, '') as mobilephone, 
	isnull(c.fax, '') as fax,
	ci.maxpermatch201 as maxpermatchv201,	---v201
	ci.credit,
	
	max(case when cs.bettype = 3 then cs.minbet else 0 end) as minbetv201,---v201
	max(case when cs.bettype = 3 then cs.maxbet else 0 end) as maxbetv201,

	max(case when cs.bettype = 3 then cs.adiscount else 0 end) as v201discount,
	@disFc as v201discount_max,

	max(case when cs.bettype = 3 then cs.spositiontaking else 0 end) as v201spositiontaking_3,	--v201
	max(case when cs.bettype = 2 then cs.spositiontaking else 0 end) as v201spositiontaking_2,	--v201
	
	max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,---v201	
	max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,---v201	

	max(case when cs.bettype = 3 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_3,---v201	
	max(case when cs.bettype = 2 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_2,---v201	

	@v201mspositiontaking_3_max as v201spositiontaking_3_max,--v201
	@v201mspositiontaking_2_max as v201spositiontaking_2_max,--v201
	
	@v201mspositiontaking_3_max as auto_v201spositiontaking_3_max, ---v201
	@v201mspositiontaking_2_max as auto_v201spositiontaking_2_max, ---v201
	
	isnull(@MinBetv201_Max, 0) as MinBetv201_Max, ---v201
	isnull(@MaxBetv201_Min, 0) as MaxBetv201_Min,	
	isnull(@MaxPerMatchv201_Min, 0) as MaxPerMatchv201_Min,	
	isnull(@MaxPerMatchv201_Max, 0) as MaxPerMatchv201_Max,
	
	max(case when cs.bettype = 3 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_3,	--v201
	max(case when cs.bettype = 2 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_2,	--v201

	@v201mspositiontaking_3_max as v201mspositiontaking_3_max,
	@v201mspositiontaking_2_max as v201mspositiontaking_2_max,
	
	@v201mspositiontaking_3_min as v201mspositiontaking_3_min,
	@v201mspositiontaking_2_min as v201mspositiontaking_2_min,

	-- get n3 to check m3 > n3 on the web

	max(case when co.bettype = 3 then co.minpositiontaking else 0 end) as v201mpositiontaking_3_min,---v201
	max(case when co.bettype = 2 then co.minpositiontaking else 0 end) as v201mpositiontaking_2_min,---v201

	--get mpt_max = min(m4, l3), to check m3 <= mpt_max on the web 
	max(case when co.bettype = 3 then case when @v201mpositiontaking_3_max<co.maxpositiontaking then @v201mpositiontaking_3_max else co.maxpositiontaking end else 0 end) as v201mpositiontaking_3_max,---v201
	max(case when co.bettype = 2 then case when @v201mpositiontaking_2_max<co.maxpositiontaking then @v201mpositiontaking_2_max else co.maxpositiontaking end else 0 end) as v201mpositiontaking_2_max ---v201

---------------------------------------------------------------------
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype

where 
	c.roleid=3 and c.custid=@CustID and
	c.srecommend=@SRecommend and co.sporttype = 201
group by 
	ci.closed, 
	ci.reject,
	c.firstname, c.lastname, c.roleid, c.username,
	c.phone, c.mobilephone, c.email,c.fax,
	ci.maxpermatch201,
	ci.credit

GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_SAg] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_SAg] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_SAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditCustomer_SAg] TO vnteam
