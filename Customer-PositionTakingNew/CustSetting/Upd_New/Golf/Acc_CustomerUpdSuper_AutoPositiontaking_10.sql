CREATE PROCEDURE [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_10]
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
Update custsetting
	set spositiontaking = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking >
							(case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end 
from
	custsetting
	inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and custsetting.sporttype=10
	and (custsetting.isautopositiontaking=1 or mcs.isautopositiontaking=1)	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_10] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking_10] TO [vnteam]
GO
 