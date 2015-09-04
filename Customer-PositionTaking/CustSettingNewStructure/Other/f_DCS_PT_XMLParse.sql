ALTER FUNCTION f_DCS_PT_XMLParse(@DataXML	NVARCHAR(MAX)) 
RETURNS @SportBetTypeTbl TABLE (SportType SMALLINT
						, Bettype SMALLINT
						, IsLive BIT
						, IsAuto_New BIT
						, IsAuto_Old BIT
						, IsUpdAllMems BIT
						, UpdAllMems_Value TINYINT
						, SuperPT TINYINT
						, MasterPT TINYINT
						, AgentPT TINYINT
						, IsAutoMasterPT BIT
						, AutoMasterPT TINYINT
						, IsAutoSuperPT BIT
						, AutoSuperPT TINYINT
						, MinPT TINYINT
						, MaxPT TINYINT
						)
/*
    Created: Dominic
    Date: 20150901
    Task: Parse PT XML (Dynamic Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:

    Parameter's Explanation:
		- @DataXML
						<ROOT>
							<PT SportType="180" BetType="1201" IsLive="0" ... />
							<PT SportType="181" BetType="1202" IsLive="0" ... />
							<PT SportType="183" BetType="1203" IsLive="0" ... />
						</ROOT>
*/
BEGIN 
	DECLARE @XML XML =  @DataXML
	

	INSERT @SportBetTypeTbl
	SELECT r.value('./@SportType','SMALLINT')
			, r.value('./@BetType','SMALLINT')
			, r.value('./@IsLive','BIT')
			
			--AutoPT: Acc_DynamicCustSetting_05
			, r.value('./@IsAuto_New','BIT')
			, r.value('./@IsAuto_Old','BIT')
			, r.value('./@IsUpdAllMems','BIT')
			, r.value('./@UpdAllMems_Value','TINYINT')
			
			--Setting
			, r.value('./@SuperPT','TINYINT')
			, r.value('./@MasterPT','TINYINT')
			, r.value('./@AgentPT','TINYINT')
			, r.value('./@IsAutoMasterPT','BIT')
			, r.value('./@AutoMasterPT','TINYINT')
			, r.value('./@IsAutoSuperPT','BIT')
			, r.value('./@AutoSuperPT','TINYINT')
			, r.value('./@MinPT','TINYINT')
			, r.value('./@MaxPT','TINYINT')
	FROM @xml.nodes('//ROOT/PT') AS RECORDS(r)

 
	RETURN
END