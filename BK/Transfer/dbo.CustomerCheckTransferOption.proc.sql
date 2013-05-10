ALTER PROCEDURE [dbo].[CustomerCheckTransferOption]
	@CustID int, 
	@ErrMsg nvarchar(100) OUTPUT,
	@ErrCode int OUTPUT,
	@Language varchar(2) = 'E'
AS

--@Source Control
----------------------------------------------------------------------
--
--Check Transfer Condition (for master and agent)
--1		2		3		4		5		6		7		8
--isSun	isMon	isTue	isWed	isThurs	isFri	isSat	isWeekly
--0		1		0		0		1		0		1		1

Declare @strTransferOption varchar(8)
select @ErrCode = 0

--skip checking for direct master
if exists(select 1 from customer with (nolock) where custid = @custid and roleid = 3 and srecommend < 100)
	return


select @strTransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))
from customer with (nolock)
where custID = @CustID

if SUBSTRING(@strTransferOption, 8, 1) = 1 --isWeekly = 1
	AND SUBSTRING(@strTransferOption, datepart(weekday, dateadd(hh, 12, CURRENT_TIMESTAMP)), 1) = 0
BEGIN	
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, you can only transfer on: ' +
							case when SUBSTRING(@strTransferOption, 2, 1) = 1 then 'Monday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 3, 1) = 1 then 'Tuesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 4, 1) = 1 then 'Wednesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 5, 1) = 1 then 'Thursday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 6, 1) = 1 then 'Friday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 7, 1) = 1 then 'Saturday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 1, 1) = 1 then 'Sunday - ' else '' end
						when 'CS' then N'對不起, 您只能於: ' +
							case when SUBSTRING(@strTransferOption, 2, 1) = 1 then N'星期一 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 3, 1) = 1 then N'星期二 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 4, 1) = 1 then N'星期三 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 5, 1) = 1 then N'星期四 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 6, 1) = 1 then N'星期伍 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 7, 1) = 1 then N'星期六 - ' else '' end +
							case when SUBSTRING(@strTransferOption, 1, 1) = 1 then N'星期日 轉帳 - ' else '' end
						when 'J' then N'Sorry, you can only transfer on: ' +
							case when SUBSTRING(@strTransferOption, 2, 1) = 1 then 'Monday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 3, 1) = 1 then 'Tuesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 4, 1) = 1 then 'Wednesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 5, 1) = 1 then 'Thursday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 6, 1) = 1 then 'Friday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 7, 1) = 1 then 'Saturday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 1, 1) = 1 then 'Sunday - ' else '' end
						else N'Sorry, you can only transfer on: ' +
							case when SUBSTRING(@strTransferOption, 2, 1) = 1 then 'Monday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 3, 1) = 1 then 'Tuesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 4, 1) = 1 then 'Wednesday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 5, 1) = 1 then 'Thursday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 6, 1) = 1 then 'Friday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 7, 1) = 1 then 'Saturday - ' else '' end +
							case when SUBSTRING(@strTransferOption, 1, 1) = 1 then 'Sunday - ' else '' end
					end, @ErrCode = 201
	select @ErrMsg = left(@ErrMsg, len(@ErrMsg)-2)	
	return
END