 ALTER PROCEDURE [dbo].[Acc_Dep_CustomerSelMember_AgInfo]
	@CustID INT
AS

/*
Created: 20120720@Dom
TASk : Select Min/Max setting Agent to add new member
DB: DB052.bodb02

Revisions:
    
Param's Explanation:
• @CustID: agent ID
*/
SET NOCOUNT ON

DECLARE @MinBetv1						MONEY, 
		@MinBetv1_Max					MONEY,
		@MinBetv2						MONEY, 
		@MinBetv2_Max					MONEY,
		@MinBetv3						MONEY,  
		@MinBetv3_Max					MONEY,  
		@MinBetv5						MONEY,  
		@MinBetv5_Max					MONEY,  
		@MinBetv8						MONEY,  
		@MinBetv8_Max					MONEY,  
		@MinBetv10						MONEY,  
		@MinBetv10_Max					MONEY,  
		@MinBetv11						MONEY,  
		@MinBetv11_Max					MONEY,  
		@MinBetv99						MONEY,  
		@MinBetv99_Max					MONEY,  
		
		@MaxBetv1						MONEY,
		@MaxBetv1_Min					MONEY,  
		@MaxBetv2						MONEY,
		@MaxBetv2_Min					MONEY,  
		@MaxBetv3						MONEY,
		@MaxBetv3_Min					MONEY,
		@MaxBetv5						MONEY,
		@MaxBetv5_Min					MONEY,
		@MaxBetv8						MONEY,
		@MaxBetv8_Min					MONEY,
		@MaxBetv10						MONEY,
		@MaxBetv10_Min					MONEY,
		@MaxBetv11						MONEY,
		@MaxBetv11_Min					MONEY,
		@MaxBetv99						MONEY,
		@MaxBetv99_Min					MONEY,
		
		@v151MinBet_31					MONEY,
		@v151MinBet_31_Max				MONEY,
		@v151MinBet_41					MONEY,
		@v151MinBet_41_Max				MONEY,
		@v151MinBet_51					MONEY,
		@v151MinBet_51_Max				MONEY,
		@v152MinBet_41					MONEY,
		@v152MinBet_41_Max				MONEY,
		@v152MinBet_51					MONEY,
		@v152MinBet_51_Max				MONEY,
		@v153MinBet_51					MONEY,
		@v153MinBet_51_Max				MONEY,

		@v151MaxBet_31					MONEY,
		@v151MaxBet_31_Min				MONEY,
		@v151MaxBet_41					MONEY,
		@v151MaxBet_41_Min				MONEY,
		@v151MaxBet_51					MONEY,
		@v151MaxBet_51_Min				MONEY,
		@v152MaxBet_41					MONEY,
		@v152MaxBet_41_Min				MONEY,
		@v152MaxBet_51					MONEY,
		@v152MaxBet_51_Min				MONEY,
		@v153MaxBet_51					MONEY,
		@v153MaxBet_51_Min				MONEY,

		@MinBetv161						MONEY,
		@MinBetv161_Max					MONEY,
		@MaxBetv161						MONEY,
		@MaxBetv161_Min					MONEY,

		@MinBetv99MP					MONEY,
		@MinBetv99MP_Max				MONEY,
		@MaxBetv99MP					MONEY,
		@MaxBetv99MP_Min				MONEY,
		
		@MaxPerMatchv1_Min  MONEY,
		@MaxPerMatchv2_Min  MONEY,
		@MaxPerMatchv3_Min  MONEY,
		@MaxPerMatchv5_Min  MONEY,
		@MaxPerMatchv8_Min  MONEY,
		@MaxPerMatchv10_Min  MONEY,
		@MaxPerMatchv11_Min  MONEY,
		@MaxPerMatchv99_Min  MONEY,
		@MaxPerMatchv99MP_Min  MONEY,
		@MaxPerMatchv161_Min  MONEY,
		
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
		@MaxPerMatchv99MP				MONEY,
		@MaxPerMatchv99MP_Max			MONEY,
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

		@v1aPositionTaking_1				MONEY,
		@v1aPositionTaking_1_Max			MONEY,
		@v161aPositionTaking_81				MONEY,
		@v161aPositionTaking_81_Max			MONEY,

		@v151aPositionTaking_31			MONEY,
		@v151aPositionTaking_41			MONEY,
		@v151aPositionTaking_51			MONEY,
		@v152aPositionTaking_41			MONEY,
		@v152aPositionTaking_51			MONEY,
		@v153aPositionTaking_51			MONEY,

		@v151aPositionTaking_31_Max MONEY,
		@v151aPositionTaking_41_Max MONEY,
		@v151aPositionTaking_51_Max MONEY,
		@v152aPositionTaking_41_Max MONEY,
		@v152aPositionTaking_51_Max MONEY,
		@v153aPositionTaking_51_Max MONEY,
		
		--Virtual Sport
		@MinBetv180 MONEY,
		@MaxBetv180 MONEY,
		@v180aPositionTaking_1201 SMALLMONEY,
		@MinBetv180_Max MONEY,
		@MaxBetv180_Min MONEY,
		@MaxPerMatchv180_Min MONEY,
		@MaxPerMatchv180_Max MONEY,
		@v180aPositionTaking_1201_Max MONEY,

		@recommend				INT,

		@UserName				VARCHAR(50)
		
