ALTER PROCEDURE [dbo].[WriteLog_UserLog_RunSP_MultiCust] 
      @UserID		INT
	, @CustIDList	VARCHAR(MAX)
	, @NewPT_XML	VARCHAR(MAX)
	, @OldPT_XML	VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @IP			VARCHAR(50)		= ''
	, @Language		VARCHAR(20)		= 'E'
	, @SPName		VARCHAR(50)		= NULL
	, @Doing		VARCHAR(4000)	= NULL
	, @ActionID		INT				= NULL
	, @Duration		INT				= NULL
	
	/* Created: 2014-12-09@Dominic 
    Task: Write log for SMA multiple upd grouped member's PT settings 
    DB: DBLOG/bodb_CustomerLog  
	*/
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NewPTTble TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		)
	DECLARE @OldPTTble TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoMasterPT	TINYINT
		, AutoMasterPT		TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		)
	DECLARE @tblCust TABLE (CustID INT)

	--Parse affected Customer
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM CustDB.dbo.strSplit(@CustIDList, ',')

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @OldPT_XML

	INSERT @OldPTTble
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			TINYINT
			, MasterPT			TINYINT
			, AgentPT			TINYINT
			, IsAutoMasterPT	TINYINT
			, AutoMasterPT		TINYINT
			, IsAutoSuperPT		BIT
			, AutoSuperPT		TINYINT
			)

	EXEC sp_xml_removedocument @iDoc

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @NewPT_XML

	INSERT @NewPTTble
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/PT', 1) WITH (
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			TINYINT
			, MasterPT			TINYINT
			, AgentPT			TINYINT
			, IsAutoMasterPT	TINYINT
			, AutoMasterPT		TINYINT
			, IsAutoSuperPT		BIT
			, AutoSuperPT		TINYINT
			)

	EXEC sp_xml_removedocument @iDoc

	DECLARE @logSpData NVARCHAR(MAX)
		, @logSpData_Old NVARCHAR(MAX)
		, @xml XML

	--START LOGGING		
	SET @xml = (
			SELECT @CustIDList AS '@c'
				, @UserID AS '@u'
				, CustDB.dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, IsLive AS '@i'
						, SuperPT AS '@spt'
						, MasterPT AS '@mpt'
						, AgentPT AS '@apt'
						, IsAutoMasterPT AS '@iam'
						, AutoMasterPT AS '@am'
						, IsAutoSuperPT AS '@ias'
						, AutoSuperPT AS '@as'
					FROM @OldPTTble
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	SET @xml = (
			SELECT @CustIDList AS '@c'
				, @UserID AS '@u'
				, CustDB.dbo.f_GetSubUsername(@SubAccID) AS '@sc'
				, @IP AS '@i'
				, @Language AS '@l'
				, (
					SELECT SportType AS '@s'
						, BetType AS '@b'
						, IsLive AS '@i'
						, SuperPT AS '@spt'
						, MasterPT AS '@mpt'
						, AgentPT AS '@apt'
						, IsAutoMasterPT AS '@iam'
						, AutoMasterPT AS '@am'
						, IsAutoSuperPT AS '@ias'
						, AutoSuperPT AS '@as'
					FROM @NewPTTble
					FOR XML PATH('x')
						, TYPE
					)
			FOR XML PATH('r')
				, TYPE
			)
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	INSERT INTO dbo.UserLog_RunSP (
		UserID
		, CustID
		, SPName
		, Doing
		, ActionID
		, TrackingValue
		, TrackingValue2
		, Duration
		)
	SELECT @UserID
		, tmp.CustID
		, @SPName
		, @Doing
		, @ActionId
		, @logSpData
		, @logSpData_Old
		, @Duration
	FROM @tblCust tmp
END

GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[WriteLog_UserLog_RunSP_MultiCust] TO [bodbExtAccNet]