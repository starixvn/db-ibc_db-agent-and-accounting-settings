 ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_07]
	@custid INT = 0,
	@srecommend INT= 0,
	@mrecommend iNT = 0,
	@recommend INT = 0,
	@roleid INT,
	@mode  VARCHAR(50) = '',
	@updautomaster bit = 1,
	@updautosuper bit = 1 
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep when corrects pt on members
		DB: DBTXN/bodb02
		
		Revision:
		
		Parameter's Explanation:
	*/ 
BEGIN
SET NOCOUNT ON
	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN ('custinfo', 'CustSetting3rd', 'CustOverride3rd')
			AND xtype = 'U'

	if @IsExistTables <> 3 RETURN
	
	IF @roleid = 4
	BEGIN			
		IF @mode = 'number'
		BEGIN
			--u = (i3 or i1)?(u3 or u1)
			--s1 = min(s4-m1-a1, u)		
			--v161
			 
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
				and (custsetting3rd.isautopositiontaking=1 or mcs3.isautopositiontaking=1)

			--v161 
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
				and (custsetting3rd.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
		END
	END
	ELSE IF @roleid = 3
	BEGIN
		IF @mode = 'number'
		BEGIN
			--Update all agent and member accounts

			declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

			--Phuc remove @20081125 
			/*
			-- Update m2,a2 when m2+a2>m3(normal)
			-- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)

			Update custsetting with (ROWLOCK, UPDLOCK) set 
				@mpos = case when mcs.mpositiontaking-custsetting.apositiontaking<0 then 0 else mcs.mpositiontaking-custsetting.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when mcs.mpositiontaking-@mpos-custsetting.apositiontaking<0 then mcs.mpositiontaking-@mpos else custsetting.apositiontaking end,
				apositiontaking = case when aco.minpositiontaking > @apos then aco.minpositiontaking else @apos end 
			from 
				custsetting inner join customer as a with (NOLOCK) on custsetting.custid = a.custid and a.mrecommend = @mrecommend and a.roleid = 2
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
				inner join custoverride as aco with (NOLOCK) on aco.custid = custsetting.custid  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
			where 
				custsetting.mpositiontaking+custsetting.apositiontaking > mcs.mpositiontaking

			-- Update m2,a2 when m2+a2>m3(live)
			-- m2=m3-a2,a2=max(iif(m3<m2+a2,m3-m2,a2),n2)
			Update custsetting with (ROWLOCK, UPDLOCK) set 
				@mpos = case when mcs.mlivepositiontaking-custsetting.alivepositiontaking<0 then 0 else mcs.mlivepositiontaking-custsetting.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when mcs.mlivepositiontaking-@mpos-custsetting.alivepositiontaking<0 then mcs.mlivepositiontaking-@mpos else custsetting.alivepositiontaking end,
				alivepositiontaking = case when aco.minlivepositiontaking > @apos then aco.minlivepositiontaking else @apos end 
			from 
				custsetting inner join customer as a with (NOLOCK) on custsetting.custid = a.custid and a.mrecommend = @mrecommend and a.roleid = 2
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
				inner join custoverride as aco with (NOLOCK) on aco.custid = custsetting.custid  and aco.sporttype=custsetting.sporttype and aco.bettype=custsetting.bettype
			where 
				custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8) 
				and custsetting.mlivepositiontaking+custsetting.alivepositiontaking > mcs.mlivepositiontaking
			*/

			--Recal AUTO MPT m1=min(m3-a1,u2)
			-------------------------------------------------------------------------------------
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
			-------------------------------------------------------------------------------------



			----------------------------------------------------------------------------
			--check master min/max
			--m1=n3-a1
			update cs3 with(rowlock,updlock)
			set mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
			from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
									inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
			where cs3.apositiontaking + cs3.mpositiontaking < mco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)


			update cs3 with(rowlock,updlock)
			set mlivepositiontaking = mco3.minlivepositiontaking-cs3.alivepositiontaking
			from custsetting3rd cs3 inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.mrecommend = @mrecommend and mb.roleid = 1
				inner join custoverride3rd mco3 with(nolock) on mco3.custid = @mrecommend and mco3.sporttype = cs3.sporttype and mco3.bettype = cs3.bettype
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking<mco3.minlivepositiontaking
			----------------------------------------------------------------------------


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
			where cs3.apositiontaking + cs3.mpositiontaking > mco3.maxpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

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
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking + cs3.mlivepositiontaking > mco3.maxlivepositiontaking
			----------------------------------------------------------------------------


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
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking + cs3.mlivepositiontaking + cs3.slivepositiontaking < sco3.minlivepositiontaking
			----------------------------------------------------------------------------


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
			where cs3.spositiontaking+cs3.apositiontaking + cs3.mpositiontaking > scs3.spositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

			
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
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.slivepositiontaking + cs3.alivepositiontaking + cs3.mlivepositiontaking > scs3.slivepositiontaking
			----------------------------------------------------------------------------
		END
	END
	ELSE IF @roleid = 2
	BEGIN
		IF @mode = 'number'
		BEGIN						
			-------------------------------------------------------------------------------------------------------------------------------------------------  
			--Check min max a1: n2<=a1<=l2 => modify a1
			-- non-live (min)
			update cs3
			set cs3.apositiontaking = aco3.minpositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
			where cs3.apositiontaking < aco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

			-- live (min)
			update cs3
			set cs3.alivepositiontaking = aco3.minlivepositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking < aco3.minlivepositiontaking

			-- non-live(max)
			update cs3
			set cs3.apositiontaking = aco3.maxpositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.roleid = 1 and mb.recommend = @recommend
				inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
			where cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) and cs3.apositiontaking > aco3.maxpositiontaking

			-- live(max)
			update cs3
			set cs3.alivepositiontaking = aco3.maxlivepositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
			where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking > aco3.maxlivepositiontaking
			-------------------------------------------------------------------------------------------------------------------------------------------------  

			--Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1			
			-- non-live
			update cs3
			set mpositiontaking = macs3.mpositiontaking - cs3.apositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
			where cs3.apositiontaking + cs3.mpositiontaking > macs3.mpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

			-- live
			update cs3
			set mlivepositiontaking = macs3.mlivepositiontaking - cs3.alivepositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
			where cs3.alivepositiontaking + cs3.mlivepositiontaking > macs3.mlivepositiontaking and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 

			--Recal u2
			--Recal AUTO MPT m1=min(m3-a1,u2)
			-------------------------------------------------------------------------------------------------------------------------------------------------  			
			-- non-live
			Update cs3 with (ROWLOCK, UPDLOCK) 
				set cs3.mpositiontaking = 
					case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
						then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
					else  mcs3.mpositiontaking-cs3.apositiontaking end
			from
				custsetting3rd cs3
				inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
				inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
				inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
			where
				mb.recommend = @recommend
				and mb.roleid = 1	
				and (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
				and cs3.sporttype = 161
				and cs3.bettype in (81,83,86,88) 

			-- live
			Update cs3 with (ROWLOCK, UPDLOCK) 
				set mlivepositiontaking =
					case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
						then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
					else  mcs3.mlivepositiontaking-cs3.alivepositiontaking end
			from
				custsetting3rd cs3
				inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
				inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
				inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90)
				and mb.recommend = @recommend
				and mb.roleid = 1
				and (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
			-------------------------------------------------------------------------------------------------------------------------------------------------  


			-------------------------------------------------------------------------------------------------------------------------------------------------  
			--Check min max n3<=m1+a1<=l3 => modify m1
			-- non-live
			update cs3
			set cs3.mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype
			where cs3.mpositiontaking + cs3.apositiontaking < mco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

			--Live(min)
			update cs3
				set cs3.mlivepositiontaking = mco3.minlivepositiontaking - cs3.alivepositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking < mco3.minlivepositiontaking

			--Nonlive(max)
			update cs3
				set cs3.mpositiontaking = mco3.maxpositiontaking - cs3.apositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
			where cs3.mpositiontaking + cs3.apositiontaking > mco3.maxpositiontaking and cs3.sporttype = 161  and cs3.bettype in (81,83,86,88)

			--Live(max)
			update cs3
				set cs3.mlivepositiontaking = mco3.maxlivepositiontaking - cs3.alivepositiontaking
			from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
				inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking > mco3.maxlivepositiontaking

			-------------------------------------------------------------------------------------------------------------------------------------------------  


			-------------------------------------------------------------------------------------------------------------------------------------------------  
			--Recal u3,u1
			-- s1=min(s4-m1-a1,u)
			--Nonlive
			Update cs3 with (ROWLOCK, UPDLOCK) 
				set spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
										(case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end 
			from
				custsetting3rd cs3
				inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
				inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
				inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
			where
				mb.recommend = @recommend
				and mb.roleid = 1
				and (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking=1)
				and cs3.sporttype = 161
				and cs3.bettype in (81,83,86,88)
				
			--Live
			Update cs3 with (ROWLOCK, UPDLOCK) 
				set slivepositiontaking = case when scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
										(case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end 
			from
				custsetting3rd cs3
				inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid 
				inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
				inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) 
				and mb.recommend = @recommend 
				and mb.roleid = 1
				and (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
			-------------------------------------------------------------------------------------------------------------------------------------------------  

				
			-------------------------------------------------------------------------------------------------------------------------------------------------  
			--check super min/max when a1+m1+s1<n4
			-- s1=n4-m1-a1
			--Nonlive(min)
			Update cs3 with (ROWLOCK, UPDLOCK) set 
				spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
			from 
				custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
			where cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking<sco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

			--Live(min)
			Update cs3 with (ROWLOCK, UPDLOCK) set 
				slivepositiontaking = sco3.minlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
			from 
				custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking<sco3.minlivepositiontaking

			--Nonlive(max)
			Update cs3 with (ROWLOCK, UPDLOCK) set 
				spositiontaking = sco3.maxpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
			from 
				custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
			where cs3.apositiontaking+cs3.mpositiontaking+cs3.spositiontaking>sco3.maxpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

			--Live(max)
			Update cs3 with (ROWLOCK, UPDLOCK) set 
				slivepositiontaking = sco3.maxlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
			from 
				custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
			where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking>sco3.maxlivepositiontaking
			-------------------------------------------------------------------------------------------------------------------------------------------------
		END
	END
END