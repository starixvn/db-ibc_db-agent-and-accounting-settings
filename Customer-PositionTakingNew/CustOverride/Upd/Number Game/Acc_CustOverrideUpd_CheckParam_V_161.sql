CREATE PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_V_161]
	@custid int,
		
	@minv161positiontaking_81 smallmoney,
	@minv161positiontaking_83 smallmoney,
	--@minv161positiontaking_85 smallmoney,
	@minv161positiontaking_86 smallmoney,
	@minv161positiontaking_88 smallmoney,
	
	@minv161livepositiontaking_85 smallmoney,
	@minv161livepositiontaking_86 smallmoney,
	@minv161livepositiontaking_87 smallmoney,
	@minv161livepositiontaking_89 smallmoney,
	@minv161livepositiontaking_90 smallmoney,

	@maxv161positiontaking_81 smallmoney,
	@maxv161positiontaking_83 smallmoney,
	--@maxv161positiontaking_85 smallmoney,
	@maxv161positiontaking_86 smallmoney,
	@maxv161positiontaking_88 smallmoney,
	
	@maxv161livepositiontaking_85 smallmoney,
	@maxv161livepositiontaking_86 smallmoney,
	@maxv161livepositiontaking_87 smallmoney,
	@maxv161livepositiontaking_89 smallmoney,
	@maxv161livepositiontaking_90 smallmoney,

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
Task : Check parameters to update CustOverride for Number Game
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
	select @minv161positiontaking_81 = minpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 81
	select @minv161positiontaking_83 = minpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 83
	--select @minv161positiontaking_85 = minpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 85
	select @minv161positiontaking_86 = minpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 86
	select @minv161positiontaking_88 = minpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 88
	
	select @minv161livepositiontaking_85 = minlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 85
	select @minv161livepositiontaking_86 = minlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 86
	select @minv161livepositiontaking_87 = minlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 87
	select @minv161livepositiontaking_89 = minlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 89
	select @minv161livepositiontaking_90 = minlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 90
END

if @UpdateMaxPos = 0
BEGIN
	select @maxv161positiontaking_81 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 81
	select @maxv161positiontaking_83 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 83
	--select @maxv161positiontaking_85 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 85
	select @maxv161positiontaking_86 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 86
	select @maxv161positiontaking_88 = maxpositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 88
	
	select @maxv161livepositiontaking_85 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 85
	select @maxv161livepositiontaking_86 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 86
	select @maxv161livepositiontaking_87 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 87
	select @maxv161livepositiontaking_89 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 89
	select @maxv161livepositiontaking_90 = maxlivepositiontaking from custoverride3rd with (NOLOCK) where custid = @custid and sporttype=161 and bettype = 90
END

Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
	if 
		   @minv161positiontaking_81 <0 or @minv161positiontaking_81 >0.9
		or @minv161positiontaking_83 <0 or @minv161positiontaking_83 >0.9
		--or @minv161positiontaking_85 <0 or @minv161positiontaking_85 >0.9
		or @minv161positiontaking_86 <0 or @minv161positiontaking_86 >0.9
		or @minv161positiontaking_88 <0 or @minv161positiontaking_88 >0.9
		
		or @minv161livepositiontaking_85 <0 or @minv161livepositiontaking_85 >0.9
		or @minv161livepositiontaking_86 <0 or @minv161livepositiontaking_86 >0.9
		or @minv161livepositiontaking_87 <0 or @minv161livepositiontaking_87 >0.9
		or @minv161livepositiontaking_89 <0 or @minv161livepositiontaking_89 >0.9
		or @minv161livepositiontaking_90 <0 or @minv161livepositiontaking_90 >0.9   
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
		   @maxv161positiontaking_81 <0 or @maxv161positiontaking_81 >0.9
		or @maxv161positiontaking_83 <0 or @maxv161positiontaking_83 >0.9
		--or @maxv161positiontaking_85 <0 or @maxv161positiontaking_85 >0.9
		or @maxv161positiontaking_86 <0 or @maxv161positiontaking_86 >0.9
		or @maxv161positiontaking_88 <0 or @maxv161positiontaking_88 >0.9
		
		or @maxv161livepositiontaking_85 <0 or @maxv161livepositiontaking_85 >0.9
		or @maxv161livepositiontaking_86 <0 or @maxv161livepositiontaking_86 >0.9
		or @maxv161livepositiontaking_87 <0 or @maxv161livepositiontaking_87 >0.9
		or @maxv161livepositiontaking_89 <0 or @maxv161livepositiontaking_89 >0.9
		or @maxv161livepositiontaking_90 <0 or @maxv161livepositiontaking_90 >0.9   
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
	   @minv161positiontaking_81 > @maxv161positiontaking_81 
	or @minv161positiontaking_83 > @maxv161positiontaking_83 
	--or @minv161positiontaking_85 > @maxv161positiontaking_85 
	or @minv161positiontaking_86 > @maxv161positiontaking_86 
	or @minv161positiontaking_88 > @maxv161positiontaking_88 
	
	or @minv161livepositiontaking_85 > @maxv161livepositiontaking_85 
	or @minv161livepositiontaking_86 > @maxv161livepositiontaking_86 
	or @minv161livepositiontaking_87 > @maxv161livepositiontaking_87	 
	or @minv161livepositiontaking_89 > @maxv161livepositiontaking_89 
	or @minv161livepositiontaking_90 > @maxv161livepositiontaking_90
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_161] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_V_161] TO vnteam
GO

 