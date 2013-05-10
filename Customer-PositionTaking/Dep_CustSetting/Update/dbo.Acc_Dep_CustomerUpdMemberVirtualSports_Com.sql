 ALTER PROCEDURE [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Com]
	@CustID INT, -- Super ID
	
	@v180MaxPerMatch MONEY,
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	
	@v180sPositionTaking SMALLMONEY,
	@v180mPositionTaking SMALLMONEY,
	@v180aPositionTaking SMALLMONEY,
	
	@UserID INT = 0,	
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
 AS
 
 --@Source Control
/*
Created: 20120828@Dom
Task : Company update MinBet, MaxBet, MaxPerMatch, PT, Commission of Super agent
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

DECLARE @username varchar(40)
SELECT @ErrCode = 0


select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', ', @ErrType = @ErrType + t.typenamee+', '
from 
	custinfo as c with (NOLOCK) 
	inner join Dep_CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
					select 180 as sporttype, 1201 as bettype, @v180spositiontaking as maxpositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
	inner join bettype as t with (NOLOCK) ON t.typeid = b.bettype
where c.srecommend = @custid 
	AND cs.sporttype = 180
	AND c.roleid = 3 
	AND (
			((cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or ((cs.mpositiontaking>b.maxpositiontaking))
		)
group by username, t.typenamee

if @ErrAcc<>''

BEGIN
	Select @ErrMsg = 
				case @Language 
						when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 103
	return
END
------------------------------------------------------------------------------------------------------
--check all u1<=s4 if i1=1
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join Dep_CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				      select 	180 as sporttype, 1201 as bettype, @v180spositiontaking as maxpositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid
	AND cs.sporttype = 180 
	and c.roleid = 1 
	and (
			(cs.spositiontaking+cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking)
		)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = @username + ': ' +
				case @Language 
						when 'E' then 'Existing members exceeded new super position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20014,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 104
	return
END
---------------------------------------------------------------------------------------------------------------
--Check all m1+a1<=m4
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join Dep_CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				     select 180 as sporttype, 1201 as bettype, @v180mpositiontaking as maxpositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid 
	AND cs.sporttype = 180 
	and c.roleid = 1 
	and (
			(cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking)  
		)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = @username + ': ' +
				case @Language 
						when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20012,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 108
	return
END
------------------------------------------------------------------------------------------------------
--Check all a1<=a4
select @ErrAcc = ''
select top 100 @ErrAcc = @ErrAcc + username +', '
from 
	custinfo as c with (NOLOCK) 
	inner join Dep_CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	inner join (
				   select 	180 as sporttype, 1201 as bettype, @v180apositiontaking as maxpositiontaking
		) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
where c.srecommend = @custid 
	AND cs.sporttype = 180
	and c.roleid = 1
	and (
			(cs.apositiontaking>b.maxpositiontaking)  
		)
group by username
if @ErrAcc<>''
BEGIN
	Select @ErrMsg = @username + ': ' +
				case @Language 
						when 'E' then 'Existing members exceeded new agent position taking ('+@ErrAcc+') (for Virtual Soccer).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20017,@Language) + ' ('+@ErrAcc+')' + ' (' + [dbo].[f_Get_SportNameBySporttype](180,@Language) + ')'
				end, @ErrCode = 109
	return
END
/**************************
* Update CustInfo
**************************/
UPDATE custinfo with (ROWLOCK, UPDLOCK)
set 	
	MaxPerMatch180 = @v180MaxPerMatch	
where custid = @custid 
if (@@error <> 0)
begin
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115
	return
END
/*****************************
* Update Dep_Cussetting3rd
*****************************/
UPDATE Dep_CustSetting3rd WITH (ROWLOCK, UPDLOCK)
SET	
	MinBet = @v180MinBet,
	MaxBet = @v180MaxBet,
	spositiontaking = @v180sPositionTaking,
	mpositiontaking = @v180mPositionTaking,
	apositiontaking = @v180aPositionTaking
WHERE custid=@CustID
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
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'MinBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MaxBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MPMv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' 

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2018,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write PT Log
SELECT @LogSPData = '<Acc_Dep_CustomerUpdMemberVirtualSports_Com><s v'+CAST(@SportType AS NVARCHAR(50))+'spt_1201="'+ COALESCE(CAST(@sPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<m v'+CAST(@SportType AS NVARCHAR(50))+'mpt_1201="'+ COALESCE(CAST(@mPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<a v'+CAST(@SportType AS NVARCHAR(50))+'apt_1201="'+ COALESCE(CAST(@aPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'</Acc_Dep_CustomerInsMemberVirtualSports_Com>'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @UserID,
	@CustID = @CustID,
	@ActionID = 2713,
	@TrackingValue = @LogSPData,
	@duration = @duration
*/	
/******************************
* Assign Permission	
******************************/
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Com] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Com] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerUpdMemberVirtualSports_Com] TO [bodbExtAccNet]