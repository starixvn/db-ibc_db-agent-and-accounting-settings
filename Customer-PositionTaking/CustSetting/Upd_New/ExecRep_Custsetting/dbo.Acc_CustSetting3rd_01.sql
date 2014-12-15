ALTER PROCEDURE [Acc_CustSetting3rd_01]
	@srecommend int,
	@mode varchar(20) = 'horse', --'horse' or 'number' or 'finance' or 'virtual-sports'
	@sports VARCHAR(500)=''
AS
--@Source Control
/*
Created: 20090520@Phuc
Task : Update member level when update l4(HR)
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdSuperHR_MaxPositiontaking, Acc_CustomerUpdSuper_MaxPositiontaking, Acc_CustomerUpdSuperFI_MaxPositiontaking

Revisions for Acc_CustomerUpdSuperHR_MaxPositiontaking:
    - 20090716@Phuc: Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
    - 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20110126@Lukas: add Greyhound & Harness racing game
	- 20111028@Thien: convert to ExecRep SP

Revisions for Acc_CustomerUpdSuper_MaxPositiontaking:
    - 20080923@Phuc: Recal auto master postiontaking   
	- 20090716@Phuc: Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
	- 20100904@Henry: Add new sporttype (161: numbergame)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20111028@Thien: convert to ExecRep SP
	- 20111029@Thien: merge Acc_CustomerUpdSuperHR_MaxPositiontaking, Acc_CustomerUpdSuperFI_MaxPositiontaking and Acc_CustomerUpdSuper_MinPositiontaking to put
	                    into execRep, for Horse racing and Number Game and finance
	- 20120803@Dan: add virtual soccer sport type
	- 20121203@Scott: add virtual tennis sport type
	- 20130222@Johnson: add virtual horse racing setting (sporttype: 181)
	- 20131126@Kathy: Add Virtual Greyhounds/Motor Racing (182, 184) [Redmine:#7234]
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20141201@Johnson: New setting revonation for others porduct [Redmine: #26274]
Param's Explanation: 

* @mode:
    = 'horse': Horse racing
    = 'number': Number Game
    = 'finance': Financial betting
    = 'virtual-sports': Virtual Soccer
    
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

--DECLARE @IsExistTables tinyint
--SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
--WHERE	name IN ('custinfo','CustSetting3rd', 'CustOverride3rd')
--		AND xtype = 'U'

--if @IsExistTables <> 3 RETURN
IF @mode = 'Others'
BEGIN
	(SELECT COUNT(1) FROM sysobjects WHERE Name IN ('custinfo','CustPTSetting3rd_Agent', 'CustPTSetting3rd_Member','CustPTGroupSetting3rd_Member') AND type = 'U') <> 4
END
ELSE IF 
BEGIN
	((SELECT COUNT(1) FROM sysobjects WHERE Name IN ('custinfo','CustSetting3rd','CustOverride3rd') AND type = 'U') <> 3
		AND (SELECT COUNT(1) FROM sysobjects WHERE Name IN ('custinfo','CustSetting3rd','CustOverride3rd') AND type = 'V') <> 3) 
	RETURN
END

    declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
	DECLARE @tmpSport TABLE(sporttype INT)
	
if @mode = 'horse'
BEGIN


    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 
	    and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype between 151 and 153
    ----------------------------------------------------------------------------

    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    Update cs
	    set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
		    spositiontaking = @spos,
		    @mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
		    @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		    @mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
		    @mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype between 151 and 153
	    
    RETURN
END
----------------

if @mode = 'number'
BEGIN

   declare @_srecommend int
    select @_srecommend = @srecommend

    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
      --v161
    update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.isautopositiontaking=0 and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<custsetting3rd.spositiontaking

    update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.slivepositiontaking = scs.slivepositiontaking - mcs.mlivepositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90)
	    and custsetting3rd.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 and scs.slivepositiontaking - mcs.mlivepositiontaking<custsetting3rd.slivepositiontaking
    	
    ----------------------------------------------------------------------------

    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    --v161
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
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

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
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.bettype in (85,86,87) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

	    
    RETURN
END

if @mode = 'finance'
BEGIN
    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs 
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 
	    and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype = 201
    ----------------------------------------------------------------------------
    /*
    if s1+m1+a1>min(s4,l4)
	    @maxpos = min(s4,l4)
	    @spos = max(0,@maxpos-m1-a1)
	    s1 = @spos
	    @mpos1 = min(@maxspos-@spos, m1+a1)
	    @mpos2 = min(l3, @mapos1)
	    @mapos = max(@mpos2, n3)
	    @mpos = max(0, @mapos-a1)
	    m1 = @mpos
	    @apos = min(@mapos-m1, a1)
	    a1 = max(@apos,n2)	
    */
    Update cs
	    set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
		    spositiontaking = @spos,
		    @mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
		    @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		    @mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
		    @mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype = 201
    RETURN
    
END
if @mode = 'virtual-sports'
BEGIN
	----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 
	    and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype in(180, 181, 182, 183, 184, 185, 186) --between 180 and 186
    ----------------------------------------------------------------------------

    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    Update cs
	    set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
		    spositiontaking = @spos,
		    @mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
		    @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		    @mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
		    @mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype in(180, 181, 182, 183, 184, 185, 186) --between 180 and 186
	    
    RETURN
END

