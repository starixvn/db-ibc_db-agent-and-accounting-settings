ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_2]
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
Created: 20120510@Elodie
Task : Check parameters to update CustOverride for Basketball
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
EXEC dbo.Acc_CustOverrideUpd_CheckParam_V_2
			@custid = @custid,
			
			@minv2positiontaking_1 = @minv2positiontaking_1,
			@minv2positiontaking_2 = @minv2positiontaking_2,
			@minv2positiontaking_3 = @minv2positiontaking_3,
			@minv2positiontaking_7 = @minv2positiontaking_7,
			@minv2positiontaking_8 = @minv2positiontaking_8,
			--@minv2positiontaking_9 = @minv2positiontaking_9,
			@minv2positiontaking_20 = @minv2positiontaking_20,

			@maxv2positiontaking_1 = @maxv2positiontaking_1,
			@maxv2positiontaking_2 = @maxv2positiontaking_2,
			@maxv2positiontaking_3 = @maxv2positiontaking_3,
			@maxv2positiontaking_7 = @maxv2positiontaking_7,
			@maxv2positiontaking_8 = @maxv2positiontaking_8,
			--@maxv2positiontaking_9 = @maxv2positiontaking_9,
			@maxv2positiontaking_20 = @maxv2positiontaking_20,
			
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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_SAg_2
			@custid = @custid,
			
			@minv2positiontaking_1 = @minv2positiontaking_1,
			@minv2positiontaking_2 = @minv2positiontaking_2,
			@minv2positiontaking_3 = @minv2positiontaking_3,
			@minv2positiontaking_7 = @minv2positiontaking_7,
			@minv2positiontaking_8 = @minv2positiontaking_8,
			--@minv2positiontaking_9 = @minv2positiontaking_9,
			@minv2positiontaking_20 = @minv2positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_MAg_2
			@custid = @custid,
			
			@minv2positiontaking_1 = @minv2positiontaking_1,
			@minv2positiontaking_2 = @minv2positiontaking_2,
			@minv2positiontaking_3 = @minv2positiontaking_3,
			@minv2positiontaking_7 = @minv2positiontaking_7,
			@minv2positiontaking_8 = @minv2positiontaking_8,
			--@minv2positiontaking_9 = @minv2positiontaking_9,
			@minv2positiontaking_20 = @minv2positiontaking_20,

			@maxv2positiontaking_1 = @maxv2positiontaking_1,
			@maxv2positiontaking_2 = @maxv2positiontaking_2,
			@maxv2positiontaking_3 = @maxv2positiontaking_3,
			@maxv2positiontaking_7 = @maxv2positiontaking_7,
			@maxv2positiontaking_8 = @maxv2positiontaking_8,
			--@maxv2positiontaking_9 = @maxv2positiontaking_9,
			@maxv2positiontaking_20 = @maxv2positiontaking_20,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_Ag_2
			@custid = @custid,
			
			@minv2positiontaking_1 = @minv2positiontaking_1,
			@minv2positiontaking_2 = @minv2positiontaking_2,
			@minv2positiontaking_3 = @minv2positiontaking_3,
			@minv2positiontaking_7 = @minv2positiontaking_7,
			@minv2positiontaking_8 = @minv2positiontaking_8,
			--@minv2positiontaking_9 = @minv2positiontaking_9,
			@minv2positiontaking_20 = @minv2positiontaking_20,

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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_2] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_2] TO vnteam
GO
 