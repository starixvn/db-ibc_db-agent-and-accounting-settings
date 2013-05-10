ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_MAg]
	@custid int OUTPUT,
	@firstname nvarchar(50),
	@lastname nvarchar(50),
	@creator int,
	@username varchar(30),
	@userpwd varchar(40),
	@discountcs decimal(9,8),
	--1x2
	@discount1x2 decimal(9,8) = 0,
	
	-- number game commission
	@discountnumber decimal(9,8) = 0,

	@phone nvarchar(50),
	@mobilephone nvarchar(50),
	@email nvarchar(50),
	@fax nvarchar(50),
	@address nvarchar(80),
	@city nvarchar(50),
	@state nvarchar(50),
	@country nvarchar(50),
	@postal nvarchar(50),
	@groupa decimal(9,8),
	@groupb decimal(9,8),
	@groupc decimal(9,8),
	@groupd decimal(9,8),
	@TransferOption varchar(8) = NULL, --pass value (not NULL) in case direct master add new agent
	@suspended bit = null,
	@Disable151_31 bit = 0,-- @DisableHorseRacing -> @Disable151_31
	@Disable151_41 bit = 0,-- @DisableOpenTote -> @Disable151_41
	@Disable151_51 bit = 0, -- @Disable151_AU -> @Disable151_51
	@Disable152_41 bit = 0, -- @Disable152_UK -> @Disable152_41
	@Disable152_51 bit = 0, -- @Disable152_AU -> @Disable152_51
	@Disable153_51 bit = 0,-- @Disable153_AU -> @Disable153_51
	@DisableFinancial bit = 0,
	@DisableCasino bit = 0, 
	@suspendedFlag varchar(6)=null,
	@IsInternal bit = 0,
	
	-- bingo & number game status
	@DisableBingo bit = 0,
	@DisableNumber bit = 0,	
	
	-- Live casino
	@Disable162_1101 bit = 0,
	
	@MinBet money,
	@MaxBet money,
	@MaxPerMatch money,
	
	@MinBetv2 money,
	@MaxBetv2 money,
	@MaxPerMatchv2 money,

	@MinBetv3 money,
	@MaxBetv3 money,
	@MaxPerMatchv3 money,

	@MinBetv5 money,
	@MaxBetv5 money,
	@MaxPerMatchv5 money,

	@MinBetv8 money,
	@MaxBetv8 money,
	@MaxPerMatchv8 money,

	@MinBetv10 money,
	@MaxBetv10 money,
	@MaxPerMatchv10 money,

	@MinBetv11 money,
	@MaxBetv11 money,
	@MaxPerMatchv11 money,

	@MinBetv99 money,
	@MaxBetv99 money,
	@MaxPerMatchv99 money,
	
	-- mix parlay of mixed sports
	@MinBetv99mp money,
	@MaxBetv99mp money,
	@MaxPerMatchv99mp money,
	-- number game
	@MinBetv161 money,
	@MaxBetv161 money,
	@MaxPerMatchv161 money,

	@MaxPerBallv161 money = 0,		

	@credit money,
	@maxcredit money = 0,
	@mrecommend int,
	@apositiontaking_1 smallmoney,
	@apositiontaking_2 smallmoney,
	@apositiontaking_3 smallmoney,
	@apositiontaking_4 smallmoney,
	@apositiontaking_5 smallmoney,
	@apositiontaking_6 smallmoney,
	@apositiontaking_7 smallmoney,
	@apositiontaking_8 smallmoney,
	@apositiontaking_9 smallmoney,
	@apositiontaking_10 smallmoney,
	
	@mpositiontaking_1 smallmoney,
	@mpositiontaking_2 smallmoney,
	@mpositiontaking_3 smallmoney,
	@mpositiontaking_4 smallmoney,
	@mpositiontaking_5 smallmoney,
	@mpositiontaking_6 smallmoney,
	@mpositiontaking_7 smallmoney,
	@mpositiontaking_8 smallmoney,
	@mpositiontaking_9 smallmoney,
	@mpositiontaking_10 smallmoney,
	
	@alivepositiontaking_1 smallmoney,
	@alivepositiontaking_3 smallmoney,
	@alivepositiontaking_7 smallmoney,
	@alivepositiontaking_8 smallmoney,
	@mlivepositiontaking_1 smallmoney,
	@mlivepositiontaking_3 smallmoney,
	@mlivepositiontaking_7 smallmoney,
	@mlivepositiontaking_8 smallmoney,
	
	@v2apositiontaking_1 smallmoney,
	@v2apositiontaking_2 smallmoney,
	@v2apositiontaking_3 smallmoney,
	@v2apositiontaking_7 smallmoney,
	@v2apositiontaking_8 smallmoney,
--	@v2apositiontaking_9 smallmoney,
	@v2apositiontaking_20 smallmoney,

	@v3apositiontaking_1 smallmoney,
	@v3apositiontaking_2 smallmoney,
	@v3apositiontaking_3 smallmoney,
	@v3apositiontaking_20 smallmoney,

	@v5apositiontaking_1 smallmoney,
	@v5apositiontaking_2 smallmoney,
	@v5apositiontaking_3 smallmoney,
	@v5apositiontaking_20 smallmoney,

	@v8apositiontaking_1 smallmoney,
	@v8apositiontaking_3 smallmoney,
	@v8apositiontaking_20 smallmoney,

	@v10apositiontaking_1 smallmoney,
	@v10apositiontaking_2 smallmoney,
	@v10apositiontaking_3 smallmoney,
	@v10apositiontaking_20 smallmoney,

	@v11apositiontaking_1 smallmoney,
	@v11apositiontaking_20 smallmoney,

	@v99apositiontaking_1 smallmoney,
	@v99apositiontaking_2 smallmoney,
	@v99apositiontaking_3 smallmoney,
	@v99apositiontaking_20 smallmoney,
	
	-- mix parlay of mixed sports	
	@v99apositiontaking_9 smallmoney, 

	
	@v161apositiontaking_81 smallmoney,
	@v161apositiontaking_83 smallmoney,
	--@v161apositiontaking_85 smallmoney,
	@v161apositiontaking_86 smallmoney,
	@v161apositiontaking_88 smallmoney = 0,
	
	@v161alivepositiontaking_85 smallmoney,
	@v161alivepositiontaking_86 smallmoney,	
	@v161alivepositiontaking_87 smallmoney,
	@v161alivepositiontaking_89 smallmoney = 0,	
	@v161alivepositiontaking_90 smallmoney = 0,
	
	
	@v2mpositiontaking_1 smallmoney,
	@v2mpositiontaking_2 smallmoney,
	@v2mpositiontaking_3 smallmoney,
	@v2mpositiontaking_7 smallmoney,
	@v2mpositiontaking_8 smallmoney,
--	@v2mpositiontaking_9 smallmoney,
	@v2mpositiontaking_20 smallmoney,

	@v3mpositiontaking_1 smallmoney,
	@v3mpositiontaking_2 smallmoney,
	@v3mpositiontaking_3 smallmoney,
	@v3mpositiontaking_20 smallmoney,

	@v5mpositiontaking_1 smallmoney,
	@v5mpositiontaking_2 smallmoney,
	@v5mpositiontaking_3 smallmoney,
	@v5mpositiontaking_20 smallmoney,

	@v8mpositiontaking_1 smallmoney,
	@v8mpositiontaking_3 smallmoney,
	@v8mpositiontaking_20 smallmoney,

	@v10mpositiontaking_1 smallmoney,
	@v10mpositiontaking_2 smallmoney,
	@v10mpositiontaking_3 smallmoney,
	@v10mpositiontaking_20 smallmoney,

	@v11mpositiontaking_1 smallmoney,
	@v11mpositiontaking_20 smallmoney,

	@v99mpositiontaking_1 smallmoney,
	@v99mpositiontaking_2 smallmoney,
	@v99mpositiontaking_3 smallmoney,
	@v99mpositiontaking_20 smallmoney,
	
	-- mix parlay of mixed sports
	@v99mpositiontaking_9 smallmoney,

	-- number game
	@v161mpositiontaking_81 smallmoney,
	@v161mpositiontaking_83 smallmoney,
	--@v161mpositiontaking_85 smallmoney,
	@v161mpositiontaking_86 smallmoney,
	@v161mpositiontaking_88 smallmoney = 0,
		
	@v161mlivepositiontaking_85 smallmoney,
	@v161mlivepositiontaking_86 smallmoney,
	@v161mlivepositiontaking_87 smallmoney,
	@v161mlivepositiontaking_89 smallmoney = 0,
	@v161mlivepositiontaking_90 smallmoney = 0,
	
	
	--Auto Master PT
	@auto_mpositiontaking_1 smallmoney = 0,
	@auto_mpositiontaking_2 smallmoney = 0,
	@auto_mpositiontaking_3 smallmoney = 0,
	@auto_mpositiontaking_4 smallmoney = 0,
	@auto_mpositiontaking_5 smallmoney = 0,
	@auto_mpositiontaking_6 smallmoney = 0,
	@auto_mpositiontaking_7 smallmoney = 0,
	@auto_mpositiontaking_8 smallmoney = 0,
	@auto_mpositiontaking_9 smallmoney = 0,
	@auto_mpositiontaking_10 smallmoney = 0,
	@auto_mlivepositiontaking_1 smallmoney = 0,
	@auto_mlivepositiontaking_3 smallmoney = 0,
	@auto_mlivepositiontaking_7 smallmoney = 0,
	@auto_mlivepositiontaking_8 smallmoney = 0,
	
	@auto_v2mpositiontaking_1 smallmoney = 0,
	@auto_v2mpositiontaking_2 smallmoney = 0,
	@auto_v2mpositiontaking_3 smallmoney = 0,
	@auto_v2mpositiontaking_7 smallmoney = 0,
	@auto_v2mpositiontaking_8 smallmoney = 0,
--	@auto_v2mpositiontaking_9 smallmoney = 0,
	@auto_v2mpositiontaking_20 smallmoney = 0,
	
	@auto_v3mpositiontaking_1 smallmoney = 0,
	@auto_v3mpositiontaking_2 smallmoney = 0,
	@auto_v3mpositiontaking_3 smallmoney = 0,	
	@auto_v3mpositiontaking_20 smallmoney = 0,
	
	@auto_v5mpositiontaking_1 smallmoney = 0,
	@auto_v5mpositiontaking_2 smallmoney = 0,
	@auto_v5mpositiontaking_3 smallmoney = 0,	
	@auto_v5mpositiontaking_20 smallmoney = 0,
	
	@auto_v8mpositiontaking_1 smallmoney = 0,	
	@auto_v8mpositiontaking_3 smallmoney = 0,	
	@auto_v8mpositiontaking_20 smallmoney = 0,
	
	@auto_v10mpositiontaking_1 smallmoney = 0,
	@auto_v10mpositiontaking_2 smallmoney = 0,
	@auto_v10mpositiontaking_3 smallmoney = 0,	
	@auto_v10mpositiontaking_20 smallmoney = 0,
	
	@auto_v11mpositiontaking_1 smallmoney = 0,	
	@auto_v11mpositiontaking_20 smallmoney = 0,
	
	@auto_v99mpositiontaking_1 smallmoney = 0,
	@auto_v99mpositiontaking_2 smallmoney = 0,
	@auto_v99mpositiontaking_3 smallmoney = 0,	
	@auto_v99mpositiontaking_20 smallmoney = 0,	

	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 smallmoney = 0,

	-- number game
	@auto_v161mpositiontaking_81 smallmoney = 0,
	@auto_v161mpositiontaking_83 smallmoney = 0,
	--@auto_v161mpositiontaking_85 smallmoney = 0,
	@auto_v161mpositiontaking_86 smallmoney = 0,
	@auto_v161mpositiontaking_88 smallmoney = 0,
	
	@auto_v161mlivepositiontaking_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_90 smallmoney = 0,
	
	-- P2P Game Setting
	@DisableP2P BIT = 0,
	@DisableFUNP2P BIT = 0,	
	
	@sitename varchar(20) = '',
	@IP varchar(15)='',
	
	@Language varchar(2)= 'E',
	@SubAccID int = 0, --Sub-AccountID
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Master create Agent
DB: DBTXN/bodb02
Original:

Revisions:
    - 20081009@Phuc: Auto Master PT, Remove site 777
    - 20081022@Phuc: Add new sporttype 201, bettype 3 Hard code copy min/max/maxperbet/PT for 201 from 2 sporttype
	- 20090122@PhuongNguyen: Remove userpwd from log writing
	- 20090122@PhuongDao: Add new sporttype 201, bettype 2.
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission.
	- 20090407@Phuc: IF DisableFinancial (upline or webconfig) set m2 = n3, a2 = 0; get minbet201, maxbet201, maxpermatch201 from upline
	- 20090410@Kiwi: Fix to select @DisableFinancial_WC instead of @DisableFinancial
	- 20090417@PhuongDao: Set default virtualrate = 0%
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed  
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Simon: Write Credit Log into Userlog_Credit table.
	- 20090917@Phuc: write log into DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status from the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100831@Lukas:	- Add setting information for Number game.
						- Add setting information for mix parlay of mixed sports 
						- Remove mix parlay of basketball
	- 20100909@Jamie: + Add param @DisableCasino to check the upline's setting 
					  + Remove param @DisableFinancial_WC 	
	- 20101019@Henry: Record execution time
	- 20101027@Lukas: Add max per ball (number game)
	-20101231@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110520@Johnson: Allow spaces between words in user name when creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20110822@Tom: Add P2P setting.
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@Error for inserting P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (from upline)
	- 20111226@Lukas: Add Live casino game - PT setting
	- 20120210@TOM: Insert default value of P2P Comm	
	- 20120502@Lukas: Encode XML values in logging
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120807@Dan: add default setting for virtual soccer
	- 20120928@Johnson: add double comm losing status
	- 20121011@Dan: add win limit setting for live casino
	- 20130219@Johnson: write log on DBTXN if DBLOG failure

Param's Explanation:
• @ErrCode:
    = 0: Create agent successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/


SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--NOT allow masters under KH, KM, KR to create agents
--Requested by wan 17-Jan-2007
--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
--20081218_By_AhWan: KER - 1238537
--20090112_Wan: unblock KM 194354
--20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
if exists (select 1 from custinfo with (nolock) where custid = @mrecommend and srecommend  = 726582)
BEGIN	
	Select @ErrMsg = case @Language 
							when 'E' then 'Sorry, cannot create agent.'
							when 'CS' then N'对不起，无法新增代理.'
							when 'CT' then N'對不起,無法新增代理.'
							when 'TH' then N'ขออภัย คุณไม่สามารถสร้างตัวแทนได้คะ.'
							when 'J' then N'Sorry, cannot create agent.'
							when 'ES' then N'Sorry, cannot create agent.'
							when 'KO' then N'죄송합니다. 에이전트를 만들 수 없습니다.'
							else N'Sorry, cannot create agent.'
						end,
		@ErrCode = 100
	return
