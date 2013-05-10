ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_161]
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
Created: 20120510@Elodie
Task : Check parameters to update CustOverride for Number Game
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
EXEC dbo.Acc_CustOverrideUpd_CheckParam_V_161
			@custid = @custid,
			
			@minv161positiontaking_81 = @minv161positiontaking_81,
			@minv161positiontaking_83 = @minv161positiontaking_83,
			--@minv161positiontaking_85 = @minv161positiontaking_85,
			@minv161positiontaking_86 = @minv161positiontaking_86,
			@minv161positiontaking_88 = @minv161positiontaking_88,

			@minv161livepositiontaking_85 = @minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @minv161livepositiontaking_90,
			
			@maxv161positiontaking_81 = @maxv161positiontaking_81,
			@maxv161positiontaking_83 = @maxv161positiontaking_83,
			--@maxv161positiontaking_85 = @maxv161positiontaking_85,
			@maxv161positiontaking_86 = @maxv161positiontaking_86,
			@maxv161positiontaking_88 = @maxv161positiontaking_88,
			
			@maxv161livepositiontaking_85 = @maxv161livepositiontaking_85,
			@maxv161livepositiontaking_86 = @maxv161livepositiontaking_86,
			@maxv161livepositiontaking_87 = @maxv161livepositiontaking_87,
			@maxv161livepositiontaking_89 = @maxv161livepositiontaking_89,
			@maxv161livepositiontaking_90 = @maxv161livepositiontaking_90,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_SAg_161
			@custid = @custid,
			
			@minv161positiontaking_81 = @minv161positiontaking_81,
			@minv161positiontaking_83 = @minv161positiontaking_83,
			--@minv161positiontaking_85 = @minv161positiontaking_85,
			@minv161positiontaking_86 = @minv161positiontaking_86,
			@minv161positiontaking_88 = @minv161positiontaking_88,

			@minv161livepositiontaking_85 = @minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @minv161livepositiontaking_90,
			
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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_MAg_161
			@custid = @custid,
			
			@minv161positiontaking_81 = @minv161positiontaking_81,
			@minv161positiontaking_83 = @minv161positiontaking_83,
			--@minv161positiontaking_85 = @minv161positiontaking_85,
			@minv161positiontaking_86 = @minv161positiontaking_86,
			@minv161positiontaking_88 = @minv161positiontaking_88,

			@minv161livepositiontaking_85 = @minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @minv161livepositiontaking_90,
			
			@maxv161positiontaking_81 = @maxv161positiontaking_81,
			@maxv161positiontaking_83 = @maxv161positiontaking_83,
			--@maxv161positiontaking_85 = @maxv161positiontaking_85,
			@maxv161positiontaking_86 = @maxv161positiontaking_86,
			@maxv161positiontaking_88 = @maxv161positiontaking_88,
			
			@maxv161livepositiontaking_85 = @maxv161livepositiontaking_85,
			@maxv161livepositiontaking_86 = @maxv161livepositiontaking_86,
			@maxv161livepositiontaking_87 = @maxv161livepositiontaking_87,
			@maxv161livepositiontaking_89 = @maxv161livepositiontaking_89,
			@maxv161livepositiontaking_90 = @maxv161livepositiontaking_90,

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
	EXEC dbo.Acc_CustOverrideUpd_CheckParam_Ag_161
			@custid = @custid,
			
			@minv161positiontaking_81 = @minv161positiontaking_81,
			@minv161positiontaking_83 = @minv161positiontaking_83,
			--@minv161positiontaking_85 = @minv161positiontaking_85,
			@minv161positiontaking_86 = @minv161positiontaking_86,
			@minv161positiontaking_88 = @minv161positiontaking_88,

			@minv161livepositiontaking_85 = @minv161livepositiontaking_85,
			@minv161livepositiontaking_86 = @minv161livepositiontaking_86,
			@minv161livepositiontaking_87 = @minv161livepositiontaking_87,
			@minv161livepositiontaking_89 = @minv161livepositiontaking_89,
			@minv161livepositiontaking_90 = @minv161livepositiontaking_90,
			
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
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_161] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpd_CheckParam_161] TO vnteam
GO
 