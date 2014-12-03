SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_DisableStatCheck]
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
						IsDisabledDownline="1"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NewDisableStatTbl TABLE(
				SportType SMALLINT,
				BetType SMALLINT,
				IsDisabled BIT,
				IsDisabledDownline BIT
			)
	
	SELECT @ErrCode = 0, @ErrMsg = ''

	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
	
	INSERT @NewDisableStatTbl
	SELECT *
	FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
	WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	IF @RoleID=3
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@SuperID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Account disabled for Virtual Sports. Unable to edit downlines.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60015,@Language)
							END, @ErrCode = 105
			return
		END
	END
	ELSE IF @RoleID=2
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@MasterID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Account disabled for Virtual Sports. Unable to edit downlines.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60015,@Language)
							END, @ErrCode = 105
			return
		END
	END
	ELSE IF @RoleID=1
	BEGIN
		IF EXISTS
		(
		SELECT TOP 1 1
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@AgentID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0)
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Account disabled for Virtual Sports. Unable to edit downlines.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60015,@Language)
							END, @ErrCode = 105
			return
		END
	END
END