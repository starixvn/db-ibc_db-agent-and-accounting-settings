USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerInsMember_Ag]    Script Date: 04/25/2013 13:32:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Ag]
	@custid int OUTPUT,
	@firstname nvarchar(50),
	@lastname nvarchar(50),
	@creator int,
	@username varchar(30),
	@userpwd varchar(40),
	@phone nvarchar(50),
	@fax nvarchar(50),
	@mobilephone nvarchar(50),
	@playerdiscount decimal(9,8), 
	@playerdiscountcs decimal(9,8),
	--1x2 
	@playerdiscount1x2 decimal(9,8)=0,	
	
	@playerdiscountnumber decimal(9,8)=0,

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
	
	--Mix Parlay mix sports
	@MinBetv99MP money,
	@MaxBetv99MP money,
	@MaxPerMatchv99MP money,
	
	--Number game
	@MinBetv161 money,
	@MaxBetv161 money,
	@MaxPerBallv161 money = 0,
	@MaxPerMatchv161 money,
	
	@credit money,
	@suspended bit = null,
	@Disable151_31 bit = 0,-- @DisableHorseRacing -> @Disable151_31
	@Disable151_41 bit = 0,-- @DisableOpenTote -> @Disable151_41
	@Disable151_51 bit = 0,-- @Disable151_AU -> @Disable151_51    
	@Disable152_41 bit = 0,-- @Disable152_UK -> @Disable152_41    
	@Disable152_51 bit = 0,-- @Disable152_AU -> @Disable152_51    
	@Disable153_51 bit = 0,--@Disable153_AU  -> @Disable153_51 
	@DisableFinancial bit = 0,
	@DisableCasino bit = 0, 
	@DisableBingo bit = 0,
	@DisableNumber bit = 0,
	@Disable162_1101 bit = 0,
	@Disable180_1201 bit = 0,
	
	@recommend int,
	@ugroup varchar(5),
	@closed bit,
	
	@suspendedFlag varchar(6)=null,
		
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
	
	@alivepositiontaking_1 smallmoney,
	@alivepositiontaking_3 smallmoney,
	@alivepositiontaking_7 smallmoney,
	@alivepositiontaking_8 smallmoney,
	
	@v2apositiontaking_1 smallmoney,
	@v2apositiontaking_2 smallmoney,
	@v2apositiontaking_3 smallmoney,
	@v2apositiontaking_7 smallmoney,
	@v2apositiontaking_8 smallmoney,
	
	--@v2apositiontaking_9 smallmoney=0,
	
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
	@v99apositiontaking_9 smallmoney,
	@v99apositiontaking_20 smallmoney,
	
	
	@v161apositiontaking_81 smallmoney, 
	@v161apositiontaking_83 smallmoney, 
	@v161apositiontaking_86 smallmoney, 
	@v161apositiontaking_88 smallmoney = 0, 
	@v161alivepositiontaking_85 smallmoney,
	@v161alivepositiontaking_86 smallmoney,
	@v161alivepositiontaking_87 smallmoney,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,
	
	@DisableP2P BIT = 0,
	@DisableFUNP2P BIT = 0,
	
	@IP varchar(15)='',
	
	@success bit = 1 OUTPUT,
	@Language varchar(2)= 'E',
	@SubAccID int = 0, --Sub-AccountID
	@isSearchAndCopy bit = 0,
	@copyFromCustID int = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
--@Source Control
/*
Created: 20090121@Thien
Task :  Add new member
		AgentSite-AccountingSite\add new member
DB: DBTRANS.bodb02
Original:  Run in Dot_Dep_CustomerInsMember_Ag_xtest
Revisions:
    - 20081009@Phuc: Auto Master PT  
	- 20081022@Phuc: Add new sporttype 201, bettype 3
	- 20081022@Phuc: Hard code copy min/max/maxperbet/PT for 201 from 2 sporttype will remove when deploy FI
	- 20090121@PhuongBich: Add new bettype 2(sporttype 201)
	- 20090122@PhuongNguyen: Remove userpwd from log writing
	- 20090218@PhuongDao: Check username2 	
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission.
	- 20090403@Phuc: hard code default values for sporttype 201 bettype 2
	- 20090407@Phuc: IF DisableFinancial (upline or webconfig) set a1 = n2; get minbet201, maxbet201, maxpermatch201 from upline
	- 20090417@PhuongDao: Set default virtualrate = 0% 
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: 
			+ Remove HR Min-Max BET
			+ Use maxcredit in CustAgent instead of Custinfo table and not to insert maxcredit on custinfo  
	- 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Simon: Write Credit Log into Userlog_Credit table.
	- 20090917@Phuc: write log into DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status from the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Phuc: hardcode commission for member under 8RM agent.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100828@Henry: remove mix parlay of basketball + add new section for MixParlay for Mix Sports + Setting for Numbergame
	- 20100909@Jamie: + Add param @DisableCasino 
					  + Remove param @DisableFinancial_WC 
	- 20101019@Henry: Record execution time
	- 20101029@Johnson: Include max per ball for number game
	-20110103@Johnson: Add setting for HR AU, Greyhound, Harness  
	- 20110504@Johnson: copy Danger's setting from upline
	- 20110520@Johnson: Allow spaces between words in user name when creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20110819@Jamie: Get Next Combo, Number Group for checking message error
	- 20110822@Tom: Add P2P setting
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20110929@Johnson: Check group for adding new member under Won currency
	- 20111020@Sophia: Create balance for new customer
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@error for inserting balance table and P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (from upline)
	- 20111226@Lukas: Add Live casino game - PT setting
	- 20120210@TOM: Insert default value of P2P Comm
	- 20120412@Hurri: hardcode commission for member under BARM agent
	- 20120413@Dan: add parameter @isSearchAndCopy to write log to know whether a customer was created from "Search and Copy" function or not (Full mode)
	- 20120502@Johnson: Correct tracking value for number game
	- 20120502@Lukas: Encode XML values in logging
	- 20120522@Sophia: Remove hardcode commission for member under BARM agent
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120710@Johnson: Add virtual soccer's setting
	- 20120823@Elodie: Add Abnormal field
	- 20120827@Johnson: Check a1 with min(a2,a4) and m1 with min(m4-a1,m3-a1,l3-a1)
	- 20120925@Dan: add win limit setting for live casino
	- 20120928@Johnson: add double comm losing status
Param's Explanation:	
• @ErrCode:
    = 0: add new member successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--20080514: Not allow agent LIM open new member (By Wan)
if @recommend in (920145)
BEGIN
	SELECT	@ErrMsg =	case @Language 
							when 'E' then 'Sorry. You cannot create more member.'
							when 'CS' then N'对不起，您不能增加任何新的会员.'
							when 'CT' then N'對不起, 您不能增加任何新的會員.'	
							when 'TH' then N'ขออภัย คุณไม่สามารถเปิดบัญชีเพื่อเพิ่มจำนวนลูกค้าได้มากกว่านี้.'	
							when 'J' then 'Sorry. You cannot create more member.'	
							when 'ES' then N'Sorry. You cannot create more member.'				
							when 'KO' then N'죄송합니다.  더 이상 회원을 만들 수 없습니다'				
							else N'Sorry. You cannot create more member.'
					end,
			@success = 0, @ErrCode = 999
	return
END

/*thien@20081205: thien unblock again from Ah Wan request
--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
if exists (select 1 from custinfo with (nolock) where custid = @recommend and srecommend in (194355, 194356, 726562, 726571, 726579, 1164457, 194354, 726582))
BEGIN	
	SELECT	@ErrMsg =	case @Language 
							when 'E' then 'Sorry. You cannot create more member.'
							when 'CS' then N'对不起，您不能增加任何新的会员.'
							when 'CT' then N'對不起, 您不能增加任何新的會員.'	
							when 'TH' then N'ขออภัย คุณไม่สามารถเปิดบัญชีเพื่อเพิ่มจำนวนลูกค้าได้มากกว่านี้.'						
							else N'Sorry. You cannot create more member.'
					end,
			@success = 0, @ErrCode = 999
	if @ReturnErrCode = 0
			RaisError (@ErrMsg, 16, 1)		
	return
END
*/


--Check an account disabled or not 
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @recommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
if @ErrCode <>0		return 



declare @transcode bigint, @currency int, @mrecommend int, @pwdexpiry datetime, @srecommend int,
	@MinMinBet money, @MaxMaxBet money, @MaxMaxPerMatch money,
	@MinMinBetv2 money, @MaxMaxBetv2 money, @MaxMaxPerMatchv2 money,
	@MinMinBetv3 money, @MaxMaxBetv3 money, @MaxMaxPerMatchv3 money,
	@MinMinBetv5 money, @MaxMaxBetv5 money, @MaxMaxPerMatchv5 money,
	@MinMinBetv8 money, @MaxMaxBetv8 money, @MaxMaxPerMatchv8 money,
	@MinMinBetv10 money, @MaxMaxBetv10 money, @MaxMaxPerMatchv10 money,
	@MinMinBetv11 money, @MaxMaxBetv11 money, @MaxMaxPerMatchv11 money,
	@MinMinBetv99 money, @MaxMaxBetv99 money, @MaxMaxPerMatchv99 money,	
	@MinMinBetv99MP money, @MaxMaxBetv99MP money, @MaxMaxPerMatchv99MP money,	
	@MinMinBetv161 money, @MaxMaxBetv161 money, @MaxMaxPerMatchv161 money,@MaxMaxPerBallv161 money,	
	@MinBetv180 money, @MaxBetv180 money, @MaxPerMatchv180 money,
	@MinMinBetv180 money, @MaxMaxBetv180 money, @MaxMaxPerMatchv180 money, 
	
	@AgentCredit money, @Credit_AllOtherMember money,
	@MaxCredit_Mem money,
	@Asuspended bit,
	@UplineClosed bit,
	@DisableOutright bit,
	@UplineSyncLiveCasino bit,
	@HideVirtualSports  BIT,
	@isAutoResetLiveCasino BIT , 
	@MaxWinLiveCasino SMALLMONEY ,
	
	@AgentDanger tinyint,
	@AgentDanger2 tinyint,
	@AgentDanger3 tinyint,
	@AgentAbnormal tinyint,
	
--	@AgentMaxPerMatch money, @AgentMaxPerMatchb money,
--	@MaxPerMatch_AllOtherMember money, @MaxPerMatchv2_AllOtherMember money,

	--m2
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
	@mlivepositiontaking_1 smallmoney,
	@mlivepositiontaking_3 smallmoney,
	@mlivepositiontaking_7 smallmoney,
	@mlivepositiontaking_8 smallmoney,
	
	@v2mpositiontaking_1 smallmoney,
	@v2mpositiontaking_2 smallmoney,
	@v2mpositiontaking_3 smallmoney,
	@v2mpositiontaking_7 smallmoney,
	@v2mpositiontaking_8 smallmoney,
	--@v2mpositiontaking_9 smallmoney,
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
	@v99mpositiontaking_9 smallmoney,
	@v99mpositiontaking_20 smallmoney,

	@v151mpositiontaking_31 smallmoney,
	@v151mpositiontaking_32 smallmoney,
	@v151mpositiontaking_41 smallmoney,
	@v151mpositiontaking_42 smallmoney,
	@v151mpositiontaking_51 smallmoney,
	@v151mpositiontaking_52 smallmoney,
	
	@v152mpositiontaking_41 smallmoney,
	@v152mpositiontaking_42 smallmoney,
	@v152mpositiontaking_51 smallmoney,
	@v152mpositiontaking_52 smallmoney,
	
	@v153mpositiontaking_51 smallmoney,
	@v153mpositiontaking_52 smallmoney,
	
	@v201mpositiontaking_2 smallmoney,
	@v201mpositiontaking_3 smallmoney,
	
	@v161mpositiontaking_81 smallmoney, 
	@v161mpositiontaking_83 smallmoney, 
	@v161mpositiontaking_86 smallmoney, 
	@v161mpositiontaking_88 smallmoney, 
	@v161mlivepositiontaking_85 smallmoney,
	@v161mlivepositiontaking_86 smallmoney,
	@v161mlivepositiontaking_87 smallmoney,
	@v161mlivepositiontaking_89 smallmoney,
	@v161mlivepositiontaking_90 smallmoney,
	
	@v162mpositiontaking_1101 smallmoney,
	
	@v180mpositiontaking_1201 smallmoney,
	--s3
	@spositiontaking_1 smallmoney,
	@spositiontaking_2 smallmoney,
	@spositiontaking_3 smallmoney,
	@spositiontaking_4 smallmoney,
	@spositiontaking_5 smallmoney,
	@spositiontaking_6 smallmoney,
	@spositiontaking_7 smallmoney,
	@spositiontaking_8 smallmoney,
	@spositiontaking_9 smallmoney,
	@spositiontaking_10 smallmoney,
	
	@slivepositiontaking_1 smallmoney,
	@slivepositiontaking_3 smallmoney,
	@slivepositiontaking_7 smallmoney,
	@slivepositiontaking_8 smallmoney,
	
	@v2spositiontaking_1 smallmoney,
	@v2spositiontaking_2 smallmoney,
	@v2spositiontaking_3 smallmoney,
	@v2spositiontaking_7 smallmoney,
	@v2spositiontaking_8 smallmoney,
	--@v2spositiontaking_9 smallmoney,
	@v2spositiontaking_20 smallmoney,
	
	@v3spositiontaking_1 smallmoney,
	@v3spositiontaking_2 smallmoney,
	@v3spositiontaking_3 smallmoney,
	@v3spositiontaking_20 smallmoney,

	@v5spositiontaking_1 smallmoney,
	@v5spositiontaking_2 smallmoney,
	@v5spositiontaking_3 smallmoney,
	@v5spositiontaking_20 smallmoney,

	@v8spositiontaking_1 smallmoney,
	@v8spositiontaking_3 smallmoney,
	@v8spositiontaking_20 smallmoney,

	@v10spositiontaking_1 smallmoney,
	@v10spositiontaking_2 smallmoney,
	@v10spositiontaking_3 smallmoney,
	@v10spositiontaking_20 smallmoney,

	@v11spositiontaking_1 smallmoney,
	@v11spositiontaking_20 smallmoney,

	@v99spositiontaking_1 smallmoney,
	@v99spositiontaking_2 smallmoney,
	@v99spositiontaking_3 smallmoney,
	@v99spositiontaking_9 smallmoney,
	@v99spositiontaking_20 smallmoney,
	
	

	@v151spositiontaking_31 smallmoney,
	@v151spositiontaking_32 smallmoney,
	@v151spositiontaking_41 smallmoney,
	@v151spositiontaking_42 smallmoney,
	@v151spositiontaking_51 smallmoney,
	@v151spositiontaking_52 smallmoney,
	
	@v152spositiontaking_41 smallmoney,
	@v152spositiontaking_42 smallmoney,
	@v152spositiontaking_51 smallmoney,
	@v152spositiontaking_52 smallmoney,
	
	@v153spositiontaking_51 smallmoney,
	@v153spositiontaking_52 smallmoney,
		
	@v201spositiontaking_2 smallmoney,
	@v201spositiontaking_3 smallmoney,
	
	@v161spositiontaking_81 smallmoney, 
	@v161spositiontaking_83 smallmoney, 
	@v161spositiontaking_86 smallmoney, 
	@v161spositiontaking_88 smallmoney, 
	@v161slivepositiontaking_85 smallmoney,
	@v161slivepositiontaking_86 smallmoney,
	@v161slivepositiontaking_87 smallmoney,
	@v161slivepositiontaking_89 smallmoney,
	@v161slivepositiontaking_90 smallmoney,
	
	@v162spositiontaking_1101 smallmoney,
	
	@v180spositiontaking_1201 smallmoney,
	
	@adiscount decimal(9,8),
	@adiscountcs decimal(9,8),
	@sdiscount decimal(9,8),
	@sdiscountcs decimal(9,8),
	@maxdiscount decimal(9,8),
	@maxdiscountcs decimal(9,8),
	
	--1x2
	@discount1x2 decimal(9,8),
	@adiscount1x2 decimal(9,8),
	@sdiscount1x2 decimal(9,8),
	
	--v151
	@v151discount_31 decimal(9,8),
	@v151adiscount_31 decimal(9,8),
	@v151sdiscount_31 decimal(9,8),
	
	@v151discount_41 decimal(9,8),
	@v151adiscount_41 decimal(9,8),
	@v151sdiscount_41 decimal(9,8),
	
	@v151discount_51 decimal(9,8),
	@v151adiscount_51 decimal(9,8),
	@v151sdiscount_51 decimal(9,8),
	
	--v152
	@v152discount_41 decimal(9,8),
	@v152adiscount_41 decimal(9,8),
	@v152sdiscount_41 decimal(9,8),
	
	@v152discount_51 decimal(9,8),
	@v152adiscount_51 decimal(9,8),
	@v152sdiscount_51 decimal(9,8),
	
	--v153
	@v153discount_51 decimal(9,8),
	@v153adiscount_51 decimal(9,8),
	@v153sdiscount_51 decimal(9,8),
	
	--v201
	@v201discount decimal(9,8),
	@v201adiscount decimal(9,8),
	@v201sdiscount decimal(9,8),

	--v161
	@discountnumber decimal(9,8),
	@adiscountnumber decimal(9,8),
	@sdiscountnumber decimal(9,8),
	
	--v162
	@v162discount_1101 decimal(9,8),
	@v162adiscount_1101 decimal(9,8),
	@v162sdiscount_1101 decimal(9,8),
	
	@site nvarchar(50),
--	@maxpos smallmoney,
	--u3
	@auto_spositiontaking_1 smallmoney,
	@auto_spositiontaking_2 smallmoney,
	@auto_spositiontaking_3 smallmoney,
	@auto_spositiontaking_4 smallmoney,
	@auto_spositiontaking_5 smallmoney,
	@auto_spositiontaking_6 smallmoney,
	@auto_spositiontaking_7 smallmoney,
	@auto_spositiontaking_8 smallmoney,
	@auto_spositiontaking_9 smallmoney,
	@auto_spositiontaking_10 smallmoney,
	
	@auto_slivepositiontaking_1 smallmoney,
	@auto_slivepositiontaking_3 smallmoney,
	@auto_slivepositiontaking_7 smallmoney,
	@auto_slivepositiontaking_8 smallmoney,
	
	@auto_v2spositiontaking_1 smallmoney,
	@auto_v2spositiontaking_2 smallmoney,
	@auto_v2spositiontaking_3 smallmoney,
	@auto_v2spositiontaking_7 smallmoney,
	@auto_v2spositiontaking_8 smallmoney,
	--@auto_v2spositiontaking_9 smallmoney,
	@auto_v2spositiontaking_20 smallmoney,

	@auto_v3spositiontaking_1 smallmoney,
	@auto_v3spositiontaking_2 smallmoney,
	@auto_v3spositiontaking_3 smallmoney,
	@auto_v3spositiontaking_20 smallmoney,

	@auto_v5spositiontaking_1 smallmoney,
	@auto_v5spositiontaking_2 smallmoney,
	@auto_v5spositiontaking_3 smallmoney,
	@auto_v5spositiontaking_20 smallmoney,

	@auto_v8spositiontaking_1 smallmoney,
	@auto_v8spositiontaking_3 smallmoney,
	@auto_v8spositiontaking_20 smallmoney,

	@auto_v10spositiontaking_1 smallmoney,
	@auto_v10spositiontaking_2 smallmoney,
	@auto_v10spositiontaking_3 smallmoney,
	@auto_v10spositiontaking_20 smallmoney,

	@auto_v11spositiontaking_1 smallmoney,
	@auto_v11spositiontaking_20 smallmoney,

	@auto_v99spositiontaking_1 smallmoney,
	@auto_v99spositiontaking_2 smallmoney,
	@auto_v99spositiontaking_3 smallmoney,
	@auto_v99spositiontaking_9 smallmoney,
	@auto_v99spositiontaking_20 smallmoney,

	
	
	@auto_v161spositiontaking_81 smallmoney,
	@auto_v161spositiontaking_83 smallmoney,
	@auto_v161spositiontaking_86 smallmoney,
	@auto_v161spositiontaking_88 smallmoney,
	@auto_v161slivepositiontaking_85 smallmoney,
	@auto_v161slivepositiontaking_86 smallmoney,
	@auto_v161slivepositiontaking_87 smallmoney,
	@auto_v161slivepositiontaking_89 smallmoney,
	@auto_v161slivepositiontaking_90 smallmoney,
	

	@auto_v151spositiontaking_31 smallmoney,
	@auto_v151spositiontaking_32 smallmoney,
	@auto_v151spositiontaking_41 smallmoney,
	@auto_v151spositiontaking_42 smallmoney,
	@auto_v151spositiontaking_51 smallmoney,
	@auto_v151spositiontaking_52 smallmoney,
	
	@auto_v152spositiontaking_41 smallmoney,
	@auto_v152spositiontaking_42 smallmoney,
	@auto_v152spositiontaking_51 smallmoney,
	@auto_v152spositiontaking_52 smallmoney,
	
	@auto_v153spositiontaking_51 smallmoney,
	@auto_v153spositiontaking_52 smallmoney,
			
	@auto_v201spositiontaking_2 smallmoney,
	@auto_v201spositiontaking_3 smallmoney,
	
	@auto_v162spositiontaking_1101 smallmoney,
	
	@auto_v180spositiontaking_1201 smallmoney,
	--s4
	@max_spositiontaking_1 smallmoney,
	@max_spositiontaking_2 smallmoney,
	@max_spositiontaking_3 smallmoney,
	@max_spositiontaking_4 smallmoney,
	@max_spositiontaking_5 smallmoney,
	@max_spositiontaking_6 smallmoney,
	@max_spositiontaking_7 smallmoney,
	@max_spositiontaking_8 smallmoney,
	@max_spositiontaking_9 smallmoney,
	@max_spositiontaking_10 smallmoney,
	@max_slivepositiontaking_1 smallmoney,
	@max_slivepositiontaking_3 smallmoney,
	@max_slivepositiontaking_7 smallmoney,
	@max_slivepositiontaking_8 smallmoney,
	
	@max_v2spositiontaking_1 smallmoney,
	@max_v2spositiontaking_2 smallmoney,
	@max_v2spositiontaking_3 smallmoney,
	@max_v2spositiontaking_7 smallmoney,
	@max_v2spositiontaking_8 smallmoney,
	--@max_v2spositiontaking_9 smallmoney,
	@max_v2spositiontaking_20 smallmoney,

	@max_v3spositiontaking_1 smallmoney,
	@max_v3spositiontaking_2 smallmoney,
	@max_v3spositiontaking_3 smallmoney,
	@max_v3spositiontaking_20 smallmoney,

	@max_v5spositiontaking_1 smallmoney,
	@max_v5spositiontaking_2 smallmoney,
	@max_v5spositiontaking_3 smallmoney,
	@max_v5spositiontaking_20 smallmoney,

	@max_v8spositiontaking_1 smallmoney,
	@max_v8spositiontaking_3 smallmoney,
	@max_v8spositiontaking_20 smallmoney,

	@max_v10spositiontaking_1 smallmoney,
	@max_v10spositiontaking_2 smallmoney,
	@max_v10spositiontaking_3 smallmoney,
	@max_v10spositiontaking_20 smallmoney,

	@max_v11spositiontaking_1 smallmoney,
	@max_v11spositiontaking_20 smallmoney,

	@max_v99spositiontaking_1 smallmoney,
	@max_v99spositiontaking_2 smallmoney,
	@max_v99spositiontaking_3 smallmoney,
	@max_v99spositiontaking_9 smallmoney,
	@max_v99spositiontaking_20 smallmoney,

	
	@max_v161spositiontaking_81 smallmoney,
	@max_v161spositiontaking_83 smallmoney,
	@max_v161spositiontaking_86 smallmoney,
	@max_v161spositiontaking_88 smallmoney,
	@max_v161slivepositiontaking_85 smallmoney,
	@max_v161slivepositiontaking_86 smallmoney,
	@max_v161slivepositiontaking_87 smallmoney,
	@max_v161slivepositiontaking_89 smallmoney,
	@max_v161slivepositiontaking_90 smallmoney,
	
	
	@max_v151spositiontaking_31 smallmoney,
	@max_v151spositiontaking_32 smallmoney,
	@max_v151spositiontaking_41 smallmoney,
	@max_v151spositiontaking_42 smallmoney,
	@max_v151spositiontaking_51 smallmoney,
	@max_v151spositiontaking_52 smallmoney,
	
	@max_v152spositiontaking_41 smallmoney,
	@max_v152spositiontaking_42 smallmoney,
	@max_v152spositiontaking_51 smallmoney,
	@max_v152spositiontaking_52 smallmoney,
	
	@max_v153spositiontaking_51 smallmoney,
	@max_v153spositiontaking_52 smallmoney,
			
	@max_v201spositiontaking_2 smallmoney,
	@max_v201spositiontaking_3 smallmoney,
	
	@max_v162spositiontaking_1101 smallmoney,
	
	@max_v180spositiontaking_1201 smallmoney,
