USE [bodb02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerInsMember_SAg    Script Date: 3/25/2013 2:14:15 PM ******/

ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_SAg]
	@custid int OUTPUT,
	@firstname nvarchar(50),
	@lastname nvarchar(50),
	@creator int,
	@username varchar(30),
	@userpwd varchar(40),
	@phone nvarchar(50),
	@mobilephone nvarchar(50),
	@email nvarchar(50),
	@fax nvarchar(50),
	@address nvarchar(80),
	@city nvarchar(50),
	@state nvarchar(50),
	@country nvarchar(50),
	@postal nvarchar(50),
	@TransferOption varchar(8) = NULL, --pass value (not NULL) in case dummy super add new master
	@suspended bit =null,
	
	@Disable151_31 bit = 0,--@DisableHorseRacing -> @Disable151_31
	@Disable151_41 bit= 0,-- @DisableOpenTote -> @Disable151_41
	@Disable151_51 bit = 0, -- @Disable151_AU -> @Disable151_51
	@Disable152_41 bit = 0, -- @Disable152_UK -> @Disable152_41
	@Disable152_51 bit = 0, -- @Disable152_AU -> @Disable152_51
	@Disable153_51 bit = 0, -- @Disable153_AU -> @Disable153_51
	@DisableFinancial bit = 0,
	@DisableCasino bit =0,
	@DisableAutoMPT bit = 1,--Super allow master using auto master PT or not.
	@DisableBingo bit = 0, 
	@DisableNumber bit = 0,
	
	@DisableP2P BIT = 0,
	@DisableFUNP2P BIT = 0,
	
	@Disable162_1101 BIT = 0,
	@Disable180_1201 BIT = 0,
	
	@suspendedFlag varchar(6) = null,
	@IsInternal bit = 0,
	@minbet money,
	@maxbet money,
	@maxpermatch money,
	
	@minbetv2 money,
	@maxbetv2 money,
	@maxpermatchv2 money,
	
	@minbetv3 money,
	@maxbetv3 money,
	@maxpermatchv3 money,
	
	@minbetv5 money,
	@maxbetv5 money,
	@maxpermatchv5 money,
	
	@minbetv8 money,
	@maxbetv8 money,
	@maxpermatchv8 money,
	
	@minbetv10 money,
	@maxbetv10 money,
	@maxpermatchv10 money,
	
	@minbetv11 money,
	@maxbetv11 money,
	@maxpermatchv11 money,
	
	@minbetv99 money,
	@maxbetv99 money,
	@maxpermatchv99 money,
	
	@minbetv99mp money = 0,
	@maxbetv99mp money = 0,
	@maxpermatchv99mp money = 0,

	@minbetv161 money = 0,				
	@maxbetv161 money = 0,
	@maxpermatchv161 money = 0,	

	@maxperballv161 money = 0,
	
	@credit money,
	@srecommend int,
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
--	@v2spositiontaking_9 smallmoney,
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
	@v99spositiontaking_20 smallmoney,	
	
	@v99spositiontaking_9 smallmoney = 0,

	@v161spositiontaking_81 smallmoney = 0, 				
	@v161spositiontaking_83 smallmoney = 0,
	@v161spositiontaking_86 smallmoney = 0,
	@v161spositiontaking_88 smallmoney = 0,
	
	@v161slivepositiontaking_85 smallmoney = 0,
	@v161slivepositiontaking_86 smallmoney = 0,
	@v161slivepositiontaking_87	smallmoney = 0,
	@v161slivepositiontaking_89	smallmoney = 0,
	@v161slivepositiontaking_90	smallmoney = 0,

	@groupa decimal(9,8),
	@groupb decimal(9,8),
	@groupc decimal(9,8),
	@groupd decimal(9,8),
	@discountcs decimal(9,8),	
	--1x2
	@discount1x2 decimal(9,8)=0,

	@discountnumber decimal (9,8) = 0,
	
	@auto_spositiontaking_1 smallmoney = 0,
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney = 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
	@auto_v2spositiontaking_1 smallmoney = 0,
	@auto_v2spositiontaking_2 smallmoney = 0,
	@auto_v2spositiontaking_3 smallmoney = 0,
	@auto_v2spositiontaking_7 smallmoney = 0,
	@auto_v2spositiontaking_8 smallmoney = 0,
--	@auto_v2spositiontaking_9 smallmoney = 0,
	@auto_v2spositiontaking_20 smallmoney = 0,
	
	@auto_v3spositiontaking_1 smallmoney = 0,
	@auto_v3spositiontaking_2 smallmoney = 0,
	@auto_v3spositiontaking_3 smallmoney = 0,	
	@auto_v3spositiontaking_20 smallmoney = 0,
	
	@auto_v5spositiontaking_1 smallmoney = 0,
	@auto_v5spositiontaking_2 smallmoney = 0,
	@auto_v5spositiontaking_3 smallmoney = 0,	
	@auto_v5spositiontaking_20 smallmoney = 0,
	
	@auto_v8spositiontaking_1 smallmoney = 0,	
	@auto_v8spositiontaking_3 smallmoney = 0,	
	@auto_v8spositiontaking_20 smallmoney = 0,
	
	@auto_v10spositiontaking_1 smallmoney = 0,
	@auto_v10spositiontaking_2 smallmoney = 0,
	@auto_v10spositiontaking_3 smallmoney = 0,	
	@auto_v10spositiontaking_20 smallmoney = 0,
	
	@auto_v11spositiontaking_1 smallmoney = 0,	
	@auto_v11spositiontaking_20 smallmoney = 0,
	
	@auto_v99spositiontaking_1 smallmoney = 0,
	@auto_v99spositiontaking_2 smallmoney = 0,
	@auto_v99spositiontaking_3 smallmoney = 0,		
	@auto_v99spositiontaking_20 smallmoney = 0,	

	@auto_v99spositiontaking_9 smallmoney = 0,
	
	@auto_v161spositiontaking_81 smallmoney = 0,            
	@auto_v161spositiontaking_83 smallmoney = 0,
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,
	
	@Language varchar(2)= 'E',
	@SubAccID int = 0,--Sub-AccountID,
	@mpositiontaking_1 smallmoney = 0.7,
	@mpositiontaking_2 smallmoney = 0.7,
	@mpositiontaking_3 smallmoney = 0.7,
	@mpositiontaking_4 smallmoney = 0.7,
	@mpositiontaking_5 smallmoney = 0.7,
	@mpositiontaking_6 smallmoney = 0.7,
	@mpositiontaking_7 smallmoney = 0.7,
	@mpositiontaking_8 smallmoney = 0.7,
	@mpositiontaking_9 smallmoney = 0.7,
	@mpositiontaking_10 smallmoney = 0.7,
	@mlivepositiontaking_1 smallmoney = 0.7,
	@mlivepositiontaking_3 smallmoney = 0.7,
	@mlivepositiontaking_7 smallmoney = 0.7,
	@mlivepositiontaking_8 smallmoney = 0.7,
	
	@v2mpositiontaking_1 smallmoney = 0.7,
	@v2mpositiontaking_2 smallmoney = 0.7,
	@v2mpositiontaking_3 smallmoney = 0.7,
	@v2mpositiontaking_7 smallmoney = 0.7,
	@v2mpositiontaking_8 smallmoney = 0.7,
--	@v2mpositiontaking_9 smallmoney = 0.7,
	@v2mpositiontaking_20 smallmoney = 0.7,
	
	@v3mpositiontaking_1 smallmoney = 0.7,
	@v3mpositiontaking_2 smallmoney = 0.7,
	@v3mpositiontaking_3 smallmoney = 0.7,	
	@v3mpositiontaking_20 smallmoney = 0.7,
	
	@v5mpositiontaking_1 smallmoney = 0.7,
	@v5mpositiontaking_2 smallmoney = 0.7,
	@v5mpositiontaking_3 smallmoney = 0.7,	
	@v5mpositiontaking_20 smallmoney = 0.7,
	
	@v8mpositiontaking_1 smallmoney = 0.7,	
	@v8mpositiontaking_3 smallmoney = 0.7,	
	@v8mpositiontaking_20 smallmoney = 0.7,
	
	@v10mpositiontaking_1 smallmoney = 0.7,
	@v10mpositiontaking_2 smallmoney = 0.7,
	@v10mpositiontaking_3 smallmoney = 0.7,	
	@v10mpositiontaking_20 smallmoney = 0.7,
	
	@v11mpositiontaking_1 smallmoney = 0.7,	
	@v11mpositiontaking_20 smallmoney = 0.7,
	
	@v99mpositiontaking_1 smallmoney = 0.7,
	@v99mpositiontaking_2 smallmoney = 0.7,
	@v99mpositiontaking_3 smallmoney = 0.7,		
	@v99mpositiontaking_20 smallmoney = 0.7,

	@v99mpositiontaking_9 smallmoney = 0.7,

	@v161mpositiontaking_81 smallmoney = 0.7,        
	@v161mpositiontaking_83 smallmoney = 0.7,
	@v161mpositiontaking_86 smallmoney = 0.7,
	@v161mpositiontaking_88 smallmoney = 0.7,
	
	@v161mlivepositiontaking_85 smallmoney = 0.7,
	@v161mlivepositiontaking_86 smallmoney = 0.7,
	@v161mlivepositiontaking_87 smallmoney = 0.7,
	@v161mlivepositiontaking_89 smallmoney = 0.7,
	@v161mlivepositiontaking_90 smallmoney = 0.7,
	
	
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT,
	@site varchar(50) = ''
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Super creates Master
DB: DBTXN/bodb02
Original:

Revisions:
    - 20081009@Phuc: Apply Auto Super PT when create Master
	- 20081021@Phuc: Add new sporttype 201, bettype 3,Hard code copy min/max/maxperbet/PT for 201 from 2 sporttype 
	- 20090122@PhuongNguyen: Remove userpwd from log writing
	- 20090122@PhuongDao: Add new sporttype 201, bettype 2.
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
	- 20090325@Phuc: check valid commission
	- 20090407@Phuc: IF DisableFinancial (upline or webconfig) set s3 = n4, m3 = 0; get minbet201, maxbet201, maxpermatch201 from upline
	- 20090417@PhuongDao: Set default virtualrate = 0%
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20090701@Phuc: super allow master using auto master.
					Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090903@Shifu: Add IsInternal
	- 20090903@Simon: Write Credit Log into Userlog_Credit table.
	- 20090917@Phuc: write log into DBLOG.
	- 20091112@Jamie: Get the customer's DisableOutright status from the upline's 
	- 20091118@Jamie: Assign the default closed status of upline to the member
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100827@Lukas:	- Add setting information (minbet,maxbet,positiontaking, auto_positiontaking...) for Number game 
						- Add setting information for Mix Parlay for Mixed Sports (sporttype = 99, bettype = 9)
						- Remove Mix Parlay for Basketball game (sporttype = 2, bettype = 9)
	- 20100909@Jamie: Add param @DisableCasino
	- 20101019@Henry: Record execution time
	- 20101026@Lukas: Add max per ball for number game
	- 20101231@Johnson: Add setting for HR AU, Greyhound, Harness
	- 20110520@Johnson: Allow spaces between words in user name when creating
	- 20110722@Sophia: Check username2 with prefix 'Agency$'
	- 20110722@Sophia: remove username2 with prefix 'Agency$'
	- 20110801@Lukas: (Number Game)
				- Add more bettypes: Warrior, Next Combo, Number Group
				- Remove dead ball Over/Under
	- 20110822@Tom: Add P2P setting
	- 20110830@Johnson: hard code setting number group bettype temporary
	- 20111207@Sophia: Add @virtualmultiplier to get upline's virtualmultiplier 
	- 20111214@Sophia: Check @@Error for inserting P2P
	- 20120204@Lukas: insert default value for stake level: Play for fund (from upline)
	- 20111222@Johnson: Add live casino setting
	- 20120210@TOM: Insert default value of P2P Comm
	- 20120502@Lukas: Encode XML values in logging
	- 20120531@Johnson: correct site of direct master if passed
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120810@Johnson: Add virtual soccer setting
	- 20120928@Johnson: add double comm losing status
	- 20121011@Dan: add win limit setting for live casino
	- 20130219@Johnson: write log into DBTXN if DBLOG failure