if @mode = 'Others'
BEGIN
	INSERT INTO @tmpSport(sporttype)
	SELECT DISTINCT val
	FROM dbo.strSplit(@sports,',')
	
	----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.SuperPT = scs.SuperPT - mcs.MasterPT
    from 
	    CustPTSetting3rd_Member as cs with (ROWLOCK, UPDLOCK)
	    INNER JOIN custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    INNER JOIN CustPTSetting3rd_Agent as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype AND mcs.isLive = cs.isLive
	    INNER JOIN CustPTSetting3rd_Agent as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype AND scs.isLive = cs.isLive
    WHERE cs.IsAutoSuperPT=0 
	    and mcs.IsAutoSuperPT=0 and scs.SuperPT - mcs.MasterPT<cs.SuperPT
	    AND cs.sporttype IN (SELECT sporttype FROM @tmpSport)
    ----------------------------------------------------------------------------

    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    UPDATE cs
	    SET @spos = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT<0 THEN 0 ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
		    SuperPT = @spos,
		    @mapos1 = CASE WHEN @spos+cs.MasterPT+cs.AgentPT>scs.SuperPT THEN scs.SuperPT -@spos ELSE cs.MasterPT+cs.AgentPT END,
		    @maxmapos = CASE WHEN mcs.MasterPT>mcs.MaxPT then mcs.MaxPT ELSE mcs.MasterPT END,
		    @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
		    @mapos = CASE WHEN @mapos2<mcs.MinPT THEN mcs.MinPT ELSE @mapos2 END,
		    @mpos = CASE WHEN @mapos-cs.AgentPT<0 THEN 0 ELSE @mapos-cs.AgentPT END,
		    MasterPT = @mpos,
		    @apos = CASE WHEN cs.AgentPT + @mpos>@mapos THEN @mapos-@mpos ELSE cs.AgentPT END,
		    AgentPT = CASE WHEN @apos<aco.MinPT THEN aco.MinPT ELSE @apos END
    FROM 
	    CustPTSetting3rd_Member AS cs WITH (ROWLOCK, UPDLOCK)
	    INNER JOIN custinfo AS mb WITH (NOLOCK) ON cs.custid = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=1
	    INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.isLive = cs.isLive
	    INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.custid = mb.mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype	AND mcs.isLive = cs.isLive    
	    INNER JOIN CustPTSetting3rd_Agent AS aco WITH (NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND aco.isLive = cs.isLive
    WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > scs.SuperPT
	    AND cs.sporttype IN (SELECT sporttype FROM @tmpSport)
	
	--correct pt on group settings
	 --s1=min(s1,s4-m3) if i=0
    UPDATE cs
	    SET cs.SuperPT = scs.SuperPT - mcs.MasterPT
    FROM 
	    CustPTGroupSetting3rd_Member AS cs WITH (ROWLOCK, UPDLOCK)
	    INNER JOIN custinfo AS mb WITH (NOLOCK) ON cs.custid = mb.custid AND mb.srecommend = @srecommend AND mb.roleid=2
	    INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.custid = mb.mrecommend AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype AND mcs.isLive = cs.isLive
	    INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.isLive = cs.isLive
    WHERE cs.IsAutoSuperPT=0 
	    AND mcs.IsAutoSuperPT=0 AND scs.SuperPT - mcs.MasterPT<cs.SuperPT
	    AND cs.sporttype IN (SELECT sporttype FROM @tmpSport)
    ----------------------------------------------------------------------------

    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    UPDATE cs
	    SET @spos = CASE WHEN scs.SuperPT-cs.MasterPT-cs.AgentPT<0 THEN 0 ELSE scs.SuperPT-cs.MasterPT-cs.AgentPT END,
		    SuperPT = @spos,
		    @mapos1 = CASE WHEN @spos+cs.MasterPT+cs.AgentPT>scs.SuperPT THEN scs.SuperPT -@spos ELSE cs.MasterPT+cs.AgentPT END,
		    @maxmapos = CASE WHEN mcs.MasterPT>mcs.MaxPT then mcs.MaxPT ELSE mcs.MasterPT END,
		    @mapos2 = CASE WHEN @mapos1>@maxmapos THEN @maxmapos ELSE @mapos1 END,
		    @mapos = CASE WHEN @mapos2<mcs.MinPT THEN mcs.MinPT ELSE @mapos2 END,
		    @mpos = CASE WHEN @mapos-cs.AgentPT<0 THEN 0 ELSE @mapos-cs.AgentPT END,
		    MasterPT = @mpos,
		    @apos = CASE WHEN cs.AgentPT + @mpos>@mapos THEN @mapos-@mpos ELSE cs.AgentPT END,
		    AgentPT = CASE WHEN @apos<aco.MinPT THEN aco.MinPT ELSE @apos END
    FROM 
	    CustPTGroupSetting3rd_Member AS cs WITH (ROWLOCK, UPDLOCK)
	    INNER JOIN custinfo AS mb WITH (NOLOCK) ON cs.AgentID = mb.custid AND mb.srecommend=@srecommend AND mb.roleid=2
	    INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend  AND scs.sporttype=cs.sporttype AND scs.bettype=cs.bettype AND scs.isLive = cs.isLive
	    INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.custid = mb.mrecommend  AND mcs.sporttype=cs.sporttype AND mcs.bettype=cs.bettype	AND mcs.isLive = cs.isLive    
	    INNER JOIN CustPTSetting3rd_Agent AS aco WITH (NOLOCK) ON aco.custid = mb.recommend  AND aco.sporttype=cs.sporttype AND aco.bettype=cs.bettype AND aco.isLive = cs.isLive
    WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > scs.SuperPT
	    AND cs.sporttype IN (SELECT sporttype FROM @tmpSport)
    
    RETURN
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_01] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_01] TO [vnteam] AS [dbo]