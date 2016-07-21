ALTER PROCEDURE [dbo].[Acc_CustSetting_06]
    @CustId              INT
  , @RoleId              INT
  , @groupa              DECIMAL(9, 8) = 0
  , @groupb              DECIMAL(9, 8) = 0
  , @groupc              DECIMAL(9, 8) = 0
  , @groupd              DECIMAL(9, 8) = 0
  , @discountcs          DECIMAL(9, 8) = 0
  , @discountHRFixedOdds DECIMAL(9, 8) = 0
  , @discount1x2         DECIMAL(9, 8) = 0
  , @discountMyanmarOdds DECIMAL(9,8)=0
  ,	@IsMyanmarOdds BIT = 0

AS
    /*
    Created: Kathy
    Date: 20131029
    Task : Update commission [Redmine:#3244]
    DB: DBTXN.bodb02
    Original: 
    Revisions:
        - 20131029: Update Sportbook's commission for all level. Refer to:
            + Acc_CustomerUpdSuper_Commission
            + Acc_CustomerUpdMaster_Commission
            + Acc_CustomerUpdAgent_Commission
            + Acc_CustomerUpdMember_Commission
        
        - 20131105@Elodie: Add HR Fixed Odds [Redmine:#6505]
        - 20140708@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
        - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                            2.Code aligning on modified parts
		- 20141113@Johnson: Hardcode agent list not give commission for downlines [Redmine #25787]                      
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST   
		- 20150616@Johnson: Add more hard customers not give commission [Redmine: #34798]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20151111@Helen: Add more hard customers not give commission [Redmine: #47068]
	    - 20151222@Johnson: Add more customers not give commission [Redmine: #49494]		
	    - 20160125@Helen: Add more customers not give commission [Redmine: #51057]		
		- 20160608@Elodie: Add more customers not give commission [Redmine: #58999]		
		- 20160621@Winnie: Add more customers not give commission [Redmine: #58999]		
    Param's Explanation: 

    */