END

--Check an account disabled or not 
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @mrecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
if @ErrCode <>0		return 


/*
--if not exists (select 1 from custinfo with (nolock) where custid = @custid and mrecommend =4300)
if @mrecommend <> 4300 
BEGIN
	declare @ErrMsg varchar(200)
	Select @ErrMsg = 'Sorry, please try again later.'
	RaisError (@ErrMsg, 16, 1)
	return
END
*/

declare @ErrType varchar(4000)
declare 
	@transcode bigint, @currency int, @pwdexpiry datetime, @site nvarchar(50),
	@MinMinBet money, @MaxMaxBet money, @MaxMaxPerMatch money, 
	@MinMinBetv2 money, @MaxMaxBetv2 money, @MaxMaxPerMatchv2 money, 
	@MinMinBetv3 money, @MaxMaxBetv3 money, @MaxMaxPerMatchv3 money, 
	@MinMinBetv5 money, @MaxMaxBetv5 money, @MaxMaxPerMatchv5 money,
	@MinMinBetv8 money, @MaxMaxBetv8 money, @MaxMaxPerMatchv8 money,
	@MinMinBetv10 money, @MaxMaxBetv10 money, @MaxMaxPerMatchv10 money,
	@MinMinBetv11 money, @MaxMaxBetv11 money, @MaxMaxPerMatchv11 money,
	@MinMinBetv99 money, @MaxMaxBetv99 money, @MaxMaxPerMatchv99 money,
	@MinMinBetv99mp money, @MaxMaxBetv99mp money, @MaxMaxPerMatchv99mp money,
	@MinMinBetv161 money, @MaxMaxBetv161 money, @MaxMaxPerMatchv161 money, 
	@MaxMaxPerBallv161 money,
	@MinBetv180 money, @MaxBetv180 money, @MaxPerMatchv180 money,
	@MinMinBetv180 money, @MaxMaxBetv180 money, @MaxMaxPerMatchv180 money, 
	@Credit_AllOtherAgent money, @Credit_AllMember money, @Credit_MAg money,
	--@MaxPerMatch_AllOtherAgent money, @MaxPerMatch_AllMember money, @MaxPerMatch_MAg money,
	--@MaxPerMatchv2_AllOtherAgent money, @MaxPerMatchv2_AllMember money, @MaxPerMatchv2_MAg money,
	@srecommend int,	 
	@matchlimit smallmoney,
	@TransferOption_dec tinyint,
	@Msuspended bit,
	@UplineClosed bit,
	@DisableOutright bit,
	@UplineSyncLiveCasino bit,
	@HideVirtualSports  BIT,
	@DoubleCommLosing BIT,
	@isAutoResetLiveCasino BIT , 
	@MaxWinLiveCasino SMALLMONEY 

declare
	@max_mapositiontaking_1 smallmoney,
	@max_mapositiontaking_2 smallmoney,
	@max_mapositiontaking_3 smallmoney,
	@max_mapositiontaking_4 smallmoney,
	@max_mapositiontaking_5 smallmoney,
	@max_mapositiontaking_6 smallmoney,
	@max_mapositiontaking_7 smallmoney,
	@max_mapositiontaking_8 smallmoney,
	@max_mapositiontaking_9 smallmoney,
	@max_mapositiontaking_10 smallmoney,
	
	@max_malivepositiontaking_1 smallmoney,
	@max_malivepositiontaking_3 smallmoney,
	@max_malivepositiontaking_7 smallmoney,
	@max_malivepositiontaking_8 smallmoney,
	
	@max_v2mapositiontaking_1 smallmoney,
	@max_v2mapositiontaking_2 smallmoney,
	@max_v2mapositiontaking_3 smallmoney,
	@max_v2mapositiontaking_7 smallmoney,
	@max_v2mapositiontaking_8 smallmoney,
--	@max_v2mapositiontaking_9 smallmoney,
	@max_v2mapositiontaking_20 smallmoney,

	@max_v3mapositiontaking_1 smallmoney,
	@max_v3mapositiontaking_2 smallmoney,
	@max_v3mapositiontaking_3 smallmoney,
	@max_v3mapositiontaking_20 smallmoney,

	@max_v5mapositiontaking_1 smallmoney,
	@max_v5mapositiontaking_2 smallmoney,
	@max_v5mapositiontaking_3 smallmoney,
	@max_v5mapositiontaking_20 smallmoney,

	@max_v8mapositiontaking_1 smallmoney,
	@max_v8mapositiontaking_3 smallmoney,
	@max_v8mapositiontaking_20 smallmoney,

	@max_v10mapositiontaking_1 smallmoney,
	@max_v10mapositiontaking_2 smallmoney,
	@max_v10mapositiontaking_3 smallmoney,
	@max_v10mapositiontaking_20 smallmoney,

	@max_v11mapositiontaking_1 smallmoney,
	@max_v11mapositiontaking_20 smallmoney,

	@max_v99mapositiontaking_1 smallmoney,
	@max_v99mapositiontaking_2 smallmoney,
	@max_v99mapositiontaking_3 smallmoney,
	@max_v99mapositiontaking_20 smallmoney,

	-- mix parlay of mixed sports
	@max_v99mapositiontaking_9 smallmoney,

	@max_v161mapositiontaking_81 smallmoney,
	@max_v161mapositiontaking_83 smallmoney,
	--@max_v161mapositiontaking_85 smallmoney,
	@max_v161mapositiontaking_86 smallmoney,
	@max_v161mapositiontaking_88 smallmoney,
	
	@max_v161malivepositiontaking_85 smallmoney,
	@max_v161malivepositiontaking_86 smallmoney,
	@max_v161malivepositiontaking_87 smallmoney,	
	@max_v161malivepositiontaking_89 smallmoney,
	@max_v161malivepositiontaking_90 smallmoney,
	@min_v180mpositiontaking_1201 smallmoney,--VS

	--Auto Master PT
	@isauto_mpositiontaking_1 smallmoney,
	@isauto_mpositiontaking_2 smallmoney,
	@isauto_mpositiontaking_3 smallmoney,
	@isauto_mpositiontaking_4 smallmoney,
	@isauto_mpositiontaking_5 smallmoney,
	@isauto_mpositiontaking_6 smallmoney,
	@isauto_mpositiontaking_7 smallmoney,
	@isauto_mpositiontaking_8 smallmoney,
	@isauto_mpositiontaking_9 smallmoney,
	@isauto_mpositiontaking_10 smallmoney,
	
	@isauto_mlivepositiontaking_1 smallmoney,
	@isauto_mlivepositiontaking_3 smallmoney,
	@isauto_mlivepositiontaking_7 smallmoney,
	@isauto_mlivepositiontaking_8 smallmoney,
	
	@isauto_v2mpositiontaking_1 smallmoney,
	@isauto_v2mpositiontaking_2 smallmoney,
	@isauto_v2mpositiontaking_3 smallmoney,
	@isauto_v2mpositiontaking_7 smallmoney,
	@isauto_v2mpositiontaking_8 smallmoney,
--	@isauto_v2mpositiontaking_9 smallmoney,
	@isauto_v2mpositiontaking_20 smallmoney,
	
	@isauto_v3mpositiontaking_1 smallmoney,
	@isauto_v3mpositiontaking_2 smallmoney,
	@isauto_v3mpositiontaking_3 smallmoney,	
	@isauto_v3mpositiontaking_20 smallmoney,
	
	@isauto_v5mpositiontaking_1 smallmoney,
	@isauto_v5mpositiontaking_2 smallmoney,
	@isauto_v5mpositiontaking_3 smallmoney,	
	@isauto_v5mpositiontaking_20 smallmoney,
	
	@isauto_v8mpositiontaking_1 smallmoney,	
	@isauto_v8mpositiontaking_3 smallmoney,	
	@isauto_v8mpositiontaking_20 smallmoney,
	
	@isauto_v10mpositiontaking_1 smallmoney,
	@isauto_v10mpositiontaking_2 smallmoney,
	@isauto_v10mpositiontaking_3 smallmoney,	
	@isauto_v10mpositiontaking_20 smallmoney,
	
	@isauto_v11mpositiontaking_1 smallmoney,	
	@isauto_v11mpositiontaking_20 smallmoney,

	@isauto_v99mpositiontaking_1 smallmoney,
	@isauto_v99mpositiontaking_2 smallmoney,
	@isauto_v99mpositiontaking_3 smallmoney,	
	@isauto_v99mpositiontaking_20 smallmoney,

	--- mix parlay of mixed sports
	@isauto_v99mpositiontaking_9 smallmoney,
	
	-- number game
	@isauto_v161mpositiontaking_81 smallmoney,
	@isauto_v161mpositiontaking_83 smallmoney,
	--@isauto_v161mpositiontaking_85 smallmoney,
	@isauto_v161mpositiontaking_86 smallmoney,
	@isauto_v161mpositiontaking_88 smallmoney,
	
	@isauto_v161mlivepositiontaking_85 smallmoney,
	@isauto_v161mlivepositiontaking_86 smallmoney,	
	@isauto_v161mlivepositiontaking_87 smallmoney,
	@isauto_v161mlivepositiontaking_89 smallmoney,
	@isauto_v161mlivepositiontaking_90 smallmoney,
    @virtualmultiplier smallmoney,
    @Disable180_1201 BIT
    
select 
	@currency = currency, 
	@Msuspended = reject,
	@UplineClosed = closed,
	@UplineSyncLiveCasino = SyncLiveCasino,
	@Credit_MAg = isnull(credit, 0),
	--@MaxPerMatch_MAg = isnull(MaxPerMatch, 0),
	--@MaxPerMatchv2_MAg = isnull(MaxPerMatchb, 0),
	@srecommend = srecommend,
	@matchlimit = matchlimit,
	@MaxPerMatchv180 = MaxPerMatch180,
	@Disable151_31 = case when DisableHorseRacing = 1 then 1 else @Disable151_31 end,
	@Disable151_41 = case when DisableOpenTote = 1 then 1 else @Disable151_41 end,
	@Disable151_51 = case when Disable151_AU = 1 then 1 else @Disable151_51 end,
	@Disable152_41 = case when Disable152_UK = 1 then 1 else @Disable152_41 end,
	@Disable152_51 = case when Disable152_AU = 1 then 1 else @Disable152_51 end,
	@Disable153_51 = case when Disable153_AU = 1 then 1 else @Disable153_51 end,
	@DisableFinancial = case when DisableFinancial = 1 then 1 else @DisableFinancial end,
	@DisableCasino = case when DisableCasino = 1 then 1 else @DisableCasino end,	
	@DisableOutright = DisableOutright,
	@DisableBingo = case when DisableBingo = 1 then 1 else @DisableBingo end,
	@DisableNumber = case when DisableNumber = 1 then 1 else @DisableNumber end,
	@DisableP2P = case when DisableP2P = 1 then 1 else @DisableP2P end,
	@DisableFUNP2P = case when DisableFUNP2P = 1 then 1 else @DisableFUNP2P end,
	@Disable162_1101 = case when DisableLiveCasino = 1 then 1 else @Disable162_1101 end,
	@Disable180_1201 = DisableVirtualSports,
	@HideVirtualSports = HideVirtualSports,
	@DoubleCommLosing = DoubleCommLosing,
	@virtualmultiplier = ISNULL(virtualmultiplier,1),
	@MaxWinLiveCasino = MaxWinLiveCasino,
	@isAutoResetLiveCasino = isAutoResetLiveCasino
from CustInfo as ci with (NOLOCK) 
where CustID = @mrecommend


Select @ErrCode = 0
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @IsValid bit
EXEC dbo.Acc_CustomerInsMember_MAg_CheckParam 
	@discountcs=@discountcs,
	@discount1x2 = @discount1x2, --1x2
	@discountnumber = @discountnumber,
	@groupa=@groupa,
	@groupb=@groupb,
	@groupc=@groupc,
	@groupd=@groupd,
	@MinBet=@MinBet,
	@MaxBet=@MaxBet,
	@MaxPerMatch=@MaxPerMatch,
	
	@MinBetv2=@MinBetv2,
	@MaxBetv2=@MaxBetv2,
	@MaxPerMatchv2=@MaxPerMatchv2,

	@MinBetv3=@MinBetv3,
	@MaxBetv3=@MaxBetv3,
	@MaxPerMatchv3=@MaxPerMatchv3,

	@MinBetv5=@MinBetv5,
	@MaxBetv5=@MaxBetv5,
	@MaxPerMatchv5=@MaxPerMatchv5,

	@MinBetv8=@MinBetv8,
	@MaxBetv8=@MaxBetv8,
	@MaxPerMatchv8=@MaxPerMatchv8,

	@MinBetv10=@MinBetv10,
	@MaxBetv10=@MaxBetv10,
	@MaxPerMatchv10=@MaxPerMatchv10,

	@MinBetv11=@MinBetv11,
	@MaxBetv11=@MaxBetv11,
	@MaxPerMatchv11=@MaxPerMatchv11,

	@MinBetv99=@MinBetv99,
	@MaxBetv99=@MaxBetv99,
	@MaxPerMatchv99=@MaxPerMatchv99,
	
	-- mix parlay of mixed sports
	@MinBetv99mp = @MinBetv99mp,
	@MaxBetv99mp = @MaxBetv99mp,
	@MaxPerMatchv99mp = @MaxPerMatchv99mp,

	--number game
	@MinBetv161 = @MinBetv161,
	@MaxBetv161 = @MaxBetv161,
	@MaxPerMatchv161 = @MaxPerMatchv161,
	
	@MaxPerBallv161 = @MaxPerBallv161,
	
	@credit=@credit,
	@maxcredit = @maxcredit,
	@mrecommend=@mrecommend,
	
	@apositiontaking_1=@apositiontaking_1,
	@apositiontaking_2=@apositiontaking_2,
	@apositiontaking_3=@apositiontaking_3,
	@apositiontaking_4=@apositiontaking_4,
	@apositiontaking_5=@apositiontaking_5,
	@apositiontaking_6=@apositiontaking_6,
	@apositiontaking_7=@apositiontaking_7,
	@apositiontaking_8=@apositiontaking_8,
	@apositiontaking_9=@apositiontaking_9,
	@apositiontaking_10=@apositiontaking_10,
	
	@mpositiontaking_1=@mpositiontaking_1,
	@mpositiontaking_2=@mpositiontaking_2,
	@mpositiontaking_3=@mpositiontaking_3,
	@mpositiontaking_4=@mpositiontaking_4,
	@mpositiontaking_5=@mpositiontaking_5,
	@mpositiontaking_6=@mpositiontaking_6,
	@mpositiontaking_7=@mpositiontaking_7,
	@mpositiontaking_8=@mpositiontaking_8,
	@mpositiontaking_9=@mpositiontaking_9,
	@mpositiontaking_10=@mpositiontaking_10,
	
	@alivepositiontaking_1=@alivepositiontaking_1,
	@alivepositiontaking_3=@alivepositiontaking_3,
	@alivepositiontaking_7=@alivepositiontaking_7,
	@alivepositiontaking_8=@alivepositiontaking_8,
	
	@mlivepositiontaking_1=@mlivepositiontaking_1,
	@mlivepositiontaking_3=@mlivepositiontaking_3,
	@mlivepositiontaking_7=@mlivepositiontaking_7,
	@mlivepositiontaking_8=@mlivepositiontaking_8,
	
	@v2apositiontaking_1=@v2apositiontaking_1,
	@v2apositiontaking_2=@v2apositiontaking_2,
	@v2apositiontaking_3=@v2apositiontaking_3,
	@v2apositiontaking_7=@v2apositiontaking_7,
	@v2apositiontaking_8=@v2apositiontaking_8,
