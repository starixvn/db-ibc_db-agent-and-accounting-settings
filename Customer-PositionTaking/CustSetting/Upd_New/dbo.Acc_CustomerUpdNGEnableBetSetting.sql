ALTER PROCEDURE [dbo].[Acc_CustomerUpdNGEnableBetSetting]
	@username varchar(30),
	@isEnable bit = 0, --default is disable	
	@minbet money = 0,
	@maxbet money = 0,
	@maxperball money = 0,
	@maxpermatch money = 0,
	@userid int, --Admin ID
	@ip nvarchar(15),
	@ErrCode int = 0 OUTPUT,
	@ErrMsg varchar(5000) = '' OUTPUT
AS

/*
	Created: 20111111@Sophia
	Task:	Accounting site/ Customers/ Enable Number Game
			Number Game - Enable/Disable status, Update Bet Setting - for whole line
	DB: DBTXN/bodb02

	Revisions:	
		- Dom.Cao@2012-07-20: Just allow Enable NG in credit site
		- 20121206@Scott : Check Allowed downlines during peak hour at weekend
		- 20130218@Dan: Change linked server DB053 to DBAGE, DB03 to DBPOLICY; Write more log on DBTXN server in case of DBLOG server failure
	Param's Explanation:
		- @isEnable: the value of checkbox Enable
 
*/  

SET NOCOUNT ON

SELECT @ErrCode = 0 , @ErrMsg = ''

--Check permission  
EXEC DBPOLICY.bodb02.dbo.Acc_Con_CheckPermission @custid=@UserID,@funcname='[EnableBetSettingNG]',@ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
IF @ErrCode <> 0
	RETURN
--end


DECLARE @CustID int, @RoleID tinyint, @UplCustid int,
		@MinMinbet money, @MaxMaxbet money ,@MaxMaxperball money ,@MaxMaxpermatch money 

DECLARE @startRun DATETIME, @endRun DATETIME, @Duration int
DECLARE @LogSPData AS NVARCHAR(MAX) 

SELECT  @startRun = GETDATE()
SELECT	@CustID = 0, @RoleID = 0, @UplCustid= 0

SELECT	@CustID = CustID, @RoleID = RoleID, 
		@UplCustid = CASE WHEN RoleID = 1 THEN recommend 
							ELSE CASE WHEN RoleID = 2 THEN mrecommend 
								      ELSE CASE WHEN RoleID IN (3,4) THEN srecommend ELSE 0 END 
								END 
					  END 
FROM	custInfo WITH (NOLOCK)
WHERE	Username = @Username


---check valid username
IF ISNULL(@CustID,0) = 0 OR ISNULL(@UplCustid,0) = 0 OR @Roleid NOT IN (1,2,3,4)
BEGIN 
	SELECT @ErrCode = 100, @ErrMsg = 'Invalid Username.'
	RETURN
END


--Check Allowed downlines during peak hour at weekend
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language='E',
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
IF @ErrCode <>0 RETURN
--END



--check is deposite
IF(EXISTS (SELECT TOP 1 1 FROM customer c  WITH (NOLOCK)
			INNER JOIN [Site] s  WITH (NOLOCK) ON s.[site] = c.[site]
           WHERE c.custid = @UplCustid AND s.isLicensee=1))
BEGIN
	SELECT @ErrCode = 100, @ErrMsg = 'The settings of deposit customers is not enabled for editing from here!'
	RETURN
END

---check upline enabled number game 
IF EXISTS (	SELECT  TOP 1 1 
			FROM	custInfo WITH (NOLOCK)
			WHERE	CustID = @UplCustid AND @RoleID < 4 AND disablenumber = 1)	AND @isEnable = 1
BEGIN 
	SELECT @ErrCode = 101, @ErrMsg = 'The upline is not enable number game.'
	RETURN
END

