ALTER PROCEDURE [dbo].[SpTest_CustomerSelSEditCustomer]
@CustId int,
@SRecommend int,

@firstname nvarchar(50) OUTPUT,
@lastname nvarchar(50) OUTPUT,
@phone nvarchar(50) OUTPUT,
@mobilephone nvarchar(50) OUTPUT,
@closed bit OUTPUT,

@minbet money OUTPUT,
@maxbet money OUTPUT,
@maxpermatch money OUTPUT,
@minbetb money OUTPUT,
@maxbetb money OUTPUT,
@maxpermatchb money OUTPUT,
@credit money OUTPUT,

@UpdateMultiple bit OUTPUT,

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

@slivepositiontaking_1 smallmoney OUTPUT,
@slivepositiontaking_3 smallmoney OUTPUT,
@slivepositiontaking_7 smallmoney OUTPUT,
@slivepositiontaking_8 smallmoney OUTPUT,

@bspositiontaking_1 smallmoney OUTPUT,
@bspositiontaking_2 smallmoney OUTPUT,
@bspositiontaking_3 smallmoney OUTPUT,
@bspositiontaking_7 smallmoney OUTPUT,
@bspositiontaking_8 smallmoney OUTPUT,

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

@mlivepositiontaking_1 smallmoney OUTPUT,
@mlivepositiontaking_3 smallmoney OUTPUT,
@mlivepositiontaking_7 smallmoney OUTPUT,
@mlivepositiontaking_8 smallmoney OUTPUT,

@bmpositiontaking_1 smallmoney OUTPUT,
@bmpositiontaking_2 smallmoney OUTPUT,
@bmpositiontaking_3 smallmoney OUTPUT,
@bmpositiontaking_7 smallmoney OUTPUT,
@bmpositiontaking_8 smallmoney OUTPUT,

@groupa decimal(9,8) OUTPUT,
@groupb decimal(9,8) OUTPUT,
@groupc decimal(9,8) OUTPUT,
@groupd decimal(9,8) OUTPUT,
@discountcs decimal(9,8) OUTPUT,
@UpdateCommission bit = 1 OUTPUT,
@UpdateMinMaxBet bit = 1 OUTPUT,
@UpdateMinMaxBetb bit = 1 OUTPUT,
@UpdatePositiontaking bit = 1 OUTPUT,
@UpdatePositiontakingb bit = 1 OUTPUT,
@UpdateClosed bit = 0 OUTPUT,

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
@auto_slivepositiontaking_1 smallmoney OUTPUT,
@auto_slivepositiontaking_3 smallmoney OUTPUT,
@auto_slivepositiontaking_7 smallmoney OUTPUT,
@auto_slivepositiontaking_8 smallmoney OUTPUT,
@auto_bspositiontaking_1 smallmoney OUTPUT,
@auto_bspositiontaking_2 smallmoney OUTPUT,
@auto_bspositiontaking_3 smallmoney OUTPUT,
@auto_bspositiontaking_7 smallmoney OUTPUT,
@auto_bspositiontaking_8 smallmoney OUTPUT,

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
@isauto_slivepositiontaking_1 bit OUTPUT,
@isauto_slivepositiontaking_3 bit OUTPUT,
@isauto_slivepositiontaking_7 bit OUTPUT,
@isauto_slivepositiontaking_8 bit OUTPUT,
@isauto_bspositiontaking_1 bit OUTPUT,
@isauto_bspositiontaking_2 bit OUTPUT,
@isauto_bspositiontaking_3 bit OUTPUT,
@isauto_bspositiontaking_7 bit OUTPUT,
@isauto_bspositiontaking_8 bit OUTPUT

as

--Th:For Testing
--SUPER EDIT MASTER
SET NOCOUNT ON

set @UpdateMultiple = 0
 
select 
	
	@firstname = c.firstname,
	@lastname = c.lastname,	
	@phone = c.phone,
	@mobilephone = c.mobilephone,
	@closed = ci.closed,
	
	@maxpermatch = ci.maxpermatch,
	@maxpermatchb = ci.maxpermatchb,
	@credit = ci.credit,
	@minbet = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.minbet else 0 end),
	@maxbet = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.maxbet else 0 end),
	@minbetb = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.minbet else 0 end),
	@maxbetb = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.maxbet else 0 end),
	@groupa = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end),
	@groupb = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end),
	@groupc = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end),
	@groupd = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end),
	@discountcs = max(case when cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end),

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

	@slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),
	@slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.slivepositiontaking else 0 end),

	@mlivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),
	@mlivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.mlivepositiontaking else 0 end),

	@bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.spositiontaking else 0 end),
	@bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.spositiontaking else 0 end),

	@bmpositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.mpositiontaking else 0 end),
	@bmpositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.mpositiontaking else 0 end),

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

	@auto_slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),
	@auto_slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.autolivepositiontaking else 0 end),

	@auto_bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	@auto_bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.autopositiontaking else 0 end),
	
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

	@isauto_slivepositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),
	@isauto_slivepositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then cs.isautolivepositiontaking else 0 end),

	@isauto_bspositiontaking_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then cs.isautopositiontaking else 0 end),
	@isauto_bspositiontaking_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then cs.isautopositiontaking else 0 end)
from 
	customer as c with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid = ci.custid
	INNER JOIN custsetting as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN exchange with (NOLOCK) ON c.currency = exchange.exchangeid
where 
	c.roleid=3 and c.custid=@CustID and
	c.srecommend=@SRecommend
group by 
	ci.closed, c.firstname, c.lastname, c.roleid, c.username,
	exchange.minbet, c.phone, c.mobilephone,
	ci.maxpermatch, ci.maxpermatchb, ci.credit
