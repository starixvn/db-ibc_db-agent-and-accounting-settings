ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] 
	@custid		INT,	
		
	@v162spositiontaking_1101 SMALLMONEY,
	@isauto_v162spositiontaking_1101 BIT,
	@auto_v162spositiontaking_1101 SMALLMONEY,
	
	@v162UpdatePositiontaking_1101 BIT =1,
	@v162UpdateAutoPositiontaking_1101 BIT =1,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 12Jan2012
		Task: Super edit PT on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120928@Lukas: do not check max PT of super SLAM (8156203) - special requirement
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20130516@Lukas: allow PT = 100%
			- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
		Parameters Explanation:
	*/
SET NOCOUNT ON 


DECLARE @startRun DATETIME
DECLARE @endRun DATETIME
DECLARE @duration INT
SET @startRun = GETDATE()
	
DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000),
		@srecommend INT, @mrecommend INT, @recommend INT, @username VARCHAR(50), @ErrType NVARCHAR(4000),
		@v162spositiontaking_1101_max SMALLMONEY, @v162mpositiontaking_1101 SMALLMONEY, @v162apositiontaking_1101 SMALLMONEY,
		@db_v162spositiontaking_1101 SMALLMONEY, @db_isauto_v162spositiontaking_1101 BIT, @db_auto_v162spositiontaking_1101 SMALLMONEY
	


SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@roleid = @roleid OUTPUT
	IF (@roleid = 0) RETURN
---------------------------

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username 
from customer with (NOLOCK) 
where custid = @custid

SELECT @v162spositiontaking_1101_max = spositiontaking --s4
FROM CustSettingGame cs WITH(NOLOCK) 
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101 

SELECT @v162mpositiontaking_1101 = mpositiontaking, @v162apositiontaking_1101 = apositiontaking,
	@db_v162spositiontaking_1101 = spositiontaking, @db_isauto_v162spositiontaking_1101 = isautopositiontaking, @db_auto_v162spositiontaking_1101 = autopositiontaking
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 

IF @v162UpdatePositiontaking_1101 = 1
BEGIN
	IF @v162spositiontaking_1101 < 0 OR ( @v162spositiontaking_1101 > 1 AND @srecommend <> 8156203)
	BEGIN			
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								WHEN 'E' THEN 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						END, @ErrCode_Cur = 100	
			
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
					
			RETURN
	END	
	
	select @ErrType = ''
	
	SELECT @ErrType = @ErrType + 'Max: ' + CAST(@v162spositiontaking_1101_max AS VARCHAR(10)) WHERE @v162spositiontaking_1101 > @v162spositiontaking_1101_max
		
	IF @ErrType <> ''
	BEGIN 
		Select @ErrMsg_Cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							end, @ErrCode_Cur = 101
		
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
					
		RETURN	
	END
	
	select @ErrType = ''
	SELECT @ErrType = @ErrType + 'Max: ' + CAST(@v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 AS VARCHAR(10)) WHERE @v162spositiontaking_1101 + @v162mpositiontaking_1101 + @v162apositiontaking_1101 > @v162spositiontaking_1101_max
	
	IF @ErrType <> ''
	BEGIN 
		Select @ErrMsg_Cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							end, @ErrCode_Cur = 102
		
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
					
		RETURN	
	END
	
	--SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 + @v162mpositiontaking_1101 + @v162apositiontaking_1101 > @v162spositiontaking_1101_max THEN @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 ELSE @v162spositiontaking_1101 END
	
	--SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 < 0 THEN 0 ELSE @v162spositiontaking_1101 END
END
 
IF @v162UpdateAutoPositiontaking_1101 = 1
BEGIN

	SELECT @ErrType = ''
	
	SELECT @ErrType	= @ErrType + 'Max: ' + CAST(@v162spositiontaking_1101_max AS VARCHAR(10)) WHERE @auto_v162spositiontaking_1101 > @v162spositiontaking_1101_max
	
	IF @ErrType <>''
	BEGIN		
		SELECT @ErrMsg_Cur = 	@UserName + ': '+
				CASE @Language when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END, @ErrCode_Cur = 201		
		
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
					
		RETURN	
	END
END


IF @v162UpdatePositiontaking_1101 = 1
BEGIN
--don't update s1 for member under master was set i3=1(normal)
	UPDATE cs
	SET cs.spositiontaking = @v162spositiontaking_1101
	FROM CustSettingGame cs 
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101 AND mcs.isautopositiontaking = 0
END

IF @v162UpdateAutoPositiontaking_1101 = 1
BEGIN
--Update auto PT
	UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
	SET isautopositiontaking = @isauto_v162spositiontaking_1101, autopositiontaking = @auto_v162spositiontaking_1101
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 
	
	if @@Error <> 0
	BEGIN
		SELECT @ErrMsg_Cur =  @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Error updating auto position taking'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
								END, @ErrCode_Cur = 202	
		
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
					
		RETURN	
	END
END

EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'LiveCasino'	
---EXEC dbo.Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

DECLARE @LogSPData VARCHAR(MAX),
		@TrackingValueDB VARCHAR(5000)
		
SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162spositiontaking_1101 = "' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162spositiontaking_1101 = "' + COALESCE(CAST(@db_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@db_isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@db_auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 


SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 428,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_SAg Custid = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162spositiontaking_1101 = "' + COALESCE(CAST(@v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'isauto_v162spositiontaking_1101 = "' + COALESCE(CAST(@isauto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'auto_v162spositiontaking_1101 ="' + COALESCE(CAST(@auto_v162spositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162UpdatePositiontaking_1101 ="' + COALESCE(CAST(@v162UpdatePositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'v162UpdateAutoPositiontaking_1101 ="' + COALESCE(CAST(@v162UpdateAutoPositiontaking_1101 AS VARCHAR(10)), SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 428,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	

SELECT @ErrCode = '-103' + char(7)


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg]  TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_SAg] TO [bodbDownlineNet]