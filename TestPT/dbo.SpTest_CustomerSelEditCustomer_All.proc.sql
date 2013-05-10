ALTER PROCEDURE  [dbo].[SpTest_CustomerSelEditCustomer_All]
@CustID int,

@firstname nvarchar(50) OUTPUT,
@lastname nvarchar(50) OUTPUT,
@phone nvarchar(50) OUTPUT,
@mobilephone nvarchar(50) OUTPUT,
@playerdiscount decimal(9,8) OUTPUT,
@playerdiscountcs decimal(9,8) OUTPUT,
@minbet money OUTPUT,
@maxbet money OUTPUT,
@maxpermatch money OUTPUT,
@minbetb money OUTPUT,
@maxbetb money OUTPUT,
@maxpermatchb money OUTPUT,
@credit money OUTPUT,
@UpdateClosed bit OUTPUT,

@apositiontaking_1 smallmoney OUTPUT,
@apositiontaking_2 smallmoney OUTPUT,
@apositiontaking_3 smallmoney OUTPUT,
@apositiontaking_4 smallmoney OUTPUT,
@apositiontaking_5 smallmoney OUTPUT,
@apositiontaking_6 smallmoney OUTPUT,
@apositiontaking_7 smallmoney OUTPUT,
@apositiontaking_8 smallmoney OUTPUT,
@apositiontaking_9 smallmoney OUTPUT,
@apositiontaking_10 smallmoney OUTPUT,

@mpositiontaking_1 smallmoney OUTPUT,
@mpositiontaking_2 smallmoney OUTPUT,
@mpositiontaking_3 smallmoney OUTPUT,
@mpositiontaking_4 smallmoney OUTPUT,
@mpositiontaking_5 smallmoney OUTPUT,
@mpositiontaking_6 smallmoney OUTPUT,
@mpositiontaking_7 smallmoney OUTPUT,
@mpositiontaking_8 smallmoney OUTPUT,
@mpositiontaking_9 smallmoney OUTPUT,
@mpositiontaking_10 smallmoney OUTPUT,

@spositiontaking_1 smallmoney OUTPUT,
@spositiontaking_2 smallmoney OUTPUT,
@spositiontaking_3 smallmoney OUTPUT,
@spositiontaking_4 smallmoney OUTPUT,
@spositiontaking_5 smallmoney OUTPUT,
@spositiontaking_6 smallmoney OUTPUT,
@spositiontaking_7 smallmoney OUTPUT,
@spositiontaking_8 smallmoney OUTPUT,
@spositiontaking_9 smallmoney OUTPUT,
@spositiontaking_10 smallmoney OUTPUT,

@auto_spositiontaking_1 smallmoney OUTPUT,
@auto_spositiontaking_2 smallmoney OUTPUT,
@auto_spositiontaking_3 smallmoney OUTPUT,
@auto_spositiontaking_4 smallmoney OUTPUT,
@auto_spositiontaking_5 smallmoney OUTPUT,
@auto_spositiontaking_6 smallmoney OUTPUT,
@auto_spositiontaking_7 smallmoney OUTPUT,
@auto_spositiontaking_8 smallmoney OUTPUT,
@auto_spositiontaking_9 smallmoney OUTPUT,
@auto_spositiontaking_10 smallmoney OUTPUT,

@isauto_spositiontaking_1 bit OUTPUT,
@isauto_spositiontaking_2 bit OUTPUT,
@isauto_spositiontaking_3 bit OUTPUT,
@isauto_spositiontaking_4 bit OUTPUT,
@isauto_spositiontaking_5 bit OUTPUT,
@isauto_spositiontaking_6 bit OUTPUT,
@isauto_spositiontaking_7 bit OUTPUT,
@isauto_spositiontaking_8 bit OUTPUT,
@isauto_spositiontaking_9 bit OUTPUT,
@isauto_spositiontaking_10 bit OUTPUT,

@m_auto_spositiontaking_1 smallmoney OUTPUT,
@m_auto_spositiontaking_2 smallmoney OUTPUT,
@m_auto_spositiontaking_3 smallmoney OUTPUT,
@m_auto_spositiontaking_4 smallmoney OUTPUT,
@m_auto_spositiontaking_5 smallmoney OUTPUT,
@m_auto_spositiontaking_6 smallmoney OUTPUT,
@m_auto_spositiontaking_7 smallmoney OUTPUT,
@m_auto_spositiontaking_8 smallmoney OUTPUT,
@m_auto_spositiontaking_9 smallmoney OUTPUT,
@m_auto_spositiontaking_10 smallmoney OUTPUT,

@m_isauto_spositiontaking_1 bit OUTPUT,
@m_isauto_spositiontaking_2 bit OUTPUT,
@m_isauto_spositiontaking_3 bit OUTPUT,
@m_isauto_spositiontaking_4 bit OUTPUT,
@m_isauto_spositiontaking_5 bit OUTPUT,
@m_isauto_spositiontaking_6 bit OUTPUT,
@m_isauto_spositiontaking_7 bit OUTPUT,
@m_isauto_spositiontaking_8 bit OUTPUT,
@m_isauto_spositiontaking_9 bit OUTPUT,
@m_isauto_spositiontaking_10 bit OUTPUT,

