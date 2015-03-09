USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_Dep_CustomerSelInfo]    Script Date: 09/03/2015 11:23:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_Dep_CustomerSelInfo] 
	@Custid INT
AS
BEGIN	
	SET NOCOUNT ON;
	--Sport book
	SELECT dc.custid,dc.sporttype,dc.bettype,dc.islive, 
	   dc.minbet,dc.maxbet,CASE dc.sporttype 
	   WHEN 1 THEN  ci.maxpermatch
	   WHEN 2 THEN  ci.maxpermatch2
	   WHEN 3 THEN  ci.maxpermatch3
	   WHEN 5 THEN  ci.maxpermatch5
	   WHEN 8 THEN  ci.maxpermatch8
	   WHEN 10 THEN  ci.maxpermatch10
	   WHEN 11 THEN  ci.maxpermatch11
	   WHEN 99 THEN  CASE WHEN dc.bettype =9 THEN ci.maxpermatch99MP 
							ELSE ci.maxpermatch99
					 END 
	   WHEN 154 THEN  ci.maxpermatch154	   
	   WHEN 161 THEN  ci.maxpermatch161
	   WHEN 151 THEN  CASE dc.bettype 
						 WHEN 31 THEN ci.maxpermatch151
						 WHEN 41 THEN ci.maxpermatch151_OT
						 WHEN 51 THEN ci.MaxPerMatch151_AU						 
						END
	   WHEN 152 THEN  CASE dc.bettype 				
						 WHEN 41 THEN ci.MaxPerMatch152_UK
						 WHEN 51 THEN ci.MaxPerMatch152_AU
						END
	   WHEN 153 THEN  CASE dc.bettype 										 
						 WHEN 51 THEN ci.MaxPerMatch153_AU
						END
		END MPM
	    ,ci.MaxPerBall161, dc.spositiontaking,dc.mpositiontaking,dc.apositiontaking
		,0,0,0
	FROM Dep_CustSetting dc WITH (NOLOCK) LEFT JOIN custInfo ci WITH (NOLOCK) ON dc.custid=ci.custid
	WHERE dc.custid=@custid	
	UNION ALL -- Racing VirtualSport
	SELECT dc3.custid,dc3.sporttype,dc3.bettype,dc3.islive,dc3.minbet,dc3.maxbet,
		CASE dc3.sporttype 
	   WHEN 151 THEN  CASE dc3.bettype 
						 WHEN 31 THEN ci.maxpermatch151
						 WHEN 32 THEN ci.maxpermatch151
						 WHEN 41 THEN ci.maxpermatch151_OT
						 WHEN 42 THEN ci.maxpermatch151_OT
						 WHEN 51 THEN ci.MaxPerMatch151_AU
						 WHEN 52 THEN ci.MaxPerMatch151_AU
						END
	   WHEN 152 THEN  CASE dc3.bettype 				
						 WHEN 41 THEN ci.MaxPerMatch152_UK
						 WHEN 42 THEN ci.MaxPerMatch152_UK
						 WHEN 51 THEN ci.MaxPerMatch152_AU
						 WHEN 52 THEN ci.MaxPerMatch152_AU
						END
	   WHEN 153 THEN  CASE dc3.bettype 										 
						 WHEN 51 THEN ci.MaxPerMatch153_AU
						 WHEN 52 THEN ci.MaxPerMatch153_AU
						END
	   WHEN 161 THEN ci.maxpermatch161
	   WHEN 180 THEN ci.maxpermatch180
	   WHEN 181 THEN ci.maxpermatch181
	   WHEN 182 THEN ci.maxpermatch182
	   WHEN 183 THEN ci.maxpermatch183
	   WHEN 184 THEN ci.maxpermatch184
	   WHEN 185 THEN ci.maxpermatch185
	   WHEN 186 THEN ci.maxpermatch186
	   END MPM,
	ci.MaxPerBall161,dc3.spositiontaking,dc3.mpositiontaking,dc3.apositiontaking
	,dc3.sdiscount SupRBDiscount,dc3.adiscount MasRBDiscount,dc3.discount AgRBDiscount
	FROM Dep_CustSetting3rd dc3 WITH (NOLOCK) LEFT JOIN	custInfo ci WITH (NOLOCK) ON dc3.custid=ci.custid 
	WHERE dc3.custid=@custID AND dc3.bettype NOT IN (32,42,52)
	UNION ALL -- Keno
	select a.CustID,a.Sporttype,
	KT.IBCBetTypeID,
	0 islive,b.MinBet,b.MaxBet,b.MaxPerGameType,0 MPB,a.spositiontaking,a.mpositiontaking,a.apositiontaking
	,0,0,0
	FROM CustSettingGame a WITH (NOLOCK)LEFT JOIN	CustGameType b WITH (NOLOCK) ON a.custid=b.custid 
	INNER JOIN bodb02.dbo.GameType KT WITH(NOLOCK)  ON b.GameTypeID = kt.GameTypeID
	WHERE a.custid=@custID 
	and a.Sporttype=202
	ORDER by sporttype	
END

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_Dep_CustomerSelInfo] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_Dep_CustomerSelInfo] TO [bodbAdminNet]
GO 
