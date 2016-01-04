ALTER PROCEDURE dbo.Acc_CheckAllowedShow
	@CustID int,
	@AllowedFI bit=1 output, --unused
	@AllowedHR bit=0 output,
	@AllowedCS bit=0 output,
	@AllowedBI bit=0 output,
	@AllowedLiveCS BIT = 0 OUTPUT,
	@AllowedVS BIT = 0 OUTPUT,
	@AllowedColossusbets BIT = 0 OUTPUT,
	@AllowedCockfighting BIT = 0 OUTPUT
	
AS
BEGIN
/*
Created by: 20090525@Simon
Task: Check the showed types. (Finance / Horse Racing / Casino)
DB: DBAGE.BODB02 
Revisions:
	- 20090908@Shifu: Check Allow HR
	- 20100930@Ethan: Check Allow BI
	- 20120207@Johnson: Check allow live casino
	- 20120821@Dan: Check allow VS
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20151231@Helen: Cockfighting - [Redmine: #48133]
	
*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit, @SyncBingo bit, @DisableBingo bit, @SyncLiveCS BIT  , @HideVirtualSports BIT
	Declare @srecommend int, @mrecommend int, @recommend int

	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend
		, @AllowedColossusbets = CASE WHEN HideColossusBet = 0 THEN 1 ELSE 0 END
		
	from custinfo with (nolock) where CustID=@CustID
	
	SET @AllowedCockfighting = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,2) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 THEN 1 ELSE 0 END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedCS=1
		SET @AllowedBI=1
		SET @AllowedLiveCS = 1
		SET @AllowedVS = 1
	END
	ELSE 
	BEGIN 
		-- Check if Replicate run slowly.
		If (@RoleID is null) 
		Begin 
			set @AllowedHR=0
			set @AllowedCS=0
			set @AllowedBI=0
			set @AllowedLiveCS = 0
			return
		End
		-- For Casino (Check Upline allowed Casino)
		if @RoleID=3
			Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino, @HideVirtualSports=HideVirtualSports from custinfo with (nolock) where CustID=@srecommend	
		Else if @RoleID=2
			Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino, @HideVirtualSports=HideVirtualSports from custinfo with (nolock) where CustID=@mrecommend	
		Else if @RoleID=1
			Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino, @HideVirtualSports=HideVirtualSports from custinfo with (nolock) where CustID=@recommend		
		
		-- For Casino
		if @SyncCasino!=1
			set @AllowedCS=0
		else
			set @AllowedCS=1
			
		-- For Bingo
		if @SyncBingo!=1 
			set @AllowedBI=0
		else
			set @AllowedBI=1
		
		-- For live casino
		if @SyncLiveCS != 1
			set @AllowedLiveCS = 0
		else
			set @AllowedLiveCS = 1
		
		-- For VS
		SET @AllowedVS = CASE WHEN ISNULL(@HideVirtualSports,0) = 0 THEN 1 ELSE 0 END			
	End

	-- For Horse Racing	
	Exec Acc_CheckHRAllowedCurrency @CurrencyID=@mCurrencyID, @Allowed= @AllowedHR OUTPUT
END
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CheckAllowedShow] TO vnteam