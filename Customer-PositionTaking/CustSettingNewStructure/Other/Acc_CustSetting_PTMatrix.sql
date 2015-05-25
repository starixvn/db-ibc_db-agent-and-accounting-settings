SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_PTMatrix]   
   @ProductID TINYINT = NULL,
   @UserName VARCHAR(30) = ''
AS  
/*  
 Created: 20150518@Dominic  
 Task : Get PT Matrix
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
 
   
 */  
BEGIN  
	SET NOCOUNT ON
	DECLARE @CustID INT
		, @RoleID INT
		, @SAg VARCHAR(20)
		, @MAg VARCHAR(20)
		, @Ag VARCHAR(20)
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT
		, @currency TINYINT
		, @DisableAutoMPT BIT
		, @SettingLevel TINYINT

	SELECT @CustID = CustID
		, @currency = currency
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName

	SELECT @UserName = UserName
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @CustID

	SELECT @SAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @SRecommend

	SELECT @MAg = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @MRecommend

	SELECT @Ag = UserName
	FROM Custinfo WITH (NOLOCK)
	WHERE CustID = @Recommend

	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM CustMaster WITH (NOLOCK)
	WHERE custid = @MRecommend
	
	SELECT @SettingLevel=  
	(SELECT TOP 1 SettingLevel
		FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE ProductID = @ProductID AND SettingType = 1
	)
	
	--Return Customer Infor
	SELECT @CustID CustID
		, @UserName UserName
		, @RoleID RoleID
		, @currency Currency
		, @SRecommend SuperID
		, @MRecommend MasterID
		, @Recommend AgentID
		, @SAg SuperName
		, @MAg MasterName
		, @Ag AgentName
		, @DisableAutoMPT DisableAutoMPT
		, @SettingLevel SettingLevel
	
	
	DECLARE @PTMatrix TABLE (
		[CustID] [int],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SuperPT] [tinyint],
		[MasterPT] [tinyint],
		[AgentPT] [tinyint],
		[AutoSuperPT] [tinyint],
		[IsAutoSuperPT] [bit],
		[AutoMasterPT] [tinyint],
		[IsAutoMasterPT] [bit],
		[MinPT] [tinyint],
		[MaxPT] [tinyint]
	)	
	
	
	INSERT @PTMatrix
	SELECT
		spt.CustID
	  ,spt.[SportType]
	  ,spt.[BetType]
	  ,spt.[IsLive]
	  ,spt.[SuperPT]
	  ,spt.[MasterPT]
	  ,spt.[AgentPT]
	  , NULL
	  , NULL
	  , NULL
	  , NULL
	  ,spt.[MinPT]
	  ,spt.[MaxPT]
	FROM [dbo].[CustPTSetting3rd_Agent] spt WITH(NOLOCK)
	JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
		ON pdt.SportType = spt.SportType
			AND pdt.BetType = spt.BetType
			AND pdt.IsLive = spt.IsLive
			AND pdt.SettingType = 1
	WHERE CustID = @SRecommend AND pdt.ProductID = @ProductID
	
	IF @RoleID IN (3, 2, 1)
	BEGIN
		INSERT @PTMatrix
		SELECT mpt.CustID
		  , mpt.[SportType]
		  ,mpt.[BetType]
		  ,mpt.[IsLive]
		  ,mpt.[SuperPT]
		  ,mpt.[MasterPT]
		  ,NULL
		  ,mpt.[AutoSuperPT]
		  ,mpt.[IsAutoSuperPT]
		  ,NULL
		  ,NULL
		  ,mpt.[MinPT]
		  ,mpt.[MaxPT]
		FROM [dbo].[CustPTSetting3rd_Agent] mpt WITH(NOLOCK)
		JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
		ON pdt.SportType = mpt.SportType
			AND pdt.BetType = mpt.BetType
			AND pdt.IsLive = mpt.IsLive
			AND pdt.SettingType = 1
		WHERE CustID = @MRecommend AND pdt.ProductID = @ProductID
		
		IF @RoleID IN (2, 1)
		BEGIN
			INSERT @PTMatrix
			SELECT apt.CustID
			  , apt.[SportType]
			  ,apt.[BetType]
			  ,apt.[IsLive]
			  ,NULL
			  ,[MasterPT]
			  ,[AgentPT]
			  ,NULL
			  ,NULL
			  ,apt.[AutoMasterPT]
			  ,apt.[IsAutoMasterPT]
			  ,apt.[MinPT]
			  ,apt.[MaxPT]
			FROM [dbo].[CustPTSetting3rd_Agent] apt WITH(NOLOCK)
			JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
			ON pdt.SportType = apt.SportType
				AND pdt.BetType = apt.BetType
				AND pdt.IsLive = apt.IsLive
				AND pdt.SettingType = 1
			WHERE CustID = @Recommend AND pdt.ProductID = @ProductID
			
			IF @RoleID = 1
			BEGIN
				IF EXISTS(SELECT TOP 1 1 
							FROM dbo.CustSettingMode3rd WITH(NOLOCK) 
							WHERE CustID = @CustID AND IsGrouped = 0)
				BEGIN
					INSERT @PTMatrix
					SELECT mempt.CustID
						, mempt.[SportType]
						, mempt.[BetType]
						, mempt.[IsLive]
						, mempt.[SuperPT]
						, mempt.[MasterPT]
						, mempt.[AgentPT]
						, mempt.[AutoSuperPT]
						, mempt.[IsAutoSuperPT]
						, mempt.[AutoMasterPT]
						, mempt.[IsAutoMasterPT]
						, NULL
						, NULL
					FROM [dbo].CustPTSetting3rd_Member mempt WITH (NOLOCK)
					JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
					ON pdt.SportType = mempt.SportType
						AND pdt.BetType = mempt.BetType
						AND pdt.IsLive = mempt.IsLive
						AND pdt.SettingType = 1
					WHERE CustID = @CustID AND pdt.ProductID = @ProductID
				END
				ELSE
				BEGIN
					INSERT @PTMatrix
					SELECT @CustID
						, mempt.[SportType]
						, mempt.[BetType]
						, mempt.[IsLive]
						, mempt.[SuperPT]
						, mempt.[MasterPT]
						, mempt.[AgentPT]
						, mempt.[AutoSuperPT]
						, mempt.[IsAutoSuperPT]
						, mempt.[AutoMasterPT]
						, mempt.[IsAutoMasterPT]
						, NULL
						, NULL
					FROM [dbo].CustPTGroupSetting3rd_Member mempt WITH (NOLOCK)
					JOIN dbo.ProductSettingDetail pdt WITH(NOLOCK)
					ON pdt.SportType = mempt.SportType
						AND pdt.BetType = mempt.BetType
						AND pdt.IsLive = mempt.IsLive
						AND pdt.SettingType = 1
					WHERE AgentID = @Recommend AND pdt.ProductID = @ProductID
				END
			END
		END
	END
	
	--Return PT
	SELECT [SportType]
		, [BetType]
		, [IsLive]
		, [RoleID]
		, ISNULL([SuperPT],0) [SuperPT]
		, ISNULL([MasterPT],0) [MasterPT]
		, ISNULL([AgentPT],0) [AgentPT]
		, ISNULL([AutoSuperPT],0) [AutoSuperPT]
		, ISNULL([IsAutoSuperPT],0) [IsAutoSuperPT]
		, ISNULL([AutoMasterPT],0) [AutoMasterPT]
		, ISNULL([IsAutoMasterPT],0) [IsAutoMasterPT]
		, ISNULL([MinPT],0) [MinPT]
		--, ISNULL([MaxPT],0) [MaxPT]
	FROM @PTMatrix pt
	JOIN dbo.custInfo ci WITH(NOLOCK) ON pt.CustID = ci.custid
	ORDER BY [SportType]
		, [BetType]
		, [IsLive]
		, [RoleID] DESC
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbExtAccNet]