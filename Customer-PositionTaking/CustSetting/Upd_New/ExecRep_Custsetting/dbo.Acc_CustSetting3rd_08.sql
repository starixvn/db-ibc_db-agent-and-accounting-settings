  ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_08]
	@custid INT = 0,
	@mode VARCHAR(50) ='',
	@roleid INT,
	--------------------------------------------------------------------
	--super update pt on member
	--number game
	@v161spositiontaking_81 SMALLMONEY = 0,
	@v161spositiontaking_83 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87 SMALLMONEY = 0,
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0,
	
	--horse racing
	@v151spositiontaking_31 SMALLMONEY = 0,
	@v151spositiontaking_32 SMALLMONEY = 0,
	@v151spositiontaking_41 SMALLMONEY = 0,
	@v151spositiontaking_42 SMALLMONEY = 0,
	@v151spositiontaking_51 SMALLMONEY = 0,
	@v151spositiontaking_52 SMALLMONEY = 0,
	@v152spositiontaking_41 SMALLMONEY = 0,
	@v152spositiontaking_42 SMALLMONEY = 0,
	@v152spositiontaking_51 SMALLMONEY = 0,
	@v152spositiontaking_52 SMALLMONEY = 0,
	@v153spositiontaking_51 SMALLMONEY = 0,
	@v153spositiontaking_52 SMALLMONEY = 0,
	
	--------------------------------------------------------------------
	---master update pt on member
	--number game
	@v161mpositiontaking_81 SMALLMONEY  = 0,
	@v161mpositiontaking_83 SMALLMONEY  = 0,
	@v161mpositiontaking_86 SMALLMONEY  = 0,
	@v161mpositiontaking_88 SMALLMONEY = 0,
	@v161mlivepositiontaking_85 SMALLMONEY  = 0,
	@v161mlivepositiontaking_86 SMALLMONEY  = 0,
	@v161mlivepositiontaking_87 SMALLMONEY  = 0,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY = 0,
	
	--horse racing
	@v151mpositiontaking_31 smallmoney  = 0,
	@v151mpositiontaking_32 smallmoney  = 0,
	@v151mpositiontaking_41 smallmoney  = 0,
	@v151mpositiontaking_42 smallmoney  = 0,
	@v151mpositiontaking_51 smallmoney = 0,
	@v151mpositiontaking_52 smallmoney = 0,
	@v152mpositiontaking_41 smallmoney = 0,
	@v152mpositiontaking_42 smallmoney = 0,
	@v152mpositiontaking_51 smallmoney = 0,
	@v152mpositiontaking_52 smallmoney = 0,
	@v153mpositiontaking_51 smallmoney = 0,
	@v153mpositiontaking_52 smallmoney = 0,
	
	--------------------------------------------------------------------
	--agent update pt on member
	--number game
	@v161apositiontaking_81 smallmoney = 0, 
	@v161apositiontaking_83 smallmoney = 0, 	
	@v161apositiontaking_86 smallmoney = 0, 
	@v161apositiontaking_88 smallmoney = 0, 
	@v161alivepositiontaking_85 smallmoney = 0,
	@v161alivepositiontaking_86 smallmoney = 0,
	@v161alivepositiontaking_87 smallmoney = 0,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,
	
	--horse racing	
	@v151apositiontaking_31 SMALLMONEY = 0,
	@v151apositiontaking_32 SMALLMONEY = 0,
	@v151apositiontaking_41 SMALLMONEY = 0,
	@v151apositiontaking_42 SMALLMONEY = 0,
	@v151apositiontaking_51 SMALLMONEY = 0,
	@v151apositiontaking_52 SMALLMONEY = 0,
	@v152apositiontaking_41 SMALLMONEY = 0,
	@v152apositiontaking_42 SMALLMONEY = 0,
	@v152apositiontaking_51 SMALLMONEY = 0,
	@v152apositiontaking_52 SMALLMONEY = 0,
	@v153apositiontaking_51 SMALLMONEY = 0,
	@v153apositiontaking_52 SMALLMONEY = 0,
			
	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1
	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBTXN/bodb02
		Original versions: Acc_CustomerUpdMember_Super
					Acc_CustomerUpdMember_Master
					Acc_CustomerUpdMember_PositionTaking
					Acc_CustomerUpdMemberHR_SAg
					Acc_CustomerUpdMemberHR_MAg
					Acc_CustomerUpdMemberHR_PositionTaking
					
		Revision:
			- 20131104@Johnson: Add ive casino, racing
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
		ELSE IF @mode = 'horse'
		BEGIN
			update cs with (ROWLOCK, UPDLOCK)
			set
				cs.spositiontaking = case when @UpdateMultiple = 1 
											AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											then cs.spositiontaking 
										else case	
												when cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_31 
												when cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_32 
												when cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_41 
												when cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_42 
												when cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_51 
												when cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_52 
												when cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_41 
												when cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_42 
												when cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_51 
												when cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_52 
												when cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_51 
												when cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_52 
											else cs.spositiontaking end
										end
			from CustSetting3rd cs  inner join customer c (nolock) on cs.custid = c.custid
				inner join CustSetting3rd scs (nolock) on scs.custid = c.mrecommend and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
			where cs.custid=@custid and cs.sporttype in (151,152,153) and c.roleid = 1 and scs.isautopositiontaking = 0

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
		ELSE IF @mode = 'horse'
		BEGIN
			UPDATE cs WITH (ROWLOCK, UPDLOCK)
			SET
				mpositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))	
											THEN cs.mpositiontaking	
										ELSE CASE	WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
												WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
												WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
												WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
												WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
												WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
												WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
												WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
												WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
												ELSE cs.mpositiontaking END
										END,
				spositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN cs.spositiontaking 
										ELSE CASE WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
												WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
												WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
												WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
												WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
												WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
												WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
												WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
												WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
												WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
												ELSE cs.spositiontaking END
										END
			FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
				INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
			WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 AND cs.sporttype in (151,152,153)

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
		ELSE IF @mode = 'horse'
		BEGIN						
			UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
			SET
				apositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN apositiontaking	
										ELSE CASE WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_31 
												WHEN bettype = 32 and sporttype = 151  and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_32 
												WHEN bettype = 41 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_41 
												WHEN bettype = 42 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_42 
												WHEN bettype = 51 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_51 
												WHEN bettype = 52 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_52 
												WHEN bettype = 41 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_41 
												WHEN bettype = 42 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_42 
												WHEN bettype = 51 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_51 
												WHEN bettype = 52 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_52 
												WHEN bettype = 51 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_51 
												WHEN bettype = 52 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_52 
												ELSE apositiontaking END END,
				--Auto Master PT
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				mpositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN mpositiontaking
										ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
													WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
													WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
													WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
													WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
													WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
													WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
													WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
													WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
													WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
													ELSE mpositiontaking END END,	
								  
				-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				spositiontaking = CASE WHEN @UpdateMultiple = 1 
											AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
												OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
												OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
											THEN spositiontaking
										ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
													WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
													WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
													WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
													WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51
													WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
													WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
													WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
													WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
													WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
													WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
													WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
													ELSE spositiontaking END
										END
			WHERE custid=@custid and sporttype BETWEEN 151 AND 153
		END
	END
END
	
	