Param's Explanation:
• @ErrCode:
    = 0: super create master successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--NOT allow agent under KH, KR, KAR, KBR, KCR, LDR, KM, KAM to create downlines (Requested by wan 04-Dec-2008)
--20081218_By_AhWan: KER - 1238537
--20090112_Wan: unblock KM 194354
--20091130_Wan: Unblock KAR,KBR,KCR,KDR,KER,KH,KR 
if @srecommend = 726582
BEGIN
	Select	@ErrMsg = case @Language 
						when 'E' then 'Sorry, cannot create master.'
						when 'CS' then N'对不起，无法新增总代理.'
						when 'CT' then N'對不起,無法新增總代理.'
						when 'TH' then N'ขออภัย คุณไม่สามารถสร้างตัวแทนหลักได้คะ.'
						when 'J' then N'Sorry, cannot create master.'
						when 'ES' then N'Sorry, cannot create master.'
						when 'KO' then N'죄송합니다 . 마스터를 만들 수 없습니다.'
						else N'Sorry, cannot create master.'
					end,@ErrCode = 100	

	--Select @ErrMsg = 'Sorry, cannot create master.',
		--@ErrCode = 100
	
	return
END

--Check an account disabled or not 
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @srecommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
if @ErrCode <>0		return 

declare 
	@transcode bigint, @currency int, @pwdexpiry datetime,
	@MinMinBet money, @MaxMaxBet money, @MaxMaxPerMatch money,
	@MinMinBetv2 money, @MaxMaxBetv2 money, @MaxMaxPerMatchv2 money,
	@MinMinBetv3 money, @MaxMaxBetv3 money, @MaxMaxPerMatchv3 money,
	@MinMinBetv5 money, @MaxMaxBetv5 money, @MaxMaxPerMatchv5 money,
	@MinMinBetv8 money, @MaxMaxBetv8 money, @MaxMaxPerMatchv8 money,
	@MinMinBetv10 money, @MaxMaxBetv10 money, @MaxMaxPerMatchv10 money,
	@MinMinBetv11 money, @MaxMaxBetv11 money, @MaxMaxPerMatchv11 money,
	@MinMinBetv99 money, @MaxMaxBetv99 money, @MaxMaxPerMatchv99 money,	
	@MinMinBetv99mp money, @MaxMaxBetv99mp money, @MaxMaxPerMatchv99MP money,
	@MinMinBetv161 money, @MaxMaxBetv161 money, @MaxMaxPerMatchv161 money,
	@MaxMaxPerBallv161 money,	
	@minbetv180 money,@maxbetv180 money, @maxpermatchv180 money,
	
	@Credit_AllOtherMaster money, @Credit_AllMember money, @Credit_SAg money,
	--@MaxPerMatch_AllOtherMaster money, @MaxPerMatch_AllMember money, @MaxPerMatch_SAg money,
	--@maxpermatchv2_AllOtherMaster money, @maxpermatchv2_AllMember money, @maxpermatchv2_SAg money,
	@RoleID_SAg tinyint, @matchlimit smallmoney,
	@TransferOption_dec tinyint,
	@DisableOutright bit,
	@Ssuspended bit,
	@UplineClosed bit,
	@UplineSyncLiveCasino bit,
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
--	@max_v2spositiontaking_9 smallmoney,
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
	@max_v99spositiontaking_20 smallmoney,

	@max_v99spositiontaking_9 smallmoney,

	@max_v161spositiontaking_81 smallmoney,							
	@max_v161spositiontaking_83 smallmoney,
	@max_v161spositiontaking_86 smallmoney,
	@max_v161spositiontaking_88 smallmoney,
	
	@max_v161slivepositiontaking_85 smallmoney,
	@max_v161slivepositiontaking_86 smallmoney,
	@max_v161slivepositiontaking_87 smallmoney,
	@max_v161slivepositiontaking_89 smallmoney,
	@max_v161slivepositiontaking_90 smallmoney,
	@min_v180spositiontaking_1201 smallmoney,	 --VS
	
	@isauto_spositiontaking_1 smallmoney,
	@isauto_spositiontaking_2 smallmoney,
	@isauto_spositiontaking_3 smallmoney,
	@isauto_spositiontaking_4 smallmoney,
	@isauto_spositiontaking_5 smallmoney,
	@isauto_spositiontaking_6 smallmoney,
	@isauto_spositiontaking_7 smallmoney,
	@isauto_spositiontaking_8 smallmoney,
	@isauto_spositiontaking_9 smallmoney,
	@isauto_spositiontaking_10 smallmoney,
	
	@isauto_slivepositiontaking_1 smallmoney,
	@isauto_slivepositiontaking_3 smallmoney,
	@isauto_slivepositiontaking_7 smallmoney,
	@isauto_slivepositiontaking_8 smallmoney,
	
	@isauto_v2spositiontaking_1 smallmoney,
	@isauto_v2spositiontaking_2 smallmoney,
	@isauto_v2spositiontaking_3 smallmoney,
	@isauto_v2spositiontaking_7 smallmoney,
	@isauto_v2spositiontaking_8 smallmoney,
--	@isauto_v2spositiontaking_9 smallmoney,
	@isauto_v2spositiontaking_20 smallmoney,
	
	@isauto_v3spositiontaking_1 smallmoney,
	@isauto_v3spositiontaking_2 smallmoney,
	@isauto_v3spositiontaking_3 smallmoney,	
	@isauto_v3spositiontaking_20 smallmoney,
	
	@isauto_v5spositiontaking_1 smallmoney,
	@isauto_v5spositiontaking_2 smallmoney,
	@isauto_v5spositiontaking_3 smallmoney,	
	@isauto_v5spositiontaking_20 smallmoney,
	
	@isauto_v8spositiontaking_1 smallmoney,	
	@isauto_v8spositiontaking_3 smallmoney,	
	@isauto_v8spositiontaking_20 smallmoney,
	
	@isauto_v10spositiontaking_1 smallmoney,
	@isauto_v10spositiontaking_2 smallmoney,
	@isauto_v10spositiontaking_3 smallmoney,	
	@isauto_v10spositiontaking_20 smallmoney,
	
	@isauto_v11spositiontaking_1 smallmoney,	
	@isauto_v11spositiontaking_20 smallmoney,

	@isauto_v99spositiontaking_1 smallmoney,
	@isauto_v99spositiontaking_2 smallmoney,
	@isauto_v99spositiontaking_3 smallmoney,		
	@isauto_v99spositiontaking_20 smallmoney,

	@isauto_v99spositiontaking_9 smallmoney,

	@isauto_v161spositiontaking_81 smallmoney,					
	@isauto_v161spositiontaking_83 smallmoney,
	@isauto_v161spositiontaking_86 smallmoney,
	@isauto_v161spositiontaking_88 smallmoney,
	
	@isauto_v161slivepositiontaking_85 smallmoney,
	@isauto_v161slivepositiontaking_86 smallmoney,
	@isauto_v161slivepositiontaking_87 smallmoney,
	@isauto_v161slivepositiontaking_89 smallmoney,
	@isauto_v161slivepositiontaking_90 smallmoney,
	@virtualmultiplier smallmoney,	
	@HideVirtualSports  BIT,
	@DoubleCommLosing	BIT,
	@isAutoResetLiveCasino BIT , 
	@MaxWinLiveCasino SMALLMONEY 

declare @ErrType varchar(4000)	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--select @username = replace(@username, ' ', '')
select @username = rtrim(ltrim(@username))

select 
	@currency = currency,
	@Ssuspended = reject,
	@UplineClosed = closed,
	@UplineSyncLiveCasino = SyncLiveCasino,
	@Credit_SAg = isnull(credit, 0),
	@MaxMaxPerMatch = isnull(MaxPerMatch, 0),
	@MaxMaxPerMatchv2 = isnull(MaxPerMatch2, 0),
	@MaxMaxPerMatchv3 = isnull(MaxPerMatch3, 0),
	@MaxMaxPerMatchv5 = isnull(MaxPerMatch5, 0),
	@MaxMaxPerMatchv8 = isnull(MaxPerMatch8, 0),
	@MaxMaxPerMatchv10 = isnull(MaxPerMatch10, 0),
	@MaxMaxPerMatchv11 = isnull(MaxPerMatch11, 0),
	@MaxMaxPerMatchv99 = isnull(MaxPerMatch99, 0),
	@MaxMaxPerMatchv161 = isnull(MaxPerMatch161, 0),
	@MaxMaxPerMatchv99MP = isnull(MaxPerMatch99MP, 0),
	@MaxMaxPerBallv161 = isnull(MaxPerBall161, 0),
	@MaxPerMatchv180 = isnull(maxpermatch180, 0),
	--@MaxPerMatch_SAg = isnull(MaxPerMatch, 0),
	--@maxpermatchv2_SAg = isnull(MaxPerMatchb, 0), 
	@matchlimit = matchlimit,
	@DisableBingo = case when ci.DisableBingo = 1 then 1 else @DisableBingo end,
	@DisableNumber = case when ci.DisableNumber = 1 then 1 else @DisableNumber end,
	@Disable151_31 = case when DisableHorseRacing = 1 then 1 else @Disable151_31 end,	
	@Disable151_41 = case when DisableOpenTote = 1 then 1 else @Disable151_41 end,
	@Disable151_51 = case when Disable151_AU = 1 then 1 else @Disable151_51 end,
	@Disable152_41 = case when Disable152_UK = 1 then 1 else @Disable152_41 end,
	@Disable152_51 = case when Disable152_AU = 1 then 1 else @Disable152_51 end,
	@Disable153_51 = case when Disable153_AU = 1 then 1 else @Disable153_51 end,
	@DisableFinancial = case when DisableFinancial = 1 then 1 else @DisableFinancial end,
	@DisableCasino = case when DisableCasino = 1 then 1 else @DisableCasino end, 
	@DisableOutright = DisableOutright,
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
where CustID = @srecommend

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @IsValid bit
select @IsValid = 0
Select @ErrCode = 0
EXEC dbo.Acc_CustomerInsMember_SAg_CheckParam 
		@minbet = @minbet,
		@maxbet = @maxbet,
		@maxpermatch = @maxpermatch,
		@minbetv2 = @minbetv2,
		@maxbetv2 = @maxbetv2,
		@maxpermatchv2 = @maxpermatchv2,
		@minbetv3 = @minbetv3,
		@maxbetv3 = @maxbetv3,
		@maxpermatchv3 = @maxpermatchv3,
		@minbetv5 = @minbetv5,
		@maxbetv5 = @maxbetv5,
		@maxpermatchv5 = @maxpermatchv5,
		@minbetv8 = @minbetv8,
		@maxbetv8 = @maxbetv8,
		@maxpermatchv8 = @maxpermatchv8,
		@minbetv10 = @minbetv10,
		@maxbetv10 = @maxbetv10,
		@maxpermatchv10 = @maxpermatchv10,
		@minbetv11 = @minbetv11,
		@maxbetv11 = @maxbetv11,
		@maxpermatchv11 = @maxpermatchv11,

		@minbetv99 = @minbetv99,
		@maxbetv99 = @maxbetv99,
		@maxpermatchv99 = @maxpermatchv99,

		@minbetv99mp = @minbetv99mp,
		@maxbetv99mp = @maxbetv99mp,
		@maxpermatchv99mp = @maxpermatchv99mp,

		@minbetv161 = @minbetv161,
		@maxbetv161 = @maxbetv161,
		@maxpermatchv161 = @maxpermatchv161,

		@maxperballv161 = @maxperballv161,

		@credit = @credit,
		@srecommend = @srecommend,
		@spositiontaking_1 = @spositiontaking_1,
		@spositiontaking_2 = @spositiontaking_2,
		@spositiontaking_3 = @spositiontaking_3,
		@spositiontaking_4 = @spositiontaking_4,
		@spositiontaking_5 = @spositiontaking_5,
		@spositiontaking_6 = @spositiontaking_6,
		@spositiontaking_7 = @spositiontaking_7,
		@spositiontaking_8 = @spositiontaking_8,
		@spositiontaking_9 = @spositiontaking_9,
		@spositiontaking_10 = @spositiontaking_10,
		@slivepositiontaking_1 = @slivepositiontaking_1,
		@slivepositiontaking_3 = @slivepositiontaking_3,
		@slivepositiontaking_7 = @slivepositiontaking_7,
		@slivepositiontaking_8 = @slivepositiontaking_8,
		@v2spositiontaking_1 = @v2spositiontaking_1,
		@v2spositiontaking_2 = @v2spositiontaking_2,
		@v2spositiontaking_3 = @v2spositiontaking_3,
		@v2spositiontaking_7 = @v2spositiontaking_7,
		@v2spositiontaking_8 = @v2spositiontaking_8,
