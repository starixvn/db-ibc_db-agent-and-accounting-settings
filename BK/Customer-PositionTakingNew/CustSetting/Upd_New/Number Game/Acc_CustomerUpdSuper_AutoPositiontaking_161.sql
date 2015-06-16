CREATE PROCEDURE [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_161]
	@srecommend int
AS
/*
Created: 20120510@Elodie
Task : Recalculate s1 when s4 is updated
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdSuper_AutoPositiontaking

Revision: 
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
--u = (i3 or i1)?(u3 or u1)
--s1 = min(s4-m1-a1, u)
Update custsetting3rd 
	set spositiontaking = case when scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
							(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
from
	custsetting3rd 
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and custsetting3rd.sporttype=161
	and custsetting3rd.bettype in (81,83,86,88)
	and (custsetting3rd.isautopositiontaking=1 or mcs3.isautopositiontaking=1)

Update custsetting3rd
	set slivepositiontaking = case when scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
							(case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and custsetting3rd.sporttype=161
	and custsetting3rd.bettype in (85,86,87,89,90)
	and (custsetting3rd.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_161] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_161] TO [vnteam]
GO
 