CREATE PROCEDURE [dbo].[Acc_CustomerUpdAgent_MinMaxPositiontaking_161]
	@recommend int,
	@mrecommend int,
	@srecommend int
AS
/*
Created: 20120510@Elodie
Task : update PT of Number Game at member level when n2,l2 is updated
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdAgent_MinMaxPositiontaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

-------------------------------------------------------------------------------------
--check agent min/max
-- Update a1 when a1<n2
-- a1=n2
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.minpositiontaking,
	custsetting3rd.mpositiontaking = case when custsetting3rd.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting3rd.mpositiontaking end
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking<aco.minpositiontaking


Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	alivepositiontaking = aco.minlivepositiontaking,
	custsetting3rd.mlivepositiontaking = case when custsetting3rd.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking-aco.minlivepositiontaking else custsetting3rd.mlivepositiontaking end
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking<aco.minlivepositiontaking

-------------------------------------------------------------------------------------
-- Update a1 when a1>l2
-- a1=l2
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.maxpositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking>aco.maxpositiontaking


Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	alivepositiontaking = aco.maxlivepositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking>aco.maxlivepositiontaking

-------------------------------------------------------------------------------------
--Recal AUTO MPT 
--Update m1=min(m3-a1,u2)
Update custsetting3rd with (ROWLOCK, UPDLOCK) 
set mpositiontaking = 
		case when mcs.mpositiontaking-custsetting3rd.apositiontaking > case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end
			then case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end
		else  mcs.mpositiontaking-custsetting3rd.apositiontaking end
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
where
	c.recommend = @recommend
	and c.roleid = 1
	and custsetting3rd.sporttype = 161
	and custsetting3rd.bettype in (81,83,86,88)
and (acs.isautompositiontaking = 1 or custsetting3rd.isautompositiontaking = 1)
	
Update custsetting3rd with (ROWLOCK, UPDLOCK) 
set mlivepositiontaking =
		case when mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking > case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end
			then case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end
		else  mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking end
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
where
	c.recommend = @recommend
	and c.roleid = 1
	and custsetting3rd.sporttype = 161
	and custsetting3rd.bettype in (85,86,87,89,90)
	and (acs.isautolivempositiontaking = 1 or custsetting3rd.isautolivempositiontaking = 1)
	
-------------------------------------------------------------------------------------
--check master min/max
-- Update m1 when m1+a1<n3
-- m1=n3-a1
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	mpositiontaking = mco.minpositiontaking-custsetting3rd.apositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking<mco.minpositiontaking


Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	mlivepositiontaking = mco.minlivepositiontaking-custsetting3rd.alivepositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking<mco.minlivepositiontaking

-------------------------------------------------------------------------------------
-- Update m1,a1 when m1+a1>l3
-- m1=min(m3,l3)-a1
-- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161  and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
	@mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
	mlivepositiontaking = @mpos,
	@apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
	alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking

-------------------------------------------------------------------------------------
--s1=min(s4-m1-a1,u)
--recal autopos
Update custsetting3rd with (ROWLOCK, UPDLOCK) 
	set spositiontaking = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
							(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
where
	c.recommend = @recommend
	and c.roleid = 1
	and custsetting3rd.sporttype = 161
	and custsetting3rd.bettype in (81,83,86,88)
	and (custsetting3rd.isautopositiontaking=1 or mcs.isautopositiontaking=1)

Update custsetting3rd with (ROWLOCK, UPDLOCK) 
	set slivepositiontaking = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
							(case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
where
	c.recommend = @recommend
	and c.roleid = 1
	and custsetting3rd.sporttype = 161
	and custsetting3rd.bettype in (85,86,87,89,90)
	and (custsetting3rd.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	

-------------------------------------------------------------------------------------
--check super min/max
--Update s1 when s1+m1+a1<n4
--s1=n4-m1-a1 
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco.minpositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking+custsetting3rd.spositiontaking<sco.minpositiontaking

Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	slivepositiontaking = sco.minlivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking+custsetting3rd.slivepositiontaking<sco.minlivepositiontaking

-------------------------------------------------------------------------------------
--update s1,m1,a1 in case s1+m1+a1>s4
--s1=max(0,s4-m1-a1)
--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
--@maxmapos=min(m3,l3)
--@mapos2=min(@mapos1,@maxmapos)
--@mapos=max(@mapos2,n3)
--m1=max(0,@mapos-a1)
--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	@spos = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking<0 then 0 else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end,
	spositiontaking = @spos,
	@mapos1 = case when @spos+custsetting3rd.mpositiontaking+custsetting3rd.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else custsetting3rd.mpositiontaking+custsetting3rd.apositiontaking end,
	@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
	@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
	@mpos = case when @mapos-custsetting3rd.apositiontaking<0 then 0 else @mapos-custsetting3rd.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when custsetting3rd.apositiontaking + @mpos>@mapos then @mapos-@mpos else custsetting3rd.apositiontaking end,
	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
from 
	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in  (81,83,86,88) and  custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	@spos = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking<0 then 0 else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end,
	slivepositiontaking = @spos,
	@mapos1 = case when @spos+custsetting3rd.mlivepositiontaking+custsetting3rd.alivepositiontaking>scs.slivepositiontaking then scs.slivepositiontaking-@spos else custsetting3rd.mlivepositiontaking+custsetting3rd.alivepositiontaking end,
	@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
	@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
	@mapos = case when @mapos2<mco.minlivepositiontaking then mco.minlivepositiontaking else @mapos2 end,
	@mpos = case when @mapos-custsetting3rd.alivepositiontaking<0 then 0 else @mapos-custsetting3rd.alivepositiontaking end,
	mlivepositiontaking = @mpos,
	@apos = case when custsetting3rd.alivepositiontaking + @mpos>@mapos then @mapos-@mpos else custsetting3rd.alivepositiontaking end,
	alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
from 

	custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

----------------------------------------------------------------------
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdAgent_MinMaxPositiontaking_161 TO [bodbAdminNet]
GO
 