@alivepositiontaking_1 smallmoney OUTPUT,
@alivepositiontaking_3 smallmoney OUTPUT,
@alivepositiontaking_7 smallmoney OUTPUT,
@alivepositiontaking_8 smallmoney OUTPUT,

@mlivepositiontaking_1 smallmoney OUTPUT,
@mlivepositiontaking_3 smallmoney OUTPUT,
@mlivepositiontaking_7 smallmoney OUTPUT,
@mlivepositiontaking_8 smallmoney OUTPUT,

@slivepositiontaking_1 smallmoney OUTPUT,
@slivepositiontaking_3 smallmoney OUTPUT,
@slivepositiontaking_7 smallmoney OUTPUT,
@slivepositiontaking_8 smallmoney OUTPUT,

@auto_slivepositiontaking_1 smallmoney OUTPUT,
@auto_slivepositiontaking_3 smallmoney OUTPUT,
@auto_slivepositiontaking_7 smallmoney OUTPUT,
@auto_slivepositiontaking_8 smallmoney OUTPUT,

@isauto_slivepositiontaking_1 bit OUTPUT,
@isauto_slivepositiontaking_3 bit OUTPUT,
@isauto_slivepositiontaking_7 bit OUTPUT,
@isauto_slivepositiontaking_8 bit OUTPUT,

@m_auto_slivepositiontaking_1 smallmoney OUTPUT,
@m_auto_slivepositiontaking_3 smallmoney OUTPUT,
@m_auto_slivepositiontaking_7 smallmoney OUTPUT,
@m_auto_slivepositiontaking_8 smallmoney OUTPUT,

@m_isauto_slivepositiontaking_1 bit OUTPUT,
@m_isauto_slivepositiontaking_3 bit OUTPUT,
@m_isauto_slivepositiontaking_7 bit OUTPUT,
@m_isauto_slivepositiontaking_8 bit OUTPUT,

@bapositiontaking_1 smallmoney OUTPUT,
@bapositiontaking_2 smallmoney OUTPUT,
@bapositiontaking_3 smallmoney OUTPUT,
@bapositiontaking_7 smallmoney OUTPUT,
@bapositiontaking_8 smallmoney OUTPUT,

@bmpositiontaking_1 smallmoney OUTPUT,
@bmpositiontaking_2 smallmoney OUTPUT,
@bmpositiontaking_3 smallmoney OUTPUT,
@bmpositiontaking_7 smallmoney OUTPUT,
@bmpositiontaking_8 smallmoney OUTPUT,

@bspositiontaking_1 smallmoney OUTPUT,
@bspositiontaking_2 smallmoney OUTPUT,
@bspositiontaking_3 smallmoney OUTPUT,
@bspositiontaking_7 smallmoney OUTPUT,
@bspositiontaking_8 smallmoney OUTPUT,

@auto_bspositiontaking_1 smallmoney OUTPUT,
@auto_bspositiontaking_2 smallmoney OUTPUT,
@auto_bspositiontaking_3 smallmoney OUTPUT,
@auto_bspositiontaking_7 smallmoney OUTPUT,
@auto_bspositiontaking_8 smallmoney OUTPUT,

@isauto_bspositiontaking_1 bit OUTPUT,
@isauto_bspositiontaking_2 bit OUTPUT,
@isauto_bspositiontaking_3 bit OUTPUT,
@isauto_bspositiontaking_7 bit OUTPUT,
@isauto_bspositiontaking_8 bit OUTPUT,

@m_auto_bspositiontaking_1 smallmoney OUTPUT,
@m_auto_bspositiontaking_2 smallmoney OUTPUT,
@m_auto_bspositiontaking_3 smallmoney OUTPUT,
@m_auto_bspositiontaking_7 smallmoney OUTPUT,
@m_auto_bspositiontaking_8 smallmoney OUTPUT,

@m_isauto_bspositiontaking_1 bit OUTPUT,
@m_isauto_bspositiontaking_2 bit OUTPUT,
@m_isauto_bspositiontaking_3 bit OUTPUT,
@m_isauto_bspositiontaking_7 bit OUTPUT,
@m_isauto_bspositiontaking_8 bit OUTPUT


as
--Original:???
--Th: Used to Test All Postion Taking for Member

SET NOCOUNT ON

set @UpdateClosed = 0