--	@v2apositiontaking_9=@v2apositiontaking_9,
	@v2apositiontaking_20=@v2apositiontaking_20,
	
	@v3apositiontaking_1=@v3apositiontaking_1,
	@v3apositiontaking_2=@v3apositiontaking_2,
	@v3apositiontaking_3=@v3apositiontaking_3,
	@v3apositiontaking_20=@v3apositiontaking_20,

	@v5apositiontaking_1=@v5apositiontaking_1,
	@v5apositiontaking_2=@v5apositiontaking_2,
	@v5apositiontaking_3=@v5apositiontaking_3,
	@v5apositiontaking_20=@v5apositiontaking_20,

	@v8apositiontaking_1=@v8apositiontaking_1,
	@v8apositiontaking_3=@v8apositiontaking_3,
	@v8apositiontaking_20=@v8apositiontaking_20,

	@v10apositiontaking_1=@v10apositiontaking_1,
	@v10apositiontaking_2=@v10apositiontaking_2,
	@v10apositiontaking_3=@v10apositiontaking_3,
	@v10apositiontaking_20=@v10apositiontaking_20,

	@v11apositiontaking_1=@v11apositiontaking_1,
	@v11apositiontaking_20=@v11apositiontaking_20,

	@v99apositiontaking_1=@v99apositiontaking_1,
	@v99apositiontaking_2=@v99apositiontaking_2,
	@v99apositiontaking_3=@v99apositiontaking_3,
	@v99apositiontaking_20=@v99apositiontaking_20,
	
	-- mix parlay of mixed sports
	@v99apositiontaking_9 = @v99apositiontaking_9,
	
	-- number game
	@v161apositiontaking_81 = @v161apositiontaking_81,
	@v161apositiontaking_83 = @v161apositiontaking_83,
	--@v161apositiontaking_85 = @v161apositiontaking_85,
	@v161apositiontaking_86 = @v161apositiontaking_86,
	@v161apositiontaking_88 = @v161apositiontaking_88,
	
	@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
	@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
	@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
	@v161alivepositiontaking_89 = @v161alivepositiontaking_89,
	@v161alivepositiontaking_90 = @v161alivepositiontaking_90,
	
	@v2mpositiontaking_1=@v2mpositiontaking_1,
	@v2mpositiontaking_2=@v2mpositiontaking_2,
	@v2mpositiontaking_3=@v2mpositiontaking_3,
	@v2mpositiontaking_7=@v2mpositiontaking_7,
	@v2mpositiontaking_8=@v2mpositiontaking_8,
--	@v2mpositiontaking_9=@v2mpositiontaking_9,
	@v2mpositiontaking_20=@v2mpositiontaking_20,
	
	@v3mpositiontaking_1=@v3mpositiontaking_1,
	@v3mpositiontaking_2=@v3mpositiontaking_2,
	@v3mpositiontaking_3=@v3mpositiontaking_3,
	@v3mpositiontaking_20=@v3mpositiontaking_20,

	@v5mpositiontaking_1=@v5mpositiontaking_1,
	@v5mpositiontaking_2=@v5mpositiontaking_2,
	@v5mpositiontaking_3=@v5mpositiontaking_3,
	@v5mpositiontaking_20=@v5mpositiontaking_20,

	@v8mpositiontaking_1=@v8mpositiontaking_1,
	@v8mpositiontaking_3=@v8mpositiontaking_3,
	@v8mpositiontaking_20=@v8mpositiontaking_20,

	@v10mpositiontaking_1=@v10mpositiontaking_1,
	@v10mpositiontaking_2=@v10mpositiontaking_2,
	@v10mpositiontaking_3=@v10mpositiontaking_3,
	@v10mpositiontaking_20=@v10mpositiontaking_20,

	@v11mpositiontaking_1=@v11mpositiontaking_1,
	@v11mpositiontaking_20=@v11mpositiontaking_20,

	@v99mpositiontaking_1=@v99mpositiontaking_1,
	@v99mpositiontaking_2=@v99mpositiontaking_2,
	@v99mpositiontaking_3=@v99mpositiontaking_3,
	@v99mpositiontaking_20=@v99mpositiontaking_20,

	-- mix parlay of mixed sports
	@v99mpositiontaking_9=@v99mpositiontaking_9,
	
	-- number game
	@v161mpositiontaking_81 = @v161mpositiontaking_81,
	@v161mpositiontaking_83 = @v161mpositiontaking_83,
	--@v161mpositiontaking_85 = @v161mpositiontaking_85,
	@v161mpositiontaking_86 = @v161mpositiontaking_86,
	@v161mpositiontaking_88 = @v161mpositiontaking_88,
	
	@v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
	@v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
	@v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
	@v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
	@v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,

	--Auto Master PT
	@auto_mpositiontaking_1 = @auto_mpositiontaking_1,
	@auto_mpositiontaking_2 = @auto_mpositiontaking_2,
	@auto_mpositiontaking_3 = @auto_mpositiontaking_3,
	@auto_mpositiontaking_4 = @auto_mpositiontaking_4,
	@auto_mpositiontaking_5 = @auto_mpositiontaking_5,
	@auto_mpositiontaking_6 = @auto_mpositiontaking_6,
	@auto_mpositiontaking_7 = @auto_mpositiontaking_7,
	@auto_mpositiontaking_8 = @auto_mpositiontaking_8,
	@auto_mpositiontaking_9 = @auto_mpositiontaking_9,
	@auto_mpositiontaking_10 = @auto_mpositiontaking_10,
	@auto_mlivepositiontaking_1 = @auto_mlivepositiontaking_1,
	@auto_mlivepositiontaking_3 = @auto_mlivepositiontaking_3,
	@auto_mlivepositiontaking_7 = @auto_mlivepositiontaking_7,
	@auto_mlivepositiontaking_8 = @auto_mlivepositiontaking_8,
	
	@auto_v2mpositiontaking_1 = @auto_v2mpositiontaking_1,
	@auto_v2mpositiontaking_2 = @auto_v2mpositiontaking_2,
	@auto_v2mpositiontaking_3 = @auto_v2mpositiontaking_3,
	@auto_v2mpositiontaking_7 = @auto_v2mpositiontaking_7,
	@auto_v2mpositiontaking_8 = @auto_v2mpositiontaking_8,
--	@auto_v2mpositiontaking_9 = @auto_v2mpositiontaking_9,
	@auto_v2mpositiontaking_20 = @auto_v2mpositiontaking_20,
	
	@auto_v3mpositiontaking_1 = @auto_v3mpositiontaking_1,
	@auto_v3mpositiontaking_2 = @auto_v3mpositiontaking_2,
	@auto_v3mpositiontaking_3 = @auto_v3mpositiontaking_3,
	@auto_v3mpositiontaking_20 = @auto_v3mpositiontaking_20,
	
	@auto_v5mpositiontaking_1 = @auto_v5mpositiontaking_1,
	@auto_v5mpositiontaking_2 = @auto_v5mpositiontaking_2,
	@auto_v5mpositiontaking_3 = @auto_v5mpositiontaking_3,
	@auto_v5mpositiontaking_20 = @auto_v5mpositiontaking_20,
	
	@auto_v8mpositiontaking_1 = @auto_v8mpositiontaking_1,
	@auto_v8mpositiontaking_3 = @auto_v8mpositiontaking_3,
	@auto_v8mpositiontaking_20 = @auto_v8mpositiontaking_20,
	
	@auto_v10mpositiontaking_1 = @auto_v10mpositiontaking_1,
	@auto_v10mpositiontaking_2 = @auto_v10mpositiontaking_2,
	@auto_v10mpositiontaking_3 = @auto_v10mpositiontaking_3,
	@auto_v10mpositiontaking_20 = @auto_v10mpositiontaking_20,
	
	@auto_v11mpositiontaking_1 = @auto_v11mpositiontaking_1,
	@auto_v11mpositiontaking_20 = @auto_v11mpositiontaking_20,
	
	@auto_v99mpositiontaking_1 = @auto_v99mpositiontaking_1,
	@auto_v99mpositiontaking_2 = @auto_v99mpositiontaking_2,
	@auto_v99mpositiontaking_3 = @auto_v99mpositiontaking_3,
	@auto_v99mpositiontaking_20 = @auto_v99mpositiontaking_20,
	
	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 = @auto_v99mpositiontaking_9,

	-- number game
	@auto_v161mpositiontaking_81 = @auto_v161mpositiontaking_81,
	@auto_v161mpositiontaking_83 = @auto_v161mpositiontaking_83,
	--@auto_v161mpositiontaking_85 = @auto_v161mpositiontaking_85,
	@auto_v161mpositiontaking_86 = @auto_v161mpositiontaking_86,
	@auto_v161mpositiontaking_88 = @auto_v161mpositiontaking_88,
	
	@auto_v161mlivepositiontaking_85 = @auto_v161mlivepositiontaking_85,
	@auto_v161mlivepositiontaking_86 = @auto_v161mlivepositiontaking_86,
	@auto_v161mlivepositiontaking_87 = @auto_v161mlivepositiontaking_87,
	@auto_v161mlivepositiontaking_89 = @auto_v161mlivepositiontaking_89,
	@auto_v161mlivepositiontaking_90 = @auto_v161mlivepositiontaking_90,
	
	@isvalid=@isvalid OUTPUT,
	@errmsg=@ErrMsg OUTPUT,
	@errcode=@errcode OUTPUT,
	@language=@language
if @IsValid = 0
BEGIN
	return
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select @username = replace(@username, ' ', '')

select @username = rtrim(ltrim(@username))

if exists(select 1 from customer with (NOLOCK) where username = @username)
	or exists (select 1 from customer with (NOLOCK) where username2 = @username)
	or exists(select 1 from custsub with (NOLOCK) where username = @username)
BEGIN
	Select @ErrMsg = case @Language 
							when 'E' then 'This username is not available.'
							when 'CS' then N'此账号无效.'
							when 'CT' then N'此帳號無效.'
							when 'TH' then N'ชื่อที่ใช้ในการเข้าระบบนี้ ไม่สามารถใช้งานได้.'
							when 'J' then N'This username is not available.'
							when 'ES' then N'This username is not available.'
							when 'KO' then N'이 사용자 이름을 사용할 수 없습니다'
							else N'This username is not available.'
						end,
		@ErrCode = 101		
	return
END
select @pwdexpiry = dateadd(dd, 30, getdate())

--m3
select @max_mapositiontaking_1 =mpositiontaking, @max_malivepositiontaking_1 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @max_mapositiontaking_3 =mpositiontaking, @max_malivepositiontaking_3 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @max_mapositiontaking_7 =mpositiontaking, @max_malivepositiontaking_7 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @max_mapositiontaking_8 =mpositiontaking, @max_malivepositiontaking_8 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
select @max_mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @max_mapositiontaking_4 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @max_mapositiontaking_5 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @max_mapositiontaking_6 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @max_mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @max_mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

select @max_v2mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @max_v2mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @max_v2mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @max_v2mapositiontaking_7 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @max_v2mapositiontaking_8 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
--select @max_v2mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @max_v2mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2

select @max_v3mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
select @max_v3mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
select @max_v3mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
select @max_v3mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3

select @max_v5mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
select @max_v5mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
select @max_v5mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
select @max_v5mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5

select @max_v8mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
select @max_v8mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
select @max_v8mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8

select @max_v10mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
select @max_v10mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
select @max_v10mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
select @max_v10mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10

select @max_v11mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
select @max_v11mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11

select @max_v99mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
select @max_v99mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
select @max_v99mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
select @max_v99mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99

-- mix parlay of mixed sports
select @max_v99mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99

-- number game
select @max_v161mapositiontaking_81 = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 81 and sporttype=161
select @max_v161mapositiontaking_83 = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 83 and sporttype=161
select @max_v161malivepositiontaking_85 = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 85 and sporttype=161
select @max_v161mapositiontaking_86 = mpositiontaking, @max_v161malivepositiontaking_86 = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select @max_v161malivepositiontaking_87 = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 87 and sporttype=161
select @max_v161mapositiontaking_88 = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 88 and sporttype=161
select @max_v161malivepositiontaking_89 = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 89 and sporttype=161
select @max_v161malivepositiontaking_90 = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype= 90 and sporttype=161

--VS: get n3 
select @min_v180mpositiontaking_1201 = minpositiontaking 
from custOverride3rd with(nolock) 
where custid = @mrecommend and bettype = 1201 and sporttype = 180

--check m2+a2<=m3
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-' + typenamee + '-Max: '+ cast((max_mapositiontaking) as varchar(10))
	+ case when b.sporttype in (1,161) and b.bettype in (1,3,7,8,85,86,87,89,90) then '--MaxLive: '+ cast((max_malivepositiontaking) as varchar(10)) else '' end + '<br>'