-----Check conditon
IF @isEnable = 1 
BEGIN 	

	if 	@minbet < 0	or @maxbet < 0 or @maxpermatch < 0 or (@minbet = 0 AND @maxbet > 0) or (@minbet > 0 AND @maxbet = 0)
	BEGIN
		Select @ErrMsg = 'Wrong Min bet/ Max bet/ Max per match (for Number game).',
			   @ErrCode = 102
		return
	END

	if @maxperball < 0
	begin
		Select @ErrMsg = 'Wrong Max Per Ball (Number Game).',
			   @ErrCode = 103
		return
	end


	if (@minbet <> 0 and @maxbet <> 0 and @minbet > @maxbet) 
	or (@maxbet <> 0 and @maxpermatch <> 0 and @maxbet > @maxpermatch)
	or (@minbet <> 0 and @maxpermatch <> 0 and @minbet > @maxpermatch)
	BEGIN
		SELECT @ErrMsg = @UserName + ': min bet must be less than max bet and max bet must be less than max bet per match (for Number Game)', 
			   @ErrCode = 104
		return
	END

 IF @Roleid < 4
 BEGIN 
	--check upline condition
	SELECT		@MaxMaxPerMatch = isnull(Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0),
				@MaxMaxperball = isnull(Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),0)
	FROM		custinfo cs WITH (NOLOCK) 
	INNER JOIN	custinfo as ci WITH (NOLOCK) 
			ON	(cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE		ci.custid = @custid


	SELECT 	@MinMinBet = ISNULL(Max(case when cs.MinBet = 0 then NULL else cs.MinBet end), 0), 
			@MaxMaxBet = ISNULL(Min(case when cs.MaxBet = 0 then NULL else cs.MaxBet end),0)
	FROM 	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN	custinfo as ci WITH (NOLOCK) 
			ON (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
				and cs.sporttype=161
	WHERE		ci.custid = @CustID
	
	

	if (@MaxMaxBet > 0 and @maxbet > 0 and @maxbet > @MaxMaxBet)
	BEGIN
		SELECT @ErrMsg = @UserName  + ': max bet must be equal to or less than Upline max bet (for Number Game)'												
									+ ' (' + convert(varchar(20), @MaxMaxBet) + ').', 
			   @ErrCode = 105	
		return
	END
	
	if (@MaxMaxPerMatch > 0 and @maxpermatch > 0 and @maxpermatch > @MaxMaxPerMatch)
	BEGIN
		SELECT  @ErrMsg = @UserName  + ': Max Per Match must be equal to or less than Upline Max Per Match (for Number Game)'
									 + ' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', 
				@ErrCode = 106	
		return
	END
	
	if (@MinMinBet > 0 and @minbet > 0 and @minbet < @MinMinBet)
	BEGIN
		SELECT  @ErrMsg = @UserName + ': min bet must be equal to or greater than Upline min bet (for Number Game)'												
									+ ' (' + convert(varchar(20), @MinMinBet) + ').', 
				@ErrCode = 107	
		return
	END
 
	if @MaxMaxPerBall > 0 and @maxperball > @MaxMaxPerBall 
	begin
		SELECT	@ErrMsg = @UserName + ': Max Per Ball must be less than or equal to Upline Max Per Ball (Number Game).'
									+ ' (' + CONVERT(VARCHAR(20), @MaxMaxPerBall) + ').', 
				@ErrCode = 108				
		return
	END 
 END 
END


------------------------------------------
EXEC dbo.Acc_CustSetting3rd_02 
	@custid = @custid,
	@roleid = @roleid,
	@isEnable = @isEnable,
	@minbet = @minbet,
	@maxbet = @maxbet,
	@maxperball = @maxperball,
	@maxpermatch = @maxpermatch,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT


---Write log 

SET @EndRun = getdate()
SET @Duration  = datediff (millisecond,@StartRun,@EndRun)

/*1133	Update enable/disable number game status for wholeline*/
SELECT  @LogSPData = '<Acc_CustomerUpdNGEnableBetSetting Username="' + convert (VARCHAR(50), @username) + '" ' +
		'RoleID="' + convert (VARCHAR(2), @RoleID) + '" ' +
		'isEnable="' + convert (VARCHAR(2), @isEnable) + '" ' +
		'IP="' + coalesce (cast (@IP AS VARCHAR(15)), space (1)) + '" ' +
		'Userid="' + coalesce (cast (@UserID AS VARCHAR(15)), space (1)) + '" ' +
		'ErrCode="' + coalesce (cast (@ErrCode AS VARCHAR(10)), space (1)) + '" ' +
		'ErrMsg="' + + coalesce(cast(@ErrMsg as varchar(5000)),space(1))+  + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1133,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = NULL,
		@Duration = @Duration
END TRY
BEGIN CATCH
	SELECT  @LogSPData = '<Acc_CustomerUpdNGEnableBetSetting Username="' + convert (VARCHAR(50), @username) + '" ' +
		'RoleID="' + convert (VARCHAR(2), @RoleID) + '" ' +
		'isEnable="' + convert (VARCHAR(2), @isEnable) + '" ' +
		'IP="' + coalesce (cast (@IP AS VARCHAR(15)), space (1)) + '" ' +
		'Userid="' + coalesce (cast (@UserID AS VARCHAR(15)), space (1)) + '" ' +
		'ErrCode="' + coalesce (cast (ERROR_NUMBER() AS VARCHAR(10)), space (1)) + '" ' +
		'ErrMsg="' + + coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+  + '" />'

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1133,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = NULL,
		@Duration = @Duration
END CATCH

/*355  Update number game setting for wholeline*/
IF @isEnable = 1
BEGIN 
	SELECT  @LogSPData = '<Acc_CustomerUpdNGEnableBetSetting Username="' + convert (VARCHAR(50), @username) + '" ' +
			'RoleID="' + convert (VARCHAR(2), @RoleID) + '" ' +
			'MinBv161="' + convert (VARCHAR(50), @minbet) + '" ' +
			'MaxBv161="' + convert (VARCHAR(50), @maxbet) + '" ' +
			'MPMv161="' + convert (VARCHAR(50), @maxpermatch) + '" ' +
			'MPBv161="' + convert (VARCHAR(50), @maxperball) + '" ' +		
			'IP="' + coalesce (cast (@IP AS VARCHAR(15)), space (1)) + '" ' +
			'Userid="' + coalesce (cast (@UserID AS VARCHAR(50)), space (1)) + '" ' +
			'ErrCode="' + coalesce (cast (@ErrCode AS VARCHAR(50)), space (1)) + '" ' +
			'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 355,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = NULL,
			@Duration = @Duration
	END TRY
	BEGIN CATCH
		SELECT  @LogSPData = '<Acc_CustomerUpdNGEnableBetSetting Username="' + convert (VARCHAR(50), @username) + '" ' +
			'RoleID="' + convert (VARCHAR(2), @RoleID) + '" ' +
			'MinBv161="' + convert (VARCHAR(50), @minbet) + '" ' +
			'MaxBv161="' + convert (VARCHAR(50), @maxbet) + '" ' +
			'MPMv161="' + convert (VARCHAR(50), @maxpermatch) + '" ' +
			'MPBv161="' + convert (VARCHAR(50), @maxperball) + '" ' +		
			'IP="' + coalesce (cast (@IP AS VARCHAR(15)), space (1)) + '" ' +
			'Userid="' + coalesce (cast (@UserID AS VARCHAR(50)), space (1)) + '" ' +
			'ErrCode="' + coalesce (cast (ERROR_NUMBER() AS VARCHAR(50)), space (1)) + '" ' +
			'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1))+ '" />'
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 355,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = NULL,
			@Duration = @Duration		
	END CATCH
END



	 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdNGEnableBetSetting] TO [bodbAdminNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdNGEnableBetSetting] TO [vnteam]
GO