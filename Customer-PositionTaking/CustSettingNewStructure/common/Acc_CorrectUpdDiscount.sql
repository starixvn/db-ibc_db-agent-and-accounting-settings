SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CorrectUpdDiscount]
	@CustID INT,
	@RoleID INT,
	@ProductID TINYINT
AS
	/*
	Created: 20141110@Dominic
	Task : Correct discount
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Corrected Downline 's ID

	*/
BEGIN
	IF @RoleID=4
	BEGIN
		UPDATE dcm
		SET
			dcm.discounta=CASE WHEN dcs.discounta < dcm.discounta THEN dcs.discounta ELSE dcm.discounta  END
		FROM dbo.CustDiscount3rd_Agent dcm WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcm.custid = ci.custid
                                           AND ci.srecommend = @CustID
                                           AND ci.roleid = 3
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dcm.sporttype
											AND dtl.BetType=dcm.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcm.sporttype
											AND dcs.bettype = dcm.bettype
											AND dcs.custid=@CustID
											
		UPDATE dca
		SET
			dca.discounta=CASE WHEN dcs.discounta < dca.discounta THEN dcs.discounta ELSE dca.discounta  END
		FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
                                           AND ci.srecommend = @CustID
                                           AND ci.roleid = 2
                                           AND ci.Enabled=1
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dca.sporttype
											AND dtl.BetType=dca.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dca.sporttype
											AND dcs.bettype = dca.bettype
											AND dcs.custid=@CustID
											
		UPDATE dcmem
		SET
			dcmem.sdiscount=dcs.discounta,
			dcmem.adiscount= CASE WHEN dcmem.adiscount < dcmem.sdiscount THEN dcmem.adiscount ELSE dcmem.sdiscount END,
			dcmem.discount= CASE WHEN dcmem.discount < dcmem.adiscount THEN dcmem.discount ELSE dcmem.adiscount END,
			dcmem.playerdiscount= CASE WHEN dcmem.playerdiscount < dcmem.discount THEN dcmem.playerdiscount ELSE dcmem.discount END
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
                                           AND ci.srecommend = @CustID
                                           AND ci.roleid = 1
                                           AND ci.Enabled=1
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dcmem.sporttype
											AND dtl.BetType=dcmem.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
											AND dcs.bettype = dcmem.bettype
											AND dcs.custid=@CustID
											
	END
	ELSE IF @RoleID=3
	BEGIN
		UPDATE dca
		SET
			dca.discounta=CASE WHEN dcm.discounta < dca.discounta THEN dcm.discounta ELSE dca.discounta  END
		FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
                                           AND ci.mrecommend = @CustID
                                           AND ci.roleid = 2
                                           AND ci.Enabled=1
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dca.sporttype
											AND dtl.BetType=dca.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dca.sporttype
											AND dcm.bettype = dca.bettype
											AND dcm.custid=@CustID
											
		UPDATE dcmem
		SET
			dcmem.adiscount= dcm.discounta,
			dcmem.discount= CASE WHEN dcmem.discount < dcmem.adiscount THEN dcmem.discount ELSE dcmem.adiscount END,
			dcmem.playerdiscount= CASE WHEN dcmem.playerdiscount < dcmem.discount THEN dcmem.playerdiscount ELSE dcmem.discount END
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
                                           AND ci.mrecommend = @CustID
                                           AND ci.roleid = 1
                                           AND ci.Enabled=1
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dcmem.sporttype
											AND dtl.BetType=dcmem.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
											AND dcm.bettype = dcmem.bettype
											AND dcm.custid=@CustID
	END
	ELSE IF @RoleID=2
	BEGIN
		UPDATE dcmem
		SET
			dcmem.discount= dca.discounta,
			dcmem.playerdiscount= CASE WHEN dcmem.playerdiscount < dcmem.discount THEN dcmem.playerdiscount ELSE dcmem.discount END
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
                                           AND ci.recommend = @CustID
                                           AND ci.roleid = 1
                                           AND ci.Enabled=1
        INNER JOIN dbo.ProductSettingDetail dtl ON dtl.SportType=dcmem.sporttype
											AND dtl.BetType=dcmem.bettype
											AND dtl.SettingType=3
											AND dtl.IsLive=0
											AND dtl.ProductID=@ProductID
        INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype
											AND dca.bettype = dcmem.bettype
											AND dca.custid=@CustID
	END
END