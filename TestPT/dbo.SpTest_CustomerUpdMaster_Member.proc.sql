ALTER PROCEDURE [dbo].[SpTest_CustomerUpdMaster_Member]
	@custid int,
	@m1 smallmoney	
	
AS
SET NOCOUNT ON
-----------------------------------------------------------------------
declare
	@s4 smallmoney ,
	@m4 smallmoney ,
	@a4 smallmoney ,
	@n4 smallmoney ,	
	@l4 smallmoney ,	
	@s3 smallmoney ,
	@m3 smallmoney ,	
	@u3 smallmoney ,	
	@i3 bit ,
	@n3 smallmoney ,	
	@l3 smallmoney ,	
	@m2 smallmoney ,	
	@a2 smallmoney ,
	@u2 smallmoney ,
	@i2 bit ,	
	@n2 smallmoney ,
	@l2 smallmoney ,
	@s1 smallmoney ,	
	@m1_ smallmoney ,	
	@a1 smallmoney ,	
	@u1 smallmoney,
	@i1 bit

declare @srecommend int,
		@mrecommend int,
		@recommend int

select @srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend
from customer with (nolock)
where custid = @custid

declare @ErrCode int, @ErrMsg nvarchar(4000),
		@roleid int,
		@UpdatePositiontaking bit,
		@UpdatePositiontakingb bit
		
select @roleid = 1, @UpdatePositiontaking = 1, @UpdatePositiontakingb = 1


PRINT	'Before:' + cast(@custid as varchar(10))+ '   ('+cast(@srecommend as char(7))+' - '+cast(@mrecommend as char(7))+' - '+cast(@recommend as char(7))+')'
EXEC dbo.SpTest_GetResult 
	@custid = @custid,
	@s4 = @s4 OUTPUT,
	@m4 = @m4 OUTPUT,
	@a4 = @a4 OUTPUT,
	@n4 = @n4 OUTPUT,
	@l4 = @l4 OUTPUT,
	@s3 = @s3 OUTPUT,
	@m3 = @m3 OUTPUT,
	@u3 = @u3 OUTPUT,
	@i3 = @i3 OUTPUT,
	@n3 = @n3 OUTPUT,
	@l3 = @l3 OUTPUT,
	@m2 = @m2 OUTPUT,
	@a2 = @a2 OUTPUT,
	@u2 = @u2 OUTPUT,
	@i2 = @i2 OUTPUT,
	@n2 = @n2 OUTPUT,
	@l2 = @l2 OUTPUT,
	@s1 = @s1 OUTPUT,
	@m1 = @m1_ OUTPUT,
	@a1 = @a1 OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
	
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @n2, @l2, @s1, @m1_, @a1, @u1, @i1
EXEC dbo.Acc_CustomerUpdMember_Master 
	@CustID = @CustID,
	@Closed = 0,
	@suspended = 0,
	@mpositiontaking_1 = @m1 OUTPUT,
	@mpositiontaking_2 = @m1 OUTPUT,
	@mpositiontaking_3 = @m1 OUTPUT,
	@mpositiontaking_4 = @m1 OUTPUT,
	@mpositiontaking_5 = @m1 OUTPUT,
	@mpositiontaking_6 = @m1 OUTPUT,
	@mpositiontaking_7 = @m1 OUTPUT,
	@mpositiontaking_8 = @m1 OUTPUT,
	@mpositiontaking_9 = @m1 OUTPUT,
	@mpositiontaking_10 = @m1 OUTPUT,
	@mlivepositiontaking_1 = @m1 OUTPUT,
	@mlivepositiontaking_3 = @m1 OUTPUT,
	@mlivepositiontaking_7 = @m1 OUTPUT,
	@mlivepositiontaking_8 = @m1 OUTPUT,
	@v2mpositiontaking_1 = @m1 OUTPUT,
	@v2mpositiontaking_2 = @m1 OUTPUT,
	@v2mpositiontaking_3 = @m1 OUTPUT,
	@v2mpositiontaking_7 = @m1 OUTPUT,
	@v2mpositiontaking_8 = @m1 OUTPUT,
	@v2mpositiontaking_9 = @m1 OUTPUT,
	@v2mpositiontaking_20 = @m1 OUTPUT,
	@v3mpositiontaking_1 = @m1 OUTPUT,
	@v3mpositiontaking_2 = @m1 OUTPUT,
	@v3mpositiontaking_3 = @m1 OUTPUT,
	@v3mpositiontaking_20 = @m1 OUTPUT,
	@v5mpositiontaking_1 = @m1 OUTPUT,
	@v5mpositiontaking_2 = @m1 OUTPUT,
	@v5mpositiontaking_3 = @m1 OUTPUT,
	@v5mpositiontaking_20 = @m1 OUTPUT,
	@v8mpositiontaking_1 = @m1 OUTPUT,
	@v8mpositiontaking_3 = @m1 OUTPUT,
	@v8mpositiontaking_20 = @m1 OUTPUT,
	@v10mpositiontaking_1 = @m1 OUTPUT,
	@v10mpositiontaking_2 = @m1 OUTPUT,
	@v10mpositiontaking_3 = @m1 OUTPUT,
	@v10mpositiontaking_20 = @m1 OUTPUT,
	@v11mpositiontaking_1 = @m1 OUTPUT,
	@v11mpositiontaking_20 = @m1 OUTPUT,
	@v12mpositiontaking_2 = @m1 OUTPUT,
	@v12mpositiontaking_21 = @m1 OUTPUT,
	@v12mpositiontaking_22 = @m1 OUTPUT,
	@v99mpositiontaking_1 = @m1 OUTPUT,
	@v99mpositiontaking_2 = @m1 OUTPUT,
	@v99mpositiontaking_3 = @m1 OUTPUT,
	@v99mpositiontaking_20 = @m1 OUTPUT,
	@UserID = 8,
	@UpdateMultiple = default,
	@allowupdatepositiontaking = 1 ,
	@Language = 'E',
	@SubAccID = 0,
	@IP = N'-',
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
		
PRINT	'After:' + cast(@custid as varchar(10))+ '   ('+cast(@srecommend as char(7))+' - '+cast(@mrecommend as char(7))+' - '+cast(@recommend as char(7))+')'

EXEC dbo.SpTest_GetResult 
	@custid = @custid,
	@s4 = @s4 OUTPUT,
	@m4 = @m4 OUTPUT,
	@a4 = @a4 OUTPUT,
	@n4 = @n4 OUTPUT,
	@l4 = @l4 OUTPUT,
	@s3 = @s3 OUTPUT,
	@m3 = @m3 OUTPUT,
	@u3 = @u3 OUTPUT,
	@i3 = @i3 OUTPUT,
	@n3 = @n3 OUTPUT,
	@l3 = @l3 OUTPUT,
	@m2 = @m2 OUTPUT,
	@a2 = @a2 OUTPUT,
	@u2 = @u2 OUTPUT,
	@i2 = @i2 OUTPUT,
	@n2 = @n2 OUTPUT,
	@l2 = @l2 OUTPUT,
	@s1 = @s1 OUTPUT,
	@m1 = @m1_ OUTPUT,
	@a1 = @a1 OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @n2, @l2, @s1, @m1, @a1, @u1, @i1

/* Running Test

--Master edit Member
DECLARE @custid int, @m1 decimal(10,4)
select @custid = 260841,			
	@m1 = 0.1

EXEC SpTest_CustomerUpdMaster_Member @custid, @m1
*/