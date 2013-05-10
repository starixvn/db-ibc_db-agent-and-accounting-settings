ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberVS_MAg]   
 @CustID int,--memberid  
 @sporttype tinyint,  
 @bettype int,  
    
 @m1 smallmoney  = 0,   
 @im2 bit = 0,    
 @im1 bit = 0,    
 @um1 SMALLMONEY = 0,    
  
 @UpdatePositiontaking BIT = 1,   
 @UpdateAutoPositiontaking BIT = 1,  
  
 @UserID int,--masterid   
 @Language varchar(2) = 'E',  
 @SubAccID int = 0, --Sub-AccountID  
 @IP varchar(15)='',  
 @Username varchar(30) = '',  
 @ErrCode varchar(300) = '' OUTPUT,  
 @ErrMsg nvarchar(4000) = '' OUTPUT  
AS  
--@Source Control  
/*  
	Created: 20120813@Dan  
	Task : Master edit member(VS)  
	DB: DBTXN/bodb02  
	Original: [Acc_CustomerUpdMaster_Member]  
	  
	Revisions:  
	 - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language  
	 - 20121224@Scott : Fix bug 5441( get @m3 before checking)
	 - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
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
  
Declare @ErrType varchar(1000), @roleid tinyint, @recommend INT, @mrecommend INT, @srecommend INT,  
 @ErrCode_cur int, @ErrMsg_cur nvarchar(4000)  
Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''  
  
EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging   
 @SessionCustID = @Userid,   
 @username = @username output,  
 @Custid = @custid,  
 @roleid = @roleid OUTPUT  
 if (@roleid <> 1) return -- return if not member  
  
--Check disable user  
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output  
IF @ErrCode_Cur > 0  
BEGIN  
 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
 return  
END  
--end  
  
select @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend   
from customer with (NOLOCK) where custid = @custid  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Check parameter  
  
declare @maxpos smallmoney  
set @maxpos = 0.9  
  
if (@m1 <0  
 or @m1 > @maxpos  
 or @um1 <0   
 or @um1 > @maxpos   
 )   
 AND (@UpdatePositiontaking = 1 or @UpdateAutoPositiontaking=1)  
BEGIN  
 select @ErrCode_cur = 5  
 Select @ErrMsg_cur =  @UserName + ': ' +  
  case @Language   
      when 'E' then 'Wrong position taking.'  
      ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)  
    end  
 Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
 RETURN  
END  
-- End check param  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  
  
DECLARE    
 @a1 SMALLMONEY,    
 @a2 SMALLMONEY,    
   
 @old_m1 SMALLMONEY,     
 @old_um1 SMALLMONEY,    
 @old_im1 BIT,  
 @m1_log SMALLMONEY,  
   
 @s4 SMALLMONEY,   
   
 @s1 SMALLMONEY,    
 @u1 SMALLMONEY,   
 @i1 BIT,  
   
 @m3 SMALLMONEY,   
 @u3 SMALLMONEY,     
 @i3 BIT,   
 @n3 SMALLMONEY,  
   
 --um2  
 @um2 SMALLMONEY,  
   
 ---- backup to write log  
 @old_im2 bit  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------  
/*  
if @srecommend>100 and @custid<>79711  
BEGIN  
 declare @ErrMsg varchar(200)  
 Select @ErrMsg = 'Sorry, please try again later.'  
 RaisError (@ErrMsg, 16, 1)  
 return  
END  
*/  
  
-- backup  
SELECT @old_im2 = @im2  
  
--s1,a1,old_m1,u1,i1  
SELECT @s1 = spositiontaking, @a1 = apositiontaking,   
 @u1 = autopositiontaking, @i1 = isautopositiontaking,   
 @old_m1 = mpositiontaking , @old_um1 = autompositiontaking ,   
 @old_im1 = isautompositiontaking,  
 @m1_log = @m1  
FROM CustSetting3rd WITH (NOLOCK)   
WHERE custid = @custid AND bettype = @bettype AND sporttype = @sporttype  
  
--m3,u3,i3  
SELECT @m3 = mpositiontaking, @u3 = autopositiontaking, @i3 = isautopositiontaking   
FROM CustSetting3rd WITH (NOLOCK)   
WHERE custid = @mrecommend AND bettype=@bettype AND sporttype=@sporttype  

  
  
