ALTER PROCEDURE [dbo].[Acc_Dep_CustomerSelMember_Com] 
	@CustID INT
AS

/*
Created: 20120321@Dom
Task : Company edit Super
DB: DB052.bodb02

Revisions:
    
Param's Explanation:
• @CustID: member ID
*/
SET NOCOUNT ON

DECLARE @UserName			NVARCHAR(50),
		@MinBetv1			MONEY,  
		@MinBetv2			MONEY,  
		@MinBetv3			MONEY,  
		@MinBetv5			MONEY,  
		@MinBetv8			MONEY,  
		@MinBetv10			MONEY,  
		@MinBetv11			MONEY,  
		@MinBetv99			MONEY,  

		@MaxBetv1			MONEY,
		@MaxBetv2			MONEY,
		@MaxBetv3			MONEY,
		@MaxBetv5			MONEY,
		@MaxBetv8			MONEY,
		@MaxBetv10			MONEY,
		@MaxBetv11			MONEY,
		@MaxBetv99			MONEY,
		
		@v151MinBet_31		MONEY,
		@v151MinBet_41		MONEY,
		@v151MinBet_51		MONEY,
		@v152MinBet_41		MONEY,
		@v152MinBet_51		MONEY,
		@v153MinBet_51		MONEY,

		@v151MaxBet_31		MONEY,
		@v151MaxBet_41		MONEY,
		@v151MaxBet_51		MONEY,
		@v152MaxBet_41		MONEY,
		@v152MaxBet_51		MONEY,
		@v153MaxBet_51		MONEY,

		@MinBetv99MP		MONEY,
		@MaxBetv99MP		MONEY,
		
		@MinBetv161			MONEY,
		@MaxBetv161			MONEY,
		
		@MaxPerMatchv1		MONEY,
		@MaxPerMatchv2		MONEY,
		@MaxPerMatchv3		MONEY,
		@MaxPerMatchv5		MONEY,
		@MaxPerMatchv8		MONEY,
		@MaxPerMatchv10		MONEY,
		@MaxPerMatchv11		MONEY,		
		@MaxPerMatchv99		MONEY,
		@MaxPerMatchv99MP	MONEY,
		@MaxPerMatchv161	MONEY,	
		@MaxPerBallv161		MONEY,
		@v151MaxPerMatch_31 MONEY,
		@v151MaxPerMatch_41 MONEY,
		@v151MaxPerMatch_51 MONEY,
		@v152MaxPerMatch_41 MONEY,
		@v152MaxPerMatch_51 MONEY,
		@v153MaxPerMatch_51 MONEY,

		@v1sPositionTaking_1	MONEY,
		@v161sPositionTaking_81 MONEY,
		-- House PT
		@v151IBCPositiontaking_31 MONEY,
		@v151IBCPositiontaking_41 MONEY,
		@v151IBCPositiontaking_51 MONEY,
		@v152IBCPositiontaking_41 MONEY,
		@v152IBCPositiontaking_51 MONEY,
		@v153IBCPositiontaking_51 MONEY,
		--Win/Place PT
		@v151sPositiontaking_31 MONEY,
		@v151sPositiontaking_41 MONEY,
		@v151sPositiontaking_51 MONEY,
		@v152sPositiontaking_41 MONEY,
		@v152sPositiontaking_51 MONEY,
		@v153sPositiontaking_51 MONEY,
		-- HR Commistion
		@v151discount_31 DECIMAL(9,8),
		@v151discount_41 DECIMAL(9,8),
		@v151discount_51 DECIMAL(9,8),
		@v152discount_41 DECIMAL(9,8),
		@v152discount_51 DECIMAL(9,8),
		@v153discount_51 DECIMAL(9,8),
		
		--Virtual Sport
		@MinBetv180 MONEY,
		@MaxBetv180 MONEY,
		@v180spositiontaking_1201 SMALLMONEY

SELECT @MinBetv1 = MinBet, @MaxBetv1 = MaxBet, @v1sPositionTaking_1 = spositiontaking FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype =  1 and cs.sporttype=1
SELECT @MinBetv2 = MinBet,@MaxBetv2 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=2
SELECT @MinBetv3 = MinBet,	@MaxBetv3 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=3
SELECT @MinBetv5 = MinBet,	@MaxBetv5 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=5
SELECT @MinBetv8 = MinBet,	@MaxBetv8 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=8
SELECT @MinBetv10 = MinBet,@MaxBetv10 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=10
SELECT @MinBetv11 = MinBet, @MaxBetv11 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=11
SELECT @MinBetv99 = MinBet, @MaxBetv99 = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 1 and cs.sporttype=99
--Mix parlay mixed sports 
SELECT @MinBetv99MP = MinBet, @MaxBetv99MP = MaxBet FROM Dep_CustSetting AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 9 and cs.sporttype=99

