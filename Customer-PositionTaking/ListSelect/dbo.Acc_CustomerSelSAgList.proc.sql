ALTER PROCEDURE [dbo].[Acc_CustomerSelSAgList]   
	@System varchar(50) = 'ACCOUNTING'
AS  

/*
	Created by: [Creator]
	Date: 
	Task: Bet Super List when creating master (can choose which super for master)
	DB: DBAGE/bodb02
	Original:  
	Revisions:
		-20090109@Henry: No need to get currency Name from Exchange since it is not used
		-20100720@Shifu: Get super list by System
		-20101119@Johnson: Get super list by group from Acc_CustGroup if system is not accounting
		-20120525@Dom: exclude licensee customer for accounting site
		-20130121@Dan: call to bodb_AGE for Acc_CustGroup
		- 20150904@Helen: commission setting for MO [Redmine #41470]

		
*/

SET NOCOUNT ON  
IF(@System = 'ACCOUNTING')
BEGIN

	Select c.custid, c.username, c.currency as exchangeid, c.[site] AS siteName
	from customer as c with (NOLOCK) 
	where c.roleid=4 and c.custid>100  
	and c.srecommend NOT IN(SELECT custid from f_DepSuper_1 ('all'))
	order by c.username   
END
ELSE
BEGIN
	SELECT c.custid, c.username, c.currency as exchangeid,c.[site] AS siteName
	FROM customer AS c WITH (NOLOCK) 
	WHERE c.roleid = 4 
		AND c.custid>100  
		AND c.custid IN (SELECT custid FROM bodb_AGE.dbo.Acc_CustGroup WITH(NOLOCK) WHERE GroupName = @system)
		--AND c.currency IN (SELECT exchangeID FROM dbo.f_CurrencyBySystem(@System))
		--AND c.custid NOT IN (SELECT custid FROM dbo.f_GetDummySuper())
	ORDER BY c.username 
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgList] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAgList] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSAgList] TO [vnteam] 


