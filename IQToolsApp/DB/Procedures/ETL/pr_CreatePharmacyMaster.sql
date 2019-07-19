IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePharmacyMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreatePharmacyMaster]
GO

CREATE Proc [dbo].[pr_CreatePharmacyMaster]

As

Begin
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_Pharmacy'') AND type in (N''U''))
	DROP TABLE tmp_Pharmacy')

	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempPharmacyA'') DROP TABLE TempPharmacyA')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempRegimenMap'') DROP TABLE TempRegimenMap')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''tempLastRegimens'') DROP TABLE tempLastRegimens')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempProphylaxis'') DROP TABLE TempProphylaxis') 

	EXEC('WITH 
	ARVs_A AS 
	(
	Select DISTINCT a.Ptn_Pk
	, c.VisitID
	, c.ptn_pharmacy_pk
	, coalesce(f.RegimenCode +'' - ''+ f.RegimenName, e.DrugAbbreviation) GenericAbbrevation
		FROM mst_Patient a
	INNER JOIN ord_Visit b ON a.Ptn_Pk = b.Ptn_Pk
	INNER JOIN ord_PatientPharmacyOrder c ON a.Ptn_Pk = c.Ptn_pk AND b.Visit_Id = c.VisitID
	INNER JOIN dtl_PatientPharmacyOrder d ON c.ptn_pharmacy_pk = d.ptn_pharmacy_pk
	INNER JOIN mst_Drug e ON d.Drug_Pk = e.Drug_pk
	INNER JOIN mst_DrugType i ON e.DrugType = i.DrugTypeID
	left join mst_Regimen f on c.RegimenId=f.RegimenID
	Where (a.DeleteFlag = 0 Or a.DeleteFlag IS NULL)
	AND (b.DeleteFlag = 0 OR b.DeleteFlag IS NULL)
	AND (c.DeleteFlag = 0 OR c.DeleteFlag IS NULL)
	AND i.DrugTypeName = ''ARV Medication''
	And c.DispensedByDate IS NOT NULL
	)
	,ARVs AS 
	(
	Select Ptn_Pk
	, ROW_NUMBER() Over (Partition By ptn_pharmacy_pk Order By ptn_pk, ptn_pharmacy_pk, GenericAbbrevation) i
	, VisitID
	, ptn_pharmacy_pk
	, GenericAbbrevation
	 FROM ARVs_A
	)
	, ARVsPIVOT AS (
	Select * FROM ARVs PIVOT (MIN(GenericAbbrevation) FOR i IN ([1],[2],[3],[4])) b)

	, RegimenMap AS (
	Select Ptn_Pk, VisitID, ptn_pharmacy_pk
	,CASE WHEN [4] IS NOT NULL THEN [1] + ''+'' + [2] + ''+'' + [3] + ''+'' + [4]
	 WHEN [3] IS NOT NULL THEN [1] + ''+'' + [2] + ''+'' + [3] 
	 WHEN [3] IS NULL AND [2] IS NOT NULL THEN [1] + ''+'' + [2]
	 WHEN [2] IS NULL AND [1] IS NOT NULL THEN [1] 
	 ELSE NULL END AS Regimen
	 , [1],[2],[3],[4]
	  FROM ARVsPIVOT)

	--INSERT INTO TempRegimenMap
	Select Ptn_Pk, VisitID, ptn_pharmacy_pk,regimen
	, case when regimen like ''%ATV%'' and regimen like ''%RTV%'' then 1 else NULL END AS ATVRTV INTO TempRegimenMap  
	FROM RegimenMap')

	EXEC('UPDATE TempRegimenMap SET regimen = Case WHEN regimen LIKE ''%LOPr%'' THEN REPLACE(regimen,''LOPr'', ''LPV/r'') ELSE regimen END')

	EXEC('if exists(select * from sysobjects where name=''temp_a'' and type=''u'') drop table temp_a
	if exists(select * from sysobjects where name=''temp_b'' and type=''u'') drop table temp_b
	if exists(select * from sysobjects where name=''temp_c'' and type=''u'') drop table temp_c
	if exists(select * from sysobjects where name=''temp_lastregimen'' and type=''u'') drop table temp_lastregimen
	if exists(select * from sysobjects where name=''temp_lastregimenStart'' and type=''u'') drop table temp_lastregimenStart
	if exists(select * from sysobjects where name=''temp_lastregimendispensed'' and type=''u'') drop table temp_lastregimendispensed
	if exists(select * from sysobjects where name=''tempLastRegimens'' and type=''u'') drop table tempLastRegimens

	Select Ptn_pk
	, ROW_NUMBER() Over (Partition By ptn_pk Order By ptn_pharmacy_Pk desc) i
	, VisitID
	, ptn_pharmacy_pk
	, regimen
	, len(regimen)reglength
	into temp_a
	FROM TempRegimenMap

	select *
	into temp_b 
	from temp_a where i <= 4

	select b.ptn_pk
	, b.visitid
	, b.ptn_pharmacy_pk
	, b.regimen
	into temp_c
	from temp_b b inner join (
	select ptn_pk			
	, max(reglength) reglength 
	from temp_b group by ptn_pk) c on b.ptn_pk = c.ptn_pk
	and b.reglength = c.reglength

	select c.ptn_pk
	, c.visitid, c.ptn_pharmacy_pk, c.regimen 
	into temp_lastregimen
	from temp_c c inner join (
	Select ptn_pk, max(ptn_pharmacy_pk) lastptn
	from temp_c  group by ptn_pk) d on c.ptn_pk = d.ptn_pk and c.ptn_pharmacy_pk = d.lastptn

	
	Select a.ptn_pk, min(a.ptn_pharmacy_pk)lastStart 
	into temp_lastregimenStart
	FROM temp_a a inner join temp_lastregimen b on a.ptn_pk = b.ptn_pk
	and a.regimen = b.regimen
	group by a.ptn_pk

	select a.ptn_pk
	, a.i
	, a.regimen lastregimen
	, a.ptn_pharmacy_pk 
	, len(a.regimen) reglength
	into temp_lastregimendispensed
	from temp_a a inner join (select ptn_pk
						, max(ptn_pharmacy_pk) last_pk
						from temp_a a group by ptn_pk)b 
	on a.ptn_pk = b.ptn_pk and a.ptn_pharmacy_pk = b.last_pk

	Select a.ptn_pk
	, a.visitid lastvisitID
	, a.ptn_pharmacy_pk lastdispensePK
	, case when c.reglength between 11 and 13 then c.lastregimen else a.regimen end as lastRegimen
	, case when c.reglength between 11 and 13 then c.ptn_pharmacy_pk else b.lastStart end as lastRegimenStartPK 
	into tempLastRegimens
	from temp_lastregimen a 
	inner join temp_lastregimenStart b on a.ptn_pk = b.ptn_pk
	inner join temp_lastregimendispensed c on a.ptn_pk = c.ptn_pk')

	EXEC('WITH Prophlyaxis AS (
	Select  v.Ptn_pk PatientPK,
	v.VisitID,
	v.DrugName Drug,
	Null Provider,
	v.DispensedByDate DispenseDate,
	Cast(Floor(Min(v.Duration)) As int) Duration,
	DATEADD(dd,Cast(Floor(Min(v.Duration)) As int)
	,v.DispensedByDate) ExpectedReturn
	, ''Prophylaxis'' TreatmentType
	, Null RegimenLine
	, Null PeriodTaken
	, Case WHen 
	(v.DrugName Like ''%tmx%'') Or
	(v.DrugName Like ''%dapson%'') Or
	(v.DrugName Like ''%septrin%'') Or
	(v.DrugName Like ''%co%trimox%'')Then ''CTX'' When 
	(v.DrugName Like ''%Fluconazole%'') Or (v.DrugName like ''%diflucan%'') 
	Then ''Fluconazole'' Else Null End As
			 ProphylaxisType
	, NULL PMTCT
	From VW_PatientPharmacy v
	Where (v.DrugName Like ''%tmx%'') Or
			(v.DrugName Like ''%Fluconazole%'') Or
			(v.DrugName Like ''%dapson%'') Or
			(v.DrugName Like ''%septrin%'') Or
			(v.DrugName Like ''%co%trimox%'') Or
			(v.DrugName like ''%diflucan%'')
	Group By v.Ptn_pk,v.DispensedByDate,v.DrugName, v.visitID

	UNION

	Select  o.ptn_pk PatientPK
	, o.VisitID
	, Case 
	When b.GenericName Like ''%Fluconazole%'' Then ''Fluconazole'' 
	When b.GenericName Like ''%Sulfa%tmx%'' 
	or b.GenericName Like ''%co%tri%'' 
	or b.GenericName Like ''%dapsone%%'' 
	Then ''Co-trimoxazole'' Else Null End Drug
	, Null Provider
	, o.DispensedByDate DispenseDate
	, Cast(Floor(Min(a.Duration)) As int) Duration
	, DATEADD(dd,  Cast(Floor(Min(a.Duration)) As int) ,o.DispensedByDate) ExpectedReturn
	, ''Prophylaxis'' TreatmentType
	, Null RegimenLine
	, Null PeriodTaken
	, Case 
	When b.GenericName Like ''%Fluconazole%'' Then ''Fluconazole'' 
	When b.GenericName Like ''%Sulfa%tmx%'' 
	or b.GenericName Like ''%co%tri%'' 
	or b.GenericName Like ''%dapson%'' 
	Then ''CTX'' Else Null End AS ProphylaxisType
	, NULL PMTCT
	From 
	ord_patientpharmacyorder o inner join 
	dtl_patientpharmacyorder a on o.ptn_pharmacy_pk = a.ptn_pharmacy_pk 
	inner join mst_generic b on a.genericID = b.genericID
	Where drug_pk = 0 
	and (b.GenericName Like ''%Fluconazole%'' 
	Or b.GenericName Like ''%Sulfa%tmx%''
	or b.GenericName Like ''%co%tri%'' 
	or b.GenericName Like ''%dapson%'')
	Group By o.ptn_pk ,o.DispensedByDate ,b.GenericName, o.visitID 	

	UNION

	Select Distinct   a.Ptn_pk PatientPK
	, a.VisitID 
	, a.DrugName Drug
	, Null Provider
	, a.DispensedByDate DispenseDate
	, a.Duration 
	, DATEADD(dd,a.Duration, a.DispensedByDate) ExpectedReturn
	, ''Prophylaxis'' TreatmentType
	, Null RegimenLine
	, Null PeriodTaken
	, ''TB Prophylaxis'' ProphylaxisType
	, NULL PMTCT
	From VW_PatientPharmacy a Where GenericName = ''Isoniazid''
	OR a.DrugName LIKE ''Isoniazid%''
	)

	Select * INTO TempProphylaxis FROM Prophlyaxis')

	--**ART Regimens
	EXEC('Select Distinct 
	m.Ptn_pk,
	a.VisitID,
	a.Ptn_Pharmacy_Pk,
	a.DispensedByDate dispenseDate,
	g.Regimen,
	Max(b.Duration) duration,
	h.Name Provider,
	j.Name regimenLine,
	CASE WHEN LEN(g.Regimen) >= 11 AND i.Name IN (''ART'',''PMTCT'') THEN ''ART'' ELSE i.Name END AS treatmentType 
	, CASE WHEN i.Name = ''PMTCT'' THEN ''YES'' ELSE ''NO'' END AS PMTCT

	INTO TempPharmacyA

	From mst_Patient m 
	INNER Join ord_PatientPharmacyOrder a On m.Ptn_Pk = a.Ptn_pk
	INNER join dtl_PatientPharmacyOrder b On a.ptn_pharmacy_pk = b.ptn_pharmacy_pk 
	INNER JOIN TempRegimenMap g ON a.ptn_pharmacy_pk = g.ptn_pharmacy_pk
	LEFT Join mst_Provider h On a.ProviderID = h.ID
	LEFT Join mst_Decode i On a.ProgID = i.ID
	LEFT Join mst_RegimenLine j On a.RegimenLine = j.ID
	Where 
	m.RegistrationDate <= a.DispensedByDate 
	Group By 
	m.Ptn_pk
	, a.VisitID
	, a.Ptn_Pharmacy_Pk
	, a.DispensedByDate
	, g.Regimen
	, j.Name
	, i.Name  
	, h.Name')

	EXEC('UPDATE TempPharmacyA SET TempPharmacyA.Regimen = B.lastRegimen FROM
	TempPharmacyA A INNER JOIN tempLastRegimens B ON A.Ptn_Pk = B.Ptn_Pk
	AND A.Ptn_Pharmacy_Pk >= B.lastRegimenStartPK')

	EXEC('Select  
	Pharmacy.PatientPK
	, Pharmacy.VisitID
	, Pharmacy.Drug
	, Pharmacy.Provider
	, Pharmacy.DispenseDate
	, Pharmacy.Duration
	, Pharmacy.ExpectedReturn
	, Pharmacy.TreatmentType
	, Pharmacy.RegimenLine
	, Pharmacy.PeriodTaken
	, Pharmacy.ProphylaxisType
	, Pharmacy.PMTCT
	INTO tmp_Pharmacy 

	FROM (
			Select  
			a.Ptn_pk PatientPK, 
			a.VisitID VisitID,   
			a.Regimen Drug,
			a.Provider Provider,
			a.dispenseDate DispenseDate, 
			Floor(a.duration) Duration,
			DATEADD(dd,Floor(a.duration),a.dispenseDate) ExpectedReturn,
			a.TreatmentType collate database_default TreatmentType,  
			a.RegimenLine RegimenLine,
			Null PeriodTaken,
			Null ProphylaxisType,
			a.PMTCT
			From 
			TempPharmacyA a 
			Where a.treatmentType IN (''PMTCT'',''PEP'',''ART'') And  
			  a.regimen Is Not Null
	UNION
	Select PatientPK, VisitID
	, Drug, NULL Provider, DispenseDate, Duration
	, ExpectedReturn
	, TreatmentType collate database_default TreatmentType
	, NULL RegimenLine, NULL PeriodTaken  
	, ProphylaxisType, NULL PMTCT FROM TempProphylaxis) Pharmacy')
	
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempPharmacyA'') DROP TABLE TempPharmacyA')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempRegimenMap'') DROP TABLE TempRegimenMap')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''tempLastRegimens'') DROP TABLE tempLastRegimens')
	EXEC('IF EXISTS (Select name FROM sys.tables where name = ''TempProphylaxis'') DROP TABLE TempProphylaxis') 

	Exec('CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_Pharmacy] ([PatientPK] ASC )
	WITH (PAD_INDEX  = OFF
	, STATISTICS_NORECOMPUTE  = OFF
	, SORT_IN_TEMPDB = OFF
	, IGNORE_DUP_KEY = OFF
	, DROP_EXISTING = OFF
	, ONLINE = OFF
	, ALLOW_ROW_LOCKS  = ON
	, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	 ')

END
go