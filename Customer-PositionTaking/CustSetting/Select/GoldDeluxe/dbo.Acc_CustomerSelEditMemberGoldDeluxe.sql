ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberGoldDeluxe]
	@custid		INT,
	@recommend	INT
AS
/*
	Created: 20150423@Elodie
	Task: Agent edits member's Gold Deluxe setting
	DB: DBAGE/BODB02
	
	Revisions:
	
	Parameters Explanation
*/
BEGIN

	SET NOCOUNT ON
		
		DECLARE @roleID INT 

		-- Check Downline Belonging
	EXEC dbo.Age_CustomerSelCheckBelonging  
			@SessionCustID	= @recommend, 
			@Custid			= @CustID,
			@roleID			= @roleID OUTPUT

	IF @roleID = 0
		RETURN

	DECLARE @srecommend INT,
			@mrecommend INT,
			@max_V255apositiontaking_1701	SMALLMONEY,
			@min_v255apositiontaking_1701	SMALLMONEY,
			@v255discount_1701				DECIMAL(9,8),
			
			@v255spt_1701		SMALLMONEY,
			@cs_v255apt_1701	SMALLMONEY
			
	SELECT @srecommend = srecommend , @mrecommend = mrecommend 
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	--
	SELECT	@max_V255apositiontaking_1701 = apositiontaking,
			@v255discount_1701 = discount
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701

	SELECT @min_v255apositiontaking_1701 = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701
	
	--s4
	SELECT @v255spt_1701 = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 255 AND bettype = 1701

	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	SELECT @cs_v255apt_1701 = CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
									ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
												ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= @v255spt_1701-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v255spt_1701-cs.spositiontaking-cs.mpositiontaking END
											END
										 END 
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = 255 AND cs.bettype = 1701
	
	SELECT @max_v255apositiontaking_1701 = CASE WHEN @max_v255apositiontaking_1701 <= @cs_v255apt_1701 THEN @max_v255apositiontaking_1701 ELSE @cs_v255apt_1701 END
		
	SELECT		
		apositiontaking AS v255apositiontaking_1701,
		@max_V255apositiontaking_1701 AS v255apositiontaking_1701_max,
		@min_v255apositiontaking_1701 AS v255apositiontaking_1701_min,

		playerdiscount	AS v255playerdiscount_1701,
		@v255discount_1701 AS v255playerdiscount_1701_max
	FROM CustsettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 255 AND bettype = 1701
END
/*
exec [dbo].[Acc_CustomerSelEditMemberGoldDeluxe] @custid = 642719,@recommend = 642706
*/

GO
GRANT VIEW DEFINITION ON [Acc_CustomerSelEditMemberGoldDeluxe] TO vnteam
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberGoldDeluxe] TO bodbAdminNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberGoldDeluxe] TO bodbDownlineNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberGoldDeluxe] TO bodbDownlineNetView
