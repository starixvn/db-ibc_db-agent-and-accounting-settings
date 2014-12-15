 ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTUpd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	@updateallmembers	BIT = 0,
	@newMasterPT		SMALLINT = 0,	
	
	@SubAccID			INT = 0,
	@UserID				INT = 0,    
    @Language			VARCHAR(2) = 'E',
    @IP					VARCHAR(15)='',
    @ErrCode			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2014-12-09
		Task: Update pt on Agent
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" AgentMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" AgentMinPT="0"/>
				</ROOT>
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid			TINYINT			
			,@startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT			
			,@logSPData		VARCHAR(5000)
			,@logSPDataOld	VARCHAR(5000)
			,@AutoPT		VARCHAR(MAX)
			,@sports		VARCHAR(500)			
			,@xml			XML
	  SET @startRun = GETDATE()
			
	---------------------------
	-- ***Check Downline Belonging***
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
		RETURN
	--end
	
	---- Checking total downlines before UPDATEs 
    EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 2
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
    IF    @ErrCode <> 0 
		RETURN 
    ----------		
    
    IF @PT = '' RETURN 
    
    DECLARE @username VARCHAR(40), @srecommend INT, @mrecommend INT
    
    SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend         
	FROM custinfo with (NOLOCK)         
	WHERE CustID = @CustID 
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLINT,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLINT,
				AgentPT			SMALLINT,				
				AgentMinPT		SMALLINT
				)	
				
	-- For read xml
	DECLARE @DocHandler INT    
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @PT
	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				MasterPT,
				IsAutoMasterPT,
				AutoMasterPT,
				AgentPT,								
				AgentMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.MasterPT,
		Data.isAutoMasterPT,
		Data.AutoMasterPT,	
		Data.AgentPT,			
		Data.AgentMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType		SMALLINT,
		BetType			SMALLINT,
		IsLive			BIT,
		MasterPT		SMALLINT,
		IsAutoMasterPT	BIT,
		AutoMasterPT	SMALLINT,
		AgentPT			SMALLINT,			
		AgentMinPT		SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml	
	
	 --log old data
	SET @xml =(
		SELECT @custid AS '@ci'
				,f_GetSubUsername(@SubAccID) AS '@su'
				,@userid AS '@ui'
				,@language AS '@l'
				,@IP AS '@Ip'
				,@updateallmembers AS '@ua'
				,@newMasterPT AS '@m1'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.MasterPT AS '@m2'
						,cs.isAutoMasterPT AS '@im2'
						,cs.AutoMasaterPT AS '@um2'	
						,cs.AgentPT AS '@a2'										
						,cs.MinPT AS '@n2'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('pt'), TYPE
				)
		FOR XML PATH('r'), TYPE
	)
	SET @AutoPT =(
		SELECT cs.sporttype AS '@SportType'
			,cs.bettype AS '@BetType'
			,cs.isLive AS '@IsLive'						
			,t.isAutoMasterPT AS '@IsAutoMasterPT'
			,cs.isAutoMasterPT AS '@IsAutoMasterPTOld'
			,t.AutoMasterPT AS '@AutoMasterPT'			
			,CASE WHEN t.IsAutoMasterPT = cs.IsAutoMasterPT AND t.AutoMasterPT = cs.AutoMasterPT THEN 0 ELSE 1 END AS '@IsUpdateAutoPT'			
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
		WHERE custid = @custid
		FOR XML PATH('PT'), ROOT('ROOT')
	 )
	 
	SET @logSPDataOld = CONVERT(VARCHAR(MAX), @xml)    
    
    --Check Param
    DECLARE @ErrAcc NVARCHAR(4000)
			,@ErrType VARCHAR(1000)
			,@UpdateMinPT BIT
			,@UpdatePresetPT BIT
	
	select @ErrType = ''  			
	SELECT @ErrType = @ErrType + s.sportname + ' - ' + typenamee + '<br>'
	FROM @tblPT t
		INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
															AND t.BetType = ps.bettype 
															AND t.IsLive = ps.IsLive
		INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid        
		INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.sporttype = s.sporttype       															
	WHERE ps.SettingType = 1--PT
		AND (t.AgentPT < 0 OR t.MasterPT < 0 
			OR t.AgentPT + t.MasterPT > ps.MaxPT
			OR t.MasterPT > ps.MaxPT			
			OR t.AutoSuperPT < 0 
			OR t.AutoSuperPT > ps.MaxPT								
		)
	
	IF @ErrType <> ''		
	 BEGIN
        
        SELECT @ErrMsg =  @UserName + ': '+   
						CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking.<br>' + @ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						END, @ErrCode = 100
        RETURN
    END
    
    SELECT @sports = ''
    SELECT @sports = @sports + CAST(sporttype AS VARCHAR(5)) + ','
    FROM @tblPT 			
    
     --check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND (cs.MasterPT <> t.MasterPT
			OR cs.IsAutoMasterPT <> t.IsAutoMasterPT
			OR cs.AutoMasterPT <> t.AutoMasterPT
			OR cs.AgentPT <> t.AgentPT				
		)
	)
	BEGIN
		SELECT @UpdatePresetPT = 1
	END
	
	IF EXISTS (SELECT TOP 1 1
	FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
	WHERE custid = @custid
		AND cs.MinPT <> t.AgentMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	--Update Min PT        
	IF @UpdateMinPT = 1        
	BEGIN        
		 --check l3 >= n2        
			 
		SELECT @ErrType = ''  			
		SELECT @ErrType = @ErrType + s.sportname + ' - ' + typenamee + '<br>'    
		 FROM         
			  customer AS c WITH (NOLOCK)         
			  INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON c.custid = mcs.custid        
			  INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.isLive = b.isLive
			  INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid
			  INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.sporttype = s.sporttype										
		 WHERE c.custid = @mrecommend
			 AND mcs.MaxPT < b.AgentMinPT
		 GROUP BY b.SportType, b.BetType        
		         
		 IF @ErrType<>''        
		 BEGIN          
			  SELECT @ErrMsg = @UserName + ': '+   
							  CASE @Language         
								   WHEN 'E' THEN 'Master maximum position taking violates new minimum position taking setting<br>'+ @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](30006,@Language) + '<br>' + @ErrType
								 END,        
				@ErrCode = 101
			  RETURN
		  END  
		  
		  --check a2 >= n2       
		SELECT @ErrType = ''  			
		SELECT @ErrType = @ErrType + s.sportname + ' - ' + typenamee + '<br>'
		FROM @tblPT t
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.sporttype = s.sporttype       															
		WHERE t.AgentPT < t.AgentMinPT
		GROUP BY b.SportType, b.BetType  
		
		IF @ErrType <> ''        
		 BEGIN          
			  SELECT @ErrMsg = @UserName + ': '+   
							  CASE @Language         
								   WHEN 'E' THEN 'Current account position taking violates new minimum position taking setting <br>' + @ErrType
								   ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + '<br>' + @ErrType      
								 END, @ErrCode = 102        
			       
			  RETURN        
		 END          
	 END  
	 
	 IF @UpdatePresetPT = 1
	 BEGIN
		 --check m2 > m3   
		SELECT @ErrType = ''  			
		SELECT @ErrType = @ErrType + s.sportname + ' - ' + typenamee   
					+ CASE WHEN b.IsLive = 0 THEN '-Max: ' ELSE '-MaxLive: ' END 
					+  CAST( mcs.MasterPT AS VARCHAR(10)) + '<br>'   						
		FROM         
			CustPTSetting3rd_Agent AS mcs WITH (NOLOCK)     
			INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
									AND mcs.bettype = b.bettype        
									AND mcs.isLive = b.isLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON t.bettype = bt.typeid
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON t.sporttype = s.sporttype										
		WHERE mcs.custid = @mrecommend
			AND b.IsAutoMasterPT = 0
			AND b.MasterPT > mcs.MasterPT


		IF @ErrType <>''        
		BEGIN        	      
			SELECT @ErrMsg = @UserName + ': '+   
							 CASE @Language         
								WHEN 'E' THEN 'Wrong position taking (max set by company).<br>'+@ErrType        
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType        
							END, @ErrCode = 103              
			RETURN          
		END
      
		 --check n3<=m2+a2<=l3 if im2 = 0,         
		 --a2<=l3 and um2+a2>=n3 if im2 = 1        
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
					+ CASE WHEN b.isLive = 0 THEN '-Min: '+ CAST((mcs.MinPT) AS VARCHAR(10))+ '-Max: '+ CAST((mcs.MaxPT) AS VARCHAR(10))+ '<br>'        
							WHEN b.isLive = 1 THEN '-MinLive: '+ CAST((mcs.MinPT) AS VARCHAR(10))+ '-MaxLive: '+ CAST((mcs.MaxPT) AS VARCHAR(10))+ '<br>'        
						END
		FROM 
			CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
			INNER JOIN @tblPT b ON mcs.sporttype=b.sporttype 
									AND mcs.bettype = b.bettype        
									AND mcs.isLive = b.isLive       
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype        
		WHERE mcs.custid = @mrecommend 
			AND (         
					(b.IsAutoMasterPT=0
					AND (b.MasterPT + b.AgentPT > mcs.MaxPT OR b.MasterPT + b.AgentPT  < mcs.MinPT)
					)
					OR         
					(b.IsAutoMasterPT>0 
					AND (b.AgentPT > mcs.MaxPT OR b.AgentPT + b.AutoMasterPT < mcs.MinPT)
					)        
				)  
	      
		IF @ErrType <>''        
		BEGIN        	     
			SELECT @ErrMsg = @UserName + ': '+   
							 CASE @Language         
									WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType        
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType        
								END, @ErrCode = 104
			RETURN          
		END
		
		--n2<=a2<=l2        
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
			+ CASE WHEN b.IsLive = 0 THEN '-Min: '+ CAST((cs.MinPT) AS VARCHAR(10))+ '-Max: '+ CAST((cs.MaxPT) AS VARCHAR(10))+ '<br>'        
					WHEN b.IsLive = 1 THEN '-MinLive: '+ CAST((cs.MinPT) AS VARCHAR(10))+ '-MaxLive: '+ CAST((cs.MaxPT) AS VARCHAR(10))+ '<br>'        
				END
		FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK) 
			INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
									AND cs.bettype = b.bettype        
									AND cs.isLive = b.isLive
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype        
		WHERE cs.custid = @custid 
			AND (b.AgentPT > cs.MaxPT OR b.AgentPT < cs.MinPT)        
				      
		IF @ErrType <>''        
		BEGIN    
			SELECT @ErrMsg = @UserName + ': '+   
							CASE @Language         
								WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType        
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType        
							END, @ErrCode = 105        
			RETURN        
		END
		
		--check a2<= Min(A4, Min(m3,m4)-M2) if im2 =0        
		--check a2<= Min(A4, Min(m3,m4)) if im2 =1        
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee  
						+ CASE WHEN b.IsLive = 0 THEN '-Max: ' ELSE '-MaxLive: ' END       
						+ CAST((      
								CASE WHEN b.IsAutoMasterPT=0        
									THEN (CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END - b.MasterPT 
												THEN scs.AgentPT 
												ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END - b.MasterPT 
												END
										)        
									ELSE (CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																		THEN mcs.MasterPT ELSE scs.MasterPT 
																	END 
												THEN scs.AgentPT 
												ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END
												END
										)        
									END
						) AS VARCHAR(10)) + '<br>'        
		FROM custinfo AS c WITH (NOLOCK)          
			INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.custid = c.custid
			INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.isLive = b.IsLive 	
			INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend 
																		AND scs.sporttype=b.sporttype 
																		AND scs.bettype = b.bettype        
																		AND scs.isLive = b.IsLive        
			INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s witH(nolock) on b.sporttype = s.sporttype          
		WHERE c.custid = @mrecommend 
			AND (         
					(b.IsAutoMasterPT=0
					AND (b.AgentPT > CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END - b.MasterPT 
											THEN scs.AgentPT 
											ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END - b.MasterPT 
										END
						)
					) 
					OR 
					(b.IsAutoMasterPT>0 
					AND (b.AgentPT > CASE WHEN scs.AgentPT<= CASE WHEN mcs.MasterPT < scs.MasterPT 
																THEN mcs.MasterPT ELSE scs.MasterPT 
															END 
											THEN scs.AgentPT 
											ELSE CASE WHEN mcs.MasterPT < scs.MasterPT 
														THEN mcs.MasterPT ELSE scs.MasterPT 
													END
									END
						)
					)        
				)         

		IF @ErrType <>''        
		BEGIN        
			SELECT @ErrMsg = @UserName + ': '+   
							CASE @Language         
								WHEN 'E' THEN 'Wrong position taking (max set by company).<br>'+@ErrType        
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType        
							END, @ErrCode = 106        
			RETURN          
		END              
   

		 --check m2+a2<=min(m3,m4) - Vinh        
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
		+ '-Max: '+ CAST((CASE WHEN mcs.MasterPT < scs.MasterPT 
												THEN mcs.MasterPT 
												ELSE scs.MasterPT 
										END
						) AS VARCHAR(10)) + '<br>'        
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																	AND scs.sporttype=b.sporttype 
																	AND scs.bettype = b.bettype        
																	AND scs.isLive = b.IsLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																	AND mcs.sporttype=b.sporttype 
																	AND mcs.bettype = b.bettype        
																	AND mcs.isLive = b.IsLive															        
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype        
		WHERE b.AgentPT + b.MasterPT > CASE WHEN mcs.MasterPT < scs.MasterPT 
												THEN mcs.MasterPT 
												ELSE scs.MasterPT 
										END
			
		IF @ErrType <>''        
		BEGIN
			SELECT @ErrMsg = @UserName + ': '+  
							CASE @Language         
								WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType        
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
							END, @ErrCode = 107
			RETURN          
		END
		
		--check u2<=min(m3,m4,l3) - Phuc@20081209        
		SELECT @ErrType = ''    
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
						+ CASE WHEN b.IsLive = 0 THEN '-Max: ' ELSE '-MaxLive: ' END
						+ CAST(
									(
										CASE WHEN mcs.MasterPT < mcs.MaxPT
												 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
												ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
											END
									) AS VARCHAR(10)
								) + '<br>'        
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																	AND scs.sporttype=b.sporttype 
																	AND scs.bettype = b.bettype        
																	AND scs.isLive = b.IsLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																	AND mcs.sporttype=b.sporttype 
																	AND mcs.bettype = b.bettype        
																	AND mcs.isLive = b.IsLive															        
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype        
		WHERE b.IsAutoMasterPT = 1
			AND b.AutoMasterPT > CASE WHEN mcs.MasterPT < mcs.MaxPT
										 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
										ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
									END

		IF @ErrType <>''        
		BEGIN        
			SELECT @ErrMsg_Cur =  @UserName + ': '+        
									CASE @Language         
										WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType        
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType 
								END, @ErrCode = 108          
			RETURN      
		END 
		
      
		 --check u2>= Max(0, N3-A4)        
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
						+ CASE WHEN b.IsLive = 0 THEN '-Min: ' ELSE '-MinLive: ' END        
						+ CAST((CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END) 
								AS VARCHAR(10)) + '<br>'        
		FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@srecommend 
																	AND mcs.sporttype=scs.sporttype 
																	AND mcs.bettype=scs.bettype        
																	AND mcs.isLive = scs.isLive
			INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
									AND b.bettype = mcs.bettype        
									AND b.IsLive = mcs.isLive
			INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s with(nolock) on b.sporttype = s.sporttype         
		WHERE mcs.custid = @mrecommend 
			AND b.IsAutoMasterPT = 1         
			AND b.AutoMasterPT < CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END        
	
		IF @ErrType <>''        
		BEGIN 
			SELECT @ErrMsg_Cur =  @UserName + ': '+        
								CASE @Language         
									WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType        
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
								END, @ErrCode = 109  
			RETURN          
		END 
		
		 
		--check m2<=min(m3,m4,l3)         
		SELECT @ErrType = '' 
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
						+ CASE WHEN b.IsLive = 0 THEN '-Max: ' ELSE '-MaxLive: ' END
						+ CAST(
									(
										CASE WHEN mcs.MasterPT < mcs.MaxPT
												 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
												ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
											END
									) AS VARCHAR(10)
								) + '<br>'        
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																	AND scs.sporttype=b.sporttype 
																	AND scs.bettype = b.bettype        
																	AND scs.isLive = b.IsLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																	AND mcs.sporttype=b.sporttype 
																	AND mcs.bettype = b.bettype        
																	AND mcs.isLive = b.IsLive															        
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype        
		WHERE b.IsAutoMasterPT = 0
			AND b.MasterPT > CASE WHEN mcs.MasterPT < mcs.MaxPT
										 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
										ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
									END
       
		IF @ErrType <>''        
		BEGIN        			       
			SELECT @ErrMsg_Cur =  @UserName + ': '+        
								CASE @Language         
									WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType        
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
								END, @ErrCode = 110
			RETURN          
		END         
 		
 		
		--check m2>= Max(0, N3-A4) 
		SELECT @ErrType = ''        
		SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
						+ CASE WHEN b.IsLive = 0 THEN '-Min: ' ELSE '-MinLive: ' END        
						+ CAST((CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END) 
								AS VARCHAR(10)) + '<br>'        
		FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@srecommend 
																	AND mcs.sporttype=scs.sporttype 
																	AND mcs.bettype=scs.bettype        
																	AND mcs.isLive = scs.isLive
			INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
									AND b.bettype = mcs.bettype        
									AND b.IsLive = mcs.isLive
			INNER JOIN bodb02.dbo.bettype bt with (nolock) on b.bettype = bt.typeid        
			INNER JOIN bodb02.dbo.sports s with(nolock) on b.sporttype = s.sporttype         
		WHERE mcs.custid = @mrecommend 
			AND b.IsAutoMasterPT = 0         
			AND b.MasterPT < CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END        
	       
		IF @ErrType <>''        
		BEGIN      
			SELECT @ErrMsg =  @UserName + ': '+        
								CASE @Language         
									WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType        
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
								END, @ErrCode = 112
			RETURN          
		END    
	 END-- end check        
	
	 --update data change into db
	 UPDATE cs
	SET cs.MasterPT = b.MasterPT
		,cs.IsAutoMasterPT = b.IsAutoMasterPT
		,cs.AutoMasterPT = b.AutoMasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.AgentMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.MasterPT <> b.MasterPT
			OR cs.isAutoMasterPT <> b.isAutoMasterPT
			OR cs.AutoMasterPT <> b.AutoMasterPT			
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.AgentMinPT					
		)
	
	IF @UpdateMinPT = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_04 
			@recommend = @custid
			,@mrecommend = @mrecommend
			,@srecommend = @srecommend
			,@mode = 'Others'
			,@roleid = 2
			,@sports = @sports

		-- The minimum position taking value of agent was modified by agent's upline
		EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID 
	END
	
	IF @UpdatePresetPT = 1
	BEGIN
		EXEC dbo.Acc_CustSetting3rd_05
            ,@mrecommend = @mrecommend
			,@recommend = @custid
			,@roleid = 2
			,@mode = 'Others'
            
            ,@PT = @AutoPT
                                        
            ,@updateallmembers = @updateallmembers
            ,@newmpositiontaking = @newMasterPT
            
       EXEC dbo.Acc_CustSetting3rd_07 
			@recommend = @custid
			,@roleid = 2
			,@mode = 'Others'
			,@sports = @sports
	END	
	
	 -- Write log after update
	SET @xml = (
			SELECT @custid AS '@ci'
				,f_GetSubUsername(@SubAccID) AS '@su'
				,@userid AS '@ui'
				,@language AS '@l'
				,@IP AS '@Ip'
				,@updateallmembers AS '@ua'
				,@newMasterPT AS '@m1'
				,(
					SELECT cs.sporttype AS '@s'
						,cs.bettype AS '@b'
						,cs.isLive AS '@i'
						,cs.MasterPT AS '@m2'
						,cs.isAutoMasterPT AS '@im2'
						,cs.AutoMasaterPT AS '@um2'	
						,cs.AgentPT AS '@a2'										
						,cs.MinPT AS '@n2'
					FROM @tblPT cs	
					)
			FOR XML PATH('r'),TYPE				
	)
	
	SET @logSPData = CONVERT(VARCHAR(MAX), @xml)	
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	BEGIN TRY
		DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 450,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 450,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPDataOld,
			@duration = @duration
	END CATCH 
    
    
				
END
 GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbExtAccNet]
GO 	