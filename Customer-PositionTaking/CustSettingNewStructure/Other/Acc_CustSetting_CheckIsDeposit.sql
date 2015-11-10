ALTER PROCEDURE Acc_CustSetting_CheckIsDeposit @UserName NVARCHAR(50)=''
AS
BEGIN
	DECLARE @IsDeposit BIT = 0
	IF EXISTS (SELECT TOP 1 1
	FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN dbo.Dep_CustSuper dep WITH(NOLOCK) ON ci.srecommend = dep.custid
	WHERE ci.username = @UserName)
	SELECT @IsDeposit = 1
	
	SELECT @IsDeposit IsDeposit
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CheckIsDeposit] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_CheckIsDeposit] TO [vnteam] AS [dbo]


