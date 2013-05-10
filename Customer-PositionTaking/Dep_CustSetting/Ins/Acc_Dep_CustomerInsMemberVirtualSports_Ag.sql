 ALTER PROCEDURE Acc_Dep_CustomerInsMemberVirtualSports_Ag
	@custid INT,
	@recommend INT,

	@v180aPositionTaking SMALLMONEY,
	
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	
	@ErrCode int = 0 OUTPUT,
	@Language VARCHAR(2) = 'E',
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS

--@Source Control
/*
Created: 20122808@Dom
Task : Agent create Member's info and settings for virutal sport in Deposite site
DB: DBTRANS.bodb02
Original:
Revisions:
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:
• @ErrCode:
    = 0: Create super successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

DECLARE @v180aPositionTaking_Max SMALLMONEY,
		@v180mPositionTaking SMALLMONEY,
		@v180sPositionTaking SMALLMONEY,
		@v180MinBet_Max MONEY,
		@v180MaxBet_Min MONEY,
		@v180MaxPerMatch_Max MONEY,
		
		@DisableVirtualSports BIT,
		
		@srecommend INT,
		@mrecommend INT
		
SELECT @DisableVirtualSports = DisableVirtualSports,
	@mrecommend = mrecommend,
	@srecommend = srecommend
FROM custinfo WITH (NOLOCK)
WHERE custid = @recommend

SELECT @v180sPositionTaking = cs3.spositiontaking
FROM Dep_CustSetting3rd cs3 WITH (NOLOCK)
WHERE cs3.custid = @mrecommend 

SELECT @v180mPositionTaking = cs3.mpositiontaking
FROM Dep_CustSetting3rd cs3 WITH (NOLOCK)
WHERE cs3.custid = @recommend

/***********************************
* Validate Min/max Bet
***********************************/
IF(@v180MinBet>@v180MaxBet)
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Min Bet must be less than Max Bet and Max Bet must be less than Max Per Match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
					end
										
	Select @ErrCode = 103
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END

/****************************
* Validate Bet Setting
****************************/
SELECT @v180aPositionTaking_Max = cs3.apositiontaking
FROM Dep_CustSetting3rd cs3 WITH(NOLOCK)
WHERE cs3.custid = @recommend

SELECT @v180MaxPerMatch_Max = min(CASE WHEN ci.maxpermatch180 = 0 THEN NULL ELSE ci.maxpermatch180 END), 
	@v180MinBet_Max = MAX(cs3.minbet), 
	@v180MaxBet_Min = min(cs3.maxbet)
FROM custinfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 WITH(NOLOCK) ON (ci.custid = cs3.custid OR ci.mrecommend = cs3.custid OR ci.srecommend = cs3.custid)
WHERE ci.custid = @recommend
	AND cs3.sporttype = 180

IF (@v180MinBet < @v180MinBet_Max and @v180MinBet > 0 AND @v180MinBet_Max > 0)
	OR (@v180MaxBet > @v180MaxBet_Min and @v180MaxBet > 0 AND @v180MaxBet_Min > 0)
BEGIN
	 SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Min bet must be equal to or greater than agent min bet .'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
					end
										
	SELECT @ErrCode = 107
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN 
END 

IF (@v180aPositionTaking>@v180aPositionTaking_Max)
BEGIN
	 SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (max for super set by company).<br>'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20004,@Language) + '<br>'
						end
	SELECT @ErrCode = 104
	RETURN   
END


/****************************
* Add Bet Setting
****************************/

INSERT INTO Dep_CustSetting3rd
(
	custid,
	bettype,
	sporttype,
	islive,
	apositiontaking,
	mpositiontaking,
	spositiontaking,
	playerdiscount,
	discount,
	adiscount,
	sdiscount,
	minbet,
	maxbet
)
VALUES
(
	@custid,
	1201,
	180,
	0,
	@v180aPositionTaking,
	@v180mPositionTaking,
	@v180sPositionTaking,
	0,
	0,
	0,
	0,
	@v180MinBet,
	@v180MaxBet
)
IF @@error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end	
			,  @ErrCode=119
	
	RETURN 
END

/**************************
* Write Logs
**************************/
/*
SET @endRun = GETDATE()
SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

DECLARE @LogSPData VARCHAR(4000)
--Write status log
SELECT @LogSPData = '<Acc_Dep_CustomerInsMemberVirtualSports_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'disablevirtualsport="'+ COALESCE(CAST(@DisableVirtualSports AS VARCHAR(1)),SPACE(1)) + '" ' +
'" />'
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @custid,
	@ActionID = 2209,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
--Write Bet setting log
SELECT @LogSPData = '<Acc_Dep_CustomerInsMemberVirtualSports_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
'MinBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MaxBv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
'MPMv'+CAST(@SportType AS VARCHAR(50))+'="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' 

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 2017,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write PT Log
SELECT @LogSPData = '<Acc_Dep_CustomerInsMemberVirtualSports_Ag><s v'+CAST(@SportType AS NVARCHAR(50))+'spt_1201="'+ COALESCE(CAST(@sPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<m v'+CAST(@SportType AS NVARCHAR(50))+'mpt_1201="'+ COALESCE(CAST(@mPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'<a v'+CAST(@SportType AS NVARCHAR(50))+'apt_1201="'+ COALESCE(CAST(@aPositionTaking AS VARCHAR(50)),SPACE(1)) + '" ' +
'" />' +
'</Acc_Dep_CustomerInsMemberVirtualSports_Ag>'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 2712,
	@TrackingValue = @LogSPData,
	@duration = @duration
*/
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_Ag] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_Ag] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_Ag] TO [bodbExtAccNet]