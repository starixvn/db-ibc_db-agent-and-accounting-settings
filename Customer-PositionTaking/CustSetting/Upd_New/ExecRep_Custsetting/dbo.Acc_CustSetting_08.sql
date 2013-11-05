ALTER PROCEDURE [dbo].[Acc_Custsetting_08]
	@custid INT = 0,
	@roleid INT,
		
	--super update pt on member	
	@spositiontaking_1 SMALLMONEY = 0,
	@spositiontaking_2 SMALLMONEY = 0,
	@spositiontaking_3 SMALLMONEY = 0,
	@spositiontaking_4 SMALLMONEY = 0,
	@spositiontaking_5 SMALLMONEY = 0,
	@spositiontaking_6 SMALLMONEY = 0,
	@spositiontaking_7 SMALLMONEY = 0,
	@spositiontaking_8 SMALLMONEY = 0,
	@spositiontaking_9 SMALLMONEY = 0,
	@spositiontaking_10 SMALLMONEY = 0,
	
	@slivepositiontaking_1 SMALLMONEY = 0,
	@slivepositiontaking_3 SMALLMONEY = 0,
	@slivepositiontaking_7 SMALLMONEY = 0,
	@slivepositiontaking_8 SMALLMONEY = 0,
	
	@v2spositiontaking_1 SMALLMONEY = 0,
	@v2spositiontaking_2 SMALLMONEY = 0,
	@v2spositiontaking_3 SMALLMONEY = 0,
	@v2spositiontaking_7 SMALLMONEY = 0,
	@v2spositiontaking_8 SMALLMONEY = 0,
--	@v2spositiontaking_9 SMALLMONEY = 0,
	@v2spositiontaking_20 SMALLMONEY = 0,

	@v3spositiontaking_1 SMALLMONEY = 0,
	@v3spositiontaking_2 SMALLMONEY = 0,
	@v3spositiontaking_3 SMALLMONEY = 0,
	@v3spositiontaking_20 SMALLMONEY = 0,

	@v5spositiontaking_1 SMALLMONEY = 0,
	@v5spositiontaking_2 SMALLMONEY = 0,
	@v5spositiontaking_3 SMALLMONEY = 0,
	@v5spositiontaking_20 SMALLMONEY = 0,

	@v8spositiontaking_1 SMALLMONEY = 0,
	@v8spositiontaking_3 SMALLMONEY = 0,
	@v8spositiontaking_20 SMALLMONEY = 0,

	@v10spositiontaking_1 SMALLMONEY = 0,
	@v10spositiontaking_2 SMALLMONEY = 0,
	@v10spositiontaking_3 SMALLMONEY = 0,
	@v10spositiontaking_20 SMALLMONEY = 0,

	@v11spositiontaking_1 SMALLMONEY = 0,
	@v11spositiontaking_20 SMALLMONEY = 0,

	@v99spositiontaking_1 SMALLMONEY = 0,
	@v99spositiontaking_2 SMALLMONEY = 0,
	@v99spositiontaking_3 SMALLMONEY = 0,
	@v99spositiontaking_20 SMALLMONEY = 0,

	-- mixed sports
	@v99spositiontaking_9 SMALLMONEY = 0,

	-- HR Fixed Odds
	@v154spositiontaking_20 SMALLMONEY = 0,
	
	--master update pt on member
	@mpositiontaking_1 SMALLMONEY = 0,
	@mpositiontaking_2 SMALLMONEY  = 0,
	@mpositiontaking_3 SMALLMONEY  = 0,
	@mpositiontaking_4 SMALLMONEY  = 0,
	@mpositiontaking_5 SMALLMONEY  = 0,
	@mpositiontaking_6 SMALLMONEY  = 0,
	@mpositiontaking_7 SMALLMONEY  = 0,
	@mpositiontaking_8 SMALLMONEY  = 0,
	@mpositiontaking_9 SMALLMONEY  = 0,
	@mpositiontaking_10 SMALLMONEY  = 0,
	@mlivepositiontaking_1 SMALLMONEY  = 0,
	@mlivepositiontaking_3 SMALLMONEY  = 0,
	@mlivepositiontaking_7 SMALLMONEY  = 0,
	@mlivepositiontaking_8 SMALLMONEY  = 0,
	
	@v2mpositiontaking_1 SMALLMONEY  = 0,
	@v2mpositiontaking_2 SMALLMONEY  = 0,
	@v2mpositiontaking_3 SMALLMONEY  = 0,
	@v2mpositiontaking_7 SMALLMONEY  = 0,
	@v2mpositiontaking_8 SMALLMONEY  = 0,