--		@v2spositiontaking_9 = @v2spositiontaking_9,
		@v2spositiontaking_20 = @v2spositiontaking_20,
		@v3spositiontaking_1 = @v3spositiontaking_1,
		@v3spositiontaking_2 = @v3spositiontaking_2,
		@v3spositiontaking_3 = @v3spositiontaking_3,
		@v3spositiontaking_20 = @v3spositiontaking_20,
		@v5spositiontaking_1 = @v5spositiontaking_1,
		@v5spositiontaking_2 = @v5spositiontaking_2,
		@v5spositiontaking_3 = @v5spositiontaking_3,
		@v5spositiontaking_20 = @v5spositiontaking_20,
		@v8spositiontaking_1 = @v8spositiontaking_1,
		@v8spositiontaking_3 = @v8spositiontaking_3,
		@v8spositiontaking_20 = @v8spositiontaking_20,
		@v10spositiontaking_1 = @v10spositiontaking_1,
		@v10spositiontaking_2 = @v10spositiontaking_2,
		@v10spositiontaking_3 = @v10spositiontaking_3,
		@v10spositiontaking_20 = @v10spositiontaking_20,
		@v11spositiontaking_1 = @v11spositiontaking_1,
		@v11spositiontaking_20 = @v11spositiontaking_20,

		@v99spositiontaking_1 = @v99spositiontaking_1,
		@v99spositiontaking_2 = @v99spositiontaking_2,
		@v99spositiontaking_3 = @v99spositiontaking_3,		
		@v99spositiontaking_20 = @v99spositiontaking_20,

		@v99spositiontaking_9 = @v99spositiontaking_9,

		@v161spositiontaking_81 = @v161spositiontaking_81,
		@v161spositiontaking_83 = @v161spositiontaking_83,
		@v161spositiontaking_86 = @v161spositiontaking_86,
		@v161spositiontaking_88 = @v161spositiontaking_88,
		
		@v161slivepositiontaking_85 = @v161slivepositiontaking_85,
		@v161slivepositiontaking_86 = @v161slivepositiontaking_86,
		@v161slivepositiontaking_87 = @v161slivepositiontaking_87,
		@v161slivepositiontaking_89 = @v161slivepositiontaking_89,
		@v161slivepositiontaking_90 = @v161slivepositiontaking_90,
		
		@groupa = @groupa,
		@groupb = @groupb,
		@groupc = @groupc,
		@groupd = @groupd,
		@discountcs = @discountcs,
		@discount1x2 = @discount1x2, --1x2
		--- number game commission
		@discountnumber = @discountnumber,		

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
--		@auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
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

		@auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,
	
		@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
		@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
		@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
		@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
		
		@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
		@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
		@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
		@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
		@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

		@mpositiontaking_1 = @mpositiontaking_1,
		@mpositiontaking_2 = @mpositiontaking_2,
		@mpositiontaking_3 = @mpositiontaking_3,
		@mpositiontaking_4 = @mpositiontaking_4,
		@mpositiontaking_5 = @mpositiontaking_5,
		@mpositiontaking_6 = @mpositiontaking_6,
		@mpositiontaking_7 = @mpositiontaking_7,
		@mpositiontaking_8 = @mpositiontaking_8,
		@mpositiontaking_9 = @mpositiontaking_9,
		@mpositiontaking_10 = @mpositiontaking_10,
		@mlivepositiontaking_1 = @mlivepositiontaking_1,
		@mlivepositiontaking_3 = @mlivepositiontaking_3,
		@mlivepositiontaking_7 = @mlivepositiontaking_7,
		@mlivepositiontaking_8 = @mlivepositiontaking_8,
		@v2mpositiontaking_1 = @v2mpositiontaking_1,
		@v2mpositiontaking_2 = @v2mpositiontaking_2,
		@v2mpositiontaking_3 = @v2mpositiontaking_3,
		@v2mpositiontaking_7 = @v2mpositiontaking_7,
		@v2mpositiontaking_8 = @v2mpositiontaking_8,
--		@v2mpositiontaking_9 = @v2mpositiontaking_9,
		@v2mpositiontaking_20 = @v2mpositiontaking_20,
		@v3mpositiontaking_1 = @v3mpositiontaking_1,
		@v3mpositiontaking_2 = @v3mpositiontaking_2,
		@v3mpositiontaking_3 = @v3mpositiontaking_3,
		@v3mpositiontaking_20 = @v3mpositiontaking_20,
		@v5mpositiontaking_1 = @v5mpositiontaking_1,
		@v5mpositiontaking_2 = @v5mpositiontaking_2,
		@v5mpositiontaking_3 = @v5mpositiontaking_3,
		@v5mpositiontaking_20 = @v5mpositiontaking_20,
		@v8mpositiontaking_1 = @v8mpositiontaking_1,
		@v8mpositiontaking_3 = @v8mpositiontaking_3,
		@v8mpositiontaking_20 = @v8mpositiontaking_20,
		@v10mpositiontaking_1 = @v10mpositiontaking_1,
		@v10mpositiontaking_2 = @v10mpositiontaking_2,
		@v10mpositiontaking_3 = @v10mpositiontaking_3,
		@v10mpositiontaking_20 = @v10mpositiontaking_20,
		@v11mpositiontaking_1 = @v11mpositiontaking_1,
		@v11mpositiontaking_20 = @v11mpositiontaking_20,

		@v99mpositiontaking_1 = @v99mpositiontaking_1,
		@v99mpositiontaking_2 = @v99mpositiontaking_2,
		@v99mpositiontaking_3 = @v99mpositiontaking_3,		
		@v99mpositiontaking_20 = @v99mpositiontaking_20,

		@v99mpositiontaking_9 = @v99mpositiontaking_9,
		
		@v161mpositiontaking_81 = @v161mpositiontaking_81,
		@v161mpositiontaking_83 = @v161mpositiontaking_83,
		@v161mpositiontaking_86 = @v161mpositiontaking_86,
		@v161mpositiontaking_88 = @v161mpositiontaking_88,
		
		@v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
		@v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
		@v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
		@v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
		@v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,

		@isvalid = @isvalid OUTPUT,
		@errmsg = @errmsg OUTPUT,
		@errcode = @errcode OUTPUT,
		@language = @language
if @IsValid = 0
BEGIN
	return
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if exists(select 1 from customer with (NOLOCK) where username= @username)
	or exists (select 1 from customer with (NOLOCK) where username2 = @username)
	or exists(select 1 from custsub with (NOLOCK) where username= @username)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'This username is not available.'
						when 'CS' then N'此账号无效.'
						when 'CT' then N'此帳號無效.'
						when 'TH' then N'ชื่อที่ใช้ในการเข้าระบบนี้ ไม่สามารถใช้งานได้.'
						when 'J' then N'This username is not available.'
						when 'ES' then N'This username is not available.'
						when 'KO' then N'이 사용자 이름을 사용할 수 없습니다.'
						else N'This username is not available.'
					end		
	Select @ErrCode = 101
	return
END
select @pwdexpiry = dateadd(dd, 30, getdate())

select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @minbet as minbet, @maxbet as maxbet, @maxpermatch as maxpermatch
	union all	select 2 as sporttype, @minbetv2 as minbet, @maxbetv2 as maxbet, @maxpermatchv2 as maxpermatch
	union all	select 3 as sporttype, @minbetv3 as minbet, @maxbetv3 as maxbet, @maxpermatchv3 as maxpermatch
	union all	select 5 as sporttype, @minbetv5 as minbet, @maxbetv5 as maxbet, @maxpermatchv5 as maxpermatch
	union all	select 8 as sporttype, @minbetv8 as minbet, @maxbetv8 as maxbet, @maxpermatchv8 as maxpermatch
	union all	select 10 as sporttype, @minbetv10 as minbet, @maxbetv10 as maxbet, @maxpermatchv10 as maxpermatch
	union all	select 11 as sporttype, @minbetv11 as minbet, @maxbetv11 as maxbet, @maxpermatchv11 as maxpermatch
	union all	select 99 as sporttype, @minbetv99 as minbet, @maxbetv99 as maxbet, @maxpermatchv99 as maxpermatch	 
	union all	select 99 as sporttype, @minbetv99mp as minbet, @maxbetv99mp as maxbet, @maxpermatchv99mp as maxpermatch
	union all   select 161 as sporttype, @minbetv161 as minbet, @maxbetv161 as maxbet, @maxpermatchv161 as maxpermatch
) as b on sports.sporttype = b.sporttype
where (minbet<>0 and maxbet <> 0 and  minbet>maxbet) 
or (maxbet<> 0 and maxpermatch <> 0 and maxbet>maxpermatch) 
or (minbet <> 0 and maxpermatch <> 0 and minbet>maxpermatch) 

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be less than max bet and max bet must be less than max per match ('+@ErrType+').'
							when 'CS' then N'对不起，最低投注不能高于最高投注，最高投注不能高于单场最高投注设定 ('+@ErrType+').'
							when 'CT' then N'對不起,最低投注不能高於最高投注,最高投注不能高於單場最高投注設定 ('+@ErrType+').'
							when 'TH' then N'ขออภัยจำนวนเงินในการเล่นขั้นต่ำต้องน้อยกว่าจำนวนเงินสูงสุดที่จะเล่นได้และจำนวนเงินสูงสุดที่เล่นได้ต้องน้อยกว่าจำนวนเงินเดิมพันต่อเกมการแข่งขัน('+@ErrType+').'
							when 'J' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match ('+@ErrType+').'
							when 'ES' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match ('+@ErrType+').'
							when 'KO' then N'죄송합니다, 최소 배팅은 최대 배팅보다 작아야 하고  최대 배팅은 경기당 최대 배팅보다 작아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be less than max bet and max bet must be less than max per match ('+@ErrType+').'
					end
										
	Select @ErrCode = 103
	return
