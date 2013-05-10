ALTER PROCEDURE [dbo].[Acc_CustomerSelFIEditCustomer_MAg]
	@CustId int,
	@MRecommend int
AS
/*
Created by: Phuong Dao 
Date: 2009-04-16
Task : MASTER EDIT AGENT FOR FINANCE 
DB: DB05.bodb02
Orginal: Acc_CustomerSelMEditCustomer

Revisions:
    - 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
    - 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
    - 20100729@Henry: Grant permission for bodbExtAccNet
Param's Explanation:
• @CustID: AgentID
  @MRecommend
*/

SET NOCOUNT ON

Declare 
	@MinBetv201_Max money,
	@MaxBetv201_Min money,	
	@MaxPerMatchv201_Min money,	
	@MaxPerMatchv201_Max money,
	
	@disFC decimal(9,8),
	@Msuspended bit, 
	@UplineDisableFI bit, 
	@DownlineDisableFI bit,
	@DisableAutoMPT bit

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select top 1 @DownlineDisableFI = DisableFinancial 
from custinfo with (NOLOCK) 
WHERE recommend = @custid and roleid = 1 and disablefinancial = 1

Select @UplineDisableFI = isnull(DisableFinancial,0) From custinfo (nolock) where custid = @Mrecommend

--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @Mrecommend

Select 
	@MinBetv201_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv201_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	CustSetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 3 and cs.sporttype=201
where ci.custid = @CustID


