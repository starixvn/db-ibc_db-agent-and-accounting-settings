
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustomerSelFIEditMember_MAg    Script Date: 8/6/2009 8:08:11 PM ******/
ALTER PROCEDURE  [dbo].[Acc_CustomerSelFIEditMember_MAg]
	@CustID int,
	@AgentID int
AS
/*
	Created by: Phuong Dao
	Date: 2009-04-16
	Task: MASTER EDIT MEMBER FOR FINANCE AT AGENT SITE 
	DB: DB05.BODB02 
	Original: Acc_CustomerSelEditCustomer_MAg
	
	Revisions:
		- 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
		- 20090806@Phuc: remove check m1=min(m3-a2,m1)
		- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
*/
SET NOCOUNT ON

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @mrecommend int, @DisableAutoMPT bit
select @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid

--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @mrecommend

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Declare 
	@v201sp_2 smallmoney,
	@v201sp_3 smallmoney,
	@max_v201mp_2 smallmoney,
	@max_v201mp_3 smallmoney,
	@isauto_v201mpositiontaking_2 bit ,
	@isauto_v201mpositiontaking_3 bit 

--im2
Select 
	@isauto_v201mpositiontaking_2 = max(case when acs.bettype = 2 then acs.isautompositiontaking else 0 end),
	@isauto_v201mpositiontaking_3 = max(case when acs.bettype = 3 then acs.isautompositiontaking else 0 end)
From custinfo m with(nolock) 
inner join CustSetting3rd acs with(nolock) on m.recommend = acs.custid 
where m.custid = @AgentID AND acs.sporttype = 201 


--@sp=s4
Select 
	@v201sp_2 = max(case when Scs.bettype = 2 then Scs.spositiontaking else 0 end),
	@v201sp_3 = max(case when Scs.bettype = 3 then Scs.spositiontaking else 0 end)
From CustSetting3rd as Scs with (NOLOCK)
where scs.CustID in (Select srecommend from custinfo with (NOLOCK) where CustID = @CustID) and Scs.sporttype=201

Declare 
	@v201mapositiontaking_2_max smallmoney,
	@v201mapositiontaking_3_max smallmoney,
	--min
	@v201mapositiontaking_2_min smallmoney,
	@v201mapositiontaking_3_min smallmoney

Select
	--@mapos_max=min(m3,l3)
	@v201mapositiontaking_2_max = max(case when cs.bettype = 2 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v201mapositiontaking_3_max = max(case when cs.bettype = 3 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	--@mapos_min=n3
	@v201mapositiontaking_2_min = max(case when co.bettype = 2 then co.minpositiontaking else 0 end),
	@v201mapositiontaking_3_min = max(case when co.bettype = 3 then co.minpositiontaking else 0 end)

From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID in (Select mRecommend from custinfo with (NOLOCK) where CustID = @AgentID) and cs.sporttype=201



Select
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	@max_v201mp_2 = max(case when cs.bettype = 2 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v201sp_2-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v201sp_2-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v201mp_3 = max(case when cs.bettype = 3 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v201sp_3-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v201sp_3-cs.spositiontaking-cs.apositiontaking end end else 0 end)
From CustSetting3rd as cs with (NOLOCK) 
inner join custinfo as c with (nolock) on cs.custid = c.custid
inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend
where cs.custid = @custid and cs.sporttype=201


SELECT
	isnull(c.fax,'') as fax, 
	c.firstname, 
	c.lastname,
	ci.maxpermatch, 
	isnull(c.mobilephone,'') as mobilephone,
	isnull(c.phone,'') as phone,
	c.username,  
	c.username2,  
	ci.maxpermatch201 as maxpermatchv201, 
	ci.credit,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	--v201	
	isnull(max(case when cs.bettype = 3 then cs.discount else 0 end), 0) as v201discount_ag,
	isnull(max(case when cs.bettype = 3 then cs.playerdiscount else 0 end), 0) as v201discount,

	max(case when cs.bettype = 3 then cs.minbet else 0 end) as minbetv201,
	max(case when cs.bettype = 3 then cs.maxbet else 0 end) as maxbetv201,

	max(case when cs.bettype = 2 then cs.apositiontaking else 0 end) as v201apositiontaking_2,
    max(case when cs.bettype = 3 then cs.apositiontaking else 0 end) as v201apositiontaking_3,

	max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,
	max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,
	
	--maxpos_1=min[@max_mp,min(m3,l3)-a1]
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	case when isnull(@max_v201mp_2, 0)  < @v201mapositiontaking_2_max - max(case when cs.bettype = 2 then cs.apositiontaking else 0 end)  then isnull(@max_v201mp_2, 0)  else @v201mapositiontaking_2_max - max(case when cs.bettype = 2 then cs.apositiontaking else 0 end)  end as maxv201pos_2,
	case when isnull(@max_v201mp_3, 0)  < @v201mapositiontaking_3_max - max(case when cs.bettype = 3 then cs.apositiontaking else 0 end)  then isnull(@max_v201mp_3, 0)  else @v201mapositiontaking_3_max - max(case when cs.bettype = 3  then cs.apositiontaking else 0 end)  end as maxv201pos_3,
	------------------------------------------------------------------------------------------------------------------------------------
	case when @v201mapositiontaking_2_min - max(case when cs.bettype = 2 then cs.apositiontaking else 0 end)  <0 then 0 else @v201mapositiontaking_2_min - max(case when cs.bettype = 2 then cs.apositiontaking else 0 end)  end as minv201pos_2,
	case when @v201mapositiontaking_3_min - max(case when cs.bettype = 3 then cs.apositiontaking else 0 end)  <0 then 0 else @v201mapositiontaking_3_min - max(case when cs.bettype = 3 then cs.apositiontaking else 0 end)  end as minv201pos_3,

	--im2
	@isauto_v201mpositiontaking_2 	as	isauto_v201mpositiontaking_2 ,
	@isauto_v201mpositiontaking_3 	as	isauto_v201mpositiontaking_3 ,
	--im1
	max(case when cs.bettype = 2 then cs.isautompositiontaking else 0 end) as isauto_v201mpositiontaking_mem_2,
	max(case when cs.bettype = 3 then cs.isautompositiontaking else 0 end) as isauto_v201mpositiontaking_mem_3,
	--um1
	max(case when cs.bettype = 2 then cs.autompositiontaking else 0 end) as auto_v201mpositiontaking_mem_2,
	max(case when cs.bettype = 3 then cs.autompositiontaking else 0 end) as auto_v201mpositiontaking_mem_3,
	--um1_max
	isnull(@v201mapositiontaking_2_max,0) as maxauto_v201mpositiontaking_mem_2,
	isnull(@v201mapositiontaking_3_max,0) as maxauto_v201mpositiontaking_mem_3
FROM 
	customer as C with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid
	INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid  = cs.custid
WHERE c.custid=@custId AND c.recommend=@agentId AND  cs.sporttype=201
group by 
	c.fax, 
	c.firstname, 
	c.lastname,
	ci.maxpermatch, 
	c.mobilephone, 
	c.phone, 
	c.username, 
	c.username2, 
	ci.maxpermatch201,
	ci.credit

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_MAg] TO [bodbAdminNet]
 GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_MAg] TO [bodbExtAccNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_MAg] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_MAg] TO [bodbDownlineNetView]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditMember_MAg] TO [vnteam]
GO 