END
/* ------------- viet --comment this
IF @maxperballv161 < @maxbetv161 or @maxperballv161 > @maxpermatchv161
BEGIN
	SELECT @ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							when 'CS' then N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注.'
							when 'CT' then N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注.'
							when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน.'
							when 'J' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							when 'ES' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							when 'KO' then N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
							else N'Sorry, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
					end										
	Select @ErrCode = 200
	return
END
*/
/*
select @groupA = case when isnumeric(VValue) = 1 then convert(decimal(9,8), VValue) else 0.0025 end from SystemSettings with (NOLOCK) where Vname = 'MgroupA'
select @groupB = case when isnumeric(VValue) = 1 then convert(decimal(9,8), VValue) else 0.005 end  from SystemSettings with (NOLOCK) where Vname = 'MgroupB'
select @groupC = case when isnumeric(VValue) = 1 then convert(decimal(9,8), VValue) else 0.0075 end  from SystemSettings with (NOLOCK) where Vname = 'MgroupC'
select @groupD = case when isnumeric(VValue) = 1 then convert(decimal(9,8), VValue) else 0.01 end  from SystemSettings with (NOLOCK) where Vname = 'MgroupD'
select @discountcs = case when isnumeric(VValue) = 1 then convert(decimal(9,8), VValue) else 0.05 end  from SystemSettings with (NOLOCK) where Vname = 'MDiscountCS'
*/
select @max_spositiontaking_1 = spositiontaking, @max_slivepositiontaking_1 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @max_spositiontaking_3 = spositiontaking, @max_slivepositiontaking_3 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=1
select @max_spositiontaking_7 = spositiontaking, @max_slivepositiontaking_7 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=1
select @max_spositiontaking_8 = spositiontaking, @max_slivepositiontaking_8 = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=1
select @max_spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=1
select @max_spositiontaking_4 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=4 and sporttype=1
select @max_spositiontaking_5 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=5 and sporttype=1
select @max_spositiontaking_6 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=6 and sporttype=1
select @max_spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=1
select @max_spositiontaking_10 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=1

select @max_v2spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=2
select @max_v2spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=2
select @max_v2spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=2
--select @max_v2spositiontaking_7 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=2
--select @max_v2spositiontaking_8 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=2
--select @max_v2spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=2
select @max_v2spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=2

select @max_v3spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=3
select @max_v3spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=3
select @max_v3spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=3
select @max_v3spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=3

select @max_v5spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=5
select @max_v5spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=5
select @max_v5spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=5
select @max_v5spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=5

select @max_v8spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=8
select @max_v8spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=8
select @max_v8spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=8

select @max_v10spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=10
select @max_v10spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=10
select @max_v10spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=10
select @max_v10spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=10

select @max_v11spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=11
select @max_v11spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=11

select @max_v99spositiontaking_1 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=99
select @max_v99spositiontaking_2 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=99
select @max_v99spositiontaking_3 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=99
select @max_v99spositiontaking_20 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=99

select @max_v99spositiontaking_9 = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=99

select @max_v161spositiontaking_81 = spositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 81 and sporttype = 161
select @max_v161spositiontaking_83 = spositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 83 and sporttype = 161
select @max_v161spositiontaking_88 = spositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 88 and sporttype = 161
select @max_v161slivepositiontaking_85 = slivepositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 85 and sporttype = 161
select @max_v161spositiontaking_86 = spositiontaking, @max_v161slivepositiontaking_86 = slivepositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 86 and sporttype = 161
select @max_v161slivepositiontaking_87 = slivepositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 87 and sporttype = 161
select @max_v161slivepositiontaking_89 = slivepositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 89 and sporttype = 161
select @max_v161slivepositiontaking_90 = slivepositiontaking from custsetting3rd with(nolock) where custid = @srecommend and bettype = 90 and sporttype = 161

--VS: get n4 
select @min_v180spositiontaking_1201 = minpositiontaking 
from custOverride3rd with(nolock) 
where custid = @srecommend and bettype = 1201 and sporttype = 180


--check s3+m3<=s4
select @ErrType = ''
select @ErrType = @ErrType + sportname + '-' + typenamee + '-Max:'+ cast((max_spositiontaking) as varchar(10))
	+ case when b.sporttype in (1,161) and b.bettype in (1,3,7,8,85,86,87,89,90) then '--Live:'+ cast((max_slivepositiontaking) as varchar(10)) else '' end + '<br>'
from sports with (NOLOCK) inner join
(
				select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @max_spositiontaking_1 as max_spositiontaking,  @max_slivepositiontaking_1 as max_slivepositiontaking
	union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @max_spositiontaking_3 as max_spositiontaking,  @max_slivepositiontaking_3 as max_slivepositiontaking
	union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @max_spositiontaking_7 as max_spositiontaking,  @max_slivepositiontaking_7 as max_slivepositiontaking
	union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_spositiontaking_8 as max_spositiontaking,  @max_slivepositiontaking_8 as max_slivepositiontaking
	union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_4 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_5 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_6 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_9 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @max_spositiontaking_10 as max_spositiontaking,  0 as max_slivepositiontaking

	union all 	select 1 as bettype, 2 as sporttype, @v2spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 2 as bettype, 2 as sporttype, @v2spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 2 as sporttype, @v2spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking
--	union all 	select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_7 as max_spositiontaking,  0 as max_slivepositiontaking
--	union all 	select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_8 as max_spositiontaking,  0 as max_slivepositiontaking
--	union all 	select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_9 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 2 as sporttype, @v2spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v2spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking

	union all 	select 1 as bettype, 3 as sporttype, @v3spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v3spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 2 as bettype, 3 as sporttype, @v3spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v3spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 3 as sporttype, @v3spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v3spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 3 as sporttype, @v3spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v3spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking
	
	union all 	select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v5spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v5spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v5spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v5spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking
	
	union all 	select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v8spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v8spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v8spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking
	
	union all 	select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v10spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v10spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v10spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v10spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking
	
	union all 	select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v11spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v11spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking

	union all 	select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @max_v99spositiontaking_1 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @max_v99spositiontaking_2 as max_spositiontaking,  0 as max_slivepositiontaking
	union all 	select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @max_v99spositiontaking_3 as max_spositiontaking,  0 as max_slivepositiontaking	
	union all 	select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @max_v99spositiontaking_20 as max_spositiontaking,  0 as max_slivepositiontaking

	union all 	select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @max_v99spositiontaking_9 as max_spositiontaking,  0 as max_slivepositiontaking

	union all   select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @max_v161spositiontaking_81 as max_positiontaking, 0 as max_slivepositiontaking
	union all   select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @max_v161spositiontaking_83 as max_positiontaking, 0 as max_slivepositiontaking
	union all   select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @max_v161spositiontaking_88 as max_positiontaking, 0 as max_slivepositiontaking	
	union all   select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as max_positiontaking, @max_v161slivepositiontaking_85 as max_slivepositiontaking
	union all   select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @max_v161spositiontaking_86 as max_spositiontaking, @max_v161slivepositiontaking_86 as max_slivepositiontaking
	union all   select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as max_positiontaking, @max_v161slivepositiontaking_87 as max_slivepositiontaking
	union all   select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as max_positiontaking, @max_v161slivepositiontaking_89 as max_slivepositiontaking
	union all   select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as max_positiontaking, @max_v161slivepositiontaking_90 as max_slivepositiontaking
			
	) as b on sports.sporttype = b.sporttype
	inner join bettype with (nolock) on b.bettype = bettype.typeid
	where (spositiontaking + mpositiontaking>max_spositiontaking)
		or (slivepositiontaking + mlivepositiontaking>max_slivepositiontaking)

if @ErrType <>''
BEGIN
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (max for super set by company).<br>'+@ErrType
							when 'CS' then N'占成数不正确(公司设给超级总代理最高占成).<br>'+@ErrType
							when 'CT' then N'佔成數不正確(公司設給超級總代理最高佔成).<br>'+@ErrType
							when 'TH' then N'การกำหนดไม่ถูกต้อง (สูงสุดไม่เกิน จากรายการถ่ายทอดสด อ้างอิงจากข้อมูลบริษัท).<br>'+@ErrType
							when 'J' then N'Wrong position taking (max for super set by company).<br>'+@ErrType
							when 'ES' then N'Wrong position taking (max for super set by company).<br>'+@ErrType
							when 'KO' then N'거래 조건이 잘못 되었습니다 (ibc가 설정한 슈퍼의 최대값).<br>'+@ErrType
							else N'Wrong position taking (max for super set by company).<br>'+@ErrType
						end
	Select @ErrCode = 104
	return 
END


select @auto_spositiontaking_1=  case when @auto_spositiontaking_1>@max_spositiontaking_1 then @max_spositiontaking_1 else @auto_spositiontaking_1 end
select @auto_spositiontaking_2=  case when @auto_spositiontaking_2>@max_spositiontaking_2 then @max_spositiontaking_2 else @auto_spositiontaking_2 end
select @auto_spositiontaking_3=  case when @auto_spositiontaking_3>@max_spositiontaking_3 then @max_spositiontaking_3 else @auto_spositiontaking_3 end
select @auto_spositiontaking_4=  case when @auto_spositiontaking_4>@max_spositiontaking_4 then @max_spositiontaking_4 else @auto_spositiontaking_4 end
select @auto_spositiontaking_5=  case when @auto_spositiontaking_5>@max_spositiontaking_5 then @max_spositiontaking_5 else @auto_spositiontaking_5 end
select @auto_spositiontaking_6=  case when @auto_spositiontaking_6>@max_spositiontaking_6 then @max_spositiontaking_6 else @auto_spositiontaking_6 end
select @auto_spositiontaking_7=  case when @auto_spositiontaking_7>@max_spositiontaking_7 then @max_spositiontaking_7 else @auto_spositiontaking_7 end
select @auto_spositiontaking_8= case when @auto_spositiontaking_8>@max_spositiontaking_8 then @max_spositiontaking_8 else @auto_spositiontaking_8 end
select @auto_spositiontaking_9=  case when @auto_spositiontaking_9>@max_spositiontaking_9 then @max_spositiontaking_9 else @auto_spositiontaking_9 end
select @auto_spositiontaking_10=  case when @auto_spositiontaking_10>@max_spositiontaking_10 then @max_spositiontaking_10 else @auto_spositiontaking_10 end

select @auto_slivepositiontaking_1=  case when @auto_slivepositiontaking_1>@max_slivepositiontaking_1 then @max_slivepositiontaking_1 else @auto_slivepositiontaking_1 end
select @auto_slivepositiontaking_3=  case when @auto_slivepositiontaking_3>@max_slivepositiontaking_3 then @max_slivepositiontaking_3 else @auto_slivepositiontaking_3 end
select @auto_slivepositiontaking_7=  case when @auto_slivepositiontaking_7>@max_slivepositiontaking_7 then @max_slivepositiontaking_7 else @auto_slivepositiontaking_7 end
select @auto_slivepositiontaking_8=  case when @auto_slivepositiontaking_8>@max_slivepositiontaking_8 then @max_slivepositiontaking_8 else @auto_slivepositiontaking_8 end

