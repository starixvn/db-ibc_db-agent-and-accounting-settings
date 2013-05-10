 ALTER PROCEDURE [dbo].[Acc_Dep_CustomerSelMember_SAg]
	@CustID INT
AS

/*
Created: 20120321@Dom
TASk : Super edit master
DB: DB052.bodb02

Revisions:
    
Param's Explanation:
• @CustID: member ID
*/
SET NOCOUNT ON

DECLARE @MinBetv1						MONEY, 
		@MinBetv1_Min					MONEY,
		@MinBetv2						MONEY, 
		@MinBetv2_Min					MONEY,
		@MinBetv3						MONEY,  
		@MinBetv3_Min					MONEY,  
		@MinBetv5						MONEY,  
		@MinBetv5_Min					MONEY,  
		@MinBetv8						MONEY,  
		@MinBetv8_Min					MONEY,  
		@MinBetv10						MONEY,  
		@MinBetv10_Min					MONEY,  
		@MinBetv11						MONEY,  
		@MinBetv11_Min					MONEY,  
		@MinBetv99						MONEY,  
		@MinBetv99_Min					MONEY,  
		
		@MaxBetv1						MONEY,
		@MaxBetv1_Max					MONEY,  
		@MaxBetv2						MONEY,
		@MaxBetv2_Max					MONEY,  
		@MaxBetv3						MONEY,
		@MaxBetv3_Max					MONEY,
		@MaxBetv5						MONEY,
		@MaxBetv5_Max					MONEY,
		@MaxBetv8						MONEY,
		@MaxBetv8_Max					MONEY,
		@MaxBetv10						MONEY,
		@MaxBetv10_Max					MONEY,
		@MaxBetv11						MONEY,
		@MaxBetv11_Max					MONEY,
		@MaxBetv99						MONEY,
		@MaxBetv99_Max					MONEY,
		
		@v151MinBet_31					MONEY,
		@v151MinBet_31_Min				MONEY,
		@v151MinBet_41					MONEY,
		@v151MinBet_41_Min				MONEY,
		@v151MinBet_51					MONEY,
		@v151MinBet_51_Min				MONEY,
		@v152MinBet_41					MONEY,
		@v152MinBet_41_Min				MONEY,
		@v152MinBet_51					MONEY,
		@v152MinBet_51_Min				MONEY,
		@v153MinBet_51					MONEY,
		@v153MinBet_51_Min				MONEY,

		@v151MaxBet_31					MONEY,
		@v151MaxBet_31_Max				MONEY,
		@v151MaxBet_41					MONEY,
		@v151MaxBet_41_Max				MONEY,
		@v151MaxBet_51					MONEY,
		@v151MaxBet_51_Max				MONEY,
		@v152MaxBet_41					MONEY,
		@v152MaxBet_41_Max				MONEY,
		@v152MaxBet_51					MONEY,
		@v152MaxBet_51_Max				MONEY,
		@v153MaxBet_51					MONEY,
		@v153MaxBet_51_Max				MONEY,

		@MinBetv99MP					MONEY,
		@MinBetv99MP_Min				MONEY,
		@MaxBetv99MP					MONEY,
		@MaxBetv99MP_Max				MONEY,
		@MaxPerMatchv99MP				MONEY,
		@MaxPerMatchv99MP_Max			MONEY,
		@MinBetv161						MONEY,
		@MinBetv161_Min					MONEY,
		@MaxBetv161						MONEY,
		@MaxBetv161_Max					MONEY,
		
		@MaxPerMatchv1					MONEY,
		@MaxPerMatchv1_Max				MONEY,
		@MaxPerMatchv2					MONEY,
		@MaxPerMatchv2_Max				MONEY,
		@MaxPerMatchv3					MONEY,
		@MaxPerMatchv3_Max				MONEY,
		@MaxPerMatchv5					MONEY,
		@MaxPerMatchv5_Max				MONEY,
		@MaxPerMatchv8					MONEY,
		@MaxPerMatchv8_Max				MONEY,
		@MaxPerMatchv10					MONEY,
		@MaxPerMatchv10_Max				MONEY,
		@MaxPerMatchv11					MONEY,
		@MaxPerMatchv11_Max				MONEY,		
		@MaxPerMatchv99					MONEY,
		@MaxPerMatchv99_Max				MONEY,
		@MaxPerMatchv161				MONEY,	
		@MaxPerMatchv161_Max			MONEY,	
		@MaxPerBallv161					MONEY,
		@MaxPerBallv161_Max				MONEY,
		@v151MaxPerMatch_31_Max			MONEY,
		@v151MaxPerMatch_41_Max			MONEY,
		@v151MaxPerMatch_51_Max			MONEY,
		@v152MaxPerMatch_41_Max			MONEY,
		@v152MaxPerMatch_51_Max			MONEY,
		@v153MaxPerMatch_51_Max			MONEY,

		@v151MaxPerMatch_31				MONEY,
		@v151MaxPerMatch_41				MONEY,
		@v151MaxPerMatch_51				MONEY,
		@v152MaxPerMatch_41				MONEY,
		@v152MaxPerMatch_51				MONEY,
		@v153MaxPerMatch_51				MONEY,

		@v151Discount_31				DECIMAL(9,8),
		@v151Discount_31_Max			DECIMAL(9,8),
		@v151Discount_41				DECIMAL(9,8),
		@v151Discount_41_Max			DECIMAL(9,8),
		@v151Discount_51				DECIMAL(9,8),
		@v151Discount_51_Max			DECIMAL(9,8),
		@v152Discount_41				DECIMAL(9,8),
		@v152Discount_41_Max			DECIMAL(9,8),
		@v152Discount_51				DECIMAL(9,8),
		@v152Discount_51_Max			DECIMAL(9,8),
		@v153Discount_51				DECIMAL(9,8),
		@v153Discount_51_Max			DECIMAL(9,8),

		@v1mPositionTaking_1				MONEY,
		@v1mPositionTaking_1_Max			MONEY,
		@v161mPositionTaking_81				MONEY,
		@v161mPositionTaking_81_Max			MONEY,

		@v151mPositionTaking_31			MONEY,
		@v151mPositionTaking_41			MONEY,
		@v151mPositionTaking_51			MONEY,
		@v152mPositionTaking_41			MONEY,
		@v152mPositionTaking_51			MONEY,
		@v153mPositionTaking_51			MONEY,

		@v151mPositionTaking_31_Max MONEY,
		@v151mPositionTaking_41_Max MONEY,
		@v151mPositionTaking_51_Max MONEY,
		@v152mPositionTaking_41_Max MONEY,
		@v152mPositionTaking_51_Max MONEY,
		@v153mPositionTaking_51_Max MONEY,
		
		--Virtual Sports
		@MinBetv180				MONEY,
		@MaxBetv180				MONEY,
		@v180mPositionTaking_1201		SMALLMONEY,
		@MaxPerMatchv180		MONEY,
		---------------------------------
		@MinBetv180_Min				MONEY,
		@MaxBetv180_Max				MONEY,
		@v180mPositionTaking_1201_Max		SMALLMONEY,
		@MaxPerMatchv180_Max		MONEY,
		-----End Virtual Sport
		
		@srecommend				INT

