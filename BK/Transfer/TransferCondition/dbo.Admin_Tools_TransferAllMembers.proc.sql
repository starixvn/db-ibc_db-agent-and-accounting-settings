ALTER PROCEDURE [dbo].[Admin_Tools_TransferAllMembers]
	@AdminID int,
	@AgentName varchar(50)
AS
	Declare @roleid int, @AgentID int

	SELECT @roleid = roleid, @AgentID = custid
	FROM custinfo (nolock)
	WHERE username = @AgentName

	-- CREATE Lists of A/C to transfer
	CREATE TABLE #c (custid int, recommend int, NeedTransfer bit)
	IF @roleid NOT IN (2,3,4) RETURN 0
	IF @roleid = 2 INSERT INTO #c SELECT custid, recommend, 0 FROM custinfo (nolock) WHERE  recommend = @AgentID AND roleid = 1
	IF @roleid = 3 INSERT INTO #c SELECT custid, recommend, 0 FROM custinfo (nolock) WHERE mrecommend = @AgentID AND roleid = 1
	IF @roleid = 4 INSERT INTO #c SELECT custid, recommend, 0 FROM custinfo (nolock) WHERE srecommend = @AgentID AND roleid = 1

	-- Mark for A/C which need to transfer (Balance Not Zero)
	UPDATE #c
	SET NeedTransfer = 1
	WHERE custid in (
		SELECT b.custid
		FROM bettrans b (nolock)
		WHERE custid in (SELECT custid FROM #c)
		GROUP BY custid
		HAVING isnull(SUM(isnull(case when ruben=0 then 0 else winlost-actual_stake+playercomm end, 0)), 0) <> 0
	)

	DELETE FROM #c WHERE NeedTransfer = 0

	-- Start Transfer (CURSOR Loop)
	Declare @Now datetime, @recommend int, @custid int
	SET @Now = CURRENT_TIMESTAMP

	DECLARE CS_recommend
		CURSOR FOR
		SELECT recommend, custid FROM #c

	OPEN CS_recommend
	FETCH NEXT FROM CS_recommend INTO @recommend, @custid

	WHILE @@FETCH_STATUS = 0
	BEGIN		
		--Thien@20080212: Fix raisError with new @ReturnErrCode param
		--EXEC dbo.CustAccountInsClearBalance @recommend, @custid, @Now, @AdminID		
		EXEC dbo.CustAccountInsClearBalance 
			@FromCustID = @recommend,
			@ToCustIDs = @custid,
			@Transdate = @Now,
			@creator = @AdminID,			
			@ReturnErrCode = 1
			
		FETCH NEXT FROM CS_recommend INTO @recommend, @custid
	END

	CLOSE CS_recommend
	DEALLOCATE CS_recommend