select @auto_v2spositiontaking_1=  case when @auto_v2spositiontaking_1>@max_v2spositiontaking_1 then @max_v2spositiontaking_1 else @auto_v2spositiontaking_1 end
select @auto_v2spositiontaking_2=  case when @auto_v2spositiontaking_2>@max_v2spositiontaking_2 then @max_v2spositiontaking_2 else @auto_v2spositiontaking_2 end
select @auto_v2spositiontaking_3=  case when @auto_v2spositiontaking_3>@max_v2spositiontaking_3 then @max_v2spositiontaking_3 else @auto_v2spositiontaking_3 end
select @auto_v2spositiontaking_7=  case when @auto_v2spositiontaking_7>@max_v2spositiontaking_7 then @max_v2spositiontaking_7 else @auto_v2spositiontaking_7 end
select @auto_v2spositiontaking_8=  case when @auto_v2spositiontaking_8>@max_v2spositiontaking_8 then @max_v2spositiontaking_8 else @auto_v2spositiontaking_8 end
--select @auto_v2spositiontaking_9=  case when @auto_v2spositiontaking_9>@max_v2spositiontaking_9 then @max_v2spositiontaking_9 else @auto_v2spositiontaking_9 end
select @auto_v2spositiontaking_20=  case when @auto_v2spositiontaking_20>@max_v2spositiontaking_20 then @max_v2spositiontaking_20 else @auto_v2spositiontaking_20 end

select @auto_v3spositiontaking_1=  case when @auto_v3spositiontaking_1>@max_v3spositiontaking_1 then @max_v3spositiontaking_1 else @auto_v3spositiontaking_1 end
select @auto_v3spositiontaking_2=  case when @auto_v3spositiontaking_2>@max_v3spositiontaking_2 then @max_v3spositiontaking_2 else @auto_v3spositiontaking_2 end
select @auto_v3spositiontaking_3=  case when @auto_v3spositiontaking_3>@max_v3spositiontaking_3 then @max_v3spositiontaking_3 else @auto_v3spositiontaking_3 end
select @auto_v3spositiontaking_20=  case when @auto_v3spositiontaking_20>@max_v3spositiontaking_20 then @max_v3spositiontaking_20 else @auto_v3spositiontaking_20 end

select @auto_v5spositiontaking_1=  case when @auto_v5spositiontaking_1>@max_v5spositiontaking_1 then @max_v5spositiontaking_1 else @auto_v5spositiontaking_1 end
select @auto_v5spositiontaking_2=  case when @auto_v5spositiontaking_2>@max_v5spositiontaking_2 then @max_v5spositiontaking_2 else @auto_v5spositiontaking_2 end
select @auto_v5spositiontaking_3=  case when @auto_v5spositiontaking_3>@max_v5spositiontaking_3 then @max_v5spositiontaking_3 else @auto_v5spositiontaking_3 end
select @auto_v5spositiontaking_20=  case when @auto_v5spositiontaking_20>@max_v5spositiontaking_20 then @max_v5spositiontaking_20 else @auto_v5spositiontaking_20 end

select @auto_v8spositiontaking_1=  case when @auto_v8spositiontaking_1>@max_v8spositiontaking_1 then @max_v8spositiontaking_1 else @auto_v8spositiontaking_1 end
select @auto_v8spositiontaking_3=  case when @auto_v8spositiontaking_3>@max_v8spositiontaking_3 then @max_v8spositiontaking_3 else @auto_v8spositiontaking_3 end
select @auto_v8spositiontaking_20=  case when @auto_v8spositiontaking_20>@max_v8spositiontaking_20 then @max_v8spositiontaking_20 else @auto_v8spositiontaking_20 end

select @auto_v10spositiontaking_1=  case when @auto_v10spositiontaking_1>@max_v10spositiontaking_1 then @max_v10spositiontaking_1 else @auto_v10spositiontaking_1 end
select @auto_v10spositiontaking_2=  case when @auto_v10spositiontaking_2>@max_v10spositiontaking_2 then @max_v10spositiontaking_2 else @auto_v10spositiontaking_2 end
select @auto_v10spositiontaking_3=  case when @auto_v10spositiontaking_3>@max_v10spositiontaking_3 then @max_v10spositiontaking_3 else @auto_v10spositiontaking_3 end
select @auto_v10spositiontaking_20=  case when @auto_v10spositiontaking_20>@max_v10spositiontaking_20 then @max_v10spositiontaking_20 else @auto_v10spositiontaking_20 end

select @auto_v11spositiontaking_1=  case when @auto_v11spositiontaking_1>@max_v11spositiontaking_1 then @max_v11spositiontaking_1 else @auto_v11spositiontaking_1 end
select @auto_v11spositiontaking_20=  case when @auto_v11spositiontaking_20>@max_v11spositiontaking_20 then @max_v11spositiontaking_20 else @auto_v11spositiontaking_20 end

select @auto_v99spositiontaking_1=  case when @auto_v99spositiontaking_1>@max_v99spositiontaking_1 then @max_v99spositiontaking_1 else @auto_v99spositiontaking_1 end
select @auto_v99spositiontaking_2=  case when @auto_v99spositiontaking_2>@max_v99spositiontaking_2 then @max_v99spositiontaking_2 else @auto_v99spositiontaking_2 end
select @auto_v99spositiontaking_3=  case when @auto_v99spositiontaking_3>@max_v99spositiontaking_3 then @max_v99spositiontaking_3 else @auto_v99spositiontaking_3 end
select @auto_v99spositiontaking_20=  case when @auto_v99spositiontaking_20>@max_v99spositiontaking_20 then @max_v99spositiontaking_20 else @auto_v99spositiontaking_20 end

select @auto_v99spositiontaking_9=  case when @auto_v99spositiontaking_9>@max_v99spositiontaking_9 then @max_v99spositiontaking_9 else @auto_v99spositiontaking_9 end

select @auto_v161spositiontaking_81 = case when @auto_v161spositiontaking_81 > @max_v161spositiontaking_81 then @max_v161spositiontaking_81 else @auto_v161spositiontaking_81 end
select @auto_v161spositiontaking_83 = case when @auto_v161spositiontaking_83 > @max_v161spositiontaking_83 then @max_v161spositiontaking_83 else @auto_v161spositiontaking_83 end
select @auto_v161spositiontaking_86 = case when @auto_v161spositiontaking_86 > @max_v161spositiontaking_86 then @max_v161spositiontaking_86 else @auto_v161spositiontaking_86 end
select @auto_v161spositiontaking_88 = case when @auto_v161spositiontaking_88 > @max_v161spositiontaking_88 then @max_v161spositiontaking_88 else @auto_v161spositiontaking_88 end

select @auto_v161slivepositiontaking_85=  case when @auto_v161slivepositiontaking_85 > @max_v161slivepositiontaking_85 then @max_v161slivepositiontaking_85 else @auto_v161slivepositiontaking_85 end
select @auto_v161slivepositiontaking_86=  case when @auto_v161slivepositiontaking_86 > @max_v161slivepositiontaking_86 then @max_v161slivepositiontaking_86 else @auto_v161slivepositiontaking_86 end
select @auto_v161slivepositiontaking_87 = case when @auto_v161slivepositiontaking_87 > @max_v161slivepositiontaking_87 then @max_v161slivepositiontaking_87 else @auto_v161slivepositiontaking_87 end
select @auto_v161slivepositiontaking_89 = case when @auto_v161slivepositiontaking_89 > @max_v161slivepositiontaking_89 then @max_v161slivepositiontaking_89 else @auto_v161slivepositiontaking_89 end
select @auto_v161slivepositiontaking_90 = case when @auto_v161slivepositiontaking_90 > @max_v161slivepositiontaking_90 then @max_v161slivepositiontaking_90 else @auto_v161slivepositiontaking_90 end

/*
if @minbet>@maxbet 
--or @maxbet>@maxpermatch 
or @minbetv2>@maxbetv2 
--or @maxbetv2>@maxpermatchv2
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be less than max bet and max bet must be less than max bet per match!!!'
							when 'CS' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match!!!'
							when 'J' then N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match!!!'
							else N'Sorry, min bet must be less than max bet and max bet must be less than max bet per match!!!'
					end		
					+ char(13) + char(10) + convert(varchar(20), @minbet) + '-' + convert(varchar(20), @maxbet) + '-' + convert(varchar(20), @maxpermatch)
	Select @ErrCode = 105
	RaisError(@ErrMsg, 16, 1)
	return
END
*/



select 
	@MinMinBet = Isnull(MinBet, 0), @MaxMaxBet = isnull(MaxBet, 0),
	@groupa = case when @groupa>groupa then groupa else @groupa end,
	@groupb = case when @groupb>groupb then groupb else @groupb end,
	@groupc = case when @groupc>groupc then groupc else @groupc end,
	@groupd = case when @groupd>groupd then groupd else @groupd end
from custsetting with (NOLOCK) where custid = @srecommend and  bettype=1 and sporttype=1

select 
	@discountcs = case when @discountcs>sdiscount then sdiscount else @discountcs end
from custsetting with (NOLOCK) where custid = @srecommend and bettype=4 and sporttype=1

--1X2 Commission
select 
	@discount1x2 = case when @discount1x2>sdiscount then sdiscount else @discount1x2 end
from custsetting with (NOLOCK) where custid = @srecommend and bettype=5 and sporttype=1
--HR commission

-- number game commission
select @discountnumber = case when @discountnumber > sdiscount then sdiscount else @discountnumber end
from custsetting3rd with(nolock) where custid = @srecommend and bettype = 81 and sporttype = 161

--End Check valid commission 
select @minbetv180 = Isnull(MinBet, 0), @maxbetv180 = isnull(MaxBet, 0) 
from custsetting3rd with (NOLOCK) 
where custid = @srecommend and bettype= 1201 and sporttype=180


select @MinMinBetv2 = Isnull(MinBet, 0), @MaxMaxBetv2 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=2
select @MinMinBetv3 = Isnull(MinBet, 0), @MaxMaxBetv3 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=3
select @MinMinBetv5 = Isnull(MinBet, 0), @MaxMaxBetv5 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=5
select @MinMinBetv8 = Isnull(MinBet, 0), @MaxMaxBetv8 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=8
select @MinMinBetv10 = Isnull(MinBet, 0), @MaxMaxBetv10 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=10
select @MinMinBetv11 = Isnull(MinBet, 0), @MaxMaxBetv11 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=11
select @MinMinBetv99 = Isnull(MinBet, 0), @MaxMaxBetv99 = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=99
select @MinMinBetv99MP = Isnull(MinBet, 0), @MaxMaxBetv99MP = isnull(MaxBet, 0) from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=99

select @MinMinBetv161 = Isnull(MinBet,0), @MaxMaxBetv161 = Isnull(MaxBet,0) from custsetting3rd with(NOLOCK) where custid = @srecommend and bettype = 81 and sporttype = 161


--Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline
--if ((@minbetv151 < @MinMinBetv151 or @maxbetv151 > @MaxMaxBetv151 or @MaxPerMatchv151 > @MaxMaxPerMatchv151) 
--	and not (@minbetv151 = 0 and @maxbetv151 = 0 and @MaxPerMatchv151 = 0))
--	Select @minbetv151 = @MinMinBetv151,
--			@maxbetv151 = @MaxMaxBetv151,
--			@MaxPerMatchv151 = @MaxMaxPerMatchv151
--End Hard code for Horse racing: check valid minbet, maxbet, maxpermatch for HR if invalid copy from upline

if isnull(@site, '') = ''
BEGIN
	select @site = site from customer with (nolock) where CustID = @srecommend
END


--Vinh@20080213: get transfer option from super
if @srecommend > 100 -- get site from upline if not direct master
	select @site = site from customer with (nolock) where CustID = @srecommend

select	@IsInternal = case when IsInternal = 1 then 1 else @IsInternal end,
		@TransferOption_dec = TransferOption 
from custsuper with (nolock) where CustID = @srecommend

Select @Credit_AllOtherMaster = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where srecommend = @srecommend and RoleID = 3

