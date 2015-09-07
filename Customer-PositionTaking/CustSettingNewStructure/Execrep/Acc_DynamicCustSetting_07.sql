USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_DynamicCustSetting_07]    Script Date: 9/7/2015 6:20:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting_07]
	@SuperID INT = 0
	,@MasterID INT = 0
	,@AgentID INT = 0
	,@RoleID INT
	,@SportBettypeXML NVARCHAR(MAX) = ''
AS
/*
    Created: Elodie
    Date: 20150901
    Task: Apply execrep when corrects pt on members
    DB: DBCUST/CustDB
    Original versions: Acc_CustSetting3rd_07
        
    Revision:
			                              
    Parameter's Explanation:        

*/
BEGIN
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	
	DECLARE @tmpSportBettype TABLE(sporttype SMALLINT, bettype SMALLINT, islive BIT)
	DECLARE @_SuperID INT, @_MasterID INT, @_AgentID INT

	-- declare variable table to keep super's settings 
	DECLARE @temp_sag TABLE (custid int, bettype smallint, sporttype smallint, islive bit,
		a4 smallmoney, m4 smallmoney, s4 smallmoney, n4 smallmoney, l4 smallmoney
		UNIQUE CLUSTERED (custid, sporttype, bettype, islive)
	)
	
	-- declare variable table to keep master's settings 
	DECLARE @temp_mag TABLE (custid int, bettype smallint, sporttype smallint, islive bit,
		a3 smallmoney, m3 smallmoney, s3 smallmoney, u3 smallmoney, i3 bit, n3 smallmoney, l3 smallmoney
		UNIQUE CLUSTERED (custid, sporttype, bettype, islive)
	)

	DECLARE @a2 smallmoney, @m2 smallmoney, @s2 smallmoney, @n2 smallmoney, @l2 smallmoney
	DECLARE @im2 bit, @um2 smallmoney
	DECLARE @a1 smallmoney, @m1 smallmoney, @s1 smallmoney, @i1 bit, @u1 smallmoney, @im1 bit, @um1 smallmoney
	DECLARE @temp1 smallmoney, @temp2 smallmoney, @temp3 smallmoney
	DECLARE @s_new smallmoney, @m_new smallmoney, @a_new smallmoney
	---------------------------------

	SELECT @_SuperID = @SuperID, @_MasterID = @MasterID, @_AgentID = @AgentID

	INSERT INTO @tmpSportBettype (sporttype, bettype, islive)
	SELECT SportType,Bettype,IsLive
	FROM dbo.f_SportBetTypeXMLParse(@SportBetTypeXML)

	INSERT INTO @temp_sag (custid, bettype, sporttype, islive, a4, m4, s4, n4, l4)
	SELECT scs.custid, scs.bettype, scs.sporttype, scs.IsLive, scs.AgentPT, scs.MasterPT, scs.SuperPT, scs.MinPT, scs.MaxPT
	FROM dbo.CustPTSetting3rd_Agent scs WITH(NOLOCK)
		INNER JOIN @tmpSportBettype tmp ON tmp.sporttype = scs.SportType AND tmp.bettype = scs.BetType AND tmp.islive = scs.IsLive
	WHERE scs.custid = @_SuperID

	IF @RoleID = 4
	BEGIN		
		-- rule #1: s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
		/*
			@x1 = (i1=1) ? u1 : u3
			s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
		*/	
		SELECT 1	
	END	
	
	IF @RoleID In (2,3)
	BEGIN
		IF @RoleID = 2
		BEGIN
			-- rule #1: a1 = max(a1,n2) -- agent min
			-- rule #2: a1 = min(a1,l2) -- agent max 
			-- rule #3: m1 = min(m3-a1,m1)
			SELECT 1
		END

		-- rule #1: m1 = min(m3-a1,u2) if master auto -- Recalculate AUTO MPT 
		-- rule #2: m1 = max(m1,n3-a1) -- master min   
		-- rule #3: check master max 
		/*	@x1 = min(m3,l3) -- mpt max
			@x2 = max(@x1-a1,0) --mpt
			m1 = (a1+m1>l3) ? @x2 : m1
			@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
			a1 = (a1+m1>l3) ? max(@x3, n2) : a1
		*/ 
		-- rule #4: s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
		/*
			@x1 = (i1=1) ? u1 : u3
			s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
		*/
		-- rule #5: s1 = max(n4-m1-a1,s1) --super min
		-- rule #8: s1 = min(l4-m1-a1,s1) --super max

		IF @RoleID = 3
		BEGIN
			-- rule #6: UPDATE s1,m1,a1 in case s1+m1+a1>s4
			/* -- explanation
				@x1 = (s4-m1-a1 < 0) ? 0 : s4-m1-a1
				s1 = (s1+a1+m1 > s4) ? @x1 : s1
				@x1 = (@x1+m1+a1 > s4) ? s4-@x1 : m1+a1
				@x2 = (m3 > l3) ? l3 : m3
				@x2 = (@x1 > @x2) ? @x2 : @x1
				@x2 = (@x2 < n3) ? n3 : @x2
				@x3 = (@x2-a1 < 0) ? 0 : @x2-a1
				m1 = (s1+a1+m1 > s4) ? @x3 : m1
				@x3 = (a1+@x3>@x2) ? @x2-@x3 : a1
				@x3 =  (@x3 < n2) ? n2 : @x3
				a1 = (s1+a1+m1 > s4) ? @x3 : a1				
			*/ 
			SELECT 1
		END
	END
END