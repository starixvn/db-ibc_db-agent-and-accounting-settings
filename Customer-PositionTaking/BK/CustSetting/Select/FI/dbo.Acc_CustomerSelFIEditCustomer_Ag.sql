ALTER PROCEDURE [dbo].[Acc_CustomerSelFIEditCustomer_Ag]
	@CustID int
AS
/*
	Created by: Phuong Dao  
	Date: 2009-04-16
	Task : Agent edit member
	DB: DB05.bodb02
	Original: Acc_CustomerSelEditCustomer

	Revisions:
		- 20090630@Phuc: auto master PT on member level.
		- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
		- 20100729@Shifu: Grant execute for bodbExAccNet
	Param's Explanation:
	• @CustID: member ID
*/


Declare 
	@MinBetv201_Max				money, 
	@MaxBetv201_Min				money, 
	@MaxPerMatchv201_Min		money, 
	@MaxPerMatchv201_Max		money,
	----------------------------------
	@v201ap_3					smallmoney,
	@v201ap_2					smallmoney,
	@cs_v201ap_3				smallmoney,
	@cs_v201ap_2				smallmoney,
	@v201sp_3					smallmoney,
	@v201sp_2					smallmoney,
	-----------------------------------
	@v201apositiontaking_3_max	smallmoney,
	@v201apositiontaking_2_max	smallmoney,
	@v201apositiontaking_3_min	smallmoney,
	@v201apositiontaking_2_min	smallmoney


	--------------------------------------------------------------------------------------------------------
	declare	 
			@mrecommend int, 
			@recommend	int,
			@ADisableFI bit
	select	@mrecommend = mrecommend, 
			@recommend	= recommend 
	from	custinfo with (NOLOCK) 
	where	custid = @custid
	
	select	@ADisableFI = DisableFinancial
	from	custinfo with (NOLOCK) 
	where	custid = @recommend
	
	-------------------------------------------------------------------------------------------------
							  
	----@apos_max = min(a2,l2)-----------------------------------------------------------------------
	Select	@v201apositiontaking_3_max = max(case when cs.bettype = 3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
			@v201apositiontaking_2_max = max(case when cs.bettype = 2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
			@v201apositiontaking_3_min = max(case when co.bettype = 3 then co.minpositiontaking else 0 end),
			@v201apositiontaking_2_min = max(case when co.bettype = 2 then co.minpositiontaking else 0 end)
	From 
			CustSetting3rd as cs with (NOLOCK)
			LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
	Where	cs.CustID in (Select Recommend from Customer with (NOLOCK) where CustID = @custid) AND co.sporttype = 201 

	Select 
			@MinBetv201_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
			@MaxBetv201_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
			CustSetting3rd as cs WITH (NOLOCK)
			INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
														and cs.bettype = 3 and cs.sporttype=201
	where	ci.custid = @CustID

	/*
	--Revert MPM
	Select 	
		@MaxPerMatch_Min = 0, @MaxPerMatchv2_Min = 0,
		@MaxPerMatch_Max = isnull(max(isnull(aci.MaxPerMatch, 0)), 0) - isnull(sum(ci.MaxPerMatch), 0),
		@MaxPerMatchv2_Max = isnull(max(isnull(aci.MaxPerMatchb, 0)), 0) - isnull(sum(ci.MaxPerMatchb), 0)
	from 
		custinfo as aci WITH (NOLOCK) 
		LEFT JOIN custinfo as ci WITH (NOLOCK) on (aci.CustID = ci.Recommend)  and ci.custid<>@custid and ci.roleid=1
	where aci.custid=@recommend
	*/

	Select 
			@MaxPerMatchv201_Min = 0,
			--@MaxPerMatchv201_Max = cs.MaxPerMatch201,--Min(case when cs.MaxPerMatch201 = 0 then NULL else cs.MaxPerMatch201 end), 
			@MaxPerMatchv201_Max = Min(case when cs.MaxPerMatch201 = 0 then NULL else cs.MaxPerMatch201 end) 
	from 
			custinfo as cs WITH (NOLOCK) 
			INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	where ci.custid = @CustID

	Select 
			@v201sp_3 = max(case when Scs.bettype = 3 then Scs.spositiontaking else 0 end),
			@v201sp_2 = max(case when Scs.bettype = 2 then Scs.spositiontaking else 0 end)
	From	CustSetting3rd as Scs with (NOLOCK)
	where	scs.CustID in (Select srecommend from Customer with (NOLOCK) where CustID = @CustID) AND scs.sporttype = 201 

	--=iff(i2,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
	Select	@cs_v201ap_3 = max(case when cs.bettype = 3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v201sp_3-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v201sp_3-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
			@cs_v201ap_2 = max(case when cs.bettype = 2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v201sp_2-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v201sp_2-cs.spositiontaking-cs.mpositiontaking end end end else 0 end)
	From	CustSetting3rd as cs with (NOLOCK) 
			inner join customer as c with (nolock) on cs.custid = c.custid
			inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
			inner join CustSetting3rd as acs with (nolock) on acs.custid = c.recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
	where	cs.custid = @custid AND acs.sporttype = 201 

	select	@v201apositiontaking_3_max = case when @v201apositiontaking_3_max <= @cs_v201ap_3 then @v201apositiontaking_3_max else @cs_v201ap_3 end,
			@v201apositiontaking_2_max = case when @v201apositiontaking_2_max <= @cs_v201ap_2 then @v201apositiontaking_2_max else @cs_v201ap_2 end
	
	select	C.username, 
			C.firstname, 
			C.lastname,
			isnull(ci.disablefinancial,0) as disablefinancial,
			isnull(@ADisableFI,0) as UplineDisableFI,
			isnull(C.phone,'') as phone, 
			isnull(C.mobilephone,'') as mobilephone,  
			isnull(C.fax,'') as fax, 
			isnull(ci.maxpermatch201, 0) as maxpermatchv201,
			C.roleid,
			isnull(ci.credit, 0) as credit,

			isnull(max(case when cs.bettype = 3 then cs.minbet else 0 end), 0) as MinBetv201,
			isnull(max(case when cs.bettype = 3 then cs.maxbet else 0 end), 0) as MaxBetv201,

			isnull(max(case when cs.bettype = 3 then cs.apositiontaking else 0 end), 0) as v201apositiontaking_3,
			isnull(max(case when cs.bettype = 2 then cs.apositiontaking else 0 end), 0) as v201apositiontaking_2,
	
			---v201discount_max = agent's discount  v201discount = member's discount 
			isnull(max(case when cs.bettype = 3 then cs.discount else 0 end), 0) as v201discount_max,
			isnull(max(case when cs.bettype = 3 then cs.playerdiscount else 0 end), 0) as v201discount,

			IsNull(@MinBetv201_Max, 0) as MinBetv201_Max,	
			IsNull(@MaxBetv201_Min, 0) as MaxBetv201_Min,	
			IsNull(@MaxPerMatchv201_Min, 0) as MaxPerMatchv201_Min,	
			IsNull(@MaxPerMatchv201_Max, 0) as MaxPerMatchv201_Max,

			isnull(@v201apositiontaking_3_min, 0) as minv201pos_3,
			isnull(@v201apositiontaking_2_min, 0) as minv201pos_2,
			isnull(@v201apositiontaking_3_max, 0) as maxv201pos_3,
			isnull(@v201apositiontaking_2_max, 0) as maxv201pos_2
	from 
			customer as C with (NOLOCK) 
			INNER JOIN CustInfo as ci with (NOLOCK) on c.custid = ci.custid
			INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	where	C.custid=@CustID AND cs.sporttype = 201 
	group by 
			C.username, 
			C.firstname, 
			C.lastname,
			ci.disablefinancial, 
			C.phone, 
			C.mobilephone,
			C.fax, 
			ci.maxpermatch201, 
			C.roleid,
			ci.credit

	    
	GO
	GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Ag] TO [bodbAdminNet]
	GO
	GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Ag] TO [bodbDownlineNet]
	GO
	GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Ag] TO [bodbDownlineNetView]
	GO
	GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditCustomer_Ag] TO [bodbExtAccNet]
	GO
	GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditCustomer_Ag] TO [vnteam]