if @Credit_AllOtherMaster + @Credit > @Credit_SAg and @srecommend>100
BEGIN
	SET @ErrMsg = case @Language 
						when 'E' then 'Sorry, credit update is not successful, You have exceeded your super agent credit.'
						when 'CS' then N'对不起，更新信用额度不成功，已超出超级总代理信用额度.'
						when 'CT' then N'對不起,更新信用額度不成功, 已超出超級總代理信用額度.'
						when 'TH' then N'ขออภัย การเพิ่มจำนวนยอดเงินในบัญชี ไม่เป็นผล เนื่องจาก คุณได้มียอดเกินจำนวนเงินสูงสุดในบัญชีของตัวแทนสูงสุดคะ.'
						when 'J' then N'Sorry, credit update is not successful, You have exceeded your super agent credit.'
						when 'ES' then N'Sorry, credit update is not successful, You have exceeded your super agent credit.'
						when 'KO' then N'죄송합니다. 크레딧 업데이트에 실패했습니다, 해당 슈터 에이전트의 크레딧을 초과 했습니다.'
						else N'Sorry, credit update is not successful, You have exceeded your super agent credit.'
					end	
	Select @ErrCode = 106
	return
END

/*
Select @MaxPerMatch_AllOtherMaster = isnull(sum(MaxPerMatch), 0) from custinfo as ci with (NOLOCK) where srecommend = @srecommend and RoleID = 3

if @MaxPerMatch_AllOtherMaster + @MaxPerMatch >@MaxPerMatch_SAg and @srecommend>100
BEGIN
	SET @ErrMsg = case @Language 
						when 'E' then 'Sorry, Max Per Match update is not successful, You have exceeded your super agent Max Per Match.'
						when 'CS' then N'Sorry, Max Per Match update is not successful, You have exceeded your super agent Max Per Match.'
						when 'J' then N'Sorry, Max Per Match update is not successful, You have exceeded your super agent Max Per Match.'
						else N'Sorry, Max Per Match update is not successful, You have exceeded your super agent Max Per Match.'
					end	
	Select @ErrCode = 106
	RaisError(@ErrMsg, 16, 1)
	return
END

Select @maxpermatchv2_AllOtherMaster = isnull(sum(MaxPerMatchb), 0) from custinfo as ci with (NOLOCK) where srecommend = @srecommend and RoleID = 3

if @maxpermatchv2_AllOtherMaster + @maxpermatchv2 >@maxpermatchv2_SAg and @srecommend>100
BEGIN
	SET @ErrMsg = case @Language 
						when 'E' then 'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your super agent Max Per Match (basketball).'
						when 'CS' then N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your super agent Max Per Match (basketball).'
						when 'J' then N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your super agent Max Per Match (basketball).'
						else N'Sorry, Max Per Match (basketball) update is not successful, You have exceeded your super agent Max Per Match (basketball).'
					end	
	Select @ErrCode = 106
	RaisError(@ErrMsg, 16, 1)
	return
END*/

select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @minbet as minbet, @MinMinBet as MinMinBet
	union all	select 2 as sporttype, @minbetv2 as minbet, @MinMinBetv2 as MinMinBet
	union all	select 3 as sporttype, @minbetv3 as minbet, @MinMinBetv3 as MinMinBet
	union all	select 5 as sporttype, @minbetv5 as minbet, @MinMinBetv5 as MinMinBet
	union all	select 8 as sporttype, @minbetv8 as minbet, @MinMinBetv8 as MinMinBet
	union all	select 10 as sporttype, @minbetv10 as minbet, @MinMinBetv10 as MinMinBet
	union all	select 11 as sporttype, @minbetv11 as minbet, @MinMinBetv11 as MinMinBet
	union all	select 99 as sporttype, @minbetv99 as minbet, @MinMinBetv99 as MinMinBet
	union all   select 99 as sporttype, @minbetv99mp as minbet, @MinMinBetv99MP as MinMinBet
	union all   select 161 as sporttype, @minbetv161 as minbet, @MinMinBetv161 as MinMinBet	 
) as b on sports.sporttype = b.sporttype
where MinMinBet>0 and MinBet>0 and minbet<MinMinBet

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, min bet must be equal to or greater than super agent min bet ('+@ErrType+').'
							when 'CS' then N'对不起，最低投注需相等于或少于总代理/代理最低投注 ('+@ErrType+').'
							when 'CT' then N'對不起,最低投注需相等於或少於總代理/代理最低投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินในการเล่นขั้นต่ำ ต้องเท่ากับ หรือมากกว่า ขั้นต่ำที่กำหนดไว้ ของตัวแทนสูงสุด('+@ErrType+').'
							when 'J' then N'Sorry, min bet must be equal to or greater than super agent min bet ('+@ErrType+').'
							when 'ES' then N'Sorry, min bet must be equal to or greater than super agent min bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최소 배팅은 슈퍼 에이전트 최소 베팅보다 많아야 합니다 ('+@ErrType+').'
							else N'Sorry, min bet must be equal to or greater than super agent min bet ('+@ErrType+').'
					end
										
	Select @ErrCode = 107
	return
END

select @ErrType = ''
select @ErrType = @ErrType + sportname + ', '
from sports with (NOLOCK) inner join
(
				select 1 as sporttype, @maxbet as maxbet, @MaxMaxBet as MaxMaxBet
	union all	select 2 as sporttype, @maxbetv2 as maxbet, @MaxMaxBetv2 as MaxMaxBet
	union all	select 3 as sporttype, @maxbetv3 as maxbet, @MaxMaxBetv3 as MaxMaxBet
	union all	select 5 as sporttype, @maxbetv5 as maxbet, @MaxMaxBetv5 as MaxMaxBet
	union all	select 8 as sporttype, @maxbetv8 as maxbet, @MaxMaxBetv8 as MaxMaxBet
	union all	select 10 as sporttype, @maxbetv10 as maxbet, @MaxMaxBetv10 as MaxMaxBet
	union all	select 11 as sporttype, @maxbetv11 as maxbet, @MaxMaxBetv11 as MaxMaxBet
	union all	select 99 as sporttype, @maxbetv99 as maxbet, @MaxMaxBetv99 as MaxMaxBet	
	union all	select 99 as sporttype, @maxbetv99mp as maxbet, @MaxMaxBetv99MP as MaxMaxBet
	union all   select 161 as sporttype, @maxbetv161 as maxbet, @MaxMaxBetv161 as MaxMaxbet 
) as b on sports.sporttype = b.sporttype
where MaxMaxBet>0 and MaxBet>0 and maxbet>MaxMaxBet

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, max bet must be equal to or less than super agent max bet ('+@ErrType+').'
							when 'CS' then N'对不起，最高投注需相等于或少于超级总代理最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,最高投注需相等於或少於超級總代理最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัย จำนวนเงินสูงสุดที่สามารถเล่นได้ต้องเท่ากับ หรือ น้อยกว่า จำนวนเงินสูงสุดที่กำหนดไว้ของตัวแทนสูงสุด('+@ErrType+').'
							when 'J' then N'Sorry, max bet must be equal to or less than super agent max bet ('+@ErrType+').'
							when 'ES' then N'Sorry, max bet must be equal to or less than super agent max bet ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 최대 배팅은 슈퍼 에이전트의 최대 배팅 이하이여야 합니다 ('+@ErrType+').'
							else N'Sorry, max bet must be equal to or less than super agent max bet ('+@ErrType+').'
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
	union all	select 99 as sporttype, @MaxPerMatchv99MP as MaxPerMatch, @MaxMaxPerMatchv99MP as MaxMaxPerMatch
	union all   select 161 as sporttype, @MaxPerMatchv161 as MaxPerMatch, @MaxMaxPerMatchv161 as MaxMaxPerMatch 
) as b on sports.sporttype = b.sporttype
where MaxMaxPerMatch>0 and MaxPerMatch>0 and MaxPerMatch>MaxMaxPerMatch

if @ErrType <>''
BEGIN
	SELECT
		@ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Match must be equal to or less than super agent Max Per Match ('+@ErrType+').'
							when 'CS' then N'对不起，单场最高投注需相等于或少于超级总代理单场最高投注 ('+@ErrType+').'
							when 'CT' then N'對不起,單場最高投注需相等於或少於超級總代理單場最高投注 ('+@ErrType+').'
							when 'TH' then N'ขออภัยจำนวนเงินในการเล่นสูงสุดต่อรายการ ต้องเท่ากับ หรือน้อยกว่าจำนวนเงินสูงุสุดต่อรายการที่กำหนดไว้ของตัวแทนสูงสุดต่อเกมการแข่งขัน('+@ErrType+').'
							when 'J' then N'Sorry, Max Per Match must be equal to or less than super agent Max Per Match ('+@ErrType+').'
							when 'ES' then N'Sorry, Max Per Match must be equal to or less than super agent Max Per Match ('+@ErrType+').'
							when 'KO' then N'죄송합니다. 경기당 최대는 슈퍼 에이전트 최대 경기보다 이하이여야 합니다 ('+@ErrType+').'
							else N'Sorry, Max Per Match must be equal to or less than super agent Max Per Match ('+@ErrType+').'
					end
										
	Select @ErrCode = 108
	return
END

--- max per ball
IF @MaxPerBallv161 > @MaxMaxPerBallv161 and @MaxMaxPerBallv161 > 0
BEGIN
	select @ErrMsg =	case @Language 
							when 'E' then 'Sorry, Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
							when 'CS' then N'单粒球最高投注必須等於或低於超级总代理单粒球最高的投注设置.'
							when 'CT' then N'單粒球最高投注必須等於或低於超級總代理單粒球最高的投注設置.'
							when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องเท่ากับหรือน้อยกว่าการตั้งค่าสูงสุดต่อบอลของซุปเปอร์เอเย่น .'
							when 'J' then N'Sorry, Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
							when 'ES' then N'Sorry, Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
							when 'KO' then N'Sorry, Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
							else N'Sorry, Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
					end										
	Select @ErrCode = 201
	return
END


select	@isauto_spositiontaking_1 	= case when	@auto_spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_spositiontaking_2 	= case when	@auto_spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_spositiontaking_3 	= case when	@auto_spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_spositiontaking_4 	= case when	@auto_spositiontaking_4 	>0 then 1 else 0 end,
	@isauto_spositiontaking_5 	= case when	@auto_spositiontaking_5 	>0 then 1 else 0 end,
	@isauto_spositiontaking_6 	= case when	@auto_spositiontaking_6 	>0 then 1 else 0 end,
	@isauto_spositiontaking_7 	= case when	@auto_spositiontaking_7 	>0 then 1 else 0 end,
	@isauto_spositiontaking_8 	= case when	@auto_spositiontaking_8 	>0 then 1 else 0 end,
	@isauto_spositiontaking_9 	= case when	@auto_spositiontaking_9 	>0 then 1 else 0 end,
	@isauto_spositiontaking_10 	= case when	@auto_spositiontaking_10 	>0 then 1 else 0 end,
	@isauto_slivepositiontaking_1 	= case when	@auto_slivepositiontaking_1 	>0 then 1 else 0 end,
	@isauto_slivepositiontaking_3 	= case when	@auto_slivepositiontaking_3 	>0 then 1 else 0 end,
	@isauto_slivepositiontaking_7 	= case when	@auto_slivepositiontaking_7 	>0 then 1 else 0 end,
	@isauto_slivepositiontaking_8 	= case when	@auto_slivepositiontaking_8 	>0 then 1 else 0 end,
	
	@isauto_v2spositiontaking_1 	= case when	@auto_v2spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v2spositiontaking_2 	= case when	@auto_v2spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v2spositiontaking_3 	= case when	@auto_v2spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v2spositiontaking_7 	= case when	@auto_v2spositiontaking_7 	>0 then 1 else 0 end,
	@isauto_v2spositiontaking_8 	= case when	@auto_v2spositiontaking_8 	>0 then 1 else 0 end,
