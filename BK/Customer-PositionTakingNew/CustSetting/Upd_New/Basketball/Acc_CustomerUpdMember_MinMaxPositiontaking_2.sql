CREATE PROCEDURE [dbo].[Acc_CustomerUpdMember_MinMaxPositiontaking_2]
	@custid int,
	@recommend int,
	@mrecommend int,
	@srecommend int,
	@updautomaster bit = 1,
	@updautosuper bit = 1
AS
/*
Created: 20120522@Elodie
Task : Update PT for Basketball at member level when add new/edit member.
DB: DBTrans.bodb02
Original: Acc_CustomerUpdMember_MinMaxPositiontaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

--check agent min/max
--update a1=n2 when a1<n2
Update custsetting with (ROWLOCK, UPDLOCK) set 
	custsetting.apositiontaking = aco.minpositiontaking,
	custsetting.mpositiontaking = case when custsetting.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting.mpositiontaking end
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.apositiontaking<aco.minpositiontaking 
		and custsetting.sporttype = 2

--update a1=l2 when a1>l2
Update custsetting with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.maxpositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custoverride as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.apositiontaking>aco.maxpositiontaking
		and custsetting.sporttype = 2

-------------------------------------------------------------------------------------
--Recal AUTO MPT 
--Update m1=min(m3-a1,(im1?um1,um2))
if @updautomaster = 1
begin
	Update custsetting with (ROWLOCK, UPDLOCK) 
		set mpositiontaking = 
			case when mcs.mpositiontaking-custsetting.apositiontaking > (case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end)
			then (case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end)
			else  mcs.mpositiontaking-custsetting.apositiontaking end
	from
		custsetting
		inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
		inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
		inner join custsetting as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting.sporttype and acs.bettype=custsetting.bettype
	where
		c.custid = @custid
		and c.roleid = 1
		and custsetting.sporttype = 2
		and (acs.isautompositiontaking = 1 or custsetting.isautompositiontaking = 1)
end

-------------------------------------------------------------------------------------
--check master min/max
--update m1=n3-a1 if a1+m1<n3
Update custsetting with (ROWLOCK, UPDLOCK) set 
	mpositiontaking = mco.minpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custoverride as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.apositiontaking+custsetting.mpositiontaking<mco.minpositiontaking
		and custsetting.sporttype = 2

-----------------------------------------------------------------------------------------------------------------------------------
--update m1,a1 when a1+m1>l3
--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	@mpos = case when @maxmapos-custsetting.apositiontaking<0 then 0 else @maxmapos-custsetting.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when custsetting.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting.apositiontaking end,
	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.apositiontaking+custsetting.mpositiontaking>mco.maxpositiontaking
		and custsetting.sporttype = 2 

-----------------------------------------------------------------------------------------------------------------------------------
--recal autopos
if @updautosuper = 1 
begin
	Update custsetting with (ROWLOCK, UPDLOCK) 
		set spositiontaking = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking >
								(case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end 
	from
		custsetting
		inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
		inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
		inner join custsetting as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
	where
		custsetting.custid = @custid
		and c.roleid = 1
		and custsetting.sporttype = 2
		and (custsetting.isautopositiontaking=1 or mcs.isautopositiontaking=1)
end

--check super min/max
--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
Update custsetting with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco.minpositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.apositiontaking+custsetting.mpositiontaking+custsetting.spositiontaking<sco.minpositiontaking
		and custsetting.sporttype = 2

--------------------------------------------------------------------------------
--update s1,m1,a1 in case s1+m1+a1>s4
--s1=max(0,s4-m1-a1)
--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
--@maxmapos=min(m3,l3)
--@mapos2=min(@mapos1,@maxmapos)
--@mapos=max(@mapos2,n3)
--m1=max(0,@mapos-a1)
--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	@spos = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking<0 then 0 else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end,
	spositiontaking = @spos,
	@mapos1 = case when @spos+custsetting.mpositiontaking+custsetting.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else custsetting.mpositiontaking+custsetting.apositiontaking end,
	@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
	@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
	@mpos = case when @mapos-custsetting.apositiontaking<0 then 0 else @mapos-custsetting.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when custsetting.apositiontaking + @mpos>@mapos then @mapos-@mpos else custsetting.apositiontaking end,
	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.custid = @custid and mb.roleid=1
	inner join custsetting as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.custid = @custid and custsetting.spositiontaking+custsetting.apositiontaking+custsetting.mpositiontaking>scs.spositiontaking
		and custsetting.sporttype = 2

--------------------------------------------------------------------
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxPositiontaking_2] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_MinMaxPositiontaking_2] TO [vnteam] 