--	@maxdownlinepos smallmoney,
	--i3
	@isauto_spositiontaking_1 bit,
	@isauto_spositiontaking_2 bit,
	@isauto_spositiontaking_3 bit,
	@isauto_spositiontaking_4 bit,
	@isauto_spositiontaking_5 bit,
	@isauto_spositiontaking_6 bit,
	@isauto_spositiontaking_7 bit,
	@isauto_spositiontaking_8 bit,
	@isauto_spositiontaking_9 bit,
	@isauto_spositiontaking_10 bit,
	
	@isauto_slivepositiontaking_1 bit,
	@isauto_slivepositiontaking_3 bit,
	@isauto_slivepositiontaking_7 bit,
	@isauto_slivepositiontaking_8 bit,
	
	@isauto_v2spositiontaking_1 bit,
	@isauto_v2spositiontaking_2 bit,
	@isauto_v2spositiontaking_3 bit,
	@isauto_v2spositiontaking_7 bit,
	@isauto_v2spositiontaking_8 bit,
	--@isauto_v2spositiontaking_9 bit,
	@isauto_v2spositiontaking_20 bit,

	@isauto_v3spositiontaking_1 bit,
	@isauto_v3spositiontaking_2 bit,
	@isauto_v3spositiontaking_3 bit,
	@isauto_v3spositiontaking_20 bit,

	@isauto_v5spositiontaking_1 bit,
	@isauto_v5spositiontaking_2 bit,
	@isauto_v5spositiontaking_3 bit,
	@isauto_v5spositiontaking_20 bit,

	@isauto_v8spositiontaking_1 bit,
	@isauto_v8spositiontaking_3 bit,
	@isauto_v8spositiontaking_20 bit,

	@isauto_v10spositiontaking_1 bit,
	@isauto_v10spositiontaking_2 bit,
	@isauto_v10spositiontaking_3 bit,
	@isauto_v10spositiontaking_20 bit,

	@isauto_v11spositiontaking_1 bit,
	@isauto_v11spositiontaking_20 bit,

	@isauto_v99spositiontaking_1 bit,
	@isauto_v99spositiontaking_2 bit,
	@isauto_v99spositiontaking_3 bit,
	@isauto_v99spositiontaking_9 bit,
	@isauto_v99spositiontaking_20 bit,
	
	
	@isauto_v161spositiontaking_81 bit,
	@isauto_v161spositiontaking_83 bit,
	@isauto_v161spositiontaking_86 bit,
	@isauto_v161spositiontaking_88 bit,
	@isauto_v161slivepositiontaking_85 bit,
	@isauto_v161slivepositiontaking_86 bit,
	@isauto_v161slivepositiontaking_87 bit,
	@isauto_v161slivepositiontaking_89 bit,
	@isauto_v161slivepositiontaking_90 bit,
	
	
	@isauto_v151spositiontaking_31 bit,
	@isauto_v151spositiontaking_32 bit,
	@isauto_v151spositiontaking_41 bit,
	@isauto_v151spositiontaking_42 bit,
	@isauto_v151spositiontaking_51 bit,
	@isauto_v151spositiontaking_52 bit,
	
	@isauto_v152spositiontaking_41 bit,
	@isauto_v152spositiontaking_42 bit,
	@isauto_v152spositiontaking_51 bit,
	@isauto_v152spositiontaking_52 bit,
	
	@isauto_v153spositiontaking_51 bit,
	@isauto_v153spositiontaking_52 bit,
		
	@isauto_v201spositiontaking_2 bit,
	@isauto_v201spositiontaking_3 bit,
	
	@isauto_v162spositiontaking_1101 bit,
	
	@isauto_v180spositiontaking_1201 bit,
	--min(a2,a4)
	@max_apositiontaking_1 smallmoney,
	@max_apositiontaking_2 smallmoney,
	@max_apositiontaking_3 smallmoney,
	@max_apositiontaking_4 smallmoney,
	@max_apositiontaking_5 smallmoney,
	@max_apositiontaking_6 smallmoney,
	@max_apositiontaking_7 smallmoney,
	@max_apositiontaking_8 smallmoney,
	@max_apositiontaking_9 smallmoney,
	@max_apositiontaking_10 smallmoney,
	@max_alivepositiontaking_1 smallmoney,
	@max_alivepositiontaking_3 smallmoney,
	@max_alivepositiontaking_7 smallmoney,
	@max_alivepositiontaking_8 smallmoney,
	
	@max_v2apositiontaking_1 smallmoney,
	@max_v2apositiontaking_2 smallmoney,
	@max_v2apositiontaking_3 smallmoney,
	@max_v2apositiontaking_7 smallmoney,
	@max_v2apositiontaking_8 smallmoney,
	--@max_v2apositiontaking_9 smallmoney,
	@max_v2apositiontaking_20 smallmoney,
	
	@max_v3apositiontaking_1 smallmoney,
	@max_v3apositiontaking_2 smallmoney,
	@max_v3apositiontaking_3 smallmoney,
	@max_v3apositiontaking_20 smallmoney,

	@max_v5apositiontaking_1 smallmoney,
	@max_v5apositiontaking_2 smallmoney,
	@max_v5apositiontaking_3 smallmoney,
	@max_v5apositiontaking_20 smallmoney,

	@max_v8apositiontaking_1 smallmoney,
	@max_v8apositiontaking_3 smallmoney,
	@max_v8apositiontaking_20 smallmoney,

	@max_v10apositiontaking_1 smallmoney,
	@max_v10apositiontaking_2 smallmoney,
	@max_v10apositiontaking_3 smallmoney,
	@max_v10apositiontaking_20 smallmoney,

	@max_v11apositiontaking_1 smallmoney,
	@max_v11apositiontaking_20 smallmoney,

	@max_v99apositiontaking_1 smallmoney,
	@max_v99apositiontaking_2 smallmoney,
	@max_v99apositiontaking_3 smallmoney,
	@max_v99apositiontaking_9 smallmoney,
	@max_v99apositiontaking_20 smallmoney,	
	
	
	@max_v161apositiontaking_81 smallmoney,
	@max_v161apositiontaking_83 smallmoney,
	@max_v161apositiontaking_86 smallmoney,
	@max_v161apositiontaking_88 smallmoney,
	@max_v161alivepositiontaking_85 smallmoney,
	@max_v161alivepositiontaking_86 smallmoney,
	@max_v161alivepositiontaking_87 smallmoney,
	@max_v161alivepositiontaking_89 smallmoney,
	@max_v161alivepositiontaking_90 smallmoney,
	
	--v162 copy a2 to a1
	@v162apositiontaking_1101 smallmoney,	
	
	@v180apositiontaking_1201 smallmoney,
	--Master auto positiontaking
	
	--m3
	@max_mpositiontaking_1 smallmoney,
	@max_mpositiontaking_2 smallmoney,
	@max_mpositiontaking_3 smallmoney,
	@max_mpositiontaking_4 smallmoney,
	@max_mpositiontaking_5 smallmoney,
	@max_mpositiontaking_6 smallmoney,
	@max_mpositiontaking_7 smallmoney,
	@max_mpositiontaking_8 smallmoney,
	@max_mpositiontaking_9 smallmoney,
	@max_mpositiontaking_10 smallmoney,
	@max_mlivepositiontaking_1 smallmoney,
	@max_mlivepositiontaking_3 smallmoney,
	@max_mlivepositiontaking_7 smallmoney,
	@max_mlivepositiontaking_8 smallmoney,
	
	@max_v2mpositiontaking_1 smallmoney,
	@max_v2mpositiontaking_2 smallmoney,
	@max_v2mpositiontaking_3 smallmoney,
	@max_v2mpositiontaking_7 smallmoney,
	@max_v2mpositiontaking_8 smallmoney,
	--@max_v2mpositiontaking_9 smallmoney,
	@max_v2mpositiontaking_20 smallmoney,

	@max_v3mpositiontaking_1 smallmoney,
	@max_v3mpositiontaking_2 smallmoney,
	@max_v3mpositiontaking_3 smallmoney,
	@max_v3mpositiontaking_20 smallmoney,

	@max_v5mpositiontaking_1 smallmoney,
	@max_v5mpositiontaking_2 smallmoney,
	@max_v5mpositiontaking_3 smallmoney,
	@max_v5mpositiontaking_20 smallmoney,

	@max_v8mpositiontaking_1 smallmoney,
	@max_v8mpositiontaking_3 smallmoney,
	@max_v8mpositiontaking_20 smallmoney,

	@max_v10mpositiontaking_1 smallmoney,
	@max_v10mpositiontaking_2 smallmoney,
	@max_v10mpositiontaking_3 smallmoney,
	@max_v10mpositiontaking_20 smallmoney,

	@max_v11mpositiontaking_1 smallmoney,
	@max_v11mpositiontaking_20 smallmoney,

	@max_v99mpositiontaking_1 smallmoney,
	@max_v99mpositiontaking_2 smallmoney,
	@max_v99mpositiontaking_3 smallmoney,
	@max_v99mpositiontaking_9 smallmoney,
	@max_v99mpositiontaking_20 smallmoney,

	
	@max_v161mpositiontaking_81 smallmoney,
	@max_v161mpositiontaking_83 smallmoney,
	@max_v161mpositiontaking_86 smallmoney,
	@max_v161mpositiontaking_88 smallmoney,
	@max_v161mlivepositiontaking_85 smallmoney,
	@max_v161mlivepositiontaking_86 smallmoney,
	@max_v161mlivepositiontaking_87 smallmoney,
	@max_v161mlivepositiontaking_89 smallmoney,
	@max_v161mlivepositiontaking_90 smallmoney,
	

	@max_v151mpositiontaking_31 smallmoney,
	@max_v151mpositiontaking_32 smallmoney,
	@max_v151mpositiontaking_41 smallmoney,
	@max_v151mpositiontaking_42 smallmoney,
	@max_v151mpositiontaking_51 smallmoney,
	@max_v151mpositiontaking_52 smallmoney,
	
	@max_v152mpositiontaking_41 smallmoney,
	@max_v152mpositiontaking_42 smallmoney,
	@max_v152mpositiontaking_51 smallmoney,
	@max_v152mpositiontaking_52 smallmoney,
	
	@max_v153mpositiontaking_51 smallmoney,
	@max_v153mpositiontaking_52 smallmoney,
	
	@max_v201mpositiontaking_2 smallmoney,
	@max_v201mpositiontaking_3 smallmoney,
	
	@max_v162mpositiontaking_1101 smallmoney,
	
	@max_v180mpositiontaking_1201 smallmoney,
	--u2
	@auto_mpositiontaking_1 smallmoney,
	@auto_mpositiontaking_2 smallmoney,
	@auto_mpositiontaking_3 smallmoney,
	@auto_mpositiontaking_4 smallmoney,
	@auto_mpositiontaking_5 smallmoney,
	@auto_mpositiontaking_6 smallmoney,
	@auto_mpositiontaking_7 smallmoney,
	@auto_mpositiontaking_8 smallmoney,
	@auto_mpositiontaking_9 smallmoney,
	@auto_mpositiontaking_10 smallmoney,
	
	@auto_mlivepositiontaking_1 smallmoney,
	@auto_mlivepositiontaking_3 smallmoney,
	@auto_mlivepositiontaking_7 smallmoney,
	@auto_mlivepositiontaking_8 smallmoney,
	
	@auto_v2mpositiontaking_1 smallmoney,
	@auto_v2mpositiontaking_2 smallmoney,
	@auto_v2mpositiontaking_3 smallmoney,
	@auto_v2mpositiontaking_7 smallmoney,
	@auto_v2mpositiontaking_8 smallmoney,
	--@auto_v2mpositiontaking_9 smallmoney,
	@auto_v2mpositiontaking_20 smallmoney,

	@auto_v3mpositiontaking_1 smallmoney,
	@auto_v3mpositiontaking_2 smallmoney,
	@auto_v3mpositiontaking_3 smallmoney,
	@auto_v3mpositiontaking_20 smallmoney,

	@auto_v5mpositiontaking_1 smallmoney,
	@auto_v5mpositiontaking_2 smallmoney,
	@auto_v5mpositiontaking_3 smallmoney,
	@auto_v5mpositiontaking_20 smallmoney,

	@auto_v8mpositiontaking_1 smallmoney,
	@auto_v8mpositiontaking_3 smallmoney,
	@auto_v8mpositiontaking_20 smallmoney,

	@auto_v10mpositiontaking_1 smallmoney,
	@auto_v10mpositiontaking_2 smallmoney,
	@auto_v10mpositiontaking_3 smallmoney,
	@auto_v10mpositiontaking_20 smallmoney,

	@auto_v11mpositiontaking_1 smallmoney,
	@auto_v11mpositiontaking_20 smallmoney,

	@auto_v99mpositiontaking_1 smallmoney,
	@auto_v99mpositiontaking_2 smallmoney,
	@auto_v99mpositiontaking_3 smallmoney,
	@auto_v99mpositiontaking_9 smallmoney,
	@auto_v99mpositiontaking_20 smallmoney,

	
	@auto_v161mpositiontaking_81 smallmoney,
	@auto_v161mpositiontaking_83 smallmoney,
	@auto_v161mpositiontaking_86 smallmoney,
	@auto_v161mpositiontaking_88 smallmoney,
	@auto_v161mlivepositiontaking_85 smallmoney,
	@auto_v161mlivepositiontaking_86 smallmoney,
	@auto_v161mlivepositiontaking_87 smallmoney,
	@auto_v161mlivepositiontaking_89 smallmoney,
	@auto_v161mlivepositiontaking_90 smallmoney,
	

	@auto_v151mpositiontaking_31 smallmoney,
	@auto_v151mpositiontaking_32 smallmoney,
	@auto_v151mpositiontaking_41 smallmoney,
	@auto_v151mpositiontaking_42 smallmoney,
	@auto_v151mpositiontaking_51 smallmoney,
	@auto_v151mpositiontaking_52 smallmoney,
	
	@auto_v152mpositiontaking_41 smallmoney,
	@auto_v152mpositiontaking_42 smallmoney,
	@auto_v152mpositiontaking_51 smallmoney,
	@auto_v152mpositiontaking_52 smallmoney,
	
	@auto_v153mpositiontaking_51 smallmoney,
	@auto_v153mpositiontaking_52 smallmoney,
			
	@auto_v201mpositiontaking_2 smallmoney,
	@auto_v201mpositiontaking_3 smallmoney,
	
	@auto_v162mpositiontaking_1101 smallmoney,
	
	@auto_v180mpositiontaking_1201 smallmoney,
	--i2
	@isauto_mpositiontaking_1 bit,
	@isauto_mpositiontaking_2 bit,
	@isauto_mpositiontaking_3 bit,
	@isauto_mpositiontaking_4 bit,
	@isauto_mpositiontaking_5 bit,
	@isauto_mpositiontaking_6 bit,
	@isauto_mpositiontaking_7 bit,
	@isauto_mpositiontaking_8 bit,
	@isauto_mpositiontaking_9 bit,
	@isauto_mpositiontaking_10 bit,
	
	@isauto_mlivepositiontaking_1 bit,
	@isauto_mlivepositiontaking_3 bit,
	@isauto_mlivepositiontaking_7 bit,
	@isauto_mlivepositiontaking_8 bit,
	
	@isauto_v2mpositiontaking_1 bit,
	@isauto_v2mpositiontaking_2 bit,
	@isauto_v2mpositiontaking_3 bit,
	@isauto_v2mpositiontaking_7 bit,
	@isauto_v2mpositiontaking_8 bit,
	--@isauto_v2mpositiontaking_9 bit,
	@isauto_v2mpositiontaking_20 bit,

	@isauto_v3mpositiontaking_1 bit,
	@isauto_v3mpositiontaking_2 bit,
	@isauto_v3mpositiontaking_3 bit,
	@isauto_v3mpositiontaking_20 bit,

	@isauto_v5mpositiontaking_1 bit,
	@isauto_v5mpositiontaking_2 bit,
	@isauto_v5mpositiontaking_3 bit,
	@isauto_v5mpositiontaking_20 bit,

	@isauto_v8mpositiontaking_1 bit,
	@isauto_v8mpositiontaking_3 bit,
	@isauto_v8mpositiontaking_20 bit,

	@isauto_v10mpositiontaking_1 bit,
	@isauto_v10mpositiontaking_2 bit,
	@isauto_v10mpositiontaking_3 bit,
	@isauto_v10mpositiontaking_20 bit,

	@isauto_v11mpositiontaking_1 bit,
	@isauto_v11mpositiontaking_20 bit,

	@isauto_v99mpositiontaking_1 bit,
	@isauto_v99mpositiontaking_2 bit,
	@isauto_v99mpositiontaking_3 bit,
	@isauto_v99mpositiontaking_9 bit,
	@isauto_v99mpositiontaking_20 bit,
	
	
	@isauto_v161mpositiontaking_81 bit,
	@isauto_v161mpositiontaking_83 bit,
	@isauto_v161mpositiontaking_86 bit,
	@isauto_v161mpositiontaking_88 bit,
	@isauto_v161mlivepositiontaking_85 bit,
	@isauto_v161mlivepositiontaking_86 bit,
	@isauto_v161mlivepositiontaking_87 bit,
	@isauto_v161mlivepositiontaking_89 bit,
	@isauto_v161mlivepositiontaking_90 bit,
	
	
	@isauto_v151mpositiontaking_31 bit,
	@isauto_v151mpositiontaking_32 bit,
	@isauto_v151mpositiontaking_41 bit,
	@isauto_v151mpositiontaking_42 bit,
	@isauto_v151mpositiontaking_51 bit,
	@isauto_v151mpositiontaking_52 bit,
	
	@isauto_v152mpositiontaking_41 bit,
	@isauto_v152mpositiontaking_42 bit,
	@isauto_v152mpositiontaking_51 bit,
	@isauto_v152mpositiontaking_52 bit,
	
	@isauto_v153mpositiontaking_51 bit,
	@isauto_v153mpositiontaking_52 bit,
		
	@isauto_v201mpositiontaking_2 bit,
	@isauto_v201mpositiontaking_3 bit,
	
	@isauto_v162mpositiontaking_1101 bit,
	
	@isauto_v180mpositiontaking_1201 BIT,

	@matchlimit smallmoney,
	@discount decimal(9,8),
	@discountcs decimal(9,8),
	@virtualmultiplier smallmoney
	
declare @ErrType varchar(4000)	
declare @v151playerdiscount_31 decimal(9,8),
		@v151playerdiscount_41 decimal(9,8),
		@v151playerdiscount_51 decimal(9,8),
		@v152playerdiscount_41 decimal(9,8),
		@v152playerdiscount_51 decimal(9,8),
		@v153playerdiscount_51 decimal(9,8)
select	@v151playerdiscount_31 = 0, @v151playerdiscount_41 =0,@v151playerdiscount_51 =0,
		@v152playerdiscount_41 = 0, @v152playerdiscount_51 =0,@v153playerdiscount_51 = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Select @maxpos = 0.7, @maxdownlinepos = 0.7
--Select @adiscount = case when @ugroup in ('a','hka') then 0.0025 when @ugroup in ('b','hkb') then 0.005 when @ugroup in ('c','hkc') then 0.0075 else 0.01 end, @adiscountcs=0.05
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
	@currency = currency, 
	@mrecommend = mrecommend, 
	@srecommend = srecommend, 
	@AgentCredit = IsNull(Credit, 0),
	@UplineSyncLiveCasino = SyncLiveCasino,
--	@MaxCredit_Mem = isnull(maxcredit,0), 
--	@AgentMaxPerMatch = IsNull(MaxPerMatch, 0),
--	@AgentMaxPerMatchb = IsNull(MaxPerMatchb, 0),
	@Asuspended = reject,
	@UplineClosed = closed,
	@matchlimit = matchlimit,
	@AgentDanger = Danger,
	@AgentDanger2 = Danger2,
	@AgentDanger3 = Danger3,
	@AgentAbnormal = Abnormal,
	@MaxPerMatchv180 = MaxPerMatch180,
	@Disable151_31 = case when DisableHorseRacing = 1 then 1 else @Disable151_31 end,
	@Disable151_41 = case when DisableOpenTote = 1 then 1 else @Disable151_41 end,
	@Disable151_51 = case when Disable151_AU = 1 then 1 else @Disable151_51 end,  
	@Disable152_41 = case when Disable152_UK = 1 then 1 else @Disable152_41 end,  
	@Disable152_51 = case when Disable152_AU = 1 then 1 else @Disable152_51 end,  
	@Disable153_51 = case when Disable153_AU = 1 then 1 else @Disable153_51 end,
	@DisableFinancial = case when DisableFinancial = 1 then 1 else @DisableFinancial end,	
	@DisableCasino = case when DisableCasino = 1 then 1 else @DisableCasino end,
	@DisableOutright = DisableOutright ,
	@DisableBingo = case when DisableBingo = 1 then 1 else @DisableBingo end,
	@DisableNumber = case when DisableNumber = 1 then 1 else @DisableNumber end,
	@DisableP2P = case when DisableP2P = 1 then 1 else @DisableP2P end,
	@DisableFUNP2P = case when DisableFUNP2P = 1 then 1 else @DisableFUNP2P end,
	@Disable162_1101 = case when DisableLiveCasino = 1 then 1 else @Disable162_1101 end,
	@Disable180_1201 = DisableVirtualSports,
	@HideVirtualSports = HideVirtualSports,
	@virtualmultiplier = ISNULL(virtualmultiplier,1),
	@MaxWinLiveCasino = MaxWinLiveCasino,
	@isAutoResetLiveCasino = isAutoResetLiveCasino
from custinfo with (NOLOCK) where CustID = @recommend

--Use maxcredit in CustAgent table 
select @MaxCredit_Mem = isnull(maxcredit,0) from custAgent with (NOLOCK)  where CustID = @recommend

