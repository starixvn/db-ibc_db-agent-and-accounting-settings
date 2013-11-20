ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking]
	@custid INT,
	@v163spositiontaking_1401 SMALLMONEY,
	@v163mpositiontaking_1401	SMALLMONEY,
	
	@isauto_v163spositiontaking_1401 BIT,
	@auto_v163spositiontaking_1401	SMALLMONEY,
	
	@v163UpdatePositiontaking_1401	BIT,
	@v163UpdateAutoPositiontaking_1401 BIT,
	
	@updateallmembers	BIT = 0,
	@newspositiontaking SMALLMONEY = 0,
	
	@SubAccID	INT = 0, -- Sub Account
	@UserID		INT = 0	,
	@IP			VARCHAR(50)= '',	
	@Language	VARCHAR(20) = 'E',		
	
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS 
	/*
		Created: Johnson
		Date: 20131119
		Task: Update pt on master for Opus Casino
		DB: DBTXN/bodb02
		
		Revisions:
		
		Parameter's Explanation:
			
	*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT

	SET @startRun = GETDATE()

	DECLARE @roleid			TINYINT, 			
			@UserName		VARCHAR(30), 
			@srecommend		INT, 
			@ErrType		VARCHAR(4000),
			@ErrCode_Cur	INT, 
			@ErrMsg_Cur		NVARCHAR(4000), 
			@ErrAcc			NVARCHAR(4000)


	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---- Checking total downlines before UPDATEs 
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
		@roleid=3,
		@isExecRep=1,
		@isUpdatePT = 1,
		@Sporttype = 1,
		@Language='E',
		@ErrMsg=@ErrMsg output,
		@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 
	
	DECLARE @db_v163spositiontaking_1401	SMALLMONEY,
		@db_v163mpositiontaking_1401		SMALLMONEY,	
		@db_isauto_v163spositiontaking_1401 BIT,
		@db_auto_v163spositiontaking_1401	SMALLMONEY	
	
	SELECT @db_v163spositiontaking_1401 = spositiontaking,
		@db_v163mpositiontaking_1401 = mpositiontaking,
		@db_isauto_v163spositiontaking_1401 = isautopositiontaking,
		@db_auto_v163spositiontaking_1401 = autopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 163 AND bettype = 1401
	
	SELECT @username = username , @srecommend = srecommend
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid

	--check if not change value
	IF @db_v163spositiontaking_1401 = @v163spositiontaking_1401
		AND @db_v163mpositiontaking_1401 = @v163mpositiontaking_1401
		AND @db_isauto_v163spositiontaking_1401 = @isauto_v163spositiontaking_1401
		AND @db_auto_v163spositiontaking_1401 = @auto_v163spositiontaking_1401		
	RETURN	
			
	IF (@v163spositiontaking_1401 < 0 OR @v163mpositiontaking_1401 < 0
		OR @v163spositiontaking_1401 + @v163mpositiontaking_1401 > 1
		OR @auto_v163spositiontaking_1101 < 0 OR @auto_v163spositiontaking_1401 > 1)
	BEGIN
			Select @ErrMsg = 	case @Language 
								WHEN 'E' THEN 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						END, @ErrCode = 100
			RETURN
	END

	SELECT @ErrType = ''	
	
	
	--check n4<=s3+m3<=s4, s3<=s4 if i3 = 0, 
	--m3<=s4 and u3+m3>=n4 if i3 = 1	
	SELECT @ErrType = @ErrType + 'Min: ' + CAST(co.minpositiontaking AS VARCHAR(10)) + ' -Max: ' + CAST(cs.spositiontaking AS VARCHAR(10)) + '<br>'
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype 
	WHERE cs.custid = @srecommend AND cs.sporttype = 163 AND cs.bettype = 1401
		AND ((@isauto_v163spositiontaking_1401 > 0 AND (@v163mpositiontaking_1401 + @auto_v163spositiontaking_1401 < co.minpositiontaking OR @v163mpositiontaking_1401 > cs.spositiontaking))
		OR (@isauto_v163spositiontaking_1401 = 0 AND (@v163spositiontaking_1401 + @v163mpositiontaking_1401 < minpositiontaking OR @v163spositiontaking_1401 + @v163mpositiontaking_1401 > cs.spositiontaking OR @v163spositiontaking_1401 > cs.spositiontaking)))

	IF @ErrType <> ''
	BEGIN	
		SELECT @ErrMsg = 	CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END, @ErrCode = 101
		RETURN
	END	
	
	
	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterOpusCS_Positiontaking] TO [bodbExtAccNet]