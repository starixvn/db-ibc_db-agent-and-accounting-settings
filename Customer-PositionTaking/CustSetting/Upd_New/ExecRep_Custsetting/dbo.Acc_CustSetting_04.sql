
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustSetting_04    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustSetting_04    Script Date: 8/21/2014 2:58:10 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustSetting_04]
    @srecommend INT = 0,
    @mrecommend INT =0,
    @recommend INT = 0,
    @roleid INT
 AS
    /*
        Created: Johnson
        Date: 2013-10-29
        Task: Apply execrep WHEN UPDATE min/max pt ON master AND agent
        DB: DBCUST/custDB
        Original versions: Acc_CustomerUpdMaster_MinMaxPositiontaking
                        Acc_CustomerUpdAgent_MinMaxPositiontaking
        
        Revision:
            - 20131112@Johnson: merge code sp Acc_CustSetting_00 into Acc_CustSetting_04 for super level
            - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                                2.Code aligning on modified parts
		  - 20150610@Daniel: 
		   + Improve medthod check table existing in subscribers	
		   + Separate custDB to new server DBCUST                                

        Parameter's Explanation:        
    */
BEGIN
    SET NOCOUNT ON
    
     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
     RETURN
        
    declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
    
    --UPDATE min pt ON super
    IF @roleid = 4
    BEGIN
        DECLARE @_srecommend INT
        SELECT @_srecommend = @srecommend
        
        --s1=min(s1,s4-m3) if i=0
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
          
           SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE cs.isautopositiontaking = 0
           AND mcs.isautopositiontaking = 0
           AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET cs.slivepositiontaking = scs.slivepositiontaking - mcs.mlivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.isautolivepositiontaking = 0
           AND mcs.isautolivepositiontaking = 0
           AND scs.slivepositiontaking - mcs.mlivepositiontaking < cs.slivepositiontaking


        --check agent min
        --a1=max(a1,n2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.minpositiontaking
             , cs.mpositiontaking =
                 CASE
                   WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                   ELSE cs.mpositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking < aco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.minlivepositiontaking
             , cs.mlivepositiontaking =
                 CASE
                   WHEN cs.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking - aco.minlivepositiontaking
                   ELSE cs.mlivepositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking < aco.minlivepositiontaking


        --check agent max
        --a1=min(a1,l2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.maxpositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking > aco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.maxlivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking > aco.maxlivepositiontaking


        --Recal AUTO MPT m1=min(m3-a1,u2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mpositiontaking = 
                 CASE
                   WHEN mcs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                   ELSE mcs.mpositiontaking - cs.apositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.srecommend = @_srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautompositiontaking = 1
                OR cs.isautompositiontaking = 1)
                
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mlivepositiontaking =
                 CASE
                   WHEN mcs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking
                          END
                        THEN CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking
                          END
                   ELSE mcs.mlivepositiontaking - cs.alivepositiontaking
                 END
          FROM custsetting cs 
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.srecommend = @_srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautolivempositiontaking = 1
                OR cs.isautolivempositiontaking = 1
               )
            
        --check master min
        --m1=max(m1,n3-a1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking


        --check master max
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking > mco.maxlivepositiontaking


        --recal autopos
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END 
            FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
          WHERE c.srecommend = @_srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautopositiontaking = 1
                OR mcs.isautopositiontaking = 1
               )


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END 
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.srecommend = @_srecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautolivepositiontaking = 1
                OR mcs.isautolivepositiontaking = 1
               )


        --check super min
        --s1=max(n4-m1-a1,s1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @_srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @_srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.sporttype = 1
            AND cs.bettype IN (1, 3, 7, 8)
            AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking


        --UPDATE s1,m1,a1 IN case s1+m1+a1>s4
        --s1=max(0,s4-m1-a1)
        --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
        --@maxmapos=min(m3,l3)
        --@mapos2=min(@mapos1,@maxmapos)
        --@mapos=max(@mapos2,n3)
        --m1=max(0,@mapos-a1)
        --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @spos =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END
             , spositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                   ELSE cs.mpositiontaking + cs.apositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.apositiontaking < 0 THEN 0
                   ELSE @mapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @spos =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking < 0 THEN 0
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END
             , slivepositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos
                   ELSE cs.mlivepositiontaking + cs.alivepositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mco.minlivepositiontaking THEN mco.minlivepositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @mapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.srecommend = @_srecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @_srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = mb.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = mb.mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > scs.slivepositiontaking

    END
    --UPDATE min/max pt ON master
    ELSE IF @roleid = 3
    BEGIN
        --check agent min/max
        --a1=max(a1,n2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.minpositiontaking
             , cs.mpositiontaking =
                 CASE
                   WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking
                   ELSE cs.mpositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking < aco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.minlivepositiontaking
             , cs.mlivepositiontaking =
                 CASE
                   WHEN cs.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking - aco.minlivepositiontaking
                   ELSE cs.mlivepositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking < aco.minlivepositiontaking


        --a1=min(a1,l2) 
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET apositiontaking = aco.maxpositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking > aco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET alivepositiontaking = aco.maxlivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking > aco.maxlivepositiontaking

        -- UPDATE m2,a2 WHEN m2+a2>l3
        -- m2=max(min(m3,l3)-a2,0)
        -- a2=min(min(m3,l3)-m2,a2,n2)
        UPDATE cs with(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb with(NOLOCK) ON cs.custid     = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid     = 2
                                       AND mb.Enabled    = 1
    INNER JOIN custsetting mcs with(NOLOCK) ON mcs.custid    = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype   = cs.bettype
    INNER JOIN custoverride mco with(NOLOCK) ON mco.custid    = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype   = cs.bettype
    INNER JOIN custoverride aco with(NOLOCK) ON aco.custid    = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype   = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking


        UPDATE cs with(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb with(NOLOCK) ON cs.custid     = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid     = 2
                                       AND mb.Enabled    = 1
    INNER JOIN custsetting mcs with(NOLOCK) ON mcs.custid    = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype   = cs.bettype
    INNER JOIN custoverride mco with(NOLOCK) ON mco.custid    = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype   = cs.bettype
    INNER JOIN custoverride aco with(NOLOCK) ON aco.custid    = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype   = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking > mco.maxlivepositiontaking


        --um2=min(m3,l3) if um2>l3
        UPDATE cs with(ROWLOCK, UPDLOCK)
          
           SET @maxmapos = CASE
                             WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                             ELSE mcs.mpositiontaking
                           END
             , autompositiontaking = @maxmapos
          FROM custsetting cs
    INNER JOIN custinfo mb with(NOLOCK) ON cs.custid     = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid     = 2
                                       AND mb.Enabled    = 1
    INNER JOIN custsetting mcs with(NOLOCK) ON mcs.custid    = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype   = cs.bettype
    INNER JOIN custoverride mco with(NOLOCK) ON mco.custid    = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype   = cs.bettype
         WHERE cs.isautompositiontaking = 1
           AND cs.autompositiontaking > mco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                CASE
                  WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                  ELSE mcs.mlivepositiontaking
                END
             , autolivempositiontaking = @maxmapos
          FROM custsetting cs
    INNER JOIN custinfo mb with(NOLOCK) ON cs.custid     = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid     = 2
                                       AND mb.Enabled    = 1
    INNER JOIN custsetting mcs with(NOLOCK) ON mcs.custid    = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype   = cs.bettype
    INNER JOIN custoverride mco with(NOLOCK) ON mco.custid    = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype   = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.isautolivempositiontaking = 1
           AND cs.autolivempositiontaking > mco.maxlivepositiontaking


        --Recal AUTO MPT m1=min(m3-a1,u2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mpositiontaking =
                 CASE
                   WHEN mcs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking
                            ELSE acs.autompositiontaking
                          END
                   ELSE mcs.mpositiontaking - cs.apositiontaking
                 END
             FROM custsetting cs 
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautompositiontaking = 1
                OR cs.isautompositiontaking = 1
               )


        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET mlivepositiontaking =
                 CASE
                   WHEN mcs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking
                            ELSE acs.autolivempositiontaking
                          END
                   ELSE mcs.mlivepositiontaking - cs.alivepositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                           AND acs.sporttype = cs.sporttype
                                           AND acs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (acs.isautolivempositiontaking = 1
                OR cs.isautolivempositiontaking = 1
               )


        --check master min/max
        --m1=n3-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mpositiontaking = mco.minpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking


        -- UPDATE m1,a1 WHEN m1+a1>l3
        -- m1=min(m3,l3)-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.apositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @maxmapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
             FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking > mco.maxlivepositiontaking


        --recal autopos
        -- s1=min(s4-m1-a1,u)
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                          CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking
                            ELSE mcs.autopositiontaking
                          END
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END 
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautopositiontaking = 1
                OR mcs.isautopositiontaking = 1
               )


        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                          CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                     THEN CASE
                            WHEN cs.isautolivepositiontaking = 1 THEN cs.autolivepositiontaking
                            ELSE mcs.autolivepositiontaking
                          END
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
         WHERE c.mrecommend = @mrecommend
           AND c.roleid = 1
           AND c.Enabled = 1
           AND (cs.isautolivepositiontaking = 1
                OR mcs.isautolivepositiontaking = 1
               )


        --check super min/max WHEN a1+m1+s1<n4
        -- s1=n4-m1-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                            AND sco.sporttype = cs.sporttype
                                            AND sco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking


        --UPDATE s1,m1,a1 IN case s1+m1+a1>s4
        --s1=max(0,s4-m1-a1)
        --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
        --@maxmapos=min(m3,l3)
        --@mapos2=min(@mapos1,@maxmapos)
        --@mapos=max(@mapos2,n3)
        --m1=max(0,@mapos-a1)
        --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @spos =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0
                   ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
                 END
             , spositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos
                   ELSE cs.mpositiontaking + cs.apositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking
                   ELSE mcs.mpositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.apositiontaking < 0 THEN 0
                   ELSE @mapos - cs.apositiontaking
                 END
             , mpositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.apositiontaking
                 END
             , apositiontaking =
                 CASE
                   WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
        WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET @spos =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking < 0 THEN 0
                   ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
                 END
             , slivepositiontaking = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos
                   ELSE cs.mlivepositiontaking + cs.alivepositiontaking
                 END
             , @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking
                   ELSE mcs.mlivepositiontaking
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < mco.minlivepositiontaking THEN mco.minlivepositiontaking
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - cs.alivepositiontaking < 0 THEN 0
                   ELSE @mapos - cs.alivepositiontaking
                 END
             , mlivepositiontaking = @mpos
             , @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos > @mapos THEN @mapos - @mpos
                   ELSE cs.alivepositiontaking
                 END
             , alivepositiontaking =
                 CASE
                   WHEN @apos < aco.minlivepositiontaking THEN aco.minlivepositiontaking
                   ELSE @apos
                 END
          FROM custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.mrecommend = @mrecommend
                                       AND mb.roleid = 1
                                       AND mb.Enabled = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                           AND scs.sporttype = cs.sporttype
                                           AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                           AND mcs.sporttype = cs.sporttype
                                           AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                            AND mco.sporttype = cs.sporttype
                                            AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = mb.recommend
                                            AND aco.sporttype = cs.sporttype
                                            AND aco.bettype = cs.bettype
         WHERE cs.sporttype = 1
           AND cs.bettype IN (1, 3, 7, 8)
           AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > scs.slivepositiontaking

    END
    
    --UPDATE min/max pt ON agent
    ELSE IF @roleid = 2
    BEGIN                    
        --check agent min/max
        -- UPDATE a1 WHEN a1<n2
        -- a1=n2
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            apositiontaking = aco.minpositiontaking,
            cs.mpositiontaking =
                 CASE
                   WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking-aco.minpositiontaking ELSE cs.mpositiontaking END
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.apositiontaking<aco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            alivepositiontaking = aco.minlivepositiontaking,
            cs.mlivepositiontaking =
                 CASE
                   WHEN cs.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking THEN mcs.mlivepositiontaking-aco.minlivepositiontaking ELSE cs.mlivepositiontaking END
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking<aco.minlivepositiontaking

        -- UPDATE a1 WHEN a1>l2
        -- a1=l2
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            apositiontaking = aco.maxpositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.apositiontaking>aco.maxpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            alivepositiontaking = aco.maxlivepositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking>aco.maxlivepositiontaking

        --Recal AUTO MPT 
        --UPDATE m1=min(m3-a1,u2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
        SET mpositiontaking = 
                CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
                    then CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
                ELSE mcs.mpositiontaking - cs.apositiontaking END
        from
            custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                       AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                       AND acs.sporttype = cs.sporttype
                                       AND acs.bettype = cs.bettype
        where
            c.recommend = @recommend
           AND c.roleid = 1
        AND (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
            
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
        SET mlivepositiontaking =
                CASE WHEN mcs.mlivepositiontaking - cs.alivepositiontaking > CASE WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking ELSE acs.autolivempositiontaking END
                    then CASE WHEN cs.isautolivempositiontaking = 1 THEN cs.autolivempositiontaking ELSE acs.autolivempositiontaking END
                ELSE mcs.mlivepositiontaking - cs.alivepositiontaking END
        from
            custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                       AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend
                                       AND acs.sporttype = cs.sporttype
                                       AND acs.bettype = cs.bettype
        where
            c.recommend = @recommend
           AND c.roleid = 1
           AND (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1)
        
        --check master min/max
        -- UPDATE m1 WHEN m1+a1<n3
        -- m1=n3-a1
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            mpositiontaking = mco.minpositiontaking - cs.apositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
        WHERE cs.apositiontaking + cs.mpositiontaking<mco.minpositiontaking


        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking + cs.mlivepositiontaking<mco.minlivepositiontaking

        -- UPDATE m1,a1 WHEN m1+a1>l3
        -- m1=min(m3,l3)-a1
        -- a1=max(iif(m1+a1>min(m3,l3),min(m3,l3)-m1,a1),n2)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END
            ,
            @mpos =
                 CASE
                   WHEN @maxmapos - cs.apositiontaking < 0 THEN 0 ELSE @maxmapos - cs.apositiontaking END
            ,
            mpositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs.apositiontaking END
            ,
            apositiontaking =
                 CASE
                   WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.apositiontaking + cs.mpositiontaking > mco.maxpositiontaking

        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking ELSE mcs.mlivepositiontaking END
            ,
            @mpos =
                 CASE
                   WHEN @maxmapos - cs.alivepositiontaking < 0 THEN 0 ELSE @maxmapos - cs.alivepositiontaking END
            ,
            mlivepositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE cs.alivepositiontaking END
            ,
            alivepositiontaking =
                 CASE
                   WHEN @apos<aco.minlivepositiontaking THEN aco.minlivepositiontaking ELSE @apos END
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking + cs.mlivepositiontaking > mco.maxlivepositiontaking

        --s1=min(s4-m1-a1,u)
        --recal autopos
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
            SET spositiontaking =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking >
                                    (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN (CASE WHEN cs.isautopositiontaking=1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END 
        from
            custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                       AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                       AND scs.sporttype = cs.sporttype
                                       AND scs.bettype = cs.bettype
        where
            c.recommend = @recommend
           AND c.roleid = 1
           AND (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)

        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
            SET slivepositiontaking =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking >
                                    (CASE WHEN cs.isautolivepositiontaking=1 THEN cs.autolivepositiontaking ELSE mcs.autolivepositiontaking END) THEN (CASE WHEN cs.isautolivepositiontaking=1 THEN cs.autolivepositiontaking ELSE mcs.autolivepositiontaking END) ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking END 
        from
            custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = c.mrecommend
                                       AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                       AND scs.sporttype = cs.sporttype
                                       AND scs.bettype = cs.bettype
        where
            c.recommend = @recommend
           AND c.roleid = 1
           AND (cs.isautolivepositiontaking = 1
                OR mcs.isautolivepositiontaking = 1)
        
        --check super min/max
        --UPDATE s1 WHEN s1+m1+a1<n4
        --s1=n4-m1-a1 
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                     AND sco.sporttype = cs.sporttype
                                       AND sco.bettype = cs.bettype
        WHERE cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking

        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custoverride sco WITH(NOLOCK) ON sco.custid = @srecommend
                                     AND sco.sporttype = cs.sporttype
                                       AND sco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking
        
        --UPDATE s1,m1,a1 IN case s1+m1+a1>s4
        --s1=max(0,s4-m1-a1)
        --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
        --@maxmapos=min(m3,l3)
        --@mapos2=min(@mapos1,@maxmapos)
        --@mapos=max(@mapos2,n3)
        --m1=max(0,@mapos-a1)
        --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @spos =
                 CASE
                   WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
            ,
            spositiontaking = @spos,
            @mapos1 =
                 CASE
                   WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END
            ,
            @maxmapos =
                 CASE
                   WHEN mcs.mpositiontaking > mco.maxpositiontaking THEN mco.maxpositiontaking ELSE mcs.mpositiontaking END
            ,
            @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos ELSE @mapos1 END
            ,
            @mapos =
                 CASE
                   WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END
            ,
            @mpos =
                 CASE
                   WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END
            ,
            mpositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN cs.apositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs.apositiontaking END
            ,
            apositiontaking =
                 CASE
                   WHEN @apos<aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
        FROM 
            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                     AND scs.sporttype = cs.sporttype
                                       AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.spositiontaking + cs.apositiontaking + cs.mpositiontaking > scs.spositiontaking

        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET 
            @spos =
                 CASE
                   WHEN scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking < 0 THEN 0 ELSE scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking END
            ,
            slivepositiontaking = @spos,
            @mapos1 =
                 CASE
                   WHEN @spos + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking THEN scs.slivepositiontaking - @spos ELSE cs.mlivepositiontaking + cs.alivepositiontaking END
            ,
            @maxmapos =
                 CASE
                   WHEN mcs.mlivepositiontaking > mco.maxlivepositiontaking THEN mco.maxlivepositiontaking ELSE mcs.mlivepositiontaking END
            ,
            @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos ELSE @mapos1 END
            ,
            @mapos =
                 CASE
                   WHEN @mapos2 < mco.minlivepositiontaking THEN mco.minlivepositiontaking ELSE @mapos2 END
            ,
            @mpos =
                 CASE
                   WHEN @mapos - cs.alivepositiontaking < 0 THEN 0 ELSE @mapos - cs.alivepositiontaking END
            ,
            mlivepositiontaking = @mpos,
            @apos =
                 CASE
                   WHEN cs.alivepositiontaking + @mpos>@mapos THEN @mapos-@mpos ELSE cs.alivepositiontaking END
            ,
            alivepositiontaking =
                 CASE
                   WHEN @apos<aco.minlivepositiontaking THEN aco.minlivepositiontaking ELSE @apos END
        FROM 

            custsetting cs
    INNER JOIN custinfo mb WITH(NOLOCK) ON cs.custid = mb.custid
                                       AND mb.recommend=@recommend
                                       AND mb.roleid = 1
    INNER JOIN custsetting scs WITH(NOLOCK) ON scs.custid = @srecommend
                                     AND scs.sporttype = cs.sporttype
                                       AND scs.bettype = cs.bettype
    INNER JOIN custsetting mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
                                     AND mcs.sporttype = cs.sporttype
                                       AND mcs.bettype = cs.bettype
    INNER JOIN custoverride mco WITH(NOLOCK) ON mco.custid = @mrecommend
                                     AND mco.sporttype = cs.sporttype
                                       AND mco.bettype = cs.bettype
    INNER JOIN custoverride aco WITH(NOLOCK) ON aco.custid = @recommend
                                     AND aco.sporttype = cs.sporttype
                                       AND aco.bettype = cs.bettype
        WHERE cs.sporttype = 1 AND cs.bettype IN (1, 3, 7, 8) AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > scs.slivepositiontaking
        
    END
    
END



GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
