ALTER PROCEDURE Acc_Dep_CustomerInsMemberVirtualSports_MAg 
	@custid INT,
	@mrecommend int,

	@v180aPositionTaking SMALLMONEY,
	@v180mPositionTaking SMALLMONEY,
	
	@v180MinBet MONEY,
	@v180MaxBet MONEY,

	@ErrCode int = 0 OUTPUT,
	@Language VARCHAR(2) = 'E',
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20122808@Dom
Task : Master create Agent's info and settings for virutal sport in Deposite site
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

DECLARE @v180mPositionTaking_Max SMALLMONEY,
	
		@v180MinBet_Max MONEY,
		@v180MaxBet_Min MONEY,
		@v180MaxPerMatch_Max MONEY,
		
		@DisableVirtualSports BIT
		
SELECT @DisableVirtualSports = DisableVirtualSports
FROM custinfo WITH (NOLOCK)
WHERE custid = @mrecommend

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
SELECT @v180MaxPerMatch_Max = ci.maxpermatch180, 
	@v180MinBet_Max = cs3.minbet, 
	@v180MaxBet_Min = cs3.maxbet, 
	@v180mPositionTaking_Max = cs3.mpositiontaking
FROM custinfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 ON ci.custid = cs3.custid
WHERE ci.custid = @mrecommend
	AND cs3.sporttype = 180

IF  (@v180MinBet < @v180MinBet_Max and @v180minbet>0 AND @v180MinBet_Max > 0)
	OR (@v180MaxBet > @v180MaxBet_Min and @v180maxbet>0 AND @v180MaxBet_Min > 0)
BEGIN
	 SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Min bet must be equal to or greater than super agent min bet .'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
					end
										
	SELECT @ErrCode = 107
	RETURN 
END 

IF (@v180mPositionTaking+@v180aPositionTaking>@v180mPositionTaking_Max)
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
	@custid/* custid	*/,
	1201,
	180,
	0,
	@v180aPositionTaking,
	@v180mPositionTaking,
	0,
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

GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_MAg] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_MAg] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_MAg] TO [bodbExtAccNet]

	
