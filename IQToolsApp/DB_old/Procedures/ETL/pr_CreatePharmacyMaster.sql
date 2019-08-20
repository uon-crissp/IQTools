IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePharmacyMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreatePharmacyMaster]
GO

CREATE Proc [dbo].[pr_CreatePharmacyMaster]

As

Begin
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_Pharmacy'') AND type in (N''U''))
	DROP TABLE tmp_Pharmacy')

	EXEC('
	select * into tmp_Pharmacy 
	from
	(
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

	Select Distinct a.Ptn_pk PatientPK
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

	UNION

	Select DISTINCT a.Ptn_Pk
	, c.VisitID
	, coalesce(f.RegimenCode +'' - ''+ f.RegimenName, e.DrugAbbreviation) GenericAbbrevation
	, '''' as Provider
	, c.DispensedByDate DispenseDate
	, d.duration
	, DATEADD(dd,d.Duration, c.DispensedByDate) ExpectedReturn
	, case when g.[name] like ''%Prophylaxis%'' then '''' else ''ART'' end TreatmentType
	, g.[name] RegimenLine
	, Null PeriodTaken
	, null ProphylaxisType
	, NULL PMTCT
	FROM mst_Patient a
	INNER JOIN ord_Visit b ON a.Ptn_Pk = b.Ptn_Pk
	INNER JOIN ord_PatientPharmacyOrder c ON a.Ptn_Pk = c.Ptn_pk AND b.Visit_Id = c.VisitID
	INNER JOIN dtl_PatientPharmacyOrder d ON c.ptn_pharmacy_pk = d.ptn_pharmacy_pk
	INNER JOIN mst_Drug e ON d.Drug_Pk = e.Drug_pk
	INNER JOIN mst_DrugType i ON e.DrugType = i.DrugTypeID
	left join mst_Regimen f on c.RegimenId=f.RegimenID
	left join mst_regimenline g on f.regimenlineid = g.id
	Where (a.DeleteFlag = 0 Or a.DeleteFlag IS NULL)
	AND (b.DeleteFlag = 0 OR b.DeleteFlag IS NULL)
	AND (c.DeleteFlag = 0 OR c.DeleteFlag IS NULL)
	AND i.DrugTypeName = ''ARV Medication''
	And c.DispensedByDate IS NOT NULL
	and g.[name] not like ''%oi%''
	) a
	 ')

END
go