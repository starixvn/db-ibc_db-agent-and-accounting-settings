CREATE PROCEDURE [dbo].Acc_CustomerUpdMaster_MaxPositiontaking_161
	@mrecommend int
AS
/*
Created: 20120528@Elodie
Task : Update PT of Number Game at member level when super update master.
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdMaster_MaxPositiontaking

Revisions:
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
declare @srecommend int
select @srecommend = srecommend from customer with (NOLOCK) where custid = @mrecommend

declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

-------------------------------------------------------------------------------------
--Recal AUTO MPT m1=min(m3-a1,u2)
update cs3 with(rowlock,updlock)
	set mpositiontaking = case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
							   then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
								else mcs3.mpositiontaking-cs3.apositiontaking end
from custsetting3rd cs3 
	inner join custinfo c with(nolock) on cs3.custid = c.custid
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custsetting3rd acs3 with(nolock) on acs3.custid = c.recommend and acs3.sporttype = cs3.sporttype and acs3.bettype = mcs3.bettype
where
	c.mrecommend = @mrecommend
	and c.roleid = 1
	and (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
	and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
	set mlivepositiontaking = case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
									then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
								else mcs3.mlivepositiontaking-cs3.alivepositiontaking end
from custsetting3rd cs3
	inner join custinfo c with(nolock) on cs3.custid = c.custid
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custsetting3rd acs3 with(nolock) on acs3.custid = c.recommend and acs3.sporttype = cs3.sporttype and acs3.bettype = cs3.bettype
where c.mrecommend = @mrecommend
	and c.roleid = 1
	and (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
	and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90)

----------------------------------------------------------------------------
--check master min/max
--m1=n3-a1
update cs3 with(rowlock,updlock)
set mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
						inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
where cs3.apositiontaking + cs3.mpositiontaking < mco3.minpositiontaking 
		and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
set mlivepositiontaking = mco3.minlivepositiontaking-cs3.alivepositiontaking
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 
		and cs3.alivepositiontaking+cs3.mlivepositiontaking<mco3.minlivepositiontaking

----------------------------------------------------------------------------
-- Update m1,a1 when m1+a1>l3
-- m1=min(m3,l3)-a1
update cs3 with(rowlock,updlock)
set @maxmapos = case when mcs3.mpositiontaking > mco3.maxpositiontaking then mco3.maxpositiontaking else mcs3.mpositiontaking end,
	@mpos = case when @maxmapos-cs3.apositiontaking < 0 then 0 else @maxmapos-cs3.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when cs3.apositiontaking + @mpos > @maxmapos then @maxmapos-@mpos else cs3.apositiontaking end,
	apositiontaking = case when @apos<aco3.minpositiontaking then aco3.minpositiontaking else @apos end
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid=1
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.apositiontaking + cs3.mpositiontaking > mco3.maxpositiontaking 
		and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
set @maxmapos = case when mcs3.mlivepositiontaking > mco3.maxlivepositiontaking then mco3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
	@mpos = case when @maxmapos-cs3.alivepositiontaking < 0 then 0 else @maxmapos-cs3.alivepositiontaking end,
	mlivepositiontaking = @mpos,
	@apos = case when cs3.alivepositiontaking + @mpos > @maxmapos then @maxmapos - @mpos else cs3.alivepositiontaking end,
	alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 
		and cs3.alivepositiontaking + cs3.mlivepositiontaking > mco3.maxlivepositiontaking

----------------------------------------------------------------------------
--recal autopos
-- s1=min(s4-m1-a1,u)
update cs3 with(rowlock,updlock)
set spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking > 
						(case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else  mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking = 1 then cs3.autopositiontaking else mcs3.autopositiontaking end ) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end
from custsetting3rd cs3 
	inner join custinfo c with(nolock) on cs3.custid = c.custid
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
where c.mrecommend = @mrecommend
	and c.roleid = 1
	and (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking = 1)
	and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
set slivepositiontaking = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking >
			(case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking = 1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end
from custsetting3rd cs3
	inner join custinfo c with(nolock) on cs3.custid = c.custid
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
where c.mrecommend = @mrecommend
	and c.roleid = 1
	and (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
	and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90)

----------------------------------------------------------------------------
--check super min/max when a1+m1+s1<n4
-- s1=n4-m1-a1
update cs3 with(rowlock,updlock)
set spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
where cs3.apositiontaking+ cs3.mpositiontaking + cs3.spositiontaking < sco3.minpositiontaking
	and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
set slivepositiontaking = sco3.minlivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 
		and cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco3.minlivepositiontaking

-------------------------------------------------------------
--update s1,m1,a1 in case s1+m1+a1>s4
--s1=max(0,s4-m1-a1)
--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
--@maxmapos=min(m3,l3)
--@mapos2=min(@mapos1,@maxmapos)
--@mapos=max(@mapos2,n3)
--m1=max(0,@mapos-a1)
--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
update cs3 with(rowlock,updlock)
set @spos = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking<0 then 0 else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end,
	spositiontaking = @spos,
	@mapos1 = case when @spos + cs3.mpositiontaking+cs3.apositiontaking>scs3.spositiontaking then scs3.spositiontaking-@spos else cs3.mpositiontaking+cs3.apositiontaking end,
	@maxmapos = case when mcs3.mpositiontaking > mco3.maxpositiontaking then mco3.maxpositiontaking else mcs3.mpositiontaking end,
	@mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
	@mapos = case when @mapos2 < mco3.minpositiontaking then mco3.minpositiontaking else @mapos2 end,
	@mpos = case when @mapos - cs3.apositiontaking < 0 then 0 else @mapos-cs3.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when cs3.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs3.apositiontaking end,
	apositiontaking = case when @apos < aco3.minpositiontaking then aco3.minpositiontaking else @apos end
from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.spositiontaking+cs3.apositiontaking + cs3.mpositiontaking > scs3.spositiontaking 
		and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

update cs3 with(rowlock,updlock)
set @spos = case when scs3.slivepositiontaking - cs3.mlivepositiontaking-cs3.alivepositiontaking < 0 then 0 else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end,
	slivepositiontaking = @spos,
	@mapos1 = case when @spos + cs3.mlivepositiontaking+ cs3.alivepositiontaking > scs3.slivepositiontaking then scs3.slivepositiontaking-@spos else cs3.mlivepositiontaking + cs3.alivepositiontaking end,
	@maxmapos = case when mcs3.mlivepositiontaking > mco3.maxlivepositiontaking then mco3.maxlivepositiontaking else mcs3.mlivepositiontaking end,
	@mapos2 = case when @mapos1 > @maxmapos then @maxmapos else @mapos1 end,
	@mapos = case when @mapos2 < mco3.minlivepositiontaking then mco3.minlivepositiontaking else @mapos2 end,
	@mpos = case when @mapos-cs3.alivepositiontaking < 0 then 0 else @mapos-cs3.alivepositiontaking end,
	mlivepositiontaking = @mpos,
	@apos = case when cs3.alivepositiontaking + @mpos > @mapos then @mapos - @mpos else cs3.alivepositiontaking end,
	alivepositiontaking = case when @apos < aco3.minlivepositiontaking then aco3.minlivepositiontaking else @apos end

from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
	inner join custsetting3rd scs3 with(nolock) on scs3.custid = @srecommend and scs3.sporttype = cs3.sporttype and scs3.bettype = cs3.bettype
	inner join custsetting3rd mcs3 with(nolock) on mcs3.custid = @mrecommend and mcs3.sporttype = cs3.sporttype and mcs3.bettype = cs3.bettype
	inner join custoverride3rd sco3 with(nolock) on sco3.custid = @srecommend and sco3.sporttype = cs3.sporttype and sco3.bettype = cs3.bettype
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = mb.recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 
		and cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs3.slivepositiontaking

GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_MaxPositiontaking_161 TO [bodbAdminNet] 