SELECT @srecommend = srecommend FROM custinfo AS ci WITH (NOLOCK) where custid = @CustID

SELECT  @MinBetv1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.minbet ELSE 0 END) , 
		@MaxBetv1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.maxbet ELSE 0 END),
		@v1mPositionTaking_1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.mpositiontaking ELSE 0 END),

		@MinBetv2 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 2 THEN cs.minbet ELSE 0 END),
		@MaxBetv2 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 2 THEN cs.maxbet ELSE 0 END),

		@MinBetv3 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 3 THEN cs.minbet ELSE 0 END),
		@MaxBetv3 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 3 THEN cs.maxbet ELSE 0 END),

		@MinBetv5 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 5 THEN cs.minbet ELSE 0 END),
		@MaxBetv5 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 5 THEN cs.maxbet ELSE 0 END),
		
		@MinBetv8 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 8 THEN cs.minbet ELSE 0 END),
		@MaxBetv8 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 8 THEN cs.maxbet ELSE 0 END),

		@MinBetv10 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 10 THEN cs.minbet ELSE 0 END),
		@MaxBetv10 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 10 THEN cs.maxbet ELSE 0 END),

		@MinBetv11 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 11 THEN cs.minbet ELSE 0 END),
		@MaxBetv11 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 11 THEN cs.maxbet ELSE 0 END),

		@MinBetv99 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 99 THEN cs.minbet ELSE 0 END),
		@MaxBetv99 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 99 THEN cs.maxbet ELSE 0 END),

		@MinBetv99MP = max(CASE WHEN cs.bettype = 9 AND cs.sporttype = 99 THEN cs.minbet ELSE 0 END),
		@MaxBetv99MP = max(CASE WHEN cs.bettype = 9 AND cs.sporttype = 99 THEN cs.maxbet ELSE 0 END),

		@MinBetv161 = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.minbet ELSE 0 END),
		@MaxBetv161 = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.maxbet ELSE 0 END),
		@v161mPositionTaking_81 = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.mpositiontaking ELSE 0 END),
		
		@MinBetv180 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.minbet ELSE 0 END) , 
		@MaxBetv180 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.maxbet ELSE 0 END),
		@v180mPositionTaking_1201 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v151MinBet_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151mPositionTaking_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v151MinBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151mPositionTaking_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v151MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151mPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v152MinBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.minbet ELSE 0 END),
		@v152MaxBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.maxbet ELSE 0 END),
		@v152mPositionTaking_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v152MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.minbet ELSE 0 END),
		@v152MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.maxbet ELSE 0 END),
		@v152mPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.mpositiontaking ELSE 0 END),

		@v153MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.minbet ELSE 0 END),
		@v153MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.maxbet ELSE 0 END),
		@v153mPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.mpositiontaking ELSE 0 END),
		
		--HR Comm
		@v151Discount_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.adiscount ELSE 0 END),
		@v151Discount_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.adiscount ELSE 0 END),
		@v151Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.adiscount ELSE 0 END),

		@v152Discount_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.adiscount ELSE 0 END),
		@v152Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.adiscount ELSE 0 END),

		@v153Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.adiscount ELSE 0 END)

