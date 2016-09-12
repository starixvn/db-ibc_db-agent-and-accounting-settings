USE CustDB
GO
CREATE PROCEDURE [dbo].[Acc_CustNoCommIns] 
	 @CustID			INT
	, @Remark			VARCHAR(200)
	, @UserID			INT=NULL
	
AS
/*
Created: 20160912@Winnie
Task : Insert custid to remove commision
DB: dbcust/custdb
Original: Insert custid to remove commision

Param's Explanation:
• @ErrCode:
    = 0: Update Agent successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
 Declare @LogSPData VARCHAR(8000)
 declare @startRun datetime
 declare @endRun datetime
 declare @duration INT
 set @startRun = getdate()
 declare @Creator INT
 SELECT @Creator=@UserID

INSERT INTO [CustDB].[dbo].[CustNoComm]
           ([CustID]
           ,[ModifiedDate]
           ,[Remark]
           ,[UserID])
     VALUES
           (@CustID
           ,GETDATE()
           ,@Remark
           ,@UserID)
IF(@@ERROR<>0)
RETURN
 set @endRun = getdate()
 set @duration  = datediff (millisecond,@startRun,@endRun)
--Write PT log
    SELECT @LogSPData = '<Acc_CustNoCommIns CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1)) + '" ' +
    'Remark="'+ COALESCE(CAST(@Remark AS VARCHAR(200)), SPACE(1))  + '" />'

    BEGIN TRY
	    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 249,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END TRY
    BEGIN CATCH	
	    --Write PT log
	    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		    @UserID = @Creator,
		    @CustID = @CustID,
		    @ActionID = 249,
		    @TrackingValue = @LogSPData,
		    @duration = @duration
    END CATCH


