 ALTER PROCEDURE Acc_Dep_CustomerUpdMemberVirtualSports_MAg -- agent custid 
	@CustID INT, -- Super ID
	
	@v180MaxPerMatch MONEY,
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	
	@v180aPositionTaking SMALLMONEY,
	@v180mPositionTaking SMALLMONEY,
	
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
	
 AS

--@Source Control
/*
Created: 20120828@Dom
Task : Master update MinBet, MaxBet, MaxPerMatch, PT of Agent for virtual sports
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
 
DECLARE @ErrType VARCHAR(1000)
DECLARE @ErrAcc nvarchar(4000)

DECLARE @v180MinBet_Max MONEY,
		@v180MaxBet_Min MONEY,
		@v180aPositionTaking_Max SMALLMONEY,
		@v180MaxPerMatch_Max MONEY,
		@mrecommend INT
		
SELECT @mrecommend = mrecommend FROM custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID
SELECT @v180MinBet_Max = cs3.minbet,
	@v180MaxBet_Min = cs3.maxbet,
	@v180MaxPerMatch_Max = ci.maxpermatch180,
	@v180aPositionTaking_Max = cs3.apositiontaking
FROM custInfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 ON (ci.srecommend = cs3.custid OR ci.mrecommend = cs3.custid)
WHERE ci.custid = @mrecommend
	AND cs3.sporttype = 180

IF @v180MinBet < 0 
	OR @v180MaxBet < 0
	OR @v180MinBet > @v180MaxBet
	OR @v180MinBet > @v180MaxPerMatch
	OR @v180MaxBet > @v180MaxPerMatch
BEGIN 
	Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 102
	return
END 

IF (@v180MinBet < @v180MinBet_Max and @v180minbet > 0 AND @v180MinBet_Max > 0)
	OR (@v180MaxBet > @v180MaxBet_Min and @v180maxbet > 0 AND @v180MaxBet_Min > 0)
	OR (@v180MaxPerMatch > @v180MaxPerMatch_Max and @v180MaxPerMatch > 0 AND @v180MaxPerMatch_Max > 0)
BEGIN
	 SELECT @ErrMsg = case @Language 
						when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Virtual Soccer)'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
					end						
			, @ErrCode = 119
	return
END 
-------------------------------------------
--Check all a1<=a4
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join Dep_CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				   select 	180 as sporttype, 1201 as bettype, @v180apositiontaking as maxpositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.recommend = @custid 
	AND cs.sporttype = 180
	and c.roleid = 1
	and (
			(cs.apositiontaking>b.maxpositiontaking)  
		)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = '' +
				case @Language 
						when 'E' then 'Existing members exceeded new agent position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20017,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 109
	return
END


	
 /*************************************
 * Update Setting
 *************************************/
 UPDATE custinfo WITH(ROWLOCK,UPDLOCK) SET maxpermatch180 = @v180MaxPerMatch
 WHERE custid = @CustID
 if (@@error <> 0)
begin
	
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end	, @ErrCode = 103 
	return
END

 /*************************************
 * Update Bet Setting
 *************************************/
 UPDATE Dep_CustSetting3rd WITH(ROWLOCK,UPDLOCK)
 SET
 	mpositiontaking = @v180mPositionTaking,
 	apositiontaking = @v180aPositionTaking,
 	minbet = @v180MinBet,
 	maxbet = @v180MaxBet
 WHERE custid = @CustID
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
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_MAg custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'MinBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MaxBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MPMv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' 

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2020,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write PT Log
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_MAg><s v'+CAST(@SportType AS NVARCHAR(50))+'spt_1201="'+ COALESCE(CAST(0 AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<m v'+CAST(@SportType AS NVARCHAR(50))+'mpt_1201="'+ COALESCE(CAST(@mPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<a v'+CAST(@SportType AS NVARCHAR(50))+'apt_1201="'+ COALESCE(CAST(@aPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'</Acc_Dep_CustomerUpdMemberVirtualSports_MAg>'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2715,
	@TrackingValue = @LogSPData,
	@duration = @duration
*/	
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_MAg] TO [bodbAdminNet]
GO
GRANT VIEW definition ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_MAg] TO vnteam
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_MAg] TO [bodbExtAccNet]