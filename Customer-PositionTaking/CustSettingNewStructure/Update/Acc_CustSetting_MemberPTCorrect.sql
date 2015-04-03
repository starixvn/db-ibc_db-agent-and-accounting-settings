ALTER PROCEDURE [dbo].[Acc_CustSetting_MemberPTCorrect] 
	  @AgentID INT
	, @MasterID INT
	, @SuperID INT
	, @PT VARCHAR(MAX)
	, @CorrectedPT_XML VARCHAR(MAX) OUTPUT
	/* Created: 2014-12-09@Dominic 
    Task: Correct member's PT when SMA update member
    DB: DBTXN/CUSTDB
    • @PT,@CorrectedPT_XML:
			<ROOT>
					<PT 
							SportType="1" 
							BetType="1" 
							IsLive="1" 
							SuperPT="10"
							MasterPT="10"
							AgentPT="10" 
							IsAutoMasterPT="1"
							AutoMasterPT="10"
							IsAutoSuperPT="1"
							AutoSuperPT="10"                     
					/>
			</ROOT>  
	    
	*/
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NewPTTble TABLE (
		SportType SMALLINT
		, BetType SMALLINT
		, IsLive BIT
		, SuperPT TINYINT
		, MasterPT TINYINT
		, AgentPT TINYINT
		, IsAutoMasterPT TINYINT
		, AutoMasterPT TINYINT
		, IsAutoSuperPT BIT
		, AutoSuperPT TINYINT
		)
	DECLARE @mpos SMALLMONEY
		, @apos SMALLMONEY
		, @spos SMALLMONEY
		, @mapos1 SMALLMONEY
		, @mapos2 SMALLMONEY
		, @mapos SMALLMONEY
		, @maxspos SMALLMONEY
		, @maxmapos SMALLMONEY
	--Parse XML	
	DECLARE @iDoc INT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @PT

	INSERT @NewPTTble
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType SMALLINT
			, BetType SMALLINT
			, IsLive BIT
			, SuperPT TINYINT
			, MasterPT TINYINT
			, AgentPT TINYINT
			, IsAutoMasterPT TINYINT
			, AutoMasterPT TINYINT
			, IsAutoSuperPT BIT
			, AutoSuperPT TINYINT
			)

	EXEC sp_xml_removedocument @iDoc

	
	--if a1<n2 then a1 = n2,
	--m1 = max(m3-n2,m1)
	UPDATE main
	SET main.AgentPT = apt.MinPT
		, main.MasterPT = CASE 
			WHEN main.MasterPT + apt.MinPT > mpt.MasterPT
				THEN mpt.MasterPT - apt.MinPT
			ELSE main.MasterPT
			END
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType = main.SportType
			AND apt.BetType = main.BetType
			AND apt.IsLive = main.IsLive
			AND apt.CustID = @AgentID
	WHERE main.AgentPT < apt.MinPT

	--if a1 > l2 then a1 = l2
	UPDATE main
	SET main.AgentPT = apt.MaxPT
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType = main.SportType
			AND apt.BetType = main.BetType
			AND apt.IsLive = main.IsLive
			AND apt.CustID = @AgentID
	WHERE main.AgentPT > apt.MaxPT

	--if im2|im1 then
	--m1 = min(min(m3,m4) - a1, im1=1?um1:um2)
	UPDATE main
	SET main.MasterPT = CASE 
			WHEN spt.MasterPT > mpt.MasterPT
				THEN CASE 
						WHEN mpt.MasterPT - main.AgentPT > (
								CASE 
									WHEN main.IsAutoMasterPT = 1
										THEN main.AutoMasterPT
									ELSE apt.AutoMasterPT
									END
								)
							THEN (
									CASE 
										WHEN main.IsAutoMasterPT = 1
											THEN main.AutoMasterPT
										ELSE apt.AutoMasterPT
										END
									)
						ELSE mpt.MasterPT - main.AgentPT
						END
			ELSE CASE 
					WHEN spt.MasterPT - main.AgentPT > (
							CASE 
								WHEN main.IsAutoMasterPT = 1
									THEN main.AutoMasterPT
								ELSE apt.AutoMasterPT
								END
							)
						THEN (
								CASE 
									WHEN main.IsAutoMasterPT = 1
										THEN main.AutoMasterPT
									ELSE apt.AutoMasterPT
									END
								)
					ELSE spt.MasterPT - main.AgentPT
					END
			END
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType = main.SportType
			AND apt.BetType = main.BetType
			AND apt.IsLive = main.IsLive
			AND apt.CustID = @AgentID
	INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType = main.SportType
			AND spt.BetType = main.BetType
			AND spt.IsLive = main.IsLive
			AND spt.CustID = @SuperID
	WHERE apt.IsAutoMasterPT = 1
		OR main.IsAutoMasterPT = 1

	--if m1+a1 < n3 then m1=n3-a1
	UPDATE main
	SET main.MasterPT = mpt.MinPT - main.AgentPT
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent mpt
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	WHERE main.AgentPT + main.MasterPT < mpt.MinPT

	--if a1+m1>l3 then
	--m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	UPDATE main
	SET @maxmapos = CASE 
			WHEN mpt.MasterPT > mpt.MaxPT
				THEN mpt.MaxPT
			ELSE mpt.MasterPT
			END
		, @mpos = CASE 
			WHEN @maxmapos - main.AgentPT < 0
				THEN 0
			ELSE @maxmapos - main.AgentPT
			END
		, main.MasterPT = @mpos
		, @apos = CASE 
			WHEN main.AgentPT + @mpos > @maxmapos
				THEN @maxmapos - @mpos
			ELSE main.AgentPT
			END
		, main.AgentPT = CASE 
			WHEN @apos < apt.MinPT
				THEN apt.MinPT
			ELSE @apos
			END
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType = main.SportType
			AND apt.BetType = main.BetType
			AND apt.IsLive = main.IsLive
			AND apt.CustID = @AgentID
	WHERE main.AgentPT + main.MasterPT > mpt.MaxPT

	--if is1= 1 or is3 = 1 then
	--s1 = min(s4-m1-a1,is1?us1:us3)
	UPDATE main
	SET main.SuperPT = CASE 
			WHEN spt.SuperPT - main.MasterPT - main.AgentPT > (
					CASE 
						WHEN main.IsAutoSuperPT = 1
							THEN main.AutoSuperPT
						ELSE mpt.AutoSuperPT
						END
					)
				THEN (
						CASE 
							WHEN main.IsAutoSuperPT = 1
								THEN main.AutoSuperPT
							ELSE mpt.AutoSuperPT
							END
						)
			ELSE spt.SuperPT - main.MasterPT - main.AgentPT
			END
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType = main.SportType
			AND spt.BetType = main.BetType
			AND spt.IsLive = main.IsLive
			AND spt.CustID = @SuperID
	WHERE (
			main.IsAutoSuperPT = 1
			OR mpt.IsAutoSuperPT = 1
			)

	--if s1+ m1 + a1< n4 then s1= n4-m1-a1
	UPDATE main
	SET main.SuperPT = spt.MinPT - main.MasterPT - main.AgentPT
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType = main.SportType
			AND spt.BetType = main.BetType
			AND spt.IsLive = main.IsLive
			AND spt.CustID = @SuperID
	WHERE main.AgentPT + main.MasterPT + main.SuperPT < spt.MinPT

	--if s1+ m1 + a1> s4 then
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=MAX(iif(m1_new+a1>@mapos,@mapos-m1_new,a1), n2)
	UPDATE main
	SET @spos = CASE 
			WHEN spt.SuperPT - main.MasterPT - main.AgentPT < 0
				THEN 0
			ELSE spt.SuperPT - main.MasterPT - main.AgentPT
			END
		, SuperPT = @spos
		, @mapos1 = CASE 
			WHEN @spos + main.MasterPT + main.AgentPT > spt.SuperPT
				THEN spt.SuperPT - @spos
			ELSE main.MasterPT + main.AgentPT
			END
		, @maxmapos = CASE 
			WHEN mpt.MasterPT > mpt.MaxPT
				THEN mpt.MaxPT
			ELSE mpt.MasterPT
			END
		, @mapos2 = CASE 
			WHEN @mapos1 > @maxmapos
				THEN @maxmapos
			ELSE @mapos1
			END
		, @mapos = CASE 
			WHEN @mapos2 < mpt.MinPT
				THEN mpt.MinPT
			ELSE @mapos2
			END
		, @mpos = CASE 
			WHEN @mapos - main.AgentPT < 0
				THEN 0
			ELSE @mapos - main.AgentPT
			END
		, MasterPT = @mpos
		, @apos = CASE 
			WHEN main.AgentPT + @mpos > @mapos
				THEN @mapos - @mpos
			ELSE main.AgentPT
			END
		, AgentPT = CASE 
			WHEN @apos < apt.MinPT
				THEN apt.MinPT
			ELSE @apos
			END
	FROM @NewPTTble main
	INNER JOIN CustPTSetting3rd_Agent apt WITH (NOLOCK)
		ON apt.SportType = main.SportType
			AND apt.BetType = main.BetType
			AND apt.IsLive = main.IsLive
			AND apt.CustID = @AgentID
	INNER JOIN CustPTSetting3rd_Agent mpt WITH (NOLOCK)
		ON mpt.SportType = main.SportType
			AND mpt.BetType = main.BetType
			AND mpt.IsLive = main.IsLive
			AND mpt.CustID = @MasterID
	INNER JOIN CustPTSetting3rd_Agent spt WITH (NOLOCK)
		ON spt.SportType = main.SportType
			AND spt.BetType = main.BetType
			AND spt.IsLive = main.IsLive
			AND spt.CustID = @SuperID
	WHERE main.SuperPT + main.AgentPT + main.MasterPT > spt.SuperPT

	--Return XML result
	SELECT @CorrectedPT_XML = (
			SELECT *
			FROM @NewPTTble
			FOR XML RAW('PT')
			)

	SELECT @CorrectedPT_XML = '<ROOT>' + @CorrectedPT_XML + '</ROOT>'
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCorrect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCorrect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MemberPTCorrect] TO [bodbExtAccNet]