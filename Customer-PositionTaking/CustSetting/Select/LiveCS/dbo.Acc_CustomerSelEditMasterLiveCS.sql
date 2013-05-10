 ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterLiveCS]
	@custid INT,
	@srecommend INT
AS
	/*
		Created: Johnson
		Date: 23Dec2011
		Task: Super edits master's live casino setting
		DB: DB053.BODB02
		
		Revisions:
		
		Parameters Explanation
	*/
SET NOCOUNT ON
	
DECLARE	@min_mpositiontaking	SMALLMONEY,
		@max_spositiontaking	SMALLMONEY,
		@max_adiscount			SMALLMONEY,
		@DisableAutoMPT			BIT
		
--Disable auto master PT
SELECT @DisableAutoMPT = DisableAutoMPT 
FROM CustMaster (nolock) 
WHERE CustID = @custid
		

SELECT @min_mpositiontaking = minpositiontaking
FROM CustOverrideGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

SELECT @max_spositiontaking = spositiontaking, @max_adiscount = sdiscount
FROM CustSettingGame cs WITH(NOLOCK)
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101


SELECT ISNULL(@DisableAutoMPT,0) as DisableAutoMPT, 
	isautopositiontaking as isauto_v162spositiontaking_1101, --i3
	autopositiontaking as auto_v162spostiontaking_1101,--u3
	spositiontaking as v162spositiontaking_1101,--s3
	mpositiontaking as v162mpositiontaking_1101,--m3	
	adiscount as v162discount_1101,--g3
	ISNULL(@max_adiscount,0) as v162discount_1101_max,--g3_max
	ISNULL(@max_spositiontaking,0) as v162spositiontaking_1101_max,--s4
	ISNULL(@min_mpositiontaking,0) as  v162mpositiontaking_1101_min,--n3	
	ISNULL(@max_spositiontaking,0) as auto_v162spositiontaking_1101_max--u3_max	
FROM CustsettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbDownlineNetView]
