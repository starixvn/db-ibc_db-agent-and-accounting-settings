  ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_08]
	@custid INT = 0,
	@mode VARCHAR(50) ='',
	@roleid INT,
	--super update pt on member
	@v161spositiontaking_81 SMALLMONEY = 0,
	@v161spositiontaking_83 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87 SMALLMONEY = 0,
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0,
	
	---master update pt on member
	@v161mpositiontaking_81 SMALLMONEY  = 0,
	@v161mpositiontaking_83 SMALLMONEY  = 0,
	@v161mpositiontaking_86 SMALLMONEY  = 0,
	@v161mpositiontaking_88 SMALLMONEY = 0,
	@v161mlivepositiontaking_85 SMALLMONEY  = 0,
	@v161mlivepositiontaking_86 SMALLMONEY  = 0,
	@v161mlivepositiontaking_87 SMALLMONEY  = 0,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY = 0,
	
	--agent update pt on member
	@v161apositiontaking_81 smallmoney = 0, 
	@v161apositiontaking_83 smallmoney = 0, 	
	@v161apositiontaking_86 smallmoney = 0, 
	@v161apositiontaking_88 smallmoney = 0, 
	@v161alivepositiontaking_85 smallmoney = 0,
	@v161alivepositiontaking_86 smallmoney = 0,
	@v161alivepositiontaking_87 smallmoney = 0,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0
	
	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBTXN/bodb02
		Original versions: Acc_CustomerUpdMember_Super
					Acc_CustomerUpdMember_Master
					Acc_CustomerUpdMember_PositionTaking
					
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
	
	IF @roleid = 4
	BEGIN
		IF @mode = 'number'
		BEGIN
			UPDATE cs3 with(rowlock,updlock)
			SET cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																						WHEN 83 THEN @v161spositiontaking_83
																						WHEN 86 THEN @v161spositiontaking_86
																						WHEN 88 THEN @v161spositiontaking_88
																						ELSE 0 END
														ELSE cs3.spositiontaking END
			from custsetting3rd cs3 INNER JOIN custinfo c with(nolock) on cs3.custid = c.custid
				 INNER JOIN custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
			where cs3.custid =@custid and c.roleid = 1 and mcs3.isautopositiontaking = 0	
		
			UPDATE cs3 with (ROWLOCK, UPDLOCK)
			set
				cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																							WHEN 86 THEN @v161slivepositiontaking_86 
																							WHEN 87 THEN @v161slivepositiontaking_87 
																							WHEN 89 THEN @v161slivepositiontaking_89
																							WHEN 90 THEN @v161slivepositiontaking_90
																							ELSE cs3.slivepositiontaking END 
															 ELSE cs3.slivepositiontaking END
			from custsetting3rd cs3 INNER JOIN custinfo c (nolock) on cs3.custid = c.custid
				INNER JOIN custsetting3rd mcs3 (nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
			where cs3.custid=@custid and c.roleid = 1 and mcs3.isautolivepositiontaking = 0		
		END
	END
	ELSE IF @roleid = 3
	BEGIN
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
	ELSE IF @roleid = 2
	BEGIN
		IF @mode = 'number'
		BEGIN
			UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
			SET 
				apositiontaking = CASE bettype 
								WHEN 81 then @v161apositiontaking_81
								WHEN 83 then @v161apositiontaking_83
								WHEN 86 then @v161apositiontaking_86
								WHEN 88 then @v161apositiontaking_88
								ELSE 0
								END,
				alivepositiontaking = CASE bettype
								WHEN 85 then @v161alivepositiontaking_85
								WHEN 86 then @v161alivepositiontaking_86
								WHEN 87 then @v161alivepositiontaking_87 
								WHEN 89 then @v161alivepositiontaking_89
								WHEN 90 then @v161alivepositiontaking_90
								ELSE 0
								END,
				mpositiontaking = CASE bettype 
								WHEN 81 then @v161mpositiontaking_81
								WHEN 83 then @v161mpositiontaking_83
								WHEN 86 then @v161mpositiontaking_86
								WHEN 88 then @v161mpositiontaking_88
								ELSE 0
								END, 
				mlivepositiontaking = CASE bettype
								WHEN 85 then @v161mlivepositiontaking_85
								WHEN 86 then @v161mlivepositiontaking_86
								WHEN 87 then @v161mlivepositiontaking_87 
								WHEN 89 then @v161mlivepositiontaking_89
								WHEN 90 then @v161mlivepositiontaking_90
								ELSE 0
								END,
				spositiontaking = CASE bettype 
								WHEN 81 then @v161spositiontaking_81
								WHEN 83 then @v161spositiontaking_83
								WHEN 86 then @v161spositiontaking_86
								WHEN 88 then @v161spositiontaking_88
								ELSE 0
								 END,
				slivepositiontaking = CASE bettype
								WHEN 85 then @v161slivepositiontaking_85
								WHEN 86 then @v161slivepositiontaking_86
								WHEN 87 then @v161slivepositiontaking_87 
								WHEN 89 then @v161slivepositiontaking_89
								WHEN 90 then @v161slivepositiontaking_90
								ELSE 0
								END			
			WHERE custid = @custid AND sporttype = 161
		END
	END
END
	
	