--Check if old_PT = new_PT return  
IF @m1 = @old_m1 AND @um1 = @old_um1 AND @im1 = @old_im1   
BEGIN   
 SELECT @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)  
 RETURN   
END  
  
  
  
IF (@UpdateAutoPositiontaking = 1)  
BEGIN  
 --Check um1<=l3  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
  + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))  
 FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN  
  (  
   SELECT @sporttype AS sporttype, @bettype AS bettype, @um1 AS autopositiontaking, @im1 AS isautopositiontaking        
  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
 INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
 INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE co.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking)  
  
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 6,  
      @ErrMsg_cur = CASE @Language   
         WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
         ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
       END  
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)          
  RETURN  
 END   
  
 --Check um1<=min(m3,m4)  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee  + '-Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))  
 FROM  
  (  
   SELECT @sporttype AS sporttype, @bettype AS bettype, @m3 AS maxmpositiontaking, @um1 AS autopositiontaking, @im1 AS isautopositiontaking    
  ) AS b   
 INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
 INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking)  
  
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 7,  
      @ErrMsg_cur = @UserName + ': '+  
       CASE @Language   
        WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
       END         
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
    
  RETURN  
 END  
   
   
 --Check um1>=Max(0, N3-A1)  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
  + '-Min: '+ CAST((case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end) AS VARCHAR(10))  
 FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN  
  (  
   SELECT @sporttype AS sporttype, @bettype AS bettype, @um1 AS autopositiontaking, @im1 AS isautopositiontaking, @a1 as  apositiontaking  
  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
 INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
 INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE co.custid = @mrecommend AND   
  (b.isautopositiontaking>0 AND b.autopositiontaking< case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end)  
  
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 10,  
      @ErrMsg_cur = CASE @Language   
        WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
       END  
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)          
  RETURN  
 END   
END  
   

  
--n3  
SELECT @n3 = minpositiontaking   
FROM CustOverride3rd WITH (NOLOCK)   
WHERE custid = @mrecommend AND bettype=@bettype AND sporttype=@sporttype  
   
--s4  
SELECT @s4 = spositiontaking   
FROM CustSetting3rd WITH (NOLOCK)   
WHERE custid = @srecommend AND bettype=@bettype AND sporttype=@sporttype  
  
--m1_max = min(m3,m4), s4  
SELECT @s4 = spositiontaking,  
  @m3 = case when @m3 > mpositiontaking then mpositiontaking   
     else @m3 end    
FROM CustSetting3rd WITH (NOLOCK)   
WHERE custid = @srecommend AND bettype=@bettype AND sporttype=@sporttype  
    
--um2, a2  
SELECT   
 @um2 = acs.autompositiontaking ,   
 @a2 = acs.apositiontaking   
FROM CustSetting3rd acs WITH(NOLOCK)  
WHERE acs.custid = @recommend  
  and acs.sporttype = @sporttype  
  and bettype=@bettype   
  