Select @ErrCode = 0
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @IsValid bit
EXEC dbo.Acc_CustomerInsMember_Ag_CheckParam 
	@playerdiscount=@playerdiscount,
	@playerdiscountcs=@playerdiscountcs,
	@playerdiscount1x2 = @playerdiscount1x2,--1x2
	@playerdiscountnumber = @playerdiscountnumber,
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
	
	@MinBetv99MP = @MinBetv99MP,
	@MaxBetv99MP = @MaxBetv99MP,
	@MaxPerMatchv99MP = @MaxPerMatchv99MP,
	
	@MinBetv161 = @MinBetv161,
	@MaxBetv161 = @MaxBetv161,
	@MaxPerBallv161 = @MaxPerBallv161,
	@MaxPerMatchv161 = @MaxPerMatchv161,

	@credit=@credit,
	@recommend=@recommend,
	@ugroup=@ugroup,
	
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
	@alivepositiontaking_1=@alivepositiontaking_1,
	@alivepositiontaking_3=@alivepositiontaking_3,
	@alivepositiontaking_7=@alivepositiontaking_7,
	@alivepositiontaking_8=@alivepositiontaking_8,
	
	@v2apositiontaking_1=@v2apositiontaking_1,
	@v2apositiontaking_2=@v2apositiontaking_2,
	@v2apositiontaking_3=@v2apositiontaking_3,
	@v2apositiontaking_7=@v2apositiontaking_7,
	@v2apositiontaking_8=@v2apositiontaking_8,
	--@v2apositiontaking_9=@v2apositiontaking_9,
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
	@v99apositiontaking_9 = @v99apositiontaking_9,
	@v99apositiontaking_20=@v99apositiontaking_20,
	
	
	@v161apositiontaking_81 = @v161apositiontaking_81,
	@v161apositiontaking_83 = @v161apositiontaking_83,
	@v161apositiontaking_86 = @v161apositiontaking_86,
	@v161apositiontaking_88 = @v161apositiontaking_88,
	@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
	@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
	@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
	@v161alivepositiontaking_89 = @v161alivepositiontaking_89,
	@v161alivepositiontaking_90 = @v161alivepositiontaking_90,
	
	
	@isvalid=@isvalid OUTPUT,
	@errmsg=@ErrMsg OUTPUT,
	@errcode=@errcode OUTPUT,
	@language=@language

if @IsValid = 0
BEGIN
	return
END

--Check member group under Won currency
IF @currency = 45 AND @ugroup NOT IN ('dea','deb','dec','ded')-- Won currency
	BEGIN
		SELECT @ErrMsg = CASE @Language
							WHEN 'E' THEN 'Unable to assign this group to the customer.'
							WHEN 'CS' THEN N'Unable to assign this group to the customer.'
							WHEN 'CT' THEN N'Unable to assign this group to the customer.'
							WHEN 'TH' THEN N'Unable to assign this group to the customer.'
							WHEN 'J' THEN N'Unable to assign this group to the customer.'
							WHEN 'KO' THEN N'Unable to assign this group to the customer.'
							ELSE N'Unable to assign this group to the customer.'
							END,
				@Success = 0, @ErrCode = 300
		return			
	END
	
IF @currency <> 45 AND @ugroup IN ('dea','deb','dec','ded') -- Others currency
	BEGIN
		SELECT @ErrMsg = CASE @Language
							WHEN 'E' THEN 'Unable to assign this group to the customer.'
							WHEN 'CS' THEN N'Unable to assign this group to the customer.'
							WHEN 'CT' THEN N'Unable to assign this group to the customer.'
							WHEN 'TH' THEN N'Unable to assign this group to the customer.'
							WHEN 'J' THEN N'Unable to assign this group to the customer.'
							WHEN 'KO' THEN N'Unable to assign this group to the customer.'
							ELSE N'Unable to assign this group to the customer.'
							END,
				@Success = 0, @ErrCode = 301
		return			
	END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select @success = 0, @username = rtrim(ltrim(@username))
--@username = replace(@username, ' ', '')

select @site=case when @ugroup like 'indo_' then 'INDO' else '' end, @ugroup = case when @ugroup like 'indo_' then right(@ugroup,1) else @ugroup end

if exists(select 1 from customer with (NOLOCK) where username= @username)
	or exists (select 1 from customer with (NOLOCK) where username2 = @username)
	or exists(select 1 from custsub with (NOLOCK) where username= @username) 
BEGIN
	Select @ErrMsg = case @Language 
							when 'E' then 'This username is not available.'
							when 'CS' then N'此账号无效.'
							when 'CT' then N'此帳號無效.'
							when 'TH' then N'ชื่อที่ใช้ในการเข้าระบบนี้ ไม่สามารถใช้งานได้.'
							when 'J' then N'ID確認できません。'
							when 'ES' then N'Este nombre de usuario no está disponible.'
							when 'KO' then N'이 사용자 이름을 사용할 수 없습니다.'
							else N'This username is not available.'
						end		
			, @success = 0, @ErrCode = 201
	return
END

select @ErrType = ''
select @ErrType = @ErrType +  (case when MP=0 then sportname else 'Mixed Sports' end )       + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype,0 as MP, @MinBet as MinBet, @MaxBet as MaxBet, @MaxPerMatch as MaxPerMatch
	union all	select 2 as sporttype,0 as MP, @MinBetv2 as MinBet, @MaxBetv2 as MaxBet, @MaxPerMatchv2 as MaxPerMatch
	union all	select 3 as sporttype,0 as MP, @MinBetv3 as MinBet, @MaxBetv3 as MaxBet, @MaxPerMatchv3 as MaxPerMatch
	union all	select 5 as sporttype,0 as MP, @MinBetv5 as MinBet, @MaxBetv5 as MaxBet, @MaxPerMatchv5 as MaxPerMatch
	union all	select 8 as sporttype,0 as MP, @MinBetv8 as MinBet, @MaxBetv8 as MaxBet, @MaxPerMatchv8 as MaxPerMatch
	union all	select 10 as sporttype,0 as MP, @MinBetv10 as MinBet, @MaxBetv10 as MaxBet, @MaxPerMatchv10 as MaxPerMatch
	union all	select 11 as sporttype,0 as MP, @MinBetv11 as MinBet, @MaxBetv11 as MaxBet, @MaxPerMatchv11 as MaxPerMatch
	union all	select 99 as sporttype,0 as MP, @MinBetv99 as MinBet, @MaxBetv99 as MaxBet, @MaxPerMatchv99 as MaxPerMatch	 
	union all	select 99 as sporttype,1 as MP, @MinBetv99MP as MinBet, @MaxBetv99MP as MaxBet, @MaxPerMatchv99MP as MaxPerMatch	 
	union all	select 161 as sporttype,0 as MP, @MinBetv161 as MinBet, @MaxBetv161 as MaxBet, @MaxPerMatchv161 as MaxPerMatch	 
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
							when 'J' then N'最小ベットは、スーパー/マスターエージェントの設定値と同等かそれ以上で無ければなりません。('+@ErrType+').'
							when 'ES' then N'Lo lamentamos, la apuesta mínima debe ser menor que la apuestas máxima, y la apuesta máxima debe ser menor que la apuesta máxima por partido ('+@ErrType+').'
							when 'KO' then N'죄송합니다, 최소 배팅은 최대 배팅보다 작아야 하고  최대 배팅은 경기당 최대 배팅보다 작아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be less than max bet and max bet must be less than max per match ('+@ErrType+').'
					end		
					+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch),
		@success = 0, @ErrCode = 202
	return
END

--SELECT @ErrType = ''
--SELECT @ErrType = @ErrType +sportname
--FROM sports WITH (NOLOCK) 
--WHERE sporttype = 161 AND ((@MaxBetv161 <> 0 AND @MaxPerBallv161 <>0 AND @MaxBetv161 >@MaxPerBallv161)
--OR (@MaxPerBallv161 <> 0 AND @MaxPerMatchv161 <> 0 AND @MaxPerBallv161 > @MaxPerMatchv161))
--
--IF @ErrType <> ''
--BEGIN
--	SELECT
--		@ErrMsg =	case @Language 
--							when 'E' then 'Sorry, max per ball must be greater than or equal to max bet and less than or equal to Max Per Match('+@ErrType+').'
--							when 'CS' then N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注('+@ErrType+').'
--							when 'CT' then N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注 ('+@ErrType+').'
--							when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน ('+@ErrType+').'
--							when 'J' then N'Sorry, max per ball must be greater than or equal to max bet and less than or equal to Max Per Match('+@ErrType+').'
--							when 'ES' then N'Sorry, max per ball must be greater than or equal to max bet and less than or equal to Max Per Match('+@ErrType+').'
--							when 'KO' then N'Sorry, max per ball must be greater than or equal to max bet and less than or equal to Max Per Match('+@ErrType+').'
--							else N'Sorry, max per ball must be greater than or equal to max bet and less than or equal to Max Per Match('+@ErrType+').'
--					end		
--					+ char(13) + char(10) + convert(varchar(20), @MaxBetv161) + '-' + convert(varchar(20), @MaxPerBallv161) + '-' + convert(varchar(20), @MaxPerMatchv161),
--		@success = 0, @ErrCode = 202
--	RETURN	
--END



--a2,m2,u2,i2
select @max_apositiontaking_1 = apositiontaking, @max_alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @auto_mpositiontaking_1 = autompositiontaking, @auto_mlivepositiontaking_1 = autolivempositiontaking, @isauto_mpositiontaking_1 = isautompositiontaking, @isauto_mlivepositiontaking_1 = isautolivempositiontaking, @minMinBet = MinBet, @maxMaxBet = MaxBet, @discount = case when @ugroup in ('a','hka','dea') then groupa when @ugroup in ('b','hkb','deb') then groupb when @ugroup in ('c','hkc','dec') then groupc else groupd end from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1
--select @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @minMinBet = MinBet, @maxMaxBet = MaxBet, @maxdiscount = case when @ugroup in ('a','hka') then groupa when @ugroup in ('b','hkb') then groupb when @ugroup in ('c','hkc') then groupc else groupd end from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1
select @max_apositiontaking_3 = apositiontaking, @max_alivepositiontaking_3 = alivepositiontaking, @mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @auto_mpositiontaking_3 = autompositiontaking, @auto_mlivepositiontaking_3 = autolivempositiontaking, @isauto_mpositiontaking_3 = isautompositiontaking, @isauto_mlivepositiontaking_3 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=1
select @max_apositiontaking_7 = apositiontaking, @max_alivepositiontaking_7 = alivepositiontaking, @mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @auto_mpositiontaking_7 = autompositiontaking, @auto_mlivepositiontaking_7 = autolivempositiontaking, @isauto_mpositiontaking_7 = isautompositiontaking, @isauto_mlivepositiontaking_7 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=1
select @max_apositiontaking_8 = apositiontaking, @max_alivepositiontaking_8 = alivepositiontaking, @mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @auto_mpositiontaking_8 = autompositiontaking, @auto_mlivepositiontaking_8 = autolivempositiontaking, @isauto_mpositiontaking_8 = isautompositiontaking, @isauto_mlivepositiontaking_8 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=1
select @max_apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @auto_mpositiontaking_2 = autompositiontaking, @isauto_mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=1
select @max_apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @auto_mpositiontaking_4 = autompositiontaking, @isauto_mpositiontaking_4 = isautompositiontaking, @discountcs = discount from custsetting with (NOLOCK) where custid = @recommend and bettype=4 and sporttype=1
--select @mpositiontaking_4 = mpositiontaking, @maxdiscountcs = discount from custsetting with (NOLOCK) where custid = @recommend and bettype=4 and sporttype=1
select @max_apositiontaking_5 = apositiontaking, @mpositiontaking_5 = mpositiontaking, @auto_mpositiontaking_5 = autompositiontaking, @isauto_mpositiontaking_5 = isautompositiontaking, @discount1x2 = discount from custsetting with (NOLOCK) where custid = @recommend and bettype=5 and sporttype=1
select @max_apositiontaking_6 = apositiontaking, @mpositiontaking_6 = mpositiontaking, @auto_mpositiontaking_6 = autompositiontaking, @isauto_mpositiontaking_6 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=6 and sporttype=1
select @max_apositiontaking_9 = apositiontaking, @mpositiontaking_9 = mpositiontaking, @auto_mpositiontaking_9 = autompositiontaking, @isauto_mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=1
select @max_apositiontaking_10 = apositiontaking, @mpositiontaking_10 = mpositiontaking, @auto_mpositiontaking_10 = autompositiontaking, @isauto_mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=1

select @max_v2apositiontaking_1 = apositiontaking, @v2mpositiontaking_1 = mpositiontaking, @auto_v2mpositiontaking_1 = autompositiontaking, @isauto_v2mpositiontaking_1 = isautompositiontaking, @minMinBetv2 = MinBet, @maxMaxBetv2 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=2
select @max_v2apositiontaking_2 = apositiontaking, @v2mpositiontaking_2 = mpositiontaking, @auto_v2mpositiontaking_2 = autompositiontaking, @isauto_v2mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=2
select @max_v2apositiontaking_3 = apositiontaking, @v2mpositiontaking_3 = mpositiontaking, @auto_v2mpositiontaking_3 = autompositiontaking, @isauto_v2mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=2
select @max_v2apositiontaking_7 = apositiontaking, @v2mpositiontaking_7 = mpositiontaking, @auto_v2mpositiontaking_7 = autompositiontaking, @isauto_v2mpositiontaking_7 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=2
select @max_v2apositiontaking_8 = apositiontaking, @v2mpositiontaking_8 = mpositiontaking, @auto_v2mpositiontaking_8 = autompositiontaking, @isauto_v2mpositiontaking_8 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=2
--select @max_v2apositiontaking_9 = apositiontaking, @v2mpositiontaking_9 = mpositiontaking, @auto_v2mpositiontaking_9 = autompositiontaking, @isauto_v2mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=2
select @max_v2apositiontaking_20 = apositiontaking, @v2mpositiontaking_20 = mpositiontaking, @auto_v2mpositiontaking_20 = autompositiontaking, @isauto_v2mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=2

select @max_v3apositiontaking_1 = apositiontaking, @v3mpositiontaking_1 = mpositiontaking, @auto_v3mpositiontaking_1 = autompositiontaking, @isauto_v3mpositiontaking_1 = isautompositiontaking, @minMinBetv3 = MinBet, @maxMaxBetv3 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=3
select @max_v3apositiontaking_2 = apositiontaking, @v3mpositiontaking_2 = mpositiontaking, @auto_v3mpositiontaking_2 = autompositiontaking, @isauto_v3mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=3
select @max_v3apositiontaking_3 = apositiontaking, @v3mpositiontaking_3 = mpositiontaking, @auto_v3mpositiontaking_3 = autompositiontaking, @isauto_v3mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=3
select @max_v3apositiontaking_20 = apositiontaking, @v3mpositiontaking_20 = mpositiontaking, @auto_v3mpositiontaking_20 = autompositiontaking, @isauto_v3mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=3

select @max_v5apositiontaking_1 = apositiontaking, @v5mpositiontaking_1 = mpositiontaking, @auto_v5mpositiontaking_1 = autompositiontaking, @isauto_v5mpositiontaking_1 = isautompositiontaking, @minMinBetv5 = MinBet, @maxMaxBetv5 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=5
select @max_v5apositiontaking_2 = apositiontaking, @v5mpositiontaking_2 = mpositiontaking, @auto_v5mpositiontaking_2 = autompositiontaking, @isauto_v5mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=5
select @max_v5apositiontaking_3 = apositiontaking, @v5mpositiontaking_3 = mpositiontaking, @auto_v5mpositiontaking_3 = autompositiontaking, @isauto_v5mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=5
select @max_v5apositiontaking_20 = apositiontaking, @v5mpositiontaking_20 = mpositiontaking, @auto_v5mpositiontaking_20 = autompositiontaking, @isauto_v5mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=5

select @max_v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @auto_v8mpositiontaking_1 = autompositiontaking, @isauto_v8mpositiontaking_1 = isautompositiontaking, @minMinBetv8 = MinBet, @maxMaxBetv8 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=8
select @max_v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @auto_v8mpositiontaking_3 = autompositiontaking, @isauto_v8mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=8
select @max_v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @auto_v8mpositiontaking_20 = autompositiontaking, @isauto_v8mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=8

select @max_v10apositiontaking_1 = apositiontaking, @v10mpositiontaking_1 = mpositiontaking, @auto_v10mpositiontaking_1 = autompositiontaking, @isauto_v10mpositiontaking_1 = isautompositiontaking, @minMinBetv10 = MinBet, @maxMaxBetv10 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=10
select @max_v10apositiontaking_2 = apositiontaking, @v10mpositiontaking_2 = mpositiontaking, @auto_v10mpositiontaking_2 = autompositiontaking, @isauto_v10mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=10
select @max_v10apositiontaking_3 = apositiontaking, @v10mpositiontaking_3 = mpositiontaking, @auto_v10mpositiontaking_3 = autompositiontaking, @isauto_v10mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=10
select @max_v10apositiontaking_20 = apositiontaking, @v10mpositiontaking_20 = mpositiontaking, @auto_v10mpositiontaking_20 = autompositiontaking, @isauto_v10mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=10

select @max_v11apositiontaking_1 = apositiontaking, @v11mpositiontaking_1 = mpositiontaking, @auto_v11mpositiontaking_1 = autompositiontaking, @isauto_v11mpositiontaking_1 = isautompositiontaking, @minMinBetv11 = MinBet, @maxMaxBetv11 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=11
select @max_v11apositiontaking_20 = apositiontaking, @v11mpositiontaking_20 = mpositiontaking, @auto_v11mpositiontaking_20 = autompositiontaking, @isauto_v11mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=11


select @max_v99apositiontaking_1 = apositiontaking, @v99mpositiontaking_1 = mpositiontaking, @auto_v99mpositiontaking_1 = autompositiontaking, @isauto_v99mpositiontaking_1 = isautompositiontaking, @minMinBetv99 = MinBet, @maxMaxBetv99 = MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=99
select @max_v99apositiontaking_2 = apositiontaking, @v99mpositiontaking_2 = mpositiontaking, @auto_v99mpositiontaking_2 = autompositiontaking, @isauto_v99mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=99
select @max_v99apositiontaking_3 = apositiontaking, @v99mpositiontaking_3 = mpositiontaking, @auto_v99mpositiontaking_3 = autompositiontaking, @isauto_v99mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=99
select @max_v99apositiontaking_9 = apositiontaking, @v99mpositiontaking_9 = mpositiontaking, @auto_v99mpositiontaking_9 = autompositiontaking, @isauto_v99mpositiontaking_9 = isautompositiontaking,@minMinBetv99MP=MinBet, @maxMaxBetv99MP=MaxBet  from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=99
select @max_v99apositiontaking_20 = apositiontaking, @v99mpositiontaking_20 = mpositiontaking, @auto_v99mpositiontaking_20 = autompositiontaking, @isauto_v99mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=99



--v161
select @max_v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @auto_v161mpositiontaking_81 = autompositiontaking,  @isauto_v161mpositiontaking_81 = isautompositiontaking, @minMinBetv161 = MinBet, @maxMaxBetv161 = MaxBet, @discountnumber = discount from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=81 and sporttype=161
select @max_v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=83 and sporttype=161
select @max_v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=88 and sporttype=161
select @max_v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=85 and sporttype=161
select @max_v161apositiontaking_86 = apositiontaking, @max_v161alivepositiontaking_86 = alivepositiontaking, @v161mpositiontaking_86 = mpositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=86 and sporttype=161
select @max_v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=87 and sporttype=161
select @max_v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=89 and sporttype=161
select @max_v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=90 and sporttype=161

--v151
select @v151mpositiontaking_31 = mpositiontaking, @auto_v151mpositiontaking_31 = autompositiontaking, @isauto_v151mpositiontaking_31 = isautompositiontaking, @v151discount_31 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=31 and sporttype=151
select @v151mpositiontaking_32 = mpositiontaking, @auto_v151mpositiontaking_32 = autompositiontaking, @isauto_v151mpositiontaking_32 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=32 and sporttype=151

select @v151mpositiontaking_41 = mpositiontaking, @auto_v151mpositiontaking_41 = autompositiontaking, @isauto_v151mpositiontaking_41 = isautompositiontaking, @v151discount_41 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=41 and sporttype=151
select @v151mpositiontaking_42 = mpositiontaking, @auto_v151mpositiontaking_42 = autompositiontaking, @isauto_v151mpositiontaking_42 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=42 and sporttype=151

select @v151mpositiontaking_51 = mpositiontaking, @auto_v151mpositiontaking_51 = autompositiontaking, @isauto_v151mpositiontaking_51 = isautompositiontaking, @v151discount_51 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=151
select @v151mpositiontaking_52 = mpositiontaking, @auto_v151mpositiontaking_52 = autompositiontaking, @isauto_v151mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=151

--v152
select @v152mpositiontaking_41 = mpositiontaking, @auto_v152mpositiontaking_41 = autompositiontaking, @isauto_v152mpositiontaking_41 = isautompositiontaking, @v152discount_41 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=41 and sporttype=152
select @v152mpositiontaking_42 = mpositiontaking, @auto_v152mpositiontaking_42 = autompositiontaking, @isauto_v152mpositiontaking_42 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=42 and sporttype=152

select @v152mpositiontaking_51 = mpositiontaking, @auto_v152mpositiontaking_51 = autompositiontaking, @isauto_v152mpositiontaking_51 = isautompositiontaking, @v152discount_51 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=152
select @v152mpositiontaking_52 = mpositiontaking, @auto_v152mpositiontaking_52 = autompositiontaking, @isauto_v152mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=152

--v153
select @v153mpositiontaking_51 = mpositiontaking, @auto_v153mpositiontaking_51 = autompositiontaking, @isauto_v153mpositiontaking_51 = isautompositiontaking, @v153discount_51 = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=153
select @v153mpositiontaking_52 = mpositiontaking, @auto_v153mpositiontaking_52 = autompositiontaking, @isauto_v153mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=153

--v201
select @v201mpositiontaking_2 = mpositiontaking, @auto_v201mpositiontaking_2 = autompositiontaking, @isauto_v201mpositiontaking_2 = isautompositiontaking  from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=201
select @v201mpositiontaking_3 = mpositiontaking, @auto_v201mpositiontaking_3 = autompositiontaking, @isauto_v201mpositiontaking_3 = isautompositiontaking, @v201discount = discount from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=201

--v162
select @v162apositiontaking_1101 = apositiontaking, @v162mpositiontaking_1101 = mpositiontaking, @auto_v162mpositiontaking_1101 = autompositiontaking, @isauto_v162mpositiontaking_1101 = isautompositiontaking , @v162discount_1101 = discount from CustSettingGame WITH(NOLOCK) where custid = @recommend and bettype = 1101 and sporttype = 162

--v180
select @v180apositiontaking_1201 = apositiontaking, @v180mpositiontaking_1201 = mpositiontaking, @auto_v180mpositiontaking_1201 = autompositiontaking, @isauto_v180mpositiontaking_1201 = isautompositiontaking from CustSetting3rd WITH(NOLOCK) where custid = @recommend and bettype = 1201 and sporttype = 180

--s3,m3,u3,i3
select @spositiontaking_1 = spositiontaking, @slivepositiontaking_1 = slivepositiontaking, @max_mpositiontaking_1 = mpositiontaking, @max_mlivepositiontaking_1 = mlivepositiontaking, @auto_spositiontaking_1 = autopositiontaking, @auto_slivepositiontaking_1 = autolivepositiontaking, @isauto_spositiontaking_1 = isautopositiontaking, @isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @spositiontaking_3 = spositiontaking, @slivepositiontaking_3 = slivepositiontaking, @max_mpositiontaking_3 = mpositiontaking, @max_mlivepositiontaking_3 = mlivepositiontaking, @auto_spositiontaking_3 = autopositiontaking, @auto_slivepositiontaking_3 = autolivepositiontaking, @isauto_spositiontaking_3 = isautopositiontaking, @isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @spositiontaking_7 = spositiontaking, @slivepositiontaking_7 = slivepositiontaking, @max_mpositiontaking_7 = mpositiontaking, @max_mlivepositiontaking_7 = mlivepositiontaking, @auto_spositiontaking_7 = autopositiontaking, @auto_slivepositiontaking_7 = autolivepositiontaking, @isauto_spositiontaking_7 = isautopositiontaking, @isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @spositiontaking_8 = spositiontaking, @slivepositiontaking_8 = slivepositiontaking, @max_mpositiontaking_8 = mpositiontaking, @max_mlivepositiontaking_8 = mlivepositiontaking, @auto_spositiontaking_8 = autopositiontaking, @auto_slivepositiontaking_8 = autolivepositiontaking, @isauto_spositiontaking_8 = isautopositiontaking, @isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
select @spositiontaking_2 = spositiontaking, @max_mpositiontaking_2 = mpositiontaking, @auto_spositiontaking_2 = autopositiontaking, @isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @spositiontaking_4 = spositiontaking, @max_mpositiontaking_4 = mpositiontaking, @auto_spositiontaking_4 = autopositiontaking, @isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @spositiontaking_5 = spositiontaking, @max_mpositiontaking_5 = mpositiontaking, @auto_spositiontaking_5 = autopositiontaking, @isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @spositiontaking_6 = spositiontaking, @max_mpositiontaking_6 = mpositiontaking, @auto_spositiontaking_6 = autopositiontaking, @isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @spositiontaking_9 = spositiontaking, @max_mpositiontaking_9 = mpositiontaking, @auto_spositiontaking_9 = autopositiontaking, @isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @spositiontaking_10 = spositiontaking, @max_mpositiontaking_10 = mpositiontaking, @auto_spositiontaking_10 = autopositiontaking, @isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

select @v2spositiontaking_1 = spositiontaking, @max_v2mpositiontaking_1 = mpositiontaking, @auto_v2spositiontaking_1 = autopositiontaking, @isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @v2spositiontaking_2 = spositiontaking, @max_v2mpositiontaking_2 = mpositiontaking, @auto_v2spositiontaking_2 = autopositiontaking, @isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @v2spositiontaking_3 = spositiontaking, @max_v2mpositiontaking_3 = mpositiontaking, @auto_v2spositiontaking_3 = autopositiontaking, @isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @v2spositiontaking_7 = spositiontaking, @max_v2mpositiontaking_7 = mpositiontaking, @auto_v2spositiontaking_7 = autopositiontaking, @isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @v2spositiontaking_8 = spositiontaking, @max_v2mpositiontaking_8 = mpositiontaking, @auto_v2spositiontaking_8 = autopositiontaking, @isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
--select @v2spositiontaking_9 = spositiontaking, @max_v2mpositiontaking_9 = mpositiontaking, @auto_v2spositiontaking_9 = autopositiontaking, @isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @v2spositiontaking_20 = spositiontaking, @max_v2mpositiontaking_20 = mpositiontaking, @auto_v2spositiontaking_20 = autopositiontaking, @isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2

select @v3spositiontaking_1 = spositiontaking, @max_v3mpositiontaking_1 = mpositiontaking, @auto_v3spositiontaking_1 = autopositiontaking, @isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
select @v3spositiontaking_2 = spositiontaking, @max_v3mpositiontaking_2 = mpositiontaking, @auto_v3spositiontaking_2 = autopositiontaking, @isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
select @v3spositiontaking_3 = spositiontaking, @max_v3mpositiontaking_3 = mpositiontaking, @auto_v3spositiontaking_3 = autopositiontaking, @isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
select @v3spositiontaking_20 = spositiontaking, @max_v3mpositiontaking_20 = mpositiontaking, @auto_v3spositiontaking_20 = autopositiontaking, @isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3

select @v5spositiontaking_1 = spositiontaking, @max_v5mpositiontaking_1 = mpositiontaking, @auto_v5spositiontaking_1 = autopositiontaking, @isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
select @v5spositiontaking_2 = spositiontaking, @max_v5mpositiontaking_2 = mpositiontaking, @auto_v5spositiontaking_2 = autopositiontaking, @isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
select @v5spositiontaking_3 = spositiontaking, @max_v5mpositiontaking_3 = mpositiontaking, @auto_v5spositiontaking_3 = autopositiontaking, @isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
select @v5spositiontaking_20 = spositiontaking, @max_v5mpositiontaking_20 = mpositiontaking, @auto_v5spositiontaking_20 = autopositiontaking, @isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5

select @v8spositiontaking_1 = spositiontaking, @max_v8mpositiontaking_1 = mpositiontaking, @auto_v8spositiontaking_1 = autopositiontaking, @isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
select @v8spositiontaking_3 = spositiontaking, @max_v8mpositiontaking_3 = mpositiontaking, @auto_v8spositiontaking_3 = autopositiontaking, @isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
select @v8spositiontaking_20 = spositiontaking, @max_v8mpositiontaking_20 = mpositiontaking, @auto_v8spositiontaking_20 = autopositiontaking, @isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8

select @v10spositiontaking_1 = spositiontaking, @max_v10mpositiontaking_1 = mpositiontaking, @auto_v10spositiontaking_1 = autopositiontaking, @isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
select @v10spositiontaking_2 = spositiontaking, @max_v10mpositiontaking_2 = mpositiontaking, @auto_v10spositiontaking_2 = autopositiontaking, @isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
select @v10spositiontaking_3 = spositiontaking, @max_v10mpositiontaking_3 = mpositiontaking, @auto_v10spositiontaking_3 = autopositiontaking, @isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
select @v10spositiontaking_20 = spositiontaking, @max_v10mpositiontaking_20 = mpositiontaking, @auto_v10spositiontaking_20 = autopositiontaking, @isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10

select @v11spositiontaking_1 = spositiontaking, @max_v11mpositiontaking_1 = mpositiontaking, @auto_v11spositiontaking_1 = autopositiontaking, @isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
select @v11spositiontaking_20 = spositiontaking, @max_v11mpositiontaking_20 = mpositiontaking, @auto_v11spositiontaking_20 = autopositiontaking, @isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11

select @v99spositiontaking_1 = spositiontaking, @max_v99mpositiontaking_1 = mpositiontaking, @auto_v99spositiontaking_1 = autopositiontaking, @isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
select @v99spositiontaking_2 = spositiontaking, @max_v99mpositiontaking_2 = mpositiontaking, @auto_v99spositiontaking_2 = autopositiontaking, @isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
select @v99spositiontaking_3 = spositiontaking, @max_v99mpositiontaking_3 = mpositiontaking, @auto_v99spositiontaking_3 = autopositiontaking, @isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
select @v99spositiontaking_9 = spositiontaking, @max_v99mpositiontaking_9 = mpositiontaking, @auto_v99spositiontaking_9 = autopositiontaking, @isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99
select @v99spositiontaking_20 = spositiontaking, @max_v99mpositiontaking_20 = mpositiontaking, @auto_v99spositiontaking_20 = autopositiontaking, @isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99



--161
select @v161spositiontaking_81 = spositiontaking, @max_v161mpositiontaking_81 = mpositiontaking,@auto_v161spositiontaking_81 = autopositiontaking, @isauto_v161spositiontaking_81 = isautopositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
select @v161spositiontaking_83 = spositiontaking, @max_v161mpositiontaking_83 = mpositiontaking,@auto_v161spositiontaking_83 = autopositiontaking, @isauto_v161spositiontaking_83 = isautopositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
select @v161spositiontaking_88 = spositiontaking, @max_v161mpositiontaking_88 = mpositiontaking,@auto_v161spositiontaking_88 = autopositiontaking, @isauto_v161spositiontaking_88 = isautopositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161
select @v161slivepositiontaking_85 = slivepositiontaking , @max_v161mlivepositiontaking_85 =mlivepositiontaking  ,@auto_v161slivepositiontaking_85 =autolivepositiontaking, @isauto_v161slivepositiontaking_85 = isautolivepositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
select @v161spositiontaking_86 = spositiontaking, @v161slivepositiontaking_86 = slivepositiontaking , @max_v161mpositiontaking_86 = mpositiontaking,@max_v161mlivepositiontaking_86 =mlivepositiontaking  , @auto_v161spositiontaking_86 = autopositiontaking, @auto_v161slivepositiontaking_86 =autolivepositiontaking, @isauto_v161spositiontaking_86 = isautopositiontaking,@isauto_v161slivepositiontaking_86 = isautolivepositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select @v161slivepositiontaking_87 = slivepositiontaking , @max_v161mlivepositiontaking_87 =mlivepositiontaking , @auto_v161slivepositiontaking_87 =autolivepositiontaking, @isauto_v161slivepositiontaking_87 = isautolivepositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
select @v161slivepositiontaking_89 = slivepositiontaking , @max_v161mlivepositiontaking_89 =mlivepositiontaking , @auto_v161slivepositiontaking_89 =autolivepositiontaking, @isauto_v161slivepositiontaking_89 = isautolivepositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
select @v161slivepositiontaking_90 = slivepositiontaking , @max_v161mlivepositiontaking_90 =mlivepositiontaking , @auto_v161slivepositiontaking_90 =autolivepositiontaking, @isauto_v161slivepositiontaking_90 = isautolivepositiontaking   from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161

--v151
select @v151spositiontaking_31 = spositiontaking, @max_v151mpositiontaking_31 = mpositiontaking, @auto_v151spositiontaking_31 = autopositiontaking, @isauto_v151spositiontaking_31 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=31 and sporttype=151
select @v151spositiontaking_32 = spositiontaking, @max_v151mpositiontaking_32 = mpositiontaking, @auto_v151spositiontaking_32 = autopositiontaking, @isauto_v151spositiontaking_32 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=32 and sporttype=151
select @v151spositiontaking_41 = spositiontaking, @max_v151mpositiontaking_41 = mpositiontaking, @auto_v151spositiontaking_41 = autopositiontaking, @isauto_v151spositiontaking_41 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=151
select @v151spositiontaking_42 = spositiontaking, @max_v151mpositiontaking_42 = mpositiontaking, @auto_v151spositiontaking_42 = autopositiontaking, @isauto_v151spositiontaking_42 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=151
select @v151spositiontaking_51 = spositiontaking, @max_v151mpositiontaking_51 = mpositiontaking, @auto_v151spositiontaking_51 = autopositiontaking, @isauto_v151spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=151
select @v151spositiontaking_52 = spositiontaking, @max_v151mpositiontaking_52 = mpositiontaking, @auto_v151spositiontaking_52 = autopositiontaking, @isauto_v151spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=151

--v152
select @v152spositiontaking_41 = spositiontaking, @max_v152mpositiontaking_41 = mpositiontaking, @auto_v152spositiontaking_41 = autopositiontaking, @isauto_v152spositiontaking_41 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=152
select @v152spositiontaking_42 = spositiontaking, @max_v152mpositiontaking_42 = mpositiontaking, @auto_v152spositiontaking_42 = autopositiontaking, @isauto_v152spositiontaking_42 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=152
select @v152spositiontaking_51 = spositiontaking, @max_v152mpositiontaking_51 = mpositiontaking, @auto_v152spositiontaking_51 = autopositiontaking, @isauto_v152spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=152
select @v152spositiontaking_52 = spositiontaking, @max_v152mpositiontaking_52 = mpositiontaking, @auto_v152spositiontaking_52 = autopositiontaking, @isauto_v152spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=152

--v153
select @v153spositiontaking_51 = spositiontaking, @max_v153mpositiontaking_51 = mpositiontaking, @auto_v153spositiontaking_51 = autopositiontaking, @isauto_v153spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=153
select @v153spositiontaking_52 = spositiontaking, @max_v153mpositiontaking_52 = mpositiontaking, @auto_v153spositiontaking_52 = autopositiontaking, @isauto_v153spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=153

--v201
select @v201spositiontaking_2 = spositiontaking, @max_v201mpositiontaking_2 = mpositiontaking, @auto_v201spositiontaking_2 = autopositiontaking, @isauto_v201spositiontaking_2 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=201
select @v201spositiontaking_3 = spositiontaking, @max_v201mpositiontaking_3 = mpositiontaking, @auto_v201spositiontaking_3 = autopositiontaking, @isauto_v201spositiontaking_3 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=201

--v162
select @v162spositiontaking_1101 = spositiontaking, @max_v162mpositiontaking_1101 = mpositiontaking, @auto_v162spositiontaking_1101 = autopositiontaking, @isauto_v162spositiontaking_1101 = isautopositiontaking from CustSettingGame with(NOLOCK) where custid = @mrecommend and bettype = 1101 and sporttype = 162

--v180
select @v180spositiontaking_1201 = spositiontaking, @max_v180mpositiontaking_1201 = mpositiontaking, @auto_v180spositiontaking_1201 = autopositiontaking, @isauto_v180spositiontaking_1201 = isautopositiontaking from CustSetting3rd with(NOLOCK) where custid = @mrecommend and bettype = 1201 and sporttype = 180


--max_a1 = min (a2,a4),max_m1 = min (m2,m4), max_m3 = min (m3,m4), s4
select @max_apositiontaking_1 = CASE WHEN @max_apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_1 END,@max_mpositiontaking_1 = CASE WHEN @max_mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_1 END,@mpositiontaking_1 = CASE WHEN @mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_1 END, @max_spositiontaking_1 = spositiontaking, @max_alivepositiontaking_1 = CASE WHEN @max_alivepositiontaking_1 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_1 END , @max_mlivepositiontaking_1 = CASE WHEN @max_mlivepositiontaking_1 < mlivepositiontaking THEN @max_mlivepositiontaking_1 ELSE mlivepositiontaking END, @mlivepositiontaking_1 = CASE WHEN @mlivepositiontaking_1 < mlivepositiontaking THEN @mlivepositiontaking_1 ELSE mlivepositiontaking END, @max_slivepositiontaking_1 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @max_apositiontaking_3 = CASE WHEN @max_apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_3 END,@max_mpositiontaking_3 = CASE WHEN @max_mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_3 END,@mpositiontaking_3 = CASE WHEN @mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_3 END, @max_spositiontaking_3 = spositiontaking, @max_alivepositiontaking_3 = CASE WHEN @max_alivepositiontaking_3 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_3 END , @max_mlivepositiontaking_3 = CASE WHEN @max_mlivepositiontaking_3 < mlivepositiontaking THEN @max_mlivepositiontaking_3 ELSE mlivepositiontaking END, @mlivepositiontaking_3 = CASE WHEN @mlivepositiontaking_3 < mlivepositiontaking THEN @mlivepositiontaking_3 ELSE mlivepositiontaking END, @max_slivepositiontaking_3 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=1
select @max_apositiontaking_7 = CASE WHEN @max_apositiontaking_7 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_7 END,@max_mpositiontaking_7 = CASE WHEN @max_mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_7 END,@mpositiontaking_7 = CASE WHEN @mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_7 END, @max_spositiontaking_7 = spositiontaking, @max_alivepositiontaking_7 = CASE WHEN @max_alivepositiontaking_7 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_7 END , @max_mlivepositiontaking_7 = CASE WHEN @max_mlivepositiontaking_7 < mlivepositiontaking THEN @max_mlivepositiontaking_7 ELSE mlivepositiontaking END, @mlivepositiontaking_7 = CASE WHEN @mlivepositiontaking_7 < mlivepositiontaking THEN @mlivepositiontaking_7 ELSE mlivepositiontaking END, @max_slivepositiontaking_7 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=1
select @max_apositiontaking_8 = CASE WHEN @max_apositiontaking_8 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_8 END,@max_mpositiontaking_8 = CASE WHEN @max_mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_8 END,@mpositiontaking_8 = CASE WHEN @mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_8 END, @max_spositiontaking_8 = spositiontaking, @max_alivepositiontaking_8 = CASE WHEN @max_alivepositiontaking_8 > alivepositiontaking THEN alivepositiontaking ELSE @max_alivepositiontaking_8 END , @max_mlivepositiontaking_8 = CASE WHEN @max_mlivepositiontaking_8 < mlivepositiontaking THEN @max_mlivepositiontaking_8 ELSE mlivepositiontaking END, @mlivepositiontaking_8 = CASE WHEN @mlivepositiontaking_8 < mlivepositiontaking THEN @mlivepositiontaking_8 ELSE mlivepositiontaking END, @max_slivepositiontaking_8 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=1

select @max_apositiontaking_2 = CASE WHEN @max_apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_2 END,@max_mpositiontaking_2 = CASE WHEN @max_mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_2 END,@mpositiontaking_2 = CASE WHEN @mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_2 END, @max_spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=1
select @max_apositiontaking_4 = CASE WHEN @max_apositiontaking_4 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_4 END,@max_mpositiontaking_4 = CASE WHEN @max_mpositiontaking_4 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_4 END,@mpositiontaking_4 = CASE WHEN @mpositiontaking_4 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_4 END, @max_spositiontaking_4 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=4 and sporttype=1
select @max_apositiontaking_5 = CASE WHEN @max_apositiontaking_5 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_5 END,@max_mpositiontaking_5 = CASE WHEN @max_mpositiontaking_5 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_5 END,@mpositiontaking_5 = CASE WHEN @mpositiontaking_5 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_5 END, @max_spositiontaking_5 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=5 and sporttype=1
select @max_apositiontaking_6 = CASE WHEN @max_apositiontaking_6 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_6 END,@max_mpositiontaking_6 = CASE WHEN @max_mpositiontaking_6 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_6 END,@mpositiontaking_6 = CASE WHEN @mpositiontaking_6 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_6 END, @max_spositiontaking_6 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=6 and sporttype=1
select @max_apositiontaking_9 = CASE WHEN @max_apositiontaking_9 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_9 END,@max_mpositiontaking_9 = CASE WHEN @max_mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_9 END,@mpositiontaking_9 = CASE WHEN @mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_9 END, @max_spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=1
select @max_apositiontaking_10 = CASE WHEN @max_apositiontaking_10 > apositiontaking THEN apositiontaking ELSE @max_apositiontaking_10 END,@max_mpositiontaking_10 = CASE WHEN @max_mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @max_mpositiontaking_10 END,@mpositiontaking_10 = CASE WHEN @mpositiontaking_10 > mpositiontaking THEN mpositiontaking ELSE @mpositiontaking_10 END, @max_spositiontaking_10 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=1

select @max_v2apositiontaking_1 = CASE WHEN @max_v2apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_1 END,@max_v2mpositiontaking_1 = CASE WHEN @max_v2mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_1 END, @v2mpositiontaking_1 = CASE WHEN @v2mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_1 END, @max_v2spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=2
select @max_v2apositiontaking_2 = CASE WHEN @max_v2apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_2 END,@max_v2mpositiontaking_2 = CASE WHEN @max_v2mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_2 END, @v2mpositiontaking_2 = CASE WHEN @v2mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_2 END, @max_v2spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=2
select @max_v2apositiontaking_3 = CASE WHEN @max_v2apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_3 END,@max_v2mpositiontaking_3 = CASE WHEN @max_v2mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_3 END, @v2mpositiontaking_3 = CASE WHEN @v2mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_3 END, @max_v2spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=2
select @max_v2apositiontaking_7 = CASE WHEN @max_v2apositiontaking_7 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_7 END,@max_v2mpositiontaking_7 = CASE WHEN @max_v2mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_7 END, @v2mpositiontaking_7 = CASE WHEN @v2mpositiontaking_7 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_7 END, @max_v2spositiontaking_7 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=2
select @max_v2apositiontaking_8 = CASE WHEN @max_v2apositiontaking_8 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_8 END,@max_v2mpositiontaking_8 = CASE WHEN @max_v2mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_8 END, @v2mpositiontaking_8 = CASE WHEN @v2mpositiontaking_8 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_8 END, @max_v2spositiontaking_8 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=2
--select @max_v2spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=2
select @max_v2apositiontaking_20 = CASE WHEN @max_v2apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v2apositiontaking_20 END,@max_v2mpositiontaking_20 = CASE WHEN @max_v2mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v2mpositiontaking_20 END, @v2mpositiontaking_20 = CASE WHEN @v2mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v2mpositiontaking_20 END, @max_v2spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=2

select @max_v3apositiontaking_1 = CASE WHEN @max_v3apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_1 END,@max_v3mpositiontaking_1 = CASE WHEN @max_v3mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_1 END, @v3mpositiontaking_1 = CASE WHEN @v3mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_1 END, @max_v3spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=3
select @max_v3apositiontaking_2 = CASE WHEN @max_v3apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_2 END,@max_v3mpositiontaking_2 = CASE WHEN @max_v3mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_2 END, @v3mpositiontaking_2 = CASE WHEN @v3mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_2 END, @max_v3spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=3
select @max_v3apositiontaking_3 = CASE WHEN @max_v3apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_3 END,@max_v3mpositiontaking_3 = CASE WHEN @max_v3mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_3 END, @v3mpositiontaking_3 = CASE WHEN @v3mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_3 END, @max_v3spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=3
select @max_v3apositiontaking_20 = CASE WHEN @max_v3apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v3apositiontaking_20 END,@max_v3mpositiontaking_20 = CASE WHEN @max_v3mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v3mpositiontaking_20 END, @v3mpositiontaking_20 = CASE WHEN @v3mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v3mpositiontaking_20 END, @max_v3spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=3

select @max_v5apositiontaking_1 = CASE WHEN @max_v5apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_1 END,@max_v5mpositiontaking_1 = CASE WHEN @max_v5mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_1 END, @v5mpositiontaking_1 = CASE WHEN @v5mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_1 END, @max_v5spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=5
select @max_v5apositiontaking_2 = CASE WHEN @max_v5apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_2 END,@max_v5mpositiontaking_2 = CASE WHEN @max_v5mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_2 END, @v5mpositiontaking_2 = CASE WHEN @v5mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_2 END, @max_v5spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=5
select @max_v5apositiontaking_3 = CASE WHEN @max_v5apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_3 END,@max_v5mpositiontaking_3 = CASE WHEN @max_v5mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_3 END, @v5mpositiontaking_3 = CASE WHEN @v5mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_3 END, @max_v5spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=5
select @max_v5apositiontaking_20 = CASE WHEN @max_v5apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v5apositiontaking_20 END,@max_v5mpositiontaking_20 = CASE WHEN @max_v5mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v5mpositiontaking_20 END, @v5mpositiontaking_20 = CASE WHEN @v5mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v5mpositiontaking_20 END, @max_v5spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=5

select @max_v8apositiontaking_1 = CASE WHEN @max_v8apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_1 END,@max_v8mpositiontaking_1 = CASE WHEN @max_v8mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_1 END, @v8mpositiontaking_1 = CASE WHEN @v8mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_1 END, @max_v8spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=8
select @max_v8apositiontaking_3 = CASE WHEN @max_v8apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_3 END,@max_v8mpositiontaking_3 = CASE WHEN @max_v8mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_3 END, @v8mpositiontaking_3 = CASE WHEN @v8mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_3 END, @max_v8spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=8
select @max_v8apositiontaking_20 = CASE WHEN @max_v8apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v8apositiontaking_20 END,@max_v8mpositiontaking_20 = CASE WHEN @max_v8mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v8mpositiontaking_20 END, @v8mpositiontaking_20 = CASE WHEN @v8mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v8mpositiontaking_20 END, @max_v8spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=8

select @max_v10apositiontaking_1 = CASE WHEN @max_v10apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_1 END,@max_v10mpositiontaking_1 = CASE WHEN @max_v10mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_1 END, @v10mpositiontaking_1 = CASE WHEN @v10mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_1 END, @max_v10spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=10
select @max_v10apositiontaking_2 = CASE WHEN @max_v10apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_2 END,@max_v10mpositiontaking_2 = CASE WHEN @max_v10mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_2 END, @v10mpositiontaking_2 = CASE WHEN @v10mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_2 END, @max_v10spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=10
select @max_v10apositiontaking_3 = CASE WHEN @max_v10apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_3 END,@max_v10mpositiontaking_3 = CASE WHEN @max_v10mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_3 END, @v10mpositiontaking_3 = CASE WHEN @v10mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_3 END, @max_v10spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=10
select @max_v10apositiontaking_20 = CASE WHEN @max_v10apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v10apositiontaking_20 END,@max_v10mpositiontaking_20 = CASE WHEN @max_v10mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v10mpositiontaking_20 END, @v10mpositiontaking_20 = CASE WHEN @v10mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v10mpositiontaking_20 END, @max_v10spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=10

select @max_v11apositiontaking_1 = CASE WHEN @max_v11apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v11apositiontaking_1 END,@max_v11mpositiontaking_1 = CASE WHEN @max_v11mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v11mpositiontaking_1 END, @v11mpositiontaking_1 = CASE WHEN @v11mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v11mpositiontaking_1 END, @max_v11spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=11
select @max_v11apositiontaking_20 = CASE WHEN @max_v11apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v11apositiontaking_20 END,@max_v11mpositiontaking_20 = CASE WHEN @max_v11mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v11mpositiontaking_20 END, @v11mpositiontaking_20 = CASE WHEN @v11mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v11mpositiontaking_20 END, @max_v11spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=11

select @max_v99apositiontaking_1 = CASE WHEN @max_v99apositiontaking_1 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_1 END,@max_v99mpositiontaking_1 = CASE WHEN @max_v99mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_1 END, @v99mpositiontaking_1 = CASE WHEN @v99mpositiontaking_1 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_1 END, @max_v99spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=99
select @max_v99apositiontaking_2 = CASE WHEN @max_v99apositiontaking_2 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_2 END,@max_v99mpositiontaking_2 = CASE WHEN @max_v99mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_2 END, @v99mpositiontaking_2 = CASE WHEN @v99mpositiontaking_2 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_2 END, @max_v99spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=99
select @max_v99apositiontaking_3 = CASE WHEN @max_v99apositiontaking_3 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_3 END,@max_v99mpositiontaking_3 = CASE WHEN @max_v99mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_3 END, @v99mpositiontaking_3 = CASE WHEN @v99mpositiontaking_3 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_3 END, @max_v99spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=99
select @max_v99apositiontaking_9 = CASE WHEN @max_v99apositiontaking_9 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_9 END,@max_v99mpositiontaking_9 = CASE WHEN @max_v99mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_9 END, @v99mpositiontaking_9 = CASE WHEN @v99mpositiontaking_9 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_9 END, @max_v99spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=99
select @max_v99apositiontaking_20 = CASE WHEN @max_v99apositiontaking_20 > apositiontaking THEN apositiontaking ELSE @max_v99apositiontaking_20 END,@max_v99mpositiontaking_20 = CASE WHEN @max_v99mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @max_v99mpositiontaking_20 END, @v99mpositiontaking_20 = CASE WHEN @v99mpositiontaking_20 > mpositiontaking THEN mpositiontaking ELSE @v99mpositiontaking_20 END, @max_v99spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=99



--v161
select @max_v161apositiontaking_81 = CASE WHEN @max_v161apositiontaking_81 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_81 END,@max_v161mpositiontaking_81 = CASE WHEN @max_v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_81 END, @v161mpositiontaking_81 = CASE WHEN @v161mpositiontaking_81 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_81 END, @max_v161spositiontaking_81 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=81 and sporttype=161
select @max_v161apositiontaking_83 = CASE WHEN @max_v161apositiontaking_83 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_83 END,@max_v161mpositiontaking_83 = CASE WHEN @max_v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_83 END,@v161mpositiontaking_83 = CASE WHEN @v161mpositiontaking_83 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_83 END,@max_v161spositiontaking_83 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=83 and sporttype=161
select @max_v161apositiontaking_88 = CASE WHEN @max_v161apositiontaking_88 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_88 END,@max_v161mpositiontaking_88 = CASE WHEN @max_v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_88 END,@v161mpositiontaking_88 = CASE WHEN @v161mpositiontaking_88 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_88 END,@max_v161spositiontaking_88 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=88 and sporttype=161
select @max_v161alivepositiontaking_85 = CASE WHEN @max_v161alivepositiontaking_85 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_85 END,@max_v161mlivepositiontaking_85 = CASE WHEN @max_v161mlivepositiontaking_85 < mlivepositiontaking THEN @max_v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @v161mlivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85 < mlivepositiontaking THEN @v161mlivepositiontaking_85 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_85 = slivepositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=85 and sporttype=161
select @max_v161apositiontaking_86 = CASE WHEN @max_v161apositiontaking_86 > apositiontaking THEN apositiontaking ELSE @max_v161apositiontaking_86 END,@max_v161mpositiontaking_86 = CASE WHEN @max_v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @max_v161mpositiontaking_86 END,@v161mpositiontaking_86 = CASE WHEN @v161mpositiontaking_86 > mpositiontaking THEN mpositiontaking ELSE @v161mpositiontaking_86 END,@max_v161spositiontaking_86 = spositiontaking, @max_v161alivepositiontaking_86 = CASE WHEN @max_v161alivepositiontaking_86 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_86 END, @max_v161mlivepositiontaking_86 = CASE WHEN @max_v161mlivepositiontaking_86 < mlivepositiontaking THEN @max_v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @v161mlivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86 < mlivepositiontaking THEN @v161mlivepositiontaking_86 ELSE mlivepositiontaking END, @max_v161slivepositiontaking_86 = slivepositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=86 and sporttype=161
select @max_v161alivepositiontaking_87 = CASE WHEN @max_v161alivepositiontaking_87 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_87 END,@max_v161mlivepositiontaking_87 = CASE WHEN @max_v161mlivepositiontaking_87 < mlivepositiontaking THEN @max_v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@v161mlivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87 < mlivepositiontaking THEN @v161mlivepositiontaking_87 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_87 = slivepositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=87 and sporttype=161
select @max_v161alivepositiontaking_89 = CASE WHEN @max_v161alivepositiontaking_89 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_89 END,@max_v161mlivepositiontaking_89 = CASE WHEN @max_v161mlivepositiontaking_89 < mlivepositiontaking THEN @max_v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@v161mlivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89 < mlivepositiontaking THEN @v161mlivepositiontaking_89 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_89 = slivepositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=89 and sporttype=161
select @max_v161alivepositiontaking_90 = CASE WHEN @max_v161alivepositiontaking_90 > alivepositiontaking THEN alivepositiontaking ELSE @max_v161alivepositiontaking_90 END,@max_v161mlivepositiontaking_90 = CASE WHEN @max_v161mlivepositiontaking_90 < mlivepositiontaking THEN @max_v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@v161mlivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90 < mlivepositiontaking THEN @v161mlivepositiontaking_90 ELSE mlivepositiontaking END,@max_v161slivepositiontaking_90 = slivepositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=90 and sporttype=161

--v151

select @max_v151spositiontaking_31 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=31 and sporttype=151
select @max_v151spositiontaking_32 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=32 and sporttype=151
select @max_v151spositiontaking_41 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=151
select @max_v151spositiontaking_42 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=42 and sporttype=151
select @max_v151spositiontaking_51 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=151
select @max_v151spositiontaking_52 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=151

--v152
select @max_v152spositiontaking_41 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=152
select @max_v152spositiontaking_42 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=42 and sporttype=152
select @max_v152spositiontaking_51 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=152
select @max_v152spositiontaking_52 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=152

--v153
select @max_v153spositiontaking_51 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=153
select @max_v153spositiontaking_52 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=153

--v201
select @max_v201spositiontaking_2 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=201
select @max_v201spositiontaking_3 = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=201

--v162
select @max_v162spositiontaking_1101 = spositiontaking from CustSettingGame WITH(NOLOCK) where custid = @srecommend and bettype = 1101 and sporttype = 162

--v180
select @max_v180spositiontaking_1201 = spositiontaking from CustSetting3rd WITH(NOLOCK) where custid = @srecommend and bettype = 1201 and sporttype = 180

--check a1<=min(a2,a4) - Vinh
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((max_apositiontaking) as varchar(10))
+ case when b.sporttype in (1,161) and b.bettype in (1,3,7,8,85,86,87,89,90) then '-MaxLive: '+ cast((max_alivepositiontaking) as varchar(10)) else '' end + '<br>'
from sports with (NOLOCK) inner join
(
			select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @max_apositiontaking_1 as max_apositiontaking,  @max_alivepositiontaking_1 as max_alivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @max_apositiontaking_3 as max_apositiontaking,  @max_alivepositiontaking_3 as max_alivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @max_apositiontaking_7 as max_apositiontaking,  @max_alivepositiontaking_7 as max_alivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @max_apositiontaking_8 as max_apositiontaking,  @max_alivepositiontaking_8 as max_alivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_4 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_5 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_6 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_9 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @max_apositiontaking_10 as max_apositiontaking,  0 as max_alivepositiontaking

	union all 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
--	union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_7 as max_apositiontaking,  0 as max_alivepositiontaking
--	union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_8 as max_apositiontaking,  0 as max_alivepositiontaking
--	union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_9 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v2apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking

	union all 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v3apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_v3apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v3apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v3apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v5apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_v5apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v5apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v5apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v8apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v8apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v8apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v10apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_v10apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v10apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v10apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v11apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v11apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking

	union all 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @max_v99apositiontaking_1 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @max_v99apositiontaking_2 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @max_v99apositiontaking_3 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @max_v99apositiontaking_20 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @max_v99apositiontaking_9 as max_apositiontaking,  0 as max_alivepositiontaking
	
	union all 	select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking, @max_v161apositiontaking_81 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking, @max_v161apositiontaking_83 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking, @max_v161apositiontaking_88 as max_apositiontaking,  0 as max_alivepositiontaking
	union all 	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, 0 as max_apositiontaking,  @max_v161alivepositiontaking_85 as max_alivepositiontaking
	union all 	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @max_v161apositiontaking_86 as max_apositiontaking,  @max_v161alivepositiontaking_86 as max_alivepositiontaking
	union all 	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, 0 as max_apositiontaking,  @max_v161alivepositiontaking_87 as max_alivepositiontaking
	union all 	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, 0 as max_apositiontaking,  @max_v161alivepositiontaking_89 as max_alivepositiontaking
	union all 	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, 0 as max_apositiontaking,  @max_v161alivepositiontaking_90 as max_alivepositiontaking
			
	) as b on sports.sporttype = b.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
	where (apositiontaking>max_apositiontaking)
		or (alivepositiontaking >max_alivepositiontaking)

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Wrong agent positiontaking. <br>'+@ErrType
							when 'CS' then N'代理占成数不正确. <br>'+@ErrType
							when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
							when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
							when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
							when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
							when 'KO' then N'에이전트의 거래 조건이 잘못 되었습니다. <br>'+@ErrType
							else N'Wrong agent positiontaking. <br>'+@ErrType
					end,
		@success = 0, @ErrCode = 203
	return
END

----------------***Use Master Auto Position Taking***----------------------------------
--use @auto_mpt at agent
--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
--if u2 = 0 then m1 = m2
--else	if u2 < m3 - a1 then m1 = u2
--		else m1 = m3 - a1

select @mpositiontaking_1 = case when isnull(@isauto_mpositiontaking_1, 0)=0 then @mpositiontaking_1 else case when @auto_mpositiontaking_1 < @max_mpositiontaking_1 - @apositiontaking_1 then @auto_mpositiontaking_1 else @max_mpositiontaking_1 - @apositiontaking_1 end end
select @mpositiontaking_3 = case when isnull(@isauto_mpositiontaking_3, 0)=0 then @mpositiontaking_3 else case when @auto_mpositiontaking_3 < @max_mpositiontaking_3 - @apositiontaking_3 then @auto_mpositiontaking_3 else @max_mpositiontaking_3 - @apositiontaking_3 end end
select @mpositiontaking_7 = case when isnull(@isauto_mpositiontaking_7, 0)=0 then @mpositiontaking_7 else case when @auto_mpositiontaking_7 < @max_mpositiontaking_7 - @apositiontaking_7 then @auto_mpositiontaking_7 else @max_mpositiontaking_7 - @apositiontaking_7 end end
select @mpositiontaking_8 = case when isnull(@isauto_mpositiontaking_8, 0)=0 then @mpositiontaking_8 else case when @auto_mpositiontaking_8 < @max_mpositiontaking_8 - @apositiontaking_8 then @auto_mpositiontaking_8 else @max_mpositiontaking_8 - @apositiontaking_8 end end

select @mlivepositiontaking_1 = case when isnull(@isauto_mlivepositiontaking_1, 0)=0 then @mlivepositiontaking_1 else case when @auto_mlivepositiontaking_1 < @max_mlivepositiontaking_1 - @alivepositiontaking_1 then @auto_mlivepositiontaking_1 else @max_mlivepositiontaking_1 - @alivepositiontaking_1 end end
select @mlivepositiontaking_3 = case when isnull(@isauto_mlivepositiontaking_3, 0)=0 then @mlivepositiontaking_3 else case when @auto_mlivepositiontaking_3 < @max_mlivepositiontaking_3 - @alivepositiontaking_3 then @auto_mlivepositiontaking_3 else @max_mlivepositiontaking_3 - @alivepositiontaking_3 end end
select @mlivepositiontaking_7 = case when isnull(@isauto_mlivepositiontaking_7, 0)=0 then @mlivepositiontaking_7 else case when @auto_mlivepositiontaking_7 < @max_mlivepositiontaking_7 - @alivepositiontaking_7 then @auto_mlivepositiontaking_7 else @max_mlivepositiontaking_7 - @alivepositiontaking_7 end end
select @mlivepositiontaking_8 = case when isnull(@isauto_mlivepositiontaking_8, 0)=0 then @mlivepositiontaking_8 else case when @auto_mlivepositiontaking_8 < @max_mlivepositiontaking_8 - @alivepositiontaking_8 then @auto_mlivepositiontaking_8 else @max_mlivepositiontaking_8 - @alivepositiontaking_8 end end

select @mpositiontaking_2 = case when isnull(@isauto_mpositiontaking_2, 0)=0 then @mpositiontaking_2 else case when @auto_mpositiontaking_2 < @max_mpositiontaking_2 - @apositiontaking_2 then @auto_mpositiontaking_2 else @max_mpositiontaking_2 - @apositiontaking_2 end end
select @mpositiontaking_4 = case when isnull(@isauto_mpositiontaking_4, 0)=0 then @mpositiontaking_4 else case when @auto_mpositiontaking_4 < @max_mpositiontaking_4 - @apositiontaking_4 then @auto_mpositiontaking_4 else @max_mpositiontaking_4 - @apositiontaking_4 end end
select @mpositiontaking_5 = case when isnull(@isauto_mpositiontaking_5, 0)=0 then @mpositiontaking_5 else case when @auto_mpositiontaking_5 < @max_mpositiontaking_5 - @apositiontaking_5 then @auto_mpositiontaking_5 else @max_mpositiontaking_5 - @apositiontaking_5 end end
select @mpositiontaking_6 = case when isnull(@isauto_mpositiontaking_6, 0)=0 then @mpositiontaking_6 else case when @auto_mpositiontaking_6 < @max_mpositiontaking_6 - @apositiontaking_6 then @auto_mpositiontaking_6 else @max_mpositiontaking_6 - @apositiontaking_6 end end
select @mpositiontaking_9 = case when isnull(@isauto_mpositiontaking_9, 0)=0 then @mpositiontaking_9 else case when @auto_mpositiontaking_9 < @max_mpositiontaking_9 - @apositiontaking_9 then @auto_mpositiontaking_9 else @max_mpositiontaking_9 - @apositiontaking_9 end end
select @mpositiontaking_10 = case when isnull(@isauto_mpositiontaking_10, 0)=0 then @mpositiontaking_10 else case when @auto_mpositiontaking_10 < @max_mpositiontaking_10 - @apositiontaking_10 then @auto_mpositiontaking_10 else @max_mpositiontaking_10 - @apositiontaking_10 end end

select @v2mpositiontaking_1 = case when isnull(@isauto_v2mpositiontaking_1, 0)=0 then @v2mpositiontaking_1 else case when @auto_v2mpositiontaking_1 < @max_v2mpositiontaking_1 - @v2apositiontaking_1 then @auto_v2mpositiontaking_1 else @max_v2mpositiontaking_1 - @v2apositiontaking_1 end end
select @v2mpositiontaking_2 = case when isnull(@isauto_v2mpositiontaking_2, 0)=0 then @v2mpositiontaking_2 else case when @auto_v2mpositiontaking_2 < @max_v2mpositiontaking_2 - @v2apositiontaking_2 then @auto_v2mpositiontaking_2 else @max_v2mpositiontaking_2 - @v2apositiontaking_2 end end
select @v2mpositiontaking_3 = case when isnull(@isauto_v2mpositiontaking_3, 0)=0 then @v2mpositiontaking_3 else case when @auto_v2mpositiontaking_3 < @max_v2mpositiontaking_3 - @v2apositiontaking_3 then @auto_v2mpositiontaking_3 else @max_v2mpositiontaking_3 - @v2apositiontaking_3 end end
select @v2mpositiontaking_7 = case when isnull(@isauto_v2mpositiontaking_7, 0)=0 then @v2mpositiontaking_7 else case when @auto_v2mpositiontaking_7 < @max_v2mpositiontaking_7 - @v2apositiontaking_7 then @auto_v2mpositiontaking_7 else @max_v2mpositiontaking_7 - @v2apositiontaking_7 end end
select @v2mpositiontaking_8 = case when isnull(@isauto_v2mpositiontaking_8, 0)=0 then @v2mpositiontaking_8 else case when @auto_v2mpositiontaking_8 < @max_v2mpositiontaking_8 - @v2apositiontaking_8 then @auto_v2mpositiontaking_8 else @max_v2mpositiontaking_8 - @v2apositiontaking_8 end end
--select @v2mpositiontaking_9 = case when isnull(@isauto_v2mpositiontaking_9, 0)=0 then @v2mpositiontaking_9 else case when @auto_v2mpositiontaking_9 < @max_v2mpositiontaking_9 - @v2apositiontaking_9 then @auto_v2mpositiontaking_9 else @max_v2mpositiontaking_9 - @v2apositiontaking_9 end end
select @v2mpositiontaking_20 = case when isnull(@isauto_v2mpositiontaking_20, 0)=0 then @v2mpositiontaking_20 else case when @auto_v2mpositiontaking_20 < @max_v2mpositiontaking_20 - @v2apositiontaking_20 then @auto_v2mpositiontaking_20 else @max_v2mpositiontaking_20 - @v2apositiontaking_20 end end

select @v3mpositiontaking_1 = case when isnull(@isauto_v3mpositiontaking_1, 0)=0 then @v3mpositiontaking_1 else case when @auto_v3mpositiontaking_1 < @max_v3mpositiontaking_1 - @v3apositiontaking_1 then @auto_v3mpositiontaking_1 else @max_v3mpositiontaking_1 - @v3apositiontaking_1 end end
select @v3mpositiontaking_2 = case when isnull(@isauto_v3mpositiontaking_2, 0)=0 then @v3mpositiontaking_2 else case when @auto_v3mpositiontaking_2 < @max_v3mpositiontaking_2 - @v3apositiontaking_2 then @auto_v3mpositiontaking_2 else @max_v3mpositiontaking_2 - @v3apositiontaking_2 end end
select @v3mpositiontaking_3 = case when isnull(@isauto_v3mpositiontaking_3, 0)=0 then @v3mpositiontaking_3 else case when @auto_v3mpositiontaking_3 < @max_v3mpositiontaking_3 - @v3apositiontaking_3 then @auto_v3mpositiontaking_3 else @max_v3mpositiontaking_3 - @v3apositiontaking_3 end end
select @v3mpositiontaking_20 = case when isnull(@isauto_v3mpositiontaking_20, 0)=0 then @v3mpositiontaking_20 else case when @auto_v3mpositiontaking_20 < @max_v3mpositiontaking_20 - @v3apositiontaking_20 then @auto_v3mpositiontaking_20 else @max_v3mpositiontaking_20 - @v3apositiontaking_20 end end

select @v5mpositiontaking_1 = case when isnull(@isauto_v5mpositiontaking_1, 0)=0 then @v5mpositiontaking_1 else case when @auto_v5mpositiontaking_1 < @max_v5mpositiontaking_1 - @v5apositiontaking_1 then @auto_v5mpositiontaking_1 else @max_v5mpositiontaking_1 - @v5apositiontaking_1 end end
select @v5mpositiontaking_2 = case when isnull(@isauto_v5mpositiontaking_2, 0)=0 then @v5mpositiontaking_2 else case when @auto_v5mpositiontaking_2 < @max_v5mpositiontaking_2 - @v5apositiontaking_2 then @auto_v5mpositiontaking_2 else @max_v5mpositiontaking_2 - @v5apositiontaking_2 end end
select @v5mpositiontaking_3 = case when isnull(@isauto_v5mpositiontaking_3, 0)=0 then @v5mpositiontaking_3 else case when @auto_v5mpositiontaking_3 < @max_v5mpositiontaking_3 - @v5apositiontaking_3 then @auto_v5mpositiontaking_3 else @max_v5mpositiontaking_3 - @v5apositiontaking_3 end end
select @v5mpositiontaking_20 = case when isnull(@isauto_v5mpositiontaking_20, 0)=0 then @v5mpositiontaking_20 else case when @auto_v5mpositiontaking_20 < @max_v5mpositiontaking_20 - @v5apositiontaking_20 then @auto_v5mpositiontaking_20 else @max_v5mpositiontaking_20 - @v5apositiontaking_20 end end

select @v8mpositiontaking_1 = case when isnull(@isauto_v8mpositiontaking_1, 0)=0 then @v8mpositiontaking_1 else case when @auto_v8mpositiontaking_1 < @max_v8mpositiontaking_1 - @v8apositiontaking_1 then @auto_v8mpositiontaking_1 else @max_v8mpositiontaking_1 - @v8apositiontaking_1 end end
select @v8mpositiontaking_3 = case when isnull(@isauto_v8mpositiontaking_3, 0)=0 then @v8mpositiontaking_3 else case when @auto_v8mpositiontaking_3 < @max_v8mpositiontaking_3 - @v8apositiontaking_3 then @auto_v8mpositiontaking_3 else @max_v8mpositiontaking_3 - @v8apositiontaking_3 end end
select @v8mpositiontaking_20 = case when isnull(@isauto_v8mpositiontaking_20, 0)=0 then @v8mpositiontaking_20 else case when @auto_v8mpositiontaking_20 < @max_v8mpositiontaking_20 - @v8apositiontaking_20 then @auto_v8mpositiontaking_20 else @max_v8mpositiontaking_20 - @v8apositiontaking_20 end end

select @v10mpositiontaking_1 = case when isnull(@isauto_v10mpositiontaking_1, 0)=0 then @v10mpositiontaking_1 else case when @auto_v10mpositiontaking_1 < @max_v10mpositiontaking_1 - @v10apositiontaking_1 then @auto_v10mpositiontaking_1 else @max_v10mpositiontaking_1 - @v10apositiontaking_1 end end
select @v10mpositiontaking_2 = case when isnull(@isauto_v10mpositiontaking_2, 0)=0 then @v10mpositiontaking_2 else case when @auto_v10mpositiontaking_2 < @max_v10mpositiontaking_2 - @v10apositiontaking_2 then @auto_v10mpositiontaking_2 else @max_v10mpositiontaking_2 - @v10apositiontaking_2 end end
select @v10mpositiontaking_3 = case when isnull(@isauto_v10mpositiontaking_3, 0)=0 then @v10mpositiontaking_3 else case when @auto_v10mpositiontaking_3 < @max_v10mpositiontaking_3 - @v10apositiontaking_3 then @auto_v10mpositiontaking_3 else @max_v10mpositiontaking_3 - @v10apositiontaking_3 end end
select @v10mpositiontaking_20 = case when isnull(@isauto_v10mpositiontaking_20, 0)=0 then @v10mpositiontaking_20 else case when @auto_v10mpositiontaking_20 < @max_v10mpositiontaking_20 - @v10apositiontaking_20 then @auto_v10mpositiontaking_20 else @max_v10mpositiontaking_20 - @v10apositiontaking_20 end end

select @v11mpositiontaking_1 = case when isnull(@isauto_v11mpositiontaking_1, 0)=0 then @v11mpositiontaking_1 else case when @auto_v11mpositiontaking_1 < @max_v11mpositiontaking_1 - @v11apositiontaking_1 then @auto_v11mpositiontaking_1 else @max_v11mpositiontaking_1 - @v11apositiontaking_1 end end
select @v11mpositiontaking_20 = case when isnull(@isauto_v11mpositiontaking_20, 0)=0 then @v11mpositiontaking_20 else case when @auto_v11mpositiontaking_20 < @max_v11mpositiontaking_20 - @v11apositiontaking_20 then @auto_v11mpositiontaking_20 else @max_v11mpositiontaking_20 - @v11apositiontaking_20 end end

select @v99mpositiontaking_1 = case when isnull(@isauto_v99mpositiontaking_1, 0)=0 then @v99mpositiontaking_1 else case when @auto_v99mpositiontaking_1 < @max_v99mpositiontaking_1 - @v99apositiontaking_1 then @auto_v99mpositiontaking_1 else @max_v99mpositiontaking_1 - @v99apositiontaking_1 end end
select @v99mpositiontaking_2 = case when isnull(@isauto_v99mpositiontaking_2, 0)=0 then @v99mpositiontaking_2 else case when @auto_v99mpositiontaking_2 < @max_v99mpositiontaking_2 - @v99apositiontaking_2 then @auto_v99mpositiontaking_2 else @max_v99mpositiontaking_2 - @v99apositiontaking_2 end end
select @v99mpositiontaking_3 = case when isnull(@isauto_v99mpositiontaking_3, 0)=0 then @v99mpositiontaking_3 else case when @auto_v99mpositiontaking_3 < @max_v99mpositiontaking_3 - @v99apositiontaking_3 then @auto_v99mpositiontaking_3 else @max_v99mpositiontaking_3 - @v99apositiontaking_3 end end
select @v99mpositiontaking_9 = case when isnull(@isauto_v99mpositiontaking_9, 0)=0 then @v99mpositiontaking_9 else case when @auto_v99mpositiontaking_9 < @max_v99mpositiontaking_9 - @v99apositiontaking_9 then @auto_v99mpositiontaking_9 else @max_v99mpositiontaking_9 - @v99apositiontaking_9 end end
select @v99mpositiontaking_20 = case when isnull(@isauto_v99mpositiontaking_20, 0)=0 then @v99mpositiontaking_20 else case when @auto_v99mpositiontaking_20 < @max_v99mpositiontaking_20 - @v99apositiontaking_20 then @auto_v99mpositiontaking_20 else @max_v99mpositiontaking_20 - @v99apositiontaking_20 end end



--v161
select @v161mpositiontaking_81 = case when isnull(@isauto_v161mpositiontaking_81, 0)=0 then @v161mpositiontaking_81 else case when @auto_v161mpositiontaking_81 < @max_v161mpositiontaking_81 - @v161apositiontaking_81 then @auto_v161mpositiontaking_81 else @max_v161mpositiontaking_81 - @v161apositiontaking_81 end end
select @v161mpositiontaking_83 = case when isnull(@isauto_v161mpositiontaking_83, 0)=0 then @v161mpositiontaking_83 else case when @auto_v161mpositiontaking_83 < @max_v161mpositiontaking_83 - @v161apositiontaking_83 then @auto_v161mpositiontaking_83 else @max_v161mpositiontaking_83 - @v161apositiontaking_83 end end
select @v161mpositiontaking_86 = case when isnull(@isauto_v161mpositiontaking_86, 0)=0 then @v161mpositiontaking_86 else case when @auto_v161mpositiontaking_86 < @max_v161mpositiontaking_86 - @v161apositiontaking_86 then @auto_v161mpositiontaking_86 else @max_v161mpositiontaking_86 - @v161apositiontaking_86 end end
select @v161mpositiontaking_88 = case when isnull(@isauto_v161mpositiontaking_88, 0)=0 then @v161mpositiontaking_88 else case when @auto_v161mpositiontaking_88 < @max_v161mpositiontaking_88 - @v161apositiontaking_88 then @auto_v161mpositiontaking_88 else @max_v161mpositiontaking_88 - @v161apositiontaking_88 end end
select @v161mlivepositiontaking_85 = case when isnull(@isauto_v161mlivepositiontaking_85, 0)=0 then @v161mlivepositiontaking_85 else case when @auto_v161mlivepositiontaking_85 < @max_v161mlivepositiontaking_85 - @v161alivepositiontaking_85 then @auto_v161mlivepositiontaking_85 else @max_v161mlivepositiontaking_85 - @v161alivepositiontaking_85 end end
select @v161mlivepositiontaking_86 = case when isnull(@isauto_v161mlivepositiontaking_86, 0)=0 then @v161mlivepositiontaking_86 else case when @auto_v161mlivepositiontaking_86 < @max_v161mlivepositiontaking_86 - @v161alivepositiontaking_86 then @auto_v161mlivepositiontaking_86 else @max_v161mlivepositiontaking_86 - @v161alivepositiontaking_86 end end
select @v161mlivepositiontaking_87 = case when isnull(@isauto_v161mlivepositiontaking_87, 0)=0 then @v161mlivepositiontaking_87 else case when @auto_v161mlivepositiontaking_87 < @max_v161mlivepositiontaking_87 - @v161alivepositiontaking_87 then @auto_v161mlivepositiontaking_87 else @max_v161mlivepositiontaking_87 - @v161alivepositiontaking_87 end end
select @v161mlivepositiontaking_89 = case when isnull(@isauto_v161mlivepositiontaking_89, 0)=0 then @v161mlivepositiontaking_89 else case when @auto_v161mlivepositiontaking_89 < @max_v161mlivepositiontaking_89 - @v161alivepositiontaking_89 then @auto_v161mlivepositiontaking_89 else @max_v161mlivepositiontaking_89 - @v161alivepositiontaking_89 end end
select @v161mlivepositiontaking_90 = case when isnull(@isauto_v161mlivepositiontaking_90, 0)=0 then @v161mlivepositiontaking_90 else case when @auto_v161mlivepositiontaking_90 < @max_v161mlivepositiontaking_90 - @v161alivepositiontaking_90 then @auto_v161mlivepositiontaking_90 else @max_v161mlivepositiontaking_90 - @v161alivepositiontaking_90 end end


--v151
select @v151mpositiontaking_31 = case when isnull(@isauto_v151mpositiontaking_31, 0)=0 then @v151mpositiontaking_31 else case when @auto_v151mpositiontaking_31 < @max_v151mpositiontaking_31 then @auto_v151mpositiontaking_31 else @max_v151mpositiontaking_31 end end
select @v151mpositiontaking_32 = case when isnull(@isauto_v151mpositiontaking_32, 0)=0 then @v151mpositiontaking_32 else case when @auto_v151mpositiontaking_32 < @max_v151mpositiontaking_32 then @auto_v151mpositiontaking_32 else @max_v151mpositiontaking_32 end end
select @v151mpositiontaking_41 = case when isnull(@isauto_v151mpositiontaking_41, 0)=0 then @v151mpositiontaking_41 else case when @auto_v151mpositiontaking_41 < @max_v151mpositiontaking_41 then @auto_v151mpositiontaking_41 else @max_v151mpositiontaking_41 end end
select @v151mpositiontaking_42 = case when isnull(@isauto_v151mpositiontaking_42, 0)=0 then @v151mpositiontaking_42 else case when @auto_v151mpositiontaking_42 < @max_v151mpositiontaking_42 then @auto_v151mpositiontaking_42 else @max_v151mpositiontaking_42 end end
select @v151mpositiontaking_51 = case when isnull(@isauto_v151mpositiontaking_51, 0)=0 then @v151mpositiontaking_51 else case when @auto_v151mpositiontaking_51 < @max_v151mpositiontaking_51 then @auto_v151mpositiontaking_51 else @max_v151mpositiontaking_51 end end
select @v151mpositiontaking_52 = case when isnull(@isauto_v151mpositiontaking_52, 0)=0 then @v151mpositiontaking_52 else case when @auto_v151mpositiontaking_52 < @max_v151mpositiontaking_52 then @auto_v151mpositiontaking_52 else @max_v151mpositiontaking_52 end end

--v152
select @v152mpositiontaking_41 = case when isnull(@isauto_v152mpositiontaking_41, 0)=0 then @v152mpositiontaking_41 else case when @auto_v152mpositiontaking_41 < @max_v152mpositiontaking_41 then @auto_v152mpositiontaking_41 else @max_v152mpositiontaking_41 end end
select @v152mpositiontaking_42 = case when isnull(@isauto_v152mpositiontaking_42, 0)=0 then @v152mpositiontaking_42 else case when @auto_v152mpositiontaking_42 < @max_v152mpositiontaking_42 then @auto_v152mpositiontaking_42 else @max_v152mpositiontaking_42 end end
select @v152mpositiontaking_51 = case when isnull(@isauto_v152mpositiontaking_51, 0)=0 then @v152mpositiontaking_51 else case when @auto_v152mpositiontaking_51 < @max_v152mpositiontaking_51 then @auto_v152mpositiontaking_51 else @max_v152mpositiontaking_51 end end
select @v152mpositiontaking_52 = case when isnull(@isauto_v152mpositiontaking_52, 0)=0 then @v152mpositiontaking_52 else case when @auto_v152mpositiontaking_52 < @max_v152mpositiontaking_52 then @auto_v152mpositiontaking_52 else @max_v152mpositiontaking_52 end end

--v153
select @v153mpositiontaking_51 = case when isnull(@isauto_v153mpositiontaking_51, 0)=0 then @v153mpositiontaking_51 else case when @auto_v153mpositiontaking_51 < @max_v153mpositiontaking_51 then @auto_v153mpositiontaking_51 else @max_v153mpositiontaking_51 end end
select @v153mpositiontaking_52 = case when isnull(@isauto_v153mpositiontaking_52, 0)=0 then @v153mpositiontaking_52 else case when @auto_v153mpositiontaking_52 < @max_v153mpositiontaking_52 then @auto_v153mpositiontaking_52 else @max_v153mpositiontaking_52 end end

--v201
select @v201mpositiontaking_2 = case when isnull(@isauto_v201mpositiontaking_2, 0)=0 then @v201mpositiontaking_2 else case when @auto_v201mpositiontaking_2 < @max_v201mpositiontaking_2 then @auto_v201mpositiontaking_2 else @max_v201mpositiontaking_2 end end
select @v201mpositiontaking_3 = case when isnull(@isauto_v201mpositiontaking_3, 0)=0 then @v201mpositiontaking_3 else case when @auto_v201mpositiontaking_3 < @max_v201mpositiontaking_3 then @auto_v201mpositiontaking_3 else @max_v201mpositiontaking_3 end end

--v162
select @v162mpositiontaking_1101 = case when isnull(@isauto_v162mpositiontaking_1101, 0) = 0 then @v162mpositiontaking_1101 else case when @auto_v162mpositiontaking_1101 < @max_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @max_v162mpositiontaking_1101 end end

--v180
select @v180mpositiontaking_1201 = case when isnull(@isauto_v180mpositiontaking_1201, 0) = 0 then @v180mpositiontaking_1201 else case when @auto_v180mpositiontaking_1201 < @max_v180mpositiontaking_1201 then @auto_v180mpositiontaking_1201 else @max_v180mpositiontaking_1201 end end

----------------***Use Auto Position Taking***----------------------------------
--use @auto_spt at master only (not exist in member yet)
--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
--if @auto_spt = 0 then @spt = @spt
--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
--		else @spt = @max_spt - @mpt - @apt
select @spositiontaking_1 = case when isnull(@isauto_spositiontaking_1, 0)=0 then @spositiontaking_1 else case when @auto_spositiontaking_1 < @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 then @auto_spositiontaking_1 else @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 end end
select @spositiontaking_3 = case when isnull(@isauto_spositiontaking_3, 0)=0 then @spositiontaking_3 else case when @auto_spositiontaking_3 < @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 then @auto_spositiontaking_3 else @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 end end
select @spositiontaking_7 = case when isnull(@isauto_spositiontaking_7, 0)=0 then @spositiontaking_7 else case when @auto_spositiontaking_7 < @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 then @auto_spositiontaking_7 else @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 end end
select @spositiontaking_8 = case when isnull(@isauto_spositiontaking_8, 0)=0 then @spositiontaking_8 else case when @auto_spositiontaking_8 < @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 then @auto_spositiontaking_8 else @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 end end

select @slivepositiontaking_1 = case when isnull(@isauto_slivepositiontaking_1, 0)=0 then @slivepositiontaking_1 else case when @auto_slivepositiontaking_1 < @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 then @auto_slivepositiontaking_1 else @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 end end
select @slivepositiontaking_3 = case when isnull(@isauto_slivepositiontaking_3, 0)=0 then @slivepositiontaking_3 else case when @auto_slivepositiontaking_3 < @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 then @auto_slivepositiontaking_3 else @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 end end
select @slivepositiontaking_7 = case when isnull(@isauto_slivepositiontaking_7, 0)=0 then @slivepositiontaking_7 else case when @auto_slivepositiontaking_7 < @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 then @auto_slivepositiontaking_7 else @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 end end
select @slivepositiontaking_8 = case when isnull(@isauto_slivepositiontaking_8, 0)=0 then @slivepositiontaking_8 else case when @auto_slivepositiontaking_8 < @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 then @auto_slivepositiontaking_8 else @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 end end

select @spositiontaking_2 = case when isnull(@isauto_spositiontaking_2, 0)=0 then @spositiontaking_2 else case when @auto_spositiontaking_2 < @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 then @auto_spositiontaking_2 else @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 end end
select @spositiontaking_4 = case when isnull(@isauto_spositiontaking_4, 0)=0 then @spositiontaking_4 else case when @auto_spositiontaking_4 < @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 then @auto_spositiontaking_4 else @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 end end
select @spositiontaking_5 = case when isnull(@isauto_spositiontaking_5, 0)=0 then @spositiontaking_5 else case when @auto_spositiontaking_5 < @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 then @auto_spositiontaking_5 else @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 end end
select @spositiontaking_6 = case when isnull(@isauto_spositiontaking_6, 0)=0 then @spositiontaking_6 else case when @auto_spositiontaking_6 < @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 then @auto_spositiontaking_6 else @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 end end
select @spositiontaking_9 = case when isnull(@isauto_spositiontaking_9, 0)=0 then @spositiontaking_9 else case when @auto_spositiontaking_9 < @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 then @auto_spositiontaking_9 else @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 end end
select @spositiontaking_10 = case when isnull(@isauto_spositiontaking_10, 0)=0 then @spositiontaking_10 else case when @auto_spositiontaking_10 < @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 then @auto_spositiontaking_10 else @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 end end

select @v2spositiontaking_1 = case when isnull(@isauto_v2spositiontaking_1, 0)=0 then @v2spositiontaking_1 else case when @auto_v2spositiontaking_1 < @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 then @auto_v2spositiontaking_1 else @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 end end
select @v2spositiontaking_2 = case when isnull(@isauto_v2spositiontaking_2, 0)=0 then @v2spositiontaking_2 else case when @auto_v2spositiontaking_2 < @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 then @auto_v2spositiontaking_2 else @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 end end
select @v2spositiontaking_3 = case when isnull(@isauto_v2spositiontaking_3, 0)=0 then @v2spositiontaking_3 else case when @auto_v2spositiontaking_3 < @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 then @auto_v2spositiontaking_3 else @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 end end
select @v2spositiontaking_7 = case when isnull(@isauto_v2spositiontaking_7, 0)=0 then @v2spositiontaking_7 else case when @auto_v2spositiontaking_7 < @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 then @auto_v2spositiontaking_7 else @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 end end
select @v2spositiontaking_8 = case when isnull(@isauto_v2spositiontaking_8, 0)=0 then @v2spositiontaking_8 else case when @auto_v2spositiontaking_8 < @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 then @auto_v2spositiontaking_8 else @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 end end
--select @v2spositiontaking_9 = case when isnull(@isauto_v2spositiontaking_9, 0)=0 then @v2spositiontaking_9 else case when @auto_v2spositiontaking_9 < @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 then @auto_v2spositiontaking_9 else @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 end end
select @v2spositiontaking_20 = case when isnull(@isauto_v2spositiontaking_20, 0)=0 then @v2spositiontaking_20 else case when @auto_v2spositiontaking_20 < @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 then @auto_v2spositiontaking_20 else @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 end end

select @v3spositiontaking_1 = case when isnull(@isauto_v3spositiontaking_1, 0)=0 then @v3spositiontaking_1 else case when @auto_v3spositiontaking_1 < @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 then @auto_v3spositiontaking_1 else @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 end end
select @v3spositiontaking_2 = case when isnull(@isauto_v3spositiontaking_2, 0)=0 then @v3spositiontaking_2 else case when @auto_v3spositiontaking_2 < @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 then @auto_v3spositiontaking_2 else @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 end end
select @v3spositiontaking_3 = case when isnull(@isauto_v3spositiontaking_3, 0)=0 then @v3spositiontaking_3 else case when @auto_v3spositiontaking_3 < @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 then @auto_v3spositiontaking_3 else @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 end end
select @v3spositiontaking_20 = case when isnull(@isauto_v3spositiontaking_20, 0)=0 then @v3spositiontaking_20 else case when @auto_v3spositiontaking_20 < @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 then @auto_v3spositiontaking_20 else @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 end end

select @v5spositiontaking_1 = case when isnull(@isauto_v5spositiontaking_1, 0)=0 then @v5spositiontaking_1 else case when @auto_v5spositiontaking_1 < @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 then @auto_v5spositiontaking_1 else @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 end end
select @v5spositiontaking_2 = case when isnull(@isauto_v5spositiontaking_2, 0)=0 then @v5spositiontaking_2 else case when @auto_v5spositiontaking_2 < @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 then @auto_v5spositiontaking_2 else @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 end end
select @v5spositiontaking_3 = case when isnull(@isauto_v5spositiontaking_3, 0)=0 then @v5spositiontaking_3 else case when @auto_v5spositiontaking_3 < @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 then @auto_v5spositiontaking_3 else @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 end end
select @v5spositiontaking_20 = case when isnull(@isauto_v5spositiontaking_20, 0)=0 then @v5spositiontaking_20 else case when @auto_v5spositiontaking_20 < @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 then @auto_v5spositiontaking_20 else @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 end end

select @v8spositiontaking_1 = case when isnull(@isauto_v8spositiontaking_1, 0)=0 then @v8spositiontaking_1 else case when @auto_v8spositiontaking_1 < @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 then @auto_v8spositiontaking_1 else @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 end end
select @v8spositiontaking_3 = case when isnull(@isauto_v8spositiontaking_3, 0)=0 then @v8spositiontaking_3 else case when @auto_v8spositiontaking_3 < @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 then @auto_v8spositiontaking_3 else @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 end end
select @v8spositiontaking_20 = case when isnull(@isauto_v8spositiontaking_20, 0)=0 then @v8spositiontaking_20 else case when @auto_v8spositiontaking_20 < @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 then @auto_v8spositiontaking_20 else @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 end end

select @v10spositiontaking_1 = case when isnull(@isauto_v10spositiontaking_1, 0)=0 then @v10spositiontaking_1 else case when @auto_v10spositiontaking_1 < @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 then @auto_v10spositiontaking_1 else @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 end end
select @v10spositiontaking_2 = case when isnull(@isauto_v10spositiontaking_2, 0)=0 then @v10spositiontaking_2 else case when @auto_v10spositiontaking_2 < @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 then @auto_v10spositiontaking_2 else @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 end end
select @v10spositiontaking_3 = case when isnull(@isauto_v10spositiontaking_3, 0)=0 then @v10spositiontaking_3 else case when @auto_v10spositiontaking_3 < @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 then @auto_v10spositiontaking_3 else @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 end end
select @v10spositiontaking_20 = case when isnull(@isauto_v10spositiontaking_20, 0)=0 then @v10spositiontaking_20 else case when @auto_v10spositiontaking_20 < @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 then @auto_v10spositiontaking_20 else @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 end end

select @v11spositiontaking_1 = case when isnull(@isauto_v11spositiontaking_1, 0)=0 then @v11spositiontaking_1 else case when @auto_v11spositiontaking_1 < @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 then @auto_v11spositiontaking_1 else @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 end end
select @v11spositiontaking_20 = case when isnull(@isauto_v11spositiontaking_20, 0)=0 then @v11spositiontaking_20 else case when @auto_v11spositiontaking_20 < @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 then @auto_v11spositiontaking_20 else @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 end end

select @v99spositiontaking_1 = case when isnull(@isauto_v99spositiontaking_1, 0)=0 then @v99spositiontaking_1 else case when @auto_v99spositiontaking_1 < @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 then @auto_v99spositiontaking_1 else @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 end end
select @v99spositiontaking_2 = case when isnull(@isauto_v99spositiontaking_2, 0)=0 then @v99spositiontaking_2 else case when @auto_v99spositiontaking_2 < @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 then @auto_v99spositiontaking_2 else @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 end end
select @v99spositiontaking_3 = case when isnull(@isauto_v99spositiontaking_3, 0)=0 then @v99spositiontaking_3 else case when @auto_v99spositiontaking_3 < @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 then @auto_v99spositiontaking_3 else @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 end end
select @v99spositiontaking_9 = case when isnull(@isauto_v99spositiontaking_9, 0)=0 then @v99spositiontaking_9 else case when @auto_v99spositiontaking_9 < @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 then @auto_v99spositiontaking_9 else @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 end end
select @v99spositiontaking_20 = case when isnull(@isauto_v99spositiontaking_20, 0)=0 then @v99spositiontaking_20 else case when @auto_v99spositiontaking_20 < @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 then @auto_v99spositiontaking_20 else @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 end end



--v161
select @v161spositiontaking_81 = case when isnull(@isauto_v161spositiontaking_81, 0)=0 then @v161spositiontaking_81 else case when @auto_v161spositiontaking_81 < @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 then @auto_v161spositiontaking_81 else @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 end end
select @v161spositiontaking_83 = case when isnull(@isauto_v161spositiontaking_83, 0)=0 then @v161spositiontaking_83 else case when @auto_v161spositiontaking_83 < @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 then @auto_v161spositiontaking_83 else @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 end end
select @v161spositiontaking_86 = case when isnull(@isauto_v161spositiontaking_86, 0)=0 then @v161spositiontaking_86 else case when @auto_v161spositiontaking_86 < @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 then @auto_v161spositiontaking_86 else @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 end end
select @v161spositiontaking_88 = case when isnull(@isauto_v161spositiontaking_88, 0)=0 then @v161spositiontaking_88 else case when @auto_v161spositiontaking_88 < @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 then @auto_v161spositiontaking_88 else @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 end end

select @v161slivepositiontaking_85 = case when isnull(@isauto_v161slivepositiontaking_85, 0)=0 then @v161slivepositiontaking_85 else case when @auto_v161slivepositiontaking_85 < @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 then @auto_v161slivepositiontaking_85 else @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 end end
select @v161slivepositiontaking_86 = case when isnull(@isauto_v161slivepositiontaking_86, 0)=0 then @v161slivepositiontaking_86 else case when @auto_v161slivepositiontaking_86 < @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 then @auto_v161slivepositiontaking_86 else @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 end end
select @v161slivepositiontaking_87 = case when isnull(@isauto_v161slivepositiontaking_87, 0)=0 then @v161slivepositiontaking_87 else case when @auto_v161slivepositiontaking_87 < @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 then @auto_v161slivepositiontaking_87 else @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 end end
select @v161slivepositiontaking_89 = case when isnull(@isauto_v161slivepositiontaking_89, 0)=0 then @v161slivepositiontaking_89 else case when @auto_v161slivepositiontaking_89 < @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 then @auto_v161slivepositiontaking_89 else @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 end end
select @v161slivepositiontaking_90 = case when isnull(@isauto_v161slivepositiontaking_90, 0)=0 then @v161slivepositiontaking_90 else case when @auto_v161slivepositiontaking_90 < @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 then @auto_v161slivepositiontaking_90 else @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 end end


--v151
select @v151spositiontaking_31 = case when isnull(@isauto_v151spositiontaking_31, 0)=0 then @v151spositiontaking_31 else case when @auto_v151spositiontaking_31 < @max_v151spositiontaking_31 - @v151mpositiontaking_31 then @auto_v151spositiontaking_31 else @max_v151spositiontaking_31 - @v151mpositiontaking_31 end end
select @v151spositiontaking_32 = case when isnull(@isauto_v151spositiontaking_32, 0)=0 then @v151spositiontaking_32 else case when @auto_v151spositiontaking_32 < @max_v151spositiontaking_32 - @v151mpositiontaking_32 then @auto_v151spositiontaking_32 else @max_v151spositiontaking_32 - @v151mpositiontaking_32 end end
select @v151spositiontaking_41 = case when isnull(@isauto_v151spositiontaking_41, 0)=0 then @v151spositiontaking_41 else case when @auto_v151spositiontaking_41 < @max_v151spositiontaking_41 - @v151mpositiontaking_41 then @auto_v151spositiontaking_41 else @max_v151spositiontaking_41 - @v151mpositiontaking_41 end end
select @v151spositiontaking_42 = case when isnull(@isauto_v151spositiontaking_42, 0)=0 then @v151spositiontaking_42 else case when @auto_v151spositiontaking_42 < @max_v151spositiontaking_42 - @v151mpositiontaking_42 then @auto_v151spositiontaking_42 else @max_v151spositiontaking_42 - @v151mpositiontaking_42 end end
select @v151spositiontaking_51 = case when isnull(@isauto_v151spositiontaking_51, 0)=0 then @v151spositiontaking_51 else case when @auto_v151spositiontaking_51 < @max_v151spositiontaking_51 - @v151mpositiontaking_51 then @auto_v151spositiontaking_51 else @max_v151spositiontaking_51 - @v151mpositiontaking_51 end end
select @v151spositiontaking_52 = case when isnull(@isauto_v151spositiontaking_52, 0)=0 then @v151spositiontaking_52 else case when @auto_v151spositiontaking_52 < @max_v151spositiontaking_52 - @v151mpositiontaking_52 then @auto_v151spositiontaking_52 else @max_v151spositiontaking_52 - @v151mpositiontaking_52 end end

--v152
select @v152spositiontaking_41 = case when isnull(@isauto_v152spositiontaking_41, 0)=0 then @v152spositiontaking_41 else case when @auto_v152spositiontaking_41 < @max_v152spositiontaking_41 - @v152mpositiontaking_41 then @auto_v152spositiontaking_41 else @max_v152spositiontaking_41 - @v152mpositiontaking_41 end end
select @v152spositiontaking_42 = case when isnull(@isauto_v152spositiontaking_42, 0)=0 then @v152spositiontaking_42 else case when @auto_v152spositiontaking_42 < @max_v152spositiontaking_42 - @v152mpositiontaking_42 then @auto_v152spositiontaking_42 else @max_v152spositiontaking_42 - @v152mpositiontaking_42 end end
select @v152spositiontaking_51 = case when isnull(@isauto_v152spositiontaking_51, 0)=0 then @v152spositiontaking_51 else case when @auto_v152spositiontaking_51 < @max_v152spositiontaking_51 - @v152mpositiontaking_51 then @auto_v152spositiontaking_51 else @max_v152spositiontaking_51 - @v152mpositiontaking_51 end end
select @v152spositiontaking_52 = case when isnull(@isauto_v152spositiontaking_52, 0)=0 then @v152spositiontaking_52 else case when @auto_v152spositiontaking_52 < @max_v152spositiontaking_52 - @v152mpositiontaking_52 then @auto_v152spositiontaking_52 else @max_v152spositiontaking_52 - @v152mpositiontaking_52 end end

--v153
select @v153spositiontaking_51 = case when isnull(@isauto_v153spositiontaking_51, 0)=0 then @v153spositiontaking_51 else case when @auto_v153spositiontaking_51 < @max_v153spositiontaking_51 - @v153mpositiontaking_51 then @auto_v153spositiontaking_51 else @max_v153spositiontaking_51 - @v153mpositiontaking_51 end end
select @v153spositiontaking_52 = case when isnull(@isauto_v153spositiontaking_52, 0)=0 then @v153spositiontaking_52 else case when @auto_v153spositiontaking_52 < @max_v153spositiontaking_52 - @v153mpositiontaking_52 then @auto_v153spositiontaking_52 else @max_v153spositiontaking_52 - @v153mpositiontaking_52 end end

---------------------

--v201
select @v201spositiontaking_2 = case when isnull(@isauto_v201spositiontaking_2, 0)=0 then @v201spositiontaking_2 else case when @auto_v201spositiontaking_2 < @max_v201spositiontaking_2 - @v201mpositiontaking_2 then @auto_v201spositiontaking_2 else @max_v201spositiontaking_2 - @v201mpositiontaking_2 end end
select @v201spositiontaking_3 = case when isnull(@isauto_v201spositiontaking_3, 0)=0 then @v201spositiontaking_3 else case when @auto_v201spositiontaking_3 < @max_v201spositiontaking_3 - @v201mpositiontaking_3 then @auto_v201spositiontaking_3 else @max_v201spositiontaking_3 - @v201mpositiontaking_3 end end
---------------------

--v162
select @v162spositiontaking_1101 = case when isnull(@isauto_v162spositiontaking_1101, 0) = 0 then @v162spositiontaking_1101 else case when @auto_v162spositiontaking_1101 < @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 then @auto_v162spositiontaking_1101 else @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 end end

--v180
select @v180spositiontaking_1201 = case when isnull(@isauto_v180spositiontaking_1201, 0) = 0 then @v180spositiontaking_1201 else case when @auto_v180spositiontaking_1201 < @max_v180spositiontaking_1201 - @v180mpositiontaking_1201 then @auto_v180spositiontaking_1201 else @max_v180spositiontaking_1201 - @v180mpositiontaking_1201 end end


select @adiscount =  case when @ugroup in ('a','hka','dea') then groupa when @ugroup in ('b','hkb','deb') then groupb when @ugroup in ('c','hkc','dec') then groupc else groupd end
from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @adiscountcs =  adiscount from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
--1x2
select @adiscount1x2 = adiscount from custsetting with (NOLOCK) where custid = @mrecommend and bettype = 5 and sporttype =1 

--v151 adiscount
select @v151adiscount_31 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=31 and sporttype=151

select @v151adiscount_41 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=151

select @v151adiscount_51 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=151

--v152 adiscount
select @v152adiscount_41 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=152

select @v152adiscount_51 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=152

--v153 adiscount
select @v153adiscount_51 = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=153

--v161 adiscount
select @adiscountnumber = adiscount from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype = 81 and sporttype =161

--v201
select @v201adiscount = adiscount 
from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=201

--v162
select @v162adiscount_1101 = adiscount
from CustSettingGame with(NOLOCK) where custid = @mrecommend and bettype = 1101 and sporttype = 162


select @sdiscount =  case when @ugroup in ('a','hka','dea') then groupa when @ugroup in ('b','hkb','deb') then groupb when @ugroup in ('c','hkc','dec') then groupc else groupd end
from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @sdiscountcs =  sdiscount from custsetting with (NOLOCK) where custid = @srecommend and bettype=4 and sporttype=1

--1x2 
select @sdiscount1x2 =  sdiscount from custsetting with (NOLOCK) where custid = @srecommend and bettype=5 and sporttype=1

--v151 sdiscount
select @v151sdiscount_31 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=31 and sporttype=151

select @v151sdiscount_41 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=151

select @v151sdiscount_51 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=151

--v152 sdiscount
select @v152sdiscount_41 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=152

select @v152sdiscount_51 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=152

--v153 sdiscount
select @v153sdiscount_51 = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=153

--v161 sdiscount
select @sdiscountnumber =  sdiscount from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=81 and sporttype=161

--v201
select @v201sdiscount = sdiscount 
from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=201

--v162 
select @v162sdiscount_1101 = sdiscount
from custsettinggame with(nolock) where custid = @srecommend and bettype = 1101 and sporttype = 162

--select 
--	@discount = case when @discount>@maxdiscount then @maxdiscount else @discount end,
--	@discountcs = case when @discountcs>@maxdiscountcs then @maxdiscountcs else @discountcs 

-- NOTE : agent discount  get value from custsetting which Master set to them
-- 	change code to get value direct to @discount , @discountcs  instead of pass to @maxdiscount , @maxdiscountcs

--select 
--	@playerdiscount = case when @playerdiscount>@discount then @discount else @playerdiscount end,
--	@playerdiscountcs = case when @playerdiscountcs>@discountcs then @discountcs else @playerdiscountcs end


--Check valid commission
--Commission for Sportsbook
select @adiscount = case when @adiscount > @sdiscount then @sdiscount else @adiscount end
select @discount = case when @discount > @adiscount then @adiscount else @discount end

select @adiscountcs = case when @adiscountcs > @sdiscountcs then @sdiscountcs else @adiscountcs end
select @discountcs = case when @discountcs > @adiscountcs then @adiscountcs else @discountcs end

--Commission 1x2 
select @adiscount1x2 = case when @adiscount1x2 > @sdiscount1x2 then @sdiscount1x2 else @adiscount1x2 end
select @discount1x2 = case when @discount1x2 > @adiscount1x2 then @adiscount1x2 else @discount1x2 end

--Commission for HR
select @v151adiscount_31 = case when @v151adiscount_31 > @v151sdiscount_31 then @v151sdiscount_31 else @v151adiscount_31 end

select @v151adiscount_41 = case when @v151adiscount_41 > @v151sdiscount_41 then @v151sdiscount_41 else @v151adiscount_41 end

select @v151adiscount_51 = case when @v151adiscount_51 > @v151sdiscount_51 then @v151sdiscount_51 else @v151adiscount_51 end

--Commission for Greyhound
select @v152adiscount_41 = case when @v152adiscount_41 > @v152sdiscount_41 then @v152sdiscount_41 else @v152adiscount_41 end

select @v152adiscount_51 = case when @v152adiscount_51 > @v152sdiscount_51 then @v152sdiscount_51 else @v152adiscount_51 end

--Commission for Harness
select @v153adiscount_51 = case when @v153adiscount_51 > @v153sdiscount_51 then @v153sdiscount_51 else @v153adiscount_51 end

--Commission for FI
select @v201adiscount = case when @v201adiscount > @v201sdiscount then @v201sdiscount else @v201adiscount end
select @v201discount = case when @v201discount > @v201adiscount then @v201adiscount else @v201discount end

--Commission for Number Game
select @adiscountnumber = case when @adiscountnumber > @sdiscountnumber then @sdiscountnumber else @adiscountnumber end
select @discountnumber = case when @discountnumber > @adiscountnumber then @adiscountnumber else @discountnumber end

--v162
select @v162adiscount_1101 = case when @v162adiscount_1101 > @v162sdiscount_1101 then @v162sdiscount_1101 else @v162adiscount_1101 end
select @v162discount_1101 = case when @v162discount_1101 > @v162adiscount_1101 then @v162adiscount_1101 else @v162discount_1101 end

select
	@playerdiscount = case when @playerdiscount > @discount then @discount else @playerdiscount end,
	@playerdiscountcs = case when @playerdiscountcs > @discountcs then @discountcs else @playerdiscountcs end,
	--1x2
	@playerdiscount1x2 = case when @playerdiscount1x2 > @discount1x2 then @discount1x2 else @playerdiscount1x2 end,
	--v151
	@v151playerdiscount_31 = case when @v151playerdiscount_31 > @v151discount_31 then @v151discount_31 else @v151playerdiscount_31 end,
	@v151playerdiscount_41 = case when @v151playerdiscount_41 > @v151discount_41 then @v151discount_41 else @v151playerdiscount_41 end,
	@v151playerdiscount_51 = case when @v151playerdiscount_51 > @v151discount_51 then @v151discount_51 else @v151playerdiscount_51 end,
	--v152
	@v152playerdiscount_41 = case when @v152playerdiscount_41 > @v152discount_41 then @v152discount_41 else @v152playerdiscount_41 end,
	@v152playerdiscount_51 = case when @v152playerdiscount_51 > @v152discount_51 then @v152discount_51 else @v152playerdiscount_51 end,
	--v153
	@v153playerdiscount_51 = case when @v153playerdiscount_51 > @v153discount_51 then @v153discount_51 else @v153playerdiscount_51 end,
	--v161
	@playerdiscountnumber = case when @playerdiscountnumber > @discountnumber then @discountnumber else @playerdiscountnumber end

--End check valid commission
	

Select @Credit_AllOtherMember = IsNull(sum(Credit), 0) from custinfo with (NOLOCK) where Recommend = @Recommend and RoleID = 1
select @MaxCredit_Mem = case when @MaxCredit_Mem =0 then (@AgentCredit - @Credit_AllOtherMember) 
						else @MaxCredit_Mem end 
If @Credit + @Credit_AllOtherMember>@AgentCredit
BEGIN
	SELECT @ErrMsg =	case @Language 
							when 'E' then 'Sorry, increase credit unsuccessfully, You have exceeded your agent credit.'
							when 'CS' then N'对不起，更新信用额度不成功，已超出代理信用额度.'
							when 'CT' then N'對不起,更新信用額度不成功, 已超出代理信用額度.'
							when 'TH' then N'ขออภัย การเพิ่มจำนวนยอดเงินในบัญชี ไม่เป็นผล เนื่องจากคุณได้มียอดเกินจำนวนเงินในบัญชีของตัวแทนคะ.'
							when 'J' then N'増加の信用不運にも残念、あなたの代理店の信用を超過した'
							when 'ES' then N'Lo lamentamos, aumento de crédito sin éxito. Ha excedido su credito de agente.'
							when 'KO' then N'죄송합니다. 크레딧 증가에 실패했습니다. 해당 에이전트의 크레딧을 초과 했습니다.'
							else N'Sorry, increase credit unsuccessfully, You have exceeded your agent credit.'
						end	
			,@success = 0, @ErrCode = 204
	return
END

If @Credit > @MaxCredit_Mem 
BEGIN
	SELECT @ErrMsg =	case @Language 
							when 'E' then 'Sorry, increase credit unsuccessfully, You have exceeded the member max credit.'
							when 'CS' then N'对不起，更新信用额度不成功，已超出会员信用额度.'
							when 'CT' then N'對不起,更新信用額度不成功, 已超出會員最高信用額度.'
							when 'TH' then N'ขออภัย  การเพิ่มจำนวนยอดเงินในบัญชี ไม่เป็นผล เนื่องจากคุณได้มียอดเกินจำนวนเงินสูงสุดในบัญชีของสมาชิกคะ.'
							when 'J' then N'Sorry, increase credit unsuccessfully, You have exceeded the member max credit'
							when 'ES' then N'Sorry, increase credit unsuccessfully, You have exceeded the member max credit.'
							when 'KO' then N'죄송합니다. 크레딧 증가에 실패했습니다. 회원님의 최대 크레딧을 초과 했습니다.'
							else N'Sorry, increase credit unsuccessfully, You have exceeded the member max credit.'
						end	
			,@success = 0, @ErrCode =217
	return
END 
/*
Select @MaxPerMatch_AllOtherMember = IsNull(sum(MaxPerMatch), 0) from custinfo with (NOLOCK) where Recommend = @Recommend and RoleID = 1

If @MaxPerMatch + @MaxPerMatch_AllOtherMember>@AgentMaxPerMatch
BEGIN
	SELECT @ErrMsg =	case @Language 
							when 'E' then 'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							when 'CS' then N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							when 'J' then N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
							else N'Sorry, increase Max Per Match unsuccessfully, You have exceeded your agent Max Per Match.'
						end	
			,@success = 0, @ErrCode = 104
	RaisError(@ErrMsg, 16, 1)
	return
END

Select @MaxPerMatchv2_AllOtherMember = IsNull(sum(MaxPerMatchb), 0) from custinfo with (NOLOCK) where Recommend = @Recommend and RoleID = 1

If @MaxPerMatchv2 + @MaxPerMatchv2_AllOtherMember>@AgentMaxPerMatchb
BEGIN
	SELECT @ErrMsg =	case @Language 
							when 'E' then 'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							when 'CS' then N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							when 'J' then N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
							else N'Sorry, increase Max Per Match (Basketball) unsuccessfully, You have exceeded your agent Max Per Match (Basketball).'
						end	
			,@success = 0, @ErrCode = 104
	RaisError(@ErrMsg, 16, 1)
	return
END
*/
SET ANSI_WARNINGS OFF
Select 
	@MinMinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @Recommend

Select 
	@MinMinBetv2 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv2 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @Recommend

Select 
	@MinMinBetv3 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv3 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @Recommend

Select 
	@MinMinBetv5 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv5 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @Recommend

Select 
	@MinMinBetv8 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv8 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @Recommend

Select 
	@MinMinBetv10 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv10 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @Recommend

Select 
	@MinMinBetv11 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv11 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @Recommend

--v151
--Select 
--	@MinMinBetv151 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
--	@MaxMaxBetv151 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
--from 
--	custsetting as cs WITH (NOLOCK)
--	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 31 and cs.sporttype=151
--where ci.custid = @Recommend

Select 
	@MinMinBetv99 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv99 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @Recommend

--Mix Parlay Mixed Sports
Select 
	@MinMinBetv99MP = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv99MP = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=99
where ci.custid = @Recommend

--v161
Select 
	@MinMinBetv161 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv161 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	CustSetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 81 and cs.sporttype=161
where ci.custid = @Recommend

--VS

Select 
	@MinMinBetv180 = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBetv180 = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1201 and cs.sporttype=180
where ci.custid = @Recommend

select @minbetv180 = Isnull(MinBet, 0), @maxbetv180 = isnull(MaxBet, 0) 
from custsetting3rd with (NOLOCK) 
where custid = @Recommend and bettype= 1201 and sporttype=180

IF @MinMinBetv180>0 and @minbetv180>0 and @minbetv180<@MinMinBetv180
	SET @minbetv180 = @MinMinBetv180
	
IF @MaxMaxBetv180>0 and @maxbetv180>0 and @maxbetv180>@MaxMaxBetv180
	SET @maxbetv180 = @MaxMaxBetv180

Select	
	@MaxMaxperMatch = IsNull(Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),0), 
	@MaxMaxPerMatchv2 = IsNull(Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),0),
	@MaxMaxPerMatchv3 = IsNull(Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),0),
	@MaxMaxPerMatchv5 = IsNull(Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),0),
	@MaxMaxPerMatchv8 = IsNull(Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),0),
	@MaxMaxPerMatchv10 = IsNull(Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),0),
	@MaxMaxPerMatchv11 = IsNull(Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),0),
	@MaxMaxPerMatchv99 = IsNull(Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),0),
	@MaxMaxPerMatchv99MP = 	IsNull(Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),0),
	@MaxMaxPerMatchv161 = 	IsNull(Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0),
	@MaxMaxPerBallv161 = IsNull(Min(case when cs.MaxPerBall161 = 0 then null else cs.MaxPerBall161 end),0),
	@MaxMaxPerMatchv180 = IsNull(Min(case when cs.MaxPerMatch180 = 0 then NULL else cs.MaxPerMatch180 end),0)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @Recommend
SET ANSI_WARNINGS ON

-- VS
IF @MaxMaxPerMatchv180>0 and @MaxPerMatchv180>0 and @MaxPerMatchv180>@MaxMaxPerMatchv180
	SET @MaxPerMatchv180 = @MaxMaxPerMatchv180
	
IF (@minbetv180<>0 and @maxbetv180 <> 0 and  @minbetv180>@maxbetv180) 
	or (@maxbetv180<> 0 and @MaxPerMatchv180 <> 0 and @maxbetv180>@MaxPerMatchv180) 
	or (@minbetv180 <> 0 and @MaxPerMatchv180 <> 0 and @minbetv180>@MaxPerMatchv180)	
BEGIN
	SELECT @minbetv180=0, @maxbetv180 = 0, @MaxPerMatchv180 = 0 
END	

--Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline
--if ((@minbetv151 < @MinMinBetv151 or @maxbetv151 > @MaxMaxBetv151 or @MaxPerMatchv151 > @MaxMaxPerMatchv151) 
--	and not (@minbetv151 = 0 and @maxbetv151 = 0 and @MaxPerMatchv151 = 0))
--	Select @minbetv151 = @MinMinBetv151,
--			@maxbetv151 = @MaxMaxBetv151,
--			@MaxPerMatchv151 = @MaxMaxPerMatchv151
--End Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline

select @ErrType = ''
select @ErrType = @ErrType + (case when MP=0 then sportname else 'Mixed Sports' end )   + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype,0 as MP, @MinBet as MinBet, @MinMinBet as MinMinBet
	union all	select 2 as sporttype,0 as MP, @MinBetv2 as MinBet, @MinMinBetv2 as MinMinBet
	union all	select 3 as sporttype,0 as MP, @MinBetv3 as MinBet, @MinMinBetv3 as MinMinBet
	union all	select 5 as sporttype,0 as MP, @MinBetv5 as MinBet, @MinMinBetv5 as MinMinBet
	union all	select 8 as sporttype,0 as MP, @MinBetv8 as MinBet, @MinMinBetv8 as MinMinBet
	union all	select 10 as sporttype,0 as MP, @MinBetv10 as MinBet, @MinMinBetv10 as MinMinBet
	union all	select 11 as sporttype,0 as MP, @MinBetv11 as MinBet, @MinMinBetv11 as MinMinBet
	union all	select 99 as sporttype,0 as MP, @MinBetv99 as MinBet, @MinMinBetv99 as MinMinBet	 
	union all	select 99 as sporttype,1 as MP, @MinBetv99MP as MinBet, @MinMinBetv99MP as MinMinBet	
	union all	select 161 as sporttype,0 as MP, @MinBetv161 as MinBet, @MinMinBetv161 as MinMinBet	
) as b on sports.sporttype = b.sporttype
where MinMinBet>0 and MinBet>0 and MinBet<MinMinBet
if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be equal to or greater than Super/Master/Agent min bet ('+@ErrType+').'
							when 'CS' then N'对不起，最低投注需相等于或少于超级总代理最低投注('+@ErrType+').'
							when 'CT' then N'對不起,最低投注需相等於或少於超級總代理最低投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินในการเล่นขั้นต่ำ ต้องเท่ากับ หรือ มากกว่าขั้นต่ำที่กำหนดไว้ ของ ตัวแทนสูงสุด/ ตัวแทนหลัก/ ตัวแทนย่อย ('+@ErrType+').'
							when 'J' then N'Sorry, min bet must be equal to or greater than Super/Master/Agent min bet ('+@ErrType+').'
							when 'ES' then N'Sorry, min bet must be equal to or greater than Super/Master/Agent min bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최소 배팅은 슈퍼/마스터/에이젼트 최소 배팅보다 많아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be equal to or greater than Super/Master/Agent min bet ('+@ErrType+').'
					end										
	Select @ErrCode = 205
	return
END

select @ErrType = ''
select @ErrType = @ErrType + (case when MP=0 then sportname else 'Mixed Sports' end )   + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype,0 as MP, @MaxBet as MaxBet, @MaxMaxBet as MaxMaxBet
	union all	select 2 as sporttype,0 as MP, @MaxBetv2 as MaxBet, @MaxMaxBetv2 as MaxMaxBet
	union all	select 3 as sporttype,0 as MP, @MaxBetv3 as MaxBet, @MaxMaxBetv3 as MaxMaxBet
	union all	select 5 as sporttype,0 as MP, @MaxBetv5 as MaxBet, @MaxMaxBetv5 as MaxMaxBet
	union all	select 8 as sporttype,0 as MP, @MaxBetv8 as MaxBet, @MaxMaxBetv8 as MaxMaxBet
	union all	select 10 as sporttype,0 as MP, @MaxBetv10 as MaxBet, @MaxMaxBetv10 as MaxMaxBet
	union all	select 11 as sporttype,0 as MP, @MaxBetv11 as MaxBet, @MaxMaxBetv11 as MaxMaxBet
	union all	select 99 as sporttype,0 as MP, @MaxBetv99 as MaxBet, @MaxMaxBetv99 as MaxMaxBet	 
	union all	select 99 as sporttype,1 as MP, @MaxBetv99MP as MaxBet, @MaxMaxBetv99MP as MaxMaxBet	 
	union all	select 161 as sporttype,0 as MP, @MaxBetv161 as MaxBet, @MaxMaxBetv161 as MaxMaxBet	 
	
) as b on sports.sporttype = b.sporttype
where MaxMaxBet>0 and MaxBet>0 and MaxBet>MaxMaxBet
if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, max bet must be equal to or less than Master/Agent max bet ('+@ErrType+').'
							when 'CS' then N'对不起，最高投注需相等于或少于总代理/代理最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,最高投注需相等於或少於總代理/代理最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินสูงสุดที่สามารถเล่นได้ ต้องเท่ากับ หรือ  น้อยกว่า จำนวนเงินสูงสุดที่กำหนดไว้ของตัวแทนหรือตัวแทนหลัก ('+@ErrType+').'
							when 'J' then N'Sorry, max bet must be equal to or less than Master/Agent max bet ('+@ErrType+').'
							when 'ES' then N'Sorry, max bet must be equal to or less than Master/Agent max bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최대 배팅은 마스터/ 에이전트의 최대 배팅 이하이여야 합니다 ('+@ErrType+').'
							else N'Sorry, max bet must be equal to or less than Master/Agent max bet ('+@ErrType+').'
					end										
	Select @ErrCode = 107
	return
END

select @ErrType = ''
select @ErrType = @ErrType + (case when MP=0 then sportname else 'Mixed Sports' end )   + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype,0 as MP, @MaxPerMatch as MaxPerMatch, @MaxMaxPerMatch as MaxMaxPerMatch
	union all	select 2 as sporttype,0 as MP, @MaxPerMatchv2 as MaxPerMatch, @MaxMaxPerMatchv2 as MaxMaxPerMatch
	union all	select 3 as sporttype,0 as MP, @MaxPerMatchv3 as MaxPerMatch, @MaxMaxPerMatchv3 as MaxMaxPerMatch
	union all	select 5 as sporttype,0 as MP, @MaxPerMatchv5 as MaxPerMatch, @MaxMaxPerMatchv5 as MaxMaxPerMatch
	union all	select 8 as sporttype,0 as MP, @MaxPerMatchv8 as MaxPerMatch, @MaxMaxPerMatchv8 as MaxMaxPerMatch
	union all	select 10 as sporttype,0 as MP, @MaxPerMatchv10 as MaxPerMatch, @MaxMaxPerMatchv10 as MaxMaxPerMatch
	union all	select 11 as sporttype,0 as MP, @MaxPerMatchv11 as MaxPerMatch, @MaxMaxPerMatchv11 as MaxMaxPerMatch
	union all	select 99 as sporttype,0 as MP, @MaxPerMatchv99 as MaxPerMatch, @MaxMaxPerMatchv99 as MaxMaxPerMatch	 
	union all	select 99 as sporttype,1 as MP, @MaxPerMatchv99MP as MaxPerMatch, @MaxMaxPerMatchv99MP as MaxMaxPerMatch	 
	union all	select 161 as sporttype,0 as MP, @MaxPerMatchv161 as MaxPerMatch, @MaxMaxPerMatchv161 as MaxMaxPerMatch
) as b on sports.sporttype = b.sporttype
where MaxMaxPerMatch>0 and MaxPerMatch>0 and MaxPerMatch>MaxMaxPerMatch
if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Match must be equal to or less than Master/Agent Max Per Match ('+@ErrType+').'
							when 'CS' then N'对不起，单场最高投注需相等于或少于总代理/代理单场最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,單場最高投注需相等於或少於總代理/代理單場最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินในการเล่นสูงสุดต่อรายการต้องเท่ากับ หรือน้อยกว่า จำนวนเงินสูงสุดต่อรายการที่กำหนดไว้ของตัวแทนหรือตัวแทนหลักต่อเกมการแข่งขัน ('+@ErrType+').'
							when 'J' then N'Sorry, Max Per Match must be equal to or less than Master/Agent Max Per Match ('+@ErrType+').'
							when 'ES' then N'Sorry, Max Per Match must be equal to or less than Master/Agent Max Per Match ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 경기당 최대는 마스터/에이전트 최대 경기보다 이하이여야 합니다 ('+@ErrType+').'
							else N'Sorry, Max Per Match must be equal to or less than Master/Agent Max Per Match ('+@ErrType+').'
					end										
	Select @ErrCode = 107
	return
END

SELECT @ErrType = ''
IF @MaxPerBallv161 > 0 AND @MaxMaxPerBallv161 > 0 AND @MaxPerBallv161 > @MaxMaxPerBallv161
BEGIN
	SELECT @ErrType = @ErrType + sportname 
	FROM sports WITH(NOLOCK)
	WHERE sporttype = 161
	
	SELECT @ErrMsg= CASE @Language
						WHEN 'E' THEN 'Max Per Ball must equal to or less than Agent Max Per Ball ('+@ErrType+').'
						WHEN 'CS' THEN '单粒球最高投注必須等於或低於代理单粒球最高的投注('+@ErrType+').'
						WHEN 'CT' THEN '單粒球最高投注必須等於或低於代理單粒球最高的投注('+@ErrType+').'
						WHEN 'TH' THEN 'ค่าสูงสุดต่อบอลต้องเท่ากับหรือน้อยกว่าการตั้งค่าสูงสุดของเอเย่น('+@ErrType+').'
						WHEN 'J' THEN  'Max Per Ball must equal to or less than Agent Max Per Ball ('+@ErrType+').'
						WHEN 'ES' THEN 'Max Per Ball must equal to or less than Agent Max Per Ball ('+@ErrType+').'
						WHEN 'KO' THEN 'Max Per Ball must equal to or less than Agent Max Per Ball ('+@ErrType+').'
						ELSE N'Max Per Ball must equal to or less than Agent Max Per Ball ('+@ErrType+').'
				END
	SELECT @ErrCode = 107
	RETURN
END

select @pwdexpiry = dateadd(dd, 30, getdate())

IF @UplineClosed = 1 SELECT @Closed = 1 

--check suspended of Agent 
if @Asuspended =1 and @suspendedFlag is null
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
	@ugroup = @ugroup,
	@srecommend = @srecommend,
	@mrecommend = @mrecommend,
	@recommend = @recommend,
	@roleid = 1,
	@phone = @phone,
	@mobilephone = @mobilephone,
	@email = '',
	@fax = @fax,
	@address = '',
	@city = '',
	@state = '',
	@country = '',
	@postal = '',
	@TransferOption = null,
	@suspended = @suspended,
	@closed = @closed,
	
	@Danger = @AgentDanger,
	@Danger2 = @AgentDanger2,
	@Danger3 = @AgentDanger3,
	@Abnormal = @AgentAbnormal,
	
	@Disable151_31 = @Disable151_31,
	@Disable151_41 = @Disable151_41,
	@Disable151_51 = @Disable151_51,  
	@Disable152_41 = @Disable152_41,  
	@Disable152_51 = @Disable152_51,  
	@Disable153_51 = @Disable153_51,
	@DisableOutright = @DisableOutright,	
	@matchlimit = @matchlimit,
	@virtualmultiplier = @virtualmultiplier,
	@DisableFinancial = @DisableFinancial,
	@DisableCasino = @DisableCasino,
	@DisableBingo = @DisableBingo,
	@DisableNumber = @DisableNumber,
	@Disable162_1101 = @Disable162_1101,
	@Disable180_1201 = @Disable180_1201,
	@HideVirtualSports = @HideVirtualSports,
	@DoubleCommLosing = 0,-- off double comm losing when create new member
	@isAutoResetLiveCasino = @isAutoResetLiveCasino, 
	@MaxWinLiveCasino = @MaxWinLiveCasino,
	
	@MaxPerMatch = @MaxPerMatch,
	@MaxPerMatchv2 = @MaxPerMatchv2,
	@MaxPerMatchv3 = @MaxPerMatchv3,
	@MaxPerMatchv5 = @MaxPerMatchv5,
	@MaxPerMatchv8 = @MaxPerMatchv8,
	@MaxPerMatchv10 = @MaxPerMatchv10,
	@MaxPerMatchv11 = @MaxPerMatchv11,
	@MaxPerMatchv99 = @MaxPerMatchv99,
	@MaxPerMatchv99MP = @MaxPerMatchv99MP,
	@MaxPerMatchv161 = @MaxPerMatchv161,
	@MaxPerBallv161 = @MaxPerBallv161,
	@MaxPerMatchv180 = @MaxPerMatchv180,
	
	@credit = @credit,
	@DisableP2P = @DisableP2P,
	@DisableFUNP2P = @DisableFUNP2P,
	@IP = @IP,
	@TransferOption_dec = null,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT

IF @ErrCode <> 0
	return
	
--Hardcode commission for member under 8RM agent
IF @recommend in (52466)	 
BEGIN
	SELECT @playerdiscount = 0,	@discount = 0, @adiscount = 0, @sdiscount = 0,
		@playerdiscount1x2 = 0, @discount1x2 = 0, @adiscount1x2 = 0, @sdiscount1x2 = 0,
		@playerdiscountcs = 0, @discountcs = 0, @adiscountcs = 0, @sdiscountcs = 0,
		@v151playerdiscount_31 = 0, @v151discount_31 = 0, @v151adiscount_31 = 0, @v151sdiscount_31 = 0,
		@v151playerdiscount_41 = 0, @v151discount_41 = 0, @v151adiscount_41 = 0, @v151sdiscount_41 = 0,
		@v201discount = 0, @v201adiscount = 0, @v201sdiscount = 0, 
		@discountnumber = 0, @adiscountnumber = 0, @sdiscountnumber = 0,
		@v162discount_1101 = 0 , @v162adiscount_1101 = 0, @v162sdiscount_1101 = 0
END

		
--print @v2mpositiontaking_20
INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], MinBet, MaxBet, autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking)
select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1,@spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
--1x2
UNION ALL
select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, @playerdiscount1x2, @discount1x2, @adiscount1x2, @sdiscount1x2, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL
select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0

UNION ALL
select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL
select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL
select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL
select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL
select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
--UNION ALL
--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL
select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0

UNION ALL
select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL
select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL
select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL
select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0

UNION ALL
select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL
select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL
select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL
select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0

UNION ALL
select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
UNION ALL
select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
UNION ALL
select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0

UNION ALL
select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL
select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL
select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL
select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0

UNION ALL
select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0
UNION ALL
select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0

UNION ALL
select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL
select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL
select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL
select @custid, 9, 99, @v99apositiontaking_9, isnull(@v99mpositiontaking_9,0), isnull(@v99spositiontaking_9,0), 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99MP, @MaxBetv99MP, 0, 0, 0, 0
UNION ALL
select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0




if @@Error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then 'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then '회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=215
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	return
END



--inser into CustSetting3rd
INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], MinBet, MaxBet, autopositiontaking, isautopositiontaking, alivepositiontaking,mlivepositiontaking,slivepositiontaking,autolivepositiontaking,isautolivepositiontaking)
select @custid, 2, 201, 0, @v201mpositiontaking_2, @v201spositiontaking_2, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 3, 201, 0, @v201mpositiontaking_3, @v201spositiontaking_3, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v151
UNION ALL
select @custid, 31, 151, 0, @v151mpositiontaking_31, @v151spositiontaking_31, @v151playerdiscount_31, @v151discount_31, @v151adiscount_31, @v151sdiscount_31, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 32, 151, 0, @v151mpositiontaking_32, @v151spositiontaking_32, @v151playerdiscount_31, @v151discount_31, @v151adiscount_31, @v151sdiscount_31, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 41, 151, 0, @v151mpositiontaking_41, @v151spositiontaking_41, @v151playerdiscount_41, @v151discount_41, @v151adiscount_41, @v151sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 42, 151, 0, @v151mpositiontaking_42, @v151spositiontaking_42, @v151playerdiscount_41, @v151discount_41, @v151adiscount_41, @v151sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 51, 151, 0, @v151mpositiontaking_51, @v151spositiontaking_51, @v151playerdiscount_51, @v151discount_51, @v151adiscount_51, @v151sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 151, 0, @v151mpositiontaking_52, @v151spositiontaking_52, @v151playerdiscount_51, @v151discount_51, @v151adiscount_51, @v151sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v152
UNION ALL
select @custid, 41, 152, 0, @v152mpositiontaking_41, @v152spositiontaking_41, @v152playerdiscount_41, @v152discount_41, @v152adiscount_41, @v152sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 42, 152, 0, @v152mpositiontaking_42, @v152spositiontaking_42, @v152playerdiscount_41, @v152discount_41, @v152adiscount_41, @v152sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 51, 152, 0, @v152mpositiontaking_51, @v152spositiontaking_51, @v152playerdiscount_51, @v152discount_51, @v152adiscount_51, @v152sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 152, 0, @v152mpositiontaking_52, @v152spositiontaking_52, @v152playerdiscount_51, @v152discount_51, @v152adiscount_51, @v152sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v153
UNION ALL
select @custid, 51, 153, 0, @v153mpositiontaking_51, @v153spositiontaking_51, @v153playerdiscount_51, @v153discount_51, @v153adiscount_51, @v153sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 52, 153, 0, @v153mpositiontaking_52, @v153spositiontaking_52, @v153playerdiscount_51, @v153discount_51, @v153adiscount_51, @v153sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v161
UNION ALL
select @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, @v161spositiontaking_81, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
UNION ALL
select @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, @v161spositiontaking_83, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
UNION ALL
select @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, @v161spositiontaking_88, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0
UNION ALL
select @custid, 85, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_85,@v161mlivepositiontaking_85,@v161slivepositiontaking_85,0,0
UNION ALL
select @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, @v161spositiontaking_86, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_86,@v161mlivepositiontaking_86,@v161slivepositiontaking_86,0,0
UNION ALL
select @custid, 87, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_87,@v161mlivepositiontaking_87,@v161slivepositiontaking_87,0,0
UNION ALL
select @custid, 89, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_89,@v161mlivepositiontaking_89,@v161slivepositiontaking_89,0,0
UNION ALL
select @custid, 90, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_90,@v161mlivepositiontaking_90,@v161slivepositiontaking_90,0,0
--v180
UNION ALL
select @custid, 1201, 180, ISNULL(@v180apositiontaking_1201,0), ISNULL(@v180mpositiontaking_1201,0), ISNULL(@v180spositiontaking_1201,0), 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0,0,0,0,0,0

if @@Error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then 'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then '회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=215
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID

	return
END

EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
if @@Error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=216
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--VS
EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = 180, @bettype = 1201, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
if @@Error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=218
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert Into P2P Setting
INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
	(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
SELECT @custid  , bettype , StakeLevel1 , 0 , 0 , 0 , 0 FROM P2PGameSetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1001
UNION ALL 
SELECT @custid  , bettype , StakeLevel1 , 0 , 0 , 0 , 0 FROM P2PGameSetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1002


if @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=216
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END


INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
           (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
SELECT @custid custId
	,P2PGroupComm.groupID
	,GC_S.sdiscount
	,GC_M.adiscount
	,P2PGroupComm.discount
	,0 playerdiscount
FROM dbo.P2PGroupComm WITH(NOLOCK) 
INNER JOIN (
	SELECT groupID
		,sdiscount
	FROM dbo.P2PGroupComm WITH(NOLOCK) 
	WHERE custid = @srecommend
	) GC_S ON GC_S.GROUPID = P2PGroupComm.GROUPID
INNER JOIN (
	SELECT groupID
		,adiscount
	FROM dbo.P2PGroupComm WITH(NOLOCK) 
	WHERE custid = @mrecommend
	) GC_M ON GC_M.GROUPID = P2PGroupComm.GROUPID
WHERE custid = @recommend;

--SELECT @custid custId,groupID,sdiscount,adiscount,discount,0 playerdiscount
--FROM dbo.P2PGroupComm
--Where custid  = @recommend ; 

if @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=216
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

SELECT	@v162apositiontaking_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162apositiontaking_1101 ELSE 0 END,
		@v162mpositiontaking_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162mpositiontaking_1101 ELSE 0 END,
		@v162spositiontaking_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162spositiontaking_1101 ELSE 0 END,
		@v162discount_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162discount_1101 ELSE 0 END,
		@v162adiscount_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162adiscount_1101 ELSE 0 END,
		@v162sdiscount_1101 = CASE WHEN @UplineSyncLiveCasino = 1 THEN @v162sdiscount_1101 ELSE 0 END
--- insert into custsettingGame
INSERT INTO custsettingGame(CustID, Bettype, Sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking)
	SELECT @custid, 1101, 162, @v162apositiontaking_1101, @v162mpositiontaking_1101, @v162spositiontaking_1101, 0, @v162discount_1101, @v162adiscount_1101, @v162sdiscount_1101, 0, 0, 0, 0
		
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
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
		
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END

EXEC Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @srecommend = @srecommend , @mrecommend = @mrecommend , @recommend = @recommend

---- Create balance for new customer
INSERT INTO BalanceCredit (CustID, Balance )
VALUES (@CustID, 0)

IF @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=216
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custid  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custid  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid	

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END


INSERT INTO BalanceDebit (CustID, Balance )
VALUES (@CustID, 0)

IF @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=216
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custid  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custid  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid
	DELETE BalanceDebit WITH (ROWLOCK) WHERE custid = @custid	

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

---- Create default balance for Live casino for new customer
DECLARE @today smalldatetime
SET @today = convert(nvarchar(10), current_timestamp,120)

INSERT INTO BalanceCreditGame (CustID, winlostdate, Balance )
VALUES (@CustID, @today, 0)

IF @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=219
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custid  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custid  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid	
	DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid
	DELETE BalanceDebit WITH (ROWLOCK) WHERE custid = @custid	
	DELETE BalanceCreditGame WITH (ROWLOCK) WHERE custid = @custid

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END


INSERT INTO BalanceDebitGame (CustID, winlostdate, Balance )
VALUES (@CustID, @today, 0)

IF @@error <> 0
BEGIN
	--Error occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add member fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการสมาชิกไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'メンバーの追加に失敗しました。再度、最初からやり直してください。'
							when 'ES' then N'Fallo al añadir miembro. Por favor, inténtelo de nuevo.'
							when 'KO' then N'회원추가에 실패했습니다. 다시 시도해 주시기 바랍니다'
							else N'Add member fail. Please try again'
						end	
			, @success = 0, @ErrCode=220
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custid  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custid  =@custid
	DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
	DELETE BalanceCredit WITH (ROWLOCK) WHERE custid = @custid
	DELETE BalanceDebit WITH (ROWLOCK) WHERE custid = @custid	
	DELETE BalanceCreditGame WITH (ROWLOCK) WHERE custid = @custid
	DELETE BalanceDebitGame WITH (ROWLOCK) WHERE custid = @custid	
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END


Select @Success = 1

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

declare @copyFromUsername varchar(30)
select @copyFromUsername = username
from customer with (nolock)
where custid = @copyFromCustID

Declare @LogSPData varchar(4000)
--Log customer general info
Select @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'fname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@firstname as varchar(100)),space(1))) + '" ' +
'lname="'+ dbo.f_EncodeXMLValue(coalesce(cast(@lastname as varchar(100)),space(1))) + '" ' +
'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
'username="'+ coalesce(cast(@username as varchar(30)),space(1)) + '" ' +
'phone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@phone as varchar(100)),space(1))) + '" ' +
'fax="'+ dbo.f_EncodeXMLValue(coalesce(cast(@fax as varchar(100)),space(1))) + '" ' +
'mphone="'+ dbo.f_EncodeXMLValue(coalesce(cast(@mobilephone as varchar(100)),space(1))) + '" ' +
'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
'recommend="'+ coalesce(cast(@recommend as varchar(50)),space(1)) + '" ' +
'ugroup="'+ coalesce(cast(@ugroup as varchar(5)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'success="'+ coalesce(cast(@success as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'isSearchAndCopy ="'+ coalesce(cast(@isSearchAndCopy as varchar(5)),space(1)) + '" ' +
'copyFromCustID ="'+ coalesce(cast(@copyFromCustID as varchar(20)),space(1)) + '" ' +
'copyFromUsername ="'+ coalesce(@copyFromUsername,space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'


EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 603,
	@TrackingValue = @LogSPData,
	@duration = @duration
--Log commission
Select @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'discount="'+ coalesce(cast(@discount as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
'playerdiscount="'+ coalesce(cast(@playerdiscount as varchar(50)),space(1)) + '" ' +
'playerdiscountcs="'+ coalesce(cast(@playerdiscountcs as varchar(50)),space(1)) + '" ' +
'playerdiscount1x2="'+ coalesce(cast(@playerdiscount1x2 as varchar(50)),space(1)) + '" ' +
'playerdiscountnumber="'+ coalesce(cast(@playerdiscountnumber as varchar(50)),space(1)) + '" />' 
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 203,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Log Bet Setting
Select @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
'MinBv99MP="'+ coalesce(cast(@MinBetv99MP as varchar(50)),space(1)) + '" ' +
'MaxBv99MP="'+ coalesce(cast(@MaxBetv99MP as varchar(50)),space(1)) + '" ' +
'MPMv99MP="'+ coalesce(cast(@MaxPerMatchv99MP as varchar(50)),space(1)) + '" ' +
'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="'+ coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1)) + '" />'



EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 303,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
--Log statuses
Select @LogSPData = '<Acc_CustomerInsMember_Ag custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'closed="'+ coalesce(cast(@closed as varchar(50)),space(1)) + '" ' +
'suspended="'+ coalesce(cast(@suspended as varchar(50)),space(1)) + '" ' +
'Danger="'+ coalesce(cast(@AgentDanger as varchar(5)),space(1)) + '" ' +
'Danger2="'+ coalesce(cast(@AgentDanger2 as varchar(5)),space(1)) + '" ' +
'Danger3="'+ coalesce(cast(@AgentDanger3 as varchar(5)),space(1)) + '" ' +
'Abnormal="'+ coalesce(cast(@AgentAbnormal as varchar(5)),space(1)) + '" ' +
'DisableHorseRacing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
'DisableOT ="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
'Disable151_51 ="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +  
'Disable152_41 ="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +  
'Disable152_51 ="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +  
'Disable153_51 ="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' + 
'DisableVirtualSports="'+ coalesce(cast(@Disable180_1201 as varchar(1)),space(1)) + '" ' +
'DisableCasino="'+ coalesce(cast(@DisableCasino as varchar(1)),space(1)) + '" ' +
'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(1)),space(1)) + '" ' +
'DisableBingo="'+ coalesce(cast(@DisableBingo as varchar(1)),space(1)) + '" ' +
'DisableNumber="'+ coalesce(cast(@DisableNumber as varchar(1)),space(1)) + '" ' +
'Disable162_1101="'+ coalesce(cast(@Disable162_1101 as varchar(1)),space(1)) + '" />'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 1103,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
-- Write Log Credit
Declare @LogSPCredit varchar(200)
Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1)) + ',
SubAccName='+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
	@UserID = @Creator,
	@CustID = @CustID,
	@Doing = @LogSPCredit,
	@NewValue = @credit,
	@IP = @IP,
	@ActionID = 1207
	
--Write PT log
Select @LogSPData = '<Acc_CustomerInsMember_Ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
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
'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1))  + '" ' +
'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1))  + '" ' +
'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1))  + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1))  + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1))  + '" ' +
'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1))  + '" ' +
'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1))  + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1))  + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1))  + '" ' +
'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1))  + '" ' +
'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1))  + '" />'

EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 403,
	@TrackingValue = @LogSPData,
	@duration = @duration


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Ag] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Ag] TO [bodbDownlineNet]
GO
DENY EXECUTE ON [dbo].[Acc_CustomerInsMember_Ag] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Ag] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Ag] TO [Dot_Member]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInsMember_Ag] TO [vnteam]