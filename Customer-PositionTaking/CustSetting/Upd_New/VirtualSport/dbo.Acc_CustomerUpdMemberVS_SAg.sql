ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberVS_SAg]   
 @CustID int,--memberid   
 @sporttype tinyint,  
 @bettype int,  
    
 @s1 smallmoney = 0,   
 @us1 smallmoney = 0,   
 @is1 bit = 0,   
 @is3 bit = 0,--i3  
   
 @UpdatePositiontaking BIT = 0,   
 @UpdateAutoPositiontaking BIT = 0,  
     
 @UserID int,  
 @language varchar(2) = 'E',  
 @SubAccID int = 0, --Sub-AccountID  
 @IP varchar(15)='',  
 @Username varchar(30) = '',  
 @ErrCode varchar(300) = '' OUTPUT,  
 @ErrMsg nvarchar(4000) = '' OUTPUT  
AS  
--@Source Control  
/*  
	Created: 20120820@Dan  
	Task : Super edits Member(VS)  
	DB: DBTRANS.bodb02  
	Original: Acc_CustomerUpdSuper_Member  
	  
	Revisions:  
		 - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language  
		 - 20130130@Scott : Fix bug 5325
		 - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
		 - 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
	Param's Explanation:  
	• @ErrCode:  
		= 0: Update successfully.  
		> 0: Specific Error.  
	    
	• @ErrMsg: Error description.  
*/  
  
SET NOCOUNT ON  
  
declare @startRun datetime  
declare @endRun datetime  
declare @duration int  
set @startRun = getdate()  
  
Declare @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @roleid tinyint  
Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''  
  
EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging   
 @SessionCustID = @Userid,   
 @Custid = @custid,  
 @Username = @Username OUTPUT,  
 @roleid = @roleid OUTPUT  
 if (@roleid <> 1) return-- return if not member  
  
--Check disable user  
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output  
IF @ErrCode_Cur > 0  
BEGIN  
 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
 return  
END  
--end   
declare   
 @m1 smallmoney,  
 @old_s1 smallmoney,  
 @log_s1 smallmoney,  
   
 @mrecommend int,  
 @recommend int,  
 @srecommend int,  
  
 @a1 smallmoney,   
 @s1_max smallmoney,   
 @old_us1 smallmoney ,   
 @old_is1 bit  
   
declare @ErrType varchar(1000), @maxpos smallmoney  
  
SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username   
FROM customer WITH (NOLOCK)   
WHERE custid = @custid  
  
SET @maxpos = 0.9   
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Check param  
declare @IsValid bit  
Select @isvalid = 1  
  
if  (@UpdatePositiontaking = 0 AND @UpdateAutoPositiontaking = 0 )  
 RETURN;  
  
if  (@s1 <0  
 or @s1 > @maxpos  
 or @us1 <0   
 or @us1 > @maxpos   
 )  
  
BEGIN  
 select @isvalid = 0, @ErrCode_cur = 101  
 Select @ErrMsg_cur =  @UserName + ': '+  
  case @Language   
      when 'E' then 'Wrong position taking.'  
      ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)  
    end  
 SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)    
 RETURN  
END   
  
--Check Old_PT <> New_PT  
select @a1 = apositiontaking,   
  @m1 = mpositiontaking,   
  @old_s1 = spositiontaking,      
  @old_us1 = autopositiontaking,   
  @old_is1 = isautopositiontaking,  
  @log_s1 = @s1   
from CustSetting3rd with (NOLOCK)   
where custid = @custid and bettype=@bettype and sporttype=@sporttype  
  
IF @s1 = @old_s1 AND  
 @us1 = @old_us1 AND  
 @is1 = @old_is1    
BEGIN  
 Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)  
 return  
END   
  
SELECT @ErrType = ''  
  
if (@UpdateAutoPositiontaking = 1)  
BEGIN   
 -- check us1<=l4 when is1=1  
 select @ErrType = '(' + @ErrType + sportname + '-'+ typenamee + ', ) : Max '+ convert(varchar(20),co.maxpositiontaking )
 from CustOverride3rd as co with (NOLOCK) inner join  
 (  
  select @sporttype as sporttype, @bettype as bettype, @us1 as autopositiontaking, @is1 as isautopositiontaking   
 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
 inner join sports with (nolock) on b.sporttype = sports.sporttype  
 inner join bettype with (nolock) on b.bettype = bettype.typeid  
 where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking))  
  
  
 if @ErrType <>''  
 BEGIN  
  select @isvalid = 0, @ErrCode_cur = 102  
  Select @ErrMsg_cur =  @UserName + ': '+  
   case @Language   