--	@v2mpositiontaking_9 SMALLMONEY  = 0,
	@v2mpositiontaking_20 SMALLMONEY  = 0,

	@v3mpositiontaking_1 SMALLMONEY  = 0,
	@v3mpositiontaking_2 SMALLMONEY  = 0,
	@v3mpositiontaking_3 SMALLMONEY  = 0,
	@v3mpositiontaking_20 SMALLMONEY  = 0,

	@v5mpositiontaking_1 SMALLMONEY  = 0,
	@v5mpositiontaking_2 SMALLMONEY  = 0,
	@v5mpositiontaking_3 SMALLMONEY  = 0,
	@v5mpositiontaking_20 SMALLMONEY  = 0,

	@v8mpositiontaking_1 SMALLMONEY  = 0,
	@v8mpositiontaking_3 SMALLMONEY  = 0,
	@v8mpositiontaking_20 SMALLMONEY  = 0,

	@v10mpositiontaking_1 SMALLMONEY  = 0,
	@v10mpositiontaking_2 SMALLMONEY  = 0,
	@v10mpositiontaking_3 SMALLMONEY  = 0,
	@v10mpositiontaking_20 SMALLMONEY  = 0,

	@v11mpositiontaking_1 SMALLMONEY  = 0,
	@v11mpositiontaking_20 SMALLMONEY  = 0,

	@v99mpositiontaking_1 SMALLMONEY  = 0,
	@v99mpositiontaking_2 SMALLMONEY  = 0,
	@v99mpositiontaking_3 SMALLMONEY  = 0,
	@v99mpositiontaking_20 SMALLMONEY  = 0,

	-- mixed sports
	@v99mpositiontaking_9 SMALLMONEY  = 0,
	
	-- HR Fixed Odds
	@v154mpositiontaking_20 SMALLMONEY = 0,

	---agent update pt on member
	@apositiontaking_1 SMALLMONEY = 0,
	@apositiontaking_2 SMALLMONEY = 0,
	@apositiontaking_3 SMALLMONEY = 0,
	@apositiontaking_4 SMALLMONEY = 0,
	@apositiontaking_5 SMALLMONEY = 0,
	@apositiontaking_6 SMALLMONEY = 0,
	@apositiontaking_7 SMALLMONEY = 0,
	@apositiontaking_8 SMALLMONEY = 0,
	@apositiontaking_9 SMALLMONEY = 0,
	@apositiontaking_10 SMALLMONEY = 0,
	
	@alivepositiontaking_1 SMALLMONEY = 0,
	@alivepositiontaking_3 SMALLMONEY = 0,
	@alivepositiontaking_7 SMALLMONEY = 0,
	@alivepositiontaking_8 SMALLMONEY = 0,
	
	@v2apositiontaking_1 SMALLMONEY = 0,
	@v2apositiontaking_2 SMALLMONEY = 0,
	@v2apositiontaking_3 SMALLMONEY = 0,
	@v2apositiontaking_7 SMALLMONEY = 0,
	@v2apositiontaking_8 SMALLMONEY = 0,
	--@v2apositiontaking_9 SMALLMONEY = 0,
	@v2apositiontaking_20 SMALLMONEY = 0,
	
	@v3apositiontaking_1 SMALLMONEY = 0,
	@v3apositiontaking_2 SMALLMONEY = 0,
	@v3apositiontaking_3 SMALLMONEY = 0,
	@v3apositiontaking_20 SMALLMONEY = 0,

	@v5apositiontaking_1 SMALLMONEY = 0,
	@v5apositiontaking_2 SMALLMONEY = 0,
	@v5apositiontaking_3 SMALLMONEY = 0,
	@v5apositiontaking_20 SMALLMONEY = 0,

	@v8apositiontaking_1 SMALLMONEY = 0,
	@v8apositiontaking_3 SMALLMONEY = 0,
	@v8apositiontaking_20 SMALLMONEY = 0,

	@v10apositiontaking_1 SMALLMONEY = 0,
	@v10apositiontaking_2 SMALLMONEY = 0,
	@v10apositiontaking_3 SMALLMONEY = 0,
	@v10apositiontaking_20 SMALLMONEY = 0,

	@v11apositiontaking_1 SMALLMONEY = 0,
	@v11apositiontaking_20 SMALLMONEY = 0,

	@v99apositiontaking_1 SMALLMONEY = 0,
	@v99apositiontaking_2 SMALLMONEY = 0,
	@v99apositiontaking_3 SMALLMONEY = 0,
	@v99apositiontaking_9 SMALLMONEY = 0,
	@v99apositiontaking_20 SMALLMONEY = 0,
	
	@v154apositiontaking_20 SMALLMONEY = 0,
	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontaking BIT = 1,
	@UpdatePositiontakingv2 BIT = 1,
	@UpdatePositiontakingv3 BIT = 1,
	@UpdatePositiontakingv5 BIT = 1,
	@UpdatePositiontakingv8 BIT = 1,
	@UpdatePositiontakingv10 BIT = 1,
	@UpdatePositiontakingv11 BIT = 1,
	@UpdatePositiontakingv99 BIT = 1,
	@UpdatePositiontakingv99MP BIT = 1,
	@UpdatePositiontakingv154 BIT = 1
	
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
			- 20131104@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
		Parameter's Explanation:
	*/ 
