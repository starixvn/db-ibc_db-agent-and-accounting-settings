ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_04] 
	@srecommend INT = 0,
	@mrecommend INT =0,
	@recommend INT = 0,
	@mode varchar(50)='',
	@sporttype INT = 0,
	@bettype INT = 0,
	@custid INT = 0,
	@roleid INT
 AS
	/*
		Created: Johnson
		Date: 2013-10-29
		Task: Apply execrep when update min/max pt on master and agent
		DB: DBTXN/bodb02
		Original versions: Acc_CustomerUpdMaster_MinMaxPositiontaking
				Acc_CustomerUpdAgent_MinMaxPositiontaking
	
		Revision:
			- 20131029@Lukas: add racing product
			- 20131030@Elodie: add virtual sports
			- 20131030@Lukas: add Live casino product
			- 20131112@Johnson: merge code sp Acc_CustSetting3rd_00 into Acc_CustSetting3rd_04 for super level
			- 20131203@Johnson: update virtual-sport for super by @sporttype not hard code in sp
		Parameter's Explanation:		
	*/ 
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @IsExistTables tinyint
	SET @IsExistTables = 0

	IF @mode = 'LiveCasino'
	BEGIN	
		SELECT @IsExistTables = COUNT(*) 
		FROM dbo.sysobjects
		WHERE	name IN ('custinfo','CustSettingGame', 'CustOverrideGame')
				AND xtype = 'U'
	END
	ELSE
	BEGIN
		SELECT @IsExistTables = COUNT(*) 
		FROM dbo.sysobjects
		WHERE	name IN ('custinfo','CustSetting3rd', 'CustOverride3rd')
				AND xtype = 'U'
	END

	IF @IsExistTables <> 3 
		RETURN
	
	declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
	
	--Update min pt on super
	IF @roleid = 4
	BEGIN		
		if @mode = 'horse'
		BEGIN
			--s1=min(s1,s4-m3) if i=0
			update cs
				set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
				and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
				and cs.sporttype between 151 and 153


			--check agent min
			--a1=max(a1,n2)
			Update cs 
				set apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
				and cs.sporttype between 151 and 153

			--check agent max
			--a1=min(a1,l2)
			Update cs 
				set apositiontaking = aco.maxpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking>aco.maxpositiontaking
				and cs.sporttype between 151 and 153
			

			--Recal AUTO MPT m1=min(m3-a1,u2)
			Update cs 
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
						then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype between 151 and 153

		    	
			
			--check master min
			--m1=max(m1,n3-a1)
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype between 151 and 153

			--check master max
			Update cs
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype between 151 and 153

			--recal autopos
			Update cs
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype between 151 and 153

			
			--check super min
			--s1=max(n4-m1-a1,s1)
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype between 151 and 153


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
		    
		END--end mode = horse
		
		if @mode = 'number'
		BEGIN
			Declare @_srecommend int
			select @_srecommend = @srecommend

			--s1=min(s1,s4-m3) if i=0
		    
			--v161
			update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.isautopositiontaking=0 and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<custsetting3rd.spositiontaking


			update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.slivepositiontaking = scs.slivepositiontaking - mcs.mlivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90)
				and custsetting3rd.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 and scs.slivepositiontaking - mcs.mlivepositiontaking<custsetting3rd.slivepositiontaking	
		    	
			--check agent min
			--a1=max(a1,n2)    
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				apositiontaking = aco.minpositiontaking,
				custsetting3rd.mpositiontaking = case when custsetting3rd.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting3rd.mpositiontaking end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.apositiontaking<aco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				alivepositiontaking = aco.minlivepositiontaking,
				custsetting3rd.mlivepositiontaking = case when custsetting3rd.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking-aco.minlivepositiontaking else custsetting3rd.mlivepositiontaking end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking<aco.minlivepositiontaking


			--check agent max
			--a1=min(a1,l2)    
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				apositiontaking = aco.maxpositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and roleid=1
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking>aco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				alivepositiontaking = aco.maxlivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking>aco.maxlivepositiontaking


			--Recal AUTO MPT m1=min(m3-a1,u2)
			
			--v161
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
				c.srecommend = @_srecommend
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
				c.srecommend = @_srecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
				and custsetting3rd.bettype in (85,86,87,89,90)
				and (acs.isautolivempositiontaking = 1 or custsetting3rd.isautolivempositiontaking = 1)	
		    

			--check master min
			--m1=max(m1,n3-a1)
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				mpositiontaking = mco.minpositiontaking-custsetting3rd.apositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking<mco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				mlivepositiontaking = mco.minlivepositiontaking-custsetting3rd.alivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking<mco.minlivepositiontaking


			--check master max   
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
				alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking

			--recal autopos   
		    	
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK)
				set spositiontaking = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
										(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
			from
				custsetting3rd
				inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			where
				c.srecommend = @_srecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
				and custsetting3rd.bettype in (81,83,89,88)
				and (custsetting3rd.isautopositiontaking=1 or mcs.isautopositiontaking=1)

			Update custsetting3rd with (ROWLOCK, UPDLOCK)
				set slivepositiontaking = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
										(case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
			from
				custsetting3rd
				inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			where
				c.srecommend = @_srecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
				and custsetting3rd.bettype in (85,86,87,89,90)
				and (custsetting3rd.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	
		    	
			
			--check super min
			--s1=max(n4-m1-a1,s1)    
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				spositiontaking = sco.minpositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @_srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and  custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking+custsetting3rd.spositiontaking<sco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				slivepositiontaking = sco.minlivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
				inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @_srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking+custsetting3rd.slivepositiontaking<sco.minlivepositiontaking

			

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
			where 
				custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

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
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

			RETURN
		END--end mode = 'number'

		if @mode = 'finance'
		BEGIN
			--s1=min(s1,s4-m3) if i=0
			update cs
				set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
				and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
				and cs.sporttype = 201


			--check agent min
			--a1=max(a1,n2)
			Update cs 
				set apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
				and cs.sporttype = 201

			--check agent max
			--a1=min(a1,l2)
			Update cs
				set apositiontaking = aco.maxpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking>aco.maxpositiontaking
				and cs.sporttype = 201


			--Recal AUTO MPT m1=min(m3-a1,um2)
			Update cs 
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype = 201

		   

			--check master min
			--m1=max(m1,n3-a1)
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype = 201

			--check master max
			Update cs 
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype = 201

			--recal autopos
			Update cs
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype = 201

			
			--check super min
			--s1=max(n4-m1-a1,s1)
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype = 201

			
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
		END--end mode = 'finance'
		
		if @mode = 'virtual-sports'
		BEGIN
			--s1=min(s1,s4-m3) if i=0
			update cs
				set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
				and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
				and cs.sporttype = @sporttype 
				and cs.bettype = @bettype

			--check agent min
			--a1=max(a1,n2)
			Update cs 
				set apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype
				
			--check agent max
			--a1=min(a1,l2)
			Update cs 
				set apositiontaking = aco.maxpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking>aco.maxpositiontaking
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype
			

			--Recal AUTO MPT m1=min(m3-a1,u2)
			Update cs 
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
						then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype

		    	
			
			--check master min
			--m1=max(m1,n3-a1)
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype
				
			--check master max
			Update cs
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype

			--recal autopos
			Update cs
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where
				c.srecommend = @srecommend
				and c.roleid = 1
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype

			--check super min
			--s1=max(n4-m1-a1,s1)
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype


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
				and cs.sporttype = @sporttype
				and cs.bettype = @bettype
			
			RETURN	
		END-- end mode = 'virtual-sports'
		if @mode = 'LiveCasino'
		BEGIN		
			--s1=min(s1,s4-m3) if i=0 & syncLC = 1
			UPDATE cs
			SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
			FROM CustSettingGame cs 
			INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
			INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
			INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
			WHERE ci.srecommend = @srecommend AND roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND (mcs.isautopositiontaking = 0 OR cs.isautopositiontaking = 0) AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking
				

			--check agent min
			--a1=max(a1,n2)
			--m1=min(m3-n2,m1)
			UPDATE cs
			SET cs.apositiontaking = aco.minpositiontaking,
				cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND cs.apositiontaking < aco.minpositiontaking


			--Recal AUTO MPT m1=min(m3-a1,u2)
			UPDATE cs
			SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
							THEN CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
							ELSE mcs.mpositiontaking - cs.apositiontaking END		
			FROM CustSettingGame cs WITH(NOLOCK)
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
				INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
				
				
			--check master min
			--m1=max(m1,n3-a1)
			UPDATE cs
			SET cs.mpositiontaking =CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 


			--recal autopos
			UPDATE cs
			SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
										CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
										ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
				
			--check super min
			--s1=max(n4-m1-a1,s1)
			UPDATE cs
			SET 
				spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			FROM 
				CustSettingGame cs
				INNER JOIN CustInfo as ci with (NOLOCK) on cs.custid = ci.custid
				INNER JOIN CustOverrideGame as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking


			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
			SET	@spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking <0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
				cs.spositiontaking = @spos,
				@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking + cs.apositiontaking END,
				@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
				@mapos  = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
				@mpos   = CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
				cs.mpositiontaking = @mpos ,
				@apos   = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
				cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
				INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
				INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
			WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking > scs.spositiontaking

			RETURN	
		END--end mode = 'LiveCasino'

	END
	
	--Update min/max pt on master
	ELSE IF @roleid = 3
	BEGIN	
		IF @mode = 'number'
		BEGIN
			--check agent min/max
			--a1=max(a1,n2)			
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				apositiontaking = aco.minpositiontaking,
				custsetting3rd.mpositiontaking = case when custsetting3rd.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting3rd.mpositiontaking end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking<aco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				alivepositiontaking = aco.minlivepositiontaking,
				custsetting3rd.mlivepositiontaking = case when custsetting3rd.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking-aco.minlivepositiontaking else custsetting3rd.mlivepositiontaking end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking<aco.minlivepositiontaking


			--a1=min(a1,l2) 			
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				apositiontaking = aco.maxpositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and  custsetting3rd.apositiontaking>aco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				alivepositiontaking = aco.maxlivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking>aco.maxlivepositiontaking

			-- Update m2,a2 when m2+a2>l3
			-- m2=max(min(m3,l3)-a2,0)
			-- a2=min(min(m3,l3)-m2,a2,n2)

			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
				alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking


			--um2=min(m3,l3) if um2>l3
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				autompositiontaking = @maxmapos
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.isautompositiontaking = 1 and custsetting3rd.autompositiontaking > mco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
				autolivempositiontaking = @maxmapos
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.isautolivempositiontaking= 1
				and custsetting3rd.autolivempositiontaking > mco.maxlivepositiontaking	

			--Recal AUTO MPT m1=min(m3-a1,u2)
			--v161
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
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
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
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
				and custsetting3rd.bettype in (85,86,87,89,90)
				and (acs.isautolivempositiontaking = 1 or custsetting3rd.isautolivempositiontaking = 1)	

			--check master min/max
			--m1=n3-a1
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				mpositiontaking = mco.minpositiontaking-custsetting3rd.apositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking<mco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				mlivepositiontaking = mco.minlivepositiontaking-custsetting3rd.alivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking<mco.minlivepositiontaking

			-- Update m1,a1 when m1+a1>l3
			-- m1=min(m3,l3)-a1
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
				mlivepositiontaking = @mpos,
				@apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
				alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking

			--recal autopos
			-- s1=min(s4-m1-a1,u)
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) 
				set spositiontaking = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
										(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
			from
				custsetting3rd
				inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			where
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
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
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and custsetting3rd.sporttype = 161
				and custsetting3rd.bettype in (85,86,87,89,90)
				and (custsetting3rd.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	
				
			--check super min/max when a1+m1+s1<n4
			-- s1=n4-m1-a1
			--v161
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				spositiontaking = sco.minpositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = 161 and  custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking+custsetting3rd.spositiontaking<sco.minpositiontaking

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				slivepositiontaking = sco.minlivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking+custsetting3rd.slivepositiontaking<sco.minlivepositiontaking

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
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

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
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				--inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

		END
		
		IF @mode = 'horse'
		BEGIN
						
			--check agent min/max
			--a1=max(a1,n2)
			Update cs
				set apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
				and cs.sporttype in (151,152,153)


			--a1=min(a1,l2) 
			Update CustSetting3rd with (ROWLOCK, UPDLOCK) set 
				apositiontaking = aco.maxpositiontaking
			from 
				CustSetting3rd as cs 
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking>aco.maxpositiontaking
				and cs.sporttype  in (151,152,153)

			-- Update m2,a2 when m2+a2>l3
			-- m2=max(min(m3,l3)-a2,0)
			-- a2=min(min(m3,l3)-m2,a2,n2)
			Update cs
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype  in (151,152,153)
				
			--um2=min(m3,l3) if um2>l3
			Update cs with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				autompositiontaking = @maxmapos
			from 
				custsetting3rd cs inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.isautompositiontaking = 1 and cs.autompositiontaking > mco.maxpositiontaking
				and cs.sporttype  in (151,152,153)

			--Recal AUTO MPT m1=min(m3-a1,u2)
			Update cs
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
						then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype  in (151,152,153)

			--check master min/max
			--m1=n3-a1
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype  in (151,152,153)

			-- Update m1,a1 when m1+a1>l3
			-- m1=min(m3,l3)-a1
			Update cs
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype  in (151,152,153)

			--recal autopos
			-- s1=min(s4-m1-a1,u)
			Update cs 
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where
				c.mrecommend = @mrecommend
				and c.roleid = 1
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype  in (151,152,153)

			--check super min/max when a1+m1+s1<n4
			-- s1=n4-m1-a1
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype  in (151,152,153)

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
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
				and cs.sporttype  in (151,152,153)

		END
		
		IF @mode = 'virtual-sports'
		BEGIN
			--check agent min/max
			--a1=max(a1,n2)
			Update cs
			set apositiontaking = aco.minpositiontaking,
				cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking<aco.minpositiontaking
				and cs.sporttype =@sporttype and cs.bettype = @bettype
				
			--a1=min(a1,l2) 
			Update custsetting3rd with (ROWLOCK, UPDLOCK) 
			set 
				apositiontaking = aco.maxpositiontaking
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = @sporttype and  custsetting3rd.apositiontaking>aco.maxpositiontaking
			
			-- Update m2,a2 when m2+a2>l3
			-- m2=max(min(m3,l3)-a2,0)
			-- a2=min(min(m3,l3)-m2,a2,n2)
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = @sporttype and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking
			
			--um2=min(m3,l3) if um2>l3
			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				autompositiontaking = @maxmapos
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = @sporttype and custsetting3rd.isautompositiontaking = 1 and custsetting3rd.autompositiontaking > mco.maxpositiontaking


			--Recal AUTO MPT m1=min(m3-a1,u2)
			Update cs
			set mpositiontaking = 
				case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
					then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
				else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid = 1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype  = @sporttype and cs.bettype = @bettype
			
			--check master min/max
			--m1=n3-a1
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype  = @sporttype and cs.bettype = @bettype
			
			-- Update m1,a1 when m1+a1>l3
			-- m1=min(m3,l3)-a1

			Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
				@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
				inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
				inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
			where custsetting3rd.sporttype = @sporttype and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

				
			--recal autopos
			-- s1=min(s4-m1-a1,u)
			Update cs 
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid = 1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype  = @sporttype and cs.bettype = @bettype
			
			--check super min/max when a1+m1+s1<n4
			-- s1=n4-m1-a1
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype  = @sporttype and cs.bettype = @bettype
			
			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)	
			--@mapos2=min(@mapos1,m3)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
			SET 
				@spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
				cs.spositiontaking = @spos,
				@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
				@mapos2 = CASE WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1 ELSE mcs.mpositiontaking END,
				@mapos  = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
				@mpos   = CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
				cs.mpositiontaking = @mpos,
				@apos   = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
				cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
			FROM CustSetting3rd cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid AND ci.mrecommend = @mrecommend AND ci.roleid = 1
				INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
				INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
				INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
			WHERE  cs.sporttype = @sporttype AND cs.bettype = @bettype
				AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
		END
		IF @mode = 'LiveCasino'
		BEGIN						
			--check agent min/max
			--a1=max(a1,n2)
			UPDATE cs
			SET cs.apositiontaking = aco.minpositiontaking,
				cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustOverride aco WITH(NOLOCK) ON aco.custid = ci.recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND cs.apositiontaking < aco.minpositiontaking

			--Recal AUTO MPT m1=min(m3-a1,u2)
			UPDATE cs
			SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
										THEN CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END  
									ELSE mcs.mpositiontaking - cs.apositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) 

			--check master min/max
			--m1=n3-a1
			UPDATE cs
			SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @custid AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking 
				
			--recal autopos
			-- s1=min(s4-m1-a1,u)
			UPDATE cs
			SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
										THEN CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
									ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101
				AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)

			--check super min/max when a1+m1+s1<n4
			-- s1=n4-m1-a1
			UPDATE cs
			SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking	

			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			UPDATE cs
			SET 
				@spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
				cs.spositiontaking = @spos,
				@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
				@mapos2 = CASE WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1 ELSE mcs.mpositiontaking END,
				@mapos  = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
				@mpos   = CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
				cs.mpositiontaking = @mpos,
				@apos   = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
				cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
			FROM CustSettingGame cs
				INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
				INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
				INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
				INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
				INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
			WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
				AND cs.sporttype = 162 AND cs.bettype = 1101 
				AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
		END
	END
	ELSE IF @roleid = 2
	BEGIN
		IF @mode = 'number'
		BEGIN			
			--check agent min/max
			-- Update a1 when a1<n2
			-- a1=n2
			--v161
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

			-- Update a1 when a1>l2
			-- a1=l2
			--v161
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

			--Recal AUTO MPT 
			--Update m1=min(m3-a1,u2)
			--v161
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

			--check master min/max
			-- Update m1 when m1+a1<n3
			-- m1=n3-a1
			--v161
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

			-- Update m1,a1 when m1+a1>l3
			-- m1=min(m3,l3)-a1
			-- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
			--v161
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

			--s1=min(s4-m1-a1,u)
			--recal autopos
			--v161
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
				
			--check super min/max
			--Update s1 when s1+m1+a1<n4
			--s1=n4-m1-a1 
			--v161
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
		END
		
		IF @mode = 'horse'
		BEGIN						
			--check agent min/max
			-- Update a1 when a1<n2
			-- a1=n2
			Update cs
				set apositiontaking = aco.minpositiontaking,
					cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking < aco.minpositiontaking
				and cs.sporttype IN ( 151,152,153)
			
			-- Update a1 when a1>l2
			-- a1=l2
			Update cs
				set apositiontaking = aco.maxpositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking > aco.maxpositiontaking
				and cs.sporttype IN ( 151,152,153)

			--Recal AUTO MPT 
			--Update m1=min(m3-a1,u2)
			Update cs
				set mpositiontaking = 
					case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
						then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					else  mcs.mpositiontaking-cs.apositiontaking end
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
			where
				c.recommend = @recommend
				and c.roleid = 1
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				and cs.sporttype IN ( 151,152,153)				
			
			--check master min/max
			-- Update m1 when m1+a1<n3
			-- m1=n3-a1
			Update cs
				set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
				and cs.sporttype IN ( 151,152,153)
			
			-- Update m1,a1 when m1+a1>l3
			-- m1=min(m3,l3)-a1
			-- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
			Update cs 
				set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
					@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
					mpositiontaking = @mpos,
					@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
					apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
				and cs.sporttype IN ( 151,152,153)
			
			--s1=min(s4-m1-a1,u)
			--recal autopos
			Update cs 
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
			where
				c.recommend = @recommend
				and c.roleid = 1
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
				and cs.sporttype IN ( 151,152,153)

			--check super min/max
			--Update s1 when s1+m1+a1<n4
			--s1=n4-m1-a1 
			Update cs
				set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
			from 
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
				and cs.sporttype IN ( 151,152,153)

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
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
			where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
				and cs.sporttype IN ( 151,152,153)
		END
		
		IF @mode = 'virtual-sports'
		BEGIN
			--check agent min/max  
			-- Update a1 when a1<n2  
			-- a1=n2  
			Update cs  
			set apositiontaking = aco.minpositiontaking,  
				cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end  
			from   
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype  
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype  
			where cs.apositiontaking < aco.minpositiontaking  
				and cs.sporttype = @sporttype  
			  
			  
			-- Update a1 when a1>l2  
			-- a1=l2  
			Update cs  
			set apositiontaking = aco.maxpositiontaking  
			from   
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype  
			where cs.apositiontaking > aco.maxpositiontaking  
				and cs.sporttype = @sporttype  
			  
			--Recal AUTO MPT   
			--Update m1=min(m3-a1,u2)  
			Update cs  
			set mpositiontaking =   
				case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)  
				then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)  
				else  mcs.mpositiontaking-cs.apositiontaking end  
			from  
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid  
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype  
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype  
			where  
				c.recommend = @recommend  
				and c.roleid = 1  
				and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  
				and cs.sporttype = @sporttype  			    			  
			  
			--check master min/max  
			-- Update m1 when m1+a1<n3  
			-- m1=n3-a1  
			Update cs  
			set mpositiontaking = mco.minpositiontaking-cs.apositiontaking  
			from   
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype  
			where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking  
				and cs.sporttype = @sporttype  
			  			  			  
			-- Update m1,a1 when m1+a1>l3  
			-- m1=min(m3,l3)-a1  
			-- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)  
			Update cs   
			set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,  
				@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,  
				mpositiontaking = @mpos,  
				@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,  
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end  
			from   
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype  
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype  
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype  
			where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking  
			 and cs.sporttype = @sporttype  			 	  
			  
			--s1=min(s4-m1-a1,u)  
			--recal autopos  
			Update cs   
			set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >  
				(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end   
			from  
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid  
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype  
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype  
			where  
				c.recommend = @recommend  
				and c.roleid = 1  
				and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)  
				and cs.sporttype = @sporttype  
			   			    
			--check super min/max  
			--Update s1 when s1+m1+a1<n4  
			--s1=n4-m1-a1   
			Update cs  
			set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking  
			from   
				CustSetting3rd as cs with (ROWLOCK, UPDLOCK)  
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype  
			where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking  
				and cs.sporttype = @sporttype  
			  
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
				inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1  
				inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype  
				inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype  
				inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype  
				inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype  
			where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking  
				and cs.sporttype = @sporttype  
		END
		IF @mode = 'LiveCasino'
		BEGIN	
			SELECT	@recommend = custid,
					@srecommend = srecommend
			FROM custinfo WITH(NOLOCK)
			WHERE custid = @custid

			--check agent min/max
			-- Update a1 when a1<n2
			-- a1=n2
			Update csg with(ROWLOCK, UPDLOCK) 
			set 
				apositiontaking = aco.minpositiontaking,
				mpositiontaking = case when csg.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else csg.mpositiontaking end
			from custsettingGame csg 
				inner join custinfo as mb with (NOLOCK) on csg.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
				inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=csg.sporttype and mcs.bettype=csg.bettype
				inner join custoverridegame as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=csg.sporttype and aco.bettype=csg.bettype
			where csg.apositiontaking < aco.minpositiontaking
				AND csg.sporttype = 162 AND csg.bettype = 1101


			--Recal AUTO MPT 
			--Update m1=min(m3-a1,u2)
			Update custsettingGame with (ROWLOCK, UPDLOCK) 
			set mpositiontaking = 
					case when mcs.mpositiontaking-custsettingGame.apositiontaking > case when custsettingGame.isautompositiontaking = 1 then custsettingGame.autompositiontaking else acs.autompositiontaking end
						then case when custsettingGame.isautompositiontaking = 1 then custsettingGame.autompositiontaking else acs.autompositiontaking end
					else  mcs.mpositiontaking-custsettingGame.apositiontaking end
			from
				custsettingGame
				inner join custinfo as c with (NOLOCK) on custsettingGame.custid = c.custid
				inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
				inner join custsettingGame as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsettingGame.sporttype and acs.bettype=custsettingGame.bettype
			where
				c.recommend = @recommend
				and c.roleid = 1 and c.SyncLiveCasino = 1
			and (acs.isautompositiontaking = 1 or custsettingGame.isautompositiontaking = 1)


			--check master min/max
			-- Update m1 when m1+a1<n3
			-- m1=n3-a1
			Update custsettingGame with (ROWLOCK, UPDLOCK) set 
				mpositiontaking = mco.minpositiontaking-custsettingGame.apositiontaking
			from 
				custsettingGame 
				inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
				inner join custoverrideGame as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsettingGame.sporttype and mco.bettype=custsettingGame.bettype
			where custsettingGame.apositiontaking+custsettingGame.mpositiontaking<mco.minpositiontaking

			

			--s1=min(s4-m1-a1,u)
			--recal autopos
			Update custsettingGame with (ROWLOCK, UPDLOCK) 
				set spositiontaking = case when scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking >
										(case when custsettingGame.isautopositiontaking=1 then custsettingGame.autopositiontaking else mcs.autopositiontaking end) then (case when custsettingGame.isautopositiontaking=1 then custsettingGame.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking end 
			from
				custsettingGame
				inner join custinfo as c with (NOLOCK) on custsettingGame.custid = c.custid
				inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
				inner join custsettingGame as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsettingGame.sporttype and scs.bettype=custsettingGame.bettype
			where
				c.recommend = @recommend
				and c.roleid = 1 and c.SyncLiveCasino = 1
				and (custsettingGame.isautopositiontaking=1 or mcs.isautopositiontaking=1)

			--check super min/max
			--Update s1 when s1+m1+a1<n4
			--s1=n4-m1-a1 
			Update custsettingGame with (ROWLOCK, UPDLOCK) set 
				spositiontaking = sco.minpositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking
			from 
				custsettingGame inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
				inner join custoverrideGame as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsettingGame.sporttype and sco.bettype=custsettingGame.bettype
			where custsettingGame.apositiontaking+custsettingGame.mpositiontaking+custsettingGame.spositiontaking<sco.minpositiontaking


			--update s1,m1,a1 in case s1+m1+a1>s4
			--s1=max(0,s4-m1-a1)
			--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
			--@maxmapos=min(m3,l3)
			--@mapos2=min(@mapos1,@maxmapos)
			--@mapos=max(@mapos2,n3)
			--m1=max(0,@mapos-a1)
			--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
			Update custsettingGame with (ROWLOCK, UPDLOCK) set 
				@spos = case when scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking<0 then 0 else scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking end,
				spositiontaking = @spos,
				@mapos1 = case when @spos+custsettingGame.mpositiontaking+custsettingGame.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else custsettingGame.mpositiontaking+custsettingGame.apositiontaking end,
				--@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
				@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
				@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
				@mpos = case when @mapos-custsettingGame.apositiontaking<0 then 0 else @mapos-custsettingGame.apositiontaking end,
				mpositiontaking = @mpos,
				@apos = case when custsettingGame.apositiontaking + @mpos>@mapos then @mapos-@mpos else custsettingGame.apositiontaking end,
				apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
			from 
				custsettingGame inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
				inner join custsettingGame as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsettingGame.sporttype and scs.bettype=custsettingGame.bettype
				inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
				inner join custoverrideGame as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsettingGame.sporttype and mco.bettype=custsettingGame.bettype
				inner join custoverrideGame as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsettingGame.sporttype and aco.bettype=custsettingGame.bettype
			where custsettingGame.spositiontaking+custsettingGame.apositiontaking+custsettingGame.mpositiontaking>scs.spositiontaking

		END
	END
	
END


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_04] TO [vnteam] AS [dbo]