--	@isauto_v2spositiontaking_9 	= case when	@auto_v2spositiontaking_9	>0 then 1 else 0 end,
	@isauto_v2spositiontaking_20 	= case when	@auto_v2spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v3spositiontaking_1 	= case when	@auto_v3spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v3spositiontaking_2 	= case when	@auto_v3spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v3spositiontaking_3 	= case when	@auto_v3spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v3spositiontaking_20 	= case when	@auto_v3spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v5spositiontaking_1 	= case when	@auto_v5spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v5spositiontaking_2 	= case when	@auto_v5spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v5spositiontaking_3 	= case when	@auto_v5spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v5spositiontaking_20 	= case when	@auto_v5spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v8spositiontaking_1 	= case when	@auto_v8spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v8spositiontaking_3 	= case when	@auto_v8spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v8spositiontaking_20 	= case when	@auto_v8spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v10spositiontaking_1 	= case when	@auto_v10spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v10spositiontaking_2 	= case when	@auto_v10spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v10spositiontaking_3 	= case when	@auto_v10spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v10spositiontaking_20 	= case when	@auto_v10spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v11spositiontaking_1 	= case when	@auto_v11spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v11spositiontaking_20 	= case when	@auto_v11spositiontaking_20	>0 then 1 else 0 end,
	
	@isauto_v99spositiontaking_1 	= case when	@auto_v99spositiontaking_1 	>0 then 1 else 0 end,
	@isauto_v99spositiontaking_2 	= case when	@auto_v99spositiontaking_2 	>0 then 1 else 0 end,
	@isauto_v99spositiontaking_3 	= case when	@auto_v99spositiontaking_3 	>0 then 1 else 0 end,
	@isauto_v99spositiontaking_9 	= case when	@auto_v99spositiontaking_9 	>0 then 1 else 0 end,
	@isauto_v99spositiontaking_20 	= case when	@auto_v99spositiontaking_20	>0 then 1 else 0 end,

	@isauto_v161spositiontaking_81  = case when @auto_v161spositiontaking_81 > 0 then 1 else 0 end,
	@isauto_v161spositiontaking_83  = case when @auto_v161spositiontaking_83 > 0 then 1 else 0 end,
	@isauto_v161spositiontaking_86  = case when @auto_v161spositiontaking_86 > 0 then 1 else 0 end,
	@isauto_v161spositiontaking_88  = case when @auto_v161spositiontaking_88 > 0 then 1 else 0 end,
	
	@isauto_v161slivepositiontaking_85 = case when @auto_v161slivepositiontaking_85 > 0 then 1 else 0 end,
	@isauto_v161slivepositiontaking_86 = case when @auto_v161slivepositiontaking_86 > 0 then 1 else 0 end,
	@isauto_v161slivepositiontaking_87 = case when @auto_v161slivepositiontaking_87 > 0 then 1 else 0 end,
	@isauto_v161slivepositiontaking_89 = case when @auto_v161slivepositiontaking_89 > 0 then 1 else 0 end,
	@isauto_v161slivepositiontaking_90 = case when @auto_v161slivepositiontaking_90 > 0 then 1 else 0 end

if @Ssuspended = 1 and @suspendedFlag is null ---@suspendedFlag is regconized for Accout Site or not 
begin 
	set @suspended = 1
end 

--Insert general info
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
	@mrecommend = 0,
	@recommend = 0,
	@roleid = 3,
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
	@closed = @UplineClosed,
	
	@Disable151_31 = @Disable151_31,
	@Disable151_41=@Disable151_41,
	@Disable151_51 = @Disable151_51,
	@Disable152_41 = @Disable152_41,
	@Disable152_51 = @Disable152_51,
	@Disable153_51 = @Disable153_51,
	@DisableOutright = @DisableOutright,
	@matchlimit = @matchlimit,
	@virtualmultiplier = @virtualmultiplier,
	@DisableFinancial = @DisableFinancial,
	@DisableCasino = @DisableCasino,
	@DisableAutoMPT = @DisableAutoMPT,
	@DisableNumber = @DisableNumber,
	@DisableBingo  = @DisableBingo,
	@DisableP2P = @DisableP2P,
	@DisableFUNP2P = @DisableFUNP2P,
	@Disable162_1101 = @Disable162_1101,
	@Disable180_1201 = @Disable180_1201,
	@HideVirtualSports  = @HideVirtualSports, 
	@DoubleCommLosing = @DoubleCommLosing,
	@isAutoResetLiveCasino = @isAutoResetLiveCasino, 
	@MaxWinLiveCasino = @MaxWinLiveCasino,
	
	@IsInternal = @IsInternal,
	@MaxPerMatch = @MaxPerMatch,
	@MaxPerMatchv2 = @MaxPerMatchv2,
	@MaxPerMatchv3 = @MaxPerMatchv3,
	@MaxPerMatchv5 = @MaxPerMatchv5,
	@MaxPerMatchv8 = @MaxPerMatchv8,
	@MaxPerMatchv10 = @MaxPerMatchv10,
	@MaxPerMatchv11 = @MaxPerMatchv11,
	@MaxPerMatchv99 = @MaxPerMatchv99,
	@MaxPerMatchv99MP =@MaxPerMatchv99MP,
	@MaxPerMatchv161 = @MaxPerMatchv161,
	@MaxPerBallv161 = @MaxPerBallv161,
	@MaxPerMatchv180 = @MaxPerMatchv180,
	
	@credit = @credit,
	@maxcredit = null,
	
	@IP = @IP,
	@TransferOption_dec = @TransferOption_dec,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT

--Error Occurs
IF @ErrCode <> 0
	return 

--Allow master using auto master PT or not
--Update CustMaster WITH(ROWLOCK,UPDLOCK) SET DisableAutoMPT = @DIsableAutoMPT WHERE CustID = @CustID

	
INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [minbet], [maxbet], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking)
select @custid, 1, 1, @spositiontaking_1, @mpositiontaking_1, 0, @slivepositiontaking_1, @mlivepositiontaking_1, 0, @auto_slivepositiontaking_1, @auto_spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_1, @isauto_slivepositiontaking_1
UNION ALL
select @custid, 3, 1, @spositiontaking_3, @mpositiontaking_3, 0, @slivepositiontaking_3, @mlivepositiontaking_3, 0, @auto_slivepositiontaking_3, @auto_spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_3, @isauto_slivepositiontaking_3
UNION ALL
select @custid, 7, 1, @spositiontaking_7, @mpositiontaking_7, 0, @slivepositiontaking_7, @mlivepositiontaking_7, 0, @auto_slivepositiontaking_7, @auto_spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_7, @isauto_slivepositiontaking_7
UNION ALL
select @custid, 8, 1, @spositiontaking_8, @mpositiontaking_8, 0, @slivepositiontaking_8, @mlivepositiontaking_8, 0, @auto_slivepositiontaking_8, @auto_spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_8, @isauto_slivepositiontaking_8
UNION ALL
select @custid, 2, 1, @spositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, @auto_spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_2, 0
UNION ALL
select @custid, 4, 1, @spositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @auto_spositiontaking_4, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_4, 0
--1x2
UNION ALL
select @custid, 5, 1, @spositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @auto_spositiontaking_5, @discount1x2, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_5, 0
UNION ALL
select @custid, 6, 1, @spositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @auto_spositiontaking_6, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_6, 0
UNION ALL
select @custid, 9, 1, @spositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @auto_spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_9, 0
UNION ALL
select @custid, 10, 1, @spositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @auto_spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_10, 0

UNION ALL
select @custid, 1, 2, @v2spositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v2spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_1, 0
UNION ALL
select @custid, 2, 2, @v2spositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v2spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_2, 0
UNION ALL
select @custid, 3, 2, @v2spositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v2spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_3, 0
UNION ALL
select @custid, 7, 2, @v2spositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, @auto_v2spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_7, 0
UNION ALL
select @custid, 8, 2, @v2spositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, @auto_v2spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_8, 0
--UNION ALL
--select @custid, 9, 2,   @v2spositiontaking_9,   @v2mpositiontaking_9,   0, 0, 0, 0, 0, @auto_v2spositiontaking_9,  @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_9, 0  
--Get commission of Correct Score for MoneyLine
UNION ALL
select @custid, 20, 2, @v2spositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v2spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_20, 0

UNION ALL
select @custid, 1, 3, @v3spositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v3spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_1, 0
UNION ALL
select @custid, 2, 3, @v3spositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v3spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_2, 0
UNION ALL
select @custid, 3, 3, @v3spositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v3spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_3, 0
UNION ALL
select @custid, 20, 3, @v3spositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v3spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_20, 0

UNION ALL
select @custid, 1, 5, @v5spositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v5spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_1, 0
UNION ALL
select @custid, 2, 5, @v5spositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v5spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_2, 0
UNION ALL
select @custid, 3, 5, @v5spositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v5spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_3, 0
UNION ALL
select @custid, 20, 5, @v5spositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v5spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_20, 0

UNION ALL
select @custid, 1, 8, @v8spositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v8spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_1, 0
UNION ALL
select @custid, 3, 8, @v8spositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v8spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_3, 0
UNION ALL
select @custid, 20, 8, @v8spositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v8spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_20, 0

UNION ALL
select @custid, 1, 10, @v10spositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v10spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_1, 0
UNION ALL
select @custid, 2, 10, @v10spositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v10spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_2, 0
UNION ALL
select @custid, 3, 10, @v10spositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v10spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_3, 0
UNION ALL
select @custid, 20, 10, @v10spositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v10spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_20, 0

UNION ALL
select @custid, 1, 11, @v11spositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v11spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv11, @maxbetv11, 0, 0, @isauto_v11spositiontaking_1, 0
UNION ALL
select @custid, 20, 11, @v11spositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v11spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv11, @maxbetv11, 0, 0, @isauto_v11spositiontaking_20, 0

--v99
UNION ALL
select @custid, 1, 99, @v99spositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v99spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_1, 0
UNION ALL
select @custid, 2, 99, @v99spositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v99spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_2, 0
UNION ALL
select @custid, 3, 99, @v99spositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v99spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_3, 0
UNION ALL
select @custid, 20, 99, @v99spositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v99spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_20, 0
-- mix parlay of mixed sports
UNION ALL
select @custid, 9, 99, @v99spositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @auto_v99spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv99mp, @maxbetv99mp, 0, 0, @isauto_v99spositiontaking_9, 0


if @@Error <> 0
BEGIN
	--Error Occurs	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新嘗試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=116
	
	-- ROLLBACK MANUALLY
	DELETE [custsetting] with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	
	return
END
--insert into CustSetting3rd
INSERT INTO [dbo].[CustSetting3rd](custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking, slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking)
--v151
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