from sports with (NOLOCK) inner join
(
			select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @max_mapositiontaking_1 as max_mapositiontaking,  @max_malivepositiontaking_1 as max_malivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @max_mapositiontaking_3 as max_mapositiontaking,  @max_malivepositiontaking_3 as max_malivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @max_mapositiontaking_7 as max_mapositiontaking,  @max_malivepositiontaking_7 as max_malivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_mapositiontaking_8 as max_mapositiontaking,  @max_malivepositiontaking_8 as max_malivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_4 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_5 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_6 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_9 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_10 as max_mapositiontaking,  0 as max_malivepositiontaking

	union all 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
--	union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_7 as max_mapositiontaking,  0 as max_malivepositiontaking
--	union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_8 as max_mapositiontaking,  0 as max_malivepositiontaking
--	union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_9 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v2mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking

	union all 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v3mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	
	union all 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v5mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	
	union all 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v8mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	
	union all 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v10mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	
	union all 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v11mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v11mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking

	union all 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_1 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_3 as max_mapositiontaking,  0 as max_malivepositiontaking
	union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_20 as max_mapositiontaking,  0 as max_malivepositiontaking
	
	-- mix parlay of mixed sports
	union all 	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_v99mapositiontaking_9 as max_mapositiontaking,  0 as max_malivepositiontaking

	-- number game
	union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_mapositiontaking_8 as max_mapositiontaking,  @max_malivepositiontaking_8 as max_malivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_mapositiontaking_2 as max_mapositiontaking,  0 as max_malivepositiontaking	
	union all   select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @max_v161mapositiontaking_81 as max_mapositiontaking, 0 as max_malivepositiontaking
	union all   select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @max_v161mapositiontaking_83 as max_mapositiontaking, 0 as max_malivepositiontaking
	union all   select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as max_mapostiontaking, @max_v161malivepositiontaking_85 as max_malivepositiontaking			
	union all   select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @max_v161mapositiontaking_86 as max_mapostiontaking, @max_v161malivepositiontaking_86 as max_malivepositiontaking			
	union all   select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as max_mapositiontaking,@max_v161malivepositiontaking_87 as max_malivepositiontaking
	union all   select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @max_v161mapositiontaking_88 as max_mapositiontaking, 0 as max_malivepositiontaking
	union all   select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as max_mapostiontaking, @max_v161malivepositiontaking_89 as max_malivepositiontaking
	union all   select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as max_mapostiontaking, @max_v161malivepositiontaking_90 as max_malivepositiontaking
	
	) as b on sports.sporttype = b.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
	where (apositiontaking + mpositiontaking>max_mapositiontaking)
		or (alivepositiontaking + mlivepositiontaking>max_malivepositiontaking)

if @ErrType <>''
BEGIN
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (max for master set by super).<br>'+@ErrType
							when 'CS' then N'占成数不正确(超级总代理设定给总代理最高占成).<br>'+@ErrType
							when 'CT' then N'佔成數不正確(超級總代理設給總代理最高佔成).<br>'+@ErrType
							when 'TH' then N'การกำหนดไม่ถูกต้อง (สูงสุดไม่เกิน สำหรับรายการหลัก อ้างอิงจากรายการถ่ายทอดสด).<br>'+@ErrType
							when 'J' then N'Wrong position taking (max for master set by super).<br>'+@ErrType
							when 'ES' then N'Wrong position taking (max for master set by super).<br>'+@ErrType
							when 'KO' then N'거래 조건이 잘못 되었습니다 (슈퍼가 설정한  마스터의 최대값).<br>'+@ErrType
							else N'Wrong position taking (max for master set by super).<br>'+@ErrType
						end
	Select @ErrCode = 102
	return 
END

select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @MinBet as MinBet, @MaxBet as MaxBet, @MaxPerMatch as MaxPerMatch
	union all	select 2 as sporttype, @MinBetv2 as MinBet, @MaxBetv2 as MaxBet, @MaxPerMatchv2 as MaxPerMatch
	union all	select 3 as sporttype, @MinBetv3 as MinBet, @MaxBetv3 as MaxBet, @MaxPerMatchv3 as MaxPerMatch
	union all	select 5 as sporttype, @MinBetv5 as MinBet, @MaxBetv5 as MaxBet, @MaxPerMatchv5 as MaxPerMatch
	union all	select 8 as sporttype, @MinBetv8 as MinBet, @MaxBetv8 as MaxBet, @MaxPerMatchv8 as MaxPerMatch
	union all	select 10 as sporttype, @MinBetv10 as MinBet, @MaxBetv10 as MaxBet, @MaxPerMatchv10 as MaxPerMatch
	union all	select 11 as sporttype, @MinBetv11 as MinBet, @MaxBetv11 as MaxBet, @MaxPerMatchv11 as MaxPerMatch
	union all	select 99 as sporttype, @MinBetv99 as MinBet, @MaxBetv99 as MaxBet, @MaxPerMatchv99 as MaxPerMatch	
	union all   select 99 as sporttype, @MinBetv99mp as MinBet, @MaxBetv99mp as MaxBet, @MaxPerMatchv99mp as MaxPerMatch
	union all   select 161 as sporttype, @MinBetv161 as MinBet, @MaxBetv161 as MaxBet, @MaxPerMatchv161 as MaxPerMatch 
) as b on sports.sporttype = b.sporttype
where (MinBet<>0 and MaxBet <> 0 and  MinBet>MaxBet) 
or (MaxBet<> 0 and MaxPerMatch <> 0 and MaxBet>MaxPerMatch) 
or (MinBet <> 0 and MaxPerMatch <> 0 and MinBet>MaxPerMatch) 

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be less than max bet and max bet must be less than max per match ('+@ErrType+').'
							when 'CS' then N'对不起，最低投注不能高于最高投注，最高投注不能高于单场最高投注设定 ('+@ErrType+').'
							when 'CT' then N'對不起,最低投注不能高於最高投注,最高投注不能高於單場最高投注設定 ('+@ErrType+').'
							when 'TH' then N'ขออภัยจำนวนเงินในการเล่นขั้นต่ำต้องน้อยกว่าจำนวนเงินสูงสุดที่จะเล่นได้และจำนวนเงินสูงสุดที่เล่นได้ต้องน้อยกว่าจำนวนเงินเดิมพันต่อเกมการแข่งขัน ('+@ErrType+').'
							when 'J' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match ('+@ErrType+').'
							when 'ES' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match ('+@ErrType+').'
							when 'KO' then N'죄송합니다, 최소 배팅은 최대 배팅보다 작아야 하고  최대 배팅은 경기당 최대 배팅보다 작아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be less than max bet and max bet must be less than max per match ('+@ErrType+').'
					end
										
	Select @ErrCode = 103
	return
END
/* ------------- viet --comment this
if @MaxPerBallv161 < @MaxBetv161 or @MaxPerBallv161 > @MaxPerMatchv161
begin
	SELECT
		@ErrMsg =	case @Language 
						when 'E' then 'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
						when 'CS' then N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注.'
						when 'CT' then N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注.'
						when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน.'
						when 'J' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
						when 'ES' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
						when 'KO' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
						else N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
				end
	Select @ErrCode = 210
	return
end
*/
--Auto Master PT
select @auto_mpositiontaking_1=  case when @auto_mpositiontaking_1>@max_mapositiontaking_1 then @max_mapositiontaking_1 else @auto_mpositiontaking_1 end
select @auto_mpositiontaking_2=  case when @auto_mpositiontaking_2>@max_mapositiontaking_2 then @max_mapositiontaking_2 else @auto_mpositiontaking_2 end
select @auto_mpositiontaking_3=  case when @auto_mpositiontaking_3>@max_mapositiontaking_3 then @max_mapositiontaking_3 else @auto_mpositiontaking_3 end
select @auto_mpositiontaking_4=  case when @auto_mpositiontaking_4>@max_mapositiontaking_4 then @max_mapositiontaking_4 else @auto_mpositiontaking_4 end
select @auto_mpositiontaking_5=  case when @auto_mpositiontaking_5>@max_mapositiontaking_5 then @max_mapositiontaking_5 else @auto_mpositiontaking_5 end
select @auto_mpositiontaking_6=  case when @auto_mpositiontaking_6>@max_mapositiontaking_6 then @max_mapositiontaking_6 else @auto_mpositiontaking_6 end
select @auto_mpositiontaking_7=  case when @auto_mpositiontaking_7>@max_mapositiontaking_7 then @max_mapositiontaking_7 else @auto_mpositiontaking_7 end
select @auto_mpositiontaking_8= case when @auto_mpositiontaking_8>@max_mapositiontaking_8 then @max_mapositiontaking_8 else @auto_mpositiontaking_8 end
select @auto_mpositiontaking_9=  case when @auto_mpositiontaking_9>@max_mapositiontaking_9 then @max_mapositiontaking_9 else @auto_mpositiontaking_9 end
select @auto_mpositiontaking_10=  case when @auto_mpositiontaking_10>@max_mapositiontaking_10 then @max_mapositiontaking_10 else @auto_mpositiontaking_10 end

select @auto_mlivepositiontaking_1=  case when @auto_mlivepositiontaking_1>@max_malivepositiontaking_1 then @max_malivepositiontaking_1 else @auto_mlivepositiontaking_1 end
select @auto_mlivepositiontaking_3=  case when @auto_mlivepositiontaking_3>@max_malivepositiontaking_3 then @max_malivepositiontaking_3 else @auto_mlivepositiontaking_3 end
select @auto_mlivepositiontaking_7=  case when @auto_mlivepositiontaking_7>@max_malivepositiontaking_7 then @max_malivepositiontaking_7 else @auto_mlivepositiontaking_7 end
select @auto_mlivepositiontaking_8=  case when @auto_mlivepositiontaking_8>@max_malivepositiontaking_8 then @max_malivepositiontaking_8 else @auto_mlivepositiontaking_8 end

select @auto_v2mpositiontaking_1=  case when @auto_v2mpositiontaking_1>@max_v2mapositiontaking_1 then @max_v2mapositiontaking_1 else @auto_v2mpositiontaking_1 end
select @auto_v2mpositiontaking_2=  case when @auto_v2mpositiontaking_2>@max_v2mapositiontaking_2 then @max_v2mapositiontaking_2 else @auto_v2mpositiontaking_2 end
select @auto_v2mpositiontaking_3=  case when @auto_v2mpositiontaking_3>@max_v2mapositiontaking_3 then @max_v2mapositiontaking_3 else @auto_v2mpositiontaking_3 end
select @auto_v2mpositiontaking_7=  case when @auto_v2mpositiontaking_7>@max_v2mapositiontaking_7 then @max_v2mapositiontaking_7 else @auto_v2mpositiontaking_7 end
select @auto_v2mpositiontaking_8=  case when @auto_v2mpositiontaking_8>@max_v2mapositiontaking_8 then @max_v2mapositiontaking_8 else @auto_v2mpositiontaking_8 end
--select @auto_v2mpositiontaking_9=  case when @auto_v2mpositiontaking_9>@max_v2mapositiontaking_9 then @max_v2mapositiontaking_9 else @auto_v2mpositiontaking_9 end
select @auto_v2mpositiontaking_20=  case when @auto_v2mpositiontaking_20>@max_v2mapositiontaking_20 then @max_v2mapositiontaking_20 else @auto_v2mpositiontaking_20 end

select @auto_v3mpositiontaking_1=  case when @auto_v3mpositiontaking_1>@max_v3mapositiontaking_1 then @max_v3mapositiontaking_1 else @auto_v3mpositiontaking_1 end
select @auto_v3mpositiontaking_2=  case when @auto_v3mpositiontaking_2>@max_v3mapositiontaking_2 then @max_v3mapositiontaking_2 else @auto_v3mpositiontaking_2 end
select @auto_v3mpositiontaking_3=  case when @auto_v3mpositiontaking_3>@max_v3mapositiontaking_3 then @max_v3mapositiontaking_3 else @auto_v3mpositiontaking_3 end
select @auto_v3mpositiontaking_20=  case when @auto_v3mpositiontaking_20>@max_v3mapositiontaking_20 then @max_v3mapositiontaking_20 else @auto_v3mpositiontaking_20 end

select @auto_v5mpositiontaking_1=  case when @auto_v5mpositiontaking_1>@max_v5mapositiontaking_1 then @max_v5mapositiontaking_1 else @auto_v5mpositiontaking_1 end
select @auto_v5mpositiontaking_2=  case when @auto_v5mpositiontaking_2>@max_v5mapositiontaking_2 then @max_v5mapositiontaking_2 else @auto_v5mpositiontaking_2 end
select @auto_v5mpositiontaking_3=  case when @auto_v5mpositiontaking_3>@max_v5mapositiontaking_3 then @max_v5mapositiontaking_3 else @auto_v5mpositiontaking_3 end
select @auto_v5mpositiontaking_20=  case when @auto_v5mpositiontaking_20>@max_v5mapositiontaking_20 then @max_v5mapositiontaking_20 else @auto_v5mpositiontaking_20 end

select @auto_v8mpositiontaking_1=  case when @auto_v8mpositiontaking_1>@max_v8mapositiontaking_1 then @max_v8mapositiontaking_1 else @auto_v8mpositiontaking_1 end
select @auto_v8mpositiontaking_3=  case when @auto_v8mpositiontaking_3>@max_v8mapositiontaking_3 then @max_v8mapositiontaking_3 else @auto_v8mpositiontaking_3 end
select @auto_v8mpositiontaking_20=  case when @auto_v8mpositiontaking_20>@max_v8mapositiontaking_20 then @max_v8mapositiontaking_20 else @auto_v8mpositiontaking_20 end

select @auto_v10mpositiontaking_1=  case when @auto_v10mpositiontaking_1>@max_v10mapositiontaking_1 then @max_v10mapositiontaking_1 else @auto_v10mpositiontaking_1 end
select @auto_v10mpositiontaking_2=  case when @auto_v10mpositiontaking_2>@max_v10mapositiontaking_2 then @max_v10mapositiontaking_2 else @auto_v10mpositiontaking_2 end
select @auto_v10mpositiontaking_3=  case when @auto_v10mpositiontaking_3>@max_v10mapositiontaking_3 then @max_v10mapositiontaking_3 else @auto_v10mpositiontaking_3 end
select @auto_v10mpositiontaking_20=  case when @auto_v10mpositiontaking_20>@max_v10mapositiontaking_20 then @max_v10mapositiontaking_20 else @auto_v10mpositiontaking_20 end

select @auto_v11mpositiontaking_1=  case when @auto_v11mpositiontaking_1>@max_v11mapositiontaking_1 then @max_v11mapositiontaking_1 else @auto_v11mpositiontaking_1 end
select @auto_v11mpositiontaking_20=  case when @auto_v11mpositiontaking_20>@max_v11mapositiontaking_20 then @max_v11mapositiontaking_20 else @auto_v11mpositiontaking_20 end

