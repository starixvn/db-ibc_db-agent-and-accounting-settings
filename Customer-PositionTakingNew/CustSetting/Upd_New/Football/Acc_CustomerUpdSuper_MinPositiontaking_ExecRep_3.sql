CREATE PROCEDURE [dbo].[Acc_CustSetting_00_3]
	@srecommend int
AS
/*
Created: 20120508@Elodie
Task : Update PT of Football at member level when n4 is updated
DB: DBTRANS.bodb02
Original: Acc_CustSetting_00

Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
DECLARE @IsExistTables tinyint
SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
WHERE	name IN ('custinfo', 'CustSetting', 'CustOverride')
		AND xtype = 'U'

if @IsExistTables <> 3 RETURN
-----------------------
Declare @_srecommend int
select @_srecommend = @srecommend
declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney


----------------------------------------------------------------------------
--s1=min(s1,s4-m3) if i=0
update custsetting with (ROWLOCK, UPDLOCK) set custsetting.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where custsetting.sporttype=3 
	and custsetting.isautopositiontaking=0 and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<custsetting.spositiontaking

----------------------------------------------------------------------------
--check agent min
--a1=max(a1,n2)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.minpositiontaking,
	custsetting.mpositiontaking = case when custsetting.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting.mpositiontaking end
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.apositiontaking<aco.minpositiontaking

----------------------------------------------------------------------------
--check agent max
--a1=min(a1,l2)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.maxpositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and roleid=1
	inner join custoverride as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.apositiontaking>aco.maxpositiontaking

----------------------------------------------------------------------------
--Recal AUTO MPT m1=min(m3-a1,u2)
Update custsetting with (ROWLOCK, UPDLOCK) 
	set mpositiontaking = 
			case when mcs.mpositiontaking-custsetting.apositiontaking > case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end
				then case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end
			else  mcs.mpositiontaking-custsetting.apositiontaking end
from
	custsetting
	inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting.sporttype and acs.bettype=custsetting.bettype
where custsetting.sporttype=3
	and c.srecommend = @_srecommend
	and c.roleid = 1
	and (acs.isautompositiontaking = 1 or custsetting.isautompositiontaking = 1)
			
-------------------------------------------------------------------------------------
--check master min
--m1=max(m1,n3-a1)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	mpositiontaking = mco.minpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	inner join custoverride as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.apositiontaking+custsetting.mpositiontaking<mco.minpositiontaking

----------------------------------------------------------------------------
--check master max
Update custsetting with (ROWLOCK, UPDLOCK) set 
	@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	@mpos = case when @maxmapos-custsetting.apositiontaking<0 then 0 else @maxmapos-custsetting.apositiontaking end,
	mpositiontaking = @mpos,
	@apos = case when custsetting.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting.apositiontaking end,
	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.apositiontaking+custsetting.mpositiontaking>mco.maxpositiontaking

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--recal autopos
Update custsetting with (ROWLOCK, UPDLOCK)
	set spositiontaking = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking >
							(case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end 
from
	custsetting
	inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where custsetting.sporttype=3
	and c.srecommend = @_srecommend
	and c.roleid = 1
	and (custsetting.isautopositiontaking=1 or mcs.isautopositiontaking=1)

----------------------------------------------------------------------------
--check super min
--s1=max(n4-m1-a1,s1)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco.minpositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = @_srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.apositiontaking+custsetting.mpositiontaking+custsetting.spositiontaking<sco.minpositiontaking

----------------------------------------------------------------------------
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
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	inner join custsetting as scs with (NOLOCK) on scs.custid = @_srecommend  and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custoverride as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting.sporttype and mco.bettype=custsetting.bettype
	inner join custoverride as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
where custsetting.sporttype=3 and custsetting.spositiontaking+custsetting.apositiontaking+custsetting.mpositiontaking>scs.spositiontaking

-----------------
GO
GRANT EXECUTE ON [dbo].Acc_CustSetting_00_3 TO [bodbAdminNet]
GO