SELECT @recommend = recommend, @UserName = username FROM custinfo AS ci WITH (NOLOCK) where custid = @CustID

SELECT  @MinBetv1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.minbet ELSE 0 END) , 
		@MaxBetv1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.maxbet ELSE 0 END),
		@v1aPositionTaking_1 = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.apositiontaking ELSE 0 END),

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
		@v161aPositionTaking_81 = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.apositiontaking ELSE 0 END),
		
		@MinBetv180 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.minbet ELSE 0 END),
		@MaxBetv180 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.maxbet ELSE 0 END),
		@v180aPositionTaking_1201 = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.apositiontaking ELSE 0 END),

		@v151MinBet_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151aPositionTaking_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),

		@v151MinBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151aPositionTaking_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),

		@v151MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.minbet ELSE 0 END),
		@v151MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.maxbet ELSE 0 END),
		@v151aPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),

		@v152MinBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.minbet ELSE 0 END),
		@v152MaxBet_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.maxbet ELSE 0 END),
		@v152aPositionTaking_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.apositiontaking ELSE 0 END),

		@v152MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.minbet ELSE 0 END),
		@v152MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.maxbet ELSE 0 END),
		@v152aPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.apositiontaking ELSE 0 END),

		@v153MinBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.minbet ELSE 0 END),
		@v153MaxBet_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.maxbet ELSE 0 END),
		@v153aPositionTaking_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.apositiontaking ELSE 0 END),
		
		--HR Comm
		@v151Discount_31 = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),
		@v151Discount_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),
		@v151Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),

		@v152Discount_41 = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.discount ELSE 0 END),
		@v152Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.discount ELSE 0 END),

		@v153Discount_51 = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.discount ELSE 0 END)

FROM Dep_CustSetting AS cs WITH (NOLOCK) 
	INNER JOIN Dep_CustSetting3rd AS cs3rd WITH (NOLOCK) ON cs.custid = cs3rd.custid
WHERE cs.custid = @CustID

--- MIN and MAX setting
SELECT  @MinBetv1_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv1_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=1
WHERE ci.custid = @CustID
		
SELECT	@MinBetv2_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv2_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=2
WHERE ci.custid = @CustID		

SELECT	@MinBetv3_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv3_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=3
WHERE ci.custid = @CustID		

		
SELECT	@MinBetv5_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv5_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=5
WHERE ci.custid = @CustID		
		
SELECT	@MinBetv8_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv8_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=8
WHERE ci.custid = @CustID

SELECT	@MinBetv10_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv10_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=10
WHERE ci.custid = @CustID		

SELECT	@MinBetv11_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv11_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=11
WHERE ci.custid = @CustID		

SELECT	@MinBetv99_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv99_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1 AND cs.sporttype=99
WHERE ci.custid = @CustID		

SELECT	@MinBetv99MP_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv99MP_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 9 AND cs.sporttype=99
WHERE ci.custid = @CustID		

SELECT	@MinBetv161_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv161_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 81 AND cs.sporttype=161
WHERE ci.custid = @CustID

SELECT	@MinBetv180_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@MaxBetv180_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 1201 AND cs.sporttype=180
WHERE ci.custid = @CustID

SELECT	@v151MinBet_31_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_31_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 31 AND cs.sporttype=151
WHERE ci.custid = @CustID

SELECT	@v151MinBet_41_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_41_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 41 AND cs.sporttype=151
WHERE ci.custid = @CustID

SELECT	@v151MinBet_51_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v151MaxBet_51_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 51 AND cs.sporttype=151
WHERE ci.custid = @CustID

SELECT	@v152MinBet_41_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v152MaxBet_41_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 41 AND cs.sporttype=152
WHERE ci.custid = @CustID

SELECT	@v152MinBet_51_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v152MaxBet_51_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 51 AND cs.sporttype=152
WHERE ci.custid = @CustID

