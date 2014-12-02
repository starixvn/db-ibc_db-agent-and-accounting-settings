
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_CustSetting3rd_06    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustSetting3rd_06    Script Date: 8/21/2014 2:58:10 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_06]
    @CustId int,
    @RoleId int,
    @discountNumber decimal(9,8)    = 0, -- Number game

    @v151discount_31 decimal(9,8)   = 0, -- Horse Racing
    @v151discount_41 decimal(9,8)   = 0, 
    @v151discount_51 decimal(9,8)   = 0,
    @v152discount_41 decimal(9,8)   = 0,
    @v152discount_51 decimal(9,8)   = 0,
    @v153discount_51 decimal(9,8)   = 0,

    @v162discount_1101 DECIMAL(9,8) = 0,-- Live Casino
    @mode varchar(30),
    @Sporttype INT = 202, 
    @Bettype INT = 1501, 
    @Discount DECIMAL(9,8) = 0,
    /*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
	@Discount_XML VARCHAR(MAX) = NULL
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
AS
/*
    Created: Kathy
    Date: 20131029
    Task : Update commission [Redmine:#3244]
    DB: DBTXN/CustDB
    Original: 
    Revisions:
        - 20131029@Kathy: Update NumberGame's commission for all level. Refer to:
            + Acc_CustomerUpdSuper_Commission
            + Acc_CustomerUpdMaster_Commission
            + Acc_CustomerUpdAgent_Commission
            + Acc_CustomerUpdMember_Commission
        - 20131030@Kathy: Apply exec rep for all level Horse Racing. Refer to:
            + Acc_CustomerUpdSuper_CommissionHR
            + Acc_CustomerUpdMaster_CommissionHR
            + Acc_CustomerUpdAgent_CommissionHR
            + Acc_CustomerUpdMember_CommissionHR
        - 20131031@Kathy: Apply exec rep for super, master, agent level Live Casino. Refer to:
            + Acc_CustomerUpdSuperLiveCS_Commission
            + Acc_CustomerUpdMasterLiveCS_Commission
            + Acc_CustomerUpdAgentLiveCS_Commission
        - 20131118@Kathy: Update live casino commission for super and all downlines. Refer to:
            + Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels                        
        - 20131122@Francis: Add checking for super Deposit Type
            + If super is Deposit, do not update commission on its downline members for LiveCasino
        - 20140227@Elodie: Add Keno sport [Redmine:#11658]
        - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                            2.Code aligning on modified parts
    Param's Explanation: 
        @mode: 
                - 'Numbergame': Number game
                - 'HorseRacing': Horse Racing
                - 'LiveCasino': Live Casino
                - 'Keno': Keno
                - 'LiveCasinoUpdAll': Update LC commision for super and downlines
            
    */