select @auto_v99mpositiontaking_1=  case when @auto_v99mpositiontaking_1>@max_v99mapositiontaking_1 then @max_v99mapositiontaking_1 else @auto_v99mpositiontaking_1 end
select @auto_v99mpositiontaking_2=  case when @auto_v99mpositiontaking_2>@max_v99mapositiontaking_2 then @max_v99mapositiontaking_2 else @auto_v99mpositiontaking_2 end
select @auto_v99mpositiontaking_3=  case when @auto_v99mpositiontaking_3>@max_v99mapositiontaking_3 then @max_v99mapositiontaking_3 else @auto_v99mpositiontaking_3 end
select @auto_v99mpositiontaking_20=  case when @auto_v99mpositiontaking_20>@max_v99mapositiontaking_20 then @max_v99mapositiontaking_20 else @auto_v99mpositiontaking_20 end

-- mix parlay of mixed sports
select @auto_v99mpositiontaking_9 =  case when @auto_v99mpositiontaking_9>@max_v99mapositiontaking_9 then @max_v99mapositiontaking_9 else @auto_v99mpositiontaking_9 end

-- number game
select @auto_v161mpositiontaking_81 = case when @auto_v161mpositiontaking_81 > @max_v161mapositiontaking_81 then @max_v161mapositiontaking_81 else @auto_v161mpositiontaking_81 end
select @auto_v161mpositiontaking_83 = case when @auto_v161mpositiontaking_83 > @max_v161mapositiontaking_83 then @max_v161mapositiontaking_83 else @auto_v161mpositiontaking_83 end
--select @auto_v161mpositiontaking_85 = case when @auto_v161mpositiontaking_85 > @max_v161mapositiontaking_85 then @max_v161mapositiontaking_85 else @auto_v161mpositiontaking_85 end
select @auto_v161mpositiontaking_86 = case when @auto_v161mpositiontaking_86 > @max_v161mapositiontaking_86 then @max_v161mapositiontaking_86 else @auto_v161mpositiontaking_86 end
select @auto_v161mpositiontaking_88 = case when @auto_v161mpositiontaking_88 > @max_v161mapositiontaking_88 then @max_v161mapositiontaking_88 else @auto_v161mpositiontaking_88 end

select @auto_v161mlivepositiontaking_85=  case when @auto_v161mlivepositiontaking_85 > @max_v161malivepositiontaking_85 then @max_v161malivepositiontaking_85 else @auto_v161mlivepositiontaking_85 end
select @auto_v161mlivepositiontaking_86=  case when @auto_v161mlivepositiontaking_86 > @max_v161malivepositiontaking_86 then @max_v161malivepositiontaking_86 else @auto_v161mlivepositiontaking_86 end
select @auto_v161mlivepositiontaking_87 = case when @auto_v161mlivepositiontaking_87 > @max_v161malivepositiontaking_87 then @max_v161malivepositiontaking_87 else @auto_v161mlivepositiontaking_87 end
select @auto_v161mlivepositiontaking_89 = case when @auto_v161mlivepositiontaking_89 > @max_v161malivepositiontaking_89 then @max_v161malivepositiontaking_89 else @auto_v161mlivepositiontaking_89 end
select @auto_v161mlivepositiontaking_90 = case when @auto_v161mlivepositiontaking_90 > @max_v161malivepositiontaking_90 then @max_v161malivepositiontaking_90 else @auto_v161mlivepositiontaking_90 end
Select 
	@MinMinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @mrecommend

Select 
	@MinMinBetv2 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv2 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @mrecommend

Select 
	@MinMinBetv3 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv3 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @mrecommend

Select 
	@MinMinBetv5 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv5 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @mrecommend

Select 
	@MinMinBetv8 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv8 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @mrecommend

Select 
	@MinMinBetv10 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv10 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @mrecommend

Select 
	@MinMinBetv11 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv11 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @mrecommend

--v151
--Select 
--	@MinMinBetv151 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
--	@MaxMaxBetv151 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
--from 
--	custsetting as cs WITH (NOLOCK)
--	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 31 and cs.sporttype=151
--where ci.custid = @mrecommend

Select 
	@MinMinBetv99 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv99 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @mrecommend

--- mix parlay of mixed sports
select	@MinMinBetv99mp = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0),
		@MaxMaxBetv99mp = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from custsetting as cs with(nolock) inner join
	custinfo as ci with(nolock) on (cs.custid = ci.custid or cs.custid = ci.srecommend) and cs.bettype = 9 and cs.sporttype = 99
where ci.custid = @mrecommend

-- number game
select	@MinMinBetv161 = isnull(max(case when minbet = 0 then null else minbet end),0),
		@MaxMaxBetv161 = isnull(Min(case when maxbet = 0 then NULL else maxbet end),0)
from custsetting3rd as cs with(nolock) inner join 
	 custinfo as ci with(nolock) on (cs.custid = ci.custid or cs.custid = ci.srecommend) and cs.bettype = 81 and cs.sporttype = 161
where ci.custid = @mrecommend

-- VS (get from upline)
select	@MinMinBetv180 = isnull(max(case when minbet = 0 then null else minbet end),0),
		@MaxMaxBetv180 = isnull(Min(case when maxbet = 0 then NULL else maxbet end),0)
from custsetting3rd as cs with(nolock) inner join 
	 custinfo as ci with(nolock) on (cs.custid = ci.custid or cs.custid = ci.srecommend) and cs.bettype = 1201 and cs.sporttype = 180
where ci.custid = @mrecommend

select @minbetv180 = Isnull(MinBet, 0), @maxbetv180 = isnull(MaxBet, 0) 
from custsetting3rd with (NOLOCK) 
where custid = @mrecommend and bettype= 1201 and sporttype=180

IF @MinMinBetv180>0 and @minbetv180>0 and @minbetv180<@MinMinBetv180
	SET @minbetv180 = @MinMinBetv180
	
IF @MaxMaxBetv180>0 and @maxbetv180>0 and @maxbetv180>@MaxMaxBetv180
	SET @maxbetv180 = @MaxMaxBetv180


Select 
	@MaxMaxperMatch = isnull(Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),0),	
	@MaxMaxPerMatchv2 = isnull(Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),0),
	@MaxMaxPerMatchv3 = isnull(Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),0),
	@MaxMaxPerMatchv5 = isnull(Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),0),
	@MaxMaxPerMatchv8 = isnull(Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),0),
	@MaxMaxPerMatchv10 = isnull(Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),0),
	@MaxMaxPerMatchv11 = isnull(Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),0),
	@MaxMaxPerMatchv99 = isnull(Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),0),
	@MaxMaxPerMatchv99mp = isnull(min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),0),
	@MaxMaxPerMatchv161 = isnull(min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0),
	@MaxMaxPerBallv161 = isnull(min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),0),
	@MaxMaxPerMatchv180 = isnull(Min(case when cs.MaxPerMatch180 = 0 then NULL else cs.MaxPerMatch180 end),0)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.SRecommend)
where ci.custid = @mrecommend

-- VS
IF @MaxMaxPerMatchv180>0 and @MaxPerMatchv180>0 and @MaxPerMatchv180>@MaxMaxPerMatchv180
	SET @MaxPerMatchv180 = @MaxMaxPerMatchv180

--Check valid commission for financial and HR
select 
	@groupa = case when @groupa>groupa then groupa else @groupa end,
	@groupb = case when @groupb>groupb then groupb else @groupb end,
	@groupc = case when @groupc>groupc then groupc else @groupc end,
	@groupd = case when @groupd>groupd then groupd else @groupd end
from custsetting with (NOLOCK) where custid = @mrecommend and  bettype=1 and sporttype=1

select 
	@discountcs = case when @discountcs>adiscount then adiscount else @discountcs end
from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1

--1x2 Commission
select 
	@discount1x2 = case when @discount1x2>adiscount then adiscount else @discount1x2 end
from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1

--HR commission

-- Number game commission
select @discountnumber = case when @discountnumber > adiscount then adiscount else @discountnumber end
from custsetting3rd with(nolock) where custid = @mrecommend and bettype = 81 and sporttype = 161

--End Check valid commission for financial and HR


--Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline
--if ((@minbetv151 < @MinMinBetv151 or @maxbetv151 > @MaxMaxBetv151 or @MaxPerMatchv151 > @MaxMaxPerMatchv151) 
--	and not (@minbetv151 = 0 and @maxbetv151 = 0 and @MaxPerMatchv151 = 0))
--	Select @minbetv151 = @MinMinBetv151,
--			@maxbetv151 = @MaxMaxBetv151,
--			@MaxPerMatchv151 = @MaxMaxPerMatchv151
--End Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline

--Vinh@20080213: get transfer option from master
select @site = site from customer with (nolock) where CustID = @mrecommend

select	@IsInternal = case when IsInternal = 1 then 1 else @IsInternal end,
		@TransferOption_dec = TransferOption 
from custmaster with (nolock) 
where CustID = @mrecommend

Select @Credit_AllOtherAgent = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where mrecommend = @mrecommend and RoleID = 2

if @Credit_AllOtherAgent + @Credit >@Credit_MAg
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, credit update is not successful, You have exceeded your master credit.'
						when 'CS' then N'对不起，更新信用额度不成功，已超出总代理信用额度.'
						when 'CT' then N'對不起,更新信用額度不成功, 已超出總代理信用額度.'
						when 'TH' then N'ขออภัย การปรับยอดเงินในบัญชี ไม่เป็นผล เนื่องจากคุณมียอดเกินจำนวนเงินสูงสุดในบัญชีของตัวแทนหลักคะ.'
						when 'J' then N'Sorry, credit update is not successful, You have exceeded your master credit.'
						when 'ES' then N'Sorry, credit update is not successful, You have exceeded your master credit.'
						when 'KO' then N'죄송합니다. 크레딧 업데이트에 실패했습니다, 해당 마스터 크레딧을 초과 했습니다.'
						else N'Sorry, credit update is not successful, You have exceeded your master credit.'
					end,
		@ErrCode = 104
	return
END
-- maxcredit 
if (isnull(@maxcredit ,0) > @credit )
BEGIN 
	Select @ErrMsg = case @Language
		when 'E' then 'Sorry, credit update is not successful, You have exceeded your agent credit.'  
        when 'CS' then N'对不起， 更新信用额度不成功， 已超出代理信用额度.'
        when 'CT' then N'對不起, 更新信用額度不成功, 已超出代理信用額度.'
        when 'TH' then N'ขออภัย การเพิ่มจำนวนยอดเงินในบัญชี ไม่เป็นผล เนื่องจากคุณได้มียอดเกินจำนวนเงินในบัญชีของตัวแทนคะ.'  
        when 'J' then N'Sorry, credit update is not successful, You have exceeded your agent credit.'  
        when 'ES' then N'Sorry, credit update is not successful, You have exceeded your agent credit.'  
        when 'KO' then N'Sorry, credit update is not successful, You have exceeded your agent credit.'  
        else N'Sorry, credit update is not successful, You have exceeded your agent credit.'  
     end,  
  @ErrCode = 116  
 return  
END 

/*
Select @MaxPerMatch_AllOtherAgent = isnull(sum(MaxPerMatch), 0) from custinfo as ci with (NOLOCK) where mrecommend = @mrecommend and RoleID = 2

if @MaxPerMatch_AllOtherAgent + @MaxPerMatch >@MaxPerMatch_MAg
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, Max Per Match update is not successful, You have exceeded your master Max Per Match.'
						when 'CS' then N'Sorry, Max Per Match update is not successful, You have exceeded your master Max Per Match.'
						when 'J' then N'Sorry, Max Per Match update is not successful, You have exceeded your master Max Per Match.'
						else N'Sorry, Max Per Match update is not successful, You have exceeded your master Max Per Match.'
					end,
		@ErrCode = 104
	RaisError(@ErrMsg, 16, 1)
	return
END


Select @MaxPerMatchv2_AllOtherAgent = isnull(sum(MaxPerMatchb), 0) from custinfo as ci with (NOLOCK) where mrecommend = @mrecommend and RoleID = 2

if @MaxPerMatchv2_AllOtherAgent + @MaxPerMatchv2 >@MaxPerMatchv2_MAg
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your master Max Per Match (basketball).'
						when 'CS' then N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your master Max Per Match (basketball).'
						when 'J' then N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your master Max Per Match (basketball).'
						else N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your master Max Per Match (basketball).'
					end,
		@ErrCode = 104
	RaisError(@ErrMsg, 16, 1)
	return
END
*/

select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @MinBet as MinBet, @MinMinBet as MinMinBet
	union all	select 2 as sporttype, @MinBetv2 as MinBet, @MinMinBetv2 as MinMinBet
	union all	select 3 as sporttype, @MinBetv3 as MinBet, @MinMinBetv3 as MinMinBet
	union all	select 5 as sporttype, @MinBetv5 as MinBet, @MinMinBetv5 as MinMinBet
	union all	select 8 as sporttype, @MinBetv8 as MinBet, @MinMinBetv8 as MinMinBet
	union all	select 10 as sporttype, @MinBetv10 as MinBet, @MinMinBetv10 as MinMinBet
	union all	select 11 as sporttype, @MinBetv11 as MinBet, @MinMinBetv11 as MinMinBet
	union all	select 99 as sporttype, @MinBetv99 as MinBet, @MinMinBetv99 as MinMinBet
	union all   select 99 as sporttype, @MinBetv99 as MinBet, @MinMinBetv99 as MinMinBet
	union all   select 161 as sporttype, @MinBetv161 as MinBet, @MinMinBetv161 as MinMinBet	 
) as b on sports.sporttype = b.sporttype
where MinMinBet>0 and MinBet>0 and MinBet<MinMinBet

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be equal to or greater than master agent min bet ('+@ErrType+').'
							when 'CS' then N'对不起，最低投注需相等于或少于总代理最低投注 ('+@ErrType+').'
							when 'CT' then N'對不起,最低投注需相等於或少於總代理最低投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินในการเล่นขั้นต่ำ ตัองเท่ากับ หรือ มากกว่า ขั้นต่ำที่กำหนดไว้ของตัวแทนหลัก ('+@ErrType+').'
							when 'J' then N'Sorry, min bet must be equal to or greater than master agent min bet ('+@ErrType+').'
							when 'ES' then N'Sorry, min bet must be equal to or greater than master agent min bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최소 배팅은 마스터 에이전트 최소 베팅보다 많아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be equal to or greater than master agent min bet ('+@ErrType+').'
					end										
	Select @ErrCode = 105
	return
END


