CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_V_2]
	@custid int,
		
	@minv2positiontaking_1 smallmoney,
	@minv2positiontaking_2 smallmoney,
	@minv2positiontaking_3 smallmoney,
	@minv2positiontaking_7 smallmoney,
	@minv2positiontaking_8 smallmoney,
	--@minv2positiontaking_9 smallmoney,
	@minv2positiontaking_20 smallmoney,

	@maxv2positiontaking_1 smallmoney,
	@maxv2positiontaking_2 smallmoney,
	@maxv2positiontaking_3 smallmoney,
	@maxv2positiontaking_7 smallmoney,
	@maxv2positiontaking_8 smallmoney,
	--@maxv2positiontaking_9 smallmoney,
	@maxv2positiontaking_20 smallmoney,

	@UpdateMinPos bit = 1,
	@UpdateMaxPos bit = 1,
	@roleid int, 
	@srecommend int, 
	@mrecommend int, 
	@recommend int,
	@isvalid bit OUTPUT,
	@errmsg nvarchar(4000) OUTPUT,
	@errcode int OUTPUT,
	@language varchar(2) = 'E'
AS
/*
Created: 20120508@Elodie
Task : Check parameters to update CustOverride for Basketball
DB: DBTRANS.bodb02
Original: Acc_CustOverrideUpd_CheckParam_V
	
Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: check parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
if @UpdateMinPos = 0
BEGIN
	select @minv2positiontaking_1 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 1
	select @minv2positiontaking_2 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 2
	select @minv2positiontaking_3 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 3
	select @minv2positiontaking_7 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 7
	select @minv2positiontaking_8 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 8
	--select @minv2positiontaking_9 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 9
	select @minv2positiontaking_20 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 20
END

if @UpdateMaxPos = 0
BEGIN
	select @maxv2positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 1
	select @maxv2positiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 2
	select @maxv2positiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 3
	select @maxv2positiontaking_7 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 7
	select @maxv2positiontaking_8 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 8
	--select @maxv2positiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 9
	select @maxv2positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 2 and bettype = 20
END

Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
	if 
		   @minv2positiontaking_1 <0 or @minv2positiontaking_1 >0.9
		or @minv2positiontaking_2 <0 or @minv2positiontaking_2 >0.9
		or @minv2positiontaking_3 <0 or @minv2positiontaking_3 >0.9
		or @minv2positiontaking_7 <0 or @minv2positiontaking_7 >0.9
		or @minv2positiontaking_8 <0 or @minv2positiontaking_8 >0.9
		--or @minv2positiontaking_9 <0 or @minv2positiontaking_9 >0.9
		or @minv2positiontaking_20 <0 or @minv2positiontaking_20 >0.9
	BEGIN
		select @isvalid = 0, @ErrCode = 1
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong min position taking.'
							when 'CS' then N'最低占成数不正确.'
							when 'CT' then N'最低佔成數不正確.'
							when 'TH' then N'การกำหนดจำนวนเงินต่ำสุดไม่ถูกต้อง.'
							when 'J' then N'Wrong min position taking.'
							else N'Wrong min position taking.'
					end
		return
	END
END

if @UpdateMaxPos=1
BEGIN
	if 
		   @maxv2positiontaking_1 <0 or @maxv2positiontaking_1 >0.9
		or @maxv2positiontaking_2 <0 or @maxv2positiontaking_2 >0.9
		or @maxv2positiontaking_3 <0 or @maxv2positiontaking_3 >0.9
		or @maxv2positiontaking_7 <0 or @maxv2positiontaking_7 >0.9
		or @maxv2positiontaking_8 <0 or @maxv2positiontaking_8 >0.9
		--or @maxv2positiontaking_9 <0 or @maxv2positiontaking_9 >0.9
		or @maxv2positiontaking_20 <0 or @maxv2positiontaking_20 >0.9
	BEGIN
		select @isvalid = 0, @ErrCode = 2
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong max position taking.'
							when 'CS' then N'占成数不正确.'
							when 'CT' then N'佔成數不正確.'
							when 'TH' then N'การกำหนดจำนวนเงินต่ำสุดไม่ถูกต้อง.'
							when 'J' then N'Wrong max position taking.'
							else N'Wrong max position taking.'
					end
		return
	END
END

if 
	   @minv2positiontaking_1 > @maxv2positiontaking_1
	or @minv2positiontaking_2 > @maxv2positiontaking_2
	or @minv2positiontaking_3 > @maxv2positiontaking_3
	or @minv2positiontaking_7 > @maxv2positiontaking_7
	or @minv2positiontaking_8 > @maxv2positiontaking_8
	--or @minv2positiontaking_9 > @maxv2positiontaking_9
	or @minv2positiontaking_20 > @maxv2positiontaking_20
	BEGIN
		select @isvalid = 0, @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong min/max position taking.'
							when 'CS' then N'占成数不正确.'
							when 'CT' then N'佔成數不正確.'
							when 'TH' then N'การกำหนดจำนวนเงินต่ำสุดไม่ถูกต้อง.'
							when 'J' then N'Wrong min/max position taking.'
							else N'Wrong min/max position taking.'
					end
		return
	END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_2] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_2] TO vnteam
GO

 