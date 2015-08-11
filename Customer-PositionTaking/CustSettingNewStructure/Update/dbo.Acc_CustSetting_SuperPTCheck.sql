ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTCheck]
	@custid		INT,
	@username	VARCHAR(30),
	@PT			VARCHAR(MAX),	
	@UpdatePresetPT INT = 0,	
	@ErrCode	INT = 0 OUTPUT,
	@MsgType	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000)='' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task: check input parameters for updating pt on super
		DB: DBCUST/CustDB
		
		Revisions:
		
		Parameter's Explanations:
			- @PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="90" MasterPT ="90" AgentPT = "90" SuperMinPT="0"/>
				</ROOT>
			- @MsgType : xml format of error message return						
			
	*/
BEGIN
	SET NOCOUNT ON
	
	 --Check Param
    DECLARE @ErrType XML
						
	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				MasterPT	SMALLINT,
				AgentPT		SMALLINT,
				SuperMinPT	SMALLINT
				)
	DECLARE @tmpPTGroup TABLE(custid INT
							,sporttype INT
							,bettype INT
							,islive BIT
							)
				
	-- For read xml
	DECLARE @DocHandler INT    
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @PT
	
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				MasterPT,
				AgentPT,
				SuperMinPT
			)
	SELECT
		Data.SportType,
		Data.BetType,
		Data.IsLive,
		Data.SuperPT,
		Data.MasterPT,
		Data.AgentPT,
		Data.SuperMinPT
	FROM OPENXML (@DocHandler, '/ROOT/PT',1) 
	WITH (
		SportType	SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,
		SuperPT		SMALLINT,
		MasterPT	SMALLINT,
		AgentPT		SMALLINT,
		SuperMinPT	SMALLINT		
	) AS Data
	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml				
	
	SET @ErrType =
		(
			SELECT t.SportType, t.BetType, t.IsLive
				FROM @tblPT t
					INNER JOIN ProductSettingDetail ps WITH(NOLOCK) ON t.SportType = ps.Sporttype AND t.BetType = ps.bettype AND t.IsLive = ps.IsLive
			WHERE ps.SettingType = 1--PT
				AND (t.SuperPT < 0 OR t.SuperPT > ps.MaxPT
					OR t.MasterPT < 0 OR t.MasterPT > ps.MaxPT
					OR t.AgentPT < 0 OR t.AgentPT > ps.MaxPT
					OR t.SuperMinPT < 0
					OR t.SuperPT < t.MasterPT 
					OR t.MasterPT < t.AgentPT				
					)
			FOR XML RAW('Row'), TYPE
		)
	
	IF @ErrType IS NOT NULL
	BEGIN        
        SELECT @ErrMsg = '<Root MsgID="20001" Msg="Wrong position taking.">'
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
                    , @ErrCode = 101
                    , @MsgType = 5
        RETURN
    END		
    
    IF @UpdatePresetPT = 1
	BEGIN		
		--check n4<=s4
		 SELECT @ErrType = ''
	     
	     SELECT @ErrType = 
	     (
			 SELECT t.SportType, t.BetType, t.IsLive
			 FROM @tblPT t			
			WHERE SuperPT < SuperMinPT	
			ORDER BY t.SportType, t.BetType, t.IsLive
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
		
		------------------------------------------------------------------------------------------
		--check all s3+m3<=s4 if i3 = 0,
		--m3<=s4 and u3<=s4 if i3=1
		SELECT @ErrType = ''
		
		SET @ErrType =
		(
			SELECT b.SportType, b.BetType, Islive, UserName
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				FROM 
					CustPTSetting3rd_Agent AS cs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype 
												AND cs.bettype = b.BetType 
												AND cs.isLive = b.IsLive
					INNER JOIN custinfo as c WITH (NOLOCK) ON c.custid = cs.custid					
				WHERE c.srecommend = @custid AND c.roleid = 3 AND (
										((cs.IsAutoSuperPT=0) AND (cs.SuperPT+cs.MasterPT>b.SuperPT)) OR 
										((cs.IsAutoSuperPT=1) AND (cs.MasterPT>b.SuperPT)) OR 
										((cs.IsAutoSuperPT=1) AND (cs.AutoSuperPT>b.SuperPT)) 
									)
			) b
			WHERE b.rn <= 10
			FOR XML RAW('Row'), TYPE
		)
	    
		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20019" Msg="Existing masters exceeded new Super Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 103
						, @MsgType = 1
			RETURN      
		END
		
		------------------------------------------------------------------------------------------
		--check all s1+m1+a1 <= s4
		--check all u1<=s4 if i1=1
		SELECT @ErrType = ''
		
		SELECT @ErrType =(
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype 
											AND cs.IsLive = b.IsLive
					INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
				WHERE c.srecommend = @custid
					AND c.roleid     = 1
					AND c.Enabled    = 1
					AND (1*cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT--convert datatype to ignore sql exception
						OR (cs.IsAutoSuperPT = 1
							AND cs.AutoSuperPT > b.SuperPT
						   )  
					   )
			)b 
			WHERE b.rn<= 10
			FOR XML RAW('Row'), TYPE
		)
	    
		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20020" Msg="Existing members exceeded new Super Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 104
						, @MsgType = 1			        
			RETURN
		END
		 
		 --check pt on grouped settings
		
		INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
		SELECT b.SportType, b.BetType, islive, custid 
		FROM
		(
			SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
			FROM CustPTGroupSetting3rd_Member cs WITH(NOLOCK) 
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
										AND cs.bettype = b.bettype 
										AND cs.IsLive = b.IsLive	
				INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.AgentID															
			WHERE c.srecommend = @custid
				AND c.roleid     = 2
				AND c.Enabled    = 1
				AND (1*cs.SuperPT+cs.MasterPT+cs.AgentPT>b.SuperPT
					OR (cs.IsAutoSuperPT = 1
						AND cs.AutoSuperPT > b.SuperPT
					   )  
				   )
		)b
		WHERE b.rn<= 10
					
		SELECT @ErrType = ''	 
		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				 FROM custinfo c WITH(NOLOCK)
					INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
					INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
				WHERE roleid = 1
					AND c.Enabled    = 1
					AND IsGrouped = 1
			)b
			WHERE b.rn<= 10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20020" Msg="Existing members exceeded new Super Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 104
						, @MsgType = 1			        
			RETURN						
		END
		
		------------------------------------------------------------------------------------------
		--Check all m3<=m4
		SELECT @ErrType = ''
		
		SELECT @ErrType =(
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				FROM 
					CustPTSetting3rd_Agent AS cs WITH (NOLOCK) 
					INNER JOIN @tblPT AS b ON cs.sporttype=b.sporttype 
												AND cs.bettype = b.bettype 
												AND cs.IsLive = b.IsLive
					INNER JOIN custinfo AS c WITH (NOLOCK) ON c.custid = cs.custid					
				WHERE c.srecommend = @custid AND c.roleid = 3 
					AND cs.MasterPT > b.MasterPT
			)b	
			WHERE b.rn<= 10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20021" Msg="Existing masters exceeded new Master Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 105
						, @MsgType = 1			        
			RETURN		
		END
		
		-------------------------------------------------------------------------------------------
		--Check all m1+a1<=m4
		SELECT @ErrType = ''
		
		SELECT @ErrType =(
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			(
				SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn
				FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype 
											AND cs.IsLive = b.IsLive
					INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
				WHERE c.srecommend = @custid
					   AND c.roleid     = 1
					   AND c.Enabled    = 1
					   AND cs.MasterPT + cs.AgentPT > b.MasterPT
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20022" Msg=" Existing members exceeded new Master Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 106
						, @MsgType = 1	
			RETURN
		END
		
		--check PT on grouped settings
		 
		INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
		SELECT b.SportType, b.BetType, islive, custid 
		FROM
		(
			SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn						
			FROM CustPTGroupSetting3rd_Member cs WITH(NOLOCK) 
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
										AND cs.bettype = b.bettype 
										AND cs.IsLive = b.IsLive
				INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.AgentID				
			WHERE c.srecommend = @custid
				   AND c.roleid     = 2
				   AND c.Enabled    = 1
				   AND cs.MasterPT + cs.AgentPT > b.MasterPT
		)b
		WHERE b.rn <= 10
		
		
		SELECT @ErrType = ''	 
		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			( 
				 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
				 FROM custinfo c WITH(NOLOCK)
					INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
					INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
				WHERE roleid = 1
					AND c.Enabled    = 1
					AND IsGrouped = 1
			)b
			WHERE b.rn <= 10
			FOR XML RAW('Row'), TYPE
		)
			
		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20022" Msg=" Existing members exceeded new Master Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 106
						, @MsgType = 1				
			RETURN
		END     
		
		-------------------------------------------------------------------------------------------------------------------
		--Check all a2<=a4
		SELECT @ErrType = ''

		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			( 
				 SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
				 FROM CustPTSetting3rd_Agent cs WITH(NOLOCK) 
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype 
											AND cs.bettype = b.bettype 
											AND cs.IsLive = b.IsLive
					INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid				
				 WHERE c.srecommend = @custid
				   AND c.roleid     = 2
				   AND c.Enabled    = 1
				   AND cs.AgentPT > b.AgentPT
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20023" Msg="Existing agents exceeded new Agent Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 107
						, @MsgType = 1				
			RETURN			
		END
	    
		-----------------------------------------------------------------------------------------------------------------
		--Check all a1<=a4
		SELECT @ErrType = ''

		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName
			FROM
			( 
				 SELECT b.SportType, b.BetType, b.islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 
				 FROM CustPTSetting3rd_Member cs WITH(NOLOCK) 
					INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
											AND cs.bettype = b.bettype
											AND cs.IsLive = b.IsLive
					INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = cs.custid					
				 WHERE c.srecommend = @custid
				   AND c.roleid     = 1
				   AND c.Enabled    = 1
				   AND cs.AgentPT > b.AgentPT
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)

		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20024" Msg="Existing members exceeded new Agent Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 108
						, @MsgType = 1						
			RETURN
		END
	    
		--check PT on grouped settings
		 SELECT @ErrType = ''
		
		INSERT INTO @tmpPTGroup(sporttype,bettype,islive,custid)
		SELECT b.SportType, b.BetType, islive, custid 
		FROM
		(
			SELECT b.SportType, b.BetType, b.islive, custid, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn									
			FROM CustPTGroupSetting3rd_Member cs WITH(NOLOCK) 
				INNER JOIN @tblPT b ON cs.sporttype = b.sporttype
										AND cs.bettype = b.bettype
										AND cs.IsLive = b.IsLive
				INNER JOIN custinfo c WITH(NOLOCK) ON cs.AgentID = c.custid
			 WHERE c.srecommend = @custid
			   AND c.roleid     = 2
			   AND c.Enabled    = 1
			   AND cs.AgentPT > b.AgentPT
		)b 
		WHERE b.rn<=10
		
		
		SELECT @ErrType = ''	 
		SELECT @ErrType =
		(  
			SELECT b.SportType, b.BetType, IsLive, UserName 
			FROM
			( 
				 SELECT b.SportType, b.BetType, islive, username, ROW_NUMBER() OVER(ORDER BY b.SportType, b.BetType, b.IsLive) rn				 				 
				 FROM custinfo c WITH(NOLOCK)
					INNER JOIN CustSettingMode3rd cm WITH(NOLOCK) ON c.custid = cm.custid
					INNER JOIN @tmpPTGroup b ON c.recommend = b.custid
				WHERE roleid = 1
					AND c.Enabled    = 1
					AND IsGrouped = 1
			)b
			WHERE b.rn<=10
			FOR XML RAW('Row'), TYPE
		)			
				
		IF @ErrType IS NOT NULL
		BEGIN
			SELECT @ErrMsg = '<Root MsgID="20024" Msg="Existing members exceeded new Agent Max PT">' 
							+ CONVERT(VARCHAR(MAX),@ErrType) + '</Root>'
						, @ErrCode = 108
						, @MsgType = 1									
			RETURN
		END
	END
	
END	 