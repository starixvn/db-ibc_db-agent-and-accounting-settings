CREATE PROCEDURE Acc_CustomerUpdMember_AutoPositiontaking_10
	@custid int,

	@auto_v10spositiontaking_1 smallmoney = 0,
	@auto_v10spositiontaking_2 smallmoney = 0,
	@auto_v10spositiontaking_3 smallmoney = 0,
	@auto_v10spositiontaking_20 smallmoney = 0,

	@isauto_v10spositiontaking_1 bit = 0,
	@isauto_v10spositiontaking_2 bit = 0,
	@isauto_v10spositiontaking_3 bit = 0,
	@isauto_v10spositiontaking_20 bit = 0,

	@language varchar(2) = 'E',
	@userid int
AS
/*
Created: 20120521@Elodie
Task : Update auto PT for Golf at member level
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdMember_AutoPositiontaking

Revisions:
    
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
Declare @ErrMsg nvarchar(2000)
Declare @bettype int,
	@autov10positiontaking smallmoney,
	@isautov10positiontaking bit, 
	@old_autov10positiontaking smallmoney,
	@old_isautov10positiontaking bit,
	
	@maxpos smallmoney,	
	
	@srecommend int,
	@mrecommend int
declare 
	@old_auto_v10spositiontaking_1 smallmoney,
	@old_auto_v10spositiontaking_2 smallmoney,
	@old_auto_v10spositiontaking_3 smallmoney,
	@old_auto_v10spositiontaking_20 smallmoney,
	
	@old_isauto_v10spositiontaking_1 bit,
	@old_isauto_v10spositiontaking_2 bit,
	@old_isauto_v10spositiontaking_3 bit,
	@old_isauto_v10spositiontaking_20 bit,

	@master_auto_v10spositiontaking_1 smallmoney,
	@master_auto_v10spositiontaking_2 smallmoney,
	@master_auto_v10spositiontaking_3 smallmoney,
	@master_auto_v10spositiontaking_20 smallmoney,

	@master_isauto_v10spositiontaking_1 bit,
	@master_isauto_v10spositiontaking_2 bit,
	@master_isauto_v10spositiontaking_3 bit,
	@master_isauto_v10spositiontaking_20 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Get old Auto PT of Member
select 	@old_auto_v10spositiontaking_1	=	autopositiontaking		,	@old_isauto_v10spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=1
select 	@old_auto_v10spositiontaking_2	=	autopositiontaking		,	@old_isauto_v10spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=2
select 	@old_auto_v10spositiontaking_3	=	autopositiontaking		,	@old_isauto_v10spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=3
select 	@old_auto_v10spositiontaking_20	=	autopositiontaking		,	@old_isauto_v10spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=20

--------------------------------------------------------
--Get Auto PT of member from Master
select @master_auto_v10spositiontaking_1 = autopositiontaking, @master_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
select @master_auto_v10spositiontaking_2 = autopositiontaking, @master_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
select @master_auto_v10spositiontaking_3 = autopositiontaking, @master_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
select @master_auto_v10spositiontaking_20 = autopositiontaking, @master_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10

--------------------------------------------------------
--Update Member account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
	(
				select 1 as bettype, 10 as sporttype, @auto_v10spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking 
	union all 	select 2 as bettype, 10 as sporttype, @auto_v10spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking 
	union all 	select 3 as bettype, 10 as sporttype, @auto_v10spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking 
	union all 	select 20 as bettype, 10 as sporttype, @auto_v10spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking 
	) as b on b.bettype = custsetting.bettype and b.sporttype = custsetting.sporttype
	where custsetting.custid = @custid
	if @@Error <> 0
	BEGIN
		SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking'
			when 'CS' then N'更新占成数不成功'
			when 'CT' then N'更新佔成數不成功'
			when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์'
			when 'J' then N'Error updating auto position taking'
			when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다.'
			else N'Error updating auto position taking'
		end	
		RaisError (@ErrMsg, 16, 1)
		return
	END
	
---------------------------------------------------------------------------------------------------------------------------------------------
--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
select 
	@auto_v10spositiontaking_1 = case when @isauto_v10spositiontaking_1>0 then @auto_v10spositiontaking_1 else @master_auto_v10spositiontaking_1 end,
	@auto_v10spositiontaking_2 = case when @isauto_v10spositiontaking_2>0 then @auto_v10spositiontaking_2 else @master_auto_v10spositiontaking_2 end,
	@auto_v10spositiontaking_3 = case when @isauto_v10spositiontaking_3>0 then @auto_v10spositiontaking_3 else @master_auto_v10spositiontaking_3 end,
	@auto_v10spositiontaking_20 = case when @isauto_v10spositiontaking_20>0 then @auto_v10spositiontaking_20 else @master_auto_v10spositiontaking_20 end,

	@isauto_v10spositiontaking_1 = case when @isauto_v10spositiontaking_1>0 then @isauto_v10spositiontaking_1 else @master_isauto_v10spositiontaking_1 end,
	@isauto_v10spositiontaking_2 = case when @isauto_v10spositiontaking_2>0 then @isauto_v10spositiontaking_2 else @master_isauto_v10spositiontaking_2 end,
	@isauto_v10spositiontaking_3 = case when @isauto_v10spositiontaking_3>0 then @isauto_v10spositiontaking_3 else @master_isauto_v10spositiontaking_3 end,
	@isauto_v10spositiontaking_20 = case when @isauto_v10spositiontaking_20>0 then @isauto_v10spositiontaking_20 else @master_isauto_v10spositiontaking_20 end

---------------------------------------------------------------------------------------------------------------------------------------------
	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v10spositiontaking_1 as isautov10positiontaking	,	   @auto_v10spositiontaking_1 as autov10positiontaking	,	   @old_auto_v10spositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking	
union all  	select 2 as bettype	,	   @isauto_v10spositiontaking_2 as isautov10positiontaking	,	   @auto_v10spositiontaking_2 as autov10positiontaking	,	   @old_auto_v10spositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking	
union all 	select 3 as bettype	,	   @isauto_v10spositiontaking_3 as isautov10positiontaking	,	   @auto_v10spositiontaking_3 as autov10positiontaking	,	   @old_auto_v10spositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking	
union all 	select 20 as bettype,	   @isauto_v10spositiontaking_20 as isautov10positiontaking,		@auto_v10spositiontaking_20 as autov10positiontaking,	   @old_auto_v10spositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking	
------------------------------------------
OPEN CUR

FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,20) --and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking )
	BEGIN
		if @isautov10positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=10
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking (for Golf)'
						when 'CS' then N'更新占成数不成功(于高尔夫球)'
						when 'CT' then N'更新佔成數不成功(於高爾夫球)'
						when 'TH' then N'การปรับยอดจำนวนเงินในการเล่นไม่สมบูรณ์ (สำหรับกีฬากอฟล์)'
						when 'J' then N'Error updating auto position taking (for Golf)'
						when 'KO' then N'자동 거래 조건 업데이트에 에러가 발생 했습니다 (골프)'
						else N'Error updating auto position taking (for Golf)'
					end	
				RaisError (@ErrMsg, 16, 1)
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
FETCH NEXT FROM CUR INTO			
	@bettype,
	@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking

END
CLOSE CUR
DEALLOCATE CUR

GO
GRANT VIEW DEFINITION ON Acc_CustomerUpdMember_AutoPositiontaking_10 TO vnteam
GO
GRANT EXECUTE ON Acc_CustomerUpdMember_AutoPositiontaking_10 TO [bodbAdminNet]
 
  