FROM Dep_CustSetting AS cs WITH (NOLOCK) 
	INNER JOIN Dep_CustSetting3rd AS cs3rd WITH (NOLOCK) ON cs.custid = cs3rd.custid
WHERE cs.custid = @CustID

		
SELECT  @v1mPositionTaking_1_Max = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.spositiontaking ELSE 0 END),
		@v161mPositionTaking_81_Max = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.spositiontaking ELSE 0 END),
		
		@v180mPositionTaking_1201_Max = MAX(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.spositiontaking ELSE 0 END),
		
		@v151mPositionTaking_31_Max = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.spositiontaking ELSE 0 END),
		@v151mPositionTaking_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.spositiontaking ELSE 0 END),
		@v151mPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.spositiontaking ELSE 0 END),
		
		@v152mPositionTaking_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.spositiontaking ELSE 0 END),
		@v152mPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.spositiontaking ELSE 0 END),
		
		@v153mPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.spositiontaking ELSE 0 END),

		--HR Comm
		@v151Discount_31_Max = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.sdiscount ELSE 0 END),
		@v151Discount_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.sdiscount ELSE 0 END),
		@v151Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.sdiscount ELSE 0 END),

		@v152Discount_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.sdiscount ELSE 0 END),
		@v152Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.sdiscount ELSE 0 END),

		@v153Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.sdiscount ELSE 0 END)

FROM Dep_CustSetting AS cs WITH (NOLOCK)
	INNER JOIN Dep_CustSetting3rd AS cs3rd WITH (NOLOCK) ON cs.custid = cs3rd.custid
 WHERE cs.custid = @srecommend
 
 
 
--min max
Select 
	@MinBetv1_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv1_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetv2_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv2_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @CustID

Select 
	@MinBetv3_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv3_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @CustID

Select 
	@MinBetv5_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv5_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @CustID

Select 
	@MinBetv8_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv8_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @CustID

Select 
	@MinBetv10_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv10_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @CustID

Select 
	@MinBetv11_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv11_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @CustID

Select 
	@MinBetv99_Min = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	dep_custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @CustID

-- mix parlay mixed sports
select	@MinBetv99MP_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv99MP_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from dep_custsetting cs WITH(NOLOCK)
	 INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype = 99
