ALTER PROCEDURE DBA_DelCustomer
	@InputUser varchar(30) = ''
AS

Set nocount on

Declare @RoleID int, @custid int
Set @custid = null
if isnumeric(@InputUser) = 0
BEGIN
	select @custid = custid, @roleid = roleid from customer with (nolock) where username = @InputUser
	if @@rowcount = 0
		select @custid = custid, @roleid = roleid from customer with (nolock) where username2 = @InputUser		
END
else
BEGIN
	select @custid = custid, @roleid = roleid from customer with (nolock) where custid = @InputUser
END
if @custid is null
begin	
	print 'Invalid User'
	return
end


if @roleid = 1
begin
	begin transaction 
		delete from custsetting where custid = @custid
		delete from custoverride where custid = @custid
		delete from custinfo where custid = @custid 
		delete from customer where custid = @custid   
	commit transaction
end
else if @roleid = 2
begin
	begin transaction 
		delete cs
		from custsetting cs inner join custinfo ci with(nolock) on cs.custid = ci.recommend 
		where ci.custid = @custid
		delete co
		from custoverride co inner join custinfo ci with(nolock) on co.custid = ci.recommend 
		where ci.custid = @custid
		delete custinfo where recommend = @custid 
		delete customer where recommend = @custid  
		
		if @@error <> 0
			rollback transaction 
			
		delete from custsetting where custid = @custid
		delete from custoverride where custid = @custid
		delete from custinfo where custid = @custid 
		delete from customer where custid = @custid   
		
		if @@error <> 0
			rollback transaction 
	
	commit transaction
end
else if @roleid = 3
begin
	begin transaction 
		delete cs
		from custsetting cs inner join custinfo ci with(nolock) on cs.custid = ci.mrecommend 
		where ci.custid = @custid

		delete co
		from custoverride co inner join custinfo ci with(nolock) on co.custid = ci.mrecommend 
		where ci.custid = @custid

		delete custinfo where mrecommend = @custid 
		delete customer where mrecommend = @custid  
		if @@error <> 0
			rollback transaction 
		
		delete from custsetting where custid = @custid
		delete from custoverride where custid = @custid
		delete from custinfo where custid = @custid 
		delete from customer where custid = @custid   
		
		if @@error <> 0
			rollback transaction 
			
	commit transaction
end
else if @roleid = 4
begin
	begin transaction 
		delete cs
		from custsetting cs inner join custinfo ci with(nolock) on cs.custid = ci.srecommend 
		where ci.custid = @custid

		delete co
		from custoverride co inner join custinfo ci with(nolock) on co.custid = ci.srecommend 
		where ci.custid = @custid

		delete custinfo where srecommend = @custid 
		delete customer where srecommend = @custid  
		if @@error <> 0
			rollback transaction 
			
		delete from custsetting where custid = @custid
		delete from custoverride where custid = @custid
		delete from custinfo where custid = @custid 
		delete from customer where custid = @custid   
		
		if @@error <> 0
			rollback transaction 
	
	commit transaction
end
