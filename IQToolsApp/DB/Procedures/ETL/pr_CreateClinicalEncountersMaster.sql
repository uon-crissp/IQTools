IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateClinicalEncountersMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateClinicalEncountersMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateClinicalEncountersMaster]
AS
BEGIN

EXEC
('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_ClinicalEncounters'') AND type in (N''U''))
DROP TABLE tmp_ClinicalEncounters')

CREATE TABLE tmp_ClinicalEncounters 
(PatientPK INT NULL
, FacilityID INT NULL
, VisitID INT NULL
, VisitDate DATE NULL
, [Service] VARCHAR(100) NULL
, VisitType VARCHAR(100) NULL
, EncounterType VARCHAR(100) NULL
, WHOStage INT NULL
, Pregnant VARCHAR(100) NULL
, LMP DATE NULL
, EDD DATE NULL
, Height DECIMAL(18,1) NULL
, [Weight] DECIMAL(18,1) NULL
, BPS INT NULL
, BPD INT NULL
, Symptom VARCHAR(200) NULL
, SymptomCategory VARCHAR(200) NULL
, OI VARCHAR(200) NULL
, OIDate DATE NULL
, Adherence VARCHAR(100) NULL
, AdherenceCategory VARCHAR(100) NULL
, FamilyPlanningMethod VARCHAR(200) NULL
, NextAppointmentDate DATE NULL
, DataManagerName VARCHAR(200) NULL
, ClinicianName VARCHAR(200) NULL
, DataQuality INT NULL
, CreateDate DATE NULL
, UpdateDate DATE NULL
, VisitScheduled int null
, WABStage varchar (250) null
, BP varchar (21) null
, ClinicalAssessment varchar (100) null
, TherapyChangeReason varchar (100) null
, Comments varchar(max) null
, CommentsCategory varchar (100) null
, PwP varchar (100) null
, FeedingOption varchar (250) null
, Immunisation varchar (250) null
, GestationAge int null
, PMTCTMedication int null
, NextAppointmentReason varchar(100) null
, StabilityAssessment varchar(8) null
, DateStabilityAssessed date null
, ArtRefillModel varchar(37) null
, DifferentiatedCare varchar(200) null
, SubstitutionFirstlineRegimenDate date null
, SubstitutionFirstlineRegimenReason varchar(250) null
, SubstitutionSecondlineRegimenDate date null
, SubstitutionSecondlineRegimenReason varchar(250) null
, SecondlineRegimenChangeDate date null
, SecondlineRegimenChangeReason varchar(250) null
);

--Create Table tmp_IsPregnant
IF EXISTS(Select Name FROM sys.tables Where Name = N'tmp_IsPregnant')
DROP TABLE tmp_IsPregnant
EXEC('Create TABLE tmp_IsPregnant(Ptn_Pk int null, Visit_Pk int null
	, Pregnant Varchar(250) null
	, LMP Datetime NULL, EDD datetime NULL)')
IF EXISTS(Select Name FROM sys.synonyms WHERE Name = N'DTL_FBCUSTOMFIELD_02_Follow_Up_Form')
EXEC 
('INSERT INTO tmp_IsPregnant
Select a.Ptn_Pk, a.Visit_Pk
, d.Name Pregnant,
CASE
WHEN b.LMP = CAST('''' AS datetime) THEN NULL
ELSE b.LMP
END AS LMP,
CASE
WHEN b.EDD = CAST('''' AS datetime) THEN NULL
ELSE b.EDD
END AS EDD
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form a INNER JOIN
dtl_PatientClinicalStatus b ON a.Ptn_Pk = b.Ptn_Pk AND a.Visit_Pk = b.Visit_Pk
INNER JOIN ord_Visit c ON a.Ptn_Pk = c.Ptn_Pk AND a.Visit_Pk = c.Visit_id
INNER JOIN mst_ModDecode d ON a.Pregnancy = d.ID
Where  (c.DeleteFlag IS NULL OR c.DeleteFlag = 0)
AND a.Pregnancy > 0
')
EXEC('INSERT INTO tmp_IsPregnant
Select a.Ptn_Pk, a.Visit_Pk,
CASE
WHEN a.Pregnant = ''1''
OR a.Pregnant = ''89'' THEN ''Yes''
WHEN a.Pregnant = 91 Then ''No - Induced Abortion (ab)''
WHEN a.Pregnant = 92 Then ''No - Miscarriage (mc)''
WHEN a.Pregnant IS NULL THEN NULL
ELSE ''No''
END AS Pregnant,
CASE
WHEN a.LMP = CAST('''' AS datetime) THEN NULL ELSE a.LMP
END AS LMP,
CASE
WHEN a.EDD = CAST('''' AS datetime) THEN NULL	ELSE a.EDD
END AS EDD
FROM dtl_PatientClinicalStatus a INNER JOIN ord_Visit b 
ON a.Ptn_Pk = b.Ptn_Pk AND a.Visit_Pk = b.Visit_Id
Where  (b.DeleteFlag IS NULL OR b.DeleteFlag = 0)
AND a.Pregnant > 0
')
Exec('
CREATE CLUSTERED INDEX [IDX_IsPregnantCPK] ON 
[dbo].[tmp_IsPregnant] (Visit_Pk, Ptn_Pk ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
')
--Create tmp_OrdVisit
IF EXISTS(Select Name FROM sys.tables WHERE NAME = 'tmp_OrdVisit')
DROP TABLE tmp_OrdVisit
EXEC('Select a.Visit_Id 
, a.Ptn_pk
, a.LocationID
, a.VisitDate
, a.DataQuality
, a.UserID
, e.UserFirstName + '' '' + e.UserLastName DataManagerName 
, a.CreateDate
, a.UpdateDate
, Case WHEN b.VisitName LIKE ''%Enrollment%'' THEN 999 ELSE a.VisitType END AS VisitType
, b.VisitName
, COALESCE(f.FirstName, h.FirstName) + '' '' + COALESCE(f.LastName,h.LastName) ClinicianName
, CASE
WHEN d.ModuleName IN (''HIVCARE-STATICFORM'',
						''SMART ART FORM'',
						''HIV Care/ART Card (UG)'',
						''CCC Patient Card MoH 257'',
						''Comprehensive Care Clinic'',
						''TB Intensive Case Finding'') THEN ''ART''
WHEN d.ModuleName IN (''TB Module'',
						''T B'',
						''TB'',
						''TBModule'') THEN ''TB''
WHEN d.ModuleName IN (''PMTCT'',
						''ANC Maternity and Postnatal'') THEN ''PMTCT''
ELSE d.ModuleName
END AS [Service]
, CASE WHEN COALESCE(i.Name, j.Name) = ''TS - Treatment Supporter'' THEN ''Treatment Supporter''
ELSE ''Self'' END AS EncounterType
INTO tmp_OrdVisit

FROM 
ord_Visit a
LEFT JOIN mst_VisitType b ON a.VisitType = b.VisitTypeID
LEFT JOIN mst_Feature c ON Replace(b.VisitName, ''-'', ''_'') = c.FeatureName
LEFT JOIN mst_module d ON c.ModuleId = d.ModuleID
LEFT JOIN mst_User e ON a.UserID = e.UserID
LEFT JOIN mst_Employee f ON a.Signature = f.EmployeeID
LEFT JOIN dtl_PatientARTEncounter g ON a.Visit_Id = g.Visit_Id 
LEFT JOIN mst_employee h ON g.AttendingClinician = h.EmployeeID
LEFT JOIN mst_BlueDecode i ON a.TypeOfVisit = i.ID
LEFT JOIN mst_PMTCTDecode j ON a.TypeOfVisit = j.ID

Where 
(a.DeleteFlag = 0 OR a.DeleteFlag iS NULL)
AND a.VisitType NOT IN (0,4,5,6,12,18,19,101)
AND b.VisitName NOT IN (''Contact Tracking Form'')')
Exec('
CREATE CLUSTERED INDEX [IDX_VisitsCPK] ON 
[dbo].[tmp_OrdVisit] (Visit_Id, Ptn_Pk ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
')

--Create Table tmp_ICFSymptoms 
IF EXISTS(Select Name FROM sys.tables WHERE NAME = 'tmp_ICFSymptoms')
DROP TABLE tmp_ICFSymptoms
EXEC('CREATE TABLE tmp_ICFSymptoms
(ptn_pk INT NULL,visit_pk INT NULL, Symptom Varchar(250) NULL
,SymptomCategory  Varchar(250) NULL)')

IF EXISTS(Select Name FROM sys.synonyms Where Name = 'DTL_FBCUSTOMFIELD_Intensive_Case_Finding')
EXEC('INSERT INTO tmp_ICFSymptoms 
Select ptn_pk, visit_pk, Symptom, SymptomCategory   
FROM (SELECT n.ptn_pk,
n.visit_pk,
''Cough'' Symptom,
''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE n.Cough = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Fever'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE n.Fever = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Weight Loss'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE n.WeightLoss = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Sweat'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE n.Sweat = 1				   
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Contact TB'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE n.ContactTB = 1				  
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''No signs'' Symptom,
			''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_Intensive_Case_Finding n
WHERE (n.Cough = 0
OR n.Cough IS NULL)
AND (n.WeightLoss = 0
OR n.WeightLoss IS NULL)
AND (n.Sweat = 0
OR n.Sweat IS NULL)					
AND (n.ContactTB = 0
OR n.ContactTB IS NULL)				
AND (n.Fever = 0
OR n.Fever IS NULL)
UNION SELECT DISTINCT a.ptn_pk,
		a.Visit_pk,
		b.Name Symptom,
		''TB Screening'' SymptomCategory
FROM dtl_PatientOtherTreatment a
INNER JOIN mst_BlueDecode b ON a.TBStatus = b.ID
WHERE b.Name NOT IN (''Not Done'',
	''TB Rx'')				
) a')

IF EXISTS(Select Name FROM sys.synonyms Where Name = 'DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form')
EXEC(' INSERT INTO tmp_ICFSymptoms
Select ptn_pk, visit_pk, Symptom, SymptomCategory   
FROM (SELECT n.ptn_pk,
n.visit_pk,
''Cough'' Symptom,
''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE n.Cough = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Fever'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE n.Fever = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Weight Loss'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE n.WeightLoss = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Sweat'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE n.Sweat = 1				   
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Contact TB'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE n.ContactTB = 1
				  
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''No Signs'' Symptom,
			''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
WHERE (n.Cough = 0
OR n.Cough IS NULL)
AND (n.WeightLoss = 0
OR n.WeightLoss IS NULL)
AND (n.Sweat = 0
OR n.Sweat IS NULL)					
AND (n.ContactTB = 0
OR n.ContactTB IS NULL)					
AND (n.Fever = 0
OR n.Fever IS NULL)
UNION 
SELECT n.ptn_pk,
n.visit_pk,
b.Name Symptom,						  
''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form n
INNER JOIN mst_ModDeCode b ON n.TBFindings = b.ID
WHERE n.TBFindings IS NOT NULL
AND b.Name NOT IN (''Not Done'',
	''TB Rx'')			
) a')

IF EXISTS(Select Name FROM sys.synonyms Where Name = 'DTL_FBCUSTOMFIELD_02_Follow_Up_Form')
EXEC(' INSERT INTO tmp_ICFSymptoms
Select ptn_pk, visit_pk, Symptom, SymptomCategory   
FROM (SELECT n.ptn_pk,
n.visit_pk,
''Cough'' Symptom,
''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE n.Cough = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Fever'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE n.Fever = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Weight Loss'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE n.WeightLoss = 1
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Sweat'' Symptom,
				''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE n.Sweat = 1				   
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''Contact TB'' Symptom,
					''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE n.ContactTB = 1
				  
UNION SELECT DISTINCT n.ptn_pk,
		n.visit_pk,
		''No Signs'' Symptom,
			''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
WHERE (n.Cough = 0
OR n.Cough IS NULL)
AND (n.WeightLoss = 0
OR n.WeightLoss IS NULL)
AND (n.Sweat = 0
OR n.Sweat IS NULL)
					
AND (n.ContactTB = 0
OR n.ContactTB IS NULL)
					
AND (n.Fever = 0
OR n.Fever IS NULL)
UNION 
SELECT n.ptn_pk,
n.visit_pk,
b.Name Symptom,						  
''TB Screening'' SymptomCategory
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form n
INNER JOIN mst_ModDeCode b ON n.TBFindings = b.ID
WHERE n.TBFindings IS NOT NULL
AND b.Name NOT IN (''Not Done'',
	''TB Rx'')			
) a')

--//IQCare 4.0 Clinical Encounter

IF EXISTS(Select Name FROM sys.synonyms WHERE NAME = 'dtl_Multiselect_line')
EXEC('INSERT INTO tmp_ICFSymptoms
 SELECT Ptn_pk  
  ,Visit_Pk 
  , b.Name Symptom
  , ''TB Screening''
 FROM dtl_Multiselect_line a  INNER JOIN mst_Decode b ON a.ValueID = b.ID
 WHERE FieldName IN (''TBAssessmentICF'')  
  AND (a.DeleteFlag IS NULL  OR a.DeleteFlag = 0)')

Exec('CREATE CLUSTERED INDEX [IDX_ICFCPK] ON 
[dbo].[tmp_ICFSymptoms] (visit_pk, Ptn_Pk ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
')

--Create Table tmp_tempAppointments
IF EXISTS(Select Name FROM sys.tables WHERE NAME = N'tmp_tempAppointments')
DROP TABLE tmp_tempAppointments
EXEC('Create Table tmp_tempAppointments(Ptn_Pk int null, Visit_Pk int null
, AppDate datetime null)')
IF EXISTS(Select Name FROM sys.synonyms Where Name = 'DTL_FBCUSTOMFIELD_02_Follow_Up_Form')
EXEC('INSERT INTO tmp_tempAppointments
Select a.Ptn_Pk, a.Visit_Pk, MAX(a.NextAppointmentDate) NextAppointmentDate
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form a 
INNER JOIN ord_Visit c ON a.Ptn_Pk = c.Ptn_Pk AND a.Visit_Pk = c.Visit_id
Where  (c.DeleteFlag IS NULL OR c.DeleteFlag = 0)
AND a.NextAppointmentDate >= c.VisitDate
GROUP BY a.Ptn_Pk, a.Visit_Pk
')
EXEC('INSERT INTO tmp_tempAppointments
Select a.Ptn_pk, a.Visit_Pk, MAX(a.AppDate) AppDate 
FROM dtl_PatientAppointment a INNER JOIN ord_Visit b ON a.Visit_Pk = b.Visit_ID  
Where (a.DeleteFlag = 0 Or a.DeleteFlag IS NULL) AND a.AppDate >= b.VisitDate
GROUP BY a.Ptn_Pk, a.Visit_Pk
')
EXEC('
CREATE CLUSTERED INDEX [IDX_APPCPK] ON 
[dbo].[tmp_tempAppointments] (visit_pk, Ptn_Pk ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
')
--Create Table tmp_tempFP
IF EXISTS(Select Name FROM sys.tables Where Name = N'tmp_tempFP')
DROP TABLE tmp_tempFP
EXEC('Create Table tmp_tempFP(Ptn_Pk int null, Visit_Pk int null, FPMethod Varchar(250) null)')
IF EXISTS (Select Name FROM sys.synonyms Where Name = N'DTL_FBCUSTOMFIELD_02_Follow_Up_Form')
EXEC('INSERT INTO tmp_tempFP
Select a.Ptn_Pk, a.Visit_Pk, e.Name  FamilyPlanningMethod
FROM DTL_FBCUSTOMFIELD_02_Follow_Up_Form a 
INNER JOIN ord_Visit c ON a.Ptn_Pk = c.Ptn_Pk AND a.Visit_Pk = c.Visit_id
LEFT JOIN mst_ModDeCode d ON a.FamilyPlanning = d.ID
LEFT JOIN mst_ModDeCode e ON a.OnFPWantsFP = e.ID
Where  (c.DeleteFlag IS NULL OR c.DeleteFlag = 0)
AND e.Name IS NOT NULL')
EXEC('INSERT INTO tmp_tempFP
Select a.Ptn_Pk, a.Visit_Id, b.Name FamilyPlanningMethod 
FROM dtl_patientFamilyPlanning a INNER JOIN 
mst_BlueDecode b ON a.FamilyPlanningMethod = b.ID
INNER JOIN ord_Visit c ON a.Ptn_Pk = c.Ptn_Pk AND a.Visit_Id = c.Visit_id
Where  (c.DeleteFlag IS NULL OR c.DeleteFlag = 0)')
EXEC('
CREATE CLUSTERED INDEX [IDX_FPCPK] ON 
[dbo].[tmp_tempFP] (visit_pk, Ptn_Pk ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
')

--Create Table tmp_ClinicalEncounters
EXEC('
INSERT INTO tmp_ClinicalEncounters
 SELECT 
DISTINCT 
a.Ptn_Pk PatientPK,
a.LocationID FacilityID,
a.Visit_Id VisitID,
a.VisitDate,
a.[Service] ,
a.VisitName VisitType,
a.EncounterType,
CASE
WHEN d2.Name IN (''1'',
		''I'',
		''T1'') THEN 1
WHEN d2.Name IN (''2'',
		''II'',
		''T2'') THEN 2
WHEN d2.Name IN (''3'',
		''III'',
		''T3'') THEN 3
WHEN d2.Name IN (''4'',
		''IV'',
		''T4'') THEN 4
ELSE NULL
END AS WHOStage,
c.Pregnant,
c.LMP,
c.EDD,
Case WHEN o.Height = 0 THEN NULL ELSE o.Height END AS Height ,
Case WHEN o.[Weight] = 0 THEN NULL ELSE o.[Weight] END AS [Weight] 
, o.bpsystolic BPS
, o.BPDiastolic BPD
, COALESCE(ICFSymptoms.Symptom collate database_default,d7.Name) Symptom,
COALESCE(ICFSymptoms.SymptomCategory collate database_default, d8.SymptomCategoryName) AS SymptomCategory,
CASE WHEN COALESCE(d3Blue.Name, d3.Name) LIKE ''%none%'' 
OR COALESCE(d3Blue.Name, d3.Name) LIKE ''%Not Documented%'' THEN NULL
WHEN Tb.Ptn_pk is not Null Then ''TB''
ELSE COALESCE(d3Blue.Name, d3.Name) END AS OI,
CASE WHEN (COALESCE(d3Blue.Name, d3.Name) LIKE ''%none%'' 
OR COALESCE(d3Blue.Name, d3.Name) LIKE ''%Not Documented%''
OR COALESCE(d3Blue.Name, d3.Name) is null) And Tb.Ptn_Pk is null THEN NULL
When Tb.TBRxStartDate Is not null then TBRxStartDate
ELSE a.VisitDate END AS  OIDate,
Adherence.Adherence,
Adherence.AdherenceCategory,
r.FPMethod FamilyPlanningMethod, 
i.AppDate NextAppointmentDate,
a.DataManagerName,
a.ClinicianName,
a.DataQuality,
a.CreateDate,
a.UpdateDate			
, null as VisitScheduled
, null as WABStage
, null as BP
, null as ClinicalAssessment
, null as TherapyChangeReason
, null as Commments
, null as CommentsCategory
, null as PWP
, null as FeedingOption
, null as Immunisation
, null as GestationAge
, null as PMTCTMedication
, null as NextAppointmentReason
, null as StabilityAssessment
, null as DateStabilityAssessed
, null as ArtRefillmodel
, null as DifferentiatedCare
, null as SubstitutionFirstlineRegimenDate
, null as SubstitutionFirstlineRegimenReason
, null as SubstitutionSecondlineRegimenDate
, null as SubstitutionSecondlineRegimenReason
, null as SecondlineRegimenChangeDate
, null as SecondlineRegimenChangeReason				
				
FROM tmp_OrdVisit a
LEFT JOIN tmp_IsPregnant c ON a.Visit_Id = c.Visit_pk and a.Ptn_pk = c.Ptn_pk
LEFT JOIN dtl_PatientStage d ON a.Visit_Id = d.Visit_Pk and a.Ptn_pk = d.Ptn_pk
LEFT JOIN mst_Decode d2 ON d.WHOStage = d2.ID
LEFT JOIN dtl_PatientDisease e ON a.Visit_Id = e.Visit_Pk and a.Ptn_pk = e.Ptn_pk
LEFT JOIN mst_HivDisease d3 ON e.Disease_Pk = d3.ID
LEFT JOIN mst_BlueDecode d3Blue ON e.Disease_Pk = d3Blue.ID	AND d3Blue.CodeID = 4
LEFT JOIN (Select Ptn_pk, Visit_pk, TBRxStartDate From dtl_PatientOtherTreatment Where TBStatus = 3) Tb 
On a.ptn_pk = Tb.ptn_pk and a.visit_id = Tb.visit_pk
LEFT JOIN dtl_PatientAssessment f ON a.Visit_Id = f.Visit_pk and a.Ptn_pk = f.Ptn_pk
LEFT JOIN mst_Assessment d4 ON f.AssessmentID = d4.AssessmentID
LEFT JOIN dtl_PatientSymptoms h ON a.Visit_Id = h.Visit_pk and a.Ptn_pk = h.Ptn_pk
LEFT JOIN mst_Symptom d7 ON h.SymptomID = d7.ID
LEFT JOIN mst_SymptomCategory d8 ON d7.CategoryID = d8.SymptomCategoryID
LEFT JOIN tmp_tempAppointments i ON a.Visit_Id = i.Visit_pk and a.Ptn_pk = i.Ptn_pk					
LEFT JOIN dtl_PatientAllergy j ON a.Visit_Id = j.Visit_Pk and a.Ptn_pk = j.Ptn_pk
LEFT JOIN mst_Decode d10 ON j.AllergyID = d10.ID					
LEFT JOIN dtl_PatientVitals o ON a.Visit_Id = o.Visit_pk and a.Ptn_pk = o.Ptn_pk
LEFT JOIN tmp_tempFP r ON a.Visit_Id = r.visit_Pk and a.Ptn_pk = r.Ptn_pk
LEFT JOIN (Select t.ptn_pk, t.visit_pk, u.Name Adherence, ''ARV Adherence'' AdherenceCategory From 
dtl_PatientAdherence t 
Inner Join mst_Adherence u on t.ARVAdhere = u.ID
)Adherence on a.visit_id = Adherence.visit_pk and a.Ptn_pk = Adherence.Ptn_pk
LEFT JOIN tmp_ICFSymptoms  ICFSymptoms ON a.visit_id = ICFSymptoms.visit_pk and a.Ptn_pk = ICFSymptoms.Ptn_pk
WHERE a.VisitType < 999')
--Drop Temp Tables
IF EXISTS(Select Name FROM sys.tables WHERE NAME = N'tmp_OrdVisit')
DROP TABLE tmp_OrdVisit
IF EXISTS(Select Name FROM sys.tables WHERE NAME = N'tmp_ICFSymptoms')
DROP TABLE tmp_ICFSymptoms
IF EXISTS(Select Name FROM sys.tables WHERE NAME = N'tmp_tempAppointments')
DROP TABLE tmp_tempAppointments
IF EXISTS(Select Name FROM sys.tables Where Name = N'tmp_IsPregnant')
DROP TABLE tmp_IsPregnant
IF EXISTS(Select Name FROM sys.tables Where Name = N'tempIE')
DROP TABLE tempIE
IF EXISTS(Select Name FROM sys.tables Where Name = N'tempOIs')
DROP TABLE tempOIs
IF EXISTS(Select Name FROM sys.tables Where Name = N'tmp_tempFP')
DROP TABLE tmp_tempFP
EXEC('
CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_ClinicalEncounters] ([PatientPK] ASC )
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