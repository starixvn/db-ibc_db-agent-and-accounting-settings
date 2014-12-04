SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableStatCheck]
	@IsDisabled_XML VARCHAR(MAX),
	@RoleID INT,
	@AgentID INT,
	@MasterID INT,
	@SuperID INT,

	@Language varchar(2) = 'E',
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
			
	DECLARE @ErrorSportTypeTbl TABLE(
				SportType SMALLINT,
				BetType SMALLINT
			)
			
	DECLARE @ErrSport VARCHAR(4000)	= ''
	
	SELECT @ErrCode = 0, @ErrMsg = ''

	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
	
	INSERT @NewDisableStatTbl
	SELECT *
	FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
	WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT)	
	
	EXEC sp_xml_removedocument @iDoc
	
	
	--Get error data
	IF @RoleID=3
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType,stt.BetType
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@SuperID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0
	END
	ELSE IF @RoleID=2
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType,stt.BetType
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@MasterID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0
	END
	ELSE IF @RoleID=1
	BEGIN
		INSERT INTO @ErrorSportTypeTbl
		SELECT stt.SportType,stt.BetType
		FROM @NewDisableStatTbl tmp 
		JOIN dbo.CustProductStatus stt
			ON tmp.SportType=stt.SportType
			AND tmp.BetType=stt.BetType
			AND stt.CustID=@SuperID
		WHERE stt.IsDisabled=1 AND tmp.IsDisabled=0
	END
	
	--IF there's no error data then return
	IF NOT EXISTS ( 
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
	)
	RETURN

	SELECT @ErrSport = @ErrSport + [dbo].[f_Get_SportNameBySporttype](tmp.SportType,@Language) + ','
	FROM @ErrorSportTypeTbl tmp

	IF @ErrSport <> ''
	BEGIN
		SET @ErrSport= LEFT(@ErrSport, LEN(@ErrSport) - 1)
		
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'Account disabled for this product. Unable to edit downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60031,@Language)
						END
						+ ' (' + @ErrSport + ')'
						, @ErrCode = 101
	END
END