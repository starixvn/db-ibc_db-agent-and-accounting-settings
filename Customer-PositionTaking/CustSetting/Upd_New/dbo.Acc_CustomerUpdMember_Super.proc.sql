
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_Super] 
	@CustID INT,--memberid
	@Closed BIT,
	@disCasino BIT = 0,
	@UpdateClosed BIT = 0,
	@Suspended BIT = null,
	@updatesuspended BIT = 0,
	@DisabledFI BIT = 0,
	@spositiontaking_1 SMALLMONEY OUTPUT,
	@spositiontaking_2 SMALLMONEY OUTPUT,
	@spositiontaking_3 SMALLMONEY OUTPUT,
	@spositiontaking_4 SMALLMONEY OUTPUT,
	@spositiontaking_5 SMALLMONEY OUTPUT,
	@spositiontaking_6 SMALLMONEY OUTPUT,
	@spositiontaking_7 SMALLMONEY OUTPUT,
	@spositiontaking_8 SMALLMONEY OUTPUT,
	@spositiontaking_9 SMALLMONEY OUTPUT,
	@spositiontaking_10 SMALLMONEY OUTPUT,
	
	@slivepositiontaking_1 SMALLMONEY OUTPUT,
	@slivepositiontaking_3 SMALLMONEY OUTPUT,
	@slivepositiontaking_7 SMALLMONEY OUTPUT,
	@slivepositiontaking_8 SMALLMONEY OUTPUT,
	
	@v2spositiontaking_1 SMALLMONEY OUTPUT,
	@v2spositiontaking_2 SMALLMONEY OUTPUT,
	@v2spositiontaking_3 SMALLMONEY OUTPUT,
	@v2spositiontaking_7 SMALLMONEY OUTPUT,
	@v2spositiontaking_8 SMALLMONEY OUTPUT,
--	@v2spositiontaking_9 SMALLMONEY OUTPUT,
	@v2spositiontaking_20 SMALLMONEY OUTPUT,

	@v3spositiontaking_1 SMALLMONEY OUTPUT,
	@v3spositiontaking_2 SMALLMONEY OUTPUT,
	@v3spositiontaking_3 SMALLMONEY OUTPUT,
	@v3spositiontaking_20 SMALLMONEY OUTPUT,

	@v5spositiontaking_1 SMALLMONEY OUTPUT,
	@v5spositiontaking_2 SMALLMONEY OUTPUT,
	@v5spositiontaking_3 SMALLMONEY OUTPUT,
	@v5spositiontaking_20 SMALLMONEY OUTPUT,

	@v8spositiontaking_1 SMALLMONEY OUTPUT,
	@v8spositiontaking_3 SMALLMONEY OUTPUT,
	@v8spositiontaking_20 SMALLMONEY OUTPUT,

	@v10spositiontaking_1 SMALLMONEY OUTPUT,
	@v10spositiontaking_2 SMALLMONEY OUTPUT,
	@v10spositiontaking_3 SMALLMONEY OUTPUT,
	@v10spositiontaking_20 SMALLMONEY OUTPUT,

	@v11spositiontaking_1 SMALLMONEY OUTPUT,
	@v11spositiontaking_20 SMALLMONEY OUTPUT,

	--v151
	--@v151spositiontaking_31 SMALLMONEY OUTPUT,
	--@v151spositiontaking_32 SMALLMONEY OUTPUT,

	@v99spositiontaking_1 SMALLMONEY OUTPUT,
	@v99spositiontaking_2 SMALLMONEY OUTPUT,
	@v99spositiontaking_3 SMALLMONEY OUTPUT,
	@v99spositiontaking_20 SMALLMONEY OUTPUT,

	-- mixed sports
	@v99spositiontaking_9 SMALLMONEY OUTPUT,

	-- number game
	@v161spositiontaking_81 SMALLMONEY OUTPUT,
	@v161spositiontaking_83 SMALLMONEY OUTPUT,
	@v161spositiontaking_86 SMALLMONEY OUTPUT,
	@v161spositiontaking_88 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_85 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_86 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_87 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_89 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_90 SMALLMONEY = 0 OUTPUT,
	
	
	@UserID int,
	
	@auto_spositiontaking_1 SMALLMONEY = 0,
	@auto_spositiontaking_2 SMALLMONEY = 0,
	@auto_spositiontaking_3 SMALLMONEY = 0,
	@auto_spositiontaking_4 SMALLMONEY = 0,
	@auto_spositiontaking_5 SMALLMONEY= 0,
	@auto_spositiontaking_6 SMALLMONEY = 0,
	@auto_spositiontaking_7 SMALLMONEY = 0,
	@auto_spositiontaking_8 SMALLMONEY = 0,
	@auto_spositiontaking_9 SMALLMONEY = 0,
	@auto_spositiontaking_10 SMALLMONEY = 0,
	
	@auto_slivepositiontaking_1 SMALLMONEY = 0,
	@auto_slivepositiontaking_3 SMALLMONEY = 0,
	@auto_slivepositiontaking_7 SMALLMONEY = 0,
	@auto_slivepositiontaking_8 SMALLMONEY = 0,
	
	@auto_v2spositiontaking_1 SMALLMONEY = 0,
	@auto_v2spositiontaking_2 SMALLMONEY = 0,
	@auto_v2spositiontaking_3 SMALLMONEY = 0,
	@auto_v2spositiontaking_7 SMALLMONEY = 0,
	@auto_v2spositiontaking_8 SMALLMONEY = 0,
--	@auto_v2spositiontaking_9 SMALLMONEY = 0,
	@auto_v2spositiontaking_20 SMALLMONEY = 0,

	@auto_v3spositiontaking_1 SMALLMONEY = 0,
	@auto_v3spositiontaking_2 SMALLMONEY = 0,
	@auto_v3spositiontaking_3 SMALLMONEY = 0,
	@auto_v3spositiontaking_20 SMALLMONEY = 0,

	@auto_v5spositiontaking_1 SMALLMONEY = 0,
	@auto_v5spositiontaking_2 SMALLMONEY = 0,
	@auto_v5spositiontaking_3 SMALLMONEY = 0,
	@auto_v5spositiontaking_20 SMALLMONEY = 0,

	@auto_v8spositiontaking_1 SMALLMONEY = 0,
	@auto_v8spositiontaking_3 SMALLMONEY = 0,
	@auto_v8spositiontaking_20 SMALLMONEY = 0,

	@auto_v10spositiontaking_1 SMALLMONEY = 0,
	@auto_v10spositiontaking_2 SMALLMONEY = 0,
	@auto_v10spositiontaking_3 SMALLMONEY = 0,
	@auto_v10spositiontaking_20 SMALLMONEY = 0,

	@auto_v11spositiontaking_1 SMALLMONEY = 0,
	@auto_v11spositiontaking_20 SMALLMONEY = 0,

	@auto_v99spositiontaking_1 SMALLMONEY = 0,
	@auto_v99spositiontaking_2 SMALLMONEY = 0,
	@auto_v99spositiontaking_3 SMALLMONEY = 0,
	@auto_v99spositiontaking_20 SMALLMONEY = 0,

	-- mixed sports
	@auto_v99spositiontaking_9 SMALLMONEY = 0,

	-- number game
	@auto_v161spositiontaking_81 SMALLMONEY = 0,
	@auto_v161spositiontaking_83 SMALLMONEY = 0,
	@auto_v161spositiontaking_86 SMALLMONEY = 0,
	@auto_v161spositiontaking_88 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_85 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_86 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_87 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_89 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_90 SMALLMONEY = 0,

	--i1
	@isauto_spositiontaking_1 BIT = 0,
	@isauto_spositiontaking_2 BIT = 0,
	@isauto_spositiontaking_3 BIT = 0,
	@isauto_spositiontaking_4 BIT = 0,
	@isauto_spositiontaking_5 bit= 0,
	@isauto_spositiontaking_6 BIT = 0,
	@isauto_spositiontaking_7 BIT = 0,
	@isauto_spositiontaking_8 BIT = 0,
	@isauto_spositiontaking_9 BIT = 0,
	@isauto_spositiontaking_10 BIT = 0,
	
	@isauto_slivepositiontaking_1 BIT = 0,
	@isauto_slivepositiontaking_3 BIT = 0,
	@isauto_slivepositiontaking_7 BIT = 0,
	@isauto_slivepositiontaking_8 BIT = 0,
	
	@isauto_v2spositiontaking_1 BIT = 0,
	@isauto_v2spositiontaking_2 BIT = 0,
	@isauto_v2spositiontaking_3 BIT = 0,
	@isauto_v2spositiontaking_7 BIT = 0,
	@isauto_v2spositiontaking_8 BIT = 0,
--	@isauto_v2spositiontaking_9 BIT = 0,
	@isauto_v2spositiontaking_20 BIT = 0,

	@isauto_v3spositiontaking_1 BIT = 0,
	@isauto_v3spositiontaking_2 BIT = 0,
	@isauto_v3spositiontaking_3 BIT = 0,
	@isauto_v3spositiontaking_20 BIT = 0,

	@isauto_v5spositiontaking_1 BIT = 0,
	@isauto_v5spositiontaking_2 BIT = 0,
	@isauto_v5spositiontaking_3 BIT = 0,
	@isauto_v5spositiontaking_20 BIT = 0,

	@isauto_v8spositiontaking_1 BIT = 0,
	@isauto_v8spositiontaking_3 BIT = 0,
	@isauto_v8spositiontaking_20 BIT = 0,

	@isauto_v10spositiontaking_1 BIT = 0,
	@isauto_v10spositiontaking_2 BIT = 0,
	@isauto_v10spositiontaking_3 BIT = 0,
	@isauto_v10spositiontaking_20 BIT = 0,

	@isauto_v11spositiontaking_1 BIT = 0,
	@isauto_v11spositiontaking_20 BIT = 0,

	@isauto_v99spositiontaking_1 BIT = 0,
	@isauto_v99spositiontaking_2 BIT = 0,
	@isauto_v99spositiontaking_3 BIT = 0,
	@isauto_v99spositiontaking_20 BIT = 0,

	-- mixed sports
	@isauto_v99spositiontaking_9 BIT = 0,	

	-- number game
	@isauto_v161spositiontaking_81 BIT = 0,	
	@isauto_v161spositiontaking_83 BIT = 0,	
	@isauto_v161spositiontaking_86 BIT = 0,	
	@isauto_v161spositiontaking_88 BIT = 0,	
	@isauto_v161slivepositiontaking_85 BIT = 0,	
	@isauto_v161slivepositiontaking_86 BIT = 0,	
	@isauto_v161slivepositiontaking_87 BIT = 0,	
	@isauto_v161slivepositiontaking_89 BIT = 0,
	@isauto_v161slivepositiontaking_90 BIT = 0,

	--i3
	@isauto_smpositiontaking_1 BIT = 0,
	@isauto_smpositiontaking_2 BIT = 0,
	@isauto_smpositiontaking_3 BIT = 0,
	@isauto_smpositiontaking_4 BIT = 0,
	@isauto_smpositiontaking_5 bit= 0,
	@isauto_smpositiontaking_6 BIT = 0,
	@isauto_smpositiontaking_7 BIT = 0,
	@isauto_smpositiontaking_8 BIT = 0,
	@isauto_smpositiontaking_9 BIT = 0,
	@isauto_smpositiontaking_10 BIT = 0,
	
	@isauto_smlivepositiontaking_1 BIT = 0,
	@isauto_smlivepositiontaking_3 BIT = 0,
	@isauto_smlivepositiontaking_7 BIT = 0,
	@isauto_smlivepositiontaking_8 BIT = 0,
	
	@isauto_v2smpositiontaking_1 BIT = 0,
	@isauto_v2smpositiontaking_2 BIT = 0,
	@isauto_v2smpositiontaking_3 BIT = 0,
	@isauto_v2smpositiontaking_7 BIT = 0,
	@isauto_v2smpositiontaking_8 BIT = 0,
--	@isauto_v2smpositiontaking_9 BIT = 0,
	@isauto_v2smpositiontaking_20 BIT = 0,

	@isauto_v3smpositiontaking_1 BIT = 0,
	@isauto_v3smpositiontaking_2 BIT = 0,
	@isauto_v3smpositiontaking_3 BIT = 0,
	@isauto_v3smpositiontaking_20 BIT = 0,

	@isauto_v5smpositiontaking_1 BIT = 0,
	@isauto_v5smpositiontaking_2 BIT = 0,
	@isauto_v5smpositiontaking_3 BIT = 0,
	@isauto_v5smpositiontaking_20 BIT = 0,

	@isauto_v8smpositiontaking_1 BIT = 0,
	@isauto_v8smpositiontaking_3 BIT = 0,
	@isauto_v8smpositiontaking_20 BIT = 0,

	@isauto_v10smpositiontaking_1 BIT = 0,
	@isauto_v10smpositiontaking_2 BIT = 0,
	@isauto_v10smpositiontaking_3 BIT = 0,
	@isauto_v10smpositiontaking_20 BIT = 0,

	@isauto_v11smpositiontaking_1 BIT = 0,
	@isauto_v11smpositiontaking_20 BIT = 0,

	@isauto_v99smpositiontaking_1 BIT = 0,
	@isauto_v99smpositiontaking_2 BIT = 0,
	@isauto_v99smpositiontaking_3 BIT = 0,
	@isauto_v99smpositiontaking_20 BIT = 0,

	-- mixed sports
	@isauto_v99smpositiontaking_9 BIT = 0,		

	-- number game
	@isauto_v161smpositiontaking_81 BIT = 0,		
	@isauto_v161smpositiontaking_83 BIT = 0,		
	@isauto_v161smpositiontaking_86 BIT = 0,		
	@isauto_v161smpositiontaking_88 BIT = 0,		
	@isauto_v161smlivepositiontaking_85 BIT = 0,		
	@isauto_v161smlivepositiontaking_86 BIT = 0,		
	@isauto_v161smlivepositiontaking_87 BIT = 0,		
	@isauto_v161smlivepositiontaking_89 BIT = 0,
	@isauto_v161smlivepositiontaking_90 BIT = 0,

	@UpdateMultiple BIT = 0,
	@UpdatePositiontaking BIT = 1,
	@UpdatePositiontakingv2 BIT = 1,
	@UpdatePositiontakingv3 BIT = 1,
	@UpdatePositiontakingv5 BIT = 1,
	@UpdatePositiontakingv8 BIT = 1,
	@UpdatePositiontakingv10 BIT = 1,
	@UpdatePositiontakingv11 BIT = 1,
	@UpdatePositiontakingv99 BIT = 1,
	@UpdatePositiontakingv99MP BIT = 1,
	@UpdatePositiontakingv161 BIT = 1,

	@language varchar(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080515@Thien
Task : Super edits Member
DB: DBTXN/bodb02
Original: Acc_CustomerUpdSuper_Member

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
	- 20090403@Phuc: Add new tag on write log session <isau> for i3
					 Check to update old value (disable FI cases) for update multiple member.
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.		
    - 20090717@Phuc: Enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR)
	- 20090801@Shifu: check disabled user
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091127@Jamie: Remove input @UpdateMultiple and write log @updatesuspended
	- 20100112@Kiwi: amEND to write log in xml format.
	- 20100730@Henry: grant execute to bodbExtAccNet
	- 20100908@Lukas:	- Add number game setting
						- Add mixed sports setting
						- Remove mix parlay of basketball
	- 20100925@Lukas:	check upline status WHEN update member status
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write Log Old values
	- 20110802@Lukas: (Number Game)
				- Add new bettypes: Warrior, Next Combo, Number Group
				- Remove Dead ball Over/Under
	- 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20111014@TOM: Apply Multiple Edit PT.
	- 20111223@Tom: Add parameter @UpdatePositiontaking_xxx to check multiple edit PT when call sp Acc_CustomerUpdMember_AutoPositiontaking
	- 20120704@Johnson: Remove setting hard code of number group
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

