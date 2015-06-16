ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_3]
	@custid int,

	@minv3positiontaking_1 smallmoney,
	@minv3positiontaking_2 smallmoney,
	@minv3positiontaking_3 smallmoney,
	@minv3positiontaking_20 smallmoney,

	@maxv3positiontaking_1 smallmoney,
	@maxv3positiontaking_2 smallmoney,
	@maxv3positiontaking_3 smallmoney,
	@maxv3positiontaking_20 smallmoney,
	
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
Task : Check parameters to update CustOverride for Football
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
EXEC dbo.Acc_CustOverrideUpd_CheckParam_V_3
			@custid = @custid,
			
			@minv3positiontaking_1 = @minv3positiontaking_1,
			@minv3positiontaking_2 = @minv3positiontaking_2,
			@minv3positiontaking_3 = @minv3positiontaking_3,
			@minv3positiontaking_20 = @minv3positiontaking_20,

			@maxv3positiontaking_1 = @maxv3positiontaking_1,
			@maxv3positiontaking_2 = @maxv3positiontaking_2,
			@maxv3positiontaking_3 = @maxv3positiontaking_3,
			@maxv3positiontaking_20 = @maxv3positiontaking_20,
			
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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_SAg_3
			@custid = @custid,
			
			@minv3positiontaking_1 = @minv3positiontaking_1,
			@minv3positiontaking_2 = @minv3positiontaking_2,
			@minv3positiontaking_3 = @minv3positiontaking_3,
			@minv3positiontaking_20 = @minv3positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_MAg_3
			@custid = @custid,
			
			@minv3positiontaking_1 = @minv3positiontaking_1,
			@minv3positiontaking_2 = @minv3positiontaking_2,
			@minv3positiontaking_3 = @minv3positiontaking_3,
			@minv3positiontaking_20 = @minv3positiontaking_20,

			@maxv3positiontaking_1 = @maxv3positiontaking_1,
			@maxv3positiontaking_2 = @maxv3positiontaking_2,
			@maxv3positiontaking_3 = @maxv3positiontaking_3,
			@maxv3positiontaking_20 = @maxv3positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_Ag_3
			@custid = @custid,
			
			@minv3positiontaking_1 = @minv3positiontaking_1,
			@minv3positiontaking_2 = @minv3positiontaking_2,
			@minv3positiontaking_3 = @minv3positiontaking_3,
			@minv3positiontaking_20 = @minv3positiontaking_20,

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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_3] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_3] TO vnteam
GO
 