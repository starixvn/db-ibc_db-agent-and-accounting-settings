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
	DB: DBTRANS.bodb02

	Revisions:	
 
	Param's Explanation:
 
*/  
SET NOCOUNT ON

DECLARE @isDisable BIT
SELECT @isDisable = CASE WHEN @isEnable = 1 THEN 0 ELSE 1 END

IF NOT exists (select TOP 1 1 from dbo.sysobjects where name = 'Custinfo') RETURN  
 
IF @roleid = 1 -- update for himself only
BEGIN  
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)  
	SET		disablenumber = @isDisable,		
		 	maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
		 	maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	custid = @custid

	IF @@ERROR > 0 
	BEGIN
		SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
				@ErrCode = 110
		RETURN
	END
	
	
	IF @isDisable = 0
	BEGIN
		IF NOT exists (select TOP 1 1 from dbo.sysobjects where name = 'custsetting3rd') RETURN

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
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	recommend = @custid

	IF @@ERROR > 0 
		BEGIN
			SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
					@ErrCode = 112
			RETURN
		END	

	IF @isDisable = 0
	BEGIN
		IF NOT exists (select TOP 1 1 from dbo.sysobjects where name = 'custsetting3rd') RETURN

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
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	mrecommend = @custid

	IF @@ERROR > 0 
		BEGIN
			SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
					@ErrCode = 114
			RETURN
		END	

	IF @isDisable = 0
	BEGIN
		IF NOT exists (select TOP 1 1 from dbo.sysobjects where name = 'custsetting3rd') RETURN

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
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	srecommend = @custid

		IF @@ERROR > 0 
			BEGIN
				SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
						@ErrCode = 116
				RETURN
			END	

	IF @isDisable = 0
	BEGIN
		IF NOT exists (select TOP 1 1 from dbo.sysobjects where name = 'custsetting3rd') RETURN

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
GRANT EXECUTE ON [dbo].[Acc_CustSetting3rd_02] TO [bodbAdminNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting3rd_02] TO [vnteam]
GO