SELECT	@v153MinBet_51_Max = max(case when MinBet = 0 then NULL else MinBet end),
		@v153MaxBet_51_Min = min(case when MaxBet = 0 then NULL else MaxBet end)
FROM 
	dep_custsetting3rd AS cs WITH (NOLOCK)
	INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.MRecommend OR cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend) AND cs.bettype = 51 AND cs.sporttype=153
WHERE ci.custid = @CustID

Select	
	@MaxPerMatchv1_Min = 0,
	@MaxPerMatchv2_Min = 0,
	@MaxPerMatchv3_Min = 0,
	@MaxPerMatchv5_Min = 0,
	@MaxPerMatchv8_Min = 0,
	@MaxPerMatchv10_Min = 0,
	@MaxPerMatchv11_Min = 0,
	@MaxPerMatchv99_Min = 0,
	@MaxPerMatchv99MP_Min = 0,
	@MaxPerMatchv161_Min = 0,
	@MaxPerMatchv180_Min = 0,
	
	@MaxPerMatchv1_Max = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end), 
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
	@MaxPerMatchv180_Max = Min(case when cs.MaxPerMatch180 = 0 then NULL else cs.MaxPerMatch180 end),
	@v151MaxPerMatch_31_Max	= Min(case when cs.maxpermatch151 = 0 then NULL else cs.maxpermatch151 end),
	@v151MaxPerMatch_41_Max	= Min(case when cs.maxpermatch151_OT = 0 then NULL else cs.maxpermatch151_OT end),
	@v151MaxPerMatch_51_Max	= Min(case when cs.MaxPerMatch151_AU = 0 then NULL else cs.MaxPerMatch151_AU end),
	@v152MaxPerMatch_41_Max	= Min(case when cs.MaxPerMatch152_UK = 0 then NULL else cs.MaxPerMatch152_UK end),
	@v152MaxPerMatch_51_Max	= Min(case when cs.MaxPerMatch152_AU = 0 then NULL else cs.MaxPerMatch152_AU end),
	@v153MaxPerMatch_51_Max	= Min(case when cs.MaxPerMatch153_AU = 0 then NULL else cs.MaxPerMatch153_AU end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend OR cs.CustID = ci.Recommend)
where ci.custid = @CustID

--PT MAX
SELECT	@v1aPositionTaking_1_Max = max(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.apositiontaking ELSE 0 END),
		@v161aPositionTaking_81_Max = max(CASE WHEN cs3rd.bettype = 81 AND cs3rd.sporttype = 161 THEN cs3rd.apositiontaking ELSE 0 END),
		
		@v180aPositionTaking_1201_Max = max(CASE WHEN cs3rd.bettype = 1201 AND cs3rd.sporttype = 180 THEN cs3rd.apositiontaking ELSE 0 END),
		
		--HR PT Max
		@v151aPositionTaking_31_Max = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),
		@v151aPositionTaking_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),
		@v151aPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.apositiontaking ELSE 0 END),
		@v152aPositionTaking_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.apositiontaking ELSE 0 END),
		@v152aPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.apositiontaking ELSE 0 END),
		@v153aPositionTaking_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.apositiontaking ELSE 0 END),
		-- Commision Max
		@v151Discount_31_Max = max(CASE WHEN cs3rd.bettype = 31 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),
		@v151Discount_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),
		@v151Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 151 THEN cs3rd.discount ELSE 0 END),
		@v152Discount_41_Max = max(CASE WHEN cs3rd.bettype = 41 AND cs3rd.sporttype = 152 THEN cs3rd.discount ELSE 0 END),
		@v152Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 152 THEN cs3rd.discount ELSE 0 END),
		@v153Discount_51_Max = max(CASE WHEN cs3rd.bettype = 51 AND cs3rd.sporttype = 153 THEN cs3rd.discount ELSE 0 END)