DECLARE @startRun DATETIME
DECLARE @ENDRun DATETIME
DECLARE @duration INT
SET @startRun = getdate()

/*
if not exists (select 1 from custinfo with (nolock) where custid = @custid and srecommEND in (181940,197461))
BEGIN
	DECLARE @ErrMsg varchar(200)
	SELECT @ErrMsg = 'Sorry, please try again later.'
	RaisError (@ErrMsg, 16, 1)
	return
END
*/
DECLARE @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @mrecommEND int, @recommEND int,	@srecommEND int

SELECT @DisabledFI = isnull(@DisabledFI,0), @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

SELECT @srecommEND = srecommEND, @mrecommEND = mrecommEND, @recommEND = recommEND, @username = username FROM custinfo WITH (NOLOCK) Where custid = @custid

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--END
 
-- Update customer info first
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
IF @disCasino = 1 AND EXISTS(SELECT 1 FROM Custinfo WITH (NOLOCK) WHERE syncCasino = 1 AND custID = @CustID)
	BEGIN
		IF @UpdateClosed = 1
		BEGIN
			SELECT @ErrMsg_Cur = case @Language 
								WHEN 'E' THEN 'This CLOSED function is temporarily unavailable, please update later.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60004,@Language)
							END	,
				@ErrCode_Cur = 902
				
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
		
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		IF @updatesuspended = 1
		BEGIN
			SELECT @ErrMsg_Cur = case @Language 
								WHEN 'E' THEN 'This SUSPENDED function is temporarily unavailable, please update later.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60001,@Language)
							END	,
				@ErrCode_Cur = 903
				
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
		
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
	END
ELSE
	BEGIN	--- update close
		IF @UpdateClosed = 1 --OR @closed is not null
		BEGIN
			EXEC [dbo].[Acc_CustomerUpdClosed] 
				@CustID = @CustID, 
				@Closed = @closed, 
				@SubAccID = @SubAccID, 
				@UserID = @UserID, 
				@disCasino = @disCasino, 
				@Language = @language,
				@ErrCode = @ErrCode_cur output, 
				@ErrMsg = @ErrMsg_cur output, 
				@IP = @IP
				
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		
		--- update SuspENDed
		IF @updatesuspended = 1 --OR @Suspended is not null
		BEGIN
			EXEC [dbo].[Acc_CustomerUpdSuspENDed] 
				@CustID = @CustID, 
				@Suspended = @Suspended, 
				@SubAccID = @SubAccID, 
				@UserID = @UserID, 
				@disCasino = @disCasino, 
				@Language = @language,
				@ErrCode = @ErrCode_cur output, 
				@ErrMsg = @ErrMsg_cur output, 
				@IP = @IP
				
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		/*
		UPDATE custinfo with (ROWLOCK, UPDLOCK) SET 
			closed= CASE WHEN @closed is null or @UpdateClosed = 0 THEN closed ELSE @closed END,
			reject = case  WHEN @Suspended is null or @updatesuspended = 0 THEN reject ELSE @Suspended END
		WHERE custid=@CustID
		*/
		SELECT @ErrCode = @ErrCode + '-102'+char(7), @ErrMsg = @ErrMsg + char(7)
		
	END

--Log customer info
DECLARE @LogSPData varchar(MAX)

