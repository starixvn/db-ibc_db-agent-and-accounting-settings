CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_V_11]
	@custid int,
		
	@minv11positiontaking_1 smallmoney,
	@minv11positiontaking_20 smallmoney,

	@maxv11positiontaking_1 smallmoney,
	@maxv11positiontaking_20 smallmoney,

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
Task : Check parameters to update CustOverride for Motor Sports
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
	select @minv11positiontaking_1 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 1
	select @minv11positiontaking_20 = minpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 20
END

if @UpdateMaxPos = 0
BEGIN
	select @maxv11positiontaking_1 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 1
	select @maxv11positiontaking_20 = maxpositiontaking from custoverride with (NOLOCK) where custid = @custid and sporttype=11 and bettype = 20
END

Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
	if 
		   @minv11positiontaking_1 <0 or @minv11positiontaking_1 >0.9
		or @minv11positiontaking_20 <0 or @minv11positiontaking_20 >0.9   
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
		   @maxv11positiontaking_1 <0 or @maxv11positiontaking_1 >0.9
		or @maxv11positiontaking_20 <0 or @maxv11positiontaking_20 >0.9   
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
	   @minv11positiontaking_1 > @maxv11positiontaking_1
	or @minv11positiontaking_20 > @maxv11positiontaking_20
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_11] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_11] TO vnteam
GO

 