SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_UpdateRestrictionSelect]   
	@ProductID	TINYINT = NULL,
	@SettingType SMALLINT = NULL,
	@SystemID	TINYINT  = 0,
	@TargetID	INT,
	@ActorRoleID TINYINT,
	@TargetRoleID TINYINT
AS  
/*  
 Created: 20160111@Dominic  
 Task : Get Update Restriction Information  
 DB:  DBCUST/custdb  
 Original:  
  
 Param's Explanation:  

   
 */  
BEGIN   
	DECLARE @SuperID INT
	
	SELECT @SuperID = srecommend
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE CustID = @TargetID
	
	SELECT @ProductID ProductID,@SettingType SettingType,@SystemID SystemID,@TargetID TargetID,@ActorRoleID ActorRoleID,@TargetRoleID TargetRoleID,@SuperID SuperID
	INTO #tmp
	
	SELECT t.SettingType,ISNULL(rs.RestrictionMode,1) RestrictionMode,ISNULL(rs.ErrCode,0) ErrCode
	FROM #tmp t WITH(NOLOCK)
	LEFT JOIN dbo.ProductSettingUpdateRestriction rs WITH(NOLOCK)
		ON rs.ProductID = t.ProductID AND rs.SettingType = t.SettingType AND rs.SystemID = t.SystemID 
		AND rs.ActorRoleID = t.ActorRoleID AND rs.TargetRoleID = t.TargetRoleID AND rs.SuperID = t.SuperID
	
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbExtAccNet]