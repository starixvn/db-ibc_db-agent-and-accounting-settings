SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Acc_CustSetting_UserInfoSelect] 
	  @CustID		INT
AS
/*
	Created: 20150622@Dominic
	Task : Get User infor
	DB: DBAGE/bodb02
	Original:

	Param's Explanation:
	
	*/
BEGIN
	--Cusinfo
	SELECT c.username AS UserName
			, c.username2 AS UserName2
			, c.firstname AS FirstName
			, c.lastname AS LastName
			, c.phone AS Phone
			, c.mobilephone AS MobilePhone
			, c.email AS Email
			, c.fax AS Fax
	FROM dbo.Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UserInfoSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UserInfoSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UserInfoSelect] TO [bodbExtAccNet]