CREATE PROCEDURE [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_10
	@mrecommend int,
	@srecommend int,

	@auto_v10spositiontaking_1 smallmoney = 0,
	@auto_v10spositiontaking_2 smallmoney = 0,
	@auto_v10spositiontaking_3 smallmoney = 0,
	@auto_v10spositiontaking_20 smallmoney = 0,

	@isauto_v10spositiontaking_1 bit = 0,
	@isauto_v10spositiontaking_2 bit = 0,
	@isauto_v10spositiontaking_3 bit = 0,
	@isauto_v10spositiontaking_20 bit = 0,

	@language varchar(2),
	@updateallmembers bit = 0,
	@newspositiontaking smallmoney,
	@userid int,

	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20100511@Elodie
Task : update auto super PT of Golf at master level
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdMaster_AutoPositiontaking

Revisions:
   
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
Declare
	@bettype int,
	@maxpos smallmoney,

	@autov10positiontaking smallmoney,
	@old_autov10positiontaking smallmoney,
	@isautov10positiontaking bit,
	@old_isautov10positiontaking bit

Declare 
	@old_auto_v10spositiontaking_1 smallmoney,
	@old_auto_v10spositiontaking_2 smallmoney,
	@old_auto_v10spositiontaking_3 smallmoney,
	@old_auto_v10spositiontaking_20 smallmoney,
	
	@old_isauto_v10spositiontaking_1 bit,
	@old_isauto_v10spositiontaking_2 bit,
	@old_isauto_v10spositiontaking_3 bit,
	@old_isauto_v10spositiontaking_20 bit

--------------------------------------------------------
--Get old Auto PT from Master
select 	@old_auto_v10spositiontaking_1	=	autopositiontaking		,	@old_isauto_v10spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=10	and bettype=	1
select 	@old_auto_v10spositiontaking_2	=	autopositiontaking		,	@old_isauto_v10spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=10	and bettype=	2
select 	@old_auto_v10spositiontaking_3	=	autopositiontaking		,	@old_isauto_v10spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=10	and bettype=	3
select 	@old_auto_v10spositiontaking_20	=	autopositiontaking		,	@old_isauto_v10spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @mrecommend and sporttype=10	and bettype=	20

--Update Master Agent account (autopositiontaking field)
update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
from custsetting inner join 
(
				select 1 as bettype, @auto_v10spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 2 as bettype, @auto_v10spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 3 as bettype, @auto_v10spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
	union all 	select 20 as bettype, @auto_v10spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
) as b on b.bettype = custsetting.bettype
where custsetting.custid = @mrecommend and custsetting.sporttype=10
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
		,  @ErrCode=206
	return
END

Declare CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_v10spositiontaking_1 as isautov10positiontaking	,	   @auto_v10spositiontaking_1 as autov10positiontaking	,	   @old_auto_v10spositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking 
union all  	select 2 as bettype	,	   @isauto_v10spositiontaking_2 as isautov10positiontaking	,	   @auto_v10spositiontaking_2 as autov10positiontaking	,	   @old_auto_v10spositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking
union all 	select 3 as bettype	,	   @isauto_v10spositiontaking_3 as isautov10positiontaking	,	   @auto_v10spositiontaking_3 as autov10positiontaking	,	   @old_auto_v10spositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking
union all 	select 20 as bettype,	   @isauto_v10spositiontaking_20 as isautov10positiontaking,	   @auto_v10spositiontaking_20 as autov10positiontaking,	   @old_auto_v10spositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking

OPEN CUR
FETCH NEXT FROM CUR INTO
	@bettype, 
	@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking

WHILE @@FETCH_STATUS = 0
BEGIN
	if @bettype in (1,2,3,20) and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking )
	BEGIN
		if @isautov10positiontaking >0
		BEGIN
			select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
			from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
			where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
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
						,  @ErrCode=221
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
		else if @isautov10positiontaking <> @old_isautov10positiontaking
		BEGIN
			if @updateallmembers = 1
			BEGIN
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
				from custsetting inner join customer as c with (NOLOCK) on custsetting.custid = c.custid
				inner join custsetting as mcs with (NOLOCK) on mcs.custid = @mrecommend and custsetting.sporttype=mcs.sporttype and custsetting.bettype=mcs.bettype
				where c.mrecommend = @mrecommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 and custsetting.isautopositiontaking=0
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
						,  @ErrCode=222
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
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
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_10 TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_10 TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdMaster_AutoPositiontaking_10 TO vnteam


 