--v201
UNION ALL
select @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL
select @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--- v161   
--custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking,
-----------------------------------------																																						-- slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking
UNION ALL
select @custid, 81, 161, 0, @v161mpositiontaking_81, @v161spositiontaking_81, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_81, @isauto_v161spositiontaking_81, 0, 0, 0, 0, 0, 0, 0, 0,0
UNION ALL				 
select @custid, 83, 161, 0, @v161mpositiontaking_83, @v161spositiontaking_83, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_83, @isauto_v161spositiontaking_83, 0, 0, 0, 0, 0, 0, 0, 0,0
UNION ALL
select @custid, 85, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_85, @v161slivepositiontaking_85, @auto_v161slivepositiontaking_85, @isauto_v161slivepositiontaking_85, 0,0
UNION ALL
select @custid, 86, 161, 0, @v161mpositiontaking_86, @v161spositiontaking_86, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_86, @isauto_v161spositiontaking_86, 0, 0, 0, @v161mlivepositiontaking_86, @v161slivepositiontaking_86, @auto_v161slivepositiontaking_86, @isauto_v161slivepositiontaking_86, 0,0
UNION ALL
select @custid, 87, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_87, @v161slivepositiontaking_87, @auto_v161slivepositiontaking_87, @isauto_v161slivepositiontaking_87, 0,0
UNION ALL
select @custid, 88, 161, 0, @v161mpositiontaking_88, @v161spositiontaking_88, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_88, @isauto_v161spositiontaking_88, 0, 0, 0, 0, 0, 0, 0, 0,0
UNION ALL
select @custid, 89, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_89, @v161slivepositiontaking_89, @auto_v161slivepositiontaking_89, @isauto_v161slivepositiontaking_89, 0,0
UNION ALL
select @custid, 90, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_90, @v161slivepositiontaking_90, @auto_v161slivepositiontaking_90, @isauto_v161slivepositiontaking_90, 0,0
--v180
--------------------------------------
UNION ALL
select @custid, 1201, 180, 0, 0, ISNULL(@min_v180spositiontaking_1201,0), 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


if @@Error <> 0
BEGIN
	--Error Occurs	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新嘗試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=117
	
	-- ROLLBACK MANUALLY
	DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
	DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
	
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
UNION ALL select @custid, 3, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 7, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 8, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 2, 0, 0.9, 0, 0.9
--UNION ALL select @custid, 9, 2, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 2, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 3, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 3, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 5, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 5, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 8, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 8, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 8, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 10, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 10, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 11, 0, 0.9, 0, 0.9
UNION ALL select @custid, 20, 11, 0, 0.9, 0, 0.9

UNION ALL select @custid, 1, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 3, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 2, 99, 0, 0.9, 0, 0.9
UNION ALL select @custid, 9, 99, 0, 0.9, 0, 0.9

UNION ALL select @custid, 20, 99, 0, 0.9, 0, 0.9


if @@Error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=118
	
	-- ROLLBACK MANUALLY
	DELETE custoverride with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert into CustOverride3rd
INSERT INTO [dbo].[CustOverride3rd]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
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

UNION ALL select @custid, 81, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 83, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 85, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 86, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 87, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 88, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 89, 161, 0, 0.9, 0, 0.9
UNION ALL select @custid, 90, 161, 0, 0.9, 0, 0.9
--v180
UNION ALL select @custid, 1201, 180, 0, 0.9, 0, 0.9

if @@Error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=119
	
	-- ROLLBACK MANUALLY
	DELETE CustOverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert Into P2P Setting
INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
	(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
SELECT @custid  , 1001 , StakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @srecommend AND bettype = 1001
UNION ALL 
SELECT @custid  , 1002 , StakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @srecommend AND bettype = 1002
 
 
if @@error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=119
	
	-- ROLLBACK MANUALLY
	DELETE CustOverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid

	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END


INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
           (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
SELECT @custid  , 1 , 0 , 0 , 0 , 0 
UNION ALL SELECT @custid  , 2 , 0 , 0 , 0 , 0
--SELECT @custid custId,groupID,sdiscount,0 adiscount,0 discount,0 playerdiscount
--FROM dbo.P2PGroupComm
--Where custid  = @srecommend ; 

 
if @@error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง.'
							when 'J' then N'Add customer fail. Please try again'
							when 'ES' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			,  @ErrCode=119
	
	-- ROLLBACK MANUALLY
	DELETE CustOverride with (ROWLOCK) where custid =  @custid
	DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--Insert live casino setting
INSERT INTO CustSettingGame([CustID]
	       ,[Bettype]
           ,[Sporttype]
           ,[apositiontaking]
           ,[mpositiontaking]
           ,[spositiontaking]
           ,[playerdiscount]
           ,[discount]
           ,[adiscount]
           ,[sdiscount]
           ,[autopositiontaking]
           ,[isautopositiontaking]
           ,[autompositiontaking]
           ,[isautompositiontaking])
	SELECT @custid , bettype, 162, 0, 0, CASE WHEN @UplineSyncLiveCasino = 1 THEN spositiontaking ELSE 0 END, 0, 0, 0,  0, 0, 0 ,0 ,0       
	FROM CustSettingGame cs WITH(NOLOCK) 		
	WHERE cs.custid = @srecommend and cs.sporttype = 162 AND cs.bettype = 1101
	
IF @@ERROR <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Add customer fail. Please try again.'
							WHEN 'CS' THEN N'新增会员不成功，请重新尝.'
							WHEN 'CT' THEN N'新增會員不成功,請重新再.'
							WHEN 'TH' THEN N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้.'
							WHEN 'J' THEN N'Add customer fail. Please try agai.'
							WHEN 'KO' THEN N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							ELSE N'Add customer fail. Please try again.'
						END	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
	DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END

INSERT INTO [bodb02].[dbo].[CustOverrideGame]
           ([CustID]
           ,[Bettype]
           ,[Sporttype]
           ,[minpositiontaking])
VALUES(@custid, 1101, 162, 0)

IF @@ERROR <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Add customer fail. Please try again.'
							WHEN 'CS' THEN N'新增会员不成功，请重新尝.'
							WHEN 'CT' THEN N'新增會員不成功,請重新再.'
							WHEN 'TH' THEN N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้.'
							WHEN 'J' THEN N'Add customer fail. Please try agai.'
							WHEN 'KO' THEN N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							ELSE N'Add customer fail. Please try again.'
						END	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
	DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
	DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
	DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
	DELETE CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	RETURN
END     


set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

Declare @LogSPData varchar(MAX)
--Log customer info
Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
'TransferOption="'+ coalesce(cast(@TransferOption as varchar(8)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'srecommend="'+ coalesce(cast(@srecommend as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'site="'+ coalesce(cast(@site as varchar(50)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 601,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH 
	Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
	'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
	'TransferOption="'+ coalesce(cast(@TransferOption as varchar(8)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'srecommend="'+ coalesce(cast(@srecommend as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'site="'+ coalesce(cast(@site as varchar(50)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 601,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH	
	
--Log betsetting
Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1)) + '" ' +
'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1)) + '" ' +
'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1)) + '" ' +
'MPM99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1)) + '" ' +
'MinBv161="' + coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="' + coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="' + coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 301,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1)) + '" ' +
	'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1)) + '" ' +
	'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1)) + '" ' +
	'MPM99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1)) + '" ' +
	'MinBv161="' + coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="' + coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="' + coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" ' +
	'ErrMsg="' + ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 301,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH

--log commission
Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 201,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
	'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
	'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
	'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
	'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
	'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" ' +
	'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 201,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH	
	
--Log status
Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'suspended="'+ coalesce(cast(@suspended as varchar(1)),space(1)) + '" ' +
'closed="'+ coalesce(cast(@UplineClosed as varchar(1)),space(1)) + '" ' +
'DisableHorseRacing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
'DisableOT="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
'Disable151_51="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +
'Disable152_41="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +
'Disable152_51="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +
'Disable153_51="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' +
'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(1)),space(1)) + '" ' +
'DisableVirtualSports="'+ coalesce(cast(@Disable180_1201 as varchar(1)),space(1)) + '" ' +
'DisableCasino="'+ coalesce(cast(@DisableCasino as varchar(1)),space(1)) + '" ' +
'DisableAutoMPT="'+ coalesce(cast(@DisableAutoMPT as varchar(1)),space(1)) + '" ' +
'IsInternal="'+ coalesce(cast(@IsInternal as varchar(1)),space(1)) + '" ' +
'DisableNumber="' + coalesce(cast(@DisableNumber as varchar(1)),space(1)) + '" ' +
'DisableBingo="' + coalesce(cast(@DisableBingo as varchar(1)),space(1)) + '" ' +
'DisableP2P="' + coalesce(cast(@DisableP2P as varchar(1)),space(1)) + '" ' +
'DisableFunP2P="' + coalesce(cast(@DisableFunP2P as varchar(1)),space(1)) + '" ' +
'Disable162_1101="' + coalesce(cast(@Disable162_1101 as varchar(1)),space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1101,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_SAg custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'suspended="'+ coalesce(cast(@suspended as varchar(1)),space(1)) + '" ' +
	'closed="'+ coalesce(cast(@UplineClosed as varchar(1)),space(1)) + '" ' +
	'DisableHorseRacing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
	'DisableOT="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
	'Disable151_51="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +
	'Disable152_41="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +
	'Disable152_51="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +
	'Disable153_51="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' +
	'DisableOutright="'+ coalesce(cast(@DisableOutright as varchar(1)),space(1)) + '" ' +
	'DisableVirtualSports="'+ coalesce(cast(@Disable180_1201 as varchar(1)),space(1)) + '" ' +
	'DisableCasino="'+ coalesce(cast(@DisableCasino as varchar(1)),space(1)) + '" ' +
	'DisableAutoMPT="'+ coalesce(cast(@DisableAutoMPT as varchar(1)),space(1)) + '" ' +
	'IsInternal="'+ coalesce(cast(@IsInternal as varchar(1)),space(1)) + '" ' +
	'DisableNumber="' + coalesce(cast(@DisableNumber as varchar(1)),space(1)) + '" ' +
	'DisableBingo="' + coalesce(cast(@DisableBingo as varchar(1)),space(1)) + '" ' +
	'DisableP2P="' + coalesce(cast(@DisableP2P as varchar(1)),space(1)) + '" ' +
	'DisableFunP2P="' + coalesce(cast(@DisableFunP2P as varchar(1)),space(1)) + '" ' +
	'Disable162_1101="' + coalesce(cast(@Disable162_1101 as varchar(1)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 1101,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH

-- Write Log Credit	
Declare @LogSPCredit varchar(MAX)
Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1)) + ',
SubAccName='+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1210
END TRY
BEGIN CATCH
	Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1)) + ',
		SubAccName='+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + ',
		ErrMsg=' + ERROR_MESSAGE()
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1210
END CATCH
	
--Log positiontaking
Select @LogSPData = '<Acc_CustomerInsMember_SAg><s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v161spt_81="' + coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="' + coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_86="' + coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="' + coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="' + coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="' + coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
'v161slivept_87="' + coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
'v161slivept_89="' + coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
'v161slivept_90="' + coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
 
'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' + 
'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

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

-- mix parlay of mixed sports
'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

-- number game
'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' + 
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' + 
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' + 
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' + 
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' + 
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerInsMember_SAg>' 

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 401,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerInsMember_SAg><s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v161spt_81="' + coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161spt_83="' + coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
	'v161spt_86="' + coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161spt_88="' + coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'v161slivept_85="' + coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161slivept_86="' + coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
	'v161slivept_87="' + coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
	'v161slivept_89="' + coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
	'v161slivept_90="' + coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
	 
	'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' + 
	'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
	'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
	'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
	'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

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

	-- mix parlay of mixed sports
	'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +

	-- number game
	'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' + 
	'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' + 
	'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' + 
	'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' + 
	'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' + 
	'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' + 
	'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
	'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' + 
	'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" /></Acc_CustomerInsMember_SAg>' 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 401,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_SAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_SAg] TO [bodbExtAccNet] AS [dbo]
GO
