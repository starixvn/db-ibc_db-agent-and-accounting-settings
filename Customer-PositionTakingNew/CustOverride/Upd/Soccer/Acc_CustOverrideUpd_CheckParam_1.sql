ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_1]
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
Created: 20120510@Elodie
Task : Check parameters to update CustOverride for Soccer
DB: DBTRANS.bodb02
Original: Acc_CustOverrideUpd_CheckParam

Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: check parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
--check values
Select @ErrCode = 0
EXEC dbo.Acc_CustOverrideUpd_CheckParam_V_1
			@custid = @custid,
			@minpositiontaking_1 = @minpositiontaking_1,
			@minpositiontaking_2 = @minpositiontaking_2,
			@minpositiontaking_3 = @minpositiontaking_3,
			@minpositiontaking_4 = @minpositiontaking_4,
			@minpositiontaking_5 = @minpositiontaking_5,
			@minpositiontaking_6 = @minpositiontaking_6,
			@minpositiontaking_7 = @minpositiontaking_7,
			@minpositiontaking_8 = @minpositiontaking_8,
			@minpositiontaking_9 = @minpositiontaking_9,
			@minpositiontaking_10 = @minpositiontaking_10,

			@minlivepositiontaking_1 = @minlivepositiontaking_1,
			@minlivepositiontaking_3 = @minlivepositiontaking_3,
			@minlivepositiontaking_7 = @minlivepositiontaking_7,
			@minlivepositiontaking_8 = @minlivepositiontaking_8,			
			
			@maxpositiontaking_1 = @maxpositiontaking_1,
			@maxpositiontaking_2 = @maxpositiontaking_2,
			@maxpositiontaking_3 = @maxpositiontaking_3,
			@maxpositiontaking_4 = @maxpositiontaking_4,
			@maxpositiontaking_5 = @maxpositiontaking_5,
			@maxpositiontaking_6 = @maxpositiontaking_6,
			@maxpositiontaking_7 = @maxpositiontaking_7,
			@maxpositiontaking_8 = @maxpositiontaking_8,
			@maxpositiontaking_9 = @maxpositiontaking_9,
			@maxpositiontaking_10 = @maxpositiontaking_10,

			@maxlivepositiontaking_1 = @maxlivepositiontaking_1,
			@maxlivepositiontaking_3 = @maxlivepositiontaking_3,
			@maxlivepositiontaking_7 = @maxlivepositiontaking_7,
			@maxlivepositiontaking_8 = @maxlivepositiontaking_8,
			
			@UpdateMinPos = @UpdateMinPos,
			@UpdateMaxPos = @UpdateMaxPos,
			@roleid = @roleid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language
if @ErrCode <> 0
BEGIN
	return
END

if @roleid=4
BEGIN 
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_SAg_1
			@custid = @custid,
			@minpositiontaking_1 = @minpositiontaking_1,
			@minpositiontaking_2 = @minpositiontaking_2,
			@minpositiontaking_3 = @minpositiontaking_3,
			@minpositiontaking_4 = @minpositiontaking_4,
			@minpositiontaking_5 = @minpositiontaking_5,
			@minpositiontaking_6 = @minpositiontaking_6,
			@minpositiontaking_7 = @minpositiontaking_7,
			@minpositiontaking_8 = @minpositiontaking_8,
			@minpositiontaking_9 = @minpositiontaking_9,
			@minpositiontaking_10 = @minpositiontaking_10,

			@minlivepositiontaking_1 = @minlivepositiontaking_1,
			@minlivepositiontaking_3 = @minlivepositiontaking_3,
			@minlivepositiontaking_7 = @minlivepositiontaking_7,
			@minlivepositiontaking_8 = @minlivepositiontaking_8,

			@UpdateMinPos = @UpdateMinPos,
			@UpdateMaxPos = @UpdateMaxPos,
			@roleid = @roleid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language
END
if @ErrCode <> 0
BEGIN
	return
END
if @roleid=3
BEGIN 
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_MAg_1
			@custid = @custid,
			@minpositiontaking_1 = @minpositiontaking_1,
			@minpositiontaking_2 = @minpositiontaking_2,
			@minpositiontaking_3 = @minpositiontaking_3,
			@minpositiontaking_4 = @minpositiontaking_4,
			@minpositiontaking_5 = @minpositiontaking_5,
			@minpositiontaking_6 = @minpositiontaking_6,
			@minpositiontaking_7 = @minpositiontaking_7,
			@minpositiontaking_8 = @minpositiontaking_8,
			@minpositiontaking_9 = @minpositiontaking_9,
			@minpositiontaking_10 = @minpositiontaking_10,

			@minlivepositiontaking_1 = @minlivepositiontaking_1,
			@minlivepositiontaking_3 = @minlivepositiontaking_3,
			@minlivepositiontaking_7 = @minlivepositiontaking_7,
			@minlivepositiontaking_8 = @minlivepositiontaking_8,
			
			@maxpositiontaking_1 = @maxpositiontaking_1,
			@maxpositiontaking_2 = @maxpositiontaking_2,
			@maxpositiontaking_3 = @maxpositiontaking_3,
			@maxpositiontaking_4 = @maxpositiontaking_4,
			@maxpositiontaking_5 = @maxpositiontaking_5,
			@maxpositiontaking_6 = @maxpositiontaking_6,
			@maxpositiontaking_7 = @maxpositiontaking_7,
			@maxpositiontaking_8 = @maxpositiontaking_8,
			@maxpositiontaking_9 = @maxpositiontaking_9,
			@maxpositiontaking_10 = @maxpositiontaking_10,

			@maxlivepositiontaking_1 = @maxlivepositiontaking_1,
			@maxlivepositiontaking_3 = @maxlivepositiontaking_3,
			@maxlivepositiontaking_7 = @maxlivepositiontaking_7,
			@maxlivepositiontaking_8 = @maxlivepositiontaking_8,

			@UpdateMinPos = @UpdateMinPos,
			@UpdateMaxPos = @UpdateMaxPos,
			@roleid = @roleid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language
END
if @ErrCode <> 0
BEGIN
	return
END
if @roleid=2
BEGIN 
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_Ag_1 
			@custid = @custid,
			@minpositiontaking_1 = @minpositiontaking_1,
			@minpositiontaking_2 = @minpositiontaking_2,
			@minpositiontaking_3 = @minpositiontaking_3,
			@minpositiontaking_4 = @minpositiontaking_4,
			@minpositiontaking_5 = @minpositiontaking_5,
			@minpositiontaking_6 = @minpositiontaking_6,
			@minpositiontaking_7 = @minpositiontaking_7,
			@minpositiontaking_8 = @minpositiontaking_8,
			@minpositiontaking_9 = @minpositiontaking_9,
			@minpositiontaking_10 = @minpositiontaking_10,
			
			@minlivepositiontaking_1 = @minlivepositiontaking_1,
			@minlivepositiontaking_3 = @minlivepositiontaking_3,
			@minlivepositiontaking_7 = @minlivepositiontaking_7,
			@minlivepositiontaking_8 = @minlivepositiontaking_8,
			
			@UpdateMinPos = @UpdateMinPos,
			@UpdateMaxPos = @UpdateMaxPos,
			@roleid = @roleid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language
END
if @ErrCode <> 0
BEGIN
	return
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_1] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_1] TO vnteam
GO
 