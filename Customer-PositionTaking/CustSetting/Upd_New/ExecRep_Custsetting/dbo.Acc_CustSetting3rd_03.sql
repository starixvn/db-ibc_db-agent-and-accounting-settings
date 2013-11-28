ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_03]  
	@custid    INT,  
	@roleid    TINYINT,
	@sporttype smallint,
	@bettype SMALLINT,  
	@minbet   MONEY,  
	@maxbet   MONEY,  
	@maxpermatch MONEY,  
	@ErrCode   INT = 0 OUTPUT,  
	@ErrMsg    NVARCHAR(200) = '' OUTPUT  
AS  
/*  

Created: Johnson  
Date: 2012-09-19  
Task: exec replicate to update status and bet setting virtual sports for downlines  
DB: DBTXN/CustDB  

Revisions:  
	- 20121203@Scott : update status and bet setting for virtual tennis by setting's virtual soccer  
	- 20121211@Scott : don't update status virtual sport
	- 20120221@Johnson: add virtual horse racing setting (sporttype :181)
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)						
	
Parameter's Explanation:  

*/

SET NOCOUNT ON  

IF @roleid = 4  
BEGIN  
	
	IF @sporttype = 180 
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch180 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 181
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch181 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 182
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch182 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 184
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch184 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 186 
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch186 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 301  
		RETURN  
	END  
 
	UPDATE cs  
		SET minbet = @minbet,  
			maxbet = @maxbet  
	FROM custsetting3rd cs WITH(UPDLOCK,ROWLOCK)  
		INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
	WHERE ci.srecommend = @custid    
	 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 302  
		RETURN  
	END  
END  

ELSE IF @roleid = 3  
BEGIN

	IF @sporttype = 180 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch180 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 181 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch181 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 182
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch182 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 184
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch184 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 186 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch186 = @maxpermatch 
		WHERE mrecommend = @custid  
		
	END 
 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 303  
		RETURN  
	END  
 
	UPDATE cs  
		SET minbet = @minbet,  
			maxbet = @maxbet
	FROM custsetting3rd cs WITH(UPDLOCK,ROWLOCK)  
		INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
	WHERE ci.mrecommend = @custid    
	 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT @ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 304	
		RETURN  
	END  
END 
 
ELSE IF @roleid = 2  
BEGIN  

	IF @sporttype = 180 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch180 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 181 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch181 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 182
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch182 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 184
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch184 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 186 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch186 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	
	
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 305  
		RETURN  
	END  
 
	UPDATE cs  
		SET minbet = @minbet,  
			maxbet = @maxbet  
	FROM custsetting3rd cs WITH(UPDLOCK,ROWLOCK)  
			INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
	WHERE ci.recommend = @custid    
 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 306  
		RETURN  
	END  
END  

GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_03] TO [bodbAdminNet]

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_03] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_03] TO [vnteam] AS [dbo]