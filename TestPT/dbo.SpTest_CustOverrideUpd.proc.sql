ALTER PROCEDURE [dbo].[SpTest_CustOverrideUpd]
	@custid int,
	@n smallmoney,
	@l smallmoney
	
	
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
	@i2 bit,	
	@n2 smallmoney ,	
	@l2 smallmoney ,
	@s1 smallmoney ,	
	@m1 smallmoney ,	
	@a1 smallmoney ,	
	@u1 smallmoney,
	@i1 bit

declare @srecommend int,
		@mrecommend int,
		@recommend int,
		@ErrCode int,
		@roleid int,
		@ErrMsg nvarchar(200)

select @srecommend = srecommend,@ErrCode = 0,@Errmsg = '',
		@mrecommend = mrecommend,
		@recommend = recommend,
		@roleid = roleid
from customer with (nolock)
where custid = @custid

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
	@m1 = @m1 OUTPUT,
	@a1 = @a1 OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
	
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @u2, @i2, @n2, @l2, @s1, @m1, @a1, @u1, @i1

	EXEC dbo.Acc_CustOverrideUpd 
		@custid = @custid,
		@minpositiontaking_1 = @n,
		@minpositiontaking_2 = @n,
		@minpositiontaking_3 = @n,
		@minpositiontaking_4 = @n,
		@minpositiontaking_5 = @n,
		@minpositiontaking_6 = @n,
		@minpositiontaking_7 = @n,
		@minpositiontaking_8 = @n,
		@minpositiontaking_9 = @n,
		@minpositiontaking_10 = @n,
		@minlivepositiontaking_1 = @n,
		@minlivepositiontaking_3 = @n,
		@minlivepositiontaking_7 = @n,
		@minlivepositiontaking_8 = @n,
		@minv2positiontaking_1 = @n,
		@minv2positiontaking_2 = @n,
		@minv2positiontaking_3 = @n,
		@minv2positiontaking_7 = @n,
		@minv2positiontaking_8 = @n,
		@minv2positiontaking_9 = @n,
		@minv2positiontaking_20 = @n,
		@minv3positiontaking_1 = @n,
		@minv3positiontaking_2 = @n,
		@minv3positiontaking_3 = @n,
		@minv3positiontaking_20 = @n,
		@minv5positiontaking_1 = @n,
		@minv5positiontaking_2 = @n,
		@minv5positiontaking_3 = @n,
		@minv5positiontaking_20 = @n,
		@minv8positiontaking_1 = @n,
		@minv8positiontaking_3 = @n,
		@minv8positiontaking_20 = @n,
		@minv10positiontaking_1 = @n,
		@minv10positiontaking_2 = @n,
		@minv10positiontaking_3 = @n,
		@minv10positiontaking_20 = @n,
		@minv11positiontaking_1 = @n,
		@minv11positiontaking_20 = @n,
		@minv201positiontaking_3 = @n,
		@minv99positiontaking_1 = @n,
		@minv99positiontaking_2 = @n,
		@minv99positiontaking_3 = @n,
		@minv99positiontaking_20 = @n,
		@maxpositiontaking_1 = @l,
		@maxpositiontaking_2 = @l,
		@maxpositiontaking_3 = @l,
		@maxpositiontaking_4 = @l,
		@maxpositiontaking_5 = @l,
		@maxpositiontaking_6 = @l,
		@maxpositiontaking_7 = @l,
		@maxpositiontaking_8 = @l,
		@maxpositiontaking_9 = @l,
		@maxpositiontaking_10 = @l,
		@maxlivepositiontaking_1 = @l,
		@maxlivepositiontaking_3 = @l,
		@maxlivepositiontaking_7 = @l,
		@maxlivepositiontaking_8 = @l,
		@maxv2positiontaking_1 = @l,
		@maxv2positiontaking_2 = @l,
		@maxv2positiontaking_3 = @l,
		@maxv2positiontaking_7 = @l,
		@maxv2positiontaking_8 = @l,
		@maxv2positiontaking_9 = @l,
		@maxv2positiontaking_20 = @l,
		@maxv3positiontaking_1 = @l,
		@maxv3positiontaking_2 = @l,
		@maxv3positiontaking_3 = @l,
		@maxv3positiontaking_20 = @l,
		@maxv5positiontaking_1 = @l,
		@maxv5positiontaking_2 = @l,
		@maxv5positiontaking_3 = @l,
		@maxv5positiontaking_20 = @l,
		@maxv8positiontaking_1 = @l,
		@maxv8positiontaking_3 = @l,
		@maxv8positiontaking_20 = @l,
		@maxv10positiontaking_1 = @l,
		@maxv10positiontaking_2 = @l,
		@maxv10positiontaking_3 = @l,
		@maxv10positiontaking_20 = @l,
		@maxv11positiontaking_1 = @l,
		@maxv11positiontaking_20 = @l,
		@maxv201positiontaking_3 = @l,
		@maxv99positiontaking_1 = @l,
		@maxv99positiontaking_2 = @l,
		@maxv99positiontaking_3 = @l,
		@maxv99positiontaking_20 = @l,
		@CheckPermission = 1,
		@UpdateMinPos = 1,
		@UpdateMaxPos = 1,
		@language = 'E',
		@UserID = 8,
		@SubAccID = 0,
		@WriteLog = 1,
		@IP = '',
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

if @errcode <> 0 
	print @Errmsg
		
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
	@m1 = @m1 OUTPUT,
	@a1 = @a1 OUTPUT,
	@u1 = @u1 OUTPUT,
	@i1 = @i1 OUTPUT
	
EXEC [SpTest_PrintResult] @roleid, @s4, @m4, @a4, @n4, @l4, @s3, @m3, @u3, @i3, @n3, @l3, @m2, @a2, @u2, @i2, @n2, @l2, @s1, @m1, @a1, @u1, @i1

/* Running Test

--Update CustOverride
DECLARE @custid int, @n decimal(10,4), @l decimal(10,4)
select @custid = 1000142,
	@n = 0.45,
	@l = 0.9		

EXEC SpTest_CustOverrideUpd @custid, @n, @l
*/