IF @UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1  
BEGIN   
 --Check m1<= Max(0, MIN(M3,M4)-A1)  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
   + '-Max: '+ CAST((case when b.maxmpositiontaking - b.apositiontaking  < b.maxspositiontaking -spositiontaking - apositiontaking  
         then (case when b.maxmpositiontaking - b.apositiontaking > 0 then b.maxmpositiontaking - b.apositiontaking else 0 end)  
         else (case when b.maxspositiontaking -spositiontaking - apositiontaking > 0 then b.maxspositiontaking -spositiontaking - apositiontaking else 0 end)  
      end ) AS VARCHAR(10))  
 FROM (  
   SELECT @sporttype AS sporttype, @bettype AS bettype ,        
     @s1 AS spositiontaking, @m1 AS mpositiontaking, @a1 AS apositiontaking,   
     @m3 AS maxmpositiontaking, @s4 AS maxspositiontaking  
 )b    
  INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
  INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE @im1 = 0 and b.mpositiontaking > b.maxmpositiontaking - b.apositiontaking           
  
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 8,  
    @ErrMsg_cur = @UserName + ': '+  
       CASE @Language   
        WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType  
        ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
       END         
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
    
  RETURN  
 END  
   
 --Check m1<=l3  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
  + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))  
 FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN  
  (  
   SELECT @sporttype AS sporttype ,  @sporttype AS bettype ,  @m1 AS mpositiontaking       
  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
  INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
  INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE co.custid = @mrecommend AND (b.mpositiontaking>co.maxpositiontaking)   
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 9,  
    @ErrMsg_cur = @UserName + ': '+  
      CASE @Language   
       WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
     END  
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  RETURN  
 END    
   
 --Check m1>=Max(0, N3-A1)  
 SELECT @ErrType = ''  
 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
  + '-Min: '+ CAST((case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end) AS VARCHAR(10))  
 FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN  
  (  
   SELECT @sporttype AS sporttype, @bettype AS bettype, @m1 AS mpositiontaking, @im1 AS isautopositiontaking, @a1 as  apositiontaking  
  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
 INNER JOIN sports WITH (NOLOCK) ON b.sporttype = sports.sporttype  
 INNER JOIN bettype WITH (NOLOCK) ON b.bettype = bettype.typeid  
 WHERE co.custid = @mrecommend AND   
  (b.isautopositiontaking=0 AND b.mpositiontaking< case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end)  
  
 IF @ErrType <>''  
 BEGIN  
  SELECT @ErrCode_cur = 11,  
      @ErrMsg_cur = CASE @Language   
         WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
         ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
       END  
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)          
  RETURN  
 END   
   
 --m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1  
 SELECT   
  @m1 = CASE WHEN @a1+@m1>@m3 THEN @m3-@a1 ELSE @m1 END    
  
 --m1=m1+a1<n3?n3-a1:m1  
 SELECT   
  @m1 = CASE WHEN @a1+@m1<@n3 THEN @n3-@a1 ELSE @m1 END    
  
 SELECT   
  @m1 = CASE WHEN @m1<0 THEN 0 ELSE @m1 END  
    
  
 --Must include code for auto master  
 --um=im1>0?um1:um2  
 --im=im1>0?im1:im2  
 --m1=im>0?min(um,m3-a1):m1  
 ----------------------------------------------------------------------------------------------------------------------------  
 --auto master  
  
 --um=im1>0?um1:um2  
 SELECT   
  @um2 = CASE WHEN @im1>0 THEN @um1 ELSE @um2 END,   
  --im=im1>0?im1:im31  
  @im2 = CASE WHEN @im1>0 THEN @im1 ELSE @im2 END  
 ---------------------------------------------------------------------------------------------------------------------------------------------  
  
 ----------------***Use Auto Position Taking***----------------------------------  
 --m1=im>0?min(um,m3-a1):m1  
 SELECT @m1 = CASE WHEN ISNULL(@im2, 0)<=0 THEN @m1 ELSE CASE WHEN @um2 < @m3 - @a1 THEN @um2 ELSE @m3 - @a1 END END  
   
 ---------------------------------------------------------------------------------------------------------------------------------------------  
 --CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)  
 SELECT   
  @u3 = CASE WHEN @i1>0 THEN @u1 ELSE @u3 END,    
  @i3 = CASE WHEN @i1>0 THEN @i1 ELSE @i3 END  
    
 ----------------***Use Auto Position Taking***----------------------------------  
 SELECT @s1 = CASE WHEN ISNULL(@i3, 0)<=0 THEN @s1 ELSE CASE WHEN @u3 < @s4 - @m1 - @a1 THEN @u3 ELSE @s4 - @m1 - @a1 END END  
   
 -------------------------------------------------------------------------------  
 --maxs1=isauto?s4:s4-m2  
 SELECT @s4 = CASE WHEN ISNULL(@i3, 0)>0 THEN @s4 ELSE @s4-@m3 END  
   
 --s1=s1>maxs1?maxs1:s1  
 SELECT @s1 = CASE WHEN @s1 > @s4 THEN @s4 ELSE @s1 END  
END   
  
--don't update m1,s1 for member under agent was set im2=1  
UPDATE cs WITH (ROWLOCK, UPDLOCK)  
SET  
 mpositiontaking = @m1 ,  
 spositiontaking = @s1  
FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid  
 INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype   
WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0   
 AND cs.sporttype = @sporttype and cs.bettype = @bettype  
  
