ALTER PROCEDURE  [dbo].[Acc_CustomerSelFIEditMember_SAg]
	@CustID int,  
	@AgentID int  
AS  

/*
	Created by: Phuong Dao
	Date: 2009-04-16
	Task: SUPER EDIT MEMBER FOR FINANCE AT AGENT SITE  
	Original: Acc_CustomerSelEditCustomer_SAg

	Revisions:
		- 20090626@ThoNguyen: Get value Super IsAuto on Master
		- 20090804@Phuc: get max_s1 = min(s4,l4)-m3
		- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
*/
SET NOCOUNT ON  
  
	Declare  
	 --min(s4,l4) 
	 @v201mspositiontaking_2_max smallmoney,  
	 @v201mspositiontaking_3_max smallmoney,
	 --n4  
	 @v201mspositiontaking_2_min smallmoney,  
	 @v201mspositiontaking_3_min smallmoney,  
	 --m3
	 @v201mpositiontaking_2 smallmoney,  
	 @v201mpositiontaking_3 smallmoney,  
	 --i3
	 @isauto_v201spositiontaking_2 bit ,
	 @isauto_v201spositiontaking_3 bit ,		
	 
	 @Ssuspended BIT
--i3,m3 
Select 	
	@isauto_v201spositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=201 then mcs.isautopositiontaking else 0 end),
	@isauto_v201spositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=201 then mcs.isautopositiontaking else 0 end),	

	@v201mpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=201 then mcs.mpositiontaking else 0 end),
	@v201mpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=201 then mcs.mpositiontaking else 0 end)	
From CustSetting3rd mcs with (NOLOCK) 
where mcs.custid in (Select mrecommend from custinfo with (NOLOCK) where custid = @AgentID)
 
Select    
 	 @v201mspositiontaking_2_max = max(case when cs.bettype = 2 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v201mspositiontaking_3_max = max(case when cs.bettype = 3 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 --min  
	 @v201mspositiontaking_2_min = max(case when co.bettype = 2 then co.minpositiontaking else 0 end),  
	 @v201mspositiontaking_3_min = max(case when co.bettype = 3 then co.minpositiontaking else 0 end)  

From   
	 CustSetting3rd as cs with (NOLOCK)  
	 LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype  
Where cs.CustID in (Select sRecommend from Customer with (NOLOCK) where CustID = @AgentID) AND cs.sporttype = 201 
  

SELECT  
	 isnull(c.fax,'') as fax, c.firstname, c.lastname,   
	 ci.maxpermatch201 as maxpermatchv201,   
	 isnull(c.mobilephone,'') as mobilephone, 
	 isnull(c.phone,'') as phone, 
	 c.username,  
	 c.username2, 
	 ci.credit,  
	 

	 max(case when cs.bettype = 3 then cs.minbet else 0 end) as minbetv201,  
	 max(case when cs.bettype = 3 then cs.maxbet else 0 end) as maxbetv201,  
	 --comm for 201
	isnull(max(case when cs.bettype = 3 then cs.discount else 0 end), 0) as v201discount_Ag,
	isnull(max(case when cs.bettype = 3 then cs.adiscount else 0 end), 0) as v201discount_MAg,
	isnull(max(case when cs.bettype = 3 then cs.playerdiscount else 0 end), 0) as v201discount,
	 
	 max(case when cs.bettype = 2 then cs.apositiontaking else 0 end) as v201apositiontaking_2,  
	 max(case when cs.bettype = 3 then cs.apositiontaking else 0 end) as v201apositiontaking_3,  

	 max(case when cs.bettype = 2 then cs.mpositiontaking else 0 end) as v201mpositiontaking_2,  
	 max(case when cs.bettype = 3 then cs.mpositiontaking else 0 end) as v201mpositiontaking_3,  

	 max(case when cs.bettype = 2 then cs.spositiontaking else 0 end) as v201spositiontaking_2,  
	 max(case when cs.bettype = 3 then cs.spositiontaking else 0 end) as v201spositiontaking_3,  
     
     --s1_max=min(s4,l4)-m3
	 ISNULL(@v201mspositiontaking_3_max, 0) - ISNULL(@v201mpositiontaking_3,0) AS maxv201pos_3,  
	 ISNULL(@v201mspositiontaking_2_max, 0) - ISNULL(@v201mpositiontaking_2,0) AS maxv201pos_2,  
		
	 max(case when cs.bettype = 2 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_2,  
	 max(case when cs.bettype = 3 then cs.autopositiontaking else 0 end) as auto_v201spositiontaking_3,  
	 
	 max(case when cs.bettype = 2 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_mem_2,  
	 max(case when cs.bettype = 3 then cs.isautopositiontaking else 0 end) as isauto_v201spositiontaking_mem_3,  
	 
	 @isauto_v201spositiontaking_2 as isauto_v201spositiontaking_2,
	 @isauto_v201spositiontaking_3 as isauto_v201spositiontaking_3,
	 
	 isnull(@v201mspositiontaking_2_max, 0) as maxautov201pos_2,  
	 isnull(@v201mspositiontaking_3_max, 0) as maxautov201pos_3,  
	  
	 case when isnull(@v201mspositiontaking_2_min, 0)-max(case when cs.bettype = 2 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v201mspositiontaking_2_min, 0)-max(case when cs.bettype = 2 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as minv201pos_2,  
	 case when isnull(@v201mspositiontaking_3_min, 0)-max(case when cs.bettype = 3 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v201mspositiontaking_3_min, 0)-max(case when cs.bettype = 3 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as minv201pos_3
	  
FROM   
	 customer as C with (nolock)   
	 INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid  
	 INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid  = cs.custid   
WHERE c.custid=@custId AND c.recommend=@agentId AND cs.sporttype = 201 
group by   
		c.fax, 
		c.firstname, 
		c.lastname, 
		ci.maxpermatch, 
		c.mobilephone, 
		c.phone, 
		c.username,  
		c.username2,  
		ci.maxpermatch201,  
		ci.credit  
		
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_SAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_SAg] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelFIEditMember_SAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelFIEditMember_SAg] TO [vnteam]
