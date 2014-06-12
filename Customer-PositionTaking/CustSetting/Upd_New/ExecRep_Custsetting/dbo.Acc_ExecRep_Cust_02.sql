USE [CustDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_02]
	@IDs VARCHAR(MAX),
	@SBComm DECIMAL(9,8) ,
	@NGComm DECIMAL(9,8)=0,	
	@RacingComm DECIMAL(9,8)=0,
	@LCComm DECIMAL(9,8)=0,
	@IsUpdateNG BIT = 0,
	@IsUpdateRacing BIT = 0,
	@IsUpdateLC BIT = 0
AS
/*
Created: 20120730@Henry
Task : Update Licensee's players commission
DB: DBCUST.CustDB
Original: 

Revisions:
	- 20131023@Hannah: offer Live Casino commission
	- 20140612@Victor: fix VARCHAR(4000) issue
   
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
    
• @ErrMsg: Error description.
*/

IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('custinfo', 'Dep_CustSetting', 'Dep_CustSetting3rd') AND (type = 'U' OR type = 'V')) <3 
	OR ((SELECT COUNT(1) FROM sysobjects WHERE name IN ('custinfo', 'CustSettingGame') AND (type = 'U' OR type = 'V')) < 2) 
	RETURN

DECLARE @res AS TABLE (custid INT)
DECLARE @splitter CHAR(1), @string VARCHAR(MAX)

SELECT @splitter = ',', @string = @IDs

IF SUBSTRING (@string, LEN (@string), 1) <> @splitter
	  SET @string= @string+@splitter

DECLARE @START INT, @word VARCHAR(MAX), @CHARINDEX INT, @i INT
SET @i=1
SET @START=1
SET @CHARINDEX= CHARINDEX( @splitter, @string, @START)
WHILE (@CHARINDEX <> 0)BEGIN
	SET @word= SUBSTRING( @string, @START, @CHARINDEX - @START)
	SET @START= @CHARINDEX +1
	SET @CHARINDEX= CHARINDEX( @splitter, @string, @START)
	INSERT INTO @res  VALUES(CAST(@word AS INT))
	SET @i=@i+1
END	

UPDATE [dbo].Dep_CustSetting WITH (ROWLOCK, UPDLOCK)
SET playerdiscount = @SBComm 
WHERE custid IN (SELECT CustID FROM @res)  
	AND playerdiscount <> @SBComm  	
	
IF (@IsUpdateNG=1) -- update Number Game
BEGIN	
	UPDATE [dbo].Dep_CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET playerdiscount = @NGComm 
	WHERE custid IN (SELECT CustID FROM @res)  
		AND playerdiscount <> @NGComm
		AND sporttype = 161  	
END

IF (@IsUpdateRacing=1) --update racing
BEGIN
	UPDATE [dbo].Dep_CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET playerdiscount = @RacingComm 
	WHERE custid IN (SELECT CustID FROM @res)
		AND playerdiscount <> @RacingComm
		AND sporttype IN (151,152,153)
END		
IF (@IsUpdateLC=1) -- update Live Casino
BEGIN	
	UPDATE [dbo].CustSettingGame WITH (ROWLOCK, UPDLOCK)
	SET playerdiscount = @LCComm 
	WHERE custid IN (SELECT CustID FROM @res)  
		AND playerdiscount <> @LCComm
		AND sporttype = 162  	
END

