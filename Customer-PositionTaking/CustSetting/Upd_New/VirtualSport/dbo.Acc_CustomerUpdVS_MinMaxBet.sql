ALTER PROCEDURE [dbo].[Acc_CustomerUpdVS_MinMaxBet]  
 @custid   INT,  
 @sporttype SMALLINT,
 @bettype SMALLINT, 
 @UpdDownlinesVS  BIT = 0,  
 @minbet  MONEY = 0,  
 @maxbet  MONEY = 0,  
 @maxpermatch MONEY = 0,   
 @UserID   INT,  
 @Language  VARCHAR(2) = 'E',  
 @ErrCode  INT = 0 OUTPUT,  
 @ErrMsg   NVARCHAR(200) = '' OUTPUT,  
 @IP    VARCHAR(15)=''  
AS  
 /*  
  Created: Scott  
  Date: 2012-12-11  
  Task: Update minbet,maxbet,maxpermatch setting for virtual sports  
  DB: DBTXN/BODB02  
    
  Revisions:  
     - 20130220@Johnson: - add virtual horse racing setting (sporttype: 181)
						 - change linked server DB053 to DBAGE
						 - write log on DBTXN if DBLOG failure
  Parameters Explanation:  
 */   
SET NOCOUNT ON   
DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT,  
		@MinMinBet MONEY,  
		@MaxMaxBet MONEY,  
		@MaxMaxPerMatch MONEY,  
     
		@MinBet_old MONEY,  
		@MaxBet_old MONEY,  
		@MaxPerMatch_old MONEY,  
     
		@roleid TINYINT,  
		@srecommend INT,  
		@mrecommend INT,  
		@recommend INT,  
		@DisableUplineVS BIT  
   
SET @startRun = GETDATE()  
  
--Check disable user  
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output  
IF @ErrCode <>0 RETURN  
   
SELECT	@recommend = recommend,   
		@mrecommend = mrecommend,  
		@srecommend = srecommend,    
		@roleid = roleid  
FROM custinfo WITH(NOLOCK)  
WHERE custid = @custid  
   
  
--Check Allowed downlines during peak hour at weekend   
IF @UpdDownlinesVS = 1  
BEGIN  
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines @custid=@custid,  
       @roleid=@roleid,  
       @isExecRep=1,  
       @Language=@Language,  
       @ErrMsg=@ErrMsg output,  
       @ErrCode=@ErrCode output  
       
	IF @ErrCode <>0 RETURN  
END  
--END   
   
IF @roleid = 3  
BEGIN  
	
	SELECT	@MinMinBet = minbet,  
			@MaxMaxBet = maxbet  
	FROM custsetting3rd WITH(NOLOCK)  
	WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype

	SELECT @MaxMaxPerMatch = (case	when @sporttype = 180 then maxpermatch180  
									when @sporttype = 181 then maxpermatch181   
									when @sporttype = 186 then maxpermatch186 else 0 end )
	FROM custinfo WITH(NOLOCK)  
	WHERE custid = @srecommend  
END  
 
ELSE IF @roleid = 2  
BEGIN  
 
	SELECT	@MinMinBet = MAX(minbet),  
			@MaxMaxBet = MIN(maxbet)  
	FROM custsetting3rd WITH(NOLOCK)  
	WHERE custid IN (@srecommend, @mrecommend) AND sporttype = @sporttype AND bettype = @bettype  
    
	SELECT @MaxMaxPerMatch = MIN(CASE	WHEN @sporttype = 180 then maxpermatch180
										WHEN @sporttype = 181 then maxpermatch181
										WHEN @sporttype = 186 then maxpermatch186 else 0 end)  
	FROM custinfo WITH(NOLOCK)  
	WHERE custid IN (@srecommend,@mrecommend)  
	
END  
 
ELSE IF @roleid = 1  
BEGIN  
	SELECT	@MinMinBet = MAX(minbet),  
			@MaxMaxBet = MIN(maxbet)  
	FROM custsetting3rd WITH(NOLOCK)  
	WHERE custid IN (@srecommend, @mrecommend,@recommend) AND sporttype = @sporttype AND bettype = @bettype   
    
	SELECT @MaxMaxPerMatch = MIN(CASE	WHEN @sporttype = 180 then maxpermatch180
										WHEN @sporttype = 181 then maxpermatch181
										WHEN @sporttype = 186 then maxpermatch186 else 0 end)
	FROM custinfo WITH(NOLOCK)  
	WHERE custid IN (@srecommend,@mrecommend,@recommend)  
END  
   

IF @minbet < 0 OR @maxbet < 0 OR @maxpermatch < 0  
BEGIN  
	SELECT	@ErrMsg = 'Wrong Min bet/ Max bet/ Max per match.',  
			@ErrCode = 101  
	RETURN  
END  
   
IF (@minbet<>0 and @maxbet <> 0 and  @minbet>@maxbet)   
	or (@maxbet<> 0 and @maxpermatch <> 0 and @maxbet>@maxpermatch)   
	or (@minbet <> 0 and @maxpermatch <> 0 and @minbet>@maxpermatch)  
