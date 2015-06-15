USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_3rdProductSelSuperStatus]    Script Date: 3/16/2015 4:51:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
ALTER PROCEDURE	[dbo].[Acc_3rdProductSelSuperStatus]
	@ProductID			INT,
	@CustID				INT,
	@SupperStatus		BIT=0 OUTPUT,
	@DownlineStatus		BIT=0 OUTPUT
AS
/*
	Created: 20150313@Winne
	Task: select 3rd product status of super ( 12 GoldDeluxe)
	DB: DBCUST/CustDB
	Original:
	Revisions:
	-- 20150612@Winnie: Add Microgaming
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	IF @ProductID=14 -- Microgaming
	BEGIN
	DECLARE @RoleId INT
	SELECT @SupperStatus=~DisableMicrogame,@RoleId=RoleId FROM CustInfo  WITH (NOLOCK) WHERE CustID = @CustID 
	CREATE TABLE #CustList14 ( CustID INT)	
		IF @RoleId=4	
		BEGIN
		INSERT INTO #CustList14 (CustID)
		SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
		INNER JOIN Customer ag WITH (NOLOCK) ON rm.recommend=ag.Custid
		WHERE rm.srecommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'	
		END
		ELSE IF @RoleId=3
		BEGIN
		INSERT INTO #CustList14 (CustID)
		SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
		INNER JOIN Customer ag WITH (NOLOCK) ON rm.recommend=ag.Custid
		WHERE rm.mrecommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'
		END
		ELSE
		BEGIN
		INSERT INTO #CustList14 (CustID)
		SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
		INNER JOIN Customer ag WITH (NOLOCK) ON rm.recommend=ag.Custid
		WHERE rm.recommend = @CustID AND ag.Username not like '%'+ag.site +'ACC%'
		END

		IF EXISTS(SELECT TOP 1 1 FROM CustInfo a WITH (NOLOCK) INNER JOIN #CustList14 b ON a.CustID=b.CustID 
				WHERE a.DisableMicrogame=1)	
		SELECT @DownlineStatus=0
		ELSE
		SELECT @DownlineStatus=1
	RETURN
	END
	---
	SELECT @SupperStatus=IsEnabled FROM Dep_SupperProductSetting  WITH (NOLOCK) WHERE CustID = @CustID AND ProductId=@ProductId	

	CREATE TABLE #CustList ( CustID INT)		
		INSERT INTO #CustList (CustID)
		SELECT rm.CustID FROM Customer rm WITH (NOLOCK) 
		INNER JOIN Customer ag WITH (NOLOCK) ON rm.recommend=ag.Custid
		WHERE rm.srecommend = @CustID AND rm.roleid = 1 AND ag.Username not like '%'+ag.site +'ACC%'

	IF EXISTS(SELECT TOP 1 1 FROM Dep_CustProductSetting a WITH (NOLOCK) INNER JOIN #CustList b ON a.CustID=b.CustID 
				WHERE a.ProductId=@ProductId  AND a.IsEnabled=1)
	
	SELECT @DownlineStatus=1
	ELSE
	SELECT @DownlineStatus=0

	
END
GO
GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_3rdProductSelSuperStatus] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_3rdProductSelSuperStatus] TO [vnteam] AS [dbo]


