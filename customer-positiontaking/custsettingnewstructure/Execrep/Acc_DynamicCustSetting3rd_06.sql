ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_06]
    @CustId int,
    @RoleId int,
    @mode varchar(30),
	@Discount_XML VARCHAR(MAX) = NULL
AS
/*
    Created: 20151007@Dominic
    Task : Update commission 
    DB: DBCust/CustDB
            
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

	--Parse XML	
	DECLARE @iDoc INT
	
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
	   UPDATE main  
	   SET main.PlayerDiscount = tmp.Discount
	   FROM dbo.CustDiscount3rd_Member main WITH(ROWLOCK, UPDLOCK)  
	   JOIN @NewDiscountTbl tmp   
		ON tmp.SportType=main.SportType  
		 AND tmp.BetType=main.BetType 
	   WHERE main.CustID=@CustID  
	END
    
END


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