select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @MaxBet as MaxBet, @MaxMaxBet as MaxMaxBet
	union all	select 2 as sporttype, @MaxBetv2 as MaxBet, @MaxMaxBetv2 as MaxMaxBet
	union all	select 3 as sporttype, @MaxBetv3 as MaxBet, @MaxMaxBetv3 as MaxMaxBet
	union all	select 5 as sporttype, @MaxBetv5 as MaxBet, @MaxMaxBetv5 as MaxMaxBet
	union all	select 8 as sporttype, @MaxBetv8 as MaxBet, @MaxMaxBetv8 as MaxMaxBet
	union all	select 10 as sporttype, @MaxBetv10 as MaxBet, @MaxMaxBetv10 as MaxMaxBet
	union all	select 11 as sporttype, @MaxBetv11 as MaxBet, @MaxMaxBetv11 as MaxMaxBet
	union all	select 99 as sporttype, @MaxBetv99 as MaxBet, @MaxMaxBetv99 as MaxMaxBet
	union all   select 99 as sporttype, @MaxBetv99mp as MaxBet, @MaxMaxBetv99mp as MaxMaxBet
	union all   select 161 as sporttype, @MaxBetv161 as MaxBet, @MaxMaxBetv161 as MaxMaxBet
) as b on sports.sporttype = b.sporttype
where MaxMaxBet>0 and MaxBet>0 and MaxBet>MaxMaxBet

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, max bet must be equal to or less than master agent max bet ('+@ErrType+').'
							when 'CS' then N'对不起，最高投注需相等于或少于超级总代理最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,最高投注需相等於或少於總代理最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย  จำนวนเงินสูงสุดที่สามารถเล่นได้ ต้องเท่ากับ หรือ น้อยกว่า จำนวนเงินสูงสุดที่กำหนดไว้ของตัวแทนหลัก ('+@ErrType+').'
							when 'J' then N'Sorry, max bet must be equal to or less than master agent max bet ('+@ErrType+').'
							when 'ES' then N'Sorry, max bet must be equal to or less than master agent max bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최대 배팅은 마스터 에이전트의 최대 배팅 이하이여야 합니다 ('+@ErrType+').'
							else N'Sorry, max bet must be equal to or less than master agent max bet ('+@ErrType+').'
					end
										
	Select @ErrCode = 107
	return
END


select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @MaxPerMatch as MaxPerMatch, @MaxMaxPerMatch as MaxMaxPerMatch
	union all	select 2 as sporttype, @MaxPerMatchv2 as MaxPerMatch, @MaxMaxPerMatchv2 as MaxMaxPerMatch
	union all	select 3 as sporttype, @MaxPerMatchv3 as MaxPerMatch, @MaxMaxPerMatchv3 as MaxMaxPerMatch
	union all	select 5 as sporttype, @MaxPerMatchv5 as MaxPerMatch, @MaxMaxPerMatchv5 as MaxMaxPerMatch
	union all	select 8 as sporttype, @MaxPerMatchv8 as MaxPerMatch, @MaxMaxPerMatchv8 as MaxMaxPerMatch
	union all	select 10 as sporttype, @MaxPerMatchv10 as MaxPerMatch, @MaxMaxPerMatchv10 as MaxMaxPerMatch
	union all	select 11 as sporttype, @MaxPerMatchv11 as MaxPerMatch, @MaxMaxPerMatchv11 as MaxMaxPerMatch
	union all	select 99 as sporttype, @MaxPerMatchv99 as MaxPerMatch, @MaxMaxPerMatchv99 as MaxMaxPerMatch	 
	union all	select 99 as sporttype, @MaxPerMatchv99mp as MaxPerMatch, @MaxMaxPerMatchv99mp as MaxMaxPerMatch
	union all	select 161 as sporttype, @MaxPerMatchv161 as MaxPerMatch, @MaxMaxPerMatchv161 as MaxMaxPerMatch
) as b on sports.sporttype = b.sporttype
where MaxMaxPerMatch>0 and MaxPerMatch>0 and MaxPerMatch>MaxMaxPerMatch

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Match must be equal to or less than master agent Max Per Match ('+@ErrType+').'
							when 'CS' then N'对不起，单场最高投注需相等于或少于总代理单场最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,單場最高投注需相等於或少於總代理單場最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัยจำนวนเงินในการเล่นสูงสุดต่อรายการต้องเท่ากับ หรือน้อยกว่า จำนวนเงินสูงสุดต่อรายการที่กำหนดไว้ของตัวแทนหลักต่อเกมการแข่งขัน ('+@ErrType+').'
							when 'J' then N'Sorry, Max Per Match must be equal to or less than master agent Max Per Match ('+@ErrType+').'
							when 'ES' then N'Sorry, Max Per Match must be equal to or less than master agent Max Per Match ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 경기당 최대는 마스터 에이전트의 경기당 최대 보다 적어야야 합니다 ('+@ErrType+').'
							else N'Sorry, Max Per Match must be equal to or less than master agent Max Per Match ('+@ErrType+').'
					end
										
	Select @ErrCode = 107
	return
END

if @MaxPerBallv161 > @MaxMaxPerBallv161 and @MaxMaxPerBallv161 > 0
begin
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
							when 'CS' then N'单粒球最高投注必須等於或低於总代理单粒球最高的投注.'
							when 'CT' then N'單粒球最高投注必須等於或低於總代理單粒球最高的投注.'
							when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องเท่ากับหรือน้อยกว่าการตั้งค่าสูงสุดต่อบอลของมาสเตอร์เอเย่น.'
							when 'J' then N'Sorry, Max Per Ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
							when 'ES' then N'Sorry, Max Per Ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
							when 'KO' then N'Sorry, Max Per Ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
							else N'Sorry, Max Per Ball must be equal to or less than Master Agent Max Per Ball (Number Game).'
					end										
	Select @ErrCode = 201
	return
end
--Auto Master PT

select	@isauto_mpositiontaking_1 	= case when	@auto_mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_2 	= case when	@auto_mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_3 	= case when	@auto_mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_4 	= case when	@auto_mpositiontaking_4 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_5 	= case when	@auto_mpositiontaking_5 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_6 	= case when	@auto_mpositiontaking_6 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_7 	= case when	@auto_mpositiontaking_7 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_8 	= case when	@auto_mpositiontaking_8 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_9 	= case when	@auto_mpositiontaking_9 	>0 then 1 else 0 end,
	@isauto_mpositiontaking_10 	= case when	@auto_mpositiontaking_10 	>0 then 1 else 0 end,
	@isauto_mlivepositiontaking_1 	= case when	@auto_mlivepositiontaking_1 	>0 then 1 else 0 end,
	@isauto_mlivepositiontaking_3 	= case when	@auto_mlivepositiontaking_3 	>0 then 1 else 0 end,
	@isauto_mlivepositiontaking_7 	= case when	@auto_mlivepositiontaking_7 	>0 then 1 else 0 end,
	@isauto_mlivepositiontaking_8 	= case when	@auto_mlivepositiontaking_8 	>0 then 1 else 0 end,
	
	@isauto_v2mpositiontaking_1 	= case when	@auto_v2mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v2mpositiontaking_2 	= case when	@auto_v2mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v2mpositiontaking_3 	= case when	@auto_v2mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v2mpositiontaking_7 	= case when	@auto_v2mpositiontaking_7 	>0 then 1 else 0 end,
	@isauto_v2mpositiontaking_8 	= case when	@auto_v2mpositiontaking_8 	>0 then 1 else 0 end,
--	@isauto_v2mpositiontaking_9 	= case when	@auto_v2mpositiontaking_9	>0 then 1 else 0 end,
	@isauto_v2mpositiontaking_20 	= case when	@auto_v2mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v3mpositiontaking_1 	= case when	@auto_v3mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v3mpositiontaking_2 	= case when	@auto_v3mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v3mpositiontaking_3 	= case when	@auto_v3mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v3mpositiontaking_20 	= case when	@auto_v3mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v5mpositiontaking_1 	= case when	@auto_v5mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v5mpositiontaking_2 	= case when	@auto_v5mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v5mpositiontaking_3 	= case when	@auto_v5mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v5mpositiontaking_20 	= case when	@auto_v5mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v8mpositiontaking_1 	= case when	@auto_v8mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v8mpositiontaking_3 	= case when	@auto_v8mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v8mpositiontaking_20 	= case when	@auto_v8mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v10mpositiontaking_1 	= case when	@auto_v10mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v10mpositiontaking_2 	= case when	@auto_v10mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v10mpositiontaking_3 	= case when	@auto_v10mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v10mpositiontaking_20 	= case when	@auto_v10mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v11mpositiontaking_1 	= case when	@auto_v11mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v11mpositiontaking_20 	= case when	@auto_v11mpositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v99mpositiontaking_1 	= case when	@auto_v99mpositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v99mpositiontaking_2 	= case when	@auto_v99mpositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v99mpositiontaking_3 	= case when	@auto_v99mpositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v99mpositiontaking_20 	= case when	@auto_v99mpositiontaking_20	>0 then 1 else 0 end,

	@isauto_v99mpositiontaking_9 	= case when	@auto_v99mpositiontaking_9 	> 0 then 1 else 0 end,

	@isauto_v161mpositiontaking_81  = case when @auto_v161mpositiontaking_81 > 0 then 1 else 0 end,
	@isauto_v161mpositiontaking_83  = case when @auto_v161mpositiontaking_83 > 0 then 1 else 0 end,
	--@isauto_v161mpositiontaking_85  = case when @auto_v161mpositiontaking_85 > 0 then 1 else 0 end,
	@isauto_v161mpositiontaking_86  = case when @auto_v161mpositiontaking_86 > 0 then 1 else 0 end,
	@isauto_v161mpositiontaking_88  = case when @auto_v161mpositiontaking_88 > 0 then 1 else 0 end,
	
	@isauto_v161mlivepositiontaking_85  = case when @auto_v161mlivepositiontaking_85 > 0 then 1 else 0 end,
	@isauto_v161mlivepositiontaking_86  = case when @auto_v161mlivepositiontaking_86 > 0 then 1 else 0 end,
	@isauto_v161mlivepositiontaking_87  = case when @auto_v161mlivepositiontaking_87 > 0 then 1 else 0 end,
	@isauto_v161mlivepositiontaking_89  = case when @auto_v161mlivepositiontaking_89 > 0 then 1 else 0 end,
	@isauto_v161mlivepositiontaking_90  = case when @auto_v161mlivepositiontaking_90 > 0 then 1 else 0 end

--check suspended
if @Msuspended =1 and @suspendedFlag is null -- @suspendedFlag is regconized for Account Site or not 
BEGIN
	set @suspended =1 
END 



--Insert general data 
EXEC dbo.Acc_CustomerInsUserInfo
	@custid = @custid OUTPUT,
	@firstname = @firstname,
	@lastname = @lastname,
	@creator = @creator,
	@username = @username,
	@userpwd = @userpwd,
	@pwdexpiry = @pwdexpiry,
	@currency = @currency,
	@site = @site,
	@srecommend = @srecommend,
	@mrecommend = @mrecommend,
	@recommend = 0,
	@roleid = 2,
	@phone = @phone,
	@mobilephone = @mobilephone,
	@email = @email,
	@fax = @fax,
	@address = @address,
	@city = @city,
	@state = @state,
	@country = @country,
	@postal = @postal,
	@TransferOption = @TransferOption,
	@suspended = @suspended,
	@closed=@UplineClosed,
	@Disable151_31 = @Disable151_31,
	@Disable151_41 = @Disable151_41,
	@Disable151_51 = @Disable151_51,
	@Disable152_41 = @Disable152_41,
	@Disable152_51 = @Disable152_51,
	@Disable153_51 = @Disable153_51,
	@DisableOutright = @DisableOutright,
	@Disable162_1101 = @Disable162_1101,
	@matchlimit = @matchlimit,
	@virtualmultiplier = @virtualmultiplier,
	@DisableFinancial = @DisableFinancial,
	@DisableCasino = @DisableCasino,
	@IsInternal = @IsInternal,
	@DisableNumber = @DisableNumber,
	@DisableBingo = @DisableBingo,
	@MaxPerMatch = @MaxPerMatch,
	@MaxPerMatchv2 = @MaxPerMatchv2,
	@MaxPerMatchv3 = @MaxPerMatchv3,
	@MaxPerMatchv5 = @MaxPerMatchv5,
	@MaxPerMatchv8 = @MaxPerMatchv8,
	@MaxPerMatchv10 = @MaxPerMatchv10,
	@MaxPerMatchv11 = @MaxPerMatchv11,
	@MaxPerMatchv99 = @MaxPerMatchv99,

	@MaxPerMatchv99MP = @MaxPerMatchv99mp,
	@MaxPerMatchv161 = @MaxPerMatchv161,	
	@MaxPerBallv161 = @MaxPerBallv161,
	@MaxPerMatchv180 = @MaxPerMatchv180,
		
	@credit = @credit,
	@maxcredit = @maxcredit,
	@DisableP2P = @DisableP2P,
	@DisableFUNP2P = @DisableFUNP2P,
	@Disable180_1201 = @Disable180_1201,
	@HideVirtualSports = @HideVirtualSports,
	@DoubleCommLosing = @DoubleCommLosing,
	@isAutoResetLiveCasino = @isAutoResetLiveCasino, 
	@MaxWinLiveCasino = @MaxWinLiveCasino,
	
	@IP = @IP,
	@TransferOption_dec = @TransferOption_dec,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT

if @ErrCode <> 0
	return


INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [MinBet], [MaxBet], autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking)
select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, 0, @alivepositiontaking_1, @mlivepositiontaking_1, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_1, @auto_mlivepositiontaking_1, @isauto_mpositiontaking_1, @isauto_mlivepositiontaking_1
UNION ALL
select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, 0, @alivepositiontaking_3, @mlivepositiontaking_3, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_3, @auto_mlivepositiontaking_3, @isauto_mpositiontaking_3, @isauto_mlivepositiontaking_3
UNION ALL
select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, 0, @alivepositiontaking_7, @mlivepositiontaking_7, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_7, @auto_mlivepositiontaking_7, @isauto_mpositiontaking_7, @isauto_mlivepositiontaking_7
UNION ALL
select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, 0, @alivepositiontaking_8, @mlivepositiontaking_8, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_8, @auto_mlivepositiontaking_8, @isauto_mpositiontaking_8, @isauto_mlivepositiontaking_8
UNION ALL
select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_2, 0, @isauto_mpositiontaking_2, 0
UNION ALL
select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_4, 0, @isauto_mpositiontaking_4, 0
--1x2
UNION ALL
select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_5, 0, @isauto_mpositiontaking_5, 0
UNION ALL
select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_6, 0, @isauto_mpositiontaking_6, 0
UNION ALL
select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_9, 0, @isauto_mpositiontaking_9, 0
UNION ALL
select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_10, 0, @isauto_mpositiontaking_10, 0

