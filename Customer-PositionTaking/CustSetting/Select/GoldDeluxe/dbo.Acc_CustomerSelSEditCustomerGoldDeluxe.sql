ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerGoldDeluxe]
	@custid		INT
AS
/*
	Created: Elodie
	Date: 20150423
	Task: Super edits Gold Deluxe settings on member
	DB: BDAGE/BODB02
		
	Revisions:
		
	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE 	
		@v255spositiontaking_1701		SMALLMONEY,--s4
		@v255spositiontaking_1701_min	SMALLMONEY,--n4
		@v255mpositiontaking_1701		SMALLMONEY,--m3
		@isauto_v255spositiontaking_1701 BIT,--i3
		@srecommend INT, 
		@mrecommend	INT

	SELECT @srecommend = srecommend, @mrecommend = mrecommend 
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid

	--s4
	SELECT @v255spositiontaking_1701 = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 255 AND bettype = 1701

	--n4
	SELECT @v255spositiontaking_1701_min = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)	
	WHERE custid = @srecommend AND sporttype = 255 AND bettype = 1701

	--i3,m3
	SELECT @v255mpositiontaking_1701 = mpositiontaking, @isauto_v255spositiontaking_1701 = isautopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 255 AND bettype = 1701 

	SELECT	spositiontaking as v255spositiontaking_1701,
			mpositiontaking as v255mpositiontaking_1701,
			apositiontaking as v255apositiontaking_1701,
			autopositiontaking as auto_v255spositiontaking_1701_mem,	
			isautopositiontaking as isauto_v255spositiontaking_1701_mem,
			ISNULL(@isauto_v255spositiontaking_1701,0) as isauto_v255spositiontaking_1701, -- i3
			ISNULL(@v255spositiontaking_1701,0) as auto_v255spositiontaking_1701_max,
			--s1_max= s4- m3
			ISNULL(@v255spositiontaking_1701,0) - ISNULL(@v255mpositiontaking_1701,0) as v255spositiontaking_1701_max,
			-- s1_min 
			CASE WHEN ISNULL(@v255spositiontaking_1701_min,0) - (mpositiontaking + apositiontaking) > 0 THEN ISNULL(@v255spositiontaking_1701_min,0) - (mpositiontaking + apositiontaking) ELSE 0 END v255spositiontaking_1701_min	
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 255 AND bettype = 1701
END

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSEditCustomerGoldDeluxe] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerGoldDeluxe] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerGoldDeluxe] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerGoldDeluxe] TO [bodbDownlineNetView]