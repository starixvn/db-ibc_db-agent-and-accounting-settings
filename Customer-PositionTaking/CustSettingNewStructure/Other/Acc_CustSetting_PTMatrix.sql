SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_PTMatrix]
   @SportType SMALLINT,
   @BetType SMALLINT,
   @isLive BIT,
   @UserName VARCHAR(30) = ''
AS  
/*  
 Created: 20150518@Dominic  
 Task : Get PT Matrix
 DB:  DBCUST/CustDB  
 Original:  

 Revision:
    - 20151021@Billy: Change parameter from (@ProductID, @UserName) to (@SportType, @BetType, @isLive, @UserName)
  
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
	
	IF @BetType = 0                         -- Select all bettype
    BEGIN
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
	    WHERE CustID = @SRecommend
          AND SportType = @SportType
          AND IsLive <= @isLive
	
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
		    WHERE CustID = @MRecommend
              AND SportType = @SportType
              AND IsLive <= @isLive
		
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
			    WHERE CustID = @Recommend
                  AND SportType = @SportType
                  AND IsLive <= @isLive
			
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
					    WHERE CustID = @CustID
                          AND SportType = @SportType
                          AND IsLive <= @isLive
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
					    WHERE AgentID = @Recommend
                          AND SportType = @SportType
                          AND IsLive <= @isLive
				    END
			    END
		    END
	    END
    END
    ELSE                                    -- Select specified bettype
    BEGIN
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
	    WHERE CustID = @SRecommend
          AND SportType = @SportType
          AND BetType = @BetType
          AND IsLive <= @isLive
	
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
		    WHERE CustID = @MRecommend
              AND SportType = @SportType
              AND BetType = @BetType
              AND IsLive <= @isLive
		
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
			    WHERE CustID = @Recommend
                  AND SportType = @SportType
                  AND BetType = @BetType
                  AND IsLive <= @isLive
			
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
					    WHERE CustID = @CustID
                          AND SportType = @SportType
                          AND BetType = @BetType
                          AND IsLive <= @isLive
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
					    WHERE AgentID = @Recommend
                          AND SportType = @SportType
                          AND BetType = @BetType
                          AND IsLive <= @isLive
				    END
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