BEGIN  
	SELECT	@ErrMsg = 'Min bet must be less than max bet and max bet must be less than max bet per match!!!',  
			@ErrCode = 102  
	RETURN  
END  
   
IF @roleid < 4  
BEGIN  
	IF (@MinMinBet>0 and @MinBet>0 and @minbet<@MinMinBet)  
	BEGIN  
		SELECT	@ErrMsg = 'Min bet must be equal to or greater than upline min bet ' + convert(varchar(10),@MinMinBet),  
				@ErrCode = 103  
		RETURN  
	END  
    
	IF (@MaxMaxBet>0 and @MaxBet>0 and @maxbet>@MaxMaxBet)  
	BEGIN  
		SELECT	@ErrMsg = 'max bet must be equal to or less than upline max bet ' + convert(varchar(10),@MaxMaxBet),  
				@ErrCode = 104  
		RETURN  
	END  
    
	IF (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)  
	BEGIN  
		SELECT	@ErrMsg = 'Max Per Match must be equal to or less than Upline Max Per Match ' + convert(varchar(10),@MaxMaxPerMatch),  
				@ErrCode = 105  
		RETURN  
	END       
END    
   
SELECT	@MinBet_old = MinBet,  
		@MaxBet_old = MaxBet  
FROM custsetting3rd WITH(NOLOCK)  
WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype

SELECT @MaxPerMatch_Old = (CASE WHEN @sporttype = 180 then MaxPerMatch180 
								WHEN @sporttype = 181 then MaxPerMatch181
								WHEN @sporttype = 186 then MaxPermatch186 Else 0 End)
FROM custinfo WITH(NOLOCK)  
WHERE custid = @custid  


IF @sporttype =  180 
BEGIN
	UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
		SET maxpermatch180 = @maxpermatch			
	WHERE custid = @custid  
END	

IF @sporttype =  181 
BEGIN
	UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
		SET maxpermatch181 = @maxpermatch			
	WHERE custid = @custid  
END	

IF @sporttype =  186
BEGIN
	UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
		SET maxpermatch186 = @maxpermatch  
	WHERE custid = @custid  
END	


IF (@@ERROR <> 0)  
BEGIN     
	SELECT	@ErrMsg = 'Update process is unsuccessful.',  
			@ErrCode = 201  
	RETURN  
END  

UPDATE custsetting3rd WITH(UPDLOCK, ROWLOCK)  
	SET minbet = @minbet,  
		maxbet = @maxbet  
WHERE custid = @custid AND sporttype =@sporttype AND bettype =@bettype 

IF (@@ERROR <> 0)  
BEGIN     
	SELECT	@ErrMsg = 'Update process is unsuccessful.',  
			@ErrCode = 202  
	RETURN  
END  
  

IF @UpdDownlinesVS = 1 
BEGIN  

	EXEC Acc_CustSetting3rd_03  
		@custid    = @custid,  
		@roleid    = @roleid,  
		@sporttype = @sporttype,
		@bettype   = @bettype,
		@minbet    = @minbet,  
		@maxbet    = @maxbet,  
		@maxpermatch = @maxpermatch,  
		@ErrCode   = @ErrCode OUTPUT,  
		@ErrMsg    = @ErrMsg OUTPUT  


IF @ErrCode > 0  
	RETURN  
  
END  

DECLARE @LogSPData VARCHAR(MAX),@LogSPData_Old VARCHAR(2000)  


	Select @LogSPData = '<Acc_CustomerUpdVS_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		'Sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" '+  
		'Bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" '+  
		'UpdDownlinesVS="'+ coalesce(cast(@UpdDownlinesVS as varchar(50)),space(1)) + '" '+ 
		'Minbet="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" '+  
		'Maxbet="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" '+  
		'Maxpermatch="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" '+  
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  

	Select @LogSPData_old = '<Acc_CustomerUpdVS_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		'Sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" '+  
		'Bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" '+  
		'Minbet="'+ coalesce(cast(@minbet_old as varchar(50)),space(1)) + '" '+  
		'Maxbet="'+ coalesce(cast(@maxbet_old as varchar(50)),space(1)) + '" '+  
		'Maxpermatch="'+ coalesce(cast(@maxpermatch_old as varchar(50)),space(1)) + '" '+  
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	
	BEGIN TRY          
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			@UserID = @UserID,  
			@CustID = @CustID,  
			@ActionID = 374,  
			@TrackingValue = @LogSPData  ,		
			@TrackingValue2 = @LogSPData_Old,  
			@duration = @duration  
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdVS_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		'Sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" '+  
		'Bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" '+  
		'UpdDownlinesVS="'+ coalesce(cast(@UpdDownlinesVS as varchar(50)),space(1)) + '" '+ 
		'Minbet="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" '+  
		'Maxbet="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" '+  
		'Maxpermatch="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" '+  
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		'ErrMsg="'+ ERROR_MESSAGE() + '" ' +  
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" />' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			@UserID = @UserID,  
			@CustID = @CustID,  
			@ActionID = 374,  
			@TrackingValue = @LogSPData  ,		
			@TrackingValue2 = @LogSPData_Old,  
			@duration = @duration
	END CATCH

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdVS_MinMaxBet] TO [bodbAdminNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdVS_MinMaxBet] TO [vnteam]
GO
