SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_GetCorrectedDefaultMemberPT]
	@CustID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,
	@CorrectedPT_XML VARCHAR(MAX) OUTPUT
AS
	/*
	Created: 20141105@Dominic
	Task : Correct default PT settings of a specific member
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @CustID: Member ID
	• @CorrectedPT_XML: Corrected PT setting of a member
	*/
BEGIN
	DECLARE @memberPTTbl 
			TABLE(
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[Islive] [bit] NOT NULL,
			[SuperPT] [tinyint] NOT NULL,
			[MasterPT] [tinyint] NOT NULL,
			[AgentPT] [tinyint] NOT NULL,
			[IsAutoMPT] [bit] NOT NULL,
			[AutoMPT] [tinyint] NOT NULL,
			[IsautoSPT] [bit] NOT NULL,
			[AutoSPT] [tinyint] NOT NULL)
			
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, 
			@mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
		
	INSERT INTO @memberPTTbl
			(SportType,BetType,Islive,
			SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsautoSPT,AutoSPT)	
	SELECT 
			acs.SportType,acs.BetType,acs.IsLive,
			mcs.superPT,acs.masterPT,acs.agentPT,0,0,0,0
	FROM dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK)
	JOIN dbo.CustPTSetting3rd_Agent mcs WITH (NOLOCK)
				ON acs.sporttype = mcs.sporttype
				AND acs.bettype = mcs.bettype
				AND acs.islive = mcs.islive
				AND mcs.custid = @MasterID
	WHERE acs.custid=@AgentID 
	
	--Rule 2,3
	UPDATE main
	SET 
			main.AgentPT = apt.minPT,
			main.MasterPT = CASE WHEN main.MasterPT + apt.minPT > mpt.masterPT 
											THEN mpt.masterPT-apt.minPT ELSE main.MasterPT end
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt with (NOLOCK) 
			ON mpt.custid = @MasterID  
				AND mpt.sporttype=main.sporttype 
				AND mpt.bettype=main.bettype
				AND mpt.islive=main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK) 
			ON apt.custid = @AgentID  
				AND apt.sporttype=main.sporttype 
				AND apt.bettype=main.bettype
				AND apt.islive=main.Islive
	WHERE main.AgentPT<apt.minPT
	
	--Rule 4
	UPDATE main 
	SET 
			main.AgentPT = apt.maxPT
	FROM @memberPTTbl main 
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK) 
			ON apt.custid = @AgentID  
			AND apt.sporttype=main.sporttype 
			AND apt.bettype=main.bettype
			AND apt.islive=main.Islive
	WHERE main.AgentPT>apt.maxPT
	
	--Rule 7
	Update main
	SET
		 main.MasterPT = 
				CASE WHEN spt.masterPT > mpt.masterPT THEN
						CASE WHEN mpt.masterPT-main.AgentPT > (CASE WHEN main.IsAutoMPT = 1 then main.AutoMPT else apt.automPT end)
						then (case when main.IsAutoMPT = 1 then main.AutoMPT else apt.automPT end)
						else  mpt.masterPT-main.AgentPT end
					else 
						case when spt.masterPT-main.AgentPT > (case when main.IsAutoMPT = 1 then main.AutoMPT else apt.automPT end)
						then (case when main.IsAutoMPT = 1 then main.AutoMPT else apt.automPT end)
						else  spt.masterPT-main.AgentPT end
					end
	FROM @memberPTTbl main 
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK) 
			ON mpt.custid = @MasterID 
			AND mpt.sporttype=main.sporttype 
			AND mpt.bettype=main.bettype
			AND mpt.islive=main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK) 
			ON spt.custid = @SuperID 
			AND spt.sporttype=main.sporttype 
			AND spt.bettype=main.bettype
			AND spt.islive=main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK) 
			ON apt.custid = @AgentID 
			AND apt.sporttype=main.sporttype 
			AND apt.bettype=main.bettype
			AND apt.islive=main.Islive
	WHERE (apt.isautomPT = 1 or main.IsAutoMPT = 1)
	
	--Rule 8
	UPDATE main 
	SET
			main.MasterPT = mpt.minPT-main.AgentPT
	FROM @memberPTTbl main 
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK) 
			ON mpt.custid = @MasterID 
			AND mpt.sporttype=main.sporttype 
			AND mpt.bettype=main.bettype
			AND mpt.islive=main.Islive
	where main.AgentPT+main.MasterPT<mpt.minPT

	--Rule 9
	UPDATE main 
	SET 
		@maxmapos = CASE WHEN mpt.masterPT>mpt.maxPT THEN mpt.maxPT ELSE mpt.masterPT END,
		@mpos = CASE WHEN @maxmapos-main.AgentPT<0 THEN 0 ELSE @maxmapos-main.AgentPT END,
		main.MasterPT = @mpos,
		@apos = CASE WHEN main.AgentPT + @mpos>@maxmapos THEN @maxmapos-@mpos ELSE main.AgentPT END,
		main.AgentPT = CASE WHEN @apos<apt.minPT THEN apt.minPT ELSE @apos END
	FROM @memberPTTbl main 
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt with (NOLOCK)
			ON mpt.custid = @MasterID 
			AND mpt.sporttype=main.sporttype 
			AND mpt.bettype=main.bettype
			AND mpt.islive=main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt with (NOLOCK) 
			ON apt.custid = @AgentID 
				AND apt.sporttype=main.sporttype 
				AND apt.bettype=main.bettype
				AND apt.islive=main.Islive
	where main.AgentPT+main.MasterPT>mpt.maxPT

	--Rule 10
	UPDATE main
	SET 
		main.SuperPT = CASE 
			WHEN spt.superPT - main.masterPT - main.agentPT > (
					CASE 
						WHEN main.IsAutoSPT = 1
							THEN main.AutoSPT
						ELSE mpt.AutoSPT
						END
					)
				THEN (
						CASE 
							WHEN main.IsautoSPT = 1
								THEN main.autoSPT
							ELSE mpt.autoSPT
							END
						)
			ELSE spt.superPT - main.masterPT - main.agentPT
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK) 
		ON mpt.custid = @MasterID 
			AND mpt.sporttype=main.sporttype 
			AND mpt.bettype=main.bettype
			AND mpt.islive=main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID 
			AND spt.sporttype=main.sporttype 
			AND spt.bettype=main.bettype
			AND spt.islive=main.Islive
	WHERE (
			main.IsautoSPT = 1
			OR mpt.IsautoSPT = 1
			)
			
	--Rule 11
	UPDATE main
	SET main.SuperPT = spt.minPT - main.masterPT - main.agentPT
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID 
			AND spt.sporttype=main.sporttype 
			AND spt.bettype=main.bettype
			AND spt.islive=main.Islive
	WHERE main.agentPT + main.masterPT + main.SuperPT < spt.minPT

	--Rule 12
	UPDATE main
	SET @spos = CASE 
			WHEN spt.superPT - main.masterPT - main.agentPT < 0
				THEN 0
			ELSE spt.superPT - main.masterPT - main.agentPT
			END
		,superPT = @spos
		,@mapos1 = CASE 
			WHEN @spos + main.masterPT + main.agentPT > spt.superPT
				THEN spt.superPT - @spos
			ELSE main.masterPT + main.agentPT
			END
		,@maxmapos = CASE 
			WHEN mpt.masterPT > mpt.maxPT
				THEN mpt.maxPT
			ELSE mpt.masterPT
			END
		,@mapos2 = CASE 
			WHEN @mapos1 > @maxmapos
				THEN @maxmapos
			ELSE @mapos1
			END
		,@mapos = CASE 
			WHEN @mapos2 < mpt.minPT
				THEN mpt.minPT
			ELSE @mapos2
			END
		,@mpos = CASE 
			WHEN @mapos - main.agentPT < 0
				THEN 0
			ELSE @mapos - main.agentPT
			END
		,masterPT = @mpos
		,@apos = CASE 
			WHEN main.agentPT + @mpos > @mapos
				THEN @mapos - @mpos
			ELSE main.agentPT
			END
		,agentPT = CASE 
			WHEN @apos < apt.minPT
				THEN apt.minPT
			ELSE @apos
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK) ON mpt.custid = @MasterID
		AND mpt.sporttype = main.sporttype
		AND mpt.bettype = main.bettype
		AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK) ON spt.custid = @SuperID
		AND spt.sporttype = main.sporttype
		AND spt.bettype = main.bettype
		AND spt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK) ON apt.custid = @AgentID
		AND apt.sporttype = main.sporttype
		AND apt.bettype = main.bettype
		AND apt.islive = main.Islive
	WHERE main.superPT + main.agentPT + main.masterPT > spt.superPT

	SELECT @CorrectedPT_XML = (SELECT *
	FROM @memberPTTbl
	FOR XML RAW ('PositionTaking'))

END