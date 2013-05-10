ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_8]
	@custid int,

	@minv8positiontaking_1 smallmoney,
	@minv8positiontaking_3 smallmoney,
	@minv8positiontaking_20 smallmoney,

	@maxv8positiontaking_1 smallmoney,
	@maxv8positiontaking_3 smallmoney,
	@maxv8positiontaking_20 smallmoney,
	
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
Task : Check parameters to update CustOverride for Baseball
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
EXEC dbo.Acc_CustOverrideUpd_CheckParam_V_8
			@custid = @custid,
			
			@minv8positiontaking_1 = @minv8positiontaking_1,
			@minv8positiontaking_3 = @minv8positiontaking_3,
			@minv8positiontaking_20 = @minv8positiontaking_20,

			@maxv8positiontaking_1 = @maxv8positiontaking_1,
			@maxv8positiontaking_3 = @maxv8positiontaking_3,
			@maxv8positiontaking_20 = @maxv8positiontaking_20,
			
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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_SAg_8
			@custid = @custid,
			
			@minv8positiontaking_1 = @minv8positiontaking_1,
			@minv8positiontaking_3 = @minv8positiontaking_3,
			@minv8positiontaking_20 = @minv8positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_MAg_8
			@custid = @custid,
			
			@minv8positiontaking_1 = @minv8positiontaking_1,
			@minv8positiontaking_3 = @minv8positiontaking_3,
			@minv8positiontaking_20 = @minv8positiontaking_20,

			@maxv8positiontaking_1 = @maxv8positiontaking_1,
			@maxv8positiontaking_3 = @maxv8positiontaking_3,
			@maxv8positiontaking_20 = @maxv8positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_Ag_8
			@custid = @custid,
			
			@minv8positiontaking_1 = @minv8positiontaking_1,
			@minv8positiontaking_3 = @minv8positiontaking_3,
			@minv8positiontaking_20 = @minv8positiontaking_20,

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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_8] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_8] TO vnteam
GO
 