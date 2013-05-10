ALTER PROCEDURE [dbo].[Acc_CustomerInsUserInfo_Rollback]
	@CustID int
AS

--Created:  
--Task : Rollback data for invalid insert
--DB: DBTRANS.bodb02
--Original:
--
--Revisions:

Declare @RoleID tinyint
SELECT @RoleID = RoleID FROM CustInfo (nolock) WHERE CustID = @CustID

DELETE FROM custinfo WITH (ROWLOCK)  WHERE custid = @CustID
DELETE FROM customer WITH (ROWLOCK)  WHERE CustID = @CustID

IF @RoleID BETWEEN 2 AND 4
	DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 

IF @RoleID = 4
	DELETE FROM CustSuper WITH (ROWLOCK)  WHERE CustID = @CustID
ELSE IF @RoleID = 3
	DELETE FROM CustMaster WITH (ROWLOCK)  WHERE CustID = @CustID
ELSE IF @RoleID = 2
	DELETE FROM CustAgent WITH (ROWLOCK)  WHERE CustID = @CustID
		

GO
GRANT EXECUTE ON [Acc_CustomerInsUserInfo_Rollback] TO [bodbAdminNet]

