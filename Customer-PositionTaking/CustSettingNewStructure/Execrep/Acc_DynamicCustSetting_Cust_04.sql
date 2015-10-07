CREATE PROCEDURE [dbo].[Acc_DynamicCustSetting_Cust_04]
	@custid int,
	@roleid tinyint,
	@action varchar(30) = '',
	@IsDisabled_XML VARCHAR(MAX) = NULL
AS
/*
	Created: 20151007@Dominic
	Task : Update customer/custinfo settings
	DB: DBCust/CustDB

*/
BEGIN
	
	SET NOCOUNT ON 
	
	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustProductStatus') = 0 RETURN
		
	IF @Action = 'Others'
	BEGIN
		--Check if XML is null or empty
		IF @IsDisabled_XML IS NULL OR @IsDisabled_XML='' RETURN
		
		DECLARE @NewDisableStatTbl TABLE(
					SportType SMALLINT,
					BetType SMALLINT,
					IsDisabled BIT,
					IsDisabledDownline BIT
				)
		--Parse XML		
		DECLARE @iDoc INT
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
		
		INSERT @NewDisableStatTbl
		SELECT *
		FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
		WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT)	
		
		EXEC sp_xml_removedocument @iDoc
			
		IF @RoleID=4
		BEGIN
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsDisabled=tmp.IsDisabled
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.srecommend=@CustID AND ci.roleid<>4
				
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsHidden=0
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
				AND ci.srecommend=@CustID AND ci.roleid<>4
			WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
		END
		ELSE IF @RoleID=3
		BEGIN
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsDisabled=tmp.IsDisabled
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.mrecommend=@CustID AND ci.roleid<>3
				
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsHidden=0
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
				AND ci.mrecommend=@CustID AND ci.roleid<>3
			WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
		END
		ELSE IF @RoleID=2
		BEGIN
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsDisabled=tmp.IsDisabled
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
			AND ci.recommend=@CustID AND ci.roleid<>2
				
			UPDATE stt WITH(UPDLOCK,ROWLOCK) 
			SET 
				stt.IsHidden=0
			FROM dbo.CustProductStatus stt
			JOIN @NewDisableStatTbl tmp 
				ON tmp.SportType=stt.SportType
				AND tmp.BetType=stt.BetType
			JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid=stt.CustID
				AND ci.recommend=@CustID AND ci.roleid<>2
			WHERE stt.IsHidden=1 AND tmp.IsDisabled=0
		END
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_DynamicCustSetting_Cust_04] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustSetting_Cust_04] TO [vnteam] AS [dbo]