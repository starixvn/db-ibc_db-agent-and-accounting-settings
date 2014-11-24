 ALTER PROCEDURE [dbo].[Acc_SuperPTUpd]
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
		Task: Update pt on super
		DB: DBTXN/CustDB
		
		Revisions:
		
		Parameter's Explanation:
			@PT = <Root>
					<PT sporttype="1" bettype="1" isLive="0" SuperPT="50" SuperMinPT="0" />
					<PT sporttype="1" bettype="1" isLive="1" SuperPT="50" SuperMinPT="0" />
				</Root>
				
	*/
BEGIN
	SET NOCOUNT ON
	
END
GO