UNION ALL
select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_1, 0, @isauto_v2mpositiontaking_1, 0
UNION ALL
select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_2, 0, @isauto_v2mpositiontaking_2, 0
UNION ALL
select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_3, 0, @isauto_v2mpositiontaking_3, 0
UNION ALL
select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_7, 0, @isauto_v2mpositiontaking_7, 0
UNION ALL
select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_8, 0, @isauto_v2mpositiontaking_8, 0
--UNION ALL
--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_9, 0, @isauto_v2mpositiontaking_9, 0
UNION ALL
select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_20, 0, @isauto_v2mpositiontaking_20, 0

UNION ALL
select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_1, 0, @isauto_v3mpositiontaking_1, 0
UNION ALL
select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_2, 0, @isauto_v3mpositiontaking_2, 0
UNION ALL
select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_3, 0, @isauto_v3mpositiontaking_3, 0
UNION ALL
select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_20, 0, @isauto_v3mpositiontaking_20, 0

UNION ALL
select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_1, 0, @isauto_v5mpositiontaking_1, 0
UNION ALL
select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_2, 0, @isauto_v5mpositiontaking_2, 0
UNION ALL
select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_3, 0, @isauto_v5mpositiontaking_3, 0
UNION ALL
select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_20, 0, @isauto_v5mpositiontaking_20, 0

UNION ALL
select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_1, 0, @isauto_v8mpositiontaking_1, 0
UNION ALL
select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_3, 0, @isauto_v8mpositiontaking_3, 0
UNION ALL
select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_20, 0, @isauto_v8mpositiontaking_20, 0

UNION ALL
select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_1, 0, @isauto_v10mpositiontaking_1, 0
UNION ALL
select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_2, 0, @isauto_v10mpositiontaking_2, 0
UNION ALL
select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_3, 0, @isauto_v10mpositiontaking_3, 0
UNION ALL
select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_20, 0, @isauto_v10mpositiontaking_20, 0

UNION ALL
select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv11, @MaxBetv11, @auto_v11mpositiontaking_1, 0, @isauto_v11mpositiontaking_1, 0
UNION ALL
select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, @auto_v11mpositiontaking_20, 0, @isauto_v11mpositiontaking_20, 0

UNION ALL
select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_1, 0, @isauto_v99mpositiontaking_1, 0
UNION ALL
select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_2, 0, @isauto_v99mpositiontaking_2, 0
UNION ALL
select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_3, 0, @isauto_v99mpositiontaking_3, 0
UNION ALL
select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_20, 0, @isauto_v99mpositiontaking_20, 0
--- mix parlay of mixed sports
UNION ALL
select @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv99mp, @MaxBetv99mp, @auto_v99mpositiontaking_9, 0, @isauto_v99mpositiontaking_9, 0

if @@error <> 0
BEGIN
	--Error occur	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'크레딧 업데이트에 실패했습니다.  현재 마스터의 크레딧이 충분하지 않습니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 114
	
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert into CustSetting3rd  
INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [MinBet], [MaxBet], [autopositiontaking], [isautopositiontaking], [autompositiontaking], [isautompositiontaking], [alivepositiontaking],[mlivepositiontaking], [slivepositiontaking],[autolivepositiontaking], [isautolivepositiontaking], [autolivempositiontaking], [isautolivempositiontaking])
--v201
select @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
--v151
UNION ALL
select @custid, 31, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 32, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 41, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 42, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 51, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v152
UNION ALL
select @custid, 41, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 42, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 51, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v153
UNION ALL
select @custid, 51, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

---- v161 number game
--custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking, 
																																			-- slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking
UNION ALL 
select @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_81, @isauto_v161mpositiontaking_81, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_83, @isauto_v161mpositiontaking_83, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 85, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_85, @v161mlivepositiontaking_85, 0, 0, 0, @auto_v161mlivepositiontaking_85, @isauto_v161mlivepositiontaking_85
UNION ALL
select @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_86, @isauto_v161mpositiontaking_86, @v161alivepositiontaking_86, @v161mlivepositiontaking_86, 0, 0, 0, @auto_v161mlivepositiontaking_86, @isauto_v161mlivepositiontaking_86
UNION ALL
select @custid, 87, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_87, @v161mlivepositiontaking_87, 0, 0, 0, @auto_v161mlivepositiontaking_87, @isauto_v161mlivepositiontaking_87
UNION ALL
select @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_88, @isauto_v161mpositiontaking_88, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 89, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_89, @v161mlivepositiontaking_89, 0, 0, 0, @auto_v161mlivepositiontaking_89, @isauto_v161mlivepositiontaking_89
UNION ALL
select @custid, 90, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_90, @v161mlivepositiontaking_90, 0, 0, 0, @auto_v161mlivepositiontaking_90, @isauto_v161mlivepositiontaking_90

-- v180 virtual soccer
UNION ALL
select @custid, 1201, 180, 0, ISNULL(@min_v180mpositiontaking_1201,0), 0, 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

if @@error <> 0
BEGIN
	--Error occur	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'크레딧 업데이트에 실패했습니다.  현재 마스터의 크레딧이 충분하지 않습니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 114
	
	-- ROLLBACK MANUALLY
	DELETE CustSetting with (ROWLOCK) where custid =  @custid
	DELETE CustSetting3rd with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
select @custid, 1, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 7, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 8, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 4, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 5, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 6, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 9, 1, 0, 0.9, 0, 0.9
UNION ALL select @custid, 10, 1, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 7, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 8, 2, 0, 0.9, 0, 0.9
--UNION ALL select @custid, 9, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 2, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 3, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 5, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 8, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 8, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 8, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 10, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 11, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 11, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 99, 0, 0.9, 0, 0.9

UNION ALL select @custid, 9, 99, 0, 0.9, 0, 0.9

if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 115
		
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert Into CustOverride3rd
INSERT INTO [dbo].[CustOverride3rd]([custid], [bettype], [sporttype], [minpositiontaking], [maxpositiontaking],[minlivepositiontaking],[maxlivepositiontaking])
		  select @custid, 2, 201, 0, 0.5, 0, 0.9
UNION ALL select @custid, 3, 201, 0, 0.5, 0, 0.9

--v151
UNION ALL select @custid, 31, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 32, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 41, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 42, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 51, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 151, 0, 0.5, 0, 0.9
--v152
UNION ALL select @custid, 41, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 42, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 51, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 152, 0, 0.5, 0, 0.9
--v153
UNION ALL select @custid, 51, 153, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 153, 0, 0.5, 0, 0.9

-- number game
UNION ALL select @custid, 81, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 83, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 85, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 86, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 87, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 88, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 89, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 90, 161, 0, 0.9, 0, 0.9
-- v180 virtual soccer
UNION ALL select @custid, 1201, 180, 0, 0.9, 0, 0.9