when 'E' then 'Wrong position taking (min/max set by company) ('+@ErrType+').'
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
     end  
  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
 -- End check parameter  
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    
 --Check us1<=s4  
 select @ErrType = ''  
 select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'  
 from CustSetting3rd as cs with (NOLOCK) inner join  
  (  
   select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking      
  ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype  
 inner join sports with (nolock) on b.sporttype = sports.sporttype  
 inner join bettype with (nolock) on b.bettype = bettype.typeid  
 where cs.custid = @srecommend  
  and   
  ((cs.spositiontaking<b.autopositiontaking))  
    
 if @ErrType <>''  
 BEGIN  
  Select @ErrMsg_cur = @UserName + ': '+  
       case @Language   
        when 'E' then 'Wrong auto position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
       end , @ErrCode_cur = 103        
  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
   
 -- check us1>= Max(0, N4-M1-A1) when is1=1  
 select @ErrType = @ErrType + sportname + '-'+ typenamee +   
  '-Min: '+ cast((case when co.minpositiontaking - mpositiontaking - apositiontaking >0 then co.minpositiontaking - mpositiontaking - apositiontaking else 0 end) as varchar(10)) + '<br>'  
 from CustOverride3rd as co with (NOLOCK) inner join  
 (  
  select @sporttype as sporttype, @bettype as bettype,   
  @us1 as autopositiontaking, @is1 as isautopositiontaking ,  
  @a1 as apositiontaking, @m1 as mpositiontaking  
 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
 inner join sports with (nolock) on b.sporttype = sports.sporttype  
 inner join bettype with (nolock) on b.bettype = bettype.typeid  
 where co.custid = @srecommend and   
  (b.isautopositiontaking>0 and b.autopositiontaking< case when co.minpositiontaking - mpositiontaking - apositiontaking >0 then co.minpositiontaking - mpositiontaking - apositiontaking else 0 end)  
  
 if @ErrType <>''  
 BEGIN  
  select @isvalid = 0, @ErrCode_cur = 108  
  Select @ErrMsg_cur =  @UserName + ': '+  
   case @Language   
        when 'E' then 'Wrong auto position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
     end  
  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
END  
  
if (@UpdatePositiontaking = 1)  
BEGIN    
 --Check s1<=Max(N4-M1-A1, S4-M3)  
 select @ErrType = ''  
 select @ErrType = @ErrType + sportname + '-'+ typenamee   
   + '-Max: '+ cast((case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking > cs.spositiontaking - mcs.mpositiontaking  
         then co.minpositiontaking - b.mpositiontaking - b.apositiontaking  
         else cs.spositiontaking - mcs.mpositiontaking  
       end) as varchar(10)) + '<br>'  
 from CustOverride3rd as co with (NOLOCK) inner join    
  (  
   select @bettype as bettype, @sporttype as sporttype,   
   @s1 as spositiontaking, @is1 as isautopositiontaking ,  
   @a1 as apositiontaking, @m1 as mpositiontaking     
  ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
  inner join CustSetting3rd as cs with (NOLOCK) ON cs.custid=co.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype  
  inner join CustSetting3rd as mcs with (NOLOCK) ON mcs.custid=@mrecommend and co.sporttype=mcs.sporttype and co.bettype=mcs.bettype  
  inner join sports with (nolock) on b.sporttype = sports.sporttype  
  inner join bettype with (nolock) on b.bettype = bettype.typeid  
 where co.custid = @srecommend  
  and (b.spositiontaking> case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking > cs.spositiontaking - mcs.mpositiontaking  
         then co.minpositiontaking - b.mpositiontaking - b.apositiontaking  
         else cs.spositiontaking - mcs.mpositiontaking  
        end  
   )   
    
 if @ErrType <>''  
 BEGIN  
  Select @ErrMsg_cur = @UserName + ': '+  
       case @Language   
        when 'E' then 'Wrong  position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
       end, @ErrCode_cur = 104  
  Select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
   
 -- check s1>= Max(0, N4-M1-A1)   
 select @ErrType = @ErrType + sportname + '-'+ typenamee +   
  '-Min: '+ cast((case when co.minpositiontaking - mpositiontaking - apositiontaking >0 then co.minpositiontaking - mpositiontaking - apositiontaking else 0 end) as varchar(10)) + '<br>'  
 from CustOverride3rd as co with (NOLOCK) inner join  
 (  
  select @sporttype as sporttype, @bettype as bettype,   
  @s1 as spositiontaking, @is1 as isautopositiontaking ,  
  @a1 as apositiontaking, @m1 as mpositiontaking  
 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
 inner join sports with (nolock) on b.sporttype = sports.sporttype  
 inner join bettype with (nolock) on b.bettype = bettype.typeid  
 where co.custid = @srecommend and   
  (b.isautopositiontaking=0 and b.spositiontaking< case when co.minpositiontaking - mpositiontaking - apositiontaking >0 then co.minpositiontaking - mpositiontaking - apositiontaking else 0 end)  
  
 if @ErrType <>''  
 BEGIN  
  select @isvalid = 0, @ErrCode_cur = 109  
  Select @ErrMsg_cur =  @UserName + ': '+  
   case @Language   
        when 'E' then 'Wrong  position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
     end  
  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
  
 SELECT @s1_max = spositiontaking   
 FROM CustSetting3rd WITH (NOLOCK)   
 WHERE custid = @srecommend and bettype=@bettype and sporttype=@sporttype  
  
 SELECT @s1 = CASE WHEN @m1+@s1+@a1>@s1_max THEN @s1_max-@m1-@a1 else @s1 end  
  
 SELECT @s1 = CASE WHEN @s1<0 THEN 0 ELSE @s1 END  
END  
  
IF @UpdatePositiontaking = 1  
BEGIN  
 --don't update s1 for member under master was set i3=1(normal)  
 UPDATE cs WITH (ROWLOCK, UPDLOCK)  
 SET  
  cs.spositiontaking = @s1    
 FROM CustSetting3rd cs  inner join customer c (NOLOCK) ON cs.custid = c.custid  
  inner join CustSetting3rd scs (NOLOCK) ON scs.custid = c.mrecommend and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype  
 WHERE cs.custid=@custid and   
  cs.sporttype = @sporttype and c.roleid = 1 and scs.isautopositiontaking = 0  
   
 IF (@@error <> 0)  
 BEGIN  
  SELECT @ErrMsg_Cur = CASE @Language   
        WHEN 'E' THEN 'Update process is unsuccessful !'  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)  
       END , @ErrCode_Cur = 105  
              
  SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)      
  RETURN  
 END  
END  
  
--Update auto PT  
IF @UpdateAutoPositiontaking = 1  
BEGIN  
 UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)   
 SET autopositiontaking = b.autopositiontaking,  
  isautopositiontaking = b.isautopositiontaking   
 FROM CustSetting3rd as CS INNER JOIN   
   (  
    select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking, @is1 as isautopositiontaking     
   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
 WHERE cs.custid = @custid  
  
 if @@Error <> 0  
 BEGIN  
  SELECT @ErrMsg_cur =  @UserName + ': '+  
  case @Language   
   when 'E' then 'Error updating auto position taking'  
   ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)     
  end, @ErrCode_cur = 106  
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
END  
  
EXEC dbo.Acc_CustSetting3rd_00
	@custid = @custid, 
	@recommend = @recommend, 
	@mrecommend = @mrecommend, 
	@srecommend = @srecommend,
	@mode = 'virtual-sports',
	@sporttype =  @sporttype,   
    @bettype = @bettype
      
/*EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking   
      @sporttype =  @sporttype,   
      @bettype = @bettype,   
      @custid = @custid,   
      @recommend = @recommend,   
      @mrecommend = @mrecommend,   
      @srecommend = @srecommend 
*/       
IF (@@error <> 0)  
BEGIN    
 SELECT @ErrMsg_Cur = CASE @Language   
       WHEN 'E' THEN 'Update process is unsuccessful !'  
       ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)  
      END, @ErrCode_Cur = 107   
   
 SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)    
 RETURN  
