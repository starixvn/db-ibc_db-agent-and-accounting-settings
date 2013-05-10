ALTER PROCEDURE dbo.SpTest_GetResult
	@custid int,
	@s4 smallmoney = 0 OUTPUT,
	@m4 smallmoney = 0 OUTPUT,
	@a4 smallmoney = 0 OUTPUT,
	@n4 smallmoney = 0 OUTPUT,	
	@l4 smallmoney = 0 OUTPUT,	
	@s3 smallmoney = 0 OUTPUT,
	@m3 smallmoney = 0 OUTPUT,
	@u3 smallmoney = 0 OUTPUT,
	@i3 bit = 0 OUTPUT,
	@n3 smallmoney = 0 OUTPUT,
	@l3 smallmoney = 0 OUTPUT,
	@m2 smallmoney = 0 OUTPUT,
	@a2 smallmoney = 0 OUTPUT,
	@u2 smallmoney = 0 OUTPUT,
	@i2 bit = 0 OUTPUT,
	@n2 smallmoney = 0 OUTPUT,
	@l2 smallmoney = 0 OUTPUT,
	@s1 smallmoney = 0 OUTPUT,
	@m1 smallmoney = 0 OUTPUT,
	@a1 smallmoney = 0 OUTPUT,
	@u1 smallmoney = 0 OUTPUT,
	@i1 bit OUTPUT
AS
declare @srecommend int,
		@mrecommend int,
		@recommend int

select @srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend
from customer with (nolock)
where custid = @custid


select @l4 = maxpositiontaking, @n4 = minpositiontaking from custoverride with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @l3 = maxpositiontaking, @n3 = minpositiontaking from custoverride with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @l2 = maxpositiontaking, @n2 = minpositiontaking from custoverride with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1

select @s4 = spositiontaking, @m4 = mpositiontaking, @a4 = apositiontaking from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @s3 = spositiontaking, @m3 = mpositiontaking, @u3 = autopositiontaking, @i3 = isautopositiontaking from custsetting with (NOLOCK)  where custid = @mrecommend and bettype=1 and sporttype=1
select @m2= mpositiontaking, @a2 = apositiontaking, @u2 = autopositiontaking, @i2 = isautopositiontaking from custsetting with (NOLOCK)  where custid = @recommend and bettype=1 and sporttype=1
select @s1 = spositiontaking, @m1 = mpositiontaking, @a1 = apositiontaking, @u1 = autopositiontaking, @i1 = isautopositiontaking from custsetting with (NOLOCK)  where custid = @custid and bettype=1 and sporttype=1 