--Number Game 
SELECT @MinBetv161 = MinBet, @MaxBetv161 = MaxBet, @v161sPositionTaking_81 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK)	WHERE cs.custid = @CustID and cs.bettype = 81 and cs.sporttype=161

--Horse Racing
SELECT @v151MinBet_31 = MinBet,@v151MaxBet_31 = MaxBet, @v151sPositiontaking_31 = spositiontaking, @v151discount_31 = sdiscount, @v151sPositiontaking_31 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 31 and cs.sporttype=151
SELECT @v151MinBet_41 = MinBet,@v151MaxBet_41 = MaxBet, @v151sPositiontaking_41 = spositiontaking, @v151discount_41 = sdiscount, @v151sPositiontaking_41 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 41 and cs.sporttype=151
SELECT @v151MinBet_51 = MinBet,@v151MaxBet_51 = MaxBet, @v151sPositiontaking_51 = spositiontaking, @v151discount_51 = sdiscount, @v151sPositiontaking_51 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 51 and cs.sporttype=151
SELECT @v152MinBet_41 = MinBet,@v152MaxBet_41 = MaxBet, @v152sPositiontaking_41 = spositiontaking, @v152discount_41 = sdiscount, @v152sPositiontaking_41 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 41 and cs.sporttype=152
SELECT @v152MinBet_51 = MinBet,@v152MaxBet_51 = MaxBet, @v152sPositiontaking_51 = spositiontaking, @v152discount_51 = sdiscount, @v152sPositiontaking_51 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 51 and cs.sporttype=152
SELECT @v153MinBet_51 = MinBet,@v153MaxBet_51 = MaxBet, @v153sPositiontaking_51 = spositiontaking, @v153discount_51 = sdiscount, @v153sPositiontaking_51 = spositiontaking FROM Dep_CustSetting3rd AS cs WITH (NOLOCK) WHERE cs.custid = @CustID and cs.bettype = 51 and cs.sporttype=153

--Virtual Sports
SELECT @v180spositiontaking_1201 = cs3.spositiontaking,@MinBetv180 = cs3.minbet,@MaxBetv180 = cs3.maxbet FROM Dep_CustSetting3rd cs3 WITH(NOLOCK) where cs3.custid = @CustID AND cs3.sporttype = 180 AND cs3.bettype = 1201