/*
--Revert MPM
Select 	
	@MaxPerMatch_Max = isnull(max(isnull(mci.MaxPerMatch, 0)), 0) - isnull(sum(ci.MaxPerMatch), 0),
	@MaxPerMatchv2_Max = isnull(max(isnull(mci.MaxPerMatchv2, 0)), 0) - isnull(sum(ci.MaxPerMatchv2), 0)
from 
	custinfo as mci WITH (NOLOCK) 
	LEFT JOIN custinfo as ci WITH (NOLOCK) on (mci.CustID = ci.mRecommend)  and ci.custid<>@custid and ci.roleid=2
where mci.custid=@mrecommend

Select 	
	@MaxPerMatch_Min = sum(ci.maxpermatch), 
	@MaxPerMatchv2_Min = sum(ci.MaxPerMatchv2)
from 
	custinfo as ci WITH (NOLOCK) 
where ci.recommend=@custid and ci.roleid=1
*/
Select
	@MaxPerMatchv201_Min = 0,
	@MaxPerMatchv201_Max = Min(case when cs.MaxPerMatch201 = 0 then NULL else cs.MaxPerMatch201 end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

select 
	@disFC = max(case when acs.bettype = 3 then acs.adiscount else 0 end)
from CustSetting3rd as acs with (NOLOCK)
where acs.custid = @MRecommend AND acs.sporttype = 201 

declare
	@max_v201mapositiontaking_3 smallmoney,
	@max_v201mapositiontaking_2 smallmoney,
	
	@min_v201mapositiontaking_3 smallmoney,	
	@min_v201mapositiontaking_2 smallmoney,	

	--Declare @apt_max = a4
	@v201apositiontaking_3_max smallmoney,	
	@v201apositiontaking_2_max smallmoney

--Get n3, l3
select @min_v201mapositiontaking_3 =minpositiontaking, @max_v201mapositiontaking_3 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=201
select @min_v201mapositiontaking_2 =minpositiontaking, @max_v201mapositiontaking_2 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=201

-------------------------------------------------------
--get @max_ma = min(l3,m3)
Select	
	@max_v201mapositiontaking_3 = max(case when cs.bettype = 3 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v201mapositiontaking_2 = max(case when cs.bettype = 2 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end)
from
	CustSetting3rd as cs with (nolock)
	inner join CustOverride3rd as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
where cs.custid = (select mrecommend from customer with (nolock) where custid = @CustID) AND mco.sporttype = 201 

Select
	--get @apt_max = a4
	@v201apositiontaking_3_max = max(case when cs.bettype = 3 then cs.apositiontaking else 0 end),
	@v201apositiontaking_2_max = max(case when cs.bettype = 2 then cs.apositiontaking else 0 end)
from CustSetting3rd as cs with (nolock)
where custid = (select srecommend from customer with (nolock) where custid = @CustID) AND cs.sporttype = 201 



select 
	@Msuspended as Msuspended, 
	isnull(@UplineDisableFI,0) as UplineDisableFI, 
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	isnull(c.firstname,'') as firstname,
	isnull(c.lastname,'') as lastname,
	c.roleid, c.username,
	isnull(@DownlineDisableFI,0) as DownlineDisableFI,
	isnull(c.phone,'') as phone, 
	isnull(c.mobilephone,'') as mobilephone, 
	isnull(c.fax,'') as fax,
	ci.maxpermatch201 as maxpermatchv201,
	ci.credit,
	isnull(ci.disablefinancial,0) as disablefinancial,
	max(case when cs.bettype = 3 then cs.minbet else 0 end) as MinBetv201,
	max(case when cs.bettype = 3 then cs.maxbet else 0 end) as MaxBetv201,
	
	max(case when cs.bettype = 3 then cs.discount else 0 end) as v201discount,
	@disFC as v201discount_max,

	max(case when cs.bettype = 3 then cs.apositiontaking else 0 end) as v201apositiontaking_3, 
	max(case when cs.bettype = 2 then cs.apositiontaking else 0 end) as v201apositiontaking_2,

	max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,	
	max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,	

	--Auto Master PT
	--um2
	max(case when cs.bettype = 3 then cs.autompositiontaking else 0 end) as auto_v201mpositiontaking_3,	---v201
	max(case when cs.bettype = 2 then cs.autompositiontaking else 0 end) as auto_v201mpositiontaking_2,	

	--im2
	max(case when cs.bettype = 3 then cs.isautompositiontaking else 0 end) as isauto_v201mpositiontaking_3,	---v201
	max(case when cs.bettype = 2 then cs.isautompositiontaking else 0 end) as isauto_v201mpositiontaking_2,	
	
	--max um2
	@max_v201mapositiontaking_3 as auto_v201mpositiontaking_3_max,	---v201
	@max_v201mapositiontaking_2 as auto_v201mpositiontaking_2_max,
	IsNull(@MinBetv201_Max, 0) as MinBetv201_Max,
	IsNull(@MaxBetv201_Min, 0) as MaxBetv201_Min,	
	IsNull(@MaxPerMatchv201_Min, 0) as MaxPerMatchv201_Min,	
	IsNull(@MaxPerMatchv201_Max, 0) as MaxPerMatchv201_Max,
	
	--max (m2+a2)
	@max_v201mapositiontaking_3 as max_v201mapositiontaking_3,	---v201
	@max_v201mapositiontaking_2 as max_v201mapositiontaking_2,	

	@min_v201mapositiontaking_3 as min_v201mapositiontaking_3,	---v201
	@min_v201mapositiontaking_2 as min_v201mapositiontaking_2,	

	--get n2 to check a2 > n2 on the web
	max(case when co.bettype = 3 then co.minpositiontaking else 0 end) as v201apositiontaking_3_min,	---v201
	max(case when co.bettype = 2 then co.minpositiontaking else 0 end) as v201apositiontaking_2_min,

	--get apt_max = min(a4, l2) to check a2 < min(a4, l2) on the web
	max(case when co.bettype = 3 then case when co.maxpositiontaking<@v201apositiontaking_3_max then co.maxpositiontaking else @v201apositiontaking_3_max end else 0 end) as v201apositiontaking_3_max,--v201	
	max(case when co.bettype = 2 then case when co.maxpositiontaking<@v201apositiontaking_2_max then co.maxpositiontaking else @v201apositiontaking_2_max end else 0 end) as v201apositiontaking_2_max
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
where 
	c.roleid=2 and c.custid=@CustID and
	c.mrecommend=@MRecommend AND cs.sporttype=201 
group by 
	ci.reject, c.firstname, c.lastname, c.roleid, c.username,
	c.phone, c.mobilephone, c.fax,
	ci.maxpermatch201,
	ci.credit,
	ci.disablefinancial
	 
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_MAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_MAg] TO [bodbExtAccNet]
GO


GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_MAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditCustomer_MAg] TO [vnteam]
