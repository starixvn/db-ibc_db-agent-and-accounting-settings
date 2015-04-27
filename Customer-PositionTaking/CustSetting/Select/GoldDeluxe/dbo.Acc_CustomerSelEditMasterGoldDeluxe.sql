ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterGoldDeluxe]
	@custid INT,
	@srecommend INT
AS
	/*
		Created: Kathy
		Date: 20150424
		Task: Super edits master's live casino setting
		DB: DBAGE.BODB02
		
		Revisions:
		
		Parameters Explanation
	*/
BEGIN
	SET NOCOUNT ON
		
	DECLARE	@min_mpositiontaking	SMALLMONEY,
			@max_spositiontaking	SMALLMONEY,
			@max_adiscount			SMALLMONEY,
			@DisableAutoMPT			BIT
			
	--Disable auto master PT
	SELECT	@DisableAutoMPT = DisableAutoMPT 
	FROM	CustMaster WITH(NOLOCK) 
	WHERE	CustID = @custid
			

	SELECT	@min_mpositiontaking = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

	SELECT	@max_spositiontaking = spositiontaking
			,@max_adiscount = sdiscount
	FROM	CustSettingGame cs WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 255 
			AND bettype = 1701


	SELECT	ISNULL(@DisableAutoMPT,0)		AS DisableAutoMPT, 
			isautopositiontaking			AS isauto_v255spositiontaking_1701, --i3
			autopositiontaking				AS auto_v255spostiontaking_1701,--u3
			spositiontaking					AS v255spositiontaking_1701,--s3
			mpositiontaking					AS v255mpositiontaking_1701,--m3	
			adiscount						AS v255discount_1701,--g3
			ISNULL(@max_adiscount,0)		AS v255discount_1701_max,--g3_max
			ISNULL(@max_spositiontaking,0)	AS v255spositiontaking_1701_max,--s4
			ISNULL(@min_mpositiontaking,0)	AS  v255mpositiontaking_1701_min,--n3	
			ISNULL(@max_spositiontaking,0)	AS auto_v255spositiontaking_1701_max--u3_max	
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

END

GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerSelEditMasterGoldDeluxe TO [vnteam]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelEditMasterGoldDeluxe TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelEditMasterGoldDeluxe TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelEditMasterGoldDeluxe TO [bodbDownlineNetView]
