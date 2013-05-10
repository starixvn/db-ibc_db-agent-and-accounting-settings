 ALTER PROCEDURE Acc_Dep_CustomerInsMemberVirtualSports_SAg
	@custid int,
	@creator int,
	@srecommend int,

	@v180sPositionTaking SMALLMONEY,
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
Task : Super create Master's info and settings for virutal sport in Deposite site
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
		@v180MaxBet_Min MONEY
		

/**********************************
* validate Min/Max Bet & MaxPerMatch
**********************************/
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
SELECT @v180MinBet_Max = cs3.minbet, 
	@v180MaxBet_Min = cs3.maxbet, 
	@v180mPositionTaking_Max = cs3.mpositiontaking
FROM custinfo ci WITH(NOLOCK)
	INNER JOIN Dep_CustSetting3rd cs3 ON ci.custid = cs3.custid
WHERE ci.custid = @srecommend
	AND cs3.sporttype = 180

IF 	@v180MinBet < @v180MinBet_Max AND @v180MinBet > 0 AND @v180MinBet_Max > 0
	OR @v180MaxBet > @v180MaxBet_Min AND @v180MaxBet > 0 AND @v180MaxBet_Min > 0
BEGIN
	 SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Min bet must be equal to or greater than super agent min bet .'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
					end
										
	SELECT @ErrCode = 107
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN 
END 

IF (@v180mPositionTaking+@v180sPositionTaking>@v180mPositionTaking_Max)
BEGIN
	 SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (max for super set by company).<br>'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20004,@Language) + '<br>'
						end
	SELECT @ErrCode = 104
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN   
END

/**********************
* Insert Setting
**********************/
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
	0,
	@v180mpositiontaking,
	@v180spositiontaking,
	0,
	0,
	0,
	0,
	@v180minbet,
	@v180maxbet
)

IF @@error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						end	
			,  @ErrCode=119
	-- ROLLBACK MANUALLY
	DELETE Dep_CustSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE Dep_CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
	
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN 
END

GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_SAg] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_SAg] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_SAg] TO [bodbExtAccNet]