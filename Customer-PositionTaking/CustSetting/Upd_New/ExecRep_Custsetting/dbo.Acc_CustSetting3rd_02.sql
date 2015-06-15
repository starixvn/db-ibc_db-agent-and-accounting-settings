ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_02]   
	@custid int,  
	@roleid int,  
	@isEnable bit = 0,
	@minbet money = 0,
	@maxbet money = 0,
	@maxperball money = 0,
	@maxpermatch money = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg varchar(500) = '' OUTPUT
AS  

/*  
	Created: 20111111@Sophia
	Task: enable/disable number game for whole line
	DB: DBCUST/CustDB

	Revisions:	
 	- 20150610@Daniel: 
	    + Improve medthod check table existing in subscribers	
	    + Separate custDB to new server DBCUST  
 
	Param's Explanation:
 
*/  
SET NOCOUNT ON

 if NOT(dbo.f_CheckRepTable('custinfo') = 1 
   AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
   )
 RETURN


DECLARE @isDisable BIT
SELECT @isDisable = CASE WHEN @isEnable = 1 THEN 0 ELSE 1 END
 
IF @roleid = 1 -- update for himself only
BEGIN  	
     EXEC [dbo].[Acc_ExecRep_Cust_11]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @isEnable = @isEnable,
	   @maxperball = @maxperball,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg
	
	IF @isDisable = 0
	BEGIN
		UPDATE	custsetting3rd WITH (ROWLOCK, UPDLOCK)  
		SET		minbet = @minbet,
				maxbet = @maxbet
		WHERE	custid = @custid and sporttype = 161

		IF @@ERROR > 0 
			BEGIN
				SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
						@ErrCode = 111
				RETURN
			END			
	END
END
ELSE IF @roleid = 2
BEGIN
     EXEC [dbo].[Acc_ExecRep_Cust_11]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @isEnable = @isEnable,
	   @maxperball = @maxperball,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg

	IF @isDisable = 0
	BEGIN
		UPDATE	custsetting3rd WITH (ROWLOCK, UPDLOCK)  
		SET		minbet = @minbet,
				maxbet = @maxbet
		WHERE	custid in (select custid from custinfo with(nolock) where recommend = @custid)
				and sporttype = 161

		IF @@ERROR > 0 
		BEGIN
			SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
					@ErrCode = 113
			RETURN
		END	

	END
END
ELSE IF @roleid = 3
BEGIN
     EXEC [dbo].[Acc_ExecRep_Cust_11]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @isEnable = @isEnable,
	   @maxperball = @maxperball,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg

	IF @isDisable = 0
	BEGIN

		UPDATE	custsetting3rd WITH (ROWLOCK, UPDLOCK)  
		SET		minbet = @minbet,
				maxbet = @maxbet
		WHERE	custid in (select custid from custinfo with(nolock) where mrecommend = @custid)
				and sporttype = 161

		IF @@ERROR > 0 
			BEGIN
				SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
						@ErrCode = 115
				RETURN
			END	
	END
END
ELSE IF @roleid = 4
BEGIN
     EXEC [dbo].[Acc_ExecRep_Cust_11]   
	   @custid = @custid,  
	   @roleid = @roleid,  
	   @isEnable = @isEnable,
	   @maxperball = @maxperball,
	   @maxpermatch = @maxpermatch,
	   @ErrCode = @ErrCode,
	   @ErrMsg = @ErrMsg

	IF @isDisable = 0
	BEGIN

		UPDATE	custsetting3rd WITH (ROWLOCK, UPDLOCK)  
		SET		minbet = @minbet,
				maxbet = @maxbet
		WHERE	custid in (select custid from custinfo with(nolock) where srecommend = @custid)
				and sporttype = 161

		IF @@ERROR > 0 
			BEGIN
				SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
						@ErrCode = 117
				RETURN
			END	
	END
END

	 


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_02] TO [bodbadminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_02] TO [vnteam] AS [dbo]