-----------------------------------------------
--**Start Master edits Member**

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @allow bit, @mrecommend bit
select @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
select @allow = dbo.IsAllowChangePositiontaking(@mrecommend, getdate())
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select 	
	@m_auto_spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_4 = max(case when mcs.bettype = 4 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_5 = max(case when mcs.bettype = 5 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_6 = max(case when mcs.bettype = 6 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	@m_auto_spositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end), 
	@m_auto_spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=1 then mcs.autopositiontaking else 0 end),
	
	@m_auto_slivepositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.autolivepositiontaking else 0 end),
	@m_auto_slivepositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.autolivepositiontaking else 0 end),
	@m_auto_slivepositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.autolivepositiontaking else 0 end),
	@m_auto_slivepositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.autolivepositiontaking else 0 end),
	
	@m_auto_bspositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=2 then mcs.autopositiontaking else 0 end),
	@m_auto_bspositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=2 then mcs.autopositiontaking else 0 end),
	@m_auto_bspositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=2 then mcs.autopositiontaking else 0 end),
	@m_auto_bspositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=2 then mcs.autopositiontaking else 0 end),
	@m_auto_bspositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=2 then mcs.autopositiontaking else 0 end),
	
	
	@m_isauto_spositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_4 = max(case when mcs.bettype = 4 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_5 = max(case when mcs.bettype = 5 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_6 = max(case when mcs.bettype = 6 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	@m_isauto_spositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end), 
	@m_isauto_spositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
	
	@m_isauto_slivepositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
	@m_isauto_slivepositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
	@m_isauto_slivepositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
	@m_isauto_slivepositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
	
	@m_isauto_bspositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
	@m_isauto_bspositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
	@m_isauto_bspositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
	@m_isauto_bspositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
	@m_isauto_bspositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end)		
	
From CustSetting as cs with (NOLOCK) 
inner join customer as c with (nolock) on cs.custid = c.custid
inner join custsetting as mcs with (nolock) on mcs.custid = c.mrecommend
where cs.custid = @custid
--**End Master edits Member**
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
--**End Agent edits Member**
Declare @MinBet_Max money, @MaxBet_Min money, @MinBetb_Max money, @MaxBetb_Min money, @MaxPerMatch_Min money, @MaxPerMatchb_Min money

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select
	@MinBet_Max = MinBet, --Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBet_Min = MaxBet --Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend) -- or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetb_Max = MinBet, --Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetb_Min = MaxBet --Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend) --or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @CustID

Select 
	@MaxperMatch_Min = cs.MaxPerMatch, --Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end), 
	@MaxPerMatchb_Min = cs.MaxPerMatchb --Min(case when cs.MaxPerMatchb = 0 then NULL else cs.MaxPerMatchb end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend) --or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

--**End Agent edits Member**
-----------------------------------------------------------------------------------------------



SELECT
	@firstname = c.firstname,
	@lastname = c.lastname,
	@phone =c.phone,
	@mobilephone =c.mobilephone,	 
	@playerdiscount = isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.playerdiscount else 0 end), 0),
	@playerdiscountcs = isnull(max(case when cs.bettype = 4 and cs.sporttype=1 then cs.playerdiscount else 0 end), 0),
	
	@minbet = isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.minbet else 0 end), 0),
	@maxbet = isnull(max(case when cs.bettype = 1 and cs.sporttype=1 then cs.maxbet else 0 end), 0),
	@minbetb = isnull(max(case when cs.bettype = 1 and cs.sporttype=2 then cs.minbet else 0 end), 0),
	@maxbetb = isnull(max(case when cs.bettype = 1 and cs.sporttype=2 then cs.maxbet else 0 end), 0),
	@maxpermatch = isnull(Ci.maxpermatch, 0),
	@maxpermatchb = isnull(ci.maxpermatchb, 0),	
	@credit = isnull(ci.credit, 0),		
	@apositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end),
	@apositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end),

	@mpositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	@mpositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.mpositiontaking else 0 end), 
	@mpositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.mpositiontaking else 0 end),
	
	@spositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.spositiontaking else 0 end),
	@spositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.spositiontaking else 0 end), 
	@spositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.spositiontaking else 0 end), 
	
	@auto_spositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autopositiontaking else 0 end),
	@auto_spositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.autopositiontaking else 0 end), 
	@auto_spositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.autopositiontaking else 0 end), 
	
	@isauto_spositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautopositiontaking else 0 end),
	@isauto_spositiontaking_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then cs.isautopositiontaking else 0 end), 
	@isauto_spositiontaking_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then cs.isautopositiontaking else 0 end), 

	@alivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
	@alivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),

	@mlivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	
	@slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	
	@auto_slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	
	@isauto_slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),

	@bapositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@bapositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@bapositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@bapositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@bapositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end),
	@bmpositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	
	@bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	
	@auto_bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	
	@isauto_bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.isautopositiontaking else 0 end)
	
FROM 
	customer as C with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid  = cs.custid
	inner join exchange with (nolock) ON C.currency=exchange.exchangeid 
WHERE c.custid=@custId
group by 
	c.email, c.fax, c.firstname, c.lastname, ci.maxpermatch, c.mobilephone, c.phone, c.ugroup, c.username, ci.maxpermatchb,
	exchange.minbet, ci.closed, ci.credit
