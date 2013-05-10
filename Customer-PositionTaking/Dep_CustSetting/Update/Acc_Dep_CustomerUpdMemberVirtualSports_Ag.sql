ALTER  PROCEDURE Acc_Dep_CustomerUpdMemberVirtualSports_Ag
	@custid int,
	@userid int,

	@v180aPositionTaking SMALLMONEY,
	@v180mPositionTaking SMALLMONEY,
	@v180sPositionTaking SMALLMONEY,
	
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	@v180MaxPerMatch MONEY,
	
	@ErrCode int = 0 OUTPUT,
	@Language VARCHAR(2) = 'E',
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS

--@Source Control
/*
Created: 20120828@Dom
Task : Agent update MinBet, MaxBet, MaxPerMatch, PT of member for virtual sports
DB: DBTrans.bodb02

Revisions:
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/


DECLARE @startRun DATETIME
DECLARE @endRun DATETIME
DECLARE @duration INT
SET @startRun = getdate()

DECLARE @recommend int,-- Super ID
		@v180apositiontaking_max SMALLMONEY,
		@v180MinBet_Max MONEY,
		@v180MaxBet_Min MONEY

SELECT @recommend = recommend 
FROM custInfo ci WITH (NOLOCK) 
WHERE ci.custid = @custid

SELECT @v180apositiontaking_max = apositiontaking FROM Dep_CustSetting3rd cs3 WHERE cs3.custid = @recommend

SELECT @v180MinBet_Max = MAX(CASE WHEN cs3.minbet = 0 THEN NULL ELSE cs3.minbet END),
	@v180MaxBet_Min = MIN(CASE WHEN cs3.maxbet = 0 THEN NULL ELSE cs3.maxbet END)
FROM Dep_CustSetting3rd cs3 WITH (NOLOCK)
INNER JOIN custInfo ci WITH (NOLOCK) ON (ci.srecommend = ci.custid OR ci.mrecommend = ci.custid OR ci.recommend = cs3.custid) 
WHERE ci.custid = @custid
	AND cs3.sporttype = 180

/*************************************
* Validate 
*************************************/

IF @v180aPositionTaking > @v180apositiontaking_max
	OR @v180aPositionTaking < 0
	OR @v180mPositionTaking < 0
	OR @v180sPositionTaking < 0
BEGIN
	 SELECT @ErrMsg = case @Language 
						when 'E' then 'Wrong  position taking.<br>'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
					end, @ErrCode = 104
	RETURN
END

IF @v180MinBet < 0
	OR @v180MaxBet < 0
	OR @v180MinBet > @v180MaxPerMatch
	OR @v180MaxBet > @v180MaxPerMatch
BEGIN 
	SELECT @ErrMsg = CASE @Language 
					WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
			END, @ErrCode = 101
	RETURN
END	

/*********************************
* Update info	
*********************************/
UPDATE custInfo WITH(ROWLOCK,UPDLOCK)
SET
	maxpermatch180 = @v180MaxPerMatch
WHERE custid = @custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
	return
END
	
/*******************************
* Update Bet Setting
*******************************/
UPDATE Dep_CustSetting3rd WITH(ROWLOCK,UPDLOCK)
SET
	minbet = @v180MinBet,
	maxbet = @v180MaxBet
WHERE custid = @custid
AND sporttype = 180
if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
	return
END

/**************************
* Write Logs
**************************/
/*
SET @endRun = GETDATE()
SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

DECLARE @LogSPData VARCHAR(4000)

--Write Bet setting log
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'MinBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MaxBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MPMv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' 

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2021,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write PT Log
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_Ag><s v'+CAST(@SportType AS NVARCHAR(50))+'spt_1201="'+ COALESCE(CAST(@sPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<m v'+CAST(@SportType AS NVARCHAR(50))+'mpt_1201="'+ COALESCE(CAST(@mPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<a v'+CAST(@SportType AS NVARCHAR(50))+'apt_1201="'+ COALESCE(CAST(@aPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'</Acc_Dep_CustomerUpdMemberVirtualSports_Ag>'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2716,
	@TrackingValue = @LogSPData,
	@duration = @duration
*/	
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Ag] TO [bodbAdminNet]
GO
GRANT VIEW definition ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Ag] TO vnteam
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Ag] TO [bodbExtAccNet]