BEGIN
    SET NOCOUNT ON;
    -- check existing tables
    IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('custsetting3rd','CustSettingGame', 'custinfo', 'customer', 'Dep_CustSuper') AND type = 'U') < 5
        RETURN
    
    IF @Mode = 'NumberGame'
    BEGIN
        IF @RoleId = 4
        BEGIN
            UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
            SET
                sdiscount = @discountNumber
             WHERE custid = @custid and sporttype = 161

            --Update s4 to member level --number game
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.sdiscount = @discountNumber
              FROM custsetting3rd cs
        INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid    
             WHERE c.srecommend = @custid
               AND c.recommend <> 52466
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs.sporttype = 161


            --Update m3=s4 if m3>s4  --number game
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET 
                adiscount = @discountNumber
              FROM custsetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) 
                ON cs.custid = ci.custid
             WHERE ci.srecommend = @custid 
                AND ci.roleid = 3 
                AND cs.sporttype = 161 
                AND cs.adiscount>@discountNumber
            
            --Update a2=s4 if a2>s4  --number game
            UPDATE c3d WITH(ROWLOCK, UPDLOCK) 
               SET discount = @discountNumber
              FROM custsetting3rd c3d
        INNER JOIN custinfo ci WITH(NOLOCK) ON c3d.custid = ci.custid
             WHERE ci.srecommend = @custid 
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND sporttype     = 161
               AND discount      > @discountNumber

            --At member level, update adiscount = sdiscount  if adiscount > sdiscount  (Number Game)
            UPDATE c3d WITH(ROWLOCK, UPDLOCK) 
               SET adiscount = sdiscount
              FROM custsetting3rd c3d
        INNER JOIN custInfo c WITH(NOLOCK) ON c3d.custid = c.custid
             WHERE c.srecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND c3d.adiscount > c3d.sdiscount
               AND c3d.sporttype = 161

            --At member level, update discount = adiscount  if discount > adiscount -- Number Game
            UPDATE c3d WITH(ROWLOCK, UPDLOCK) 
               SET discount = adiscount
              FROM custsetting3rd c3d
        INNER JOIN custInfo c WITH(NOLOCK) ON c3d.custid = c.custid
             WHERE c.srecommend = @custid 
               AND c.roleid = 1
               AND c.Enabled = 1
               AND c3d.discount > c3d.adiscount
               AND c3d.sporttype = 161


            --At member level, update playerdiscount = discount  if playerdiscount > discount --Number Game
            UPDATE c3d WITH (ROWLOCK, UPDLOCK) 
               SET playerdiscount = discount
              FROM custsetting3rd c3d
        INNER JOIN custInfo c WITH(NOLOCK) ON c3d.custid = c.custid
             WHERE c.srecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND c3d.playerdiscount > c3d.discount
               AND c3d.sporttype = 161
        END

        --Master
        IF @RoleId = 3
        BEGIN
            -- number game commission - update master discount
            UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
            SET    adiscount = @discountNumber
             WHERE custid=@custid 
                and sporttype = 161

            -- number game - update agent discount
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK) 
               SET cs3.discount =
                     CASE
                       WHEN cs3.discount > @discountNumber THEN @discountNumber
                       ELSE cs3.discount
                     END 
              FROM custsetting3rd cs3 
        INNER JOIN custinfo ci WITH(NOLOCK) ON cs3.custid = ci.custid
             WHERE ci.mrecommend = @custid 
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND sporttype     = 161    


            -- number game - update master-discount on member
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.adiscount = @discountNumber
              FROM custsetting3rd cs3 
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
             WHERE c.mrecommend = @custid
               AND c.recommend <> 52466
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161


            -- number game - update agent discount on member
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.discount = cs3.adiscount
              FROM custsetting3rd cs3
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
             WHERE c.mrecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.discount > cs3.adiscount


            -- number game - update agent discount on member
            UPDATE cs3 WITH(ROWLOCK, UPDLOCK)
               SET cs3.playerdiscount = cs3.discount
              FROM custsetting3rd cs3 
        INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
             WHERE c.mrecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs3.sporttype = 161
               AND cs3.playerdiscount > cs3.discount
        END

        IF @RoleId = 2
        BEGIN
            -- number game commission
            Update custsetting3rd with(rowlock,updlock) 
               SET discount = @discountNumber
             WHERE custid = @custid 
                and sporttype = 161

            UPDATE cs3 WITH (ROWLOCK, UPDLOCK) 
               SET     cs3.discount = @discountNumber
              FROM custsetting3rd cs3 
            INNER JOIN customer c WITH(NOLOCK) 
                ON cs3.custid = c.custid
             WHERE c.recommend = @custid 
                AND c.recommend <> 52466
                AND c.roleid = 1 
                AND cs3.sporttype = 161

            UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
            SET
                cs3.playerdiscount = cs3.discount 
              FROM custsetting3rd cs3 
            INNER JOIN customer AS c WITH(NOLOCK) 
                ON cs3.custid = c.custid
             WHERE c.recommend = @custid 
                AND c.roleid = 1 
                AND cs3.playerdiscount > cs3.discount
        END
        IF @RoleId = 1
        BEGIN
            UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
            SET
                playerdiscount = @discountNumber
             WHERE custid = @custid AND Sporttype = 161
        END
    END
    IF @mode = 'HorseRacing'
    BEGIN
        DECLARE @db_v151discount_31 DECIMAL(9,8) , 
                @db_v151discount_41 DECIMAL(9,8),
                @db_v151discount_51 DECIMAL(9,8),
                @db_v152discount_41 DECIMAL(9,8),
                @db_v152discount_51 DECIMAL(9,8),
                @db_v153discount_51 DECIMAL(9,8)

        IF @RoleId = 4
        BEGIN
            SELECT 
                @db_v151discount_31 =  sdiscount -- @db_v151discount_31
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 31 
                AND sporttype = 151

            SELECT 
                @db_v151discount_41 =  sdiscount -- @db_v151discount_41
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 41 
                AND sporttype = 151

            SELECT 
                @db_v151discount_51 =  sdiscount -- @db_v151discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 51 
                AND sporttype = 151

            SELECT 
                @db_v152discount_41 =  sdiscount -- @db_v152discount_41
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 41 
                AND sporttype = 152

            SELECT 
                @db_v152discount_51 =  sdiscount -- @db_v152discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 51 
                AND sporttype = 152

            SELECT 
                @db_v153discount_51 =  sdiscount -- @db_v153discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 51 
                AND sporttype = 153

            --Update @Super: g4, s4
            UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
            SET
                sdiscount =
                     CASE
                       WHEN bettype IN (31,32) AND sporttype = 151 THEN @v151discount_31 
                                 WHEN bettype IN (41,42) AND sporttype = 151 THEN @v151discount_41 
                                 WHEN bettype IN (51,52) AND sporttype = 151 THEN @v151discount_51 
                                 WHEN bettype IN (41,42) AND sporttype = 152 THEN @v152discount_41
                                 WHEN bettype IN (51,52) AND sporttype = 152 THEN @v152discount_51
                                 WHEN bettype IN (51,52) AND sporttype = 153 THEN @v153discount_51
                                 ELSE sdiscount END
             WHERE custid=@custid 
                   AND sporttype in (151, 152, 153)

            IF @db_v151discount_31 <> @v151discount_31
            BEGIN
                --Update g3=g4 if g3>g4 
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                     CASE
                       WHEN cs.adiscount>@v151discount_31 THEN @v151discount_31 ELSE adiscount END
              FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN(31,32) AND cs.sporttype = 151
            
                --Update g2=g4 if g2>g4
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v151discount_31 THEN @v151discount_31
                           ELSE cs.discount
                         END 
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (31, 32)
                   AND cs.sporttype = 151
    
                --Update g4 at Member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.sdiscount = @v151discount_31
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (31, 32)
                   AND cs.sporttype = 151
            END

            IF @db_v151discount_41 <> @v151discount_41--(fixed odds) 
            BEGIN
                --Update m3=s4 if m3>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                     CASE
                       WHEN cs.adiscount>@v151discount_41 THEN @v151discount_41 ELSE adiscount END 
              FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (41,42) AND cs.sporttype = 151 

                --Update a2=s4 if a2>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v151discount_41 THEN @v151discount_41
                           ELSE cs.discount
                         END 
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42)
                   AND cs.sporttype = 151

                --Update s4 to member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.sdiscount = @v151discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42) 
                   AND cs.sporttype = 151
            END

            IF @db_v151discount_51 <> @v151discount_51
            BEGIN
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                     CASE
                       WHEN cs.adiscount>@v151discount_51 THEN @v151discount_51 ELSE adiscount END 
              FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 151 

                --Update a2=s4 if a2>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v151discount_51 THEN @v151discount_51
                           ELSE cs.discount
                         END
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52)
                   AND cs.sporttype = 151

                --Update s4 to member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.sdiscount = @v151discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52) 
                   AND cs.sporttype = 151
            END

            IF @db_v152discount_41 <> @v152discount_41
            BEGIN
                --Update m3=s4 if m3>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                     CASE
                       WHEN cs.adiscount>@v152discount_41 THEN @v152discount_41 ELSE adiscount END 
              FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (41,42) AND cs.sporttype = 152 

                --Update a2=s4 if a2>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v152discount_41 THEN @v152discount_41
                           ELSE cs.discount
                         END
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42)
                   AND cs.sporttype = 152

                --Update s4 to member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.sdiscount = @v152discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42) 
                   AND cs.sporttype = 152
            END

            IF @db_v152discount_51 <> @v152discount_51
            BEGIN
                --Update m3=s4 if m3>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                     CASE
                       WHEN cs.adiscount>@v152discount_51 THEN @v152discount_51 ELSE adiscount END 
              FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 152 

                --Update a2=s4 if a2>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v152discount_51 THEN @v152discount_51
                           ELSE cs.discount
                         END 
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52)
                   AND cs.sporttype = 152

                --Update s4 to member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.sdiscount = @v152discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52) 
                   AND cs.sporttype = 152
            END

            IF @db_v153discount_51 <> @v153discount_51
            BEGIN

                --Update m3=s4 if m3>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount =
                         CASE
                           WHEN cs.adiscount>@v153discount_51 THEN @v153discount_51 ELSE adiscount END 
                  FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid AND c.roleid = 3 AND cs.bettype IN (51,52) AND cs.sporttype = 153 


                --Update a2=s4 if a2>s4
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount =
                         CASE
                           WHEN cs.discount > @v153discount_51 THEN @v153discount_51
                           ELSE cs.discount
                         END 
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid
                   AND c.roleid     = 2
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52)
                   AND cs.sporttype = 153


                --Update s4 to member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.sdiscount = @v153discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.srecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52) 
                   AND cs.sporttype = 153
            END


            --At member level, update adiscount = sdiscount  if adiscount > sdiscount
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.adiscount =
                     CASE
                       WHEN cs.adiscount > cs.sdiscount THEN cs.sdiscount
                       ELSE cs.adiscount
                     END 
              FROM CustSetting3rd cs
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.srecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs.sporttype IN (151, 152, 153)


            --At member level, update discount = adiscount  if discount > adiscount
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.discount =
                     CASE
                       WHEN cs.discount > cs.adiscount THEN cs.adiscount
                       ELSE cs.discount
                     END 
              FROM CustSetting3rd cs
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.srecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs.sporttype IN (151, 152, 153)


            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.playerdiscount =
                     CASE
                       WHEN cs.playerdiscount > cs.discount THEN cs.discount
                       ELSE cs.playerdiscount
                     END 
              FROM CustSetting3rd cs
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.srecommend = @custid
               AND c.roleid = 1
               AND c.Enabled = 1
               AND cs.sporttype IN (151, 152, 153)
        END
        IF @RoleId = 3
        BEGIN
            SELECT @db_v151discount_31 = adiscount    -- @db_v151discount_31
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid 
                AND bettype = 31 
                and sporttype = 151

            SELECT @db_v151discount_41 = adiscount    -- @db_v151discount_41
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 41 and sporttype = 151

            SELECT @db_v151discount_51 = adiscount    -- @db_v151discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 51 and sporttype = 151

            SELECT @db_v152discount_41 = adiscount    -- @db_v152discount_41
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 41 and sporttype = 152

            SELECT @db_v152discount_51 = adiscount    -- @db_v152discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 51 and sporttype = 152

            SELECT @db_v153discount_51 = adiscount    -- @db_v153discount_51
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 51 and sporttype = 153

            IF @db_v151discount_31 <> @v151discount_31
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v151discount_31
                 WHERE            custid=@custid AND bettype IN(31,32) AND sporttype = 151

                --Update g2 = g3 if g2>g3 at agent
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount = @v151discount_31
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid 
                   AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (31, 32) 
                   AND cs.sporttype  = 151
                   AND cs.discount   > @v151discount_31

                --Update g3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount = @v151discount_31
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid     
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (31, 32) 
                   AND cs.sporttype = 151
            END
            
            IF @db_v151discount_41 <> @v151discount_41
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v151discount_41 
                 WHERE            custid=@custid AND bettype IN(41,42) AND sporttype = 151 

                --Update a2 = m3 if a2>m3 at agent
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount = @v151discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid
                   AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (41, 42)
                   AND cs.sporttype  = 151
                   AND discount > @v151discount_41
                
                --Update m3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.adiscount = @v151discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42) 
                   AND cs.sporttype = 151
            END

            IF @db_v151discount_51 <> @v151discount_51
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v151discount_51 
                 WHERE            custid=@custid AND bettype IN(51,52) AND sporttype = 151 

                --Update a2 = m3 if a2>m3 at agent
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount = @v151discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid
                   AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (51, 52)
                   AND cs.sporttype  = 151
                   AND discount > @v151discount_51

                --Update m3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.adiscount = @v151discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52) 
                   AND cs.sporttype = 151
            END

            IF @db_v152discount_41 <> @v152discount_41
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v152discount_41 
                 WHERE            custid=@custid AND bettype IN(41,42) AND sporttype = 152 

                --Update a2 = m3 if a2>m3 at agent
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount = @v152discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid 
                   AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (41, 42) 
                   AND cs.sporttype  = 152
                   AND discount > @v152discount_41

                --Update m3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.adiscount = @v152discount_41
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (41, 42) 
                   AND cs.sporttype = 152
            END

            IF @db_v152discount_51 <> @v152discount_51
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v152discount_51 
                 WHERE            custid=@custid AND bettype IN(51,52) AND sporttype = 152 

                --Update a2 = m3 if a2>m3 at agent
                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET cs.discount = @v152discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid
                   AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (51, 52)
                   AND cs.sporttype  = 152
                   AND discount > @v152discount_51

                --Update m3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET cs.adiscount = @v152discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1 
                   AND cs.bettype   IN (51, 52) 
                   AND cs.sporttype = 152
            END

            IF @db_v153discount_51 <> @v153discount_51
            BEGIN
                --Update @Master: g3, m3
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                   SET    adiscount = @v153discount_51 
                 WHERE            custid=@custid AND bettype IN(51,52) AND sporttype = 153 

                UPDATE cs WITH(ROWLOCK, UPDLOCK) 
                   SET discount = @v153discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
                 WHERE ci.mrecommend = @custid
                      AND ci.roleid     = 2
                   AND ci.Enabled    = 1
                   AND cs.bettype    IN (51, 52)
                   AND cs.sporttype  = 153
                   AND discount > @v153discount_51

                --Update m3 @ member level
                UPDATE cs WITH(ROWLOCK, UPDLOCK)
                   SET adiscount = @v153discount_51
                  FROM CustSetting3rd cs
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE c.mrecommend = @custid 
                   AND c.recommend  <> 52466
                   AND c.roleid     = 1
                   AND c.Enabled    = 1
                   AND cs.bettype   IN (51, 52)
                   AND cs.sporttype = 153
            END

            --At member level, update discount = adiscount  if discount > adiscount
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.discount = cs.adiscount
              FROM CustSetting3rd cs
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.mrecommend = @custid
               AND c.roleid     = 1
               AND c.Enabled    = 1
               AND cs.discount  > cs.adiscount
               AND sporttype    IN (151, 152, 153)


            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs WITH(ROWLOCK, UPDLOCK)
               SET cs.playerdiscount = cs.discount
              FROM CustSetting3rd cs
        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.mrecommend = @custid
               AND c.roleid     = 1
               AND c.Enabled    = 1
               AND cs.playerdiscount > cs.discount
               AND sporttype IN (151, 152, 153)
        END
        IF @RoleId = 2
        BEGIN
            SELECT  @db_v151discount_31 = discount    
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 31 AND sporttype = 151

            SELECT  @db_v151discount_41 = discount    
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 41 AND sporttype = 151

            SELECT  @db_v151discount_51 = discount    
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 51 and sporttype = 151

            SELECT  @db_v152discount_41 = discount    
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 41 and sporttype = 152

            SELECT  @db_v152discount_51 = discount    
              FROM CustSetting3rd WITH(NOLOCK)
             WHERE custid = @custid AND bettype = 51 and sporttype = 152

            SELECT  @db_v153discount_51 = discount    
              FROM CustSetting3rd WITH(NOLOCK) 
             WHERE custid = @custid AND bettype = 51 and sporttype = 153

            IF @db_v151discount_31 <> @v151discount_31 
                    or @db_v151discount_41 <> @v151discount_41 
                    or @db_v151discount_51 <> @v151discount_51
            BEGIN
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                SET
                    discount =
                     CASE
                       WHEN bettype IN(31,32) AND @db_v151discount_31 <> @v151discount_31 THEN @v151discount_31 
                                    WHEN bettype IN(41,42) AND @db_v151discount_41 <> @v151discount_41 THEN @v151discount_41 
                                    WHEN bettype IN(51,52) AND @db_v151discount_51 <> @v151discount_51 THEN @v151discount_51
                                    ELSE discount END
                 WHERE            custid=@custid 
                   AND sporttype = 151

                UPDATE cs
                       SET cs.discount = CASE 
                        WHEN cs.bettype IN(31,32)THEN @v151discount_31 
                        WHEN cs.bettype IN(41,42)THEN @v151discount_41 
                        WHEN cs.bettype IN(51,52)THEN @v151discount_51 
                    ELSE discount END 
              FROM CustSetting3rd cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.recommend = @custid 
                   AND c.recommend <> 52466
                   AND c.roleid = 1 
                   AND sporttype = 151
            END

            IF @db_v152discount_41 <> @v152discount_41
                OR @db_v152discount_51 <> @v152discount_51
            BEGIN
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                SET
                    discount = CASE 
                        WHEN bettype IN (41,42) AND @db_v152discount_41 <> @v152discount_41 THEN @v152discount_41 
                        WHEN bettype IN (51,52) AND @db_v152discount_51 <> @v152discount_51 THEN @v152discount_51
                        ELSE discount END
                 WHERE            custid=@custid 
                   AND sporttype = 152

                --Update g2, a2 at Member level    
                UPDATE cs
                       SET cs.discount = CASE 
                        WHEN cs.bettype IN (41,42) THEN @v152discount_41 
                        WHEN cs.bettype IN (51,52) THEN @v152discount_51 
                    ELSE discount END 
              FROM CustSetting3rd cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.recommend = @custid 
                   AND c.recommend <> 52466
                   AND c.roleid = 1 
                   AND sporttype = 152
            END

            IF @db_v153discount_51 <> @v153discount_51
            BEGIN
                UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
                SET
                    discount =
                     CASE
                       WHEN bettype IN (51,52) AND @db_v153discount_51 <> @v153discount_51 THEN @v153discount_51
                                    ELSE discount END
                 WHERE            custid=@custid 
                   AND sporttype = 153

                --Update g2, a2 at Member level
                UPDATE cs
                   SET cs.discount =
                     CASE
                       WHEN cs.bettype IN (51,52) AND @db_v153discount_51 <> @v153discount_51
                                            THEN @v153discount_51 
                                        ELSE discount END 
              FROM CustSetting3rd cs WITH (ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                 WHERE            c.recommend = @custid 
                   AND c.recommend <> 52466
                   AND c.roleid = 1 
                   AND sporttype = 153
            END

            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs 
                   SET cs.playerdiscount = cs.discount
              FROM CustSetting3rd cs WITH (ROWLOCK, UPDLOCK)
            INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.recommend = @custid 
                AND c.roleid = 1 
                AND cs.playerdiscount > cs.discount 
                AND sporttype in (151, 152, 153)
        END
        IF @RoleId = 1
        BEGIN    
            UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
            SET    
                playerdiscount = CASE    WHEN bettype IN (31,32) AND sporttype = 151 THEN @v151discount_31 
                                                    WHEN bettype IN (41,42) AND sporttype = 151 THEN @v151discount_41 
                                                    WHEN bettype IN (51,52) AND sporttype = 151 THEN @v151discount_51
                                                    WHEN bettype IN (41,42) AND sporttype = 152 THEN @v152discount_41
                                                    WHEN bettype IN (51,52) AND sporttype = 152 THEN @v152discount_51
                                                    WHEN bettype IN (51,52) AND sporttype = 153 THEN @v153discount_51
                                                    ELSE playerdiscount 
                                END
              FROM CustSetting3rd cs3 
            INNER JOIN custInfo c with(NOLOCK) 
            ON c.custid = cs3.custid
             WHERE cs3.custid=@custid 
                and sporttype in (151, 152, 153)
                AND c.recommend <> 52466
        END
    END
    
    IF @mode = 'LiveCasino'
    BEGIN
        IF @RoleId = 4
        BEGIN
            UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK) 
               SET sdiscount = @v162discount_1101
             WHERE custid = @custid 
                AND sporttype = 162 
                AND bettype = 1101

            --Update g3=g4 if g3>g4
            UPDATE cs
               SET cs.adiscount =
                     CASE
                       WHEN cs.adiscount > @v162discount_1101 
                                        THEN @v162discount_1101 
                                    ELSE cs.adiscount 
                               END
              FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid AND ci.roleid = 3
                AND cs.sporttype = 162 AND bettype = 1101 


            --Update g2=g4 if g2>g4
            UPDATE cs
               SET cs.discount =
                     CASE
                       WHEN cs.discount > @v162discount_1101 THEN @v162discount_1101
                       ELSE cs.discount
                        END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.srecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND cs.sporttype  = 162
               AND bettype       = 1101
            
            --Update g4 at Member level
            UPDATE cs
               SET cs.sdiscount = @v162discount_1101
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND ci.SyncLiveCasino = 1 
               AND cs.Sporttype = 162
               AND cs.Bettype = 1101

            
            --At member level, update adiscount = sdiscount  if adiscount > sdiscount
            UPDATE cs
               SET cs.adiscount =
                     CASE
                       WHEN cs.adiscount > cs.sdiscount THEN cs.sdiscount 
                       ELSE cs.adiscount 
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Sporttype = 162
               AND cs.Bettype = 1101

            
            --At member level, update discount = adiscount  if discount > adiscount
            UPDATE cs
               SET cs.discount =
                     CASE
                       WHEN cs.discount > cs.adiscount THEN cs.adiscount 
                       ELSE cs.discount 
                     END
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Sporttype = 162
               AND cs.Bettype = 1101

                
            --At member level, update playerdiscount = discount  if playerdiscount > discount
            
            --Check IF the current super is Credit type
                IF NOT EXISTS (SELECT 1 
                                 FROM Dep_CustSuper cs WITH(NOLOCK) 
                           INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.srecommend
                                WHERE ci.custid = @custid
                              )
                BEGIN
                    UPDATE cs
                       SET cs.playerdiscount =
                             CASE
                               WHEN cs.playerdiscount > cs.discount THEN cs.discount 
                               ELSE cs.playerdiscount 
                             END
                      FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                     WHERE ci.srecommend = @custid
                       AND ci.roleid = 1
                       AND ci.Enabled = 1
                       AND cs.Sporttype = 162
                       AND cs.Bettype = 1101
                END
        END
        
        IF @RoleId = 3
        BEGIN
            --Update @Master: g3, m3
            UPDATE CustSettingGame WITH(UPDLOCK, ROWLOCK)
               SET adiscount = @v162discount_1101
             WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 

            --Update g2 = g3 if g2>g3 at agent
            UPDATE cs
               SET cs.discount = @v162discount_1101
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.mrecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND cs.sporttype  = 162
               AND cs.bettype    = 1101
               AND cs.discount > @v162discount_1101

            --Update g3 @ member level
            UPDATE cs
               SET cs.adiscount = @v162discount_1101
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND ci.recommend <> 52466
               AND ci.SyncLiveCasino = 1

            --At member level, update discount = adiscount  if discount > adiscount
            UPDATE cs
               SET cs.discount = cs.adiscount
              FROM CustSettingGame cs
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = 162
               AND cs.bettype = 1101 
               AND cs.discount > cs.adiscount

            --At member level, update playerdiscount = discount  if playerdiscount > discount

            --Check IF the current super is Credit type
            IF NOT EXISTS (SELECT 1 
                             FROM Dep_CustSuper cs WITH(NOLOCK) 
                       INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.srecommend
                            WHERE ci.custid = @custid
                          )
            BEGIN
                    UPDATE cs
                       SET cs.playerdiscount = cs.discount
                      FROM CustSettingGame cs
                INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
                     WHERE ci.mrecommend = @custid
                       AND ci.roleid = 1
                       AND ci.Enabled = 1
                       AND cs.sporttype = 162
                       AND cs.bettype = 1101 
                       AND cs.playerdiscount > cs.discount
            END

        END
        
        IF @RoleId = 2
        BEGIN
            --Update @Agent: g2, a2
            UPDATE CustSettingGame WITH(ROWLOCK, UPDLOCK)
            SET    discount = @v162discount_1101
             WHERE custid=@custid AND sporttype = 162 AND bettype = 1101

            --Update g2, a2 at Member level
            UPDATE cs
                   SET cs.discount = @v162discount_1101
              FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.recommend = @custid 
                AND c.recommend <> 52466
                AND c.roleid = 1 AND c.SyncLiveCasino = 1
                AND sporttype = 162
                AND bettype = 1101

            --At member level, update playerdiscount = discount  if playerdiscount > discount
                --Check IF the current super is Credit type
            IF NOT EXISTS (SELECT 1 
                          FROM Dep_CustSuper cs WITH(NOLOCK) 
                            INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.srecommend
                             WHERE            ci.custid = @custid)
            BEGIN
                    UPDATE cs 
                       SET cs.playerdiscount = cs.discount
                  FROM CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
                        INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
                     WHERE            c.recommend = @custid 
                        AND    c.roleid = 1 
                       AND cs.playerdiscount > cs.discount 
                       AND sporttype = 162
                       AND bettype = 1101
            END

        END
    END
    IF @mode = 'LiveCasinoUpdAll'
    BEGIN
        IF @RoleId = 4
        BEGIN
            -- update commission for super
            UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
               SET sdiscount = @v162discount_1101
             WHERE custid = @custid 

            -- update commission for master
            UPDATE custsettinggame WITH(ROWLOCK,UPDLOCK)
               SET adiscount = @v162discount_1101
             WHERE custid IN (SELECT custid 
                          FROM custinfo WITH(NOLOCK)
                             WHERE            srecommend = @custid and roleid=3) 

            -- update commission for agents
            UPDATE custsettinggame WITH(ROWLOCK, UPDLOCK)
               SET discount = @v162discount_1101
             WHERE custid IN (SELECT custid 
                                FROM custinfo WITH(NOLOCK)
                               WHERE srecommend = @custid
                                 AND roleid     = 2
                                 AND Enabled    = 1
                             ) -- active agents

            -- update commission for members
            --Check IF the current super is Credit Type

            IF NOT EXISTS (SELECT 1 
                             FROM Dep_CustSuper cs WITH(NOLOCK) 
                       INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.srecommend
                            WHERE ci.custid = @custid
                          )
            BEGIN
                UPDATE custsettinggame WITH(ROWLOCK, UPDLOCK)
                   SET sdiscount = @v162discount_1101
                     , adiscount = @v162discount_1101
                     , discount = @v162discount_1101
                     , playerdiscount = @v162discount_1101
                 WHERE custid IN (SELECT custid 
                                    FROM custinfo WITH(NOLOCK)
                                   WHERE srecommend = @custid
                                     AND roleid = 1
                                     AND Enabled = 1
                                 ) 
            END
            ELSE
            BEGIN
                UPDATE custsettinggame WITH(ROWLOCK, UPDLOCK)
                   SET sdiscount = @v162discount_1101
                     , adiscount = @v162discount_1101
                     , discount = @v162discount_1101    
                 WHERE custid IN (SELECT custid 
                                    FROM custinfo WITH(NOLOCK)
                                   WHERE srecommend = @custid
                                     AND roleid = 1
                                     AND Enabled = 1
                                 ) 
            END    
        END
    END    

    IF @mode = 'Keno'
    BEGIN
        IF @RoleId = 4
        BEGIN
            UPDATE dbo.CustSettingGame WITH(UPDLOCK, ROWLOCK)
               SET sdiscount = @Discount
             WHERE custid = @CustId AND bettype = @Bettype
                AND sporttype = @Sporttype AND sdiscount <> @Discount

            --Update g3=g4 if g3>g4
            UPDATE cs
               SET cs.adiscount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
                INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid AND ci.roleid = 3
                 AND bettype = @Bettype AND cs.sporttype = @Sporttype
                 AND cs.adiscount > @Discount

            --Update g2=g4 if g2>g4
            UPDATE cs
               SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND bettype       = @Bettype
               AND cs.sporttype  = @Sporttype
               AND cs.discount   > @Discount

            --Update g4 at Member level
            UPDATE cs
               SET sdiscount = @Discount
              FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
        INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Bettype = @Bettype
               AND cs.Sporttype = @Sporttype
               AND cs.sdiscount <> @Discount


            --At member level, update adiscount = sdiscount if adiscount > sdiscount
            UPDATE cs
               SET cs.adiscount = cs.sdiscount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Bettype = @Bettype
               AND cs.Sporttype = @Sporttype
               AND cs.adiscount > cs.sdiscount


            --At member level, update discount = adiscount if discount > adiscount
            UPDATE cs
               SET cs.discount = cs.adiscount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Bettype = @Bettype
               AND cs.Sporttype = @Sporttype 
               AND cs.discount > cs.adiscount


            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs
               SET cs.playerdiscount = cs.discount 
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.Bettype = @Bettype
               AND cs.Sporttype = @Sporttype
               AND cs.playerdiscount > cs.discount
        END
        
        IF @RoleId = 3
        BEGIN
            --Update @Master: g3, m3
            UPDATE dbo.CustSettingGame WITH (UPDLOCK, ROWLOCK)
               SET adiscount = @Discount
             WHERE custid = @custid AND bettype = @Bettype AND sporttype = @Sporttype AND adiscount <> @Discount

            --Update g2 = g3 if g2>g3 at agent
            UPDATE cs
               SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
             WHERE ci.mrecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND cs.sporttype  = @Sporttype
               AND cs.bettype    = @Bettype
               AND cs.discount   > @Discount

            --Update g3 @ member level
            UPDATE cs
               SET cs.adiscount = @Discount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.sporttype = @Sporttype
               AND cs.bettype = @Bettype 
               AND ci.recommend <> 52466
               AND cs.adiscount <> @Discount


            --At member level, update discount = adiscount  if discount > adiscount
            UPDATE cs
               SET cs.discount = cs.adiscount
              FROM dbo.CustSettingGame cs WITH(UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.bettype = @Bettype
               AND cs.sporttype = @Sporttype 
               AND cs.discount > cs.adiscount

            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs
               SET cs.playerdiscount = cs.discount
              FROM dbo.CustSettingGame cs WITH (UPDLOCK, ROWLOCK)
        INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
             WHERE ci.mrecommend = @custid
               AND ci.roleid = 1
               AND ci.Enabled = 1
               AND cs.bettype = @Bettype
               AND cs.sporttype = @Sporttype 
               AND cs.playerdiscount > cs.discount
        END
        
        IF @RoleId = 2
        BEGIN
            --Update @Agent: g2, a2
            UPDATE dbo.CustSettingGame WITH (ROWLOCK, UPDLOCK)
            SET    discount = @Discount
             WHERE custid = @custid AND bettype = @Bettype AND sporttype = @Sporttype AND discount <> @Discount

            --Update g2, a2 at Member level
            UPDATE cs
                   SET cs.discount = @Discount
              FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.recommend = @custid AND c.recommend <> 52466
                AND c.roleid = 1 AND bettype = @Bettype
                AND sporttype = @Sporttype AND cs.discount <> @Discount

            --At member level, update playerdiscount = discount  if playerdiscount > discount
            UPDATE cs 
               SET cs.playerdiscount = cs.discount
              FROM dbo.CustSettingGame cs WITH(ROWLOCK, UPDLOCK)
                INNER JOIN dbo.custinfo c WITH(NOLOCK) ON cs.custid = c.custid
             WHERE c.recommend = @custid AND c.roleid = 1
                AND sporttype = @Sporttype AND bettype = @Bettype AND cs.playerdiscount > cs.discount 
        END
    END
    
    /*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
    IF @mode = 'Others'
    BEGIN
		DECLARE @NewDiscountTbl TABLE(
			SportType SMALLINT,
			BetType SMALLINT,
			Discount Decimal(9,8)
		)
		
		IF @Discount_XML IS NULL OR @Discount_XML='' RETURN
	
		--Parse XML
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @Discount_XML
		
		
		INSERT @NewDiscountTbl
		SELECT SportType,BetType,CAST(Discount AS DECIMAL(9,8)) AS Discount
		FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
		WITH(SportType smallint, BetType smallint, Discount VARCHAR(15))	
		
		EXEC sp_xml_removedocument @iDoc
	
		IF @RoleID=4
		BEGIN
			--update super
			UPDATE main
			SET main.Discount = tmp.Discount
			FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
			JOIN @NewDiscountTbl tmp 
				ON tmp.SportType=main.SportType
					AND tmp.BetType=main.BetType
			WHERE main.CustID=@CustID
			
			--downline_master_discount = min (downline_master_discount, @NEW_DISCOUNT)
			UPDATE dcm
			SET
				dcm.Discount=CASE WHEN dcs.Discount < dcm.Discount THEN dcs.Discount ELSE dcm.Discount  END
			FROM dbo.CustDiscount3rd_Agent dcm WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcm.custid = ci.custid
											   AND ci.srecommend = @CustID
											   AND ci.roleid = 3
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcm.sporttype
												AND dcs.bettype = dcm.bettype
												AND dcs.custid=@CustID
			--ownline_agent_discount = min (downline_agent_discount, @NEW_DISCOUNT)									
			UPDATE dca
			SET
				dca.Discount=CASE WHEN dcs.Discount < dca.Discount THEN dcs.Discount ELSE dca.Discount  END
			FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
											   AND ci.srecommend = @CustID
											   AND ci.roleid = 2
											   AND ci.Enabled=1
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dca.sporttype
												AND dcs.bettype = dca.bettype
												AND dcs.custid=@CustID
			
			--downline_member_sdiscount = @NEW_DISCOUNT
			--downline_member_adiscount = min(downline_member_adiscount, downline_member_sdiscount)
			--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)									
			UPDATE dcmem
			SET
				dcmem.SuperDiscount=dcs.Discount,
				dcmem.MasterDiscount= CASE WHEN dcmem.MasterDiscount < dcmem.SuperDiscount THEN dcmem.MasterDiscount ELSE dcmem.SuperDiscount END,
				dcmem.AgentDiscount= CASE WHEN dcmem.AgentDiscount < dcmem.MasterDiscount THEN dcmem.AgentDiscount ELSE dcmem.MasterDiscount END,
				dcmem.PlayerDiscount= CASE WHEN dcmem.PlayerDiscount < dcmem.AgentDiscount THEN dcmem.PlayerDiscount ELSE dcmem.AgentDiscount END
			FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
											   AND ci.srecommend = @CustID
											   AND ci.roleid = 1
											   AND ci.Enabled=1
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
												AND dcs.bettype = dcmem.bettype
												AND dcs.custid=@CustID
												
		END
		ELSE IF @RoleID=3
		BEGIN
			--update master
			UPDATE main
			SET main.Discount = tmp.Discount
			FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
			JOIN @NewDiscountTbl tmp 
				ON tmp.SportType=main.SportType
					AND tmp.BetType=main.BetType
			WHERE main.CustID=@CustID
					
			--downline_agent_discount = min (downline_agent_discount, @NEW_DISCOUNT)		
			UPDATE dca
			SET
				dca.Discount=CASE WHEN dcm.Discount < dca.Discount THEN dcm.Discount ELSE dca.Discount  END
			FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
											   AND ci.mrecommend = @CustID
											   AND ci.roleid = 2
											   AND ci.Enabled=1
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dca.sporttype
												AND dcm.bettype = dca.bettype
												AND dcm.custid=@CustID
												
			--downline_member_adiscount = @NEW_DISCOUNT
			--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)									
			UPDATE dcmem
			SET
				dcmem.MasterDiscount= dcm.Discount,
				dcmem.AgentDiscount= CASE WHEN dcmem.AgentDiscount < dcmem.MasterDiscount THEN dcmem.AgentDiscount ELSE dcmem.MasterDiscount END,
				dcmem.PlayerDiscount= CASE WHEN dcmem.PlayerDiscount < dcmem.AgentDiscount THEN dcmem.PlayerDiscount ELSE dcmem.AgentDiscount END
			FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
											   AND ci.mrecommend = @CustID
											   AND ci.roleid = 1
											   AND ci.Enabled=1
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
												AND dcm.bettype = dcmem.bettype
												AND dcm.custid=@CustID
		END
		ELSE IF @RoleID=2
		BEGIN
			--update agent
			UPDATE main
			SET main.Discount = tmp.Discount
			FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
			JOIN @NewDiscountTbl tmp 
				ON tmp.SportType=main.SportType
					AND tmp.BetType=main.BetType
			WHERE main.CustID=@CustID
					
			--downline_member_discount = @NEW_DISCOUNT
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)
			UPDATE dcmem
			SET
				dcmem.AgentDiscount= dca.Discount,
				dcmem.PlayerDiscount= CASE WHEN dcmem.PlayerDiscount < dcmem.AgentDiscount THEN dcmem.PlayerDiscount ELSE dcmem.AgentDiscount END
			FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
											   AND ci.recommend = @CustID
											   AND ci.roleid = 1
											   AND ci.Enabled=1
			INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype
												AND dca.bettype = dcmem.bettype
												AND dca.custid=@CustID
		END
		ELSE IF @RoleID=1
		BEGIN
			--update agent
			UPDATE main
			SET main.PlayerDiscount = CASE WHEN tmp.Discount < dca.Discount THEN tmp.Discount ELSE dca.Discount END
			FROM dbo.CustDiscount3rd_Member main WITH(ROWLOCK, UPDLOCK)
			JOIN @NewDiscountTbl tmp 
				ON tmp.SportType=main.SportType
					AND tmp.BetType=main.BetType
			JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK)
				ON tmp.SportType=dca.SportType
					AND tmp.BetType=dca.BetType
			WHERE main.CustID=@CustID
		END
    END
    /*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
END




GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
