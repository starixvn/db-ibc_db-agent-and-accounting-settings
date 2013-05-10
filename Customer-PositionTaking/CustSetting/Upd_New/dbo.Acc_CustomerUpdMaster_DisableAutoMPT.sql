ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT]
	@CustID int,-- MasterID
	@DisableAutoMPT bit = 0,
	@SubAccID int = 0, --Sub-AccountID
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20090701@Phuc
Task : Update Disable auto master PT
DB: DBTXN/bodb02

Revisions:
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091203@Kiwi: Modify to retrieve data from CustSetting3rd.
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101006@Lukas: update isautolive PT on custsetting3rd
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Check Old/New value
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20120215@Johnson: Update PT for live casino
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

declare @Old_DisableAutoMPT bit

--Check disable user
EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @UplineClosed bit, @RoleID int, @srecommend int
 
Select @RoleID = roleid, @srecommend = srecommend From custinfo (nolock) Where custid = @CustID
if(@RoleID is null or @roleid <> 3) 
begin
	select @ErrCode = 101,
			@ErrMsg=
					CASE @Language 
						WHEN 'E' THEN 'Account does not exist or invalid customer account'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40019,@Language)
					END	
	return
end

Select @Old_DisableAutoMPT=DisableAutoMPT From CustMaster (nolock) Where custid = @CustID
IF @Old_DisableAutoMPT = @DisableAutoMPT RETURN

Update CustMaster WITH(ROWLOCK,UPDLOCK) Set DisableAutoMPT = @DisableAutoMPT WHERE CustID = @CustID

IF @DisableAutoMPT = 1
BEGIN
	--Reset m2 of all agent under this master
	--m2=min(um2,m3-a2)
	UPDATE acs 
		SET mpositiontaking = case when acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking then mcs.mpositiontaking - acs.apositiontaking else acs.autompositiontaking end  	
	FROM custsetting acs WITH(ROWLOCK,UPDLOCK) 
		INNER JOIN custinfo ci (nolock) on ci.custid = acs.custid
		INNER JOIN custsetting mcs (NOLOCK) on acs.sporttype = mcs.sporttype and acs.bettype = mcs.bettype and mcs.custid = @CustID
	WHERE ci.mrecommend = @CustID AND ci.roleid = 2 AND (acs.isautompositiontaking = 1)
	
	UPDATE acs 
		SET mpositiontaking = case when acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking then mcs.mpositiontaking - acs.apositiontaking else acs.autompositiontaking end  	
	FROM CustSetting3rd acs WITH(ROWLOCK,UPDLOCK) 
		INNER JOIN custinfo ci (nolock) on ci.custid = acs.custid
		INNER JOIN CustSetting3rd mcs (NOLOCK) on acs.sporttype = mcs.sporttype and acs.bettype = mcs.bettype and mcs.custid = @CustID
	WHERE ci.mrecommend = @CustID AND ci.roleid = 2 AND (acs.isautompositiontaking = 1)

	UPDATE acs 
		SET mlivepositiontaking = case when acs.autolivempositiontaking > mcs.mlivepositiontaking - acs.alivepositiontaking then mcs.mlivepositiontaking - acs.alivepositiontaking else acs.autolivempositiontaking end  	
	FROM custsetting acs WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) on ci.custid = acs.custid
		INNER JOIN custsetting mcs (NOLOCK) on acs.sporttype = mcs.sporttype and acs.bettype = mcs.bettype and mcs.custid = @CustID
	WHERE ci.mrecommend = @CustID AND ci.roleid = 2 AND (acs.isautolivempositiontaking = 1)


	UPDATE acs3 
		SET mlivepositiontaking = case when acs3.autolivempositiontaking > mcs3.mlivepositiontaking - acs3.alivepositiontaking then mcs3.mlivepositiontaking - acs3.alivepositiontaking else acs3.autolivempositiontaking end  	
	FROM custsetting3rd acs3 WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) on ci.custid = acs3.custid
		INNER JOIN custsetting3rd mcs3 (NOLOCK) on acs3.sporttype = mcs3.sporttype and acs3.bettype = mcs3.bettype and mcs3.custid = @CustID
	WHERE ci.mrecommend = @CustID AND ci.roleid = 2 AND (acs3.isautolivempositiontaking = 1)
	
	UPDATE acs
	SET mpositiontaking = CASE WHEN acs.autompositiontaking > mcs.mpositiontaking - acs.apositiontaking THEN mcs.mpositiontaking - acs.apositiontaking ELSE acs.autompositiontaking END
	FROM CustSettingGame acs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN CustInfo ci WITH(NOLOCK) ON acs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = acs.sporttype AND mcs.bettype = acs.bettype 
	WHERE ci.mrecommend = @custid AND ci.roleid = 2 AND acs.isautompositiontaking = 1
	
	--Reset auto master PT of all agent under this master 
	UPDATE cs
		SET isautompositiontaking = 0,
			autompositiontaking = 0
	FROM custsetting cs WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) ON ci.custid = cs.custid 
	WHERE ci.mrecommend = @CustID AND ci.roleid in (1,2) AND (cs.isautompositiontaking = 1)
	
	UPDATE cs
		SET isautompositiontaking = 0,
			autompositiontaking = 0
	FROM CustSetting3rd cs WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) ON ci.custid = cs.custid 
	WHERE ci.mrecommend = @CustID AND ci.roleid in (1,2) AND (cs.isautompositiontaking = 1)
	 
	 UPDATE cs
		SET isautolivempositiontaking = 0,
			autolivempositiontaking = 0
	FROM custsetting cs WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) ON ci.custid = cs.custid 
	WHERE ci.mrecommend = @CustID AND ci.roleid in (1,2) AND (cs.isautolivempositiontaking = 1)

	UPDATE cs3
		SET isautolivempositiontaking = 0,
			autolivempositiontaking = 0
	FROM custsetting3rd cs3 WITH(ROWLOCK,UPDLOCK) INNER JOIN custinfo ci (nolock) ON ci.custid = cs3.custid 
	WHERE ci.mrecommend = @CustID AND ci.roleid in (1,2) AND (cs3.isautolivempositiontaking = 1)
	
	UPDATE cs
	SET isautompositiontaking = 0,
		autompositiontaking = 0
	FROM CustSettingGame cs WITH(ROWLOCK,UPDLOCK)
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	WHERE ci.mrecommend = @custid AND ci.roleid IN (1,2) AND cs.isautompositiontaking = 1
END

declare @LogSPData varchar(8000)

Select @LogSPData = '<Acc_CustomerUpdMaster_DisableAutoMPT CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
'DisableaMPT="'+ coalesce(cast(@DisableAutoMPT as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
 
set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun) 

BEGIN TRY 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1113,
		@TrackingValue = @LogSPData,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdMaster_DisableAutoMPT CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
	'DisableaMPT="'+ coalesce(cast(@DisableAutoMPT as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1113,
		@TrackingValue = @LogSPData,
		@duration = @duration
END CATCH
		
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbDownlineNet] 
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_DisableAutoMPT] TO [bodbExtAccNet]