BEGIN
    SET NOCOUNT ON;
    
    if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('customer') = 1 
	   AND dbo.f_CheckRepTable('CustCommRate') = 1 
	   AND dbo.f_CheckRepTable('AgentCommRate') = 1 
	   )
   
     RETURN    
	
    --20141113@Johnson: hardcode customer list not give commission for downlines	   
    DECLARE @tblCustList TABLE(custid INT, roleid INT)
	
	INSERT INTO @tblCustList(custid, roleid)
			 SELECT	52466		,	2	--	8RM
	UNION SELECT	134456		,	2	--	XYZRM
	UNION SELECT	11656507	,	2	--	J00101311101
	UNION SELECT	11656514	,	2	--	J00101311102
	UNION SELECT	11656525	,	2	--	J00101311150
	UNION SELECT	11642591	,	2	--	XXCH60011100
	UNION SELECT	3645795		,	2	--	999RMA01
	UNION SELECT	3645796		,	2	--	999RMA02
	UNION SELECT	3645798		,	2	--	999RMA50
	UNION SELECT	4430389		,	2	--	C527A
	UNION SELECT	4430395		,	2	--	C527B
	UNION SELECT	6201735		,	2	--	6HK2501
	UNION SELECT	15819264	,	2	--	HK000002
	UNION SELECT	1098992		,	1	--	007P
	UNION SELECT	2344		,	1	--	RICHK
	UNION SELECT	753422		,	1	--	MOONSHK
	UNION SELECT	12254453	,	1	--	6666AHK002
	UNION SELECT	15976531	,	1	--	6666AHK005
	UNION SELECT	12295775	,	1	--	10BA
	UNION SELECT	1280		,	1	--	312RMB
	UNION SELECT	1241353		,	1	--	315RMB
	UNION SELECT	1981797		,	1	--	318RMB
	UNION SELECT	4230489		,	1	--	319RMB
	UNION SELECT	4396024		,	1	--	527RMB
	UNION SELECT	11405172	,	1	--	556RMB
	UNION SELECT	10409086	,	1	--	388RMB
	UNION SELECT	8679169		,	1	--	585RMB
	UNION SELECT	13885522	,	1	--	688HKK
	
	--20150616@Johnson: add more customers into list
	UNION SELECT 	1098992		,	1	-- 	007P
	UNION SELECT 	12295775	,	1	-- 	10BA
	UNION SELECT 	4706215		,	1	-- 	168rmb
	UNION SELECT 	1686		,	1	-- 	239RMB
	UNION SELECT 	1280		,	1	-- 	312rmb
	UNION SELECT 	1241353		,	1	-- 	315RMB
	UNION SELECT 	1981797		,	1	-- 	318RMB
	UNION SELECT 	4230489		,	1	-- 	319RMB
	UNION SELECT 	10409086	,	1	-- 	388rmb
	UNION SELECT 	4396024		,	1	-- 	527RMB
	UNION SELECT 	11405172	,	1	-- 	556RMB
	UNION SELECT 	8679169		,	1	-- 	585RMB
	UNION SELECT 	13885522	,	1	-- 	688HKK
	UNION SELECT 	16698297	,	1	-- 	789RMB
	UNION SELECT 	753422		,	1	-- 	MOONSHK
	UNION SELECT 	1540595		,	1	-- 	08HK
	UNION SELECT 	15976531	,	1	-- 	6666AHK005
	UNION SELECT 	640041		,	1	-- 	M3000
	
	--20151111Helen: hardcode for 919RMB and VS3077HK
	UNION SELECT	12163698	,	1	--	919RMB
	UNION SELECT	19573984	,	1	--	VS3077HK
	
	--20151222Johnson: hardcode for 55HK and 169RMB
	UNION SELECT	19980168	,	1	--	55HK
	UNION SELECT	20044385	,	1	--	169RMB
	
	--20160125Helen: hardcode for C981RMB 
	UNION SELECT	20617088	,	1	--	C981RMB
	
	--20160608@Elodie: hardcode for SUNRM and 922HK
	UNION SELECT	14962417	,	1	--	SUNRM
	UNION SELECT	22121306	,	1	--	922HK
	
	--20160621@Winnie: add more customers into list
	UNION SELECT	7236578		,	1	--	316RMB
	UNION SELECT	22210997	,	1	--	8888HK
	UNION SELECT	18142826	,	1	--	MAX321
	UNION SELECT	22212192	,	1	--	885HK
	UNION SELECT	22296183	,	1	--	228HK 
	UNION SELECT	22296348	,	1	--	EURO3 
	UNION SELECT	14960005	,	1	--	230RMB
	UNION SELECT	13886194	,	1	--	007RIC 
	UNION SELECT	22497394	,	1	--	8888AHK 
	UNION SELECT	22682195	,	1	--	10AHK

	--UUS accounnts for testing
	UNION SELECT	14180041	,	2	--	supertestUAT0101
	UNION SELECT	14228743	,	1	--	SUPERTEST20000000
	UNION SELECT	14497432	,	1	--	SUPERTEST20000001
	--End customer list------------------------------------------
	   
    IF @RoleId = 4
    BEGIN
        --Update @Super: g4, s4
        UPDATE custsetting WITH(ROWLOCK, UPDLOCK)
           SET groupa = CASE
                          WHEN bettype IN (1, 2, 3, 7, 8) THEN @groupa
                          ELSE groupa
                        END
             , groupb = CASE
                          WHEN bettype IN (1, 2, 3, 7, 8) THEN @groupb
                          ELSE groupb
                        END
             , groupc = CASE
                          WHEN bettype IN (1, 2, 3, 7, 8) THEN @groupc
                          ELSE groupc
                        END
             , groupd = CASE
                          WHEN bettype IN (1, 2, 3, 7, 8) THEN @groupd
                          ELSE groupd
                        END
             , sdiscount = CASE
                             WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154 THEN @discountcs WHEN bettype = 5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds
                             ELSE sdiscount
                           END
         WHERE custid = @custid

        --Update g3=g4 if g3>g4
        --         g2=g4 if g2>g4
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET groupa = @groupa
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid
           AND ((ci.roleid = 2 AND ci.Enabled = 1)
                or ci.roleid = 3
               )
           AND cs.bettype IN (1, 2, 3, 7, 8)
           AND groupa > @groupa
    
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET groupb = @groupb
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid
           AND ((ci.roleid = 2 AND ci.Enabled = 1)
                or ci.roleid = 3
               )
           AND cs.bettype IN (1, 2, 3, 7, 8)
           AND groupb > @groupb

        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET groupc = @groupc 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid 
           AND ((ci.roleid = 2 AND ci.Enabled = 1)
                or ci.roleid = 3
               )
           AND cs.bettype IN (1, 2, 3, 7, 8)
           AND groupc > @groupc
    
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET groupd = @groupd 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid 
           AND ((ci.roleid = 2 AND ci.Enabled = 1)
                or ci.roleid = 3
               )
           AND cs.bettype IN (1, 2, 3, 7, 8)
           AND groupd > @groupd

        --Update g4 to Member level
        UPDATE cs WITH (ROWLOCK, UPDLOCK) 
           SET sdiscount =
                 CASE
                   WHEN c.ugroup IN ('a', 'hka', 'dea') THEN @groupa 
                   WHEN c.ugroup IN ('b', 'hkb', 'deb') THEN @groupb 
                   WHEN c.ugroup IN ('c', 'hkc', 'dec') THEN @groupc 
                   WHEN c.ugroup IN ('d', 'hkd', 'ded') THEN @groupd
                   ELSE @groupa
                 END 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
    INNER JOIN Customer c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid 
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND ci.Enabled = 1
           AND cs.bettype IN (1, 2, 3, 7, 8) 

    
        --Update s4 to member level
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET sdiscount = @discountcs 
          FROM custsetting cs
    INNER JOIN custinfo AS c WITH (NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid
            AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)           
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.bettype IN (4, 6, 9, 10, 20, 21, 22, 9999)
           AND cs.sporttype <> 154


        --Update s4 to member level --1x2
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET sdiscount = @discount1x2 
          FROM custsetting cs
    INNER JOIN custinfo c WITH (NOLOCK) ON cs.custid = c.custid
        WHERE c.srecommend = @custid
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)           
          AND c.roleid = 1
          AND c.Enabled = 1
          AND cs.bettype = 5
        
        --Update s4 to member level --HRFixedOdds
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET sdiscount = @discountHRFixedOdds
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.bettype = 20
           AND cs.sporttype = 154
    
        --Update m3=s4 if m3>s4
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     
            adiscount = @discountcs 
        FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
        WHERE ci.srecommend = @custid 
            AND ci.roleid = 3 
            AND bettype IN(4,6,9,10,20,21,22,9999) and sporttype <> 154 
            AND adiscount>@discountcs 
    
        --Update m3=s4 if m3>s4  --1x2
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     
            adiscount = @discount1x2
        FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
        WHERE ci.srecommend = @custid 
            AND ci.roleid = 3 
            AND bettype = 5 
            AND adiscount>@discount1x2 
         
        --Update m3=s4 if m3>s4  --HR Fixed Odds
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     
            adiscount = @discountHRFixedOdds
        FROM custsetting INNER JOIN custinfo AS ci WITH (NOLOCK) ON custsetting.custid = ci.custid
        WHERE ci.srecommend = @custid 
            AND ci.roleid = 3 
            AND bettype = 20 and sporttype = 154
            AND adiscount>@discountHRFixedOdds 
            
        --Update a2=s4 if a2>s4
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET discount = @discountcs
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND bettype       IN (4, 6, 9, 10, 20, 21, 22, 9999)
           and sporttype     <> 154
           AND discount      > @discountcs
    
        --Update a2=s4 if a2>s4  --1x2
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET discount = @discount1x2
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND bettype       = 5
           AND discount      > @discount1x2

        --Update a2=s4 if a2>s4  --HR Fixed Odds
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET discount = @discountHRFixedOdds
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.srecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND bettype       = 20
           and sporttype     = 154
           AND discount      > @discountHRFixedOdds

        --At member level, update adiscount = sdiscount  if adiscount > sdiscount
        UPDATE cs WITH (ROWLOCK, UPDLOCK) 
           SET adiscount = sdiscount
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.adiscount > cs.sdiscount


        --At member level, update discount = adiscount  if discount > adiscount
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET discount = adiscount
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid 
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.discount > cs.adiscount


        --At member level, update playerdiscount = discount  if playerdiscount > discount
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET playerdiscount = discount
          FROM custsetting cs
    INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.srecommend = @custid
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.playerdiscount > cs.discount
        
       -- For Myanmar Odds
        IF @IsMyanmarOdds = 1
        BEGIN
        
			UPDATE dbo.AgentCommRate WITH(UPDLOCK, ROWLOCK)
               SET CommRate = @discountMyanmarOdds
             WHERE custid = @CustId AND bettype = 301
                AND sporttype = 1 AND CommRate <> @discountMyanmarOdds

            --Update g3=g4 if g3>g4
            UPDATE ac
               SET ac.CommRate = @discountMyanmarOdds
              FROM dbo.AgentCommRate ac WITH(UPDLOCK, ROWLOCK)
				JOIN dbo.CustInfo ci WITH(NOLOCK) ON ac.custid = ci.custid 
             WHERE ci.srecommend = @custid AND ci.roleid = 3
                 AND bettype = 301 AND ac.sporttype = 1
                 AND ac.CommRate > @discountMyanmarOdds

            --Update g2=g4 if g2>g4
            UPDATE ac
               SET ac.CommRate = @discountMyanmarOdds
              FROM dbo.AgentCommRate ac WITH(UPDLOCK, ROWLOCK)
				JOIN dbo.CustInfo ci WITH(NOLOCK) ON ac.custid = ci.custid 
             WHERE ci.srecommend = @custid
               AND ci.roleid     = 2
               AND ci.Enabled    = 1
               AND bettype       = 301
               AND ac.sporttype  = 1
               AND ac.CommRate   > @discountMyanmarOdds

			-- Update table CustCommRate 
			IF EXISTS (SELECT 1 FROM CustInfo WITH(NOLOCK) WHERE srecommend = @CustId AND roleid = 1)
			BEGIN
				UPDATE cs
					SET sdiscount = @discountMyanmarOdds,
						adiscount = MasterComm.CommRate,
						discount =  AgentComm.CommRate,
						playerdiscount = CASE 
												WHEN cs.playerdiscount > AgentComm.CommRate THEN AgentComm.CommRate 
												ELSE cs.playerdiscount
										 END	
				 FROM dbo.CustCommRate cs WITH(UPDLOCK, ROWLOCK)
					JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
					
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.mrecommend
								) AS MasterComm
								
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.recommend
								) AS AgentComm				
				 WHERE ci.srecommend = @custid
					   AND ci.roleid = 1
					   AND ci.Enabled = 1
					   AND cs.Bettype = 301
					   AND cs.Sporttype = 1
				   
			END   
			
        END  
    END
    
    IF @RoleId = 3
    BEGIN
        --Update @Master: g3, m3
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
        SET
            groupa = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa ELSE groupa END ,
            groupb = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupb ELSE groupb END ,
            groupc = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupc ELSE groupc END ,
            groupd = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupd ELSE groupd END ,
            adiscount = CASE WHEN bettype IN (4,6,9,10,20,21,22,9999) AND sporttype <> 154 THEN @discountcs WHEN bettype = 5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds ELSE adiscount END
        WHERE custid=@custid 

        --Update g2 = g3 if g2>g3
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET groupa = CASE
                          WHEN groupa > @groupa THEN @groupa
                          ELSE groupa
                        END
             , groupb = CASE
                          WHEN groupb > @groupb THEN @groupb
                          ELSE groupb
                        END
             , groupc = CASE
                          WHEN groupc > @groupc THEN @groupc
                          ELSE groupc
                        END
             , groupd = CASE
                          WHEN groupd > @groupd THEN @groupd
                          ELSE groupd
                        END
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.bettype    IN (1, 2, 3, 7, 8)

        --Update a2 = m3 if a2>m3
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET discount = CASE
                            WHEN discount > @discountcs THEN @discountcs
                            ELSE discount
                          END 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.bettype    IN (4, 6, 9, 10, 20, 21, 22, 9999)
           and sporttype     <> 154

        --Update a2 = m3 if a2>m3 --1x2
        UPDATE cs WITH(ROWLOCK, UPDLOCK)
           SET discount = CASE
                            WHEN discount > @discount1x2 THEN @discount1x2
                            ELSE discount
                          END 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.mrecommend = @custid
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.bettype    = 5

        --Update a2 = m3 if a2>m3 --HR Fixed Odds
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET discount = CASE
                            WHEN discount > @discountHRFixedOdds THEN @discountHRFixedOdds
                            ELSE discount
                          END 
          FROM custsetting cs
    INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE ci.mrecommend = @custid 
           AND ci.roleid     = 2
           AND ci.Enabled    = 1
           AND cs.bettype    = 20
           and sporttype     = 154

        --Update g3 @ member level
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET adiscount =
                 CASE
                   WHEN c.ugroup IN ('a', 'hka', 'dea') THEN @groupa 
                   WHEN c.ugroup IN ('b', 'hkb', 'deb') THEN @groupb 
                   WHEN c.ugroup IN ('c', 'hkc', 'dec') THEN @groupc 
                   WHEN c.ugroup IN ('d', 'hkd', 'ded') THEN @groupd
                   ELSE @groupa
                 END
          FROM custsetting cs
    INNER JOIN customer c WITH(NOLOCK) ON cs.custid = c.custid
    INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
         WHERE c.mrecommend = @custid
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND ci.Enabled = 1
           AND cs.bettype IN (1, 2, 3, 7, 8) 


        --Update m3 @ member level
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET adiscount = @discountcs
          FROM custsetting cs
    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.mrecommend = @custid
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.bettype IN (4, 6, 9, 10, 20, 21, 22, 9999)
           AND cs.sporttype <> 154

        --Update m3 @ member level --1x2 
        UPDATE cs WITH (ROWLOCK, UPDLOCK) 
           SET adiscount = @discount1x2
          FROM custsetting cs
    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.mrecommend = @custid
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.bettype = 5

        --Update m3 @ member level --HRFixedOdds
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET adiscount = @discountHRFixedOdds
          FROM custsetting cs
    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.mrecommend = @custid 
           AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.bettype = 20
           AND cs.sporttype = 154


        --At member level, update discount = adiscount  if discount > adiscount
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET discount = adiscount
          FROM custsetting cs
    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.mrecommend = @custid
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.discount > cs.adiscount

        --At member level, update playerdiscount = discount if playerdiscount > discount
        UPDATE cs WITH(ROWLOCK, UPDLOCK) 
           SET playerdiscount = discount
          FROM custsetting cs
    INNER JOIN custInfo c WITH(NOLOCK) ON cs.custid = c.custid
         WHERE c.mrecommend = @custid
           AND c.roleid = 1
           AND c.Enabled = 1
           AND cs.playerdiscount > cs.discount
        
       -- For MyanmarOdds     
       --Update @Master: g3, m3
        -- For Myanmar Odds
        IF @IsMyanmarOdds = 1
        BEGIN
        
			UPDATE dbo.AgentCommRate WITH (UPDLOCK, ROWLOCK)
			   SET CommRate = @discountMyanmarOdds
			 WHERE custid = @custid AND bettype = 301 AND sporttype = 1 AND CommRate <> @discountMyanmarOdds

			--Update g2 = g3 if g2>g3 at agent
			UPDATE ac
			   SET ac.CommRate = @discountMyanmarOdds
			  FROM dbo.AgentCommRate ac WITH(UPDLOCK, ROWLOCK)
				JOIN dbo.CustInfo ci WITH(NOLOCK) ON ac.custid = ci.custid
			 WHERE ci.mrecommend = @custid
			   AND ci.roleid     = 2
			   AND ci.Enabled    = 1
			   AND ac.sporttype  = 1
			   AND ac.bettype    = 301
			   AND ac.CommRate   > @discountMyanmarOdds

			-- Update table CustCommRate
			IF EXISTS (SELECT 1 FROM CustInfo WITH (NOLOCK) WHERE mrecommend = @CustId AND roleid = 1)
			BEGIN
				UPDATE cs
					SET sdiscount = SuperComm.CommRate,
						adiscount = @discountMyanmarOdds,
						discount =  AgentComm.CommRate,
						playerdiscount = (CASE 
												WHEN cs.playerdiscount > AgentComm.CommRate THEN AgentComm.CommRate 
												ELSE cs.playerdiscount
										 END)	
										 
				 FROM dbo.CustCommRate cs WITH(UPDLOCK, ROWLOCK)
					JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.srecommend
								) AS SuperComm
								
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.recommend
								) AS AgentComm						
					
				 WHERE ci.mrecommend = @custid
					   AND ci.roleid = 1
					   AND ci.Enabled = 1
					   AND cs.Bettype = 301
					   AND cs.Sporttype = 1
			END
		END			   
           

    END
    IF @RoleId = 2
    BEGIN
        --Update @Agent: g2, a2
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
        SET
            groupa = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa ELSE groupa END,
            groupb = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupb ELSE groupb END,
            groupc = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupc ELSE groupc END,
            groupd = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupd ELSE groupd END,
            discount = CASE WHEN bettype IN (4,6,9,10,20,21,22,9999) AND sporttype <> 154 THEN @discountcs WHEN bettype =5 THEN @discount1x2 WHEN bettype = 20 and sporttype = 154 THEN @discountHRFixedOdds ELSE discount END
        WHERE custid=@custid
			AND custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
    
        --Update g2, a2 at Member level
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     custsetting.discount = CASE WHEN customer.ugroup IN ('a','hka','dea') THEN @groupa 
                                            WHEN customer.ugroup IN ('b','hkb','deb') THEN @groupb 
                                            WHEN customer.ugroup IN ('c','hkc','dec') THEN @groupc 
                                            WHEN customer.ugroup IN ('d','hkd','ded') THEN @groupd 
                                            ELSE @groupa 
                                        END  
        FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
        WHERE customer.recommend = @custid 
		   AND customer.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
		   AND customer.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
			AND customer.roleid = 1 
			AND bettype IN (1,2,3,7,8) 
    
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     custsetting.discount = @discountcs
        FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
        WHERE customer.recommend = @custid
            AND customer.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
            AND customer.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
            AND customer.roleid = 1 
            AND bettype IN (4,6,9,10,20,21,22,9999) and sporttype <> 154
    

        --1x2 
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     custsetting.discount = @discount1x2
        FROM custsetting INNER JOIN customer WITH (NOLOCK) ON custsetting.custid = customer.custid
        WHERE customer.recommend = @custid 
            AND customer.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
            AND customer.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
            AND customer.roleid = 1 
            AND bettype = 5
    
        --HRFixedOdds
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK) 
        SET     
            discount = @discountHRFixedOdds
        FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
        WHERE c.recommend = @custid 
            AND c.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
            AND c.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
            AND c.roleid = 1 
            AND bettype = 20 and sporttype = 154
    
        --At member level, update playerdiscount = discount  if playerdiscount > discount
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
        SET
            custsetting.playerdiscount = custsetting.discount 
        FROM custsetting INNER JOIN customer AS c WITH (NOLOCK) ON custsetting.custid = c.custid
        WHERE c.recommend = @custid 
            AND c.roleid = 1 
            AND custsetting.playerdiscount > custsetting.discount
        
        
        -- For MyanmarOdds
        IF @IsMyanmarOdds = 1
        BEGIN
        
			 --Update @Agent: g2, a2
            UPDATE dbo.AgentCommRate WITH (ROWLOCK, UPDLOCK)
            SET    CommRate = @discountMyanmarOdds
             WHERE custid = @custid AND bettype = 301 AND sporttype = 1 AND CommRate <> @discountMyanmarOdds
				AND custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
			
			-- Update table CustCommRate
			IF EXISTS (SELECT 1 FROM CustInfo WITH (NOLOCK) WHERE recommend = @CustId AND roleid = 1)
			BEGIN
				UPDATE cs
					SET sdiscount = SuperComm.CommRate,
						adiscount = MasterComm.CommRate,
						discount =  @discountMyanmarOdds,
						playerdiscount = (CASE 
												WHEN cs.playerdiscount > @discountMyanmarOdds THEN @discountMyanmarOdds 
												ELSE cs.playerdiscount
										 END)	
				 FROM dbo.CustCommRate cs WITH(UPDLOCK, ROWLOCK)
					JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.srecommend
								) AS SuperComm
								
					CROSS APPLY (SELECT ac.CommRate
								 FROM AgentCommRate AC WITH (NOLOCK)
								 WHERE CS.SportType = AC.SportType AND CS.BetType = AC.Bettype and ac.CustId = ci.mrecommend
								) AS MasterComm					
					
				 WHERE ci.recommend = @custid
					   AND ci.roleid = 1
					   AND ci.Enabled = 1
					   AND cs.Bettype = 301
					   AND cs.Sporttype = 1
				   
			END    
    
		END
    END
    
    IF @RoleId = 1
    BEGIN
        UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
        SET    
            playerdiscount = CASE WHEN bettype IN (1,2,3,7,8) THEN @groupa 
                                  WHEN bettype = 5 THEN @discount1x2  
                                  WHEN bettype IN (4,6,9,10,20,21,22,9999) and sporttype <> 154 THEN @discountcs 
                                  WHEN bettype = 20 and sporttype = 154 then @discountHRFixedOdds ELSE playerdiscount END  
        FROM custSetting 
        inner JOIN custInfo WITH(NOLOCK) ON custInfo.custid = custSetting.custid
        WHERE custInfo.custid=@custid             
            AND custInfo.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)
        
        --For MyanmarOdds
        IF @IsMyanmarOdds = 1
        BEGIN
			UPDATE cs
					SET playerdiscount = @discountMyanmarOdds	
			FROM dbo.CustCommRate cs WITH(UPDLOCK, ROWLOCK)
			WHERE cs.CustId = @CustId
				AND cs.SportType = 1
				AND cs.BetType = 301
        END
    END
END
