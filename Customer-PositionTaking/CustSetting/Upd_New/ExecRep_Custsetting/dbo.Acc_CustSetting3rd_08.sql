  ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_08]
	@custid INT = 0,
	@mode VARCHAR(50) ='',
	
	@v161mpositiontaking_81 SMALLMONEY  = 0,
	@v161mpositiontaking_83 SMALLMONEY  = 0,
	@v161mpositiontaking_86 SMALLMONEY  = 0,
	@v161mpositiontaking_88 SMALLMONEY = 0,
	@v161mlivepositiontaking_85 SMALLMONEY  = 0,
	@v161mlivepositiontaking_86 SMALLMONEY  = 0,
	@v161mlivepositiontaking_87 SMALLMONEY  = 0,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY = 0,
	
	@v161spositiontaking_81 SMALLMONEY = 0,
	@v161spositiontaking_83 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87 SMALLMONEY = 0,
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBTXN/bodb02
		
		Revision:
		
		Parameter's Explanation:
	*/ 
BEGIN
SET NOCOUNT ON
	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN ('custinfo', 'CustSetting3rd', 'CustOverride3rd')
			AND xtype = 'U'

	if @IsExistTables <> 3 RETURN
	
	IF @mode = 'number'
	BEGIN
		--don't update m1,s1 for member under agent was set im2=1
		UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
		SET
			mpositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype	WHEN 81 THEN @v161mpositiontaking_81 
																					WHEN 83 THEN @v161mpositiontaking_83 
																					WHEN 86 THEN @v161mpositiontaking_86 
																					WHEN 88 THEN @v161mpositiontaking_88 																			
																	ELSE 0 END					
								ELSE cs3.mpositiontaking END,

			spositiontaking =  CASE cs3.sporttype WHEN 161 THEN CASE cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																				WHEN 83 THEN @v161spositiontaking_83 
																				WHEN 86 THEN @v161spositiontaking_86 
																				WHEN 88 THEN @v161spositiontaking_88 																		
																ELSE 0 END					
								ELSE cs3.spositiontaking END
		FROM Custsetting3rd cs3 INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
			INNER JOIN Custsetting3rd acs3 WITH(NOLOCK) ON acs3.custid = c.recommend AND cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
		WHERE c.custid=@custid AND c.roleid = 1 AND acs3.isautompositiontaking = 0 
		
		--don't update m1,s1 for member under agent was set im2=1(live)
		UPDATE cs3 WITH (ROWLOCK, UPDLOCK)
		SET
			mlivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161mlivepositiontaking_85 WHEN 86 THEN @v161mlivepositiontaking_86 WHEN 87 THEN @v161mlivepositiontaking_87 WHEN 89 THEN @v161mlivepositiontaking_89 WHEN 90 THEN @v161mlivepositiontaking_90 ELSE cs3.mlivepositiontaking END ELSE cs3.mlivepositiontaking END,
			slivepositiontaking = CASE cs3.sporttype 	WHEN 161 THEN CASE cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 WHEN 86 THEN @v161slivepositiontaking_86 WHEN 87 THEN @v161slivepositiontaking_87 WHEN 89 THEN @v161slivepositiontaking_89 WHEN 90 THEN @v161slivepositiontaking_90 ELSE cs3.slivepositiontaking END ELSE cs3.slivepositiontaking END
		FROM Custsetting3rd cs3 INNER JOIN custinfo c WITH(NOLOCK) ON cs3.custid = c.custid
			INNER JOIN Custsetting3rd acs3 WITH(NOLOCK) ON acs3.custid = c.recommend AND cs3.sporttype = acs3.sporttype AND cs3.bettype = acs3.bettype 
		WHERE c.custid=@custid AND c.roleid = 1 AND acs3.isautolivempositiontaking = 0 
	END		
END
	
	