Create PROCEDURE [dbo].[Acc_CustomerUpdSyncBingo]
	@CustID int,
	@SyncBingo bit,	
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20100908@Steven
Task : Update customer SyncBingo status
DB: DB02.bodb02
Original:

Revisions:
   

Param's Explanation:
• @custid: customer id.   
• @SyncBingo: status
*/
SET NOCOUNT ON
--Check disable user
EXEC DB052.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @RoleID tinyint

select	@RoleID = RoleID
from Custinfo with (nolock)
where CustID = @CustID

if @RoleID not in (1,2,3,4)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Invalid user!'
						when 'CS' then N'账号无效!'
						when 'CT' then N'帳號無效.!'
						when 'TH' then N'ผู้ใช้ไม่ถูกต้อง!'
						when 'J' then N'Invalid user!'
						when 'KO' then N'잘못된 사용자 입니다.'
						else N'Invalid user!'
					end, @ErrCode = 100	
	return
END
---------------------

update CustInfo with (ROWLOCK, UPDLOCK) set SyncBingo = @SyncBingo
where CustID = @CustID
if (@@error <> 0)
begin

	Select @ErrMsg =
					case @Language 
						when 'E' then 'Update process is unsuccessful.'
						when 'CS' then N'更新程序不成功。'
						when 'CT' then N'更新程序不成功。'
						when 'TH' then N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น'
						when 'J' then N'アップデート出来ません。'
						when 'KO' then N'업데이트에 실패했습니다.'
						else N'Update process is unsuccessful.'
					end	, @ErrCode = 101
	return
end

declare @LogSPData varchar(2000)

Select @LogSPData = '<Acc_CustomerUpdSyncBingo CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
					'SyncBingo="'+ coalesce(cast(@SyncBingo as varchar(50)),space(1)) + '" '+
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

/*1505	[Acc_CustomerUpdSyncBingo]	Update customer SyncBingo status*/
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 1505,
	@TrackingValue = @LogSPData	 

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSyncBingo] TO [bodbAdminNet]
GO
GRANT  EXECUTE  ON [dbo].[Acc_CustomerUpdSyncBingo]  TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSyncBingo] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSyncBingo] TO [bodbExtAccNet]