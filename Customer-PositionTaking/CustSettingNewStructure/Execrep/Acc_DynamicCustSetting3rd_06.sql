
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_DynamicCustSetting3rd_06    Script Date: 12/9/2015 12:57:52 PM ******/
CREATE PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_06]
    @CustId int,
    @RoleId int,
	@Discount_XML VARCHAR(MAX) = NULL
AS
/*
    Created: 20151007@Dominic
    Task : Update commission 
    DB: DBCust/CustDB
    Revision:
		- 20151203@Dominic: Fix bug when correcting discount setting on downline members  Bug #48652, #48671      
*/
BEGIN
    SET NOCOUNT ON;
    -- check existing tables

    IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN


	DECLARE @NewDiscountTbl TABLE(
		SportType SMALLINT,
		BetType SMALLINT,
		Discount Decimal(9,8)
	)
	
	IF @Discount_XML IS NULL OR @Discount_XML='' RETURN

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
	UNION SELECT	19980168	,	1	-- 55HK
	UNION SELECT	20044385	,	1	-- 169RMB
	
	--20151222Johnson: hardcode for 55HK and 169RMB
	UNION SELECT	19980168	,	1	-- 55HK
	UNION SELECT	20044385	,	1	-- 169RMB
 
	--UUS accounnts for testing
	UNION SELECT	14180041	,	2	--	supertestUAT0101
	UNION SELECT	14228743	,	1	--	SUPERTEST20000000
	UNION SELECT	14497432	,	1	--	SUPERTEST20000001
	--End customer list------------------------------------------
	
	
	--Parse XML	
	DECLARE @iDoc INT
	DECLARE @SuperDiscount DECIMAL(9,8),
			@MasterDiscount DECIMAL(9,8),
			@AgentDiscount DECIMAL(9,8),
			@PlayerDiscount DECIMAL(9,8)
	
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
		INNER JOIN @NewDiscountTbl fil ON dcm.sporttype = fil.sporttype AND dcm.bettype = fil.bettype
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
		INNER JOIN @NewDiscountTbl fil ON dca.sporttype = fil.sporttype AND dca.bettype = fil.bettype
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
			@SuperDiscount = dcs.Discount,
			@MasterDiscount = dcmem.MasterDiscount,
			@AgentDiscount = dcmem.AgentDiscount,
			@PlayerDiscount = dcmem.PlayerDiscount,			
			@MasterDiscount= CASE WHEN @MasterDiscount < @SuperDiscount THEN @MasterDiscount ELSE @SuperDiscount END,
			@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.srecommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
											AND dcs.bettype = dcmem.bettype
											AND dcs.custid=@CustID
		WHERE ci.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
			 AND ci.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)											
											
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
		INNER JOIN @NewDiscountTbl fil ON dca.sporttype = fil.sporttype AND dca.bettype = fil.bettype
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
			@MasterDiscount = dcm.Discount,
			@AgentDiscount = dcmem.AgentDiscount,
			@PlayerDiscount = dcmem.PlayerDiscount,	
			@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.mrecommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
											AND dcm.bettype = dcmem.bettype
											AND dcm.custid=@CustID
		WHERE ci.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
           AND ci.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)											
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
			AND custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)

		--downline_member_discount = @NEW_DISCOUNT
		--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)
		UPDATE dcmem
		SET
			@AgentDiscount = dca.Discount,
			@PlayerDiscount = dcmem.PlayerDiscount,	
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.recommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype
											AND dca.bettype = dcmem.bettype
											AND dca.custid=@CustID

		WHERE ci.recommend NOT IN (SELECT custid FROM @tblCustList WHERE roleid =2)
			 AND ci.custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)												
	END
	ELSE IF @RoleID=1
	BEGIN
		UPDATE main  
		SET main.PlayerDiscount = tmp.Discount
		FROM dbo.CustDiscount3rd_Member main WITH(ROWLOCK, UPDLOCK)  
		JOIN @NewDiscountTbl tmp   
		ON tmp.SportType=main.SportType  
			AND tmp.BetType=main.BetType 
		WHERE main.CustID=@CustID  
			AND custid NOT IN (SELECT custid FROM @tblCustList WHERE roleid =1)    
	END
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustSetting3rd_06] TO [vnteam]
GO 
