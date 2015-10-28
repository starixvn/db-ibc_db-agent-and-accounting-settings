CREATE PROCEDURE dbo.DBA_CustSetting_SetupGroupSetting  
	@agentID INT
AS
/*  
	Created By: Dominic  
	Created Date: 20151027  
	Description: This SP is used to setup Group PT for a specific agent. Plz be noted that that this SP
		is applied for agents that do not have any data in dbo.CustPTSetting3rd_Member  

	Param explaination:  
		@agentID: recommend    
  
*/
BEGIN
	SET NOCOUNT ON
		
	CREATE TABLE #tempData (custid int, cs1 bigint, cs2 int)

	CREATE TABLE #tempGroup(cs1 bigint, cs2 int, memberCNT int, repCustID int)

	SELECT CustID
	INTO #tmpMembers
	FROM CustInfo WITH (NOLOCK) WHERE Recommend = @AgentID AND roleid = 1

	;WITH _s as (
		SELECT c.custid	
			,rdSetting = CAST(DENSE_RANK() OVER(ORDER BY sporttype, bettype, islive, superPT, masterPT, agentPT, isAutoMasterPT, AutoMasterPT, isAutoSuperPT, AutoSuperPT) as INT)
			,rdProduct = CAST(DENSE_RANK() OVER(ORDER BY sporttype, bettype, islive) as INT)
		FROM #tmpMembers c WITH(NOLOCK)
			INNER JOIN dbo.CustPTSetting3rd_Member pt WITH(NOLOCK) ON c.custid = pt.custid		
	)

	INSERT INTO #tempdata (custid, cs1, cs2)
	SELECT custid, SUM(CONVERT(bigint,rdSetting) + POWER(2, rdProduct%10+1)), CHECKSUM_AGG(CHECKSUM(HASHBYTES('SHA1', CONVERT(nvarchar(max), rdSetting))))
	FROM _s
	GROUP BY custid

	INSERT INTO #tempGroup(cs1, cs2, memberCNT, repCustID)
	SELECT cs1, cs2, memberCnt, repCustID
	FROM (
		SELECT cs1, cs2, rn = ROW_NUMBER() OVER (ORDER BY count(1) desc), memberCnt = count(1), repCustID = max(custid)
		FROM #tempdata
		GROUP BY cs1, cs2
	) x
	WHERE rn = 1

	INSERT INTO [dbo].[CustPTGroupSetting3rd_Member]
	   ([AgentID]
	   ,[SportType]
	   ,[BetType]
	   ,[IsLive]
	   ,[SuperPT]
	   ,[MasterPT]
	   ,[AgentPT]
	   ,[IsAutoMasterPT]
	   ,[AutoMasterPT]
	   ,[IsAutoSuperPT]
	   ,[AutoSuperPT])
	SELECT @agentID
	  ,[SportType]
	  ,[BetType]
	  ,[IsLive]
	  ,[SuperPT]
	  ,[MasterPT]
	  ,[AgentPT]
	  ,[IsAutoMasterPT]
	  ,[AutoMasterPT]
	  ,[IsAutoSuperPT]
	  ,[AutoSuperPT]
	FROM [dbo].[CustPTSetting3rd_Member] mb
		INNER JOIN #tempGroup tmp ON mb.CustID = tmp.repCustID
		
		
	UPDATE main
	SET IsGrouped = 1
	FROM dbo.CustSettingMode3rd main WITH(ROWLOCK,UPDLOCK)
	INNER JOIN #tempData tmp1 WITH(NOLOCK)
		ON tmp1.custid = main.CustID
	INNER JOIN #tempGroup tmp2 WITH(NOLOCK)
		ON tmp1.cs1 = tmp2.cs1
			AND tmp1.cs2 = tmp2.cs2
			

	DROP TABLE #tmpMembers
	DROP TABLE #tempdata
	DROP TABLE #tempGroup
END
	
	