-----MaxPerMatch
SELECT  @MinBetv1 AS MinBetv1,
		@MinBetv2  AS MinBetv2,
		@MinBetv3  AS MinBetv3,
		@MinBetv5  AS MinBetv5,
		@MinBetv8  AS MinBetv8,
		@MinBetv10 AS MinBetv10,
		@MinBetv11 AS MinBetv11,	
		@MinBetv99 AS MinBetv99,
		@MinBetv99MP AS MinBetv99MP,
		@MinBetv161 AS MinBetv161,
		
		@v151MinBet_31 AS v151MinBet_31,
		@v151MinBet_41 AS v151MinBet_41,
		@v151MinBet_51 AS v151MinBet_51,
		@v152MinBet_41 AS v152MinBet_41,
		@v152MinBet_51 AS v152MinBet_51,
		@v153MinBet_51 AS v153MinBet_51,

		@v151MaxBet_31 AS v151MaxBet_31,
		@v151MaxBet_41 AS v151MaxBet_41,
		@v151MaxBet_51 AS v151MaxBet_51,
		@v152MaxBet_41 AS v152MaxBet_41,
		@v152MaxBet_51 AS v152MaxBet_51,
		@v153MaxBet_51 AS v153MaxBet_51,

		@MaxBetv1 AS MaxBetv1,
		@MaxBetv2 AS MaxBetv2,
		@MaxBetv3 AS MaxBetv3,
		@MaxBetv5 AS MaxBetv5,
		@MaxBetv8 AS MaxBetv8,
		@MaxBetv10 AS MaxBetv10,
		@MaxBetv11 AS MaxBetv11,	
		@MaxBetv99 AS MaxBetv99,
		@MaxBetv99MP AS MaxBetv99MP,
		@MaxBetv161 AS MaxBetv161,

		@v1sPositionTaking_1 AS v1sPositionTaking_1,
		@v161sPositionTaking_81 AS v161sPositionTaking_81,

		@v151sPositiontaking_31	AS v151sPositiontaking_31,
		@v151sPositiontaking_41	AS v151sPositiontaking_41,
		@v151sPositiontaking_51	AS v151sPositiontaking_51,
		@v152sPositiontaking_41	AS v152sPositiontaking_41,
		@v152sPositiontaking_51	AS v152sPositiontaking_51,
		@v153sPositiontaking_51	AS v153sPositiontaking_51,
		
		ci.MaxPerMatch					AS MaxPerMatchv1,			
		ci.MaxPerMatch2					AS MaxPerMatchv2,			
		ci.MaxPerMatch3					AS MaxPerMatchv3,			
		ci.MaxPerMatch5					AS MaxPerMatchv5,			
		ci.MaxPerMatch8					AS MaxPerMatchv8,			
		ci.MaxPerMatch10				AS MaxPerMatchv10,			
		ci.MaxPerMatch11				AS MaxPerMatchv11,			
		ci.MaxPerMatch99				AS MaxPerMatchv99,			
		ci.MaxPerMatch99MP				AS MaxPerMatchv99MP,		
		ci.MaxPerMatch161				AS MaxPerMatchv161,		
		ci.MaxPerBall161				AS MaxPerBallv161,
		
		ci.MaxPerMatch180				AS MaxPerMatchv180,
					
		ci.MaxPerMatch151				AS v151MaxPerMatch_31,		
		ci.MaxPerMatch151_OT			AS v151MaxPerMatch_41,		
		ci.MaxPerMatch151_AU			AS v151MaxPerMatch_51,		
		ci.MaxPerMatch152_UK			AS v152MaxPerMatch_41,		
		ci.MaxPerMatch152_AU			AS v152MaxPerMatch_51,		
		ci.MaxPerMatch153_AU			AS v153MaxPerMatch_51,		
		
		ci.DisableHorseRacing			AS Disable151_31,
		ci.DisableOpenTote				AS Disable151_41,
		ci.Disable151_AU				AS Disable151_51,
		ci.Disable152_UK				AS Disable152_41,
		ci.Disable152_AU				AS Disable152_51,
		ci.Disable153_AU				AS Disable153_51,
		
		csp.AutoIBCPositionTaking_Tote	AS v151IBCPositiontaking_31,
		csp.AutoIBCPositionTaking_Fixed	AS v151IBCPositiontaking_41,
		csp.AutoIBCPT151_AU				AS v151IBCPositiontaking_51,
		csp.AutoIBCPT152_UK				AS v152IBCPositiontaking_41,
		csp.AutoIBCPT152_AU				AS v152IBCPositiontaking_51,
		csp.AutoIBCPT153_AU				AS v153IBCPositiontaking_51,

		@v151discount_31  AS v151discount_31,
		@v151discount_41  AS v151discount_41,
		@v151discount_51  AS v151discount_51,
		@v152discount_41  AS v152discount_41,
		@v152discount_51  AS v152discount_51,
		@v153discount_51  AS v153discount_51,
		
		@MinBetv180			AS MinBetv180,
		@MaxBetv180			AS MaxBetv180,
		@v180spositiontaking_1201 AS v180spositiontaking_1201, 

		ci.UserName AS UserName
FROM CustInfo AS ci WITH (NOLOCK)
	INNER JOIN CustSuper AS csp WITH (NOLOCK) ON ci.custid = csp.custid
WHERE ci.custid = @CustID

GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerSelMember_Com] TO [bodbadminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerSelMember_Com] TO [vnteam]
Go

/**********************section unit test********************************/
-- to be continued
--Acc_Dep_CustomerSelMember_Com 791080

--select *
--from custinfo ci where custid = 791082
--sp_help custinfo
--select * from dep_custsetting

--select cs.custid, max(cs.maxbet) as maxbetv1_1_max from dep_custsetting cs
--inner join custinfo ci on ci.mrecommend = cs.custid
--where ci.custid = 791083 and cs.sporttype=1 and cs.bettype=3
--group by cs.custid