--Update auto PT  
--------------------------------------------------------  
--Update Member account (autompositiontaking field)  
update CustSetting3rd with (ROWLOCK, UPDLOCK)   
set autompositiontaking =  b.autompositiontaking ,   
 isautompositiontaking = b.isautompositiontaking    
from CustSetting3rd as cs inner join   
  (  
   select @bettype as bettype, @sporttype as sporttype, @um1 as autompositiontaking, @im1 as isautompositiontaking   
  ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
where cs.custid = @custid  
  
if @@Error <> 0  
BEGIN  
   
 SELECT @ErrCode_cur = 101,  
   @ErrMsg_cur =    
     case @Language   
      when 'E' then 'Error updating auto position taking'  
      ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)  
     end   
 SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
 return  
END  
   
if @im2 >0  
BEGIN  
 select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK)   
 where custid = @mrecommend and sporttype=@sporttype and bettype = @bettype  
   
 update CustSetting3rd with (ROWLOCK, UPDLOCK)   
 set mpositiontaking = case when @maxpos - apositiontaking>@um2 then @um2 else @maxpos - apositiontaking end  
 from CustSetting3rd as cs  
 where custid = @custid and cs.bettype = @bettype and cs.sporttype = @sporttype  
   
 if @@Error <> 0  
 BEGIN  
  SELECT @ErrCode_cur = 110,  
    @ErrMsg_cur =    
      case @Language   
       when 'E' then 'Error updating auto position taking (for Other sports)'  
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'  
      end   
  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
  return  
 END  
END  
  
EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = @sporttype, @bettype = @bettype, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend  
IF (@@error <> 0)  
BEGIN    
 SELECT @ErrMsg_Cur = CASE @Language   
       WHEN 'E' THEN 'Update process is unsuccessful !'  
       ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)  
      END, @ErrCode_Cur = 304   
   
 SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)    
 RETURN  
END   
  
-- get latest m1 to write log after correcting PT for auto  
IF (@UpdateAutoPositiontaking=1 AND @im2=1 and @im1=0)  
BEGIN  
 select @m1_log = mpositiontaking     
 from CustSetting3rd with (NOLOCK)   
 where custid = @custid and bettype=@bettype and sporttype=@sporttype  
END  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------  
DECLARE @LogSPData VARCHAR(MAX),  
  @TrackingValueDB VARCHAR(5000)  
  
Select @LogSPData = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
  
'm1="'+ coalesce(cast(@m1_log as varchar(50)),space(1)) + '" ' +  
'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
'im1="'+ coalesce(cast(@im1 as varchar(50)),SPACE(1)) + '" ' +  
'um1="'+ coalesce(cast(@um1 as varchar(50)),SPACE(1)) + '" ' +  
  
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
  
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +  
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'   
  
Select @TrackingValueDB = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
  
'm1="'+ coalesce(cast(@old_m1 as varchar(50)),space(1)) + '" ' +  
'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
'im1="'+ coalesce(cast(@old_im1 as varchar(50)),SPACE(1)) + '" ' +  
'um1="'+ coalesce(cast(@old_um1 as varchar(50)),SPACE(1)) + '" ' +  
  
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
  
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +  
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
	 @ActionID = 432,  
	 @TrackingValue = @LogSPData,  
	 @TrackingValue2 = @TrackingValueDB,  
	 @duration = @duration  
END TRY
BEGIN CATCH		
	Select @LogSPData = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	  
	'm1="'+ coalesce(cast(@m1_log as varchar(50)),space(1)) + '" ' +  
	'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
	'im1="'+ coalesce(cast(@im1 as varchar(50)),SPACE(1)) + '" ' +  
	'um1="'+ coalesce(cast(@um1 as varchar(50)),SPACE(1)) + '" ' +  
	  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	  
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +  
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'   
	 
	 EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
	 @UserID = @UserID,  
	 @CustID = @CustID,  
	 @ActionID = 432,  
	 @TrackingValue = @LogSPData,  
	 @TrackingValue2 = @TrackingValueDB,  
	 @duration = @duration 
END CATCH  
 
Select @ErrCode = @ErrCode + '-101'+char(7), @ErrMsg = @ErrMsg + char(7)  



GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbAdminNet]
GO 
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [vnteam]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbExtAccNet]
