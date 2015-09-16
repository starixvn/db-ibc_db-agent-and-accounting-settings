USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_AGC_UpdSuperSetting]    Script Date: 09/16/2015 04:45:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_AGC_UpdSuperSetting    Script Date: 8/28/2014 3:01:31 PM ******/
CREATE PROCEDURE	[dbo].[Acc_AGC_UpdSuperSetting]
	@CustID				INT,
	@CheckedGroup		VARCHAR(500),
	@DefaultGroup		VARCHAR(20),
	@ApplyGroupToMember	VARCHAR(20)		= '',
	@UserID				INT,
	@IP					VARCHAR(40),
	@Langkey			VARCHAR(10)		= 'en-US',
	@ErrCode			INT				= 0		OUTPUT,
	@ErrMsg				VARCHAR(8000)	= ''	OUTPUT,
	@SportType			INT,
	--AGCasino
	@v250_1801PT		SMALLMONEY
AS
/*
	Created: 20140813@Victor
	Task: Update AG Casino product setting of super
	DB: DBTXN/CustDB
	Original:
	Revisions:
	- 20150916@Winnie: Add AGCasino
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun			DATETIME
			,@endRun			DATETIME
			,@duration			INT
			,@LogSPData			VARCHAR(MAX)
			,@TrackingValue2	VARCHAR(MAX)
			,@CheckedGroup_Old	VARCHAR(500) = ''
			,@DefaultGroup_Old	VARCHAR(20) = ''
	SET @startRun = GETDATE()

	SELECT @CheckedGroup_Old	=	ISNULL(CheckedGroup, '')
		,@DefaultGroup_Old		=	ISNULL(DefaultGroup, '')
	FROM dbo.Dep_SuperSetting_AGCasino WITH (NOLOCK) 
	WHERE CustID = @CustID


	-- Update Setting for Super
	IF (EXISTS(SELECT 1 FROM dbo.Dep_SuperSetting_AGCasino WITH (NOLOCK) WHERE CustID = @CustID))
	BEGIN
		UPDATE dbo.Dep_SuperSetting_AGCasino WITH(ROWLOCK)
		SET CheckedGroup = @CheckedGroup, DefaultGroup = @DefaultGroup
		WHERE CustID = @CustID
	END
	ELSE
	BEGIN
		INSERT INTO dbo.Dep_SuperSetting_AGCasino (CustID, CheckedGroup, DefaultGroup, IsEnabled)
		VALUES (@CustID, @CheckedGroup, @DefaultGroup, 0)
	END

	-- Update Setting for all downline members (that has no setting)
	IF LEN(@ApplyGroupToMember) > 0 
	BEGIN
		DECLARE @CurrRow INT = 1
				,@RowPerBatch INT = 10000
				,@RowCount INT = 0
		CREATE TABLE #CustList (RowNo INT IDENTITY(1,1), CustID INT)
		
		INSERT INTO #CustList (CustID)
		SELECT CustID 
		FROM Customer c WITH (NOLOCK) 
		WHERE srecommend = @CustID AND roleid = 1
			AND NOT EXISTS(SELECT 1 FROM dbo.Dep_CustSetting_AGCasino cs WITH (NOLOCK) WHERE cs.CustID = c.CustID AND LEN(cs.AGGroup) > 0)

		SELECT @RowCount = @@rowcount

		WHILE (@CurrRow <= @RowCount)
		BEGIN

			MERGE dbo.Dep_CustSetting_AGCasino AS dest
			USING (	SELECT CustID 
					FROM #CustList 
					WHERE RowNo BETWEEN @CurrRow AND (@CurrRow + @RowPerBatch - 1)
				  ) AS src (CustID)
			ON (dest.CustID = src.CustID)
			WHEN MATCHED THEN
				UPDATE SET dest.AGGroup = @ApplyGroupToMember
			WHEN NOT MATCHED THEN
				INSERT (CustID, AGGroup, IsEnabled)
				VALUES (src.CustID, @ApplyGroupToMember, 0);
			
			SELECT @CurrRow = @CurrRow + @RowPerBatch
			WAITFOR DELAY '00:00:00.300'
		END
		DROP TABLE #CustList
	END

	EXEC Acc_Dep_CustomerUpdSetting_xtest
	@CustID				=@CustID,
	@SportType			=@SportType,
	--AGCasino
	@v250_1801PT		=@v250_1801PT,	
	@UserID				=@UserID,
	@IP					=@IP,
	@Langkey			=@Langkey,
	@ErrCode			=@ErrCode,
	@ErrMsg				=@ErrMsg	

	-- Write log
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF(MILLISECOND,@startRun,@endRun)

	SELECT @LogSPData = '<Acc_AGC_UpdSuperSetting CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" ' +
						'CheckedGroup="'+ COALESCE(CAST(@CheckedGroup as VARCHAR(500)),SPACE(1)) + '" ' +
						'DefaultGroup="'+ COALESCE(CAST(@DefaultGroup as VARCHAR(20)),SPACE(1)) + '" ' +
						'ApplyGroupToMember="'+ COALESCE(CAST(@ApplyGroupToMember as VARCHAR(20)),SPACE(1)) + '" ' +
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(40)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(8000)),SPACE(1))+ '" />'

	SELECT @TrackingValue2 = '<Acc_AGC_UpdSuperSetting CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" ' +
						'CheckedGroup="'+ COALESCE(CAST(@CheckedGroup_Old as VARCHAR(500)),SPACE(1)) + '" ' +
						'DefaultGroup="'+ COALESCE(CAST(@DefaultGroup_Old as VARCHAR(20)),SPACE(1)) + '" ' +
						'ApplyGroupToMember=""' +
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(40)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(8000)),SPACE(1))+ '" />'
	
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = 2039,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @TrackingValue2,
				@duration = @duration
	
END
GO
GRANT EXECUTE ON [dbo].[Acc_AGC_UpdSuperSetting] TO [bodbAdminNet] AS [dbo]