 ALTER PROCEDURE Acc_Dep_CustomerInsMemberVirtualSports_Com
	@custid INT, 
	
	@v180MinBet MONEY,
	@v180MaxBet MONEY,
	@v180sPositionTaking SMALLMONEY ,
	@v180mPositionTaking SMALLMONEY ,
	@v180aPositionTaking SMALLMONEY ,
	
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(2000) = '' OUTPUT
 AS
 SET NOCOUNT ON
 DECLARE @startRun DATETIME , @endRun DATETIME , @duration INT
 SET @startRun = GETDATE()
 
 --@Source Control
/*
Created: 20122708@Dom
Task : Company create Super's info and settings for virutal sport in Deposite site
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

IF @v180MinBet < 0 
	OR @v180MaxBet < 0
	OR @v180sPositionTaking < 0
	OR @v180mPositionTaking < 0
	OR @v180aPositionTaking < 0
	OR @v180sPositionTaking > 0.9
	OR @v180mPositionTaking > 0.9
	OR @v180aPositionTaking > 0.9
BEGIN 
	SELECT @ErrCode = 3,
			@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Wrong position taking.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
			          END
	RETURN
END  

--------------------Add Setting--------------------------
INSERT INTO Dep_CustSetting3rd ([custid],
		[bettype],
		[sporttype],
		[islive],
		[apositiontaking],
		[mpositiontaking],
		[spositiontaking],
		[playerdiscount],
		[discount],
		[adiscount],
		[sdiscount],
		[minbet],
		[maxbet]) 
	VALUES (
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
		@v180MaxBet)

IF @@ERROR <> 0
BEGIN
	--Error Occurs
	
	SELECT @ErrMsg = CASE @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END	
			, @ErrCode=116
	
	RETURN
END 

GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_Com] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerInsMemberVirtualSports_Com] TO [vnteam]
