 ALTER PROCEDURE Acc_Dep_CustomerUpdMemberVirtualSports_SAg
	@UserID INT,
	
	@CustId INT,
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	@v180MaxPerMatch MONEY,
	@v180sPositionTaking MONEY,
	@v180mPositionTaking SMALLMONEY,
	
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
 AS

--@Source Control
/*
Created: 20120828@Dom
Task : Super update MinBet, MaxBet, MaxPerMatch, PT of Master for virtual sports
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
 
 DECLARE @v180MinBet_Max MONEY,
		@v180MaxBet_Max MONEY,
		@v180MaxPerMatch_Max MONEY,
		@v180mPositionTaking_Max SMALLMONEY,
		
		@ErrAcc varchar(4000), 
		@ErrType varchar(4000)
		

/***********************************
* Validate Setting
***********************************/
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
	
/***********************************
* Validate Bet Setting
***********************************/

IF @v180sPositionTaking < 0
	OR @v180mPositionTaking < 0
BEGIN
	 Select @ErrMsg = case @Language 
						when 'E' then 'Wrong  position taking.<br>'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
					end, @ErrCode = 104
		return
END


SELECT @ErrAcc = ''
SELECT top 100 @ErrAcc = @ErrAcc + username +', '
FROM custInfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 WITH(NOLOCK) ON ci.custid = cs3.custid
	INNER JOIN (
		SELECT 180 AS sporttype, 1201 AS bettype,@v180mPositionTaking AS mpositiontaking_max	
	) b ON b.sporttype = cs3.sporttype AND cs3.bettype = b.bettype
WHERE ci.mrecommend = @CustId
	AND ci.roleid = 2
	AND cs3.sporttype = 180
	AND cs3.apositiontaking + cs3.mpositiontaking > b.mpositiontaking_max
IF @ErrAcc <> ''
BEGIN
	select @ErrCode = 14
	Select @ErrMsg = case @Language 
						when 'E' then 'Existing agents exceeded new master position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
					end
	return
END


SELECT @ErrAcc = ''
SELECT top 100 @ErrAcc = @ErrAcc + username +', '
FROM custInfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 WITH(NOLOCK) ON ci.custid = cs3.custid
	INNER JOIN (
		SELECT 180 AS sporttype, 1201 AS bettype,@v180mPositionTaking AS mpositiontaking_max	
	) b ON b.sporttype = cs3.sporttype AND cs3.bettype = b.bettype
WHERE ci.mrecommend = @CustId
	AND ci.roleid = 2
	AND cs3.sporttype = 180
	AND cs3.apositiontaking + cs3.mpositiontaking > b.mpositiontaking_max
IF @ErrAcc <> ''
BEGIN
	select @ErrCode = 15
	Select @ErrMsg =  case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20012,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
					end
	return
END
	 
 /**********************************
 * Update setting
 **********************************/
 UPDATE custinfo WITH (ROWLOCK,UPDLOCK)
 SET maxpermatch180 = @v180MaxPerMatch
 WHERE custid = @CustId

 if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
	return
END

 /*********************************
 * Update Bet Setting
 *********************************/
 UPDATE Dep_CustSetting3rd WITH(ROWLOCK,UPDLOCK)
 SET
 	mpositiontaking = @v180mPositionTaking,
 	spositiontaking = @v180sPositionTaking,
 	minbet = @v180MinBet,
 	maxbet = @v180MaxBet
 WHERE custid = @CustId
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
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_SAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'MinBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MaxBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MPMv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' 

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2019,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write PT Log
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_SAg><s v'+CAST(@SportType AS NVARCHAR(50))+'spt_1201="'+ COALESCE(CAST(@sPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<m v'+CAST(@SportType AS NVARCHAR(50))+'mpt_1201="'+ COALESCE(CAST(@mPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<a v'+CAST(@SportType AS NVARCHAR(50))+'apt_1201="'+ COALESCE(CAST(0 AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'</Acc_Dep_CustomerUpdMemberVirtualSports_SAg>'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2714,
	@TrackingValue = @LogSPData,
	@duration = @duration
*/	
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_SAg] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_SAg] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_SAg] TO [bodbExtAccNet]