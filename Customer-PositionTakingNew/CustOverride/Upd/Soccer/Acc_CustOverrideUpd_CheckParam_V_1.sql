ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_V_1]
	@custid int,

	@minpositiontaking_1 smallmoney,
	@minpositiontaking_2 smallmoney,
	@minpositiontaking_3 smallmoney,
	@minpositiontaking_4 smallmoney,
	@minpositiontaking_5 smallmoney,
	@minpositiontaking_6 smallmoney,
	@minpositiontaking_7 smallmoney,
	@minpositiontaking_8 smallmoney,
	@minpositiontaking_9 smallmoney,
	@minpositiontaking_10 smallmoney,

	@minlivepositiontaking_1 smallmoney,
	@minlivepositiontaking_3 smallmoney,
	@minlivepositiontaking_7 smallmoney,
	@minlivepositiontaking_8 smallmoney,
	
	@maxpositiontaking_1 smallmoney,
	@maxpositiontaking_2 smallmoney,
	@maxpositiontaking_3 smallmoney,
	@maxpositiontaking_4 smallmoney,
	@maxpositiontaking_5 smallmoney,
	@maxpositiontaking_6 smallmoney,
	@maxpositiontaking_7 smallmoney,
	@maxpositiontaking_8 smallmoney,
	@maxpositiontaking_9 smallmoney,
	@maxpositiontaking_10 smallmoney,
	
	@maxlivepositiontaking_1 smallmoney,
	@maxlivepositiontaking_3 smallmoney,
	@maxlivepositiontaking_7 smallmoney,
	@maxlivepositiontaking_8 smallmoney,
	
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
Task : Check parameters to update CustOverride for Soccer
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
	select @minpositiontaking_1 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @minpositiontaking_2 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 2
	select @minpositiontaking_3 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @minpositiontaking_4 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 4
	select @minpositiontaking_5 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 5
	select @minpositiontaking_6 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 6
	select @minpositiontaking_7 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @minpositiontaking_8 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
	select @minpositiontaking_9 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 9
	select @minpositiontaking_10 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 10
	
	select @minlivepositiontaking_1 = minlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @minlivepositiontaking_3 = minlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @minlivepositiontaking_7 = minlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @minlivepositiontaking_8 = minlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
END

if @UpdateMaxPos = 0
BEGIN
	select @maxpositiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @maxpositiontaking_2 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 2
	select @maxpositiontaking_3 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @maxpositiontaking_4 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 4
	select @maxpositiontaking_5 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 5
	select @maxpositiontaking_6 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 6
	select @maxpositiontaking_7 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @maxpositiontaking_8 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
	select @maxpositiontaking_9 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 9
	select @maxpositiontaking_10 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 10
	
	select @maxlivepositiontaking_1 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 1
	select @maxlivepositiontaking_3 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 3
	select @maxlivepositiontaking_7 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 7
	select @maxlivepositiontaking_8 = maxlivepositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype = 1 and bettype = 8
END

Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
	if 
		   @minpositiontaking_1 <0 or @minpositiontaking_1 >0.9
		or @minpositiontaking_2 <0 or @minpositiontaking_2 >0.9
		or @minpositiontaking_3 <0 or @minpositiontaking_3 >0.9
		or @minpositiontaking_4 <0 or @minpositiontaking_4 >0.9
		or @minpositiontaking_5 <0 or @minpositiontaking_5 >0.9
		or @minpositiontaking_6 <0 or @minpositiontaking_6 >0.9
		or @minpositiontaking_7 <0 or @minpositiontaking_7 >0.9
		or @minpositiontaking_8 <0 or @minpositiontaking_8 >0.9
		or @minpositiontaking_9 <0 or @minpositiontaking_9 >0.9
		or @minpositiontaking_10 <0 or @minpositiontaking_10 >0.9

		or @minlivepositiontaking_1 <0 or @minlivepositiontaking_1 >0.9
		or @minlivepositiontaking_3 <0 or @minlivepositiontaking_3 >0.9
		or @minlivepositiontaking_7 <0 or @minlivepositiontaking_7 >0.9
		or @minlivepositiontaking_8 <0 or @minlivepositiontaking_8 >0.9
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
		   @maxpositiontaking_1 <0 or @maxpositiontaking_1 >0.9
		or @maxpositiontaking_2 <0 or @maxpositiontaking_2 >0.9
		or @maxpositiontaking_3 <0 or @maxpositiontaking_3 >0.9
		or @maxpositiontaking_4 <0 or @maxpositiontaking_4 >0.9
		or @maxpositiontaking_5 <0 or @maxpositiontaking_5 >0.9
		or @maxpositiontaking_6 <0 or @maxpositiontaking_6 >0.9
		or @maxpositiontaking_7 <0 or @maxpositiontaking_7 >0.9
		or @maxpositiontaking_8 <0 or @maxpositiontaking_8 >0.9
		or @maxpositiontaking_9 <0 or @maxpositiontaking_9 >0.9
		or @maxpositiontaking_10 <0 or @maxpositiontaking_10 >0.9
		
		or @maxlivepositiontaking_1 <0 or @maxlivepositiontaking_1 >0.9
		or @maxlivepositiontaking_3 <0 or @maxlivepositiontaking_3 >0.9
		or @maxlivepositiontaking_7 <0 or @maxlivepositiontaking_7 >0.9
		or @maxlivepositiontaking_8 <0 or @maxlivepositiontaking_8 >0.9
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
	   @minpositiontaking_1 > @maxpositiontaking_1
	or @minpositiontaking_2 > @maxpositiontaking_2
	or @minpositiontaking_3 > @maxpositiontaking_3
	or @minpositiontaking_4 > @maxpositiontaking_4
	or @minpositiontaking_5 > @maxpositiontaking_5
	or @minpositiontaking_6 > @maxpositiontaking_6
	or @minpositiontaking_7 > @maxpositiontaking_7
	or @minpositiontaking_8 > @maxpositiontaking_8
	or @minpositiontaking_9 > @maxpositiontaking_9
	or @minpositiontaking_10 > @maxpositiontaking_10

	or @minlivepositiontaking_1 > @maxlivepositiontaking_1
	or @minlivepositiontaking_3 > @maxlivepositiontaking_3
	or @minlivepositiontaking_7 > @maxlivepositiontaking_7
	or @minlivepositiontaking_8 > @maxlivepositiontaking_8
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_1] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_1] TO vnteam
GO

