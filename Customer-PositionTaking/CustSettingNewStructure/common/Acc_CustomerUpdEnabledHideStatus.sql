SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustomerUpdEnabledHideStatus]
	@IsDisabled_XML VARCHAR(MAX),
	@CustID INT,
	@RoleID INT
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

	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
	
		SELECT *
	INTO #newDisabledStatusTbl
	FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
	WITH(SportType smallint, BetType smallint, IsDisabled BIT,UpdateDownline BIT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	--Update disabled flag
	UPDATE stt
	SET 
		stt.IsDisabled=tmp.IsDisabled
	FROM dbo.CustProductStatus stt
	JOIN #newDisabledStatusTbl tmp 
		ON tmp.SportType=stt.SportType
		AND tmp.BetType=stt.BetType
	WHERE stt.CustID=@CustID
		
	UPDATE stt
	SET 
		stt.IsHidden=0
	FROM dbo.CustProductStatus stt
	JOIN #newDisabledStatusTbl tmp 
		ON tmp.SportType=stt.SportType
		AND tmp.BetType=stt.BetType
	WHERE stt.CustID=@CustID AND stt.IsHidden=1 AND tmp.IsDisabled=0
	
	IF @RoleID=4
	BEGIN
		UPDATE stt
		SET 
			stt.IsDisabled=tmp.IsDisabled
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
		AND ci.srecommend=@CustID AND ci.roleid<>4
			
		UPDATE stt
		SET 
			stt.IsHidden=0
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.srecommend=@CustID AND ci.roleid<>4
		WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
	END
	ELSE IF @RoleID=3
	BEGIN
		UPDATE stt
		SET 
			stt.IsDisabled=tmp.IsDisabled
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
		AND ci.mrecommend=@CustID AND ci.roleid<>3
			
		UPDATE stt
		SET 
			stt.IsHidden=0
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.mrecommend=@CustID AND ci.roleid<>3
		WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
	END
	ELSE IF @RoleID=2
	BEGIN
		UPDATE stt
		SET 
			stt.IsDisabled=tmp.IsDisabled
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
		AND ci.recommend=@CustID AND ci.roleid<>2
			
		UPDATE stt
		SET 
			stt.IsHidden=0
		FROM dbo.CustProductStatus stt
		JOIN #newDisabledStatusTbl tmp 
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
		JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.recommend=@CustID AND ci.roleid<>2
		WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
	END
	
	IF OBJECT_ID('tempdb..#newDisabledStatusTbl') IS NOT NULL
		DROP TABLE #newDisabledStatusTbl
END