BEGIN
SET NOCOUNT ON

	DECLARE @IsExistTables tinyint
	SELECT @IsExistTables = COUNT(*) FROM dbo.sysobjects
	WHERE	name IN ('custinfo', 'CustSetting', 'CustOverride')
			AND xtype = 'U'

	if @IsExistTables <> 3 RETURN
	IF @roleid = 4
	BEGIN
		--don't update s1 for member under master was set i3=1(normal)
		UPDATE cs WITH (ROWLOCK, UPDLOCK)
		SET
			cs.spositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
										OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) 
										OR (cs.sporttype = 154 AND cs.bettype = 20 AND @UpdatePositiontakingv154 = 0) )) 
									THEN cs.spositiontaking 
							ELSE CASE cs.sporttype 	
									WHEN 1 THEN case cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
									WHEN 2 THEN case cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 /*WHEN 9 THEN @v2spositiontaking_9*/ WHEN 20 THEN @v2spositiontaking_20  ELSE 0 END
									WHEN 3 THEN case cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
									WHEN 5 THEN case cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
									WHEN 8 THEN case cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
									WHEN 10 THEN case cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
									WHEN 11 THEN case cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
									WHEN 99 THEN case cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9 WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
									WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END
									ELSE cs.spositiontaking END
							END
		FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
			INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
		WHERE cs.custid=@custid and c.roleid = 1 and scs.isautopositiontaking = 0
		
		--don't update s1 for member under master was set i3=1(live)
		UPDATE cs with (ROWLOCK, UPDLOCK)
		SET
			cs.slivepositiontaking = 
								CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
										OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
										)) 
									THEN cs.slivepositiontaking 		
								ELSE case cs.sporttype WHEN 1 THEN case cs.bettype 
																			WHEN 1 THEN @slivepositiontaking_1 
																			WHEN 3 THEN @slivepositiontaking_3 
																			WHEN 7 THEN @slivepositiontaking_7 
																			WHEN 8 THEN @slivepositiontaking_8 
																			ELSE cs.slivepositiontaking END 
															ELSE cs.slivepositiontaking END
								END
		FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
			INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
		where cs.custid=@custid and c.roleid = 1 and scs.isautolivepositiontaking = 0

	END
	ELSE IF @roleid = 3
	BEGIN
		--don't update m1,s1 for member under agent was set im2=1
		UPDATE cs WITH (ROWLOCK, UPDLOCK)
			SET
				mpositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
										OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0)
										OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
										)) 
								THEN
									cs.mpositiontaking		
							ELSE CASE cs.sporttype
						 		WHEN 1 THEN CASE cs.bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 ELSE 0 END
								WHEN 2 THEN CASE cs.bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 /*WHEN 9 THEN @v2mpositiontaking_9*/ WHEN 20 THEN @v2mpositiontaking_20 ELSE 0 END
								WHEN 3 THEN CASE cs.bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20 ELSE 0 END
								WHEN 5 THEN CASE cs.bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 ELSE 0 END
								WHEN 8 THEN CASE cs.bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20 ELSE 0 END
								WHEN 10 THEN CASE cs.bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20 ELSE 0 END
								WHEN 11 THEN CASE cs.bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20 ELSE 0 END
								WHEN 99 THEN CASE cs.bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 20 THEN @v99mpositiontaking_20 WHEN 9 THEN @v99mpositiontaking_9 ELSE 0 END

								WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END 
								ELSE cs.mpositiontaking END
							END,
				spositiontaking =  
							CASE WHEN (@UpdateMultiple = 1 
									AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
										OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
										OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
										OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
										OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
										OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
										OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
										OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
										OR (cs.sporttype = 154 AND @UpdatePositiontakingv154 = 0)
										OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) )) 
									THEN			
										cs.spositiontaking
								ELSE CASE cs.sporttype 
									WHEN 1 THEN CASE cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
									WHEN 2 THEN CASE cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 /*WHEN 9 THEN @v2spositiontaking_9*/ WHEN 20 THEN @v2spositiontaking_20 ELSE 0 END
									WHEN 3 THEN CASE cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
									WHEN 5 THEN CASE cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
									WHEN 8 THEN CASE cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
									WHEN 10 THEN CASE cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
									WHEN 11 THEN CASE cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
									WHEN 99 THEN CASE cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 20 THEN @v99spositiontaking_20 WHEN 9 THEN @v99spositiontaking_9 ELSE 0 END

									WHEN 154 then CASE cs.bettype WHEN 20 then @v154spositiontaking_20 ELSE 0 END 
									ELSE cs.spositiontaking END
								END
			FROM Custsetting cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
				INNER JOIN Custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
			WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 

		--don't update m1,s1 for member under agent was set im2=1(live)
		UPDATE cs WITH (ROWLOCK, UPDLOCK)
		SET
			mlivepositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
									OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0))) 
								THEN cs.mlivepositiontaking	
							ELSE CASE cs.sporttype 	
								WHEN 1 THEN CASE cs.bettype 
										WHEN 1 THEN @mlivepositiontaking_1 
										WHEN 3 THEN @mlivepositiontaking_3 
										WHEN 7 THEN @mlivepositiontaking_7 
										WHEN 8 THEN @mlivepositiontaking_8 
										ELSE cs.mlivepositiontaking 
										END ELSE cs.mlivepositiontaking END END,
			slivepositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0)
									OR (cs.sporttype=154 AND @UpdatePositiontakingv154 = 0) 
									)) 
								THEN cs.slivepositiontaking
							ELSE CASE cs.sporttype 	
								WHEN 1 THEN CASE cs.bettype 
										WHEN 1 THEN @slivepositiontaking_1 
										WHEN 3 THEN @slivepositiontaking_3 
										WHEN 7 THEN @slivepositiontaking_7 
										WHEN 8 THEN @slivepositiontaking_8 
										ELSE cs.slivepositiontaking END 
								ELSE cs.slivepositiontaking END END
		FROM Custsetting cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
			INNER JOIN Custsetting acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
		WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautolivempositiontaking = 0 
	END
	ELSE IF @roleid = 2
	BEGIN				
		UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
		SET
			apositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) )) THEN apositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @apositiontaking_1 WHEN 2 THEN @apositiontaking_2 WHEN 3 THEN @apositiontaking_3 WHEN 4 THEN @apositiontaking_4 WHEN 5 THEN @apositiontaking_5 WHEN 6 THEN @apositiontaking_6 WHEN 7 THEN @apositiontaking_7 WHEN 8 THEN @apositiontaking_8 WHEN 9 THEN @apositiontaking_9 WHEN 10 THEN @apositiontaking_10 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2apositiontaking_1 WHEN 2 THEN @v2apositiontaking_2 WHEN 3 THEN @v2apositiontaking_3 WHEN 7 THEN @v2apositiontaking_7 WHEN 8 THEN @v2apositiontaking_8 WHEN 20 THEN @v2apositiontaking_20 ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3apositiontaking_1 WHEN 2 THEN @v3apositiontaking_2 WHEN 3 THEN @v3apositiontaking_3 WHEN 20 THEN @v3apositiontaking_20 ELSE 0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5apositiontaking_1 WHEN 2 THEN @v5apositiontaking_2 WHEN 3 THEN @v5apositiontaking_3 WHEN 20 THEN @v5apositiontaking_20 ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8apositiontaking_1 WHEN 3 THEN @v8apositiontaking_3 WHEN 20 THEN @v8apositiontaking_20 ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10apositiontaking_1 WHEN 2 THEN @v10apositiontaking_2 WHEN 3 THEN @v10apositiontaking_3 WHEN 20 THEN @v10apositiontaking_20 ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11apositiontaking_1 WHEN 20 THEN @v11apositiontaking_20 ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99apositiontaking_1 WHEN 2 THEN @v99apositiontaking_2 WHEN 3 THEN @v99apositiontaking_3 WHEN 9 THEN @v99apositiontaking_9 WHEN 20 THEN @v99apositiontaking_20 ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154apositiontaking_20 ELSE 0 END					
							ELSE apositiontaking END END,
			alivepositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN alivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @alivepositiontaking_1 WHEN 3 THEN @alivepositiontaking_3 WHEN 7 THEN @alivepositiontaking_7 WHEN 8 THEN @alivepositiontaking_8 ELSE alivepositiontaking END ELSE alivepositiontaking END END,
			
			--Auto Master PT
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			mpositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) )) THEN mpositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 WHEN 20 THEN @v2mpositiontaking_20 ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20 ELSE 0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20 ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20 ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20 ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 9 THEN @v99mpositiontaking_9 WHEN 20 THEN @v99mpositiontaking_20 ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END																	
							ELSE mpositiontaking END END,
			mlivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN mlivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @mlivepositiontaking_1 WHEN 3 THEN @mlivepositiontaking_3 WHEN 7 THEN @mlivepositiontaking_7 WHEN 8 THEN @mlivepositiontaking_8 ELSE mlivepositiontaking END ELSE mlivepositiontaking END END,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
			spositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9  AND  @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9  AND  @UpdatePositiontakingv99MP = 0) )) THEN spositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
							WHEN 2 THEN CASE bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 WHEN 20 THEN @v2spositiontaking_20 ELSE 0 END
							WHEN 3 THEN CASE bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
							WHEN 5 THEN CASE bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
							WHEN 8 THEN CASE bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
							WHEN 10 THEN CASE bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
							WHEN 11 THEN CASE bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
							WHEN 99 THEN CASE bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9  WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
							WHEN 154 THEN CASE bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END									
							ELSE spositiontaking END END,
			slivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN slivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @slivepositiontaking_1 WHEN 3 THEN @slivepositiontaking_3 WHEN 7 THEN @slivepositiontaking_7 WHEN 8 THEN @slivepositiontaking_8 ELSE slivepositiontaking END ELSE slivepositiontaking END END
		WHERE custid=@custid
	END
END