where ci.custid = @Custid


-- number game
select	@MinBetv161_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv161_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 81 and cs.sporttype = 161
where ci.custid = @CustID

--Virtual Sport
select	@MinBetv180_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv180_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 1201 and cs.sporttype = 180
where ci.custid = @CustID

--HR
select	@v151MinBet_31_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_31_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 31 and cs.sporttype = 151
where ci.custid = @CustID

select	@v151MinBet_41_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_41_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 41 and cs.sporttype = 151
where ci.custid = @CustID

select	@v151MinBet_51_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_51_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype = 151
where ci.custid = @CustID

select	@v152MinBet_41_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v152MaxBet_41_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 41 and cs.sporttype = 152
where ci.custid = @CustID

select	@v152MinBet_51_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v152MaxBet_51_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype = 152
where ci.custid = @CustID

select	@v153MinBet_51_Min = Max(case when MinBet = 0 then NULL else MinBet end),
		@v153MaxBet_51_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)
from
	dep_custsetting3rd as cs WITH(NOLOCK)
	INNER JOIN custinfo as ci WITH(NOLOCK) ON (cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype = 153
where ci.custid = @CustID

Select @MaxperMatchv1_Max = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),
	
	@MaxPerMatchv2_Max = Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),
	
	@MaxPerMatchv3_Max = Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),

	@MaxPerMatchv5_Max = Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),

	@MaxPerMatchv8_Max = Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),

	@MaxPerMatchv10_Max = Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),

	@MaxPerMatchv11_Max = Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),

	@MaxPerMatchv99_Max = Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),
		
	@MaxPerMatchv99MP_Max = Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),

	@MaxPerMatchv161_Max = Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),

	@MaxPerBallv161_Max = Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end),
	
	@MaxPerMatchv180_Max = MIN(case when cs.MaxPerMatch180 = 0 then NULL else cs.MaxPerMatch180 end),
	
	@v151MaxPerMatch_31_Max = min(case when cs.maxpermatch151 = 0 then NULL else cs.maxpermatch151 end),
	@v151MaxPerMatch_41_Max=min(case when cs.maxpermatch151_OT = 0 then NULL else cs.maxpermatch151_OT end),
	@v151MaxPerMatch_51_Max=min(case when cs.maxpermatch151_AU = 0 then NULL else cs.maxpermatch151_AU end),
	@v152MaxPerMatch_41_Max=min(case when cs.maxpermatch152_UK = 0 then NULL else cs.maxpermatch152_UK end),
	@v152MaxPerMatch_51_Max=min(case when cs.maxpermatch152_AU = 0 then NULL else cs.maxpermatch152_AU end),
	@v153MaxPerMatch_51_Max=min(case when cs.maxpermatch153_AU = 0 then NULL else cs.maxpermatch153_AU end)
	
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.SRecommend)
where ci.custid = @CustID

--- MaxPerMatch
SELECT @MaxPerMatchv1				= ci.MaxPerMatch,
	@MaxPerMatchv2				= ci.MaxPerMatch2,
	@MaxPerMatchv3				= ci.MaxPerMatch3,
	@MaxPerMatchv5				= ci.MaxPerMatch5,
	@MaxPerMatchv8				= ci.MaxPerMatch8,
	@MaxPerMatchv10				= ci.MaxPerMatch10,
	@MaxPerMatchv11				= ci.MaxPerMatch11,
	@MaxPerMatchv99				= ci.MaxPerMatch99,
	@MaxPerMatchv99MP			= ci.MaxPerMatch99MP,
	@MaxPerMatchv161			= ci.MaxPerMatch161,
	@MaxPerBallv161				= ci.MaxPerBall161,
	
	@MaxPerMatchv180 			= ci.MaxPerMatch180,
	
	@v151MaxPerMatch_31			= ci.MaxPerMatch151,
	@v151MaxPerMatch_41			= ci.MaxPerMatch151_OT,
	@v151MaxPerMatch_51			= ci.MaxPerMatch151_AU,
	@v152MaxPerMatch_41			= ci.MaxPerMatch152_UK,
	@v152MaxPerMatch_51			= ci.MaxPerMatch152_AU,
	@v153MaxPerMatch_51			= ci.MaxPerMatch153_AU
FROM custinfo (NOLOCK) ci WHERE ci.custid = @CustID

		
SELECT @MinBetv1  AS MinBetv1,
	@MinBetv2     AS MinBetv2,
	@MinBetv3     AS MinBetv3,
	@MinBetv5     AS MinBetv5,
	@MinBetv8     AS MinBetv8,
	@MinBetv10    AS MinBetv10,
	@MinBetv11    AS MinBetv11,	
	@MinBetv99    AS MinBetv99,
	@MinBetv99MP  AS minbetv99MP,
	@MinBetv161   AS minbetv161,
	
	@MinBetv180  AS minbetv180,
	
	isnull(@MinBetv1_Min,0)     AS MinBetv1_Min,
	isnull(@MinBetv2_Min,0)     AS MinBetv2_Min,
	isnull(@MinBetv3_Min,0)     AS MinBetv3_Min,
	isnull(@MinBetv5_Min,0)     AS MinBetv5_Min,
	isnull(@MinBetv8_Min,0)     AS MinBetv8_Min,
	isnull(@MinBetv10_Min,0)    AS MinBetv10_Min,
	isnull(@MinBetv11_Min,0)    AS MinBetv11_Min,	
	isnull(@MinBetv99_Min,0)    AS MinBetv99_Min,
	isnull(@MinBetv99MP_Min,0)  AS minbetv99MP_Min,
	isnull(@MinBetv161_Min,0)   AS minbetv161_Min,
	
	isnull(@MinBetv180_Min,0)   AS minbetv180_Min,
	
	@v151MinBet_31 AS v151MinBet_31,
	@v151MinBet_41 AS v151MinBet_41,
	@v151MinBet_51 AS v151MinBet_51,
	@v152MinBet_41 AS v152MinBet_41,
	@v152MinBet_51 AS v152MinBet_51,
	@v153MinBet_51 AS v153MinBet_51,

	isnull(@v151MinBet_31_Min,0) AS v151MinBet_31_Min,
	isnull(@v151MinBet_41_Min,0) AS v151MinBet_41_Min,
	isnull(@v151MinBet_51_Min,0) AS v151MinBet_51_Min,
	isnull(@v152MinBet_41_Min,0) AS v152MinBet_41_Min,
	isnull(@v152MinBet_51_Min,0) AS v152MinBet_51_Min,
	isnull(@v153MinBet_51_Min,0) AS v153MinBet_51_Min,

	@v151MaxBet_31 AS v151MaxBet_31,
	@v151MaxBet_41 AS v151MaxBet_41,
	@v151MaxBet_51 AS v151MaxBet_51,
	@v152MaxBet_41 AS v152MaxBet_41,
	@v152MaxBet_51 AS v152MaxBet_51,
	@v153MaxBet_51 AS v153MaxBet_51,

	isnull(@v151MaxBet_31_Max,0) AS v151MaxBet_31_Max,
	isnull(@v151MaxBet_41_Max,0) AS v151MaxBet_41_Max,
	isnull(@v151MaxBet_51_Max,0) AS v151MaxBet_51_Max,
	isnull(@v152MaxBet_41_Max,0) AS v152MaxBet_41_Max,
	isnull(@v152MaxBet_51_Max,0) AS v152MaxBet_51_Max,
	isnull(@v153MaxBet_51_Max,0) AS v153MaxBet_51_Max,

	@MaxBetv1 AS MaxBetv1,
	@MaxBetv2 AS MaxBetv2,
	@MaxBetv3 AS MaxBetv3,
	@MaxBetv5 AS MaxBetv5,
	@MaxBetv8 AS MaxBetv8,
	@MaxBetv10 AS MaxBetv10,
	@MaxBetv11 AS MaxBetv11,	
	@MaxBetv99 AS MaxBetv99,
	@MaxBetv99MP AS maxbetv99MP,
	@MaxBetv161 AS maxbetv161,
	
	@MaxBetv180 AS maxbetv180,

	isnull(@MaxBetv1_Max,0) AS MaxBetv1_Max,
	isnull(@MaxBetv2_Max,0) AS MaxBetv2_Max,
	isnull(@MaxBetv3_Max,0) AS MaxBetv3_Max,
	isnull(@MaxBetv5_Max,0) AS MaxBetv5_Max,
	isnull(@MaxBetv8_Max,0) AS MaxBetv8_Max,
	isnull(@MaxBetv10_Max,0) AS MaxBetv10_Max,
	isnull(@MaxBetv11_Max,0) AS MaxBetv11_Max,	
	isnull(@MaxBetv99_Max,0) AS MaxBetv99_Max,
	isnull(@MaxBetv99MP_Max,0) AS Maxbetv99MP_Max,
	isnull(@MaxBetv161_Max,0) AS Maxbetv161_Max,
	
	isnull(@MaxBetv180_Max,0) AS Maxbetv180_Max,

	---PT
	@v1mPositionTaking_1 AS v1mPositionTaking_1,
	isnull(@v1mPositionTaking_1_Max,0) AS v1mPositionTaking_1_Max,
	0 AS v1mPositionTaking_1_Min,
	@v161mPositionTaking_81 AS v161mPositionTaking_81,
	isnull(@v161mPositionTaking_81_Max,0) AS v161mPositionTaking_81_Max,
	
	@v180mPositionTaking_1201 AS v180mPositionTaking_1201,
	0 AS v180mPositionTaking_180_Min,
	isnull(@v180mPositionTaking_1201_Max,0) AS v180mPositionTaking_1201_Max,
	
	0 AS v161mPositionTaking_81_Min,
	
	@v151mPositionTaking_31		AS v151mPositionTaking_31,
	@v151mPositionTaking_41		AS v151mPositionTaking_41,
	@v151mPositionTaking_51		AS v151mPositionTaking_51,
	@v152mPositionTaking_41		AS v152mPositionTaking_41,
	@v152mPositionTaking_51		AS v152mPositionTaking_51,
	@v153mPositionTaking_51		AS v153mPositionTaking_51,

	isnull(@v151mPositionTaking_31_Max,0)	AS v151mPositionTaking_31_Max,
	isnull(@v151mPositionTaking_41_Max,0)	AS v151mPositionTaking_41_Max,
	isnull(@v151mPositionTaking_51_Max,0)	AS v151mPositionTaking_51_Max,
	isnull(@v152mPositionTaking_41_Max,0)	AS v152mPositionTaking_41_Max,
	isnull(@v152mPositionTaking_51_Max,0)	AS v152mPositionTaking_51_Max,
	isnull(@v153mPositionTaking_51_Max,0)	AS v153mPositionTaking_51_Max,

	0 AS v151mPositionTaking_31_Min,
	0 AS v151mPositionTaking_41_Min,
	0 AS v151mPositionTaking_51_Min,
	0 AS v152mPositionTaking_41_Min,
	0 AS v152mPositionTaking_51_Min,
	0 AS v153mPositionTaking_51_Min,
	
	isnull(@MaxPerMatchv1_Max,0)    AS MaxPerMatchv1_Max,
	isnull(@MaxPerMatchv2_Max,0)    AS MaxPerMatchv2_Max,
	isnull(@MaxPerMatchv3_Max,0)    AS MaxPerMatchv3_Max,
	isnull(@MaxPerMatchv5_Max,0)    AS MaxPerMatchv5_Max,
	isnull(@MaxPerMatchv8_Max,0)    AS MaxPerMatchv8_Max,
	isnull(@MaxPerMatchv10_Max,0)   AS MaxPerMatchv10_Max,
	isnull(@MaxPerMatchv11_Max,0)   AS MaxPerMatchv11_Max,	
	isnull(@MaxPerMatchv99_Max,0)   AS MaxPerMatchv99_Max,
	isnull(@MaxPerMatchv99MP_Max,0) AS MaxPerMatchv99MP_Max,
	isnull(@MaxPerMatchv161_Max,0)  AS MaxPerMatchv161_Max,
	isnull(@MaxPerBallv161_Max,0)	  AS MaxPerBallv161_Max,
	
	isnull(@MaxPerMatchv180_Max,0)	  AS MaxPerMatchv180_Max,

	isnull(@v151MaxPerMatch_31_Max,0)		AS v151MaxPerMatch_31_Max,
	isnull(@v151MaxPerMatch_41_Max,0)		AS v151MaxPerMatch_41_Max,
	isnull(@v151MaxPerMatch_51_Max,0)		AS v151MaxPerMatch_51_Max,
	isnull(@v152MaxPerMatch_41_Max,0)		AS v152MaxPerMatch_41_Max,
	isnull(@v152MaxPerMatch_51_Max,0)		AS v152MaxPerMatch_51_Max,
	isnull(@v153MaxPerMatch_51_Max,0)		AS v153MaxPerMatch_51_Max,

	@MaxPerMatchv1		AS MaxPerMatchv1,
	@MaxPerMatchv2		AS MaxPerMatchv2,
	@MaxPerMatchv3		AS MaxPerMatchv3,
	@MaxPerMatchv5		AS MaxPerMatchv5,
	@MaxPerMatchv8		AS MaxPerMatchv8,
	@MaxPerMatchv10		AS MaxPerMatchv10,
	@MaxPerMatchv11		AS MaxPerMatchv11,
	@MaxPerMatchv99		AS MaxPerMatchv99,
	@MaxPerMatchv99MP	AS MaxPerMatchv99MP,
	@MaxPerBallv161		AS MaxPerBallv161,
	@MaxPerMatchv161	AS MaxPerMatchv161,
	
	@MaxPerMatchv180	AS MaxPerMatchv180,
	
	@v151MaxPerMatch_31	AS v151MaxPerMatch_31,
	@v151MaxPerMatch_41	AS v151MaxPerMatch_41,
	@v151MaxPerMatch_51	AS v151MaxPerMatch_51,
	@v152MaxPerMatch_41	AS v152MaxPerMatch_41,
	@v152MaxPerMatch_51	AS v152MaxPerMatch_51,
	@v153MaxPerMatch_51	AS v153MaxPerMatch_51,
	--discount
	@v151Discount_31 AS v151Discount_31,
	@v151Discount_41 AS v151Discount_41,
	@v151Discount_51 AS v151Discount_51,
	@v152Discount_41 AS v152Discount_41,
	@v152Discount_51 AS v152Discount_51,
	@v153Discount_51 AS v153Discount_51,

	@v151Discount_31_Max AS v151Discount_31_Max,
	@v151Discount_41_Max AS v151Discount_41_Max,
	@v151Discount_51_Max AS v151Discount_51_Max,
	@v152Discount_41_Max AS v152Discount_41_Max,
	@v152Discount_51_Max AS v152Discount_51_Max,
	@v153Discount_51_Max AS v153Discount_51_Max,

	0 AS v151Discount_31_Min,
	0 AS v151Discount_41_Min,
	0 AS v151Discount_51_Min,
	0 AS v152Discount_41_Min,
	0 AS v152Discount_51_Min,
	0 AS v153Discount_51_Min,

	ci.DisableHorseRacing			AS Disable151_31,
	ci.DisableOpenTote				AS Disable151_41,
	ci.Disable151_AU				AS Disable151_51,
	ci.Disable152_UK				AS Disable152_41,
	ci.Disable152_AU				AS Disable152_51,
	ci.Disable153_AU				AS Disable153_51,

	ci.username
FROM CustInfo AS ci with (NOLOCK) 
WHERE ci.CustID = @CustID
		
		
GO
GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerSelMember_SAg] TO [bodbadminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerSelMember_SAg] TO [vnteam]
Go

/**********************section unit test********************************/
-- to be continued
--Acc_Dep_CustomerSelMember_SAg 791082
--go
--Acc_Dep_CustomerSelMember_Com 791080
--update dep_custsetting set maxbet = 777777 where custid = 791082 and sporttype = 1 and bettype = 1
--select *
--from custinfo ci where srecommend = 791080

--select * from dep_custsetting where custid = 791082

--select cs.custid, max(cs.maxbet) as maxbetv1_1_max from dep_custsetting cs
--inner join custinfo ci on ci.srecommend = cs.custid
--where ci.custid = 791082 and cs.sporttype=1 and cs.bettype=1
--group by cs.custid

--select super.custid, super.maxpermatch as super from custinfo ci inner join custinfo super on ci.srecommend = super.custid
--where ci.custid = 791082