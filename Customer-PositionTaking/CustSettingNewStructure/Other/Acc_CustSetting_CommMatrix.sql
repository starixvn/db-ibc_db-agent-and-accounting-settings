SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_CommMatrix]   
   @ProductID TINYINT = NULL,
   @UserName VARCHAR(30) = ''
AS  
/*  
 Created: 20150518@Dominic  
 Task : Get Comm Matrix
 DB:  DBCUST/CustDB   
 Original:  
  
 Param's Explanation:  
 
   
 */  
BEGIN  
	SET NOCOUNT ON
	DECLARE @CustID INT
		, @RoleID INT
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT

	SELECT @CustID = CustID
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName	
	
	
	DECLARE @CommMatrix TABLE (
		[RoleID] [TINYINT],
		[SportType] [smallint],
		[BetType] [smallint],
		[Discount] Decimal(9,8)
	)	
	
	
	INSERT @CommMatrix
	SELECT
		4
	  ,comm.[SportType]
	  ,comm.[BetType]
	  ,comm.Discount
	FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
	JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
		ON pdt.SportType = comm.SportType
			AND pdt.BetType = comm.BetType
			AND pdt.IsLive = 0
			AND pdt.SettingType = 3
	WHERE CustID = @SRecommend AND pdt.ProductID = @ProductID
	
	IF @RoleID IN (3, 2, 1)
	BEGIN
		INSERT @CommMatrix
		SELECT
			3
		  ,comm.[SportType]
		  ,comm.[BetType]
		  ,comm.Discount
		FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
		JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
			ON pdt.SportType = comm.SportType
				AND pdt.BetType = comm.BetType
				AND pdt.IsLive = 0
				AND pdt.SettingType = 3
		WHERE CustID = @MRecommend AND pdt.ProductID = @ProductID
		
		IF @RoleID IN (2, 1)
		BEGIN
			INSERT @CommMatrix
			SELECT
				2
			  ,comm.[SportType]
			  ,comm.[BetType]
			  ,comm.Discount
			FROM [dbo].CustDiscount3rd_Agent comm WITH(NOLOCK)
			JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
				ON pdt.SportType = comm.SportType
					AND pdt.BetType = comm.BetType
					AND pdt.IsLive = 0
					AND pdt.SettingType = 3
			WHERE CustID = @Recommend AND pdt.ProductID = @ProductID
			
			IF @RoleID = 1
			BEGIN
				INSERT @CommMatrix
				SELECT
					1
				  ,comm.[SportType]
				  ,comm.[BetType]
				  ,comm.PlayerDiscount
				FROM [dbo].CustDiscount3rd_Member comm WITH(NOLOCK)
				JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
					ON pdt.SportType = comm.SportType
						AND pdt.BetType = comm.BetType
						AND pdt.IsLive = 0
						AND pdt.SettingType = 3
				WHERE CustID = @CustID AND pdt.ProductID = @ProductID
			END
		END
	END
	
	--Return Comm
	SELECT [RoleID]
		, [SportType]
		, [BetType]
		, Discount
	FROM @CommMatrix comm
	ORDER BY [SportType]
		, [BetType] , [RoleID] DESC

END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CommMatrix] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CommMatrix] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CommMatrix] TO [bodbExtAccNet]