END   
  
-- get latest s1 to write log after correcting PT for auto  
IF (@UpdateAutoPositiontaking=1 AND @is3=1 and @is1=0)  
BEGIN  
 select @log_s1 = spositiontaking     
 from CustSetting3rd with (NOLOCK)   
 where custid = @custid and bettype=@bettype and sporttype=@sporttype  
END  
  
Declare @LogSPData varchar(MAX),  
  @TrackingValueDB varchar(5000)  
  
Select @LogSPData = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
's1="'+ coalesce(cast(@log_s1 as varchar(50)),space(1)) + '" ' +  
'us1="'+ coalesce(cast(@us1 as varchar(50)),SPACE(1)) + '" ' +  
'is1="'+ coalesce(cast(@is1 as varchar(50)),SPACE(1)) + '" ' +  
'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'   
  
Select @TrackingValueDB = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
's1="'+ coalesce(cast(@old_s1 as varchar(50)),space(1)) + '" ' +  
'us1="'+ coalesce(cast(@old_us1 as varchar(50)),SPACE(1)) + '" ' +  
'is1="'+ coalesce(cast(@old_is1 as varchar(50)),SPACE(1)) + '" ' +  
'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'   
  
set @endRun = getdate()  
set @duration  = datediff (millisecond,@startRun,@endRun)  
  
--Log positiontaking  
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP   
	 @UserID = @UserID,  
	 @CustID = @CustID,  
	 @ActionID = 435,  
	 @TrackingValue = @LogSPData,  
	 @TrackingValue2 = @TrackingValueDB,  
	 @duration = @duration  
END TRY
BEGIN CATCH	 
	Select @LogSPData = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	's1="'+ coalesce(cast(@log_s1 as varchar(50)),space(1)) + '" ' +  
	'us1="'+ coalesce(cast(@us1 as varchar(50)),SPACE(1)) + '" ' +  
	'is1="'+ coalesce(cast(@is1 as varchar(50)),SPACE(1)) + '" ' +  
	'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'   
	 
	 EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP   
	 @UserID = @UserID,  
	 @CustID = @CustID,  
	 @ActionID = 435,  
	 @TrackingValue = @LogSPData,  
	 @TrackingValue2 = @TrackingValueDB,  
	 @duration = @duration   
END CATCH
	
Select @ErrCode = @ErrCode + '-101'+char(7), @ErrMsg = @ErrMsg + char(7)


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbExtAccNet]
