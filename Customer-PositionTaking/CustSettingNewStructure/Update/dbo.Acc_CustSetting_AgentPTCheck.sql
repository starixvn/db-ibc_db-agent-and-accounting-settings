ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTCheck]
	@custid		INT,
	@username	VARCHAR(30),
	@srecommend INT,
	@mrecommend INT,
	
	@PT			VARCHAR(MAX)='',
	@UpdateMinPT INT = 0,
	@UpdatePresetPT INT = 0,
	
	@Language	VARCHAR(3)='',	
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000)='' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task:check input parameters for updating pt on Agent
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanations:
		
	*/
BEGIN
	SET NOCOUNT ON
	
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
	
	DECLARE @ErrAcc NVARCHAR(4000)
			,@ErrType VARCHAR(1000)
						
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
			OR t.AutoMasterPT < 0 
			OR t.AutoMasterPT > ps.MaxPT								
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
			  INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
			  INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype										
		 WHERE c.custid = @mrecommend
			 AND mcs.MaxPT < b.AgentMinPT
		 GROUP BY s.SportName, bt.typenamee       
		         
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
		GROUP BY s.SportName, bt.typenamee
		
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
			INNER JOIN bodb02.dbo.bettype bt WITH (NOLOCK) ON b.bettype = bt.typeid
			INNER JOIN bodb02.dbo.sports s WITH(NOLOCK) ON b.sporttype = s.sporttype										
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
		WHERE b.AgentPT + b.MasterPT > (CASE WHEN mcs.MasterPT < scs.MasterPT 
												THEN mcs.MasterPT 
												ELSE scs.MasterPT 
										END)
			
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
			AND b.AutoMasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
										 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
										ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
									END)

		IF @ErrType <>''        
		BEGIN        
			SELECT @ErrMsg =  @UserName + ': '+        
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
			AND b.AutoMasterPT < (CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
	
		IF @ErrType <>''        
		BEGIN 
			SELECT @ErrMsg =  @UserName + ': '+        
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
			AND b.MasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
										 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
										ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
									END)
       
		IF @ErrType <>''        
		BEGIN        			       
			SELECT @ErrMsg =  @UserName + ': '+        
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
			AND b.MasterPT < (CASE WHEN mcs.MinPT - scs.AgentPT > 0 
										THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
	       
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
    
END