if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 115
		
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert Into P2P Setting
INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
	(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
SELECT @custid  , 1001 , stakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @mrecommend AND bettype = 1001
UNION ALL 
SELECT @custid  , 1002 , stakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @mrecommend AND bettype = 1002


if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 115
		
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
           (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
SELECT @custid  , 1 , 0 , 0 , 0 , 0 
UNION ALL SELECT @custid  , 2 , 0 , 0 , 0 , 0           
--SELECT @custid custId,groupID,sdiscount,adiscount,0 discount,0 playerdiscount
--FROM dbo.P2PGroupComm
--Where custid  = @mrecommend ; 


if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 115
		
	-- ROLLBACK MANUALLY	
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--- insert into CustSettingGame
INSERT INTO custsettingGame(CustID, Bettype, Sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking)
		SELECT @custid, 1101, 162, 0, CASE WHEN @UplineSyncLiveCasino = 1 THEN mpositiontaking ELSE 0 END, 0, 0, 0, 0, 0, 0, 0, 0, 0
		FROM custsettingGame WITH(NOLOCK)
		WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101

if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 210
		
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid	
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END

--- insert into Custoverridegame
INSERT INTO Custoverridegame(CustID, Bettype, Sporttype, minpositiontaking)
				VALUES(@CustID, 1101, 162,0)
if @@error <> 0
BEGIN

	--Error occur
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Create customer failed. Please try again.'
							when 'CS' then N'新增会员不成功，请重新尝试.'
							when 'CT' then N'新增會員不成功,請重新再試.'
							when 'TH' then N'การเพิ่มจำนวนลูกค้าใหม่ ไม่สำเร็จ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Create customer failed. Please try again.'
							when 'ES' then N'Create customer failed. Please try again.'
							when 'KO' then N'고객 생성에 실패했습니다. 다시 시도해 주시기 바랍니다.'
							else N'Create customer failed. Please try again.'
						end,
		@ErrCode = 211
		
	-- ROLLBACK MANUALLY
	DELETE custsetting with (ROWLOCK) where custid =  @custid
	DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid	
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	DELETE Custoverridegame WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

Declare @LogSPData varchar(MAX)
--Log customer info
Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as varchar(100)),space(1))) + '" ' +
'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@address as varchar(160)),space(1))) + '" ' +
'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@city as varchar(100)),space(1))) + '" ' +
'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@state as varchar(100)),space(1))) + '" ' +
'country="'+ coalesce(cast(@country as varchar(100)),space(1)) + '" ' +
'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@postal as varchar(100)),space(1))) + '" ' +
'TransferOption="'+ coalesce(cast(@TransferOption as varchar(8)),space(1)) + '" ' +
'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
'maxcredit="'+ coalesce(cast(@maxcredit as varchar(50)),space(1)) + '" ' +
'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +
'sitename="'+ coalesce(cast(@sitename as varchar(20)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'


BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 602,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY	
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
	'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
	'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
	'email="'+ dbo.f_EncodeXMLValue(coalesce(cast(@email as varchar(100)),space(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
	'address="'+ dbo.f_EncodeXMLValue(coalesce(cast(@address as varchar(160)),space(1))) + '" ' +
	'city="'+ dbo.f_EncodeXMLValue(coalesce(cast(@city as varchar(100)),space(1))) + '" ' +
	'state="'+ dbo.f_EncodeXMLValue(coalesce(cast(@state as varchar(100)),space(1))) + '" ' +
	'country="'+ coalesce(cast(@country as varchar(100)),space(1)) + '" ' +
	'postal="'+ dbo.f_EncodeXMLValue(coalesce(cast(@postal as varchar(100)),space(1))) + '" ' +
	'TransferOption="'+ coalesce(cast(@TransferOption as varchar(8)),space(1)) + '" ' +
	'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
	'maxcredit="'+ coalesce(cast(@maxcredit as varchar(50)),space(1)) + '" ' +
	'mrecommend="'+ coalesce(cast(@mrecommend as varchar(50)),space(1)) + '" ' +
	'sitename="'+ coalesce(cast(@sitename as varchar(20)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 602,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH
	
--Log commission
Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" />'


BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 202,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' + 
	'ErrMsg="' + ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 202,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH
	
--log bet Setting
Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
'MinBv2="'+ coalesce(cast(@MinBetv2 as varchar(50)),space(1)) + '" ' +
'MaxBv2="'+ coalesce(cast(@MaxBetv2 as varchar(50)),space(1)) + '" ' +
'MPMv2="'+ coalesce(cast(@MaxPerMatchv2 as varchar(50)),space(1)) + '" ' +
'MinBv3="'+ coalesce(cast(@MinBetv3 as varchar(50)),space(1)) + '" ' +
'MaxBv3="'+ coalesce(cast(@MaxBetv3 as varchar(50)),space(1)) + '" ' +
'MPMv3="'+ coalesce(cast(@MaxPerMatchv3 as varchar(50)),space(1)) + '" ' +
'MinBv5="'+ coalesce(cast(@MinBetv5 as varchar(50)),space(1)) + '" ' +
'MaxBv5="'+ coalesce(cast(@MaxBetv5 as varchar(50)),space(1)) + '" ' +
'MPMv5="'+ coalesce(cast(@MaxPerMatchv5 as varchar(50)),space(1)) + '" ' +
'MinBv8="'+ coalesce(cast(@MinBetv8 as varchar(50)),space(1)) + '" ' +
'MaxBv8="'+ coalesce(cast(@MaxBetv8 as varchar(50)),space(1)) + '" ' +
'MPMv8="'+ coalesce(cast(@MaxPerMatchv8 as varchar(50)),space(1)) + '" ' +
'MinBv10="'+ coalesce(cast(@MinBetv10 as varchar(50)),space(1)) + '" ' +
'MaxBv10="'+ coalesce(cast(@MaxBetv10 as varchar(50)),space(1)) + '" ' +
'MPMv10="'+ coalesce(cast(@MaxPerMatchv10 as varchar(50)),space(1)) + '" ' +
'MinBv11="'+ coalesce(cast(@MinBetv11 as varchar(50)),space(1)) + '" ' +
'MaxBv11="'+ coalesce(cast(@MaxBetv11 as varchar(50)),space(1)) + '" ' +
'MPMv11="'+ coalesce(cast(@MaxPerMatchv11 as varchar(50)),space(1)) + '" ' +
'MinBv99="'+ coalesce(cast(@MinBetv99 as varchar(50)),space(1)) + '" ' +
'MaxBv99="'+ coalesce(cast(@MaxBetv99 as varchar(50)),space(1)) + '" ' +
'MPMv99="'+ coalesce(cast(@MaxPerMatchv99 as varchar(50)),space(1)) + '" ' +
'MinBv99mp="'+ coalesce(cast(@MinBetv99mp as varchar(50)),space(1)) + '" ' +
'MaxBv99mp="'+ coalesce(cast(@MaxBetv99mp as varchar(50)),space(1)) + '" ' +
'MPMv99mp="'+ coalesce(cast(@MaxPerMatchv99mp as varchar(50)),space(1)) + '" ' +
'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="' + coalesce(cast(@MaxPerBallv161 as varchar(50)), space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 302,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@MinBetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@MaxBetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@MaxPerMatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@MinBetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@MaxBetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@MaxPerMatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@MinBetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@MaxBetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@MaxPerMatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@MinBetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@MaxBetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@MaxPerMatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@MinBetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@MaxBetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@MaxPerMatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@MinBetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@MaxBetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@MaxPerMatchv11 as varchar(50)),space(1)) + '" ' +
	'MinBv99="'+ coalesce(cast(@MinBetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@MaxBetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@MaxPerMatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99mp="'+ coalesce(cast(@MinBetv99mp as varchar(50)),space(1)) + '" ' +
	'MaxBv99mp="'+ coalesce(cast(@MaxBetv99mp as varchar(50)),space(1)) + '" ' +
	'MPMv99mp="'+ coalesce(cast(@MaxPerMatchv99mp as varchar(50)),space(1)) + '" ' +
	'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161="' + coalesce(cast(@MaxPerBallv161 as varchar(50)), space(1)) + '" '+
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 302,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH 
 
--Log Status
Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'isinternal="'+ coalesce(cast(@IsInternal as varchar(50)),space(1)) + '" ' +
'suspended="'+ coalesce(cast(@suspended as varchar(1)),space(1)) + '" ' +
'closed="'+ coalesce(cast(@UplineClosed as varchar(1)),space(1)) + '" ' +
'DisableHorseRacing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
'DisableOT="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
'Disable151_51="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +
'Disable152_41="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +
'Disable152_51="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +
'Disable153_51="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' +
'DisableVirtualSports="'+ coalesce(cast(@Disable180_1201 as varchar(1)),space(1)) + '" ' +
'DisableCasino="'+ coalesce(cast(@DisableCasino as varchar(1)),space(1)) + '" ' +
'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(1)),space(1)) + '" ' +
'DisableNumber="' + coalesce(cast(@DisableNumber as varchar(1)),space(1)) + '" ' +
'DisableBingo="' + coalesce(cast(@DisableBingo as varchar(1)),space(1)) + '" ' +
'Disable162_1101="' + coalesce(cast(@Disable162_1101 as varchar(1)),space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1102,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_MAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'isinternal="'+ coalesce(cast(@IsInternal as varchar(50)),space(1)) + '" ' +
	'suspended="'+ coalesce(cast(@suspended as varchar(1)),space(1)) + '" ' +
	'closed="'+ coalesce(cast(@UplineClosed as varchar(1)),space(1)) + '" ' +
	'DisableHorseRacing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
	'DisableOT="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
	'Disable151_51="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +
	'Disable152_41="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +
	'Disable152_51="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +
	'Disable153_51="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' +
	'DisableVirtualSports="'+ coalesce(cast(@Disable180_1201 as varchar(1)),space(1)) + '" ' +
	'DisableCasino="'+ coalesce(cast(@DisableCasino as varchar(1)),space(1)) + '" ' +
	'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(1)),space(1)) + '" ' +
	'DisableNumber="' + coalesce(cast(@DisableNumber as varchar(1)),space(1)) + '" ' +
	'DisableBingo="' + coalesce(cast(@DisableBingo as varchar(1)),space(1)) + '" ' +
	'Disable162_1101="' + coalesce(cast(@Disable162_1101 as varchar(1)),space(1)) + '" '+
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1102,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH	
	
-- Write Log Credit	
Declare @LogSPCredit varchar(MAX)
Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1)) + ',
MaxCredit='+ coalesce(cast(@maxcredit as varchar(50)),space(1)) + ',
SubAccName='+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1209
END TRY
BEGIN CATCH
	Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1)) + ',
MaxCredit='+ coalesce(cast(@maxcredit as varchar(50)),space(1)) + ',
SubAccName='+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + ',
ErrMsg=' + ERROR_MESSAGE() 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1209
END CATCH

Select @LogSPData = '<Acc_CustomerInsMember_MAg><ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +

'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

--auto v1
'<aum a_mpt_1="'+ coalesce(cast(@auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mpt_2="'+ coalesce(cast(@auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_mpt_3="'+ coalesce(cast(@auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mpt_4="'+ coalesce(cast(@auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_mpt_5="'+ coalesce(cast(@auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_mpt_6="'+ coalesce(cast(@auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_mpt_7="'+ coalesce(cast(@auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mpt_8="'+ coalesce(cast(@auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_mpt_9="'+ coalesce(cast(@auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_mpt_10="'+ coalesce(cast(@auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_mlivept_1="'+ coalesce(cast(@auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mlivept_3="'+ coalesce(cast(@auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mlivept_7="'+ coalesce(cast(@auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mlivept_8="'+ coalesce(cast(@auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--auto v2
'a_v2mpt_1="'+ coalesce(cast(@auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_2="'+ coalesce(cast(@auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_3="'+ coalesce(cast(@auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_7="'+ coalesce(cast(@auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_8="'+ coalesce(cast(@auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'a_v2mpt_9="'+ coalesce(cast(@auto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_20="'+ coalesce(cast(@auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v3
'a_v3mpt_1="'+ coalesce(cast(@auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_2="'+ coalesce(cast(@auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_3="'+ coalesce(cast(@auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_20="'+ coalesce(cast(@auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v5
'a_v5mpt_1="'+ coalesce(cast(@auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_2="'+ coalesce(cast(@auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_3="'+ coalesce(cast(@auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_20="'+ coalesce(cast(@auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v8
'a_v8mpt_1="'+ coalesce(cast(@auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_3="'+ coalesce(cast(@auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_20="'+ coalesce(cast(@auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v10
'a_v10mpt_1="'+ coalesce(cast(@auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_2="'+ coalesce(cast(@auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_3="'+ coalesce(cast(@auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_20="'+ coalesce(cast(@auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v11
'a_v11mpt_1="'+ coalesce(cast(@auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11mpt_20="'+ coalesce(cast(@auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v99
'a_v99mpt_1="'+ coalesce(cast(@auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_2="'+ coalesce(cast(@auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_3="'+ coalesce(cast(@auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_20="'+ coalesce(cast(@auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v99mpt_9="'+ coalesce(cast(@auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

'a_v161mpt_81="'+ coalesce(cast(@auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_83="'+ coalesce(cast(@auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'a_v161mpt_85="'+ coalesce(cast(@auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_86="'+ coalesce(cast(@auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_88="'+ coalesce(cast(@auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_85="'+ coalesce(cast(@auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_86="'+ coalesce(cast(@auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_87="'+ coalesce(cast(@auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_89="'+ coalesce(cast(@auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_90="'+ coalesce(cast(@auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) +  '" />' +

--isauto v1
'<iam isa_mpt_1="'+ coalesce(cast(@isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mpt_2="'+ coalesce(cast(@isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_mpt_3="'+ coalesce(cast(@isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mpt_4="'+ coalesce(cast(@isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_mpt_5="'+ coalesce(cast(@isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_mpt_6="'+ coalesce(cast(@isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_mpt_7="'+ coalesce(cast(@isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mpt_8="'+ coalesce(cast(@isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_mpt_9="'+ coalesce(cast(@isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_mpt_10="'+ coalesce(cast(@isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_1="'+ coalesce(cast(@isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_3="'+ coalesce(cast(@isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_7="'+ coalesce(cast(@isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_8="'+ coalesce(cast(@isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--isauto v2
'isa_v2mpt_1="'+ coalesce(cast(@isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_2="'+ coalesce(cast(@isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_3="'+ coalesce(cast(@isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_7="'+ coalesce(cast(@isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_8="'+ coalesce(cast(@isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'isa_v2mpt_9="'+ coalesce(cast(@isauto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_20="'+ coalesce(cast(@isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v3
'isa_v3mpt_1="'+ coalesce(cast(@isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_2="'+ coalesce(cast(@isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_3="'+ coalesce(cast(@isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_20="'+ coalesce(cast(@isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v5
'isa_v5mpt_1="'+ coalesce(cast(@isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_2="'+ coalesce(cast(@isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_3="'+ coalesce(cast(@isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_20="'+ coalesce(cast(@isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v8
'isa_v8mpt_1="'+ coalesce(cast(@isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_3="'+ coalesce(cast(@isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_20="'+ coalesce(cast(@isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v10
'isa_v10mpt_1="'+ coalesce(cast(@isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_2="'+ coalesce(cast(@isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_3="'+ coalesce(cast(@isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_20="'+ coalesce(cast(@isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v11
'isa_v11mpt_1="'+ coalesce(cast(@isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v11mpt_20="'+ coalesce(cast(@isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v99
'isa_v99mpt_1="'+ coalesce(cast(@isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_2="'+ coalesce(cast(@isauto_v99mpositiontaking_2 as varchar(50)),space(1))+ '" ' +
'isa_v99mpt_3="'+ coalesce(cast(@isauto_v99mpositiontaking_3 as varchar(50)),space(1))+ '" ' +
'isa_v99mpt_20="'+ coalesce(cast(@isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

-- mix parlay of mixed sports
'isa_v99mpt_9="'+ coalesce(cast(@isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

-- number game
'isa_v161mpt_81="'+ coalesce(cast(@isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_83="'+ coalesce(cast(@isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'isa_v161mpt_85="'+ coalesce(cast(@isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_86="'+ coalesce(cast(@isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_88="'+ coalesce(cast(@isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_85="'+ coalesce(cast(@isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_86="'+ coalesce(cast(@isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_87="'+ coalesce(cast(@isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_89="'+ coalesce(cast(@isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_90="'+ coalesce(cast(@isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerInsMember_MAg>' 

--Log positiontaking
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 402,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_MAg><ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +

	'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

	'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	--auto v1
	'<aum a_mpt_1="'+ coalesce(cast(@auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mpt_2="'+ coalesce(cast(@auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_mpt_3="'+ coalesce(cast(@auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mpt_4="'+ coalesce(cast(@auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'a_mpt_5="'+ coalesce(cast(@auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'a_mpt_6="'+ coalesce(cast(@auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'a_mpt_7="'+ coalesce(cast(@auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mpt_8="'+ coalesce(cast(@auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'a_mpt_9="'+ coalesce(cast(@auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_mpt_10="'+ coalesce(cast(@auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_1="'+ coalesce(cast(@auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_3="'+ coalesce(cast(@auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_7="'+ coalesce(cast(@auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_8="'+ coalesce(cast(@auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--auto v2
	'a_v2mpt_1="'+ coalesce(cast(@auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_2="'+ coalesce(cast(@auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_3="'+ coalesce(cast(@auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_7="'+ coalesce(cast(@auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_8="'+ coalesce(cast(@auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'a_v2mpt_9="'+ coalesce(cast(@auto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_20="'+ coalesce(cast(@auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v3
	'a_v3mpt_1="'+ coalesce(cast(@auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_2="'+ coalesce(cast(@auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_3="'+ coalesce(cast(@auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_20="'+ coalesce(cast(@auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v5
	'a_v5mpt_1="'+ coalesce(cast(@auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_2="'+ coalesce(cast(@auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_3="'+ coalesce(cast(@auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_20="'+ coalesce(cast(@auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v8
	'a_v8mpt_1="'+ coalesce(cast(@auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_3="'+ coalesce(cast(@auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_20="'+ coalesce(cast(@auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v10
	'a_v10mpt_1="'+ coalesce(cast(@auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_2="'+ coalesce(cast(@auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_3="'+ coalesce(cast(@auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_20="'+ coalesce(cast(@auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v11
	'a_v11mpt_1="'+ coalesce(cast(@auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v11mpt_20="'+ coalesce(cast(@auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v99
	'a_v99mpt_1="'+ coalesce(cast(@auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_2="'+ coalesce(cast(@auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_3="'+ coalesce(cast(@auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_20="'+ coalesce(cast(@auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v99mpt_9="'+ coalesce(cast(@auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

	'a_v161mpt_81="'+ coalesce(cast(@auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_83="'+ coalesce(cast(@auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'a_v161mpt_85="'+ coalesce(cast(@auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_86="'+ coalesce(cast(@auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_88="'+ coalesce(cast(@auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_85="'+ coalesce(cast(@auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_86="'+ coalesce(cast(@auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_87="'+ coalesce(cast(@auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_89="'+ coalesce(cast(@auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_90="'+ coalesce(cast(@auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) +  '" />' +

	--isauto v1
	'<iam isa_mpt_1="'+ coalesce(cast(@isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_2="'+ coalesce(cast(@isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_3="'+ coalesce(cast(@isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_4="'+ coalesce(cast(@isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_5="'+ coalesce(cast(@isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_6="'+ coalesce(cast(@isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_7="'+ coalesce(cast(@isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_8="'+ coalesce(cast(@isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_9="'+ coalesce(cast(@isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_10="'+ coalesce(cast(@isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_1="'+ coalesce(cast(@isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_3="'+ coalesce(cast(@isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_7="'+ coalesce(cast(@isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_8="'+ coalesce(cast(@isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--isauto v2
	'isa_v2mpt_1="'+ coalesce(cast(@isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_2="'+ coalesce(cast(@isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_3="'+ coalesce(cast(@isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_7="'+ coalesce(cast(@isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_8="'+ coalesce(cast(@isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'isa_v2mpt_9="'+ coalesce(cast(@isauto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_20="'+ coalesce(cast(@isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v3
	'isa_v3mpt_1="'+ coalesce(cast(@isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_2="'+ coalesce(cast(@isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_3="'+ coalesce(cast(@isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_20="'+ coalesce(cast(@isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v5
	'isa_v5mpt_1="'+ coalesce(cast(@isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_2="'+ coalesce(cast(@isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_3="'+ coalesce(cast(@isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_20="'+ coalesce(cast(@isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v8
	'isa_v8mpt_1="'+ coalesce(cast(@isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_3="'+ coalesce(cast(@isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_20="'+ coalesce(cast(@isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v10
	'isa_v10mpt_1="'+ coalesce(cast(@isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_2="'+ coalesce(cast(@isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_3="'+ coalesce(cast(@isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_20="'+ coalesce(cast(@isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v11
	'isa_v11mpt_1="'+ coalesce(cast(@isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v11mpt_20="'+ coalesce(cast(@isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v99
	'isa_v99mpt_1="'+ coalesce(cast(@isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_2="'+ coalesce(cast(@isauto_v99mpositiontaking_2 as varchar(50)),space(1))+ '" ' +
	'isa_v99mpt_3="'+ coalesce(cast(@isauto_v99mpositiontaking_3 as varchar(50)),space(1))+ '" ' +
	'isa_v99mpt_20="'+ coalesce(cast(@isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	-- mix parlay of mixed sports
	'isa_v99mpt_9="'+ coalesce(cast(@isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

	-- number game
	'isa_v161mpt_81="'+ coalesce(cast(@isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_83="'+ coalesce(cast(@isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'isa_v161mpt_85="'+ coalesce(cast(@isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_86="'+ coalesce(cast(@isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_88="'+ coalesce(cast(@isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_85="'+ coalesce(cast(@isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_86="'+ coalesce(cast(@isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_87="'+ coalesce(cast(@isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_89="'+ coalesce(cast(@isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_90="'+ coalesce(cast(@isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" ' + 
	'ErrMsg="'+ ERROR_MESSAGE() + '" /></Acc_CustomerInsMember_MAg>' 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 402,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_MAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_MAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_MAg] TO [bodbExtAccNet] AS [dbo]
GO
