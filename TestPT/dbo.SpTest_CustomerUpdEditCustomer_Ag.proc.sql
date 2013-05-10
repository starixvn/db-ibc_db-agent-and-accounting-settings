ALTER PROCEDURE [dbo].[SpTest_CustomerUpdEditCustomer_Ag]
	@custid int,
	@n2 smallmoney,
	@l2 smallmoney,	
	@a1 smallmoney
	
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
	@i2	bit ,
	@n2_ smallmoney ,	
	@l2_ smallmoney ,
	@s1 smallmoney ,	
	@m1 smallmoney ,	
	@a1_ smallmoney ,	
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

declare @ErrCode int,@ErrMsg nvarchar(4000),
		@roleid int,
		@UpdatePositiontaking bit,
		@UpdatePositiontakingb bit
		
select @roleid = 1, @UpdatePositiontaking = 1, @UpdatePositiontakingb = 1

if @n2 < 1 and @l2 < 1
update custoverride set 
	minpositiontaking = @n2,
	maxpositiontaking = @l2,
	minlivepositiontaking = @n2,
	maxlivepositiontaking = @l2
where custid = @recommend

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
	@n2 = @n2_ OUTPUT,
	@l2 = @l2_ OUTPUT,
	@s1 = @s1 OUTPUT,
	@m1 = @m1 OUTPUT,
	@a1 = @a1_ OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @n2_, @u2, @i2, @l2_, @s1, @m1, @a1_, @u1, @i1

EXEC dbo.Acc_CustomerUpdMember_PositionTaking 
	@custid = @custid,
	@apositiontaking_1 = @a1,
	@apositiontaking_2 = @a1,
	@apositiontaking_3 = @a1,
	@apositiontaking_4 = @a1,
	@apositiontaking_5 = @a1,
	@apositiontaking_6 = @a1,
	@apositiontaking_7 = @a1,
	@apositiontaking_8 = @a1,
	@apositiontaking_9 = @a1,
	@apositiontaking_10 = @a1,
	@alivepositiontaking_1 = @a1,
	@alivepositiontaking_3 = @a1,
	@alivepositiontaking_7 = @a1,
	@alivepositiontaking_8 = @a1,
	@v2apositiontaking_1 = @a1,
	@v2apositiontaking_2 = @a1,
	@v2apositiontaking_3 = @a1,
	@v2apositiontaking_7 = @a1,
	@v2apositiontaking_8 = @a1,
	@v2apositiontaking_9 = @a1,
	@v2apositiontaking_20 = @a1,
	@v3apositiontaking_1 = @a1,
	@v3apositiontaking_2 = @a1,
	@v3apositiontaking_3 = @a1,
	@v3apositiontaking_20 = @a1,
	@v5apositiontaking_1 = @a1,
	@v5apositiontaking_2 = @a1,
	@v5apositiontaking_3 = @a1,
	@v5apositiontaking_20 = @a1,
	@v8apositiontaking_1 = @a1,
	@v8apositiontaking_3 = @a1,
	@v8apositiontaking_20 = @a1,
	@v10apositiontaking_1 = @a1,
	@v10apositiontaking_2 = @a1,
	@v10apositiontaking_3 = @a1,
	@v10apositiontaking_20 = @a1,
	@v11apositiontaking_1 = @a1,
	@v11apositiontaking_20 = @a1,
	@v12apositiontaking_2 = @a1,
	@v12apositiontaking_21 = @a1,
	@v12apositiontaking_22 = @a1,
	@v99apositiontaking_1 = @a1,
	@v99apositiontaking_2 = @a1,
	@v99apositiontaking_3 = @a1,
	@v99apositiontaking_20 = @a1,
	@UserID = 8,
	@IP = N'-',
	@Language = 'E',
	@SubAccID = 0,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT


		
PRINT	'After:' + cast(@custid as varchar(10))+ '   ('+cast(@srecommend as char(7))+' - '+cast(@mrecommend as char(7))+' - '+cast(@recommend as char(7))+')'
IF @ErrCode <> 0
	Print @ErrMsg
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
	@n2 = @n2_ OUTPUT,
	@l2 = @l2_ OUTPUT,
	@s1 = @s1 OUTPUT,
	@m1 = @m1 OUTPUT,
	@a1 = @a1_ OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
	
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @u2, @i2, @n2_, @l2_, @s1, @m1, @a1_, @u1, @i1

If @ErrCode <> 0
begin
	print @ErrCode
	print @ErrMsg
end
/* Running Test

--Agent edit Member
DECLARE @custid int, @n2 decimal(10,4), @l2 decimal(10,4), @a1 decimal(10,4)
select @custid = 260841,
	@n2 = 0.0,
	@l2 = 1,		
	@a1 = 0.1

EXEC SpTest_CustomerUpdEditCustomer_Ag @custid, @n2, @l2, @a1

*/
