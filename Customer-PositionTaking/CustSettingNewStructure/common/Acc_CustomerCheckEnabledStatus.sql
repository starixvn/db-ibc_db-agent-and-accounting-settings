SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerCheckEnabledStatus]
	@IsDisabled_XML VARCHAR(MAX),
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,

	@ErrCode  VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg     NVARCHAR(4000) = '' OUTPUT
AS
	/*
	Created: 20141110@Dominic
	Task : Validate enabled status
	DB: CUSTDB
	Original:

	Param's Explanation:
	• @IsDisabled_XML
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"
						UpdateDownline="1"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
	
		SELECT *
	INTO #newDisabledStatusTbl
	FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
	WITH(SportType smallint, BetType smallint, IsDisabled BIT,UpdateDownline BIT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF @RoleID=3
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM #newDisabledStatusTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@SuperID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
	END
	ELSE IF @RoleID=2
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM #newDisabledStatusTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@MasterID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
	END
	ELSE IF @RoleID=1
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM #newDisabledStatusTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@AgentID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
	END
	
	IF OBJECT_ID('tempdb..#newDisabledStatusTbl') IS NOT NULL
		DROP TABLE #newDisabledStatusTbl
END