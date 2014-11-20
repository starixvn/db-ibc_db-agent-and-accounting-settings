SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CorrectUpdSMA_PresetPT]
	@CustID INT,
	@RoleID INT,
	@updateallmembers BIT = 0,
	@New_Old_AutoPT_XML VARCHAR(MAX),
	@newspositiontaking TINYINT = 0,
	@ProductID TINYINT
AS
	/*
	Created: 20141110@Dominic
	Task : Correct PT after update presetPT
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Corrected Downline 's ID
	• @New_Old_AutoPT_XML
		<ROOT>
			<AutoPT
					SportType="1" 
					BetType="1" 
					IsLive="1" 
					IsautomPT_Old="0" 
					AutomPT_Old="0"
					IsautomPT_New="0" 
					AutomPT_New="0"  
					IsautosPT_Old="0" 
					AutosPT_Old="0"
					IsautosPT_New="0" 
					AutosPT_New="0"
			/>
		</ROOT>
	*/
BEGIN

	DECLARE @iDoc INT
	DECLARE @mpos SMALLMONEY
              , @apos SMALLMONEY
              , @spos SMALLMONEY
              , @mapos1 SMALLMONEY
              , @mapos2 SMALLMONEY
              , @mapos SMALLMONEY
              , @maxmapos SMALLMONEY
              
    IF @New_Old_AutoPT_XML IS NOT NULL 
    BEGIN
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @PositionTaking_XML
		
		SELECT *
		INTO #newOldAutoPTTbl
		FROM OPENXML (@iDoc, '/ROOT/AutoPT',1) 
		WITH(SportType smallint, BetType smallint, IsLive BIT,
			IsautomPT_Old BIT, AutomPT_Old TINYINT,IsautomPT_New BIT, AutomPT_New TINYINT,
			IsautosPT_Old BIT,AutosPT_Old TINYINT,IsautosPT_New BIT,AutosPT_New TINYINT)	
		
		EXEC sp_xml_removedocument @iDoc
    END

	IF @RoleID=4
	BEGIN
		--if is1|is3 then s1 = min(s4-m1-a1, is1?us1:us3)
		 UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
           SET ptmem.superPT =
                 CASE
                   WHEN pts.superPT - ptmem.masterPT - ptmem.agentPT >
                          CASE
                            WHEN ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT
                          END
                     THEN CASE
                            WHEN ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT
                          END
                   ELSE pts.superPT - ptmem.masterPT - ptmem.agentPT
                 END
          FROM dbo.CustPTSetting3rd_Member ptmem
    INNER JOIN custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid 
										AND c.srecommend = @CustID
										AND c.roleid = 1
										AND c.Enabled = 1
    INNER JOIN CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = c.mrecommend
                                           AND ptm.sporttype = ptmem.sporttype
                                           AND ptm.bettype = ptmem.bettype
                                           AND ptm.isLive=ptmem.isLive
    INNER JOIN CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = @CustID
                                           AND pts.sporttype = ptmem.sporttype
                                           AND pts.bettype = ptmem.bettype
                                           AND pts.isLive=ptmem.isLive
         WHERE (ptmem.isautosPT = 1
                OR ptm.isautosPT = 1)								
	END
	ELSE IF @RoleID=3
	BEGIN
		/*****Correct AUTO PT - START*****/
		--if is3>0 s1 =( is1=0 ? min(s4-m1-a1,us3):s1)
		UPDATE ptmem
		SET ptmem.superPT =
                     CASE
                       WHEN pts.superPT - ptmem.masterPT - ptmem.agentPT > tmp.AutosPT_New THEN tmp.AutosPT_New
                       ELSE pts.superPT - ptmem.masterPT - ptmem.agentPT
                     END
		FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid 
										AND c.mrecommend = @CustID
										AND c.roleid = 1
										AND c.Enabled = 1
		INNER JOIN #newOldAutoPTTbl tmp ON tmp.sporttype = ptmem.sporttype
                                           AND tmp.bettype = ptmem.bettype
                                           AND tmp.isLive=ptmem.isLive
        INNER JOIN CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = c.srecommend
                                           AND pts.sporttype = ptmem.sporttype
                                           AND pts.bettype = ptmem.bettype
                                           AND pts.isLive=ptmem.isLive
        WHERE (tmp.IsautosPT_Old <> tmp.IsautosPT_New OR tmp.AutosPT_Old <> tmp.AutosPT_New)
        AND tmp.IsautosPT_New = 1
        AND ptmem.isautosPT=0
        
        --if is3=0 & update all members then
		--s1=is1=0?min(s3,newspt):s1 (for case remove auto pt show popup)
        UPDATE ptmem
		SET ptmem.superPT =
                    CASE
                       WHEN ptm.superPT < @newspositiontaking THEN ptm.superPT
                       ELSE @newspositiontaking
                     END
		FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid 
										AND c.mrecommend = @CustID
										AND c.roleid = 1
										AND c.Enabled = 1
		INNER JOIN #newOldAutoPTTbl tmp ON tmp.sporttype = ptmem.sporttype
                                           AND tmp.bettype = ptmem.bettype
                                           AND tmp.isLive=ptmem.isLive
        INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = c.mrecommend
                                           AND ptm.sporttype = ptmem.sporttype
                                           AND ptm.bettype = ptmem.bettype
                                           AND ptm.isLive=ptmem.isLive
        WHERE (tmp.IsautosPT_Old <> tmp.IsautosPT_New)
        AND tmp.IsautosPT_New = 0
        AND ptmem.isautosPT=0
        AND @updateallmembers=1
        
        /*****Correct AUTO PT - END*****/
              
        --if im2=1 or im1 = 1 then
		--m1=min(m3-a1, im1=1 ? um1 : um2)
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
           SET ptmem.masterPT = 
                 CASE
                   WHEN ptm.masterPT - ptmem.agentPT >
                          CASE
                            WHEN ptmem.isautomPT = 1 THEN ptmem.automPT
                            ELSE pta.automPT
                          END
                     THEN CASE
                            WHEN ptmem.isautomPT = 1 THEN ptmem.automPT
                            ELSE pta.automPT
                          END
                   ELSE ptm.masterPT - ptmem.agentPT
                 END
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid
											AND c.mrecommend = @CustID
										   AND c.roleid = 1
										   AND c.Enabled = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = c.mrecommend
											   AND ptm.sporttype = ptmem.sporttype
											   AND ptm.bettype = ptmem.bettype
											   AND ptm.isLive=ptmem.isLive
		INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = c.recommend
											   AND pta.sporttype = ptmem.sporttype
											   AND pta.bettype = ptmem.bettype
											   AND pta.isLive=ptmem.isLive
		 WHERE (pta.isautomPT = 1
					OR ptmem.isautomPT = 1
				   )
        
        --if m1+a1 < n3 then m1=n3-a1
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.masterPT = ptm.minPT - ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo mb WITH(NOLOCK) ON ptmem.custid = mb.custid
										   AND mb.mrecommend = @CustID
										   AND mb.roleid = 1
										   AND mb.Enabled = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = @CustID
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
		WHERE ptmem.agentPT + ptmem.masterPT < ptm.minPT
         
         
		--if a1+m1 > l3 then
		--@x=min(m3,l3)
		--@y= max(0,@x-a1)
		--m1=@y
		--@z=min(@x-@y,a1)
		--a1=max(@z,n2)
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET @maxmapos =
                 CASE
                   WHEN ptm.masterPT > ptm.maxPT THEN ptm.maxPT
                   ELSE ptm.masterPT
                 END
             , @mpos =
                 CASE
                   WHEN @maxmapos - ptmem.agentPT < 0 THEN 0
                   ELSE @maxmapos-ptmem.agentPT
                 END
             , ptmem.masterPT = @mpos
             , @apos =
                 CASE
                   WHEN ptmem.agentPT + @mpos > @maxmapos THEN @maxmapos - @mpos
                   ELSE ptmem.agentPT
                 END
             , ptmem.agentPT =
                 CASE
                   WHEN @apos < pta.minPT THEN pta.minPT
                   ELSE @apos
                 END
          FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo mb WITH(NOLOCK) ON ptmem.custid = mb.custid
											   AND mb.mrecommend = @CustID
											   AND mb.roleid = 1
											   AND mb.Enabled = 1
			INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = @CustID
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
			INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = mb.recommend
												AND pta.sporttype = ptmem.sporttype
												AND pta.bettype = ptmem.bettype
												AND pta.isLive=ptmem.isLive
			WHERE ptmem.agentPT + ptmem.masterPT > ptm.maxPT

        --if is1= 1 or is3 = 1 then
		--s1 = min(s4-m1-a1,is1=1 ? us1 : us3)
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK) 
           SET ptmem.superPT =
                 CASE
                   WHEN pts.superPT - ptmem.masterPT - ptmem.agentPT >
                          CASE
                            WHEN ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT
                          END
                     THEN CASE
                            WHEN ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT
                          END
                   ELSE pts.superPT - ptmem.masterPT - ptmem.agentPT
                 END
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid
											AND c.mrecommend = @CustID
										   AND c.roleid = 1
										   AND c.Enabled = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = @CustID
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
		INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = c.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
		WHERE 
			    (ptmem.isautosPT = 1
					OR ptm.isautosPT = 1
				   )
				   
		--if s1+ m1 + a1< n4 then s1= n4-m1-a1
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.superPT = pts.minPT - ptmem.masterPT - ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo mb WITH(NOLOCK) ON ptmem.custid = mb.custid
										   AND mb.mrecommend = @CustID
										   AND mb.roleid = 1
										   AND mb.Enabled = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = mb.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
		WHERE ptmem.agentPT + ptmem.masterPT + ptmem.superPT < pts.minPT
		
		--if s1+ m1 + a1> s4 then
		--s1=max(0,s4-m1-a1)
		--@mapos1=s1_new+m1+a1>s4 ? s4-s1_new : m1+a1
		--@maxmapos=min(m3,l3)
		--@mapos2=min(@mapos1,@maxmapos)
		--@mapos=max(@mapos2,n3)
		--m1=max(0,@mapos-a1)
		--a1= m1_new+a1>@mapos ? @mapos-m1_new : a1
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
           SET @spos =
                 CASE
                   WHEN pts.superPT - ptmem.masterPT - ptmem.agentPT < 0 THEN 0
                   ELSE pts.superPT - ptmem.masterPT - ptmem.agentPT
                 END
             , superPT = @spos
             , @mapos1 =
                 CASE
                   WHEN @spos + ptmem.masterPT + ptmem.agentPT > pts.superPT THEN pts.superPT - @spos
                   ELSE ptmem.masterPT + ptmem.agentPT
                 END
             , @maxmapos =
                 CASE
                   WHEN ptm.masterPT > ptm.maxPT THEN ptm.maxPT
                   ELSE ptm.masterPT
                 END
             , @mapos2 =
                 CASE
                   WHEN @mapos1 > @maxmapos THEN @maxmapos
                   ELSE @mapos1
                 END
             , @mapos =
                 CASE
                   WHEN @mapos2 < ptm.minPT THEN ptm.minPT
                   ELSE @mapos2
                 END
             , @mpos =
                 CASE
                   WHEN @mapos - ptmem.agentPT < 0 THEN 0
                   ELSE @mapos - ptmem.agentPT
                 END
             , masterPT = @mpos
             , @apos =
                 CASE
                   WHEN ptmem.agentPT + @mpos > @mapos THEN @mapos - @mpos
                   ELSE ptmem.agentPT
                 END
             , agentPT =
                 CASE
                   WHEN @apos < pta.minPT THEN pta.minPT
                   ELSE @apos
                 END
          FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
			INNER JOIN custinfo mb WITH(NOLOCK) ON ptmem.custid = mb.custid
											   AND mb.mrecommend = @CustID
											   AND mb.roleid = 1
											   AND mb.Enabled = 1
			INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = mb.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
			INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = @CustID
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
			INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = mb.recommend
												AND pta.sporttype = ptmem.sporttype
												AND pta.bettype = ptmem.bettype
												AND pta.isLive=ptmem.isLive
         WHERE ptmem.superPT + ptmem.agentPT + ptmem.masterPT > pts.superPT
	END
	ELSE IF @RoleID=2
	BEGIN
		/*****Correct AUTO PT - START*****/	
		--if im2 > 0 then m1=min(m3-a1,um2)
		UPDATE ptmem
		SET ptmem.masterPT =
                     CASE
                       WHEN ptm.masterPT-ptmem.agentPT < tmp.AutomPT_New THEN ptm.masterPT-ptmem.agentPT
                       ELSE tmp.AutomPT_New
                     END
		FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid 
										AND c.recommend = @CustID
										AND c.roleid = 1
		INNER JOIN #newOldAutoPTTbl tmp ON tmp.sporttype = ptmem.sporttype
                                           AND tmp.bettype = ptmem.bettype
                                           AND tmp.isLive=ptmem.isLive
        INNER JOIN CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = c.mrecommend
                                           AND ptm.sporttype = ptmem.sporttype
                                           AND ptm.bettype = ptmem.bettype
                                           AND ptm.isLive=ptmem.isLive
        WHERE (tmp.IsautomPT_Old <> tmp.IsautomPT_New OR tmp.AutomPT_Old <> tmp.AutomPT_New)
        AND tmp.IsautomPT_New = 1
        
        --if im2_new=0 and im2_new <> im2_old and
		--update all members then
		--m1=min(m2,@newmpositiontaking) (remove auto pt popup)
        UPDATE ptmem
		SET ptmem.masterPT =
                    CASE
                       WHEN pta.masterPT < @newspositiontaking THEN pta.masterPT
                       ELSE @newspositiontaking
                     END
		FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo c WITH(NOLOCK) ON ptmem.custid = c.custid 
										AND c.mrecommend = @CustID
										AND c.roleid = 1
		INNER JOIN #newOldAutoPTTbl tmp ON tmp.sporttype = ptmem.sporttype
                                           AND tmp.bettype = ptmem.bettype
                                           AND tmp.isLive=ptmem.isLive
        INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = c.recommend
                                           AND pta.sporttype = ptmem.sporttype
                                           AND pta.bettype = ptmem.bettype
                                           AND pta.isLive=ptmem.isLive
        WHERE (tmp.IsautosPT_Old <> tmp.IsautosPT_New)
        AND tmp.IsautosPT_New = 0
        AND @updateallmembers=1
        
        /*****Correct AUTO PT - END*****/
        --if a1 < n2 then a1 = n2
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.agentPT = pta.minPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK) 
        inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = mb.recommend
												AND pta.sporttype = ptmem.sporttype
												AND pta.bettype = ptmem.bettype
												AND pta.isLive=ptmem.isLive
         WHERE ptmem.agentPT < pta.minPT 
        
        --if a1 > l2 then a1 = l2
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.agentPT = pta.maxPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)  
        inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = mb.recommend
												AND pta.sporttype = ptmem.sporttype
												AND pta.bettype = ptmem.bettype
												AND pta.isLive=ptmem.isLive
        WHERE ptmem.agentPT > pta.maxPT 
        
        --if m1+a1>m3 then m1=m3-a1
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.masterPT=ptm.masterPT-ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
        inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = mb.mrecommend
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
        WHERE ptmem.agentPT + ptmem.masterPT > ptm.masterPT 
        
        
        --if im2=1 or im1 = 1 then m1=min(m3-a1,im1?um1:um2)
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK) 
           SET ptmem.masterPT = 
                case when ptm.masterPT - ptmem.agentPT >
                 CASE
                   WHEN ptmem.isautomPT = 1 THEN ptmem.automPT
                            ELSE pta.automPT end
                then
                 CASE
                   WHEN ptmem.isautomPT = 1 THEN ptmem.automPT
                            ELSE pta.automPT end
                else  ptm.masterPT - ptmem.agentPT end
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN custinfo mb WITH(NOLOCK) ON ptmem.custid = mb.custid
											AND mb.recommend = @CustID
											AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = mb.mrecommend
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
		INNER JOIN dbo.CustPTSetting3rd_Agent pta WITH(NOLOCK) ON pta.custid = mb.recommend
												AND pta.sporttype = ptmem.sporttype
												AND pta.bettype = ptmem.bettype
												AND pta.isLive=ptmem.isLive
        WHERE (pta.isautomPT = 1 or ptmem.isautomPT = 1)
        
        
        --if m1+a1 < n3 then m1=n3-a1
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.masterPT = ptm.minPT - ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
        inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = mb.mrecommend
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
        WHERE ptmem.masterPT + ptmem.agentPT < ptm.minPT
       
		--if m1+a1 > l3 then m1=l3-a1 
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET ptmem.masterPT = ptm.maxPT - ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
        inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = mb.mrecommend
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
        WHERE ptmem.masterPT + ptmem.agentPT > ptm.maxPT

		
		--if is1= 1 or is3 = 1 then
		--s1 = min(s4-m1-a1,is1?us1:us3)
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK) 
           SET ptmem.superPT =
                 CASE
                   WHEN pts.superPT - ptmem.masterPT - ptmem.agentPT >
                          CASE
                            WHEN ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT end THEN (case when ptmem.isautosPT = 1 THEN ptmem.autosPT
                            ELSE ptm.autosPT end)
                            ELSE pts.superPT - ptmem.masterPT - ptmem.agentPT end 
         FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent ptm WITH(NOLOCK) ON ptm.custid = mb.mrecommend
												AND ptm.sporttype = ptmem.sporttype
												AND ptm.bettype = ptmem.bettype
												AND ptm.isLive=ptmem.isLive
		INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = mb.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
         WHERE (ptmem.isautosPT = 1 or ptm.isautosPT = 1)
         
         --if a1+m1+s1<n4 then s1 = n4-m1-a1
          --Nonlive(min)
        UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
        SET 
            ptmem.superPT = pts.minPT - ptmem.masterPT - ptmem.agentPT
        FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = mb.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
		WHERE ptmem.agentPT+ptmem.masterPT+ptmem.superPT<pts.minPT
		
		
		--if a1+m1+s1>l4 then s1 = l4-m1-a1
		UPDATE ptmem WITH(ROWLOCK, UPDLOCK)
       SET 
        ptmem.superPT = pts.maxPT - ptmem.masterPT - ptmem.agentPT
       FROM dbo.CustPTSetting3rd_Member ptmem WITH(ROWLOCK, UPDLOCK)
		inner join custinfo mb with(nolock) ON ptmem.custid = mb.custid AND mb.recommend = @CustID AND mb.roleid = 1
		INNER JOIN dbo.CustPTSetting3rd_Agent pts WITH(NOLOCK) ON pts.custid = mb.srecommend
												AND pts.sporttype = ptmem.sporttype
												AND pts.bettype = ptmem.bettype
												AND pts.isLive=ptmem.isLive
         WHERE ptmem.agentPT+ptmem.masterPT+ptmem.superPT>pts.maxPT
	END
END