FROM Dep_CustSetting AS cs WITH (NOLOCK)
	INNER JOIN Dep_CustSetting3rd AS cs3rd WITH (NOLOCK) ON cs.custid = cs3rd.custid
 WHERE cs.custid = @recommend
 
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
	@MinBetv180   AS minbetv180,

	isnull(@MinBetv1_Max,0)     AS MinBetv1_Max,
	isnull(@MinBetv2_Max,0)     AS MinBetv2_Max,
	isnull(@MinBetv3_Max,0)     AS MinBetv3_Max,
	isnull(@MinBetv5_Max,0)     AS MinBetv5_Max,
	isnull(@MinBetv8_Max,0)     AS MinBetv8_Max,
	isnull(@MinBetv10_Max,0)    AS MinBetv10_Max,
	isnull(@MinBetv11_Max,0)    AS MinBetv11_Max,	
	isnull(@MinBetv99_Max,0)    AS MinBetv99_Max,
	isnull(@MinBetv99MP_Max,0)  AS minbetv99MP_Max,
	isnull(@MinBetv161_Max,0)   AS minbetv161_Max,
	
	isnull(@MinBetv180_Max,0)   AS minbetv180_Max,
	
	@v151MinBet_31 AS v151MinBet_31,
	@v151MinBet_41 AS v151MinBet_41,
	@v151MinBet_51 AS v151MinBet_51,
	@v152MinBet_41 AS v152MinBet_41,
	@v152MinBet_51 AS v152MinBet_51,
	@v153MinBet_51 AS v153MinBet_51,

	isnull(@v151MinBet_31_Max,0) AS v151MinBet_31_Max,
	isnull(@v151MinBet_41_Max,0) AS v151MinBet_41_Max,
	isnull(@v151MinBet_51_Max,0) AS v151MinBet_51_Max,
	isnull(@v152MinBet_41_Max,0) AS v152MinBet_41_Max,
	isnull(@v152MinBet_51_Max,0) AS v152MinBet_51_Max,
	isnull(@v153MinBet_51_Max,0) AS v153MinBet_51_Max,

	@v151MaxBet_31 AS v151MaxBet_31,
	@v151MaxBet_41 AS v151MaxBet_41,
	@v151MaxBet_51 AS v151MaxBet_51,
	@v152MaxBet_41 AS v152MaxBet_41,
	@v152MaxBet_51 AS v152MaxBet_51,
	@v153MaxBet_51 AS v153MaxBet_51,

	isnull(@v151MaxBet_31_Min,0) AS v151MaxBet_31_Min,
	isnull(@v151MaxBet_41_Min,0) AS v151MaxBet_41_Min,
	isnull(@v151MaxBet_51_Min,0) AS v151MaxBet_51_Min,
	isnull(@v152MaxBet_41_Min,0) AS v152MaxBet_41_Min,
	isnull(@v152MaxBet_51_Min,0) AS v152MaxBet_51_Min,
	isnull(@v153MaxBet_51_Min,0) AS v153MaxBet_51_Min,

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

	isnull(@MaxBetv1_Min,0) AS MaxBetv1_Min,
	isnull(@MaxBetv2_Min,0) AS MaxBetv2_Min,
	isnull(@MaxBetv3_Min,0) AS MaxBetv3_Min,
	isnull(@MaxBetv5_Min,0) AS MaxBetv5_Min,
	isnull(@MaxBetv8_Min,0) AS MaxBetv8_Min,
	isnull(@MaxBetv10_Min,0) AS MaxBetv10_Min,
	isnull(@MaxBetv11_Min,0) AS MaxBetv11_Min,	
	isnull(@MaxBetv99_Min,0) AS MaxBetv99_Min,
	isnull(@MaxBetv99MP_Min,0) AS Maxbetv99MP_Min,
	isnull(@MaxBetv161_Min,0) AS Maxbetv161_Min,
	
	isnull(@MaxBetv180_Min,0) AS Maxbetv180_Min,

	---PT
	@v1aPositionTaking_1 AS v1aPositionTaking_1,
	@v1aPositionTaking_1_Max AS v1aPositionTaking_1_Max,
	@v161aPositionTaking_81 AS v161aPositionTaking_81,
	@v161aPositionTaking_81_Max AS v161aPositionTaking_81_Max,
	
	@v180aPositionTaking_1201 AS v180aPositionTaking_1201,
	@v180aPositionTaking_1201_Max AS v180aPositionTaking_1201_Max,

	@v151aPositionTaking_31		AS v151aPositionTaking_31,
	@v151aPositionTaking_41		AS v151aPositionTaking_41,
	@v151aPositionTaking_51		AS v151aPositionTaking_51,
	@v152aPositionTaking_41		AS v152aPositionTaking_41,
	@v152aPositionTaking_51		AS v152aPositionTaking_51,
	@v153aPositionTaking_51		AS v153aPositionTaking_51,

	@v151aPositionTaking_31_Max	AS v151aPositionTaking_31_Max,
	@v151aPositionTaking_41_Max	AS v151aPositionTaking_41_Max,
	@v151aPositionTaking_51_Max	AS v151aPositionTaking_51_Max,
	@v152aPositionTaking_41_Max	AS v152aPositionTaking_41_Max,
	@v152aPositionTaking_51_Max	AS v152aPositionTaking_51_Max,
	@v153aPositionTaking_51_Max	AS v153aPositionTaking_51_Max,

	-- Max Per Match
	isnull(@MaxPerMatchv1_Max,0)			AS MaxPerMatchv1_Max,		
	isnull(@MaxPerMatchv2_Max,0)			AS MaxPerMatchv2_Max,		
	isnull(@MaxPerMatchv3_Max,0)			AS MaxPerMatchv3_Max,		
	isnull(@MaxPerMatchv5_Max,0)			AS MaxPerMatchv5_Max,		
	isnull(@MaxPerMatchv8_Max,0)			AS MaxPerMatchv8_Max,		
	isnull(@MaxPerMatchv10_Max,0)			AS MaxPerMatchv10_Max,		
	isnull(@MaxPerMatchv11_Max,0)			AS MaxPerMatchv11_Max,		
	isnull(@MaxPerMatchv99_Max,0)			AS MaxPerMatchv99_Max,		
	isnull(@MaxPerMatchv99MP_Max,0)			AS MaxPerMatchv99MP_Max,	
	isnull(@MaxPerMatchv161_Max,0)			AS MaxPerMatchv161_Max,	
	isnull(@MaxPerBallv161_Max,0)			AS MaxPerBallv161_Max,	
	
	isnull(@MaxPerMatchv180_Max,0)			AS MaxPerMatchv180_Max,	
		
	isnull(@v151MaxPerMatch_31_Max,0)		AS v151MaxPerMatch_31_Max,
	isnull(@v151MaxPerMatch_41_Max,0)		AS v151MaxPerMatch_41_Max,
	isnull(@v151MaxPerMatch_51_Max,0)		AS v151MaxPerMatch_51_Max,
	isnull(@v152MaxPerMatch_41_Max,0)		AS v152MaxPerMatch_41_Max,
	isnull(@v152MaxPerMatch_51_Max,0)		AS v152MaxPerMatch_51_Max,
	isnull(@v153MaxPerMatch_51_Max,0)		AS v153MaxPerMatch_51_Max,

	ci.MaxPerMatch				AS MaxPerMatchv1,		
	ci.MaxPerMatch2				AS MaxPerMatchv2,		
	ci.MaxPerMatch3				AS MaxPerMatchv3,		
	ci.MaxPerMatch5				AS MaxPerMatchv5,		
	ci.MaxPerMatch8				AS MaxPerMatchv8,		
	ci.MaxPerMatch10			AS MaxPerMatchv10,		
	ci.MaxPerMatch11			AS MaxPerMatchv11,		
	ci.MaxPerMatch99			AS MaxPerMatchv99,		
	ci.MaxPerMatch99MP			AS MaxPerMatchv99MP,	
	ci.MaxPerMatch161			AS MaxPerMatchv161,	
	ci.MaxPerBall161			AS MaxPerBallv161,	
	ci.MaxPerMatch180			AS MaxPerMatchv180,		
	ci.MaxPerMatch151			AS v151MaxPerMatch_31,
	ci.MaxPerMatch151_OT		AS v151MaxPerMatch_41,
	ci.MaxPerMatch151_AU		AS v151MaxPerMatch_51,
	ci.MaxPerMatch152_UK		AS v152MaxPerMatch_41,
	ci.MaxPerMatch152_AU		AS v152MaxPerMatch_51,
	ci.MaxPerMatch153_AU		AS v153MaxPerMatch_51,

	--discount
	@v151Discount_31 AS v151Discount_31,
	@v151Discount_41 AS v151Discount_41,
	@v151Discount_51 AS v151Discount_51,
	@v152Discount_41 AS v152Discount_41,
	@v152Discount_51 AS v152Discount_51,
	@v153Discount_51 AS v153Discount_51,

	0 AS v151Discount_31_Max,
	0 AS v151Discount_41_Max,
	0 AS v151Discount_51_Max,
	0 AS v152Discount_41_Max,
	0 AS v152Discount_51_Max,
	0 AS v153Discount_51_Max,

	ci.DisableHorseRacing			AS Disable151_31,
	ci.DisableOpenTote				AS Disable151_41,
	ci.Disable151_AU				AS Disable151_51,
	ci.Disable152_UK				AS Disable152_41,
	ci.Disable152_AU				AS Disable152_51,
	ci.Disable153_AU				AS Disable153_51,

	@UserName AS UserName
FROM custinfo (NOLOCK) ci  WHERE ci.custid = @CustID

GO
GRANT VIEW definition ON [dbo].[Acc_Dep_CustomerSelMember_AgInfo] TO [bodbadminNet] 
GO
GRANT VIEW definition ON [dbo].[Acc_Dep_CustomerSelMember_AgInfo] TO [vnteam] 