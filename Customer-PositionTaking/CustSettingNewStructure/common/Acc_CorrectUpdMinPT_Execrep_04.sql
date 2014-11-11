SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CorrectUpdMinPT_Execrep_04]
	@CustID INT,
	@RoleID INT,
	@ProductID INT
AS
	/*
	Created: 20141110@Dominic
	Task : Update SMA'MinPT on Sporttype/bettype
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Corrected Downline 's ID

	*/
BEGIN
	DECLARE @mpos TINYINT, @apos TINYINT, @spos TINYINT, @mapos1 TINYINT, @mapos2 TINYINT, @mapos TINYINT, @maxmapos TINYINT
	
	IF @RoleID=4
	BEGIN
		--1,2,3,4,7,8,9,10,11
		--Rule #1
		--Ungrouped Setting members
		UPDATE pt
        SET pt.superPT = spt.superPT - mpt.masterPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype = pt.bettype
                                                  AND spt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
		 WHERE pt.isautosPT = 0
		   AND mpt.isautosPT = 0 
		   AND spt.superPT - mpt.masterPT < pt.superPT
		   AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		
		--Grouped Setting members   
		UPDATE gpt
        SET gpt.superPT = spt.superPT - mpt.masterPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype = gpt.bettype
                                                  AND spt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
		 WHERE gpt.isautosPT = 0
		   AND mpt.isautosPT = 0 
		   AND spt.superPT - mpt.masterPT < gpt.superPT
		   AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Rule #2,#3
		--Ungrouped Setting members
		UPDATE pt
               SET pt.agentPT = apt.minPT
                 , pt.masterPT =
                     CASE
                       WHEN pt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE pt.masterPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.agentPT = apt.minPT
                 , gpt.masterPT =
                     CASE
                       WHEN gpt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE gpt.masterPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #4
		--Ungrouped Setting members
		UPDATE pt 
        SET pt.agentPT = apt.maxPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		
		----Grouped Setting members
		UPDATE gpt 
        SET gpt.agentPT = apt.maxPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Rule #7
		--Ungrouped Setting members
		UPDATE pt
               SET pt.masterPT =
                     CASE
                       WHEN mpt.masterPT - pt.agentPT >
                              CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - pt.agentPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
											AND mb.srecommend = @CustID
										   AND mb.roleid = 1
										   AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = pt.sporttype
                                                  AND apt.bettype = pt.bettype
                                                  AND apt.bettype = pt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR pt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.masterPT =
                     CASE
                       WHEN mpt.masterPT - gpt.agentPT >
                              CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - gpt.agentPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
											AND mb.srecommend = @CustID
										   AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = gpt.sporttype
                                                  AND apt.bettype = gpt.bettype
                                                  AND apt.bettype = gpt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR gpt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		
		--Rule #8
		--Ungrouped Setting members   
		UPDATE pt
               SET pt.masterPT = mpt.minPT - pt.agentPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                            AND mb.srecommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = pt.sporttype
                                                   AND mpt.bettype = pt.bettype
                                                   AND mpt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members   
		UPDATE gpt
               SET gpt.masterPT = mpt.minPT - gpt.agentPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                            AND mb.srecommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = gpt.sporttype
                                                   AND mpt.bettype = gpt.bettype
                                                   AND mpt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #9
		--Ungrouped Setting members
		UPDATE pt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - pt.agentPT < 0 THEN 0
                             ELSE @maxmapos - pt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN pt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE pt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Grouped Setting members
		UPDATE gpt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - gpt.agentPT < 0 THEN 0
                             ELSE @maxmapos - gpt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN gpt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE gpt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #10
		--Ungrouped Setting members
		UPDATE pt
               SET pt.superPT =
                     CASE
                       WHEN spt.superPT - pt.masterPT - pt.agentPT >
                              (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - pt.masterPT - pt.agentPT
                     END 
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype=pt.bettype
                                                  AND spt.islive=pt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (pt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
		
		--Grouped Setting members		
		UPDATE gpt
               SET gpt.superPT =
                     CASE
                       WHEN spt.superPT - gpt.masterPT - gpt.agentPT >
                              (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - gpt.masterPT - gpt.agentPT
                     END 
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype=gpt.bettype
                                                  AND spt.islive=gpt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (gpt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
				
				
		--Rule #11
		--Ungrouped Setting members
		UPDATE pt
        SET pt.superPT = spt.minPT - pt.masterPT - pt.agentPT
         FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = pt.sporttype
                                                   AND spt.bettype = pt.bettype
                                                   AND spt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
         WHERE pt.agentPT + pt.masterPT + pt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
			
		--Grouped Setting members
		UPDATE gpt
        SET gpt.superPT = spt.minPT - gpt.masterPT - gpt.agentPT
         FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.srecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = gpt.sporttype
                                                   AND spt.bettype = gpt.bettype
                                                   AND spt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
         WHERE gpt.agentPT + gpt.masterPT + gpt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
	END
	ELSE IF @RoleID=3
	BEGIN
		--2,3,4,5,6,7,8,9,10,11,12
		--Rule #2,#3
		--Ungrouped Setting members
		UPDATE pt
               SET pt.agentPT = apt.minPT
                 , pt.masterPT =
                     CASE
                       WHEN pt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE pt.masterPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.agentPT = apt.minPT
                 , gpt.masterPT =
                     CASE
                       WHEN gpt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE gpt.masterPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #4
		--Ungrouped Setting members
		UPDATE pt 
        SET pt.agentPT = apt.maxPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		
		----Grouped Setting members
		UPDATE gpt 
        SET gpt.agentPT = apt.maxPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Rule #5
		UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos =
                     CASE
                       WHEN @maxmapos - c3d.agentPT < 0 THEN 0
                       ELSE @maxmapos - c3d.agentPT
                     END
                 , masterPT = @mpos
                 , @apos =
                     CASE
                       WHEN c3d.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                       ELSE c3d.agentPT
                     END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
              FROM dbo.CustPTSetting3rd_Agent c3d
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid    = mb.mrecommend
                                                  AND mpt.sporttype = c3d.sporttype
                                                  AND mpt.bettype   = c3d.bettype
                                                  AND mpt.islive   = c3d.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid    = mb.recommend
                                                   AND apt.sporttype = c3d.sporttype
                                                   AND apt.bettype   = c3d.bettype
                                                   AND apt.islive   = c3d.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON c3d.sporttype=dtl.SportType
        AND c3d.bettype=dtl.BetType AND c3d.islive=dtl.IsLive
        WHERE c3d.agentPT + c3d.masterPT > mpt.maxPT
         AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #6
		UPDATE c3d WITH(ROWLOCK, UPDLOCK)
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , c3d.automPT = @maxmapos
              FROM dbo.CustPTSetting3rd_Agent c3d
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON c3d.custid    = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid     = 2
                                           AND mb.Enabled    = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid  = mb.mrecommend
                                                  AND mpt.sporttype = c3d.sporttype
                                                  AND mpt.bettype   = c3d.bettype
                                                  AND mpt.islive   = c3d.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON c3d.sporttype=dtl.SportType
        AND c3d.bettype=dtl.BetType AND c3d.islive=dtl.IsLive
             WHERE c3d.isautomPT = 1
               AND c3d.automPT > mpt.maxPT
               AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Rule #7
		--Ungrouped Setting members
		UPDATE pt
               SET pt.masterPT =
                     CASE
                       WHEN mpt.masterPT - pt.agentPT >
                              CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - pt.agentPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
											AND mb.mrecommend = @CustID
										   AND mb.roleid = 1
										   AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = pt.sporttype
                                                  AND apt.bettype = pt.bettype
                                                  AND apt.bettype = pt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR pt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.masterPT =
                     CASE
                       WHEN mpt.masterPT - gpt.agentPT >
                              CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - gpt.agentPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
											AND mb.mrecommend = @CustID
										   AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = gpt.sporttype
                                                  AND apt.bettype = gpt.bettype
                                                  AND apt.bettype = gpt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR gpt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		
		--Rule #8
		--Ungrouped Setting members   
		UPDATE pt
               SET pt.masterPT = mpt.minPT - pt.agentPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                            AND mb.mrecommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = pt.sporttype
                                                   AND mpt.bettype = pt.bettype
                                                   AND mpt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members   
		UPDATE gpt
               SET gpt.masterPT = mpt.minPT - gpt.agentPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                            AND mb.mrecommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = gpt.sporttype
                                                   AND mpt.bettype = gpt.bettype
                                                   AND mpt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #9
		--Ungrouped Setting members
		UPDATE pt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - pt.agentPT < 0 THEN 0
                             ELSE @maxmapos - pt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN pt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE pt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Grouped Setting members
		UPDATE gpt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - gpt.agentPT < 0 THEN 0
                             ELSE @maxmapos - gpt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN gpt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE gpt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #10
		--Ungrouped Setting members
		UPDATE pt
               SET pt.superPT =
                     CASE
                       WHEN spt.superPT - pt.masterPT - pt.agentPT >
                              (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - pt.masterPT - pt.agentPT
                     END 
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype=pt.bettype
                                                  AND spt.islive=pt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (pt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
		
		--Grouped Setting members		
		UPDATE gpt
               SET gpt.superPT =
                     CASE
                       WHEN spt.superPT - gpt.masterPT - gpt.agentPT >
                              (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - gpt.masterPT - gpt.agentPT
                     END 
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype=gpt.bettype
                                                  AND spt.islive=gpt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (gpt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
				
				
		--Rule #11
		--Ungrouped Setting members
		UPDATE pt
        SET pt.superPT = spt.minPT - pt.masterPT - pt.agentPT
         FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = pt.sporttype
                                                   AND spt.bettype = pt.bettype
                                                   AND spt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
         WHERE pt.agentPT + pt.masterPT + pt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
			
		--Grouped Setting members
		UPDATE gpt
        SET gpt.superPT = spt.minPT - gpt.masterPT - gpt.agentPT
         FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = gpt.sporttype
                                                   AND spt.bettype = gpt.bettype
                                                   AND spt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
         WHERE gpt.agentPT + gpt.masterPT + gpt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
			
			
		--Rule #12
		--Ungrouped members
		UPDATE pt WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN spt.superPT - pt.masterPT - pt.agentPT < 0 THEN 0
                       ELSE spt.superPT - pt.masterPT - pt.agentPT
                     END
                 , superPT = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + pt.masterPT + pt.agentPT > spt.superPT THEN spt.superPT - @spos
                       ELSE pt.masterPT + pt.agentPT
                     END
                 , @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mpt.minPT THEN mpt.minPT
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - pt.agentPT < 0 THEN 0
                       ELSE @mapos - pt.agentPT
                     END
                 , masterPT = @mpos
                 , @apos =
                     CASE
                       WHEN pt.agentPT + @mpos > @mapos THEN @mapos - @mpos
                       ELSE pt.agentPT
                     END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
              FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype=pt.bettype
                                                  AND spt.islive=pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype=pt.bettype
                                                  AND mpt.islive=pt.islive
         INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = pt.sporttype
                                                  AND apt.bettype=pt.bettype
                                                  AND apt.islive=pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.superPT + pt.agentPT + pt.masterPT > spt.superPT
        AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
		
		
		--Grouped members
		UPDATE gpt WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN spt.superPT - gpt.masterPT - gpt.agentPT < 0 THEN 0
                       ELSE spt.superPT - gpt.masterPT - gpt.agentPT
                     END
                 , superPT = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + gpt.masterPT + gpt.agentPT > spt.superPT THEN spt.superPT - @spos
                       ELSE gpt.masterPT + gpt.agentPT
                     END
                 , @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mpt.minPT THEN mpt.minPT
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - gpt.agentPT < 0 THEN 0
                       ELSE @mapos - gpt.agentPT
                     END
                 , masterPT = @mpos
                 , @apos =
                     CASE
                       WHEN gpt.agentPT + @mpos > @mapos THEN @mapos - @mpos
                       ELSE gpt.agentPT
                     END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.mrecommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype=gpt.bettype
                                                  AND spt.islive=gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype=gpt.bettype
                                                  AND mpt.islive=gpt.islive
         INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = gpt.sporttype
                                                  AND apt.bettype=gpt.bettype
                                                  AND apt.islive=gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.superPT + gpt.agentPT + gpt.masterPT > spt.superPT
        AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
	END
	ELSE IF @RoleID = 2
	BEGIN
		--2,3,4,7,8,9,10,11,12
		--Rule #2,#3
		--Ungrouped Setting members
		UPDATE pt
               SET pt.agentPT = apt.minPT
                 , pt.masterPT =
                     CASE
                       WHEN pt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE pt.masterPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.agentPT = apt.minPT
                 , gpt.masterPT =
                     CASE
                       WHEN gpt.masterPT + apt.minPT > mpt.masterPT THEN mpt.masterPT - apt.minPT
                       ELSE gpt.masterPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT < apt.minPT
			AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #4
		--Ungrouped Setting members
		UPDATE pt 
        SET pt.agentPT = apt.maxPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		
		----Grouped Setting members
		UPDATE gpt 
        SET gpt.agentPT = apt.maxPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT > apt.maxPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Rule #7
		--Ungrouped Setting members
		UPDATE pt
               SET pt.masterPT =
                     CASE
                       WHEN mpt.masterPT - pt.agentPT >
                              CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN pt.isautomPT = 1 THEN pt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - pt.agentPT
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
											AND mb.recommend = @CustID
										   AND mb.roleid = 1
										   AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = pt.sporttype
                                                  AND apt.bettype = pt.bettype
                                                  AND apt.bettype = pt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR pt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members
		UPDATE gpt
               SET gpt.masterPT =
                     CASE
                       WHEN mpt.masterPT - gpt.agentPT >
                              CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                         THEN CASE
                                WHEN gpt.isautomPT = 1 THEN gpt.automPT
                                ELSE apt.automPT
                              END
                       ELSE mpt.masterPT - gpt.agentPT
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
											AND mb.recommend = @CustID
										   AND mb.roleid = 2
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = gpt.sporttype
                                                  AND apt.bettype = gpt.bettype
                                                  AND apt.bettype = gpt.bettype
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (apt.isautomPT = 1
                    OR gpt.isautomPT = 1)
                    AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		
		--Rule #8
		--Ungrouped Setting members   
		UPDATE pt
               SET pt.masterPT = mpt.minPT - pt.agentPT
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                            AND mb.recommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = pt.sporttype
                                                   AND mpt.bettype = pt.bettype
                                                   AND mpt.islive = pt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Grouped Setting members   
		UPDATE gpt
               SET gpt.masterPT = mpt.minPT - gpt.agentPT
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                            AND mb.recommend = @CustID
                                            AND mb.roleid = 1
                                            AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                   AND mpt.sporttype = gpt.sporttype
                                                   AND mpt.bettype = gpt.bettype
                                                   AND mpt.islive = gpt.islive
		INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT < mpt.minPT
        AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #9
		--Ungrouped Setting members
		UPDATE pt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - pt.agentPT < 0 THEN 0
                             ELSE @maxmapos - pt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN pt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE pt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = pt.sporttype
                                                   AND apt.bettype = pt.bettype
                                                   AND apt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.agentPT + pt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		   
		--Grouped Setting members
		UPDATE gpt
               SET @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mpos = CASE
                             WHEN @maxmapos - gpt.agentPT < 0 THEN 0
                             ELSE @maxmapos - gpt.agentPT
                           END
                 , masterPT = @mpos
                 , @apos = CASE
                             WHEN gpt.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                             ELSE gpt.agentPT
                           END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                   AND apt.sporttype = gpt.sporttype
                                                   AND apt.bettype = gpt.bettype
                                                   AND apt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.agentPT + gpt.masterPT > mpt.maxPT AND dtl.SettingType=1
		   AND dtl.ProductID=@ProductID
		   
		--Rule #10
		--Ungrouped Setting members
		UPDATE pt
               SET pt.superPT =
                     CASE
                       WHEN spt.superPT - pt.masterPT - pt.agentPT >
                              (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN pt.IsautoSPT = 1 THEN pt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - pt.masterPT - pt.agentPT
                     END 
        FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype = pt.bettype
                                                  AND mpt.islive = pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype=pt.bettype
                                                  AND spt.islive=pt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
             WHERE (pt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
		
		--Grouped Setting members		
		UPDATE gpt
               SET gpt.superPT =
                     CASE
                       WHEN spt.superPT - gpt.masterPT - gpt.agentPT >
                              (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                         THEN (CASE
                                 WHEN gpt.IsautoSPT = 1 THEN gpt.autoSPT
                                 ELSE mpt.autoSPT
                               END
                              )
                       ELSE spt.superPT - gpt.masterPT - gpt.agentPT
                     END 
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype = gpt.bettype
                                                  AND mpt.islive = gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype=gpt.bettype
                                                  AND spt.islive=gpt.islive
         INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
             WHERE (gpt.isautosPT = 1
                    OR mpt.isautosPT = 1
                   )
                   AND dtl.SettingType=1
				AND dtl.ProductID=@ProductID
				
				
		--Rule #11
		--Ungrouped Setting members
		UPDATE pt
        SET pt.superPT = spt.minPT - pt.masterPT - pt.agentPT
         FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = pt.sporttype
                                                   AND spt.bettype = pt.bettype
                                                   AND spt.islive = pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
         WHERE pt.agentPT + pt.masterPT + pt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
			
		--Grouped Setting members
		UPDATE gpt
        SET gpt.superPT = spt.minPT - gpt.masterPT - gpt.agentPT
         FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                   AND spt.sporttype = gpt.sporttype
                                                   AND spt.bettype = gpt.bettype
                                                   AND spt.islive = gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
         WHERE gpt.agentPT + gpt.masterPT + gpt.superPT < spt.minPT
         AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
			
			
		--Rule #12
		--Ungrouped members
		UPDATE pt WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN spt.superPT - pt.masterPT - pt.agentPT < 0 THEN 0
                       ELSE spt.superPT - pt.masterPT - pt.agentPT
                     END
                 , superPT = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + pt.masterPT + pt.agentPT > spt.superPT THEN spt.superPT - @spos
                       ELSE pt.masterPT + pt.agentPT
                     END
                 , @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mpt.minPT THEN mpt.minPT
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - pt.agentPT < 0 THEN 0
                       ELSE @mapos - pt.agentPT
                     END
                 , masterPT = @mpos
                 , @apos =
                     CASE
                       WHEN pt.agentPT + @mpos > @mapos THEN @mapos - @mpos
                       ELSE pt.agentPT
                     END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
              FROM dbo.CustPTSetting3rd_Member pt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON pt.custid = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = pt.sporttype
                                                  AND spt.bettype=pt.bettype
                                                  AND spt.islive=pt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = pt.sporttype
                                                  AND mpt.bettype=pt.bettype
                                                  AND mpt.islive=pt.islive
         INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = pt.sporttype
                                                  AND apt.bettype=pt.bettype
                                                  AND apt.islive=pt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON pt.sporttype=dtl.SportType
        AND pt.bettype=dtl.BetType AND pt.islive=dtl.IsLive
        WHERE pt.superPT + pt.agentPT + pt.masterPT > spt.superPT
        AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
		
		
		--Grouped members
		UPDATE gpt WITH(ROWLOCK, UPDLOCK)
               SET @spos =
                     CASE
                       WHEN spt.superPT - gpt.masterPT - gpt.agentPT < 0 THEN 0
                       ELSE spt.superPT - gpt.masterPT - gpt.agentPT
                     END
                 , superPT = @spos
                 , @mapos1 =
                     CASE
                       WHEN @spos + gpt.masterPT + gpt.agentPT > spt.superPT THEN spt.superPT - @spos
                       ELSE gpt.masterPT + gpt.agentPT
                     END
                 , @maxmapos =
                     CASE
                       WHEN mpt.masterPT > mpt.maxPT THEN mpt.maxPT
                       ELSE mpt.masterPT
                     END
                 , @mapos2 =
                     CASE
                       WHEN @mapos1 > @maxmapos THEN @maxmapos
                       ELSE @mapos1
                     END
                 , @mapos =
                     CASE
                       WHEN @mapos2 < mpt.minPT THEN mpt.minPT
                       ELSE @mapos2
                     END
                 , @mpos =
                     CASE
                       WHEN @mapos - gpt.agentPT < 0 THEN 0
                       ELSE @mapos - gpt.agentPT
                     END
                 , masterPT = @mpos
                 , @apos =
                     CASE
                       WHEN gpt.agentPT + @mpos > @mapos THEN @mapos - @mpos
                       ELSE gpt.agentPT
                     END
                 , agentPT =
                     CASE
                       WHEN @apos < apt.minPT THEN apt.minPT
                       ELSE @apos
                     END
        FROM dbo.AgentPTGroupSetting_3rd gpt WITH(ROWLOCK, UPDLOCK)
        INNER JOIN dbo.custinfo mb WITH(NOLOCK) ON gpt.AgentID = mb.custid
                                           AND mb.recommend = @CustID
                                           AND mb.roleid = 1
                                           AND mb.Enabled = 1
        INNER JOIN dbo.CustPTSetting3rd_Agent spt WITH(NOLOCK) ON spt.custid = mb.srecommend
                                                  AND spt.sporttype = gpt.sporttype
                                                  AND spt.bettype=gpt.bettype
                                                  AND spt.islive=gpt.islive
        INNER JOIN dbo.CustPTSetting3rd_Agent mpt WITH(NOLOCK) ON mpt.custid = mb.mrecommend
                                                  AND mpt.sporttype = gpt.sporttype
                                                  AND mpt.bettype=gpt.bettype
                                                  AND mpt.islive=gpt.islive
         INNER JOIN dbo.CustPTSetting3rd_Agent apt WITH(NOLOCK) ON apt.custid = mb.recommend
                                                  AND apt.sporttype = gpt.sporttype
                                                  AND apt.bettype=gpt.bettype
                                                  AND apt.islive=gpt.islive
        INNER JOIN dbo.ProductSettingDetail dtl WITH(NOLOCK) ON gpt.sporttype=dtl.SportType
        AND gpt.bettype=dtl.BetType AND gpt.islive=dtl.IsLive
        WHERE gpt.superPT + gpt.agentPT + gpt.masterPT > spt.superPT
        AND dtl.SettingType=1
			AND dtl.ProductID=@ProductID
	END
END