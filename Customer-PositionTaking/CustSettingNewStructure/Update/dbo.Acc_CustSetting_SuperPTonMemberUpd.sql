 ALTER PROCEDURE [dbo].[Acc_SuperPTonMemberUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,    
    @Language	VARCHAR(2) = 'E',
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update super's pt on member
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT =<Root>
					<PT sporttype="1" bettype="1" isLive="0" SuperPT="50" AutoSuperPT="0" IsAutoSuperPT="0" />
					<PT sporttype="1" bettype="1" isLive="1" SuperPT="30" AutoSuperPT="0" IsAutoSuperPT="0" />
				</Root>
	*/
BEGIN
	SET NOCOUNT ON 
	
END
GO

GO
GRANT EXECUTE ON [dbo].[Acc_SuperPTonMemberUpd] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_SuperPTonMemberUpd] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_SuperPTonMemberUpd] TO [bodbExtAccNet] AS [dbo]