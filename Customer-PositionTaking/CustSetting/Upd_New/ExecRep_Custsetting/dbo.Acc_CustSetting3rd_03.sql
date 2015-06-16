ALTER PROCEDURE [Acc_CustSetting3rd_03]  
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
DB: DBCUST/CustDB  

Revisions:  
	- 20121203@Scott : update status and bet setting for virtual tennis by setting's virtual soccer  
	- 20121211@Scott : don't update status virtual sport
	- 20120221@Johnson: add virtual horse racing setting (sporttype :181)
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)	
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]					
	- 20150610@Daniel: 
	    + Improve medthod check table existing in subscribers	
	    + Separate custDB to new server DBCUST   
	
Parameter's Explanation:  

*/

SET NOCOUNT ON  

 IF NOT(dbo.f_CheckRepTable('custinfo') = 1 
   AND dbo.f_CheckRepTable('custsetting3rd') = 1 
   )
 RETURN


IF @roleid = 4  
BEGIN  
	
     EXEC [dbo].[Acc_ExecRep_Cust_12]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @sporttype = @sporttype,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg
 
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

     EXEC [dbo].[Acc_ExecRep_Cust_12]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @sporttype = @sporttype,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg
 
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

     EXEC [dbo].[Acc_ExecRep_Cust_12]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @sporttype = @sporttype,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg
 
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

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_03] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_03] TO [vnteam] AS [dbo]