Select @LogSPData = '<Acc_CustomerUpdMember_Super custid="'+ coalesce(cast(@CustID AS varchar(50)),space(1)) + '" ' +
	'Closed="'+ coalesce(cast(@Closed AS varchar(50)),space(1)) + '" ' +
	'ClosedMultiple="'+ coalesce(cast(@UpdateClosed AS varchar(2)),space(1)) + '" ' +
	'SuspENDed="'+ coalesce(cast(@Suspended AS varchar(2)),space(1)) + '" ' +
	'SuspENDedMultiple="'+ coalesce(cast(@updatesuspended AS varchar(2)),space(1)) + '" ' +
	'DisabledFI="'+ coalesce(cast(@DisabledFI AS varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID AS varchar(50)),space(1)) + '" ' +
	'language="'+ coalesce(cast(@language AS varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP AS varchar(15)),space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1116,
		@TrackingValue = @LogSPData
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMember_Super custid="'+ coalesce(cast(@CustID AS varchar(50)),space(1)) + '" ' +
		'Closed="'+ coalesce(cast(@Closed AS varchar(50)),space(1)) + '" ' +
		'ClosedMultiple="'+ coalesce(cast(@UpdateClosed AS varchar(2)),space(1)) + '" ' +
		'SuspENDed="'+ coalesce(cast(@Suspended AS varchar(2)),space(1)) + '" ' +
		'SuspENDedMultiple="'+ coalesce(cast(@updatesuspended AS varchar(2)),space(1)) + '" ' +
		'DisabledFI="'+ coalesce(cast(@DisabledFI AS varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID AS varchar(50)),space(1)) + '" ' +
		'language="'+ coalesce(cast(@language AS varchar(2)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP AS varchar(15)),space(1)) + '" />'

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1116,
		@TrackingValue = @LogSPData
END CATCH

--Update Position Taking
if	@UpdatePositiontaking   = 1  or
	@UpdatePositiontakingv2   = 1  or
	@UpdatePositiontakingv3   = 1  or
	@UpdatePositiontakingv5   = 1  or
	@UpdatePositiontakingv8   = 1  or
	@UpdatePositiontakingv10   = 1  or
	@UpdatePositiontakingv11   = 1  or
	@UpdatePositiontakingv99   = 1  or
	@UpdatePositiontakingv99MP = 1 or
	@UpdatePositiontakingv161 = 1
BEGIN--Update Position Taking
	DECLARE 
		@mpositiontaking_1 SMALLMONEY,
		@mpositiontaking_2 SMALLMONEY,
		@mpositiontaking_3 SMALLMONEY,
		@mpositiontaking_4 SMALLMONEY,
		@mpositiontaking_5 SMALLMONEY,
		@mpositiontaking_6 SMALLMONEY,
		@mpositiontaking_7 SMALLMONEY,
		@mpositiontaking_8 SMALLMONEY,
		@mpositiontaking_9 SMALLMONEY,
		@mpositiontaking_10 SMALLMONEY,
		@mlivepositiontaking_1 SMALLMONEY,
		@mlivepositiontaking_3 SMALLMONEY,
		@mlivepositiontaking_7 SMALLMONEY,
		@mlivepositiontaking_8 SMALLMONEY,
		
		@v2mpositiontaking_1 SMALLMONEY,
		@v2mpositiontaking_2 SMALLMONEY,
		@v2mpositiontaking_3 SMALLMONEY,
		@v2mpositiontaking_7 SMALLMONEY,
		@v2mpositiontaking_8 SMALLMONEY,
	--	@v2mpositiontaking_9 SMALLMONEY,
		@v2mpositiontaking_20 SMALLMONEY,
		
		@v3mpositiontaking_1 SMALLMONEY,
		@v3mpositiontaking_2 SMALLMONEY,
		@v3mpositiontaking_3 SMALLMONEY,
		@v3mpositiontaking_20 SMALLMONEY,

		@v5mpositiontaking_1 SMALLMONEY,
		@v5mpositiontaking_2 SMALLMONEY,
		@v5mpositiontaking_3 SMALLMONEY,
		@v5mpositiontaking_20 SMALLMONEY,

		@v8mpositiontaking_1 SMALLMONEY,
		@v8mpositiontaking_3 SMALLMONEY,
		@v8mpositiontaking_20 SMALLMONEY,

		@v10mpositiontaking_1 SMALLMONEY,
		@v10mpositiontaking_2 SMALLMONEY,
		@v10mpositiontaking_3 SMALLMONEY,
		@v10mpositiontaking_20 SMALLMONEY,

		@v11mpositiontaking_1 SMALLMONEY,
		@v11mpositiontaking_20 SMALLMONEY,

		@v99mpositiontaking_1 SMALLMONEY,
		@v99mpositiontaking_2 SMALLMONEY,
		@v99mpositiontaking_3 SMALLMONEY,
		@v99mpositiontaking_20 SMALLMONEY,

		-- mixed sports
		@v99mpositiontaking_9 SMALLMONEY,

		-- number game
		@v161mpositiontaking_81 SMALLMONEY,
		@v161mpositiontaking_83 SMALLMONEY,
		@v161mpositiontaking_86 SMALLMONEY,
		@v161mpositiontaking_88 SMALLMONEY,
		@v161mlivepositiontaking_85 SMALLMONEY,
		@v161mlivepositiontaking_86 SMALLMONEY,
		@v161mlivepositiontaking_87 SMALLMONEY,
		@v161mlivepositiontaking_89 SMALLMONEY,
		@v161mlivepositiontaking_90 SMALLMONEY,
		
		@old_spositiontaking_1 SMALLMONEY,
		@old_spositiontaking_2 SMALLMONEY,
		@old_spositiontaking_3 SMALLMONEY,
		@old_spositiontaking_4 SMALLMONEY,
		@old_spositiontaking_5 SMALLMONEY,
		@old_spositiontaking_6 SMALLMONEY,
		@old_spositiontaking_7 SMALLMONEY,
		@old_spositiontaking_8 SMALLMONEY,
		@old_spositiontaking_9 SMALLMONEY,
		@old_spositiontaking_10 SMALLMONEY,
		
		@old_slivepositiontaking_1 SMALLMONEY,
		@old_slivepositiontaking_3 SMALLMONEY,
		@old_slivepositiontaking_7 SMALLMONEY,
		@old_slivepositiontaking_8 SMALLMONEY,
		
		@old_v2spositiontaking_1 SMALLMONEY,
		@old_v2spositiontaking_2 SMALLMONEY,
		@old_v2spositiontaking_3 SMALLMONEY,
		@old_v2spositiontaking_7 SMALLMONEY,
		@old_v2spositiontaking_8 SMALLMONEY,
	--	@old_v2spositiontaking_9 SMALLMONEY,
		@old_v2spositiontaking_20 SMALLMONEY,
		
		@old_v3spositiontaking_1 SMALLMONEY,
		@old_v3spositiontaking_2 SMALLMONEY,
		@old_v3spositiontaking_3 SMALLMONEY,
		@old_v3spositiontaking_20 SMALLMONEY,

		@old_v5spositiontaking_1 SMALLMONEY,
		@old_v5spositiontaking_2 SMALLMONEY,
		@old_v5spositiontaking_3 SMALLMONEY,
		@old_v5spositiontaking_20 SMALLMONEY,

		@old_v8spositiontaking_1 SMALLMONEY,
		@old_v8spositiontaking_3 SMALLMONEY,
		@old_v8spositiontaking_20 SMALLMONEY,

		@old_v10spositiontaking_1 SMALLMONEY,
		@old_v10spositiontaking_2 SMALLMONEY,
		@old_v10spositiontaking_3 SMALLMONEY,
		@old_v10spositiontaking_20 SMALLMONEY,

		@old_v11spositiontaking_1 SMALLMONEY,
		@old_v11spositiontaking_20 SMALLMONEY,

		@old_v99spositiontaking_1 SMALLMONEY,
		@old_v99spositiontaking_2 SMALLMONEY,
		@old_v99spositiontaking_3 SMALLMONEY,
		@old_v99spositiontaking_20 SMALLMONEY,

		-- mixed sports
		@old_v99spositiontaking_9 SMALLMONEY,

		-- number game
		@old_v161spositiontaking_81 SMALLMONEY,
		@old_v161spositiontaking_83 SMALLMONEY,
		@old_v161spositiontaking_86 SMALLMONEY,
		@old_v161spositiontaking_88 SMALLMONEY,
		@old_v161slivepositiontaking_85 SMALLMONEY,
		@old_v161slivepositiontaking_86 SMALLMONEY,
		@old_v161slivepositiontaking_87 SMALLMONEY,
		@old_v161slivepositiontaking_89 SMALLMONEY,
		@old_v161slivepositiontaking_90 SMALLMONEY,

		@apositiontaking_1 SMALLMONEY,
		@apositiontaking_2 SMALLMONEY,
		@apositiontaking_3 SMALLMONEY,
		@apositiontaking_4 SMALLMONEY,
		@apositiontaking_5 SMALLMONEY,
		@apositiontaking_6 SMALLMONEY,
		@apositiontaking_7 SMALLMONEY,
		@apositiontaking_8 SMALLMONEY,
		@apositiontaking_9 SMALLMONEY,
		@apositiontaking_10 SMALLMONEY,
		@alivepositiontaking_1 SMALLMONEY,
		@alivepositiontaking_3 SMALLMONEY,
		@alivepositiontaking_7 SMALLMONEY,
		@alivepositiontaking_8 SMALLMONEY,
		
		@v2apositiontaking_1 SMALLMONEY,
		@v2apositiontaking_2 SMALLMONEY,
		@v2apositiontaking_3 SMALLMONEY,
		@v2apositiontaking_7 SMALLMONEY,
		@v2apositiontaking_8 SMALLMONEY,
	--	@v2apositiontaking_9 SMALLMONEY,
		@v2apositiontaking_20 SMALLMONEY,
		
		@v3apositiontaking_1 SMALLMONEY,
		@v3apositiontaking_2 SMALLMONEY,
		@v3apositiontaking_3 SMALLMONEY,
		@v3apositiontaking_20 SMALLMONEY,

		@v5apositiontaking_1 SMALLMONEY,
		@v5apositiontaking_2 SMALLMONEY,
		@v5apositiontaking_3 SMALLMONEY,
		@v5apositiontaking_20 SMALLMONEY,

		@v8apositiontaking_1 SMALLMONEY,
		@v8apositiontaking_3 SMALLMONEY,
		@v8apositiontaking_20 SMALLMONEY,

		@v10apositiontaking_1 SMALLMONEY,
		@v10apositiontaking_2 SMALLMONEY,
		@v10apositiontaking_3 SMALLMONEY,
		@v10apositiontaking_20 SMALLMONEY,

		@v11apositiontaking_1 SMALLMONEY,
		@v11apositiontaking_20 SMALLMONEY,

		@v99apositiontaking_1 SMALLMONEY,
		@v99apositiontaking_2 SMALLMONEY,
		@v99apositiontaking_3 SMALLMONEY,
		@v99apositiontaking_20 SMALLMONEY,
		
		-- mixed sports
		@v99apositiontaking_9 SMALLMONEY,

		-- number game
		@v161apositiontaking_81 SMALLMONEY,
		@v161apositiontaking_83 SMALLMONEY,
		@v161apositiontaking_86 SMALLMONEY,
		@v161apositiontaking_88 SMALLMONEY,
		@v161alivepositiontaking_85 SMALLMONEY,
		@v161alivepositiontaking_86 SMALLMONEY,
		@v161alivepositiontaking_87 SMALLMONEY,
		@v161alivepositiontaking_89 SMALLMONEY,
		@v161alivepositiontaking_90 SMALLMONEY,

		@spositiontaking_1_max SMALLMONEY,
		@spositiontaking_2_max SMALLMONEY,
		@spositiontaking_3_max SMALLMONEY,
		@spositiontaking_4_max SMALLMONEY,
		@spositiontaking_5_max SMALLMONEY,
		@spositiontaking_6_max SMALLMONEY,
		@spositiontaking_7_max SMALLMONEY,
		@spositiontaking_8_max SMALLMONEY,
		@spositiontaking_9_max SMALLMONEY,
		@spositiontaking_10_max SMALLMONEY,
		
		@slivepositiontaking_1_max SMALLMONEY,
		@slivepositiontaking_3_max SMALLMONEY,
		@slivepositiontaking_7_max SMALLMONEY,
		@slivepositiontaking_8_max SMALLMONEY,
		
		@v2spositiontaking_1_max SMALLMONEY,
		@v2spositiontaking_2_max SMALLMONEY,
		@v2spositiontaking_3_max SMALLMONEY,
		@v2spositiontaking_7_max SMALLMONEY,
		@v2spositiontaking_8_max SMALLMONEY,
	--	@v2spositiontaking_9_max SMALLMONEY,
		@v2spositiontaking_20_max SMALLMONEY,
		
		@v3spositiontaking_1_max SMALLMONEY,
		@v3spositiontaking_2_max SMALLMONEY,
		@v3spositiontaking_3_max SMALLMONEY,
		@v3spositiontaking_20_max SMALLMONEY,

		@v5spositiontaking_1_max SMALLMONEY,
		@v5spositiontaking_2_max SMALLMONEY,
		@v5spositiontaking_3_max SMALLMONEY,
		@v5spositiontaking_20_max SMALLMONEY,

		@v8spositiontaking_1_max SMALLMONEY,
		@v8spositiontaking_3_max SMALLMONEY,
		@v8spositiontaking_20_max SMALLMONEY,

		@v10spositiontaking_1_max SMALLMONEY,
		@v10spositiontaking_2_max SMALLMONEY,
		@v10spositiontaking_3_max SMALLMONEY,
		@v10spositiontaking_20_max SMALLMONEY,

		@v11spositiontaking_1_max SMALLMONEY,
		@v11spositiontaking_20_max SMALLMONEY,

		@v99spositiontaking_1_max SMALLMONEY,
		@v99spositiontaking_2_max SMALLMONEY,
		@v99spositiontaking_3_max SMALLMONEY,
		@v99spositiontaking_20_max SMALLMONEY,
		
		-- mixed sports
		@v99spositiontaking_9_max SMALLMONEY,
		
		-- number game
		@v161spositiontaking_81_max SMALLMONEY,
		@v161spositiontaking_83_max SMALLMONEY,
		@v161spositiontaking_86_max SMALLMONEY,
		@v161spositiontaking_88_max SMALLMONEY,
		@v161slivepositiontaking_85_max SMALLMONEY,
		@v161slivepositiontaking_86_max SMALLMONEY,
		@v161slivepositiontaking_87_max SMALLMONEY,
		@v161slivepositiontaking_89_max SMALLMONEY,
		@v161slivepositiontaking_90_max SMALLMONEY,

		--Old u1,i1
		@old_auto_spositiontaking_1 SMALLMONEY ,
		@old_auto_spositiontaking_2 SMALLMONEY ,
		@old_auto_spositiontaking_3 SMALLMONEY ,
		@old_auto_spositiontaking_4 SMALLMONEY ,
		@old_auto_spositiontaking_5 SMALLMONEY,
		@old_auto_spositiontaking_6 SMALLMONEY ,
		@old_auto_spositiontaking_7 SMALLMONEY ,
		@old_auto_spositiontaking_8 SMALLMONEY ,
		@old_auto_spositiontaking_9 SMALLMONEY ,
		@old_auto_spositiontaking_10 SMALLMONEY ,
		
		@old_auto_slivepositiontaking_1 SMALLMONEY ,
		@old_auto_slivepositiontaking_3 SMALLMONEY ,
		@old_auto_slivepositiontaking_7 SMALLMONEY ,
		@old_auto_slivepositiontaking_8 SMALLMONEY ,
		
		@old_auto_v2spositiontaking_1 SMALLMONEY ,
		@old_auto_v2spositiontaking_2 SMALLMONEY ,
		@old_auto_v2spositiontaking_3 SMALLMONEY ,
		@old_auto_v2spositiontaking_7 SMALLMONEY ,
		@old_auto_v2spositiontaking_8 SMALLMONEY ,
	--	@old_auto_v2spositiontaking_9 SMALLMONEY ,
		@old_auto_v2spositiontaking_20 SMALLMONEY ,

		@old_auto_v3spositiontaking_1 SMALLMONEY ,
		@old_auto_v3spositiontaking_2 SMALLMONEY ,
		@old_auto_v3spositiontaking_3 SMALLMONEY ,
		@old_auto_v3spositiontaking_20 SMALLMONEY ,

		@old_auto_v5spositiontaking_1 SMALLMONEY ,
		@old_auto_v5spositiontaking_2 SMALLMONEY ,
		@old_auto_v5spositiontaking_3 SMALLMONEY ,
		@old_auto_v5spositiontaking_20 SMALLMONEY ,

		@old_auto_v8spositiontaking_1 SMALLMONEY ,
		@old_auto_v8spositiontaking_3 SMALLMONEY ,
		@old_auto_v8spositiontaking_20 SMALLMONEY ,

		@old_auto_v10spositiontaking_1 SMALLMONEY ,
		@old_auto_v10spositiontaking_2 SMALLMONEY ,
		@old_auto_v10spositiontaking_3 SMALLMONEY ,
		@old_auto_v10spositiontaking_20 SMALLMONEY ,

		@old_auto_v11spositiontaking_1 SMALLMONEY ,
		@old_auto_v11spositiontaking_20 SMALLMONEY ,

		@old_auto_v99spositiontaking_1 SMALLMONEY ,
		@old_auto_v99spositiontaking_2 SMALLMONEY ,
		@old_auto_v99spositiontaking_3 SMALLMONEY ,
		@old_auto_v99spositiontaking_20 SMALLMONEY ,

		-- mixed sports
		@old_auto_v99spositiontaking_9 SMALLMONEY ,	

		-- number game
		@old_auto_v161spositiontaking_81 SMALLMONEY ,
		@old_auto_v161spositiontaking_83 SMALLMONEY ,
		@old_auto_v161spositiontaking_86 SMALLMONEY ,
		@old_auto_v161spositiontaking_88 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_85 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_86 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_87 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_89 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_90 SMALLMONEY ,

		@old_isauto_spositiontaking_1 BIT ,
		@old_isauto_spositiontaking_2 BIT ,
		@old_isauto_spositiontaking_3 BIT ,
		@old_isauto_spositiontaking_4 BIT ,
		@old_isauto_spositiontaking_5 bit,
		@old_isauto_spositiontaking_6 BIT ,
		@old_isauto_spositiontaking_7 BIT ,
		@old_isauto_spositiontaking_8 BIT ,
		@old_isauto_spositiontaking_9 BIT ,
		@old_isauto_spositiontaking_10 BIT ,
		
		@old_isauto_slivepositiontaking_1 BIT ,
		@old_isauto_slivepositiontaking_3 BIT ,
		@old_isauto_slivepositiontaking_7 BIT ,
		@old_isauto_slivepositiontaking_8 BIT ,
		
		@old_isauto_v2spositiontaking_1 BIT ,
		@old_isauto_v2spositiontaking_2 BIT ,
		@old_isauto_v2spositiontaking_3 BIT ,
		@old_isauto_v2spositiontaking_7 BIT ,
		@old_isauto_v2spositiontaking_8 BIT ,
	--	@old_isauto_v2spositiontaking_9 BIT ,
		@old_isauto_v2spositiontaking_20 BIT ,

		@old_isauto_v3spositiontaking_1 BIT ,
		@old_isauto_v3spositiontaking_2 BIT ,
		@old_isauto_v3spositiontaking_3 BIT ,
		@old_isauto_v3spositiontaking_20 BIT ,

		@old_isauto_v5spositiontaking_1 BIT ,
		@old_isauto_v5spositiontaking_2 BIT ,
		@old_isauto_v5spositiontaking_3 BIT ,
		@old_isauto_v5spositiontaking_20 BIT ,

		@old_isauto_v8spositiontaking_1 BIT ,
		@old_isauto_v8spositiontaking_3 BIT ,
		@old_isauto_v8spositiontaking_20 BIT ,

		@old_isauto_v10spositiontaking_1 BIT ,
		@old_isauto_v10spositiontaking_2 BIT ,
		@old_isauto_v10spositiontaking_3 BIT ,
		@old_isauto_v10spositiontaking_20 BIT ,

		@old_isauto_v11spositiontaking_1 BIT ,
		@old_isauto_v11spositiontaking_20 BIT ,

		@old_isauto_v99spositiontaking_1 BIT ,
		@old_isauto_v99spositiontaking_2 BIT ,
		@old_isauto_v99spositiontaking_3 BIT ,
		@old_isauto_v99spositiontaking_20 BIT ,

		-- mixed sports
		@old_isauto_v99spositiontaking_9 BIT ,
		
		-- number game
		@old_isauto_v161spositiontaking_81 BIT ,
		@old_isauto_v161spositiontaking_83 BIT ,
		@old_isauto_v161spositiontaking_86 BIT ,
		@old_isauto_v161spositiontaking_88 BIT ,
		@old_isauto_v161slivepositiontaking_85 BIT ,
		@old_isauto_v161slivepositiontaking_86 BIT ,
		@old_isauto_v161slivepositiontaking_87 BIT ,
		@old_isauto_v161slivepositiontaking_89 BIT ,
		@old_isauto_v161slivepositiontaking_90 BIT


	DECLARE @ErrType varchar(1000) 
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Check param
	DECLARE @IsValid bit
	SELECT @IsValid = 1



	--Check Old_PT <> New_PT
	SELECT @apositiontaking_1 = apositiontaking, @alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @old_spositiontaking_1 = spositiontaking, @old_slivepositiontaking_1 = slivepositiontaking, @old_auto_spositiontaking_1 = autopositiontaking, @old_auto_slivepositiontaking_1 = autolivepositiontaking, @old_isauto_spositiontaking_1 = isautopositiontaking, @old_isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1
	SELECT @apositiontaking_3 = apositiontaking, @alivepositiontaking_3 = alivepositiontaking,@mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @old_spositiontaking_3 = spositiontaking, @old_slivepositiontaking_3 = slivepositiontaking, @old_auto_spositiontaking_3 = autopositiontaking, @old_auto_slivepositiontaking_3 = autolivepositiontaking, @old_isauto_spositiontaking_3 = isautopositiontaking, @old_isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1
	SELECT @apositiontaking_7 = apositiontaking, @alivepositiontaking_7 = alivepositiontaking,@mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @old_spositiontaking_7 = spositiontaking, @old_slivepositiontaking_7 = slivepositiontaking, @old_auto_spositiontaking_7 = autopositiontaking, @old_auto_slivepositiontaking_7 = autolivepositiontaking, @old_isauto_spositiontaking_7 = isautopositiontaking, @old_isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1
	SELECT @apositiontaking_8 = apositiontaking, @alivepositiontaking_8 = alivepositiontaking,@mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @old_spositiontaking_8 = spositiontaking, @old_slivepositiontaking_8 = slivepositiontaking, @old_auto_spositiontaking_8 = autopositiontaking, @old_auto_slivepositiontaking_8 = autolivepositiontaking, @old_isauto_spositiontaking_8 = isautopositiontaking, @old_isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

	SELECT @apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @old_spositiontaking_2 = spositiontaking, @old_auto_spositiontaking_2 = autopositiontaking, @old_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
	SELECT @apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @old_spositiontaking_4 = spositiontaking, @old_auto_spositiontaking_4 = autopositiontaking, @old_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
	SELECT @apositiontaking_5 = apositiontaking, @mpositiontaking_5 = mpositiontaking, @old_spositiontaking_5 = spositiontaking, @old_auto_spositiontaking_5 = autopositiontaking, @old_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
	SELECT @apositiontaking_6 = apositiontaking, @mpositiontaking_6 = mpositiontaking, @old_spositiontaking_6 = spositiontaking, @old_auto_spositiontaking_6 = autopositiontaking, @old_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
	SELECT @apositiontaking_9 = apositiontaking, @mpositiontaking_9 = mpositiontaking, @old_spositiontaking_9 = spositiontaking, @old_auto_spositiontaking_9 = autopositiontaking, @old_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
	SELECT @apositiontaking_10 = apositiontaking, @mpositiontaking_10 = mpositiontaking, @old_spositiontaking_10 = spositiontaking, @old_auto_spositiontaking_10 = autopositiontaking, @old_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1

	SELECT @v2apositiontaking_1 = apositiontaking, @v2mpositiontaking_1 = mpositiontaking, @old_v2spositiontaking_1 = spositiontaking, @old_auto_v2spositiontaking_1 = autopositiontaking, @old_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2
	SELECT @v2apositiontaking_2 = apositiontaking, @v2mpositiontaking_2 = mpositiontaking, @old_v2spositiontaking_2 = spositiontaking, @old_auto_v2spositiontaking_2 = autopositiontaking, @old_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2
	SELECT @v2apositiontaking_3 = apositiontaking, @v2mpositiontaking_3 = mpositiontaking, @old_v2spositiontaking_3 = spositiontaking, @old_auto_v2spositiontaking_3 = autopositiontaking, @old_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2
	SELECT @v2apositiontaking_7 = apositiontaking, @v2mpositiontaking_7 = mpositiontaking, @old_v2spositiontaking_7 = spositiontaking, @old_auto_v2spositiontaking_7 = autopositiontaking, @old_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2
	SELECT @v2apositiontaking_8 = apositiontaking, @v2mpositiontaking_8 = mpositiontaking, @old_v2spositiontaking_8 = spositiontaking, @old_auto_v2spositiontaking_8 = autopositiontaking, @old_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2
	--select @v2apositiontaking_9 = apositiontaking, @v2mpositiontaking_9 = mpositiontaking, @old_v2spositiontaking_9 = spositiontaking, @old_auto_v2spositiontaking_9 = autopositiontaking, @old_isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=2
	SELECT @v2apositiontaking_20 = apositiontaking, @v2mpositiontaking_20 = mpositiontaking, @old_v2spositiontaking_20 = spositiontaking, @old_auto_v2spositiontaking_20 = autopositiontaking, @old_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2

	SELECT @v3apositiontaking_1 = apositiontaking, @v3mpositiontaking_1 = mpositiontaking, @old_v3spositiontaking_1 = spositiontaking, @old_auto_v3spositiontaking_1 = autopositiontaking, @old_isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3
	SELECT @v3apositiontaking_2 = apositiontaking, @v3mpositiontaking_2 = mpositiontaking, @old_v3spositiontaking_2 = spositiontaking, @old_auto_v3spositiontaking_2 = autopositiontaking, @old_isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3
	SELECT @v3apositiontaking_3 = apositiontaking, @v3mpositiontaking_3 = mpositiontaking, @old_v3spositiontaking_3 = spositiontaking, @old_auto_v3spositiontaking_3 = autopositiontaking, @old_isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3
	SELECT @v3apositiontaking_20 = apositiontaking, @v3mpositiontaking_20 = mpositiontaking, @old_v3spositiontaking_20 = spositiontaking, @old_auto_v3spositiontaking_20 = autopositiontaking, @old_isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3

	SELECT @v5apositiontaking_1 = apositiontaking, @v5mpositiontaking_1 = mpositiontaking, @old_v5spositiontaking_1 = spositiontaking, @old_auto_v5spositiontaking_1 = autopositiontaking, @old_isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5
	SELECT @v5apositiontaking_2 = apositiontaking, @v5mpositiontaking_2 = mpositiontaking, @old_v5spositiontaking_2 = spositiontaking, @old_auto_v5spositiontaking_2 = autopositiontaking, @old_isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5
	SELECT @v5apositiontaking_3 = apositiontaking, @v5mpositiontaking_3 = mpositiontaking, @old_v5spositiontaking_3 = spositiontaking, @old_auto_v5spositiontaking_3 = autopositiontaking, @old_isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5
	SELECT @v5apositiontaking_20 = apositiontaking, @v5mpositiontaking_20 = mpositiontaking, @old_v5spositiontaking_20 = spositiontaking, @old_auto_v5spositiontaking_20 = autopositiontaking, @old_isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5

	SELECT @v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @old_v8spositiontaking_1 = spositiontaking, @old_auto_v8spositiontaking_1 = autopositiontaking, @old_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
	SELECT @v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @old_v8spositiontaking_3 = spositiontaking, @old_auto_v8spositiontaking_3 = autopositiontaking, @old_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
	SELECT @v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @old_v8spositiontaking_20 = spositiontaking, @old_auto_v8spositiontaking_20 = autopositiontaking, @old_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

	SELECT @v10apositiontaking_1 = apositiontaking, @v10mpositiontaking_1 = mpositiontaking, @old_v10spositiontaking_1 = spositiontaking, @old_auto_v10spositiontaking_1 = autopositiontaking, @old_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10
	SELECT @v10apositiontaking_2 = apositiontaking, @v10mpositiontaking_2 = mpositiontaking, @old_v10spositiontaking_2 = spositiontaking, @old_auto_v10spositiontaking_2 = autopositiontaking, @old_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10
	SELECT @v10apositiontaking_3 = apositiontaking, @v10mpositiontaking_3 = mpositiontaking, @old_v10spositiontaking_3 = spositiontaking, @old_auto_v10spositiontaking_3 = autopositiontaking, @old_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10
	SELECT @v10apositiontaking_20 = apositiontaking, @v10mpositiontaking_20 = mpositiontaking, @old_v10spositiontaking_20 = spositiontaking, @old_auto_v10spositiontaking_20 = autopositiontaking, @old_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10

	SELECT @v11apositiontaking_1 = apositiontaking, @v11mpositiontaking_1 = mpositiontaking, @old_v11spositiontaking_1 = spositiontaking, @old_auto_v11spositiontaking_1 = autopositiontaking, @old_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11
	SELECT @v11apositiontaking_20 = apositiontaking, @v11mpositiontaking_20 = mpositiontaking, @old_v11spositiontaking_20 = spositiontaking, @old_auto_v11spositiontaking_20 = autopositiontaking, @old_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11

	SELECT @v99apositiontaking_1 = apositiontaking, @v99mpositiontaking_1 = mpositiontaking, @old_v99spositiontaking_1 = spositiontaking, @old_auto_v99spositiontaking_1 = autopositiontaking, @old_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99
	SELECT @v99apositiontaking_2 = apositiontaking, @v99mpositiontaking_2 = mpositiontaking, @old_v99spositiontaking_2 = spositiontaking, @old_auto_v99spositiontaking_2 = autopositiontaking, @old_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99
	SELECT @v99apositiontaking_3 = apositiontaking, @v99mpositiontaking_3 = mpositiontaking, @old_v99spositiontaking_3 = spositiontaking, @old_auto_v99spositiontaking_3 = autopositiontaking, @old_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99
	SELECT @v99apositiontaking_20 = apositiontaking, @v99mpositiontaking_20 = mpositiontaking, @old_v99spositiontaking_20 = spositiontaking, @old_auto_v99spositiontaking_20 = autopositiontaking, @old_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99

	-- mixed sports
	SELECT @v99apositiontaking_9 = apositiontaking, @v99mpositiontaking_9 = mpositiontaking, @old_v99spositiontaking_9 = spositiontaking, @old_auto_v99spositiontaking_9 = autopositiontaking, @old_isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99

	-- number game
	SELECT @v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @old_v161spositiontaking_81 = spositiontaking, @old_auto_v161spositiontaking_81 = autopositiontaking, @old_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
	SELECT @v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @old_v161spositiontaking_83 = spositiontaking, @old_auto_v161spositiontaking_83 = autopositiontaking, @old_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
	SELECT @v161apositiontaking_86 = apositiontaking, @v161mpositiontaking_86 = mpositiontaking, @old_v161spositiontaking_86 = spositiontaking, @old_auto_v161spositiontaking_86 = autopositiontaking, @old_isauto_v161spositiontaking_86 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
	SELECT @v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @old_v161spositiontaking_88 = spositiontaking, @old_auto_v161spositiontaking_88 = autopositiontaking, @old_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
	SELECT @v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161slivepositiontaking_85 = slivepositiontaking, @old_auto_v161slivepositiontaking_85 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
	SELECT @v161alivepositiontaking_86 = alivepositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161slivepositiontaking_86 = slivepositiontaking, @old_auto_v161slivepositiontaking_86 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
	SELECT @v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161slivepositiontaking_87 = slivepositiontaking, @old_auto_v161slivepositiontaking_87 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
	SELECT @v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161slivepositiontaking_89 = slivepositiontaking, @old_auto_v161slivepositiontaking_89 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
	SELECT @v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161slivepositiontaking_90 = slivepositiontaking, @old_auto_v161slivepositiontaking_90 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161

	IF @spositiontaking_1 = @old_spositiontaking_1 AND
		@spositiontaking_2 = @old_spositiontaking_2 AND
		@spositiontaking_3 = @old_spositiontaking_3 AND
		@spositiontaking_4 = @old_spositiontaking_4 AND
		@spositiontaking_5 = @old_spositiontaking_5 AND
		@spositiontaking_6 = @old_spositiontaking_6 AND
		@spositiontaking_7 = @old_spositiontaking_7 AND
		@spositiontaking_8 = @old_spositiontaking_8 AND
		@spositiontaking_9 = @old_spositiontaking_9 AND
		@spositiontaking_10 = @old_spositiontaking_10 AND
		@slivepositiontaking_1 = @old_slivepositiontaking_1 AND
		@slivepositiontaking_3 = @old_slivepositiontaking_3 AND
		@slivepositiontaking_7 = @old_slivepositiontaking_7 AND
		@slivepositiontaking_8 = @old_slivepositiontaking_8 AND

		@v2spositiontaking_1 = @old_v2spositiontaking_1 AND
		@v2spositiontaking_2 = @old_v2spositiontaking_2 AND
		@v2spositiontaking_3 = @old_v2spositiontaking_3 AND
		@v2spositiontaking_7 = @old_v2spositiontaking_7 AND
		@v2spositiontaking_8 = @old_v2spositiontaking_8 AND
	--	@v2spositiontaking_9 = @old_v2spositiontaking_9 AND
		@v2spositiontaking_20 = @old_v2spositiontaking_20 AND
		
		@v3spositiontaking_1 = @old_v3spositiontaking_1 AND
		@v3spositiontaking_2 = @old_v3spositiontaking_2 AND
		@v3spositiontaking_3 = @old_v3spositiontaking_3 AND
		@v3spositiontaking_20 = @old_v3spositiontaking_20 AND
		
		@v5spositiontaking_1 = @old_v5spositiontaking_1 AND
		@v5spositiontaking_2 = @old_v5spositiontaking_2 AND
		@v5spositiontaking_3 = @old_v5spositiontaking_3 AND
		@v5spositiontaking_20 = @old_v5spositiontaking_20 AND
		
		@v8spositiontaking_1 = @old_v8spositiontaking_1 AND
		@v8spositiontaking_3 = @old_v8spositiontaking_3 AND
		@v8spositiontaking_20 = @old_v8spositiontaking_20 AND
		
		@v10spositiontaking_1 = @old_v10spositiontaking_1 AND
		@v10spositiontaking_2 = @old_v10spositiontaking_2 AND
		@v10spositiontaking_3 = @old_v10spositiontaking_3 AND
		@v10spositiontaking_20 = @old_v10spositiontaking_20 AND
		
		@v11spositiontaking_1 = @old_v11spositiontaking_1 AND
		@v11spositiontaking_20 = @old_v11spositiontaking_20 AND
		
		@v99spositiontaking_1 = @old_v99spositiontaking_1 AND
		@v99spositiontaking_2 = @old_v99spositiontaking_2 AND
		@v99spositiontaking_3 = @old_v99spositiontaking_3 AND
		@v99spositiontaking_20 = @old_v99spositiontaking_20 AND

		-- mixed sports
		@v99spositiontaking_9 = @old_v99spositiontaking_9 AND
		-- number game
		@v161spositiontaking_81 = @old_v161spositiontaking_81 AND
		@v161spositiontaking_83 = @old_v161spositiontaking_83 AND
		@v161spositiontaking_86 = @old_v161spositiontaking_86 AND
		@v161spositiontaking_88 = @old_v161spositiontaking_88 AND
		@v161slivepositiontaking_85 = @old_v161slivepositiontaking_85 AND
		@v161slivepositiontaking_86 = @old_v161slivepositiontaking_86 AND
		@v161slivepositiontaking_87 = @old_v161slivepositiontaking_87 AND
		@v161slivepositiontaking_89 = @old_v161slivepositiontaking_89 AND
		@v161slivepositiontaking_90 = @old_v161slivepositiontaking_90 AND
		
		@auto_spositiontaking_1 = @old_auto_spositiontaking_1 AND
		@auto_spositiontaking_2 = @old_auto_spositiontaking_2 AND
		@auto_spositiontaking_3 = @old_auto_spositiontaking_3 AND
		@auto_spositiontaking_4 = @old_auto_spositiontaking_4 AND
		@auto_spositiontaking_5 = @old_auto_spositiontaking_5 AND
		@auto_spositiontaking_6 = @old_auto_spositiontaking_6 AND
		@auto_spositiontaking_7 = @old_auto_spositiontaking_7 AND
		@auto_spositiontaking_8 = @old_auto_spositiontaking_8 AND
		@auto_spositiontaking_9 = @old_auto_spositiontaking_9 AND
		@auto_spositiontaking_10 = @old_auto_spositiontaking_10 AND
		@auto_slivepositiontaking_1 = @old_auto_slivepositiontaking_1 AND
		@auto_slivepositiontaking_3 = @old_auto_slivepositiontaking_3 AND
		@auto_slivepositiontaking_7 = @old_auto_slivepositiontaking_7 AND
		@auto_slivepositiontaking_8 = @old_auto_slivepositiontaking_8 AND
		
		@auto_v2spositiontaking_1 = @old_auto_v2spositiontaking_1 AND
		@auto_v2spositiontaking_2 = @old_auto_v2spositiontaking_2 AND
		@auto_v2spositiontaking_3 = @old_auto_v2spositiontaking_3 AND
		@auto_v2spositiontaking_7 = @old_auto_v2spositiontaking_7 AND
		@auto_v2spositiontaking_8 = @old_auto_v2spositiontaking_8 AND
	--	@auto_v2spositiontaking_9 = @old_auto_v2spositiontaking_9 AND
		@auto_v2spositiontaking_20 = @old_auto_v2spositiontaking_20 AND
		
		@auto_v3spositiontaking_1 = @old_auto_v3spositiontaking_1 AND
		@auto_v3spositiontaking_2 = @old_auto_v3spositiontaking_2 AND
		@auto_v3spositiontaking_3 = @old_auto_v3spositiontaking_3 AND
		@auto_v3spositiontaking_20 = @old_auto_v3spositiontaking_20 AND
		
		@auto_v5spositiontaking_1 = @old_auto_v5spositiontaking_1 AND
		@auto_v5spositiontaking_2 = @old_auto_v5spositiontaking_2 AND
		@auto_v5spositiontaking_3 = @old_auto_v5spositiontaking_3 AND
		@auto_v5spositiontaking_20 = @old_auto_v5spositiontaking_20 AND
		
		@auto_v8spositiontaking_1 = @old_auto_v8spositiontaking_1 AND
		@auto_v8spositiontaking_3 = @old_auto_v8spositiontaking_3 AND
		@auto_v8spositiontaking_20 = @old_auto_v8spositiontaking_20 AND
		
		@auto_v10spositiontaking_1 = @old_auto_v10spositiontaking_1 AND
		@auto_v10spositiontaking_2 = @old_auto_v10spositiontaking_2 AND
		@auto_v10spositiontaking_3 = @old_auto_v10spositiontaking_3 AND
		@auto_v10spositiontaking_20 = @old_auto_v10spositiontaking_20 AND
		
		@auto_v11spositiontaking_1 = @old_auto_v11spositiontaking_1 AND
		@auto_v11spositiontaking_20 = @old_auto_v11spositiontaking_20 AND

		@auto_v99spositiontaking_1 = @old_auto_v99spositiontaking_1 AND
		@auto_v99spositiontaking_2 = @old_auto_v99spositiontaking_2 AND
		@auto_v99spositiontaking_3 = @old_auto_v99spositiontaking_3 AND
		@auto_v99spositiontaking_20 = @old_auto_v99spositiontaking_20 AND

		-- mixed sports
		@auto_v99spositiontaking_9 = @old_auto_v99spositiontaking_9 AND

		-- number game
		@auto_v161spositiontaking_81 = @old_auto_v161spositiontaking_81 AND
		@auto_v161spositiontaking_83 = @old_auto_v161spositiontaking_83 AND
		@auto_v161spositiontaking_86 = @old_auto_v161spositiontaking_86 AND
		@auto_v161spositiontaking_88 = @old_auto_v161spositiontaking_88 AND
		@auto_v161slivepositiontaking_85 = @old_auto_v161slivepositiontaking_85 AND
		@auto_v161slivepositiontaking_86 = @old_auto_v161slivepositiontaking_86 AND
		@auto_v161slivepositiontaking_87 = @old_auto_v161slivepositiontaking_87 AND
		@auto_v161slivepositiontaking_89 = @old_auto_v161slivepositiontaking_89 AND
		@auto_v161slivepositiontaking_90 = @old_auto_v161slivepositiontaking_90 AND
		
		@isauto_spositiontaking_1 = @old_isauto_spositiontaking_1 AND
		@isauto_spositiontaking_2 = @old_isauto_spositiontaking_2 AND
		@isauto_spositiontaking_3 = @old_isauto_spositiontaking_3 AND
		@isauto_spositiontaking_4 = @old_isauto_spositiontaking_4 AND
		@isauto_spositiontaking_5 = @old_isauto_spositiontaking_5 AND
		@isauto_spositiontaking_6 = @old_isauto_spositiontaking_6 AND
		@isauto_spositiontaking_7 = @old_isauto_spositiontaking_7 AND
		@isauto_spositiontaking_8 = @old_isauto_spositiontaking_8 AND
		@isauto_spositiontaking_9 = @old_isauto_spositiontaking_9 AND
		@isauto_spositiontaking_10 = @old_isauto_spositiontaking_10 AND
		@isauto_slivepositiontaking_1 = @old_isauto_slivepositiontaking_1 AND
		@isauto_slivepositiontaking_3 = @old_isauto_slivepositiontaking_3 AND
		@isauto_slivepositiontaking_7 = @old_isauto_slivepositiontaking_7 AND
		@isauto_slivepositiontaking_8 = @old_isauto_slivepositiontaking_8 AND
		
		@isauto_v2spositiontaking_1 = @old_isauto_v2spositiontaking_1 AND
		@isauto_v2spositiontaking_2 = @old_isauto_v2spositiontaking_2 AND
		@isauto_v2spositiontaking_3 = @old_isauto_v2spositiontaking_3 AND
		@isauto_v2spositiontaking_7 = @old_isauto_v2spositiontaking_7 AND
		@isauto_v2spositiontaking_8 = @old_isauto_v2spositiontaking_8 AND
	--	@isauto_v2spositiontaking_9 = @old_isauto_v2spositiontaking_9 AND
		@isauto_v2spositiontaking_20 = @old_isauto_v2spositiontaking_20 AND
		
		@isauto_v3spositiontaking_1 = @old_isauto_v3spositiontaking_1 AND
		@isauto_v3spositiontaking_2 = @old_isauto_v3spositiontaking_2 AND
		@isauto_v3spositiontaking_3 = @old_isauto_v3spositiontaking_3 AND
		@isauto_v3spositiontaking_20 = @old_isauto_v3spositiontaking_20 AND
		
		@isauto_v5spositiontaking_1 = @old_isauto_v5spositiontaking_1 AND
		@isauto_v5spositiontaking_2 = @old_isauto_v5spositiontaking_2 AND
		@isauto_v5spositiontaking_3 = @old_isauto_v5spositiontaking_3 AND
		@isauto_v5spositiontaking_20 = @old_isauto_v5spositiontaking_20 AND
		
		@isauto_v8spositiontaking_1 = @old_isauto_v8spositiontaking_1 AND
		@isauto_v8spositiontaking_3 = @old_isauto_v8spositiontaking_3 AND
		@isauto_v8spositiontaking_20 = @old_isauto_v8spositiontaking_20 AND
		
		@isauto_v10spositiontaking_1 = @old_isauto_v10spositiontaking_1 AND
		@isauto_v10spositiontaking_2 = @old_isauto_v10spositiontaking_2 AND
		@isauto_v10spositiontaking_3 = @old_isauto_v10spositiontaking_3 AND
		@isauto_v10spositiontaking_20 = @old_isauto_v10spositiontaking_20 AND
		
		@isauto_v11spositiontaking_1 = @old_isauto_v11spositiontaking_1 AND
		@isauto_v11spositiontaking_20 = @old_isauto_v11spositiontaking_20 AND
		
		@isauto_v99spositiontaking_1 = @old_isauto_v99spositiontaking_1 AND
		@isauto_v99spositiontaking_2 = @old_isauto_v99spositiontaking_2 AND
		@isauto_v99spositiontaking_3 = @old_isauto_v99spositiontaking_3 AND
		@isauto_v99spositiontaking_20 = @old_isauto_v99spositiontaking_20 AND

		-- mixed sports
		@isauto_v99spositiontaking_9 = @old_isauto_v99spositiontaking_9 AND

		-- number game
		@isauto_v161spositiontaking_81 = @old_isauto_v161spositiontaking_81 AND
		@isauto_v161spositiontaking_83 = @old_isauto_v161spositiontaking_83 AND
		@isauto_v161spositiontaking_86 = @old_isauto_v161spositiontaking_86 AND
		@isauto_v161spositiontaking_88 = @old_isauto_v161spositiontaking_88 AND
		@isauto_v161slivepositiontaking_85 = @old_isauto_v161slivepositiontaking_85 AND
		@isauto_v161slivepositiontaking_86 = @old_isauto_v161slivepositiontaking_86 AND
		@isauto_v161slivepositiontaking_87 = @old_isauto_v161slivepositiontaking_87 AND
		@isauto_v161slivepositiontaking_89 = @old_isauto_v161slivepositiontaking_89 AND
		@isauto_v161slivepositiontaking_90 = @old_isauto_v161slivepositiontaking_90 
		
	BEGIN
		SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
		return
	END 

	if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
		BEGIN --@UpdatePositiontaking 
			if 
				@spositiontaking_1  <0 OR @spositiontaking_1  >0.9
				OR @spositiontaking_2  <0 OR @spositiontaking_2  >0.9
				OR @spositiontaking_3  <0 OR @spositiontaking_3  >0.9
				OR @spositiontaking_4  <0 OR @spositiontaking_4  >0.9
				OR @spositiontaking_5  <0 OR @spositiontaking_5  >0.9
				OR @spositiontaking_6  <0 OR @spositiontaking_6  >0.9
				OR @spositiontaking_7  <0 OR @spositiontaking_7  >0.9
				OR @spositiontaking_8  <0 OR @spositiontaking_8  >0.9
				OR @spositiontaking_9  <0 OR @spositiontaking_9  >0.9
				OR @spositiontaking_10 <0 OR @spositiontaking_10 >0.9
				OR @slivepositiontaking_1  <0 OR @slivepositiontaking_1  >0.9
				OR @slivepositiontaking_3  <0 OR @slivepositiontaking_3  >0.9
				OR @slivepositiontaking_7  <0 OR @slivepositiontaking_7  >0.9
				OR @slivepositiontaking_8  <0 OR @slivepositiontaking_8  >0.9
				BEGIN
					select @ErrCode = 5
					Select @ErrMsg = 	case @Language 
										when 'E' then 'Wrong position taking (for Soccer).'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
								end
					return
				END
			
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 1 AS sporttype, 1 AS bettype, @auto_spositiontaking_1 AS autopositiontaking, @isauto_spositiontaking_1 AS isautopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking, @isauto_slivepositiontaking_1 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 3 AS bettype, @auto_spositiontaking_3 AS autopositiontaking, @isauto_spositiontaking_3 AS isautopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking, @isauto_slivepositiontaking_3 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 7 AS bettype, @auto_spositiontaking_7 AS autopositiontaking, @isauto_spositiontaking_7 AS isautopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking, @isauto_slivepositiontaking_7 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 8 AS bettype, @auto_spositiontaking_8 AS autopositiontaking, @isauto_spositiontaking_8 AS isautopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking, @isauto_slivepositiontaking_8 AS isautolivepositiontaking

						UNION ALL	SELECT 1 AS sporttype, 2 AS bettype, @auto_spositiontaking_2 AS autopositiontaking, @isauto_spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 4 AS bettype, @auto_spositiontaking_4 AS autopositiontaking, @isauto_spositiontaking_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 5 AS bettype, @auto_spositiontaking_5 AS autopositiontaking, @isauto_spositiontaking_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 6 AS bettype, @auto_spositiontaking_6 AS autopositiontaking, @isauto_spositiontaking_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 9 AS bettype, @auto_spositiontaking_9 AS autopositiontaking, @isauto_spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 10 AS bettype, @auto_spositiontaking_10 AS autopositiontaking, @isauto_spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					)
			 AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN sports with (nolock) 
						on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) 
						on b.bettype = bettype.typeid
			where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))
			
		if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 1 AS sporttype, @auto_spositiontaking_1 AS autopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @auto_spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @auto_spositiontaking_3 AS autopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @auto_spositiontaking_4 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @auto_spositiontaking_5 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @auto_spositiontaking_6 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @auto_spositiontaking_7 AS autopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @auto_spositiontaking_8 AS autopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @auto_spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @auto_spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END				

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS positiontaking, @slivepositiontaking_1 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS positiontaking, @slivepositiontaking_3 AS livepositiontaking
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS positiontaking, @slivepositiontaking_7 AS livepositiontaking
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS positiontaking, @slivepositiontaking_8 AS livepositiontaking
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
				
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END --@UpdatePositiontaking 
			
			--Basketball
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
			BEGIN --@UpdatePositiontakingv2
				if 
					@v2spositiontaking_1 <0 OR @v2spositiontaking_1 >0.9
					OR @v2spositiontaking_2 <0 OR @v2spositiontaking_2 >0.9
					OR @v2spositiontaking_3 <0 OR @v2spositiontaking_3 >0.9
					OR @v2spositiontaking_7 <0 OR @v2spositiontaking_7 >0.9
					OR @v2spositiontaking_8 <0 OR @v2spositiontaking_8 >0.9
				--	OR @v2spositiontaking_9 <0 OR @v2spositiontaking_9 >0.9
					OR @v2spositiontaking_20 <0 OR @v2spositiontaking_20 >0.9
				
					BEGIN
						select @ErrCode = 8
						Select @ErrMsg = 	case @Language 
											when 'E' then 'Wrong position taking (for Basketball).'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
									end
						return
					END
				
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
					from custoverride AS co with (NOLOCK) 
					inner join
						(
						SELECT 2 AS sporttype, 1 AS bettype, @auto_v2spositiontaking_1 AS autopositiontaking, @isauto_v2spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 2 AS bettype, @auto_v2spositiontaking_2 AS autopositiontaking, @isauto_v2spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 3 AS bettype, @auto_v2spositiontaking_3 AS autopositiontaking, @isauto_v2spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 7 AS bettype, @auto_v2spositiontaking_7 AS autopositiontaking, @isauto_v2spositiontaking_7 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 8 AS bettype, @auto_v2spositiontaking_8 AS autopositiontaking, @isauto_v2spositiontaking_8 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						--	UNION ALL	SELECT 2 AS sporttype, 9 AS bettype, @auto_v2spositiontaking_9 AS autopositiontaking, @isauto_v2spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 20 AS bettype, @auto_v2spositiontaking_20 AS autopositiontaking, @isauto_v2spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking

						) AS b 
							on co.sporttype=b.sporttype and co.bettype=b.bettype
					INNER JOIN sports with (nolock) 
							on b.sporttype = sports.sporttype
					INNER JOIN bettype with (nolock) 
							on b.bettype = bettype.typeid

					where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

					if @ErrType <>''
					BEGIN
						SELECT @isvalid = 0, @ErrCode_cur = 2
						SELECT @ErrMsg_cur = 	case @Language 
														WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
														ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
												END
						select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
								@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						return
					END
				
					--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
					+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
					from custsetting AS cs with (NOLOCK) inner join
						(
						SELECT 1 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_7 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_8 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 2 AS sporttype, @v2spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @v2spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @v2spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @v2spositiontaking_7 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @v2spositiontaking_8 AS positiontaking, 0 AS livepositiontaking
			--			UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @v2spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @v2spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
						
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
					INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
					where cs.custid = @srecommend
						and 
						((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
						
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			END --@UpdatePositiontakingv2
			
			
			--Football
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
			BEGIN --@UpdatePositiontakingv3 
				if 
					@v3spositiontaking_1 <0 OR @v3spositiontaking_1 >0.9
					OR @v3spositiontaking_2 <0 OR @v3spositiontaking_2 >0.9
					OR @v3spositiontaking_3 <0 OR @v3spositiontaking_3 >0.9
					OR @v3spositiontaking_20 <0 OR @v3spositiontaking_20 >0.9
					
				BEGIN
					select @ErrCode = 8
					Select @ErrMsg = 	case @Language 
										when 'E' then 'Wrong position taking (for Football).'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
								end
					return
				END
			
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 3 AS sporttype, 1 AS bettype, @auto_v3spositiontaking_1 AS autopositiontaking, @isauto_v3spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 2 AS bettype, @auto_v3spositiontaking_2 AS autopositiontaking, @isauto_v3spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 3 AS bettype, @auto_v3spositiontaking_3 AS autopositiontaking, @isauto_v3spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 20 AS bettype, @auto_v3spositiontaking_20 AS autopositiontaking, @isauto_v3spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking

					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN sports with (nolock) 
						on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) 
						on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

				if @ErrType <>''
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 2
					SELECT @ErrMsg_cur = 	case @Language 
													WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
											END
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

				--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 1 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking

					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 1 AS bettype, 3 AS sporttype, @v3spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @v3spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @v3spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @v3spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
					INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

			END --@UpdatePositiontakingv3 
			
		--Tennis
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv5 = 1 )
		BEGIN --@UpdatePositiontakingv5
			if 
				@v5spositiontaking_1 <0 OR @v5spositiontaking_1 >0.9
				OR @v5spositiontaking_2 <0 OR @v5spositiontaking_2 >0.9
				OR @v5spositiontaking_3 <0 OR @v5spositiontaking_3 >0.9
				OR @v5spositiontaking_20 <0 OR @v5spositiontaking_20 >0.9
				
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Tennis).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end
				return
			END	
		
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 5 AS sporttype, 1 AS bettype, @auto_v5spositiontaking_1 AS autopositiontaking, @isauto_v5spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 2 AS bettype, @auto_v5spositiontaking_2 AS autopositiontaking, @isauto_v5spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 3 AS bettype, @auto_v5spositiontaking_3 AS autopositiontaking, @isauto_v5spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 20 AS bettype, @auto_v5spositiontaking_20 AS autopositiontaking, @isauto_v5spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN sports with (nolock) 
						on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) 
						on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

	
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 5 AS sporttype, @v5spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @v5spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @v5spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @v5spositiontaking_20 AS positiontaking, 0 AS livepositiontaking				
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

		END --@UpdatePositiontakingv5
		
		
		--Baseball
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1 )
			BEGIN --@UpdatePositiontakingv8 
				if 
					 @v8spositiontaking_1 <0 OR @v8spositiontaking_1 >0.9
					OR @v8spositiontaking_3 <0 OR @v8spositiontaking_3 >0.9
					OR @v8spositiontaking_20 <0	OR @v8spositiontaking_20 >0.9
											
					BEGIN
						select @ErrCode = 8
						Select @ErrMsg = 	case @Language 
											when 'E' then 'Wrong position taking (for Baseball).'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
									end
						return
					END				
			
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 8 AS sporttype, 1 AS bettype, @auto_v8spositiontaking_1 AS autopositiontaking, @isauto_v8spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 8 AS sporttype, 3 AS bettype, @auto_v8spositiontaking_3 AS autopositiontaking, @isauto_v8spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 8 AS sporttype, 20 AS bettype, @auto_v8spositiontaking_20 AS autopositiontaking, @isauto_v8spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN sports with (nolock) 
						on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) 
						on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

				if @ErrType <>''
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 2
					SELECT @ErrMsg_cur = 	case @Language 
													WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
											END
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

				--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
		
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
						
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
					INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
			END --@UpdatePositiontakingv8

		--Golf
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv10 = 1 )
		BEGIN -- @UpdatePositiontakingv10
			if 
			 @v10spositiontaking_1 <0 OR @v10spositiontaking_1 >0.9
				OR @v10spositiontaking_2 <0 OR @v10spositiontaking_2 >0.9
				OR @v10spositiontaking_3 <0 OR @v10spositiontaking_3 >0.9
				OR @v10spositiontaking_20 <0 OR @v10spositiontaking_20 >0.9
				
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Golf).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end
				return
			END

			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(
				SELECT 10 AS sporttype, 1 AS bettype, @auto_v10spositiontaking_1 AS autopositiontaking, @isauto_v10spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 2 AS bettype, @auto_v10spositiontaking_2 AS autopositiontaking, @isauto_v10spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 3 AS bettype, @auto_v10spositiontaking_3 AS autopositiontaking, @isauto_v10spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 20 AS bettype, @auto_v10spositiontaking_20 AS autopositiontaking, @isauto_v10spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN sports with (nolock) 
					on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) 
					on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
				--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END


			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 10 AS sporttype, @v10spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @v10spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @v10spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @v10spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
			
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END -- @UpdatePositiontakingv10


		--Motorsports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
		BEGIN--@UpdatePositiontakingv11
			if 
			 @v11spositiontaking_1 <0 OR @v11spositiontaking_1 >0.9
			OR @v11spositiontaking_20 <0 OR @v11spositiontaking_20 >0.9

			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Motorsports).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end
				return
			END

			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(SELECT 11 AS sporttype, 1 AS bettype, @auto_v11spositiontaking_1 AS autopositiontaking, @isauto_v11spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 11 AS sporttype, 20 AS bettype, @auto_v11spositiontaking_20 AS autopositiontaking, @isauto_v11spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN sports with (nolock) 
					on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) 
					on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
	
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 1 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
				UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 11 AS sporttype, @v11spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @v11spositiontaking_20 AS positiontaking, 0 AS livepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
		END	--@UpdatePositiontakingv11
	
		--Other sports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1 )
		BEGIN--@UpdatePositiontakingv99
			if 
			 @v99spositiontaking_1 <0 OR @v99spositiontaking_1 >0.9 
			OR @v99spositiontaking_2 <0 OR @v99spositiontaking_2 >0.9
			OR @v99spositiontaking_3 <0 OR @v99spositiontaking_3 >0.9
			OR @v99spositiontaking_20 <0 OR @v99spositiontaking_20 >0.9
				
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Other sports).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end
				return
			END
	
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(
				SELECT 99 AS sporttype, 1 AS bettype, @auto_v99spositiontaking_1 AS autopositiontaking, @isauto_v99spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 2 AS bettype, @auto_v99spositiontaking_2 AS autopositiontaking, @isauto_v99spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 3 AS bettype, @auto_v99spositiontaking_3 AS autopositiontaking, @isauto_v99spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 20 AS bettype, @auto_v99spositiontaking_20 AS autopositiontaking, @isauto_v99spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN sports with (nolock) 
					on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) 
					on b.bettype = bettype.typeid

			where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
					
					-- mixed sports
					UNION ALL 	SELECT 9 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 99 AS sporttype, @v99spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @v99spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @v99spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @v99spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	
		END--@UpdatePositiontakingv99	

		--Mix Parlay Mixed Sports
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv99MP = 1	)
		BEGIN--@UpdatePositiontakingv99MP
			if 
				@v99spositiontaking_9 <0 OR @v99spositiontaking_9 > 0.9

			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Mix Sports Parlay).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
							end
				return
			END
	
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(SELECT 99 AS sporttype, 9 AS bettype, @auto_v99spositiontaking_9 AS autopositiontaking, @isauto_v99spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN sports with (nolock) 
					on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) 
					on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 9 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 9 AS bettype, 99 AS sporttype, @v99spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
				
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		
		END--@UpdatePositiontakingv99MP
	
		--v161 number game
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv161 = 1)
		BEGIN --@UpdatePositiontakingv161
			if 
				@v161spositiontaking_81 <0 OR @v161spositiontaking_81 >0.9	
				OR @v161spositiontaking_83 <0 OR @v161spositiontaking_83 >0.9	
				OR @v161spositiontaking_86 <0 OR @v161spositiontaking_86 >0.9	
				OR @v161spositiontaking_88 <0 OR @v161spositiontaking_88 >0.9	
				OR @v161slivepositiontaking_85 <0 OR @v161slivepositiontaking_85 >0.9	
				OR @v161slivepositiontaking_86 <0 OR @v161slivepositiontaking_86 >0.9	
				OR @v161slivepositiontaking_87 <0 OR @v161slivepositiontaking_87 >0.9	
				OR @v161slivepositiontaking_89 <0 OR @v161slivepositiontaking_89 >0.9	
				OR @v161slivepositiontaking_90 <0 OR @v161slivepositiontaking_90 >0.9	
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Number Game).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end
				return
			END
		--Check u1<=l4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride3rd AS co3 with (NOLOCK) inner join
			(
				SELECT 161 AS sporttype, 81 AS bettype, @auto_v161spositiontaking_81 AS autopositiontaking, @isauto_v161spositiontaking_81 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 83 AS bettype, @auto_v161spositiontaking_83 AS autopositiontaking, @isauto_v161spositiontaking_83 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 88 AS bettype, @auto_v161spositiontaking_88 AS autopositiontaking, @isauto_v161spositiontaking_88 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 85 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking, @isauto_v161slivepositiontaking_85 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 86 AS bettype, @auto_v161spositiontaking_86 AS autopositiontaking, @isauto_v161spositiontaking_86 AS isautopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking, @isauto_v161slivepositiontaking_86 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 87 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking, @isauto_v161slivepositiontaking_87 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 89 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking, @isauto_v161slivepositiontaking_89 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 90 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking, @isauto_v161slivepositiontaking_90 AS isautolivepositiontaking
				
			) AS b on co3.sporttype=b.sporttype and co3.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid

			where co3.custid = @srecommEND and ((b.isautopositiontaking>0 and b.autopositiontaking>co3.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=161 and b.bettype in (85,86,87) and b.autolivepositiontaking>co3.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			-- END check parameter
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


			-- number game
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting3rd AS cs3 with (NOLOCK) inner join
				(
								SELECT 81 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_81 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_83 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_88 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_86 AS autopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking
					
				) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
			INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
			INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs3.custid = @srecommEND
				and 
				((cs3.spositiontaking<b.autopositiontaking) or (b.bettype in (85,86,87,89,90) and b.sporttype=161 and cs3.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			-- number game
			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting3rd AS cs3 with (NOLOCK) inner join
				(
								SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS positiontaking, 0 AS livepositiontaking	
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_85 AS livepositiontaking
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS positiontaking, @v161slivepositiontaking_86 AS livepositiontaking
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_87 AS livepositiontaking
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_89 AS livepositiontaking
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_90 AS livepositiontaking
					
				) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
				INNER JOIN sports with (nolock) on b.sporttype = sports.sporttype
				INNER JOIN bettype with (nolock) on b.bettype = bettype.typeid
			where cs3.custid = @srecommEND
				and 
				((cs3.spositiontaking<b.positiontaking) or (b.bettype in (85,86,87,89,90) and b.sporttype=161 and cs3.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END --@UpdatePositiontakingv161


	SELECT @spositiontaking_1_max = spositiontaking, @slivepositiontaking_1_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=1
	SELECT @spositiontaking_3_max = spositiontaking, @slivepositiontaking_3_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=1
	SELECT @spositiontaking_7_max = spositiontaking, @slivepositiontaking_7_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=7 and sporttype=1
	SELECT @spositiontaking_8_max = spositiontaking, @slivepositiontaking_8_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=8 and sporttype=1

	SELECT @spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=1
	SELECT @spositiontaking_4_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=4 and sporttype=1
	SELECT @spositiontaking_5_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=5 and sporttype=1
	SELECT @spositiontaking_6_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=6 and sporttype=1
	SELECT @spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=1
	SELECT @spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=1

	SELECT @v2spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=2
	SELECT @v2spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=2
	SELECT @v2spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=2
	SELECT @v2spositiontaking_7_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=7 and sporttype=2
	SELECT @v2spositiontaking_8_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=8 and sporttype=2
	--select @v2spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=2
	SELECT @v2spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=2

	SELECT @v3spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=3
	SELECT @v3spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=3
	SELECT @v3spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=3
	SELECT @v3spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=3

	SELECT @v5spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=5
	SELECT @v5spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=5
	SELECT @v5spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=5
	SELECT @v5spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=5

	SELECT @v8spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=8
	SELECT @v8spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=8
	SELECT @v8spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=8

	SELECT @v10spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=10
	SELECT @v10spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=10
	SELECT @v10spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=10
	SELECT @v10spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=10

	SELECT @v11spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=11
	SELECT @v11spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=11

	SELECT @v99spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=99
	SELECT @v99spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=99
	SELECT @v99spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=99
	SELECT @v99spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=99

	--mixed sports
	SELECT @v99spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=99

	--number game
	SELECT @v161spositiontaking_81_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=81 and sporttype=161
	SELECT @v161spositiontaking_83_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=83 and sporttype=161
	SELECT @v161spositiontaking_88_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=88 and sporttype=161
	SELECT @v161slivepositiontaking_85_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=85 and sporttype=161
	SELECT @v161spositiontaking_86_max = spositiontaking, @v161slivepositiontaking_86_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=86 and sporttype=161
	SELECT @v161slivepositiontaking_87_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=87 and sporttype=161
	SELECT @v161slivepositiontaking_89_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=89 and sporttype=161
	SELECT @v161slivepositiontaking_90_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=90 and sporttype=161

	SELECT 
		@spositiontaking_1 = CASE WHEN @spositiontaking_1+@mpositiontaking_1+@apositiontaking_1>@spositiontaking_1_max THEN @spositiontaking_1_max-@mpositiontaking_1-@apositiontaking_1 ELSE @spositiontaking_1 END,
		@spositiontaking_2 = CASE WHEN @spositiontaking_2+@mpositiontaking_2+@apositiontaking_2>@spositiontaking_2_max THEN @spositiontaking_2_max-@mpositiontaking_2-@apositiontaking_2 ELSE @spositiontaking_2 END,
		@spositiontaking_3 = CASE WHEN @spositiontaking_3+@mpositiontaking_3+@apositiontaking_3>@spositiontaking_3_max THEN @spositiontaking_3_max-@mpositiontaking_3-@apositiontaking_3 ELSE @spositiontaking_3 END,
		@spositiontaking_4 = CASE WHEN @spositiontaking_4+@mpositiontaking_4+@apositiontaking_4>@spositiontaking_4_max THEN @spositiontaking_4_max-@mpositiontaking_4-@apositiontaking_4 ELSE @spositiontaking_4 END,
		@spositiontaking_5 = CASE WHEN @spositiontaking_5+@mpositiontaking_5+@apositiontaking_5>@spositiontaking_5_max THEN @spositiontaking_5_max-@mpositiontaking_5-@apositiontaking_5 ELSE @spositiontaking_5 END,
		@spositiontaking_6 = CASE WHEN @spositiontaking_6+@mpositiontaking_6+@apositiontaking_6>@spositiontaking_6_max THEN @spositiontaking_6_max-@mpositiontaking_6-@apositiontaking_6 ELSE @spositiontaking_6 END,
		@spositiontaking_7 = CASE WHEN @spositiontaking_7+@mpositiontaking_7+@apositiontaking_7>@spositiontaking_7_max THEN @spositiontaking_7_max-@mpositiontaking_7-@apositiontaking_7 ELSE @spositiontaking_7 END,
		@spositiontaking_8 = CASE WHEN @spositiontaking_8+@mpositiontaking_8+@apositiontaking_8>@spositiontaking_8_max THEN @spositiontaking_8_max-@mpositiontaking_8-@apositiontaking_8 ELSE @spositiontaking_8 END,
		@spositiontaking_9 = CASE WHEN @spositiontaking_9+@mpositiontaking_9+@apositiontaking_9>@spositiontaking_9_max THEN @spositiontaking_9_max-@mpositiontaking_9-@apositiontaking_9 ELSE @spositiontaking_9 END,
		@spositiontaking_10 = CASE WHEN @spositiontaking_10+@mpositiontaking_10+@apositiontaking_10>@spositiontaking_10_max THEN @spositiontaking_10_max-@mpositiontaking_10-@apositiontaking_10 ELSE @spositiontaking_10 END,

		@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1+@mlivepositiontaking_1+@alivepositiontaking_1>@slivepositiontaking_1_max THEN @slivepositiontaking_1_max-@mlivepositiontaking_1-@alivepositiontaking_1 ELSE @slivepositiontaking_1 END,
		@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3+@mlivepositiontaking_3+@alivepositiontaking_3>@slivepositiontaking_3_max THEN @slivepositiontaking_3_max-@mlivepositiontaking_3-@alivepositiontaking_3 ELSE @slivepositiontaking_3 END,
		@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7+@mlivepositiontaking_7+@alivepositiontaking_7>@slivepositiontaking_7_max THEN @slivepositiontaking_7_max-@mlivepositiontaking_7-@alivepositiontaking_7 ELSE @slivepositiontaking_7 END,
		@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8+@mlivepositiontaking_8+@alivepositiontaking_8>@slivepositiontaking_8_max THEN @slivepositiontaking_8_max-@mlivepositiontaking_8-@alivepositiontaking_8 ELSE @slivepositiontaking_8 END,

		@v2spositiontaking_1 = CASE WHEN @v2mpositiontaking_1+@v2spositiontaking_1+@v2apositiontaking_1>@v2spositiontaking_1_max THEN @v2spositiontaking_1_max-@v2mpositiontaking_1-@v2apositiontaking_1 ELSE @v2spositiontaking_1 END,
		@v2spositiontaking_2 = CASE WHEN @v2mpositiontaking_2+@v2spositiontaking_2+@v2apositiontaking_2>@v2spositiontaking_2_max THEN @v2spositiontaking_2_max-@v2mpositiontaking_2-@v2apositiontaking_2 ELSE @v2spositiontaking_2 END,
		@v2spositiontaking_3 = CASE WHEN @v2mpositiontaking_3+@v2spositiontaking_3+@v2apositiontaking_3>@v2spositiontaking_3_max THEN @v2spositiontaking_3_max-@v2mpositiontaking_3-@v2apositiontaking_3 ELSE @v2spositiontaking_3 END,
		@v2spositiontaking_7 = CASE WHEN @v2mpositiontaking_7+@v2spositiontaking_7+@v2apositiontaking_7>@v2spositiontaking_7_max THEN @v2spositiontaking_7_max-@v2mpositiontaking_7-@v2apositiontaking_7 ELSE @v2spositiontaking_7 END,
		@v2spositiontaking_8 = CASE WHEN @v2mpositiontaking_8+@v2spositiontaking_8+@v2apositiontaking_8>@v2spositiontaking_8_max THEN @v2spositiontaking_8_max-@v2mpositiontaking_8-@v2apositiontaking_8 ELSE @v2spositiontaking_8 END,
	--	@v2spositiontaking_9 = CASE WHEN @v2mpositiontaking_9+@v2spositiontaking_9+@v2apositiontaking_9>@v2spositiontaking_9_max THEN @v2spositiontaking_9_max-@v2mpositiontaking_9-@v2apositiontaking_9 ELSE @v2spositiontaking_9 END,
		@v2spositiontaking_20 = CASE WHEN @v2mpositiontaking_20+@v2spositiontaking_20+@v2apositiontaking_20>@v2spositiontaking_20_max THEN @v2spositiontaking_20_max-@v2mpositiontaking_20-@v2apositiontaking_20 ELSE @v2spositiontaking_20 END,

		@v3spositiontaking_1 = CASE WHEN @v3mpositiontaking_1+@v3spositiontaking_1+@v3apositiontaking_1>@v3spositiontaking_1_max THEN @v3spositiontaking_1_max-@v3mpositiontaking_1-@v3apositiontaking_1 ELSE @v3spositiontaking_1 END,
		@v3spositiontaking_2 = CASE WHEN @v3mpositiontaking_2+@v3spositiontaking_2+@v3apositiontaking_2>@v3spositiontaking_2_max THEN @v3spositiontaking_2_max-@v3mpositiontaking_2-@v3apositiontaking_2 ELSE @v3spositiontaking_2 END,
		@v3spositiontaking_3 = CASE WHEN @v3mpositiontaking_3+@v3spositiontaking_3+@v3apositiontaking_3>@v3spositiontaking_3_max THEN @v3spositiontaking_3_max-@v3mpositiontaking_3-@v3apositiontaking_3 ELSE @v3spositiontaking_3 END,
		@v3spositiontaking_20 = CASE WHEN @v3mpositiontaking_20+@v3spositiontaking_20+@v3apositiontaking_20>@v3spositiontaking_20_max THEN @v3spositiontaking_20_max-@v3mpositiontaking_20-@v3apositiontaking_20 ELSE @v3spositiontaking_20 END,

		@v5spositiontaking_1 = CASE WHEN @v5mpositiontaking_1+@v5spositiontaking_1+@v5apositiontaking_1>@v5spositiontaking_1_max THEN @v5spositiontaking_1_max-@v5mpositiontaking_1-@v5apositiontaking_1 ELSE @v5spositiontaking_1 END,
		@v5spositiontaking_2 = CASE WHEN @v5mpositiontaking_2+@v5spositiontaking_2+@v5apositiontaking_2>@v5spositiontaking_2_max THEN @v5spositiontaking_2_max-@v5mpositiontaking_2-@v5apositiontaking_2 ELSE @v5spositiontaking_2 END,
		@v5spositiontaking_3 = CASE WHEN @v5mpositiontaking_3+@v5spositiontaking_3+@v5apositiontaking_3>@v5spositiontaking_3_max THEN @v5spositiontaking_3_max-@v5mpositiontaking_3-@v5apositiontaking_3 ELSE @v5spositiontaking_3 END,
		@v5spositiontaking_20 = CASE WHEN @v5mpositiontaking_20+@v5spositiontaking_20+@v5apositiontaking_20>@v5spositiontaking_20_max THEN @v5spositiontaking_20_max-@v5mpositiontaking_20-@v5apositiontaking_20 ELSE @v5spositiontaking_20 END,

		@v8spositiontaking_1 = CASE WHEN @v8mpositiontaking_1+@v8spositiontaking_1+@v8apositiontaking_1>@v8spositiontaking_1_max THEN @v8spositiontaking_1_max-@v8mpositiontaking_1-@v8apositiontaking_1 ELSE @v8spositiontaking_1 END,
		@v8spositiontaking_3 = CASE WHEN @v8mpositiontaking_3+@v8spositiontaking_3+@v8apositiontaking_3>@v8spositiontaking_3_max THEN @v8spositiontaking_3_max-@v8mpositiontaking_3-@v8apositiontaking_3 ELSE @v8spositiontaking_3 END,
		@v8spositiontaking_20 = CASE WHEN @v8mpositiontaking_20+@v8spositiontaking_20+@v8apositiontaking_20>@v8spositiontaking_20_max THEN @v8spositiontaking_20_max-@v8mpositiontaking_20-@v8apositiontaking_20 ELSE @v8spositiontaking_20 END,

		@v10spositiontaking_1 = CASE WHEN @v10mpositiontaking_1+@v10spositiontaking_1+@v10apositiontaking_1>@v10spositiontaking_1_max THEN @v10spositiontaking_1_max-@v10mpositiontaking_1-@v10apositiontaking_1 ELSE @v10spositiontaking_1 END,
		@v10spositiontaking_2 = CASE WHEN @v10mpositiontaking_2+@v10spositiontaking_2+@v10apositiontaking_2>@v10spositiontaking_2_max THEN @v10spositiontaking_2_max-@v10mpositiontaking_2-@v10apositiontaking_2 ELSE @v10spositiontaking_2 END,
		@v10spositiontaking_3 = CASE WHEN @v10mpositiontaking_3+@v10spositiontaking_3+@v10apositiontaking_3>@v10spositiontaking_3_max THEN @v10spositiontaking_3_max-@v10mpositiontaking_3-@v10apositiontaking_3 ELSE @v10spositiontaking_3 END,
		@v10spositiontaking_20 = CASE WHEN @v10mpositiontaking_20+@v10spositiontaking_20+@v10apositiontaking_20>@v10spositiontaking_20_max THEN @v10spositiontaking_20_max-@v10mpositiontaking_20-@v10apositiontaking_20 ELSE @v10spositiontaking_20 END,

		@v11spositiontaking_1 = CASE WHEN @v11mpositiontaking_1+@v11spositiontaking_1+@v11apositiontaking_1>@v11spositiontaking_1_max THEN @v11spositiontaking_1_max-@v11mpositiontaking_1-@v11apositiontaking_1 ELSE @v11spositiontaking_1 END,
		@v11spositiontaking_20 = CASE WHEN @v11mpositiontaking_20+@v11spositiontaking_20+@v11apositiontaking_20>@v11spositiontaking_20_max THEN @v11spositiontaking_20_max-@v11mpositiontaking_20-@v11apositiontaking_20 ELSE @v11spositiontaking_20 END,

		@v99spositiontaking_1 = CASE WHEN @v99mpositiontaking_1+@v99spositiontaking_1+@v99apositiontaking_1>@v99spositiontaking_1_max THEN @v99spositiontaking_1_max-@v99mpositiontaking_1-@v99apositiontaking_1 ELSE @v99spositiontaking_1 END,
		@v99spositiontaking_2 = CASE WHEN @v99mpositiontaking_2+@v99spositiontaking_2+@v99apositiontaking_2>@v99spositiontaking_2_max THEN @v99spositiontaking_2_max-@v99mpositiontaking_2-@v99apositiontaking_2 ELSE @v99spositiontaking_2 END,
		@v99spositiontaking_3 = CASE WHEN @v99mpositiontaking_3+@v99spositiontaking_3+@v99apositiontaking_3>@v99spositiontaking_3_max THEN @v99spositiontaking_3_max-@v99mpositiontaking_3-@v99apositiontaking_3 ELSE @v99spositiontaking_3 END,
		@v99spositiontaking_20 = CASE WHEN @v99mpositiontaking_20+@v99spositiontaking_20+@v99apositiontaking_20>@v99spositiontaking_20_max THEN @v99spositiontaking_20_max-@v99mpositiontaking_20-@v99apositiontaking_20 ELSE @v99spositiontaking_20 END,

		-- mixed sports
		@v99spositiontaking_9 = CASE WHEN @v99mpositiontaking_9+@v99spositiontaking_9+@v99apositiontaking_9>@v99spositiontaking_9_max THEN @v99spositiontaking_9_max-@v99mpositiontaking_9-@v99apositiontaking_9 ELSE @v99spositiontaking_9 END,

		-- number game
		@v161spositiontaking_81 = CASE WHEN @v161mpositiontaking_81+@v161spositiontaking_81+@v161apositiontaking_81>@v161spositiontaking_81_max THEN @v161spositiontaking_81_max-@v161mpositiontaking_81-@v161apositiontaking_81 ELSE @v161spositiontaking_81 END,
		@v161spositiontaking_83 = CASE WHEN @v161mpositiontaking_83+@v161spositiontaking_83+@v161apositiontaking_83>@v161spositiontaking_83_max THEN @v161spositiontaking_83_max-@v161mpositiontaking_83-@v161apositiontaking_83 ELSE @v161spositiontaking_83 END,		
		@v161spositiontaking_86 = CASE WHEN @v161mpositiontaking_86+@v161spositiontaking_86+@v161apositiontaking_86>@v161spositiontaking_86_max THEN @v161spositiontaking_86_max-@v161mpositiontaking_86-@v161apositiontaking_86 ELSE @v161spositiontaking_86 END,
		@v161spositiontaking_88 = CASE WHEN @v161mpositiontaking_88+@v161spositiontaking_88+@v161apositiontaking_88>@v161spositiontaking_88_max THEN @v161spositiontaking_88_max-@v161mpositiontaking_88-@v161apositiontaking_88 ELSE @v161spositiontaking_88 END,
		@v161slivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85+@v161slivepositiontaking_85+@v161alivepositiontaking_85>@v161slivepositiontaking_85_max THEN @v161slivepositiontaking_85_max-@v161mlivepositiontaking_85-@v161alivepositiontaking_85 ELSE @v161slivepositiontaking_85 END,
		@v161slivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86+@v161slivepositiontaking_86+@v161alivepositiontaking_86>@v161slivepositiontaking_86_max THEN @v161slivepositiontaking_86_max-@v161mlivepositiontaking_86-@v161alivepositiontaking_86 ELSE @v161slivepositiontaking_86 END,
		@v161slivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87+@v161slivepositiontaking_87+@v161alivepositiontaking_87>@v161slivepositiontaking_87_max THEN @v161slivepositiontaking_87_max-@v161mlivepositiontaking_87-@v161alivepositiontaking_87 ELSE @v161slivepositiontaking_87 END,
		@v161slivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89+@v161slivepositiontaking_89+@v161alivepositiontaking_89>@v161slivepositiontaking_89_max THEN @v161slivepositiontaking_89_max-@v161mlivepositiontaking_89-@v161alivepositiontaking_89 ELSE @v161slivepositiontaking_89 END,
		@v161slivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90+@v161slivepositiontaking_90+@v161alivepositiontaking_90>@v161slivepositiontaking_90_max THEN @v161slivepositiontaking_90_max-@v161mlivepositiontaking_90-@v161alivepositiontaking_90 ELSE @v161slivepositiontaking_90 END

	SELECT 
		@spositiontaking_1 = CASE WHEN @spositiontaking_1<0 THEN 0 ELSE @spositiontaking_1 END,
		@spositiontaking_2 = CASE WHEN @spositiontaking_2<0 THEN 0 ELSE @spositiontaking_2 END,
		@spositiontaking_3 = CASE WHEN @spositiontaking_3<0 THEN 0 ELSE @spositiontaking_3 END,
		@spositiontaking_4 = CASE WHEN @spositiontaking_4<0 THEN 0 ELSE @spositiontaking_4 END,
		@spositiontaking_5 = CASE WHEN @spositiontaking_5<0 THEN 0 ELSE @spositiontaking_5 END,
		@spositiontaking_6 = CASE WHEN @spositiontaking_6<0 THEN 0 ELSE @spositiontaking_6 END,
		@spositiontaking_7 = CASE WHEN @spositiontaking_7<0 THEN 0 ELSE @spositiontaking_7 END,
		@spositiontaking_8 = CASE WHEN @spositiontaking_8<0 THEN 0 ELSE @spositiontaking_8 END,
		@spositiontaking_9 = CASE WHEN @spositiontaking_9<0 THEN 0 ELSE @spositiontaking_9 END,
		@spositiontaking_10 = CASE WHEN @spositiontaking_10<0 THEN 0 ELSE @spositiontaking_10 END,

		@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1<0 THEN 0 ELSE @slivepositiontaking_1 END,
		@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3<0 THEN 0 ELSE @slivepositiontaking_3 END,
		@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7<0 THEN 0 ELSE @slivepositiontaking_7 END,
		@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8<0 THEN 0 ELSE @slivepositiontaking_8 END,

		@v2spositiontaking_1 = CASE WHEN @v2spositiontaking_1<0 THEN 0 ELSE @v2spositiontaking_1 END,
		@v2spositiontaking_2 = CASE WHEN @v2spositiontaking_2<0 THEN 0 ELSE @v2spositiontaking_2 END,
		@v2spositiontaking_3 = CASE WHEN @v2spositiontaking_3<0 THEN 0 ELSE @v2spositiontaking_3 END,
		@v2spositiontaking_7 = CASE WHEN @v2spositiontaking_7<0 THEN 0 ELSE @v2spositiontaking_7 END,
		@v2spositiontaking_8 = CASE WHEN @v2spositiontaking_8<0 THEN 0 ELSE @v2spositiontaking_8 END,
	--	@v2spositiontaking_9 = CASE WHEN @v2spositiontaking_9<0 THEN 0 ELSE @v2spositiontaking_9 END,
		@v2spositiontaking_20 = CASE WHEN @v2spositiontaking_20<0 THEN 0 ELSE @v2spositiontaking_20 END,

		@v3spositiontaking_1 = CASE WHEN @v3spositiontaking_1<0 THEN 0 ELSE @v3spositiontaking_1 END,
		@v3spositiontaking_2 = CASE WHEN @v3spositiontaking_2<0 THEN 0 ELSE @v3spositiontaking_2 END,
		@v3spositiontaking_3 = CASE WHEN @v3spositiontaking_3<0 THEN 0 ELSE @v3spositiontaking_3 END,
		@v3spositiontaking_20 = CASE WHEN @v3spositiontaking_20<0 THEN 0 ELSE @v3spositiontaking_20 END,

		@v5spositiontaking_1 = CASE WHEN @v5spositiontaking_1<0 THEN 0 ELSE @v5spositiontaking_1 END,
		@v5spositiontaking_2 = CASE WHEN @v5spositiontaking_2<0 THEN 0 ELSE @v5spositiontaking_2 END,
		@v5spositiontaking_3 = CASE WHEN @v5spositiontaking_3<0 THEN 0 ELSE @v5spositiontaking_3 END,
		@v5spositiontaking_20 = CASE WHEN @v5spositiontaking_20<0 THEN 0 ELSE @v5spositiontaking_20 END,

		@v8spositiontaking_1 = CASE WHEN @v8spositiontaking_1<0 THEN 0 ELSE @v8spositiontaking_1 END,
		@v8spositiontaking_3 = CASE WHEN @v8spositiontaking_3<0 THEN 0 ELSE @v8spositiontaking_3 END,
		@v8spositiontaking_20 = CASE WHEN @v8spositiontaking_20<0 THEN 0 ELSE @v8spositiontaking_20 END,

		@v10spositiontaking_1 = CASE WHEN @v10spositiontaking_1<0 THEN 0 ELSE @v10spositiontaking_1 END,
		@v10spositiontaking_2 = CASE WHEN @v10spositiontaking_2<0 THEN 0 ELSE @v10spositiontaking_2 END,
		@v10spositiontaking_3 = CASE WHEN @v10spositiontaking_3<0 THEN 0 ELSE @v10spositiontaking_3 END,
		@v10spositiontaking_20 = CASE WHEN @v10spositiontaking_20<0 THEN 0 ELSE @v10spositiontaking_20 END,

		@v11spositiontaking_1 = CASE WHEN @v11spositiontaking_1<0 THEN 0 ELSE @v11spositiontaking_1 END,
		@v11spositiontaking_20 = CASE WHEN @v11spositiontaking_20<0 THEN 0 ELSE @v11spositiontaking_20 END,

		@v99spositiontaking_1 = CASE WHEN @v99spositiontaking_1<0 THEN 0 ELSE @v99spositiontaking_1 END,
		@v99spositiontaking_2 = CASE WHEN @v99spositiontaking_2<0 THEN 0 ELSE @v99spositiontaking_2 END,
		@v99spositiontaking_3 = CASE WHEN @v99spositiontaking_3<0 THEN 0 ELSE @v99spositiontaking_3 END,
		@v99spositiontaking_20 = CASE WHEN @v99spositiontaking_20<0 THEN 0 ELSE @v99spositiontaking_20 END,

		-- mixed sports
		@v99spositiontaking_9 = CASE WHEN @v99spositiontaking_9<0 THEN 0 ELSE @v99spositiontaking_9 END,

		-- number game
		@v161spositiontaking_81 = CASE WHEN @v161spositiontaking_81<0 THEN 0 ELSE @v161spositiontaking_81 END,
		@v161spositiontaking_83 = CASE WHEN @v161spositiontaking_83<0 THEN 0 ELSE @v161spositiontaking_83 END,
		@v161spositiontaking_86 = CASE WHEN @v161spositiontaking_86<0 THEN 0 ELSE @v161spositiontaking_86 END,
		@v161spositiontaking_88 = CASE WHEN @v161spositiontaking_88<0 THEN 0 ELSE @v161spositiontaking_88 END,
		@v161slivepositiontaking_85 = CASE WHEN @v161slivepositiontaking_85<0 THEN 0 ELSE @v161slivepositiontaking_85 END,
		@v161slivepositiontaking_86 = CASE WHEN @v161slivepositiontaking_86<0 THEN 0 ELSE @v161slivepositiontaking_86 END,
		@v161slivepositiontaking_87 = CASE WHEN @v161slivepositiontaking_87<0 THEN 0 ELSE @v161slivepositiontaking_87 END,
		@v161slivepositiontaking_89 = CASE WHEN @v161slivepositiontaking_89<0 THEN 0 ELSE @v161slivepositiontaking_89 END,
		@v161slivepositiontaking_90 = CASE WHEN @v161slivepositiontaking_90<0 THEN 0 ELSE @v161slivepositiontaking_90 END


	--don't update s1 for member under master was set i3=1(normal)
	UPDATE cs WITH (ROWLOCK, UPDLOCK)
	SET
		cs.spositiontaking = 
						CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
									OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0) )) 
								THEN cs.spositiontaking 
						ELSE CASE cs.sporttype 	
								WHEN 1 THEN case cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
								WHEN 2 THEN case cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 /*WHEN 9 THEN @v2spositiontaking_9*/ WHEN 20 THEN @v2spositiontaking_20  ELSE 0 END
								WHEN 3 THEN case cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
								WHEN 5 THEN case cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
								WHEN 8 THEN case cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
								WHEN 10 THEN case cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
								WHEN 11 THEN case cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
								WHEN 99 THEN case cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9 WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
								ELSE cs.spositiontaking END
						END
	FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
		INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
	WHERE cs.custid=@custid and c.roleid = 1 and scs.isautopositiontaking = 0

	--don't update s1 for member under master was set i3=1(live)
	UPDATE cs with (ROWLOCK, UPDLOCK)
	SET
		cs.slivepositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0))) 
								THEN cs.slivepositiontaking 		
							ELSE case cs.sporttype WHEN 1 THEN case cs.bettype 
																		WHEN 1 THEN @slivepositiontaking_1 
																		WHEN 3 THEN @slivepositiontaking_3 
																		WHEN 7 THEN @slivepositiontaking_7 
																		WHEN 8 THEN @slivepositiontaking_8 
																		ELSE cs.slivepositiontaking END 
														ELSE cs.slivepositiontaking END
							END
	FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
		INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
	where cs.custid=@custid and c.roleid = 1 and scs.isautolivepositiontaking = 0

	-- number game
	IF (@UpdateMultiple=0 OR @UpdatePositiontakingv161=1)
	BEGIN
		UPDATE cs3 with(rowlock,updlock)
		SET cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																					WHEN 83 THEN @v161spositiontaking_83
																					WHEN 86 THEN @v161spositiontaking_86
																					WHEN 88 THEN @v161spositiontaking_88
																					ELSE 0 END
													ELSE cs3.spositiontaking END
		from custsetting3rd cs3 INNER JOIN custinfo c with(nolock) on cs3.custid = c.custid
			 INNER JOIN custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
		where cs3.custid =@custid and c.roleid = 1 and mcs3.isautopositiontaking = 0	
	
		UPDATE cs3 with (ROWLOCK, UPDLOCK)
		set
			cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																						WHEN 86 THEN @v161slivepositiontaking_86 
																						WHEN 87 THEN @v161slivepositiontaking_87 
																						WHEN 89 THEN @v161slivepositiontaking_89
																						WHEN 90 THEN @v161slivepositiontaking_90
																						ELSE cs3.slivepositiontaking END 
														 ELSE cs3.slivepositiontaking END
		from custsetting3rd cs3 INNER JOIN custinfo c (nolock) on cs3.custid = c.custid
			INNER JOIN custsetting3rd mcs3 (nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
		where cs3.custid=@custid and c.roleid = 1 and mcs3.isautolivepositiontaking = 0
	END
	
	EXEC dbo.Acc_CustomerUpdMember_AutoPositiontaking 
				@custid = @custid,
				@auto_spositiontaking_1 = @auto_spositiontaking_1,
				@auto_spositiontaking_2 = @auto_spositiontaking_2,
				@auto_spositiontaking_3 = @auto_spositiontaking_3,
				@auto_spositiontaking_4 = @auto_spositiontaking_4,
				@auto_spositiontaking_5 = @auto_spositiontaking_5,
				@auto_spositiontaking_6 = @auto_spositiontaking_6,
				@auto_spositiontaking_7 = @auto_spositiontaking_7,
				@auto_spositiontaking_8 = @auto_spositiontaking_8,
				@auto_spositiontaking_9 = @auto_spositiontaking_9,
				@auto_spositiontaking_10 = @auto_spositiontaking_10,
				@auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
				@auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
				@auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
				@auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
				@auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
				@auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
				@auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
				@auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
				@auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,
	--			@auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
				@auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
				@auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
				@auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
				@auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,
				@auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,
				@auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
				@auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
				@auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,
				@auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
				@auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
				@auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,
				@auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,
				@auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
				@auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
				@auto_v10spositiontaking_3 = @auto_v10spositiontaking_3,
				@auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,
				@auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,
				@auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,
				
				@auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
				@auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
				@auto_v99spositiontaking_3 = @auto_v99spositiontaking_3,
				@auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,

				-- mixed sports
				@auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,
				-- number game
				@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
				@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
				@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
				@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
				@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
				@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
				@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
				@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
				@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

				@isauto_spositiontaking_1 = @isauto_spositiontaking_1,
				@isauto_spositiontaking_2 = @isauto_spositiontaking_2,
				@isauto_spositiontaking_3 = @isauto_spositiontaking_3,
				@isauto_spositiontaking_4 = @isauto_spositiontaking_4,
				@isauto_spositiontaking_5 = @isauto_spositiontaking_5,
				@isauto_spositiontaking_6 = @isauto_spositiontaking_6,
				@isauto_spositiontaking_7 = @isauto_spositiontaking_7,
				@isauto_spositiontaking_8 = @isauto_spositiontaking_8,
				@isauto_spositiontaking_9 = @isauto_spositiontaking_9,
				@isauto_spositiontaking_10 = @isauto_spositiontaking_10,
				@isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
				@isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
				@isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
				@isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
				@isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
				@isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
				@isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
				@isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
				@isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,
	--			@isauto_v2spositiontaking_9 = @isauto_v2spositiontaking_9,
				@isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
				@isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
				@isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
				@isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,
				@isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,
				@isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
				@isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
				@isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,
				@isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
				@isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
				@isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
				@isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,
				@isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
				@isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
				@isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,
				@isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,
				@isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,
				@isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,
				
				@isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
				@isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
				@isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,
				@isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,
				-- mixed sports
				@isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
				-- number game
				@isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
				@isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,
				@isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
				@isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
				@isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
				@isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
				@isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
				@isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
				@isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,

				@UpdateMultiple = @UpdateMultiple,
				@UpdatePositiontaking = @UpdatePositiontaking,
				@UpdatePositiontakingv2 = @UpdatePositiontakingv2,
				@UpdatePositiontakingv3 = @UpdatePositiontakingv3,
				@UpdatePositiontakingv5 = @UpdatePositiontakingv5,
				@UpdatePositiontakingv8 = @UpdatePositiontakingv8,
				@UpdatePositiontakingv10 = @UpdatePositiontakingv10,
				@UpdatePositiontakingv11 = @UpdatePositiontakingv11,
				@UpdatePositiontakingv99 = @UpdatePositiontakingv99,
				@UpdatePositiontakingv99MP = @UpdatePositiontakingv99MP,
				@UpdatePositiontakingv161 = @UpdatePositiontakingv161,

				@language = @language,
				@userid = @userid

	EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking 
		@custid = @custid, 
		@recommEND = @recommEND, 
		@mrecommEND = @mrecommEND, 
		@srecommEND = @srecommEND,
		@updautosuper = 0
		
	SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)


	DECLARE @TrackingValue2 varchar(MAX)


	SELECT @LogSPData = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

	'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

	'<s spt_1="'+ coalesce(cast(@spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'spt_2="'+ coalesce(cast(@spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'spt_3="'+ coalesce(cast(@spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'spt_4="'+ coalesce(cast(@spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'spt_5="'+ coalesce(cast(@spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
	'spt_6="'+ coalesce(cast(@spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'spt_7="'+ coalesce(cast(@spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'spt_8="'+ coalesce(cast(@spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'spt_9="'+ coalesce(cast(@spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'spt_10="'+ coalesce(cast(@spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	--number game
	'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
	-- mixed sports
	'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	--i1
	'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'
	--i3
	/*'<isau isa_smpt_1="'+ coalesce(cast(@isauto_smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_2="'+ coalesce(cast(@isauto_smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_3="'+ coalesce(cast(@isauto_smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_4="'+ coalesce(cast(@isauto_smpositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_5="'+ coalesce(cast(@isauto_smpositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_6="'+ coalesce(cast(@isauto_smpositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_7="'+ coalesce(cast(@isauto_smpositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_8="'+ coalesce(cast(@isauto_smpositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_9="'+ coalesce(cast(@isauto_smpositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_10="'+ coalesce(cast(@isauto_smpositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_1="'+ coalesce(cast(@isauto_smlivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_3="'+ coalesce(cast(@isauto_smlivepositiontaking_3 AS varchar(50)),space(1))  + '" ' +
	'isa_smlivept_7="'+ coalesce(cast(@isauto_smlivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_8="'+ coalesce(cast(@isauto_smlivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2smpt_1="'+ coalesce(cast(@isauto_v2smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_2="'+ coalesce(cast(@isauto_v2smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_3="'+ coalesce(cast(@isauto_v2smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_7="'+ coalesce(cast(@isauto_v2smpositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_8="'+ coalesce(cast(@isauto_v2smpositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'isa_v2smpt_9="'+ coalesce(cast(@isauto_v2smpositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_20="'+ coalesce(cast(@isauto_v2smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3smpt_1="'+ coalesce(cast(@isauto_v3smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_2="'+ coalesce(cast(@isauto_v3smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_3="'+ coalesce(cast(@isauto_v3smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_20="'+ coalesce(cast(@isauto_v3smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5smpt_1="'+ coalesce(cast(@isauto_v5smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_2="'+ coalesce(cast(@isauto_v5smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_3="'+ coalesce(cast(@isauto_v5smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_20="'+ coalesce(cast(@isauto_v5smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v8smpt_1="'+ coalesce(cast(@isauto_v8smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8smpt_3="'+ coalesce(cast(@isauto_v8smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8smpt_20="'+ coalesce(cast(@isauto_v8smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10smpt_1="'+ coalesce(cast(@isauto_v10smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10smpt_2="'+ coalesce(cast(@isauto_v10smpositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10smpt_3="'+ coalesce(cast(@isauto_v10smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10smpt_20="'+ coalesce(cast(@isauto_v10smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11smpt_1="'+ coalesce(cast(@isauto_v11smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11smpt_20="'+ coalesce(cast(@isauto_v11smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99smpt_1="'+ coalesce(cast(@isauto_v99smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99smpt_2="'+ coalesce(cast(@isauto_v99smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99smpt_3="'+ coalesce(cast(@isauto_v99smpositiontaking_3 AS varchar(50)),space(1))  + '" ' +
	'isa_v99smpt_20="'+ coalesce(cast(@isauto_v99smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	--mixed sports
	'isa_v99smpt_9="'+ coalesce(cast(@isauto_v99smpositiontaking_9 AS varchar(50)),space(1))  + '" ' +
	-- number game
	'isa_v161smpt_81="'+ coalesce(cast(@isauto_v161smpositiontaking_81 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_83="'+ coalesce(cast(@isauto_v161smpositiontaking_83 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_85="'+ coalesce(cast(@isauto_v161smpositiontaking_85 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_86="'+ coalesce(cast(@isauto_v161smpositiontaking_86 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_85="'+ coalesce(cast(@isauto_v161smlivepositiontaking_85 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_86="'+ coalesce(cast(@isauto_v161smlivepositiontaking_86 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_87="'+ coalesce(cast(@isauto_v161smlivepositiontaking_87 AS varchar(50)),space(1))  + '" /></Acc_CustomerUpdMember_Super>'*/
		
		
	SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

	'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

	'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
	'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	--number game
	'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
	-- mixed sports
	'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	--i1
	'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'

	SET @ENDRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@ENDRun)

	BEGIN TRY
		--Log positiontaking
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 404,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH			
		SELECT @LogSPData = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

		'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

		'<s spt_1="'+ coalesce(cast(@spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'spt_2="'+ coalesce(cast(@spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'spt_3="'+ coalesce(cast(@spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'spt_4="'+ coalesce(cast(@spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'spt_5="'+ coalesce(cast(@spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
		'spt_6="'+ coalesce(cast(@spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'spt_7="'+ coalesce(cast(@spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'spt_8="'+ coalesce(cast(@spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'spt_9="'+ coalesce(cast(@spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'spt_10="'+ coalesce(cast(@spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		--number game
		'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
		-- mixed sports
		'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		--i1
		'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'
					
		SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

		'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

		'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
		'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		--number game
		'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
		-- mixed sports
		'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		--i1
		'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'

		--Log positiontaking
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 404,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration	
	END CATCH		
END--Update Position Taking




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_Super] TO [vnteam]