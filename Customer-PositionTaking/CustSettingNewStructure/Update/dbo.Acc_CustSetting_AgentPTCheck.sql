ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTCheck]
	@custid		INT,
	@username	VARCHAR(30),
	@srecommend INT,
	@mrecommend INT,
	
	@PT			VARCHAR(MAX)='',
	@UpdateMinPT INT = 0,
	@UpdatePresetPT INT = 0,
		
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
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
	
	DECLARE @ErrType XML
						
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
	
	SET @ErrType =
		( 			
			SELECT t.SportType, t.BetType, t.IsLive
			FROM @tblPT t
				INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype 
																	AND t.BetType = ps.bettype 
																	AND t.IsLive = ps.IsLive		
			WHERE ps.SettingType = 1--PT
				AND (t.AgentPT < 0 OR t.MasterPT < 0 
					OR t.AgentPT + t.MasterPT > ps.MaxPT
					OR t.MasterPT > ps.MaxPT			
					OR t.AutoMasterPT < 0 
					OR t.AutoMasterPT > ps.MaxPT
					)
			FOR XML RAW('Row'), TYPE													
		)
	
	IF @ErrType IS NOT NULL
    BEGIN       
		SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
						+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                , @ErrCode = 100
                , @MsgType = 5                                    
        RETURN
    END
        	    
    --Update Min PT        
	IF @UpdateMinPT = 1        
	BEGIN        
		 --check l3 >= n2    
		SELECT @ErrType = ''  	
				
		SELECT @ErrType = 
		(
			SELECT b.SportType, b.BetType,b.IsLive 
			FROM         
			  customer AS c WITH (NOLOCK)         
			  INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON c.custid = mcs.custid        
			  INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.isLive = b.isLive			  
			WHERE c.custid = @mrecommend
				AND mcs.MaxPT < b.AgentMinPT
			FOR XML RAW('Row'), TYPE
		)    		
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20030" Msg="The Agent Min PT violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 101
					, @MsgType = 5                                    
			RETURN
		END   
		  
		--check a2 >= n2       
		SELECT @ErrType = ''  	
				
		SELECT @ErrType = 
		(
			SELECT b.SportType, b.BetType,b.IsLive 
			FROM @tblPT b				
			WHERE b.AgentPT < b.AgentMinPT
			FOR XML RAW('Row'), TYPE
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 102
					, @MsgType = 5                                    
			RETURN
		END           
	 END  
	 
	 IF @UpdatePresetPT = 1
	 BEGIN
		 --check m2 > m3   
		SELECT @ErrType = ''  			
		  
		SELECT @ErrType =
		(			 
			SELECT b.SportType, b.BetType, b.IsLive, mcs.MasterPT as MaxPT											
			FROM         
				CustPTSetting3rd_Agent AS mcs WITH (NOLOCK)     
				INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.isLive = b.isLive			
			WHERE mcs.custid = @mrecommend
				AND b.IsAutoMasterPT = 0
				AND b.MasterPT > mcs.MasterPT
			FOR XML RAW('Row'), TYPE
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 103
					, @MsgType = 3                                    
			RETURN
		END    
		
		 --check n3<=m2+a2<=l3 if im2 = 0,         
		 --a2<=l3 and um2+a2>=n3 if im2 = 1        
		SELECT @ErrType = ''        
		
		SELECT @ErrType =
		(
			SELECT b.SportType, b.BetType, b.IsLive, mcs.MinPT, mcs.MaxPT					
			FROM 
				CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) 
				INNER JOIN @tblPT b ON mcs.sporttype=b.sporttype 
										AND mcs.bettype = b.bettype        
										AND mcs.isLive = b.isLive       			
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
			FOR XML RAW('Row'), TYPE
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 104
					, @MsgType = 4                                   
			RETURN
		END  
				
		--n2<=a2<=l2        
		SELECT @ErrType = ''        
		
		SELECT @ErrType=
		(
			SELECT b.SportType, b.BetType, b.IsLive, cs.MinPT, cs.MaxPT				
			FROM CustPTSetting3rd_Agent AS cs WITH (NOLOCK) 
				INNER JOIN @tblPT b ON cs.sporttype=b.sporttype 
										AND cs.bettype = b.bettype        
										AND cs.isLive = b.isLive			
			WHERE cs.custid = @custid 
				AND (b.AgentPT > cs.MaxPT OR b.AgentPT < cs.MinPT)
			FOR XML RAW('Row'), TYPE        
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20025" Msg="The position taking violates Upline Min/Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 105
					, @MsgType = 4                                   
			RETURN
		END  
		      		
		--check a2<= Min(A4, Min(m3,m4)-M2) if im2 =0        
		--check a2<= Min(A4, Min(m3,m4)) if im2 =1        
		SELECT @ErrType = ''        
		SELECT @ErrType =
		(
			SELECT b.SportType, b.BetType, b.IsLive,						     
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
						END as MaxPT						
			FROM custinfo AS c WITH (NOLOCK)          
				INNER JOIN CustPTSetting3rd_Agent AS mcs WITH (NOLOCK) ON mcs.custid = c.custid
				INNER JOIN @tblPT AS b ON mcs.sporttype=b.sporttype 
											AND mcs.bettype = b.bettype        
											AND mcs.isLive = b.IsLive 	
				INNER JOIN CustPTSetting3rd_Agent AS scs WITH (NOLOCK) ON scs.custid = @srecommend 
																			AND scs.sporttype=b.sporttype 
																			AND scs.bettype = b.bettype        
																			AND scs.isLive = b.IsLive        			
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
		FOR XML RAW('Row'), TYPE
		)
		         
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 106
					, @MsgType = 3                                   
			RETURN
		END  
		
		 --check m2+a2<=min(m3,m4) - Vinh        
		SELECT @ErrType = ''        
		SELECT @ErrType = 
		(
			SELECT b.SportType, b.BetType, b.IsLive,
					CASE WHEN mcs.MasterPT < scs.MasterPT 
							THEN mcs.MasterPT 
							ELSE scs.MasterPT 
					END as MaxPT						
			FROM @tblPT b
				INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																		AND scs.sporttype=b.sporttype 
																		AND scs.bettype = b.bettype        
																		AND scs.isLive = b.IsLive
				INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																		AND mcs.sporttype=b.sporttype 
																		AND mcs.bettype = b.bettype        
																		AND mcs.isLive = b.IsLive															        			
			WHERE b.AgentPT + b.MasterPT > (CASE WHEN mcs.MasterPT < scs.MasterPT 
													THEN mcs.MasterPT 
													ELSE scs.MasterPT 
											END)
			FOR XML RAW('Row'), TYPE											
		)											
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 107
					, @MsgType = 3                                   
			RETURN
		END  
				
		--check u2<=min(m3,m4,l3) - Phuc@20081209        
		SELECT @ErrType = ''    
		SELECT @ErrType =
		(
		SELECT b.SportType, b.BetType, b.IsLive,			
			CASE WHEN mcs.MasterPT < mcs.MaxPT
					 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
					ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
				END as MaxPT		        
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																	AND scs.sporttype=b.sporttype 
																	AND scs.bettype = b.bettype        
																	AND scs.isLive = b.IsLive
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																	AND mcs.sporttype=b.sporttype 
																	AND mcs.bettype = b.bettype        
																	AND mcs.isLive = b.IsLive															        			
		WHERE b.IsAutoMasterPT = 1
			AND b.AutoMasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
										 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
										ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
									END)
		FOR XML RAW('Row'), TYPE								
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 108
					, @MsgType = 3                                   
			RETURN
		END  
				
      
		 --check u2>= Max(0, N3-A4)        
		SELECT @ErrType = ''        
		SELECT @ErrType =
		(
			SELECT b.SportType, b.BetType, b.IsLive,	
					CASE WHEN mcs.MinPT - scs.AgentPT > 0 
							THEN mcs.MinPT - scs.AgentPT 
						ELSE 0 END as MinPT
			FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
				INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@srecommend 
																		AND mcs.sporttype=scs.sporttype 
																		AND mcs.bettype=scs.bettype        
																		AND mcs.isLive = scs.isLive
				INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
										AND b.bettype = mcs.bettype        
										AND b.IsLive = mcs.isLive			
			WHERE mcs.custid = @mrecommend 
				AND b.IsAutoMasterPT = 1         
				AND b.AutoMasterPT < (CASE WHEN mcs.MinPT > scs.AgentPT
											THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
			FOR XML RAW('Row'), TYPE	
		)										
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20032" Msg="The position taking violates Master Min PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 109
					, @MsgType = 2                                   
			RETURN
		END  
		 
		--check m2<=min(m3,m4,l3)         
		SELECT @ErrType = '' 
		SELECT @ErrType =
		(
			SELECT b.SportType, b.BetType, b.IsLive,	
					CASE WHEN mcs.MasterPT < mcs.MaxPT
						 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
						ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
					END as MaxPT				        
			FROM @tblPT b
				INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend 
																		AND scs.sporttype=b.sporttype 
																		AND scs.bettype = b.bettype        
																		AND scs.isLive = b.IsLive
				INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend 
																		AND mcs.sporttype=b.sporttype 
																		AND mcs.bettype = b.bettype        
																		AND mcs.isLive = b.IsLive		
			WHERE b.IsAutoMasterPT = 0
				AND b.MasterPT > (CASE WHEN mcs.MasterPT < mcs.MaxPT
											 THEN CASE WHEN mcs.MasterPT < scs.MasterPT THEN mcs.MasterPT ELSE scs.MasterPT END
											ELSE CASE WHEN mcs.MaxPT < scs.MasterPT THEN mcs.MaxPT ELSE scs.MasterPT END
										END)
			FOR XML RAW('Row'), TYPE									
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 110
					, @MsgType = 3                                  
			RETURN
		END  
		 		
		--check m2>= Max(0, N3-A4) 
		SELECT @ErrType = ''        		
		SELECT @ErrType =
		(
			SELECT b.SportType, b.BetType, b.IsLive,								      
					CASE WHEN mcs.MinPT - scs.AgentPT > 0 
						THEN mcs.MinPT - scs.AgentPT ELSE 0 END as MinPT
			FROM CustPTSetting3rd_Agent mcs WITH (NOLOCK)         
				INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid=@srecommend 
																		AND mcs.sporttype=scs.sporttype 
																		AND mcs.bettype=scs.bettype        
																		AND mcs.isLive = scs.isLive
				INNER JOIN @tblPT b ON b.sporttype = mcs.sporttype 
										AND b.bettype = mcs.bettype        
										AND b.IsLive = mcs.isLive				
			WHERE mcs.custid = @mrecommend 
				AND b.IsAutoMasterPT = 0         
				AND b.MasterPT < (CASE WHEN mcs.MinPT > scs.AgentPT
											THEN mcs.MinPT - scs.AgentPT ELSE 0 END)        
			FOR XML RAW('Row'), TYPE											
		)
		
		IF @ErrType IS NOT NULL
		BEGIN       
			SELECT @ErrMsg = '<Root MsgID="20031" Msg="The position taking violates Master Max PT.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
					, @ErrCode = 111
					, @MsgType = 2                                  
			RETURN
		END  
	 END-- end check  
    
END