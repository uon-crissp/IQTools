IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateIQToolsViews]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreateIQToolsViews]
GO

CREATE Proc [dbo].[pr_CreateIQToolsViews]
As
Begin

/****** Object:  View [dbo].[IQC_SiteDetails]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_SiteDetails]'))
DROP VIEW [dbo].[IQC_SiteDetails]
/****** Object:  View [dbo].[IQC_SiteDetails]    Script Date: 3/14/2016 12:58:47 PM ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_SiteDetails]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[IQC_SiteDetails] AS
		SELECT f.FacilityID ,
		Case WHEN LEN(f.SatelliteID) <= 3 THEN CAST(f.CountryID+f.PosID AS VARCHAR(10)) ELSE
		cast(f.SatelliteID as varchar(10)) END AS
		   SiteCode ,
		   f.FacilityName ,
		   NULL FacilityOwner ,
		   NULL ImplementingPartner ,
		   f.CountryID ,
		   CASE
			   WHEN f.CountryID = 648 THEN ''Kenya''
			   ELSE NULL
		   END AS Country ,
		   prov.Province Region ,
		   dist.District ,
		   f.PepFarStartDate
	FROM mst_Facility f,
	  (SELECT Top 1 IsNull(b.Name, ''Unknown'') Province,
					COUNT(b.Name) n
	   FROM mst_patient a
	   LEFT JOIN mst_Province b ON a.Province = b.ID
	   GROUP BY b.Name
	   ORDER BY Count(b.Name) DESC) prov,
	  (SELECT Top 1 IsNull(b.Name, ''Unknown'') District,
					COUNT(b.Name) n
	   FROM mst_patient a
	   LEFT JOIN mst_district b ON a.DistrictName = b.ID
	   GROUP BY b.Name
	   ORDER BY Count(b.Name) DESC) dist
	WHERE f.FacilityID IN
		(SELECT DISTINCT mst_Patient.LocationID
		 FROM mst_Patient WHERE DeleteFlag IS NULL OR DeleteFlag = 0)
		 ' 

IF EXISTS (Select * FROM IQC_SiteDetails WHERE FacilityName = 'St.Elizabeth Lwak Mission Health Centre')
Begin

EXEC('IF EXISTS (Select name from sys.views Where name = ''IQC_0026a'')
DROP VIEW IQC_0026a')

EXEC('CREATE VIEW IQC_0026a AS
Select b.Ptn_Pk
, a.PatientEnrollmentID As ID
, a.PatientClinicID As [Exisiting Hospital Clinic #]
, Gender = (Select Name From mst_Decode b Where a.Sex = b.ID)
, a.DOB As [Date Of Birth]
, Case  When c.PrevHIVCare = 1 Then ''Yes'' Else Case       
		When c.PrevHIVCare = 0 Then ''No'' End   
End As [Prior HIV Care]
, Referral = (Select Name From mst_Decode b Where a.ReferredFrom = b.ID) 
,   e.DateHIVDiagnosis, d.IEDate
,   f.CurrentARTStartDate,   f.longTermMedsOther1Desc
,   f.longTermMedsOther2Desc,   f.longTermMedsOther3desc
,   f.longTermTBMed,   f.longTermTBStartDate
,   f.longTermMedsSulfa,   f.PrevSingleDoseNVP
,   f.PrevSingleDoseNVPDate1,   f.PrevLowestCD4
,   f.PrevLowestCD4Percent,   f.PrevLowestCD4Date
,   f.PrevMostRecentCD4
,   f.PrevMostRecentCD4Percent,   f.PrevMostRecentCD4Date,   f.PrevARVsCD4
,   f.PrevARVsCD4Percent,   f.PrevARVsCD4Date
,   f.PrevMostRecentViralLoad,   f.PrevMostRecentViralLoadDate
,   f.PrevARVRegimen,   f.PrevARVRegimenMonths
,   f.PrevARVRegimen1Name,   f.PrevARVRegimen1Months
,   f.PrevARVRegimen1Current
,   f.PrevARVRegimen2Name,   f.PrevARVRegimen2Months
,   f.PrevARVRegimen2Current,   f.PrevARVRegimen3Name
,   f.PrevARVRegimen3Months
,   f.PrevARVRegimen3Current,   f.PrevARVRegimen4Name
,   f.PrevARVRegimen4Months,   f.PrevARVRegimen4Current, h.Name
,   b.DSSID 
From dtl_CustomField_Patient_Enrollment b 
Inner Join  mst_patient a On b.Ptn_pk = a.Ptn_Pk   
Left Join   dtl_PatientHivPrevCareEnrollment c On b.Ptn_Pk = c.ptn_pk 
Left Join   (Select 
Distinct 
ptn_pk
, Min(ord_visit.VisitDate) As IEDate
, Min(ord_visit.Visit_Id) As VisitID From 
  ord_visit 
Where (ord_visit.DeleteFlag Is Null Or ord_visit.DeleteFlag = 0) 
And   ord_visit.VisitType = 1 
Group By ptn_pk) d On a.Ptn_Pk = d.Ptn_Pk 
Left Join   dtl_PatientClinicalStatus e On d.VisitID = e.Visit_pk 
And d.Ptn_Pk = e.Ptn_pk 
Left Join   dtl_PatientHivPrevCareIE f On a.Ptn_Pk = f.Ptn_pk   
Left Join   dtl_PatientDisease g On d.Ptn_Pk = g.Ptn_Pk 
And d.VisitID =     g.Visit_Pk 
Left Join   mst_HivDisease h On g.Disease_Pk = h.ID 
Where b.DSSID <> ''''')



EXEC('IF EXISTS (Select name from sys.views Where name = ''IQC_0026b'')
DROP VIEW IQC_0026b')


EXEC('CREATE VIEW IQC_0026b AS 
SELECT LTrim(RTrim(a.DSSID)) AS DSSID ,
       b.Ptn_Pk,
       b.PatientEnrollmentID AS ID,
       o.VisitDate ,
       c.Pregnant,
       g.Name AS [Therapy Plan] ,
       i.AssessmentName,
       j.ART_Client_recently_diagnosed_with_TB ,
       j.ART_Type_of_TB,
       j.ART_TB_Therapy_Start_Date ,
       j.ART_TB_Therapy_End_Date,
       j.ART_TB_Regimen ,
       k.NonART_Client_recently_diagnosed_with_TB ,
       k.NonART_Type_of_TB,
       k.NonART_TB_Therapy_Start_Date ,
       k.NonART_TB_Therapy_End_Date,
       k.NonART_TB_Regimen ,
       l.MissedLastWeek,
       l.MissedLastMonth,
       l.MissedReasonOther ,
       l.NumDOTPerWeek,
       l.NumHomeVisitsPerWeek ,
       CASE
           WHEN l.SupportGroup = 0 THEN ''No''
           ELSE CASE
                    WHEN l.SupportGroup = 1 THEN ''Yes''
                END
       END AS [Support Group] ,
       l.InterruptedDate,
       l.InterruptedNumDays ,
       l.StoppedDate,
       l.StoppedNumDays ,
       CASE
           WHEN l.HerbalMeds = 0 THEN ''No''
           ELSE CASE
                    WHEN l.HerbalMeds = 1 THEN ''Yes''
                END
       END AS [Herbal Meds] ,
       CASE
           WHEN n.CategoryName LIKE ''%Adherence%'' THEN m.Name
       END AS [Reason for non-Adherence],
       CASE
           WHEN s.SymptomCategoryName LIKE ''%ARV%'' THEN r.Name
       END AS [ARV Side Effects],
       CASE
           WHEN s2.SymptomCategoryName LIKE ''%Complaints%'' THEN e.Name
       END AS [Presenting Complaints]
FROM dtl_CustomField_Patient_Enrollment a
INNER JOIN mst_Patient b ON a.Ptn_pk = b.Ptn_Pk
INNER JOIN ord_Visit o ON b.Ptn_Pk = o.Ptn_Pk
LEFT JOIN dtl_PatientClinicalStatus c ON o.Visit_Id = c.Visit_pk
AND o.Ptn_Pk = c.Ptn_pk
LEFT JOIN dtl_PatientSymptoms d ON o.Visit_Id = d.Visit_pk
AND o.Ptn_Pk = d.Ptn_pk
LEFT JOIN mst_Symptom e ON d.SymptomID = e.ID
LEFT JOIN dtl_PatientArvTherapy f ON o.Ptn_Pk = f.ptn_pk
AND o.Visit_Id = f.Visit_pk
LEFT JOIN mst_Decode g ON f.TherapyPlan = g.ID
LEFT JOIN dtl_PatientAssessment h ON o.Visit_Id = h.Visit_pk
AND o.Ptn_Pk = h.Ptn_pk
LEFT JOIN mst_Assessment i ON h.AssessmentID = i.AssessmentID
LEFT JOIN dtl_CustomField_ART_Follow_up j ON o.Visit_Id = j.Visit_pk
AND o.Ptn_Pk = j.Ptn_pk
LEFT JOIN dtl_CustomField_Non_ART_Follow_up k ON o.Visit_Id = k.Visit_pk
AND o.Ptn_Pk = k.Ptn_pk
LEFT JOIN dtl_PatientAdherence l ON o.Ptn_Pk = l.ptn_pk
AND o.Visit_Id = l.Visit_Pk
LEFT JOIN mst_Reason m ON l.MissedReason = m.ID
LEFT JOIN mst_ReasonCategory n ON m.CategoryID = n.CategoryID
LEFT JOIN mst_VisitType p ON o.VisitType = p.VisitTypeID
LEFT JOIN mst_AssessmentCategory q ON i.AssessmentCategoryID = q.AssessmentCategoryID
LEFT JOIN mst_Symptom r ON d.SymptomID = r.ID
LEFT JOIN mst_SymptomCategory s ON r.CategoryID = s.SymptomCategoryID
LEFT JOIN mst_SymptomCategory s2 ON e.CategoryID = s2.SymptomCategoryID
WHERE (LTrim(RTrim(a.DSSID)) IS NOT NULL
       AND LTrim(RTrim(a.DSSID)) <> '''')
  AND (p.VisitName IS NULL
       OR p.VisitName LIKE ''%Follow-Up%'')
  AND (q.AssessmentCategoryName IS NULL
       OR q.AssessmentCategoryName LIKE ''%Follow-Up%'')')

EXEC('IF EXISTS (Select name from sys.views Where name = ''IQC_0026c'')
DROP VIEW IQC_0026c')

EXEC('CREATE VIEW IQC_0026c AS
Select b.Ptn_Pk
, b.PatientEnrollmentID As ID
, LPTF = (Select Top 1 FacilityName From mst_Facility Where DeleteFlag = 0)
, b.PatientClinicID As [Exisitng Hospital #]
, Case When c.TestName Like ''%India%'' Or     c.TestName Like ''%Crypto%'' Then c.TestName   End As [CSF Labs]
, Case When c.TestName Like ''%Sputum%'' Then c.TestName   End As [Sputum Labs]
, Case When c.TestName Like ''%CD4%'' Or     c.TestName Like ''%Viral Load%'' Then c.TestName  End As [ARV Labs]
, Case When c.TestName Like ''%India%'' Or     c.TestName Like ''%Crypto%'' Or c.TestName Like ''%Sputum%''   
Or c.TestName Like ''%CD4%'' Or c.TestName Like ''%Viral Load%'' Then c.TestResult   End As [Test Results]
, c.OrderedbyDate,   RTrim(LTrim(a.DSSID)) As DSSID 

From dtl_CustomField_Patient_Enrollment a 
Inner Join mst_Patient b On a.Ptn_pk = b.Ptn_Pk   
Inner Join tmp_Labs c On b.Ptn_Pk = c.PatientPK
Where RTrim(LTrim(a.DSSID)) <> ''''
And Case When c.TestName Like ''%India%'' 
Or c.TestName Like ''%Crypto%'' 
Or c.TestName Like ''%Sputum%''   
Or c.TestName Like ''%CD4%'' 
Or c.TestName Like ''%Viral Load%'' Then c.TestResult End Is Not Null
')


EXEC('IF EXISTS (Select name from sys.views Where name = ''IQC_0026d'')
DROP VIEW IQC_0026d')

EXEC('CREATE VIEW IQC_0026d AS
Select Distinct LTrim(RTrim(a.DSSID)) As DSSID
, a.Ptn_Pk
, Case When c.DrugType = ''ARV Medication'' Then c.DrugName End As [ARV Medications]
, Case When c.DrugType <> ''ARV Medication'' Then c.DrugName End As [OI Medications]
, c.DispensedByDate, c.Duration As   [Drugs for X Days]
, c.DrugName
, b.ageLastVisit
, c.DispensedQuantity
, d.PatientEnrollmentID As ID 
From dtl_CustomField_Patient_Enrollment a 
Inner Join tmp_PatientMaster b On a.Ptn_pk = b.PatientPK 
Inner Join mst_patient d On a.Ptn_pk = d.Ptn_Pk 
Inner Join   
(Select a.Ptn_pk, a.DrugType, a.Duration, a.DispensedByDate
, a.VisitID, a.DrugName, a.DispensedQuantity, a.ptn_pharmacy_pk 
From VW_PatientPharmacy a) c On b.PatientPK = c.Ptn_Pk 
Where b.ageLastVisit >= 15 And (LTrim(RTrim(a.DSSID)) <> '''')')

EXEC('IF EXISTS (Select name from sys.views Where name = ''IQC_0026e'')
DROP VIEW IQC_0026e')

EXEC('CREATE VIEW IQC_0026e AS
Select Distinct LTrim(RTrim(a.DSSID)) As DSSID
, a.Ptn_Pk
, Case When c.DrugType = ''ARV Medication'' Then c.DrugName End As [ARV Medications]
, Case When c.DrugType <> ''ARV Medication'' Then c.DrugName End As [OI Medications]
, c.DispensedByDate, c.Duration As   [Drugs for X Days]
, c.DrugName
, b.ageLastVisit
, c.DispensedQuantity
, d.PatientEnrollmentID As ID 
From dtl_CustomField_Patient_Enrollment a 
Inner Join tmp_PatientMaster b On a.Ptn_pk = b.PatientPK 
Inner Join mst_patient d On a.Ptn_pk = d.Ptn_Pk 
Inner Join   
(Select a.Ptn_pk, a.DrugType, a.Duration, a.DispensedByDate
, a.VisitID, a.DrugName, a.DispensedQuantity, a.ptn_pharmacy_pk 
From VW_PatientPharmacy a) c On b.PatientPK = c.Ptn_Pk 
Where b.ageLastVisit < 15 And (LTrim(RTrim(a.DSSID)) <> '''')')


End

/****** Object:  View [dbo].[IQC_m6CD4]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_m6CD4]'))
DROP VIEW [dbo].[IQC_m6CD4]

/****** Object:  View [dbo].[IQC_m12CD4]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_m12CD4]'))
DROP VIEW [dbo].[IQC_m12CD4]

/****** Object:  View [dbo].[IQC_lastWHO]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastWHO]'))
DROP VIEW [dbo].[IQC_lastWHO]

/****** Object:  View [dbo].[IQC_lastWAB]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastWAB]'))
DROP VIEW [dbo].[IQC_lastWAB]

/****** Object:  View [dbo].[IQC_lastCD4]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastCD4]'))
DROP VIEW [dbo].[IQC_lastCD4]

/****** Object:  View [dbo].[IQC_eWHO]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eWHO]'))
DROP VIEW [dbo].[IQC_eWHO]

/****** Object:  View [dbo].[IQC_eWAB]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eWAB]'))
DROP VIEW [dbo].[IQC_eWAB]

/****** Object:  View [dbo].[IQC_eCD4]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eCD4]'))
DROP VIEW [dbo].[IQC_eCD4]

/****** Object:  View [dbo].[IQC_bWHO]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bWHO]'))
DROP VIEW [dbo].[IQC_bWHO]

/****** Object:  View [dbo].[IQC_bWAB]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bWAB]'))
DROP VIEW [dbo].[IQC_bWAB]

/****** Object:  View [dbo].[IQC_bCD4]    Script Date: 3/14/2016 12:58:47 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bCD4]'))
DROP VIEW [dbo].[IQC_bCD4]

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_FirstVL]'))
DROP VIEW [dbo].[IQC_FirstVL]

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_LastVL]'))
DROP VIEW [dbo].[IQC_LastVL]

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_AllVL]'))
DROP VIEW [dbo].[IQC_AllVL]

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_AdverseEvents]'))
DROP VIEW [dbo].IQC_AdverseEvents

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bWAB]'))
DROP VIEW [dbo].IQC_bWAB

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eWAB]'))
DROP VIEW [dbo].IQC_eWAB

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastWAB]'))
DROP VIEW [dbo].IQC_lastWAB

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_AllVL]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_AllVL] as 
SELECT PatientPK, VLOrderDate, VLReportDate
, FLOOR(CASE WHEN VLResult = '''' THEN NULL ELSE VLResult END) AS VLResult
FROM (
Select PatientPK, OrderedByDate VLOrderDate, ReportedByDate VLReportDate
, REPLACE(REPLACE(
	REPLACE(
		REPLACE(
			REPLACE(TestResult,''copies/ml'',''''),''>'',''''),''<'',''''),''O'',''0''),''failed'','''') VLResult
FROM tmp_Labs
Where TestName LIKE ''%Viral%'') a
WHERE ISNUMERIC(VLResult) = 1'

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_FirstVL]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_FirstVL] as 

Select a.PatientPK
, MAX(b.FirstVLDate) FirstVLDate
, MAX(a.TestResult) FirstVL FROM tmp_Labs a INNER JOIN
(Select PatientPK, MIN(OrderedByDate) FirstVLDate
FROM tmp_Labs
Where TestName LIKE ''%Viral%''
AND TestResult IS NOT NULL
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.OrderedbyDate = b.FirstVLDate
WHERE TestName LIKE ''%Viral%''
GROUP BY a.PatientPK'

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_LastVL]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_LastVL] as
Select a.PatientPK
, MAX(b.LastVLDate) LastVLDate
, MAX(a.TestResult) LastVL FROM tmp_Labs a INNER JOIN
(Select PatientPK, MAX(OrderedByDate) LastVLDate
FROM tmp_Labs
Where TestName LIKE ''%Viral%''
AND TestResult IS NOT NULL
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.OrderedbyDate = b.LastVLDate
WHERE TestName LIKE ''%Viral%''
GROUP BY a.PatientPK'

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bCD4]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_bCD4] as 
Select Distinct a.PatientPK

, a.FacilityID
,    Max(Cast(Floor(a.TestResult) As int)) bCD4
, b.bCD4Date  
From TMP_Labs a 
Inner Join    
(Select a.PatientPK
, Max(a.ReportedbyDate) bCD4Date      
From TMP_Labs a      
Where a.TestName Like ''CD4%'' 
And a.baselineTest = 0      
Group By a.PatientPK) 
b On a.PatientPK = b.PatientPK 
And a.ReportedbyDate =      
b.bCD4Date  
Where a.TestName Like ''CD4%''  
Group By a.PatientPK
, a.FacilityID
, b.bCD4Date

' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bWHO]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_bWHO] as 
With IQC_allWHO as 
(Select a.PatientPK, Min(a.VisitDate) WHODate


 , Cast(a.WHOStage As int) WHOStage
 , Case When DateDiff(dd, m.registrationDate, a.VisitDate) <= 60 Then 1 Else 0
  End As enrollmentTest, Case
    When DateDiff(dd, c.startARTDate, a.VisitDate) Between -90 And 14 Then 1
    Else 0 End As baselineTest
From tmp_ClinicalEncounters a Inner Join
  tmp_patientmaster m On a.PatientPK = m.PatientPK Left Join
  tmp_ARTPatients c On a.PatientPK = c.PatientPK
Where a.WHOStage Is Not Null
Group By a.PatientPK, m.registrationDate, c.startARTDate, a.WHOStage, a.VisitDate)

Select c.PatientPK, Max(c.WHOStage) bWHO, d.bWHODate
From IQC_allWHO c Inner Join
  (Select IQC_allWHO.PatientPK, Min(IQC_allWHO.WHODate) bWHODate
    From IQC_allWHO
    Where IQC_allWHO.baselineTest = 1
    Group By IQC_allWHO.PatientPK) d On c.PatientPK = d.PatientPK And
    c.WHODate = d.bWHODate
Group By c.PatientPK, d.bWHODate' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eCD4]'))
EXEC dbo.sp_executesql @statement = N'CREATE view [dbo].[IQC_eCD4] as 
Select Distinct a.PatientPK

, a.FacilityID
,    Max(Cast(Floor(a.TestResult) As int)) eCD4
, b.eCD4Date  
From tmp_Labs a Inner Join    (Select a.PatientPK, Max(a.ReportedbyDate) eCD4Date      
From tmp_Labs a      Where a.TestName = ''CD4'' And a.enrollmentTest = 1      
Group By a.PatientPK) b 
On a.PatientPK = b.PatientPK And a.ReportedbyDate =      b.eCD4Date  Where a.TestName = ''CD4''  
Group By 
a.PatientPK, a.FacilityID, b.eCD4Date
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eWHO]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_eWHO] as 
With IQC_allWHO as 
(Select a.PatientPK, Min(a.VisitDate) WHODate


 , Cast(a.WHOStage As int) WHOStage
 , Case When DateDiff(dd, m.registrationDate, a.VisitDate) <= 60 Then 1 Else 0
  End As enrollmentTest, Case
    When DateDiff(dd, c.startARTDate, a.VisitDate) Between -90 And 14 Then 1
    Else 0 End As baselineTest
From tmp_ClinicalEncounters a Inner Join
  tmp_patientmaster m On a.PatientPK = m.PatientPK Left Join
  tmp_ARTPatients c On a.PatientPK = c.PatientPK
Where a.WHOStage Is Not Null
Group By a.PatientPK, m.registrationDate, c.startARTDate, a.WHOStage, a.VisitDate)

Select c.PatientPK, Max(c.WHOStage) eWHO, d.eWHODate
From IQC_allWHO c Inner Join
  (Select IQC_allWHO.PatientPK, Min(IQC_allWHO.WHODate) eWHODate
    From IQC_allWHO
    Where IQC_allWHO.enrollmentTest = 1
    Group By IQC_allWHO.PatientPK) d On c.PatientPK = d.PatientPK And
    c.WHODate = d.eWHODate
Group By c.PatientPK, d.eWHODate' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastCD4]'))
EXEC dbo.sp_executesql @statement = N'CREATE view [dbo].[IQC_lastCD4] as
Select Distinct a.PatientPK

, a.FacilityID
,    Max(Cast(Floor(a.TestResult) As int)) lastCD4
, b.lastCD4Date  
From TMP_Labs a 
Inner Join    
(Select a.PatientPK
, Max(a.ReportedbyDate) lastCD4Date      
From TMP_Labs a      
Where a.TestName = ''CD4''     
Group By a.PatientPK) 
b On a.PatientPK = b.PatientPK 
And a.ReportedbyDate =      
b.lastCD4Date  
Where a.TestName = ''CD4''  
Group By a.PatientPK
, a.FacilityID
, b.lastCD4Date
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastWHO]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_lastWHO] as 
With IQC_allWHO as 
(Select a.PatientPK, Min(a.VisitDate) WHODate


 , Cast(a.WHOStage As int) WHOStage
 , Case When DateDiff(dd, m.registrationDate, a.VisitDate) <= 60 Then 1 Else 0
  End As enrollmentTest, Case
    When DateDiff(dd, c.startARTDate, a.VisitDate) Between -90 And 14 Then 1
    Else 0 End As baselineTest
From tmp_ClinicalEncounters a Inner Join
  tmp_patientmaster m On a.PatientPK = m.PatientPK Left Join
  tmp_ARTPatients c On a.PatientPK = c.PatientPK
Where a.WHOStage Is Not Null
Group By a.PatientPK, m.registrationDate, c.startARTDate, a.WHOStage, a.VisitDate)

Select c.PatientPK, Max(c.WHOStage) lastWHO, d.lastWHODate
From IQC_allWHO c Inner Join
  (Select IQC_allWHO.PatientPK, Max(IQC_allWHO.WHODate) lastWHODate
    From IQC_allWHO
    
    Group By IQC_allWHO.PatientPK) d On c.PatientPK = d.PatientPK And
    c.WHODate = d.lastWHODate
Group By c.PatientPK, d.lastWHODate' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_m12CD4]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_m12CD4] as
Select Distinct a.PatientPK

, a.FacilityID
,    Max(Cast(Floor(a.TestResult) As int)) m12CD4
, b.m12CD4Date  
From TMP_Labs a 
Inner Join    
(Select a.PatientPK
, Max(a.ReportedbyDate) m12CD4Date      
From TMP_Labs a      
Where a.TestName = ''CD4'' 
And a.baselineTest = 12     
Group By a.PatientPK) 
b On a.PatientPK = b.PatientPK 
And a.ReportedbyDate =      
b.m12CD4Date  
Where a.TestName = ''CD4''  
Group By a.PatientPK
, a.FacilityID
, b.m12CD4Date
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_m6CD4]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_m6CD4] as
Select Distinct a.PatientPK

, a.FacilityID
,    Max(Cast(Floor(a.TestResult) As int)) m6CD4
, b.m6CD4Date  
From TMP_Labs a 
Inner Join    
(Select a.PatientPK
, Max(a.ReportedbyDate) m6CD4Date      
From TMP_Labs a      
Where a.TestName = ''CD4'' 
And a.baselineTest = 6     
Group By a.PatientPK) 
b On a.PatientPK = b.PatientPK 
And a.ReportedbyDate =      
b.m6CD4Date  
Where a.TestName = ''CD4''  
Group By a.PatientPK
, a.FacilityID
, b.m6CD4Date
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_AdverseEvents]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW IQC_AdverseEvents
AS
select Distinct PatientID, PatientPK, SiteCode, null as VisitDate, null as Regimen, null as AdverseEvent, null as AdverseEventCause, null as Severity, null as ActionTaken, null as  
             ClinicalOutcome, null as AdverseEventEndDate, null as Pregnancy 
			 from tmp_PatientMaster
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_bWAB]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_bWAB] as 
WITH IQC_allWAB AS
(Select Distinct a.PatientPK, m.FacilityID
, Case When a.WABStage In (''Working'',''W'') Then 1      
When a.WABStage In (''Ambulatory'',''A'') 
Then 2 When a.WABStage In (''Bedridden'',''B'') Then 3    
End As WABStage, a.VisitDate WABDate
, Case      When DateDiff(dd, m.registrationDate, a.VisitDate) <= 90 Then 1 Else 0    
End As enrollmentTest, Case      When DateDiff(dd, c.startARTDate, a.VisitDate) 
Between -90 And 14 Then 1      Else 0 End As baselineTest  
From TMP_ClinicalEncounters a 
Inner Join    tmp_patientmaster m On a.PatientPK = m.PatientPK 
Left Join    tmp_ARTPatients c On a.PatientPK = c.PatientPK  
Where a.WABStage Is Not Null)

Select e.PatientPK,e.FacilityID, Max(e.WABStage) bWAB, e2.wabDate bWABDate
From IQC_allWAB e Inner Join
  (Select IQC_allWAB.PatientPK, Min(IQC_allWAB.WABDate) wabDate
    From IQC_allWAB
    Where IQC_allWAB.baselineTest = 1
    Group By IQC_allWAB.PatientPK) e2 On e.PatientPK = e2.PatientPK And
    e.WABDate = e2.wabDate
Group By e.PatientPK,e.FacilityID, e2.wabDate
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_eWAB]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_eWAB] as 
WITH IQC_allWAB AS
(Select Distinct a.PatientPK, m.FacilityID
, Case When a.WABStage In (''Working'',''W'') Then 1      
When a.WABStage In (''Ambulatory'',''A'') 
Then 2 When a.WABStage In (''Bedridden'',''B'') Then 3    
End As WABStage, a.VisitDate WABDate
, Case      When DateDiff(dd, m.registrationDate, a.VisitDate) <= 90 Then 1 Else 0    
End As enrollmentTest, Case      When DateDiff(dd, c.startARTDate, a.VisitDate) 
Between -90 And 14 Then 1      Else 0 End As baselineTest  
From TMP_ClinicalEncounters a 
Inner Join    tmp_patientmaster m On a.PatientPK = m.PatientPK 
Left Join    tmp_ARTPatients c On a.PatientPK = c.PatientPK  
Where a.WABStage Is Not Null)

Select e.PatientPK,e.FacilityID, Max(e.WABStage) eWAB, e2.wabDate eWABDate
From IQC_allWAB e Inner Join
  (Select IQC_allWAB.PatientPK, Min(IQC_allWAB.WABDate) wabDate
    From IQC_allWAB
    Where IQC_allWAB.enrollmentTest = 1
    Group By IQC_allWAB.PatientPK) e2 On e.PatientPK = e2.PatientPK And
    e.WABDate = e2.wabDate
Group By e.PatientPK,e.FacilityID, e2.wabDate
' 

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_lastWAB]'))
EXEC dbo.sp_executesql @statement = N'
CREATE view [dbo].[IQC_lastWAB] as 
WITH IQC_allWAB AS
(Select Distinct a.PatientPK, m.FacilityID
, Case When a.WABStage In (''Working'',''W'') Then 1      
When a.WABStage In (''Ambulatory'',''A'') 
Then 2 When a.WABStage In (''Bedridden'',''B'') Then 3    
End As WABStage, a.VisitDate WABDate
, Case      When DateDiff(dd, m.registrationDate, a.VisitDate) <= 90 Then 1 Else 0    
End As enrollmentTest, Case      When DateDiff(dd, c.startARTDate, a.VisitDate) 
Between -90 And 14 Then 1      Else 0 End As baselineTest  
From TMP_ClinicalEncounters a 
Inner Join    tmp_patientmaster m On a.PatientPK = m.PatientPK 
Left Join    tmp_ARTPatients c On a.PatientPK = c.PatientPK  
Where a.WABStage Is Not Null)

Select e.PatientPK,e.FacilityID, Max(e.WABStage) lastWAB, e2.wabDate lastWABDate
From IQC_allWAB e Inner Join
  (Select IQC_allWAB.PatientPK, Max(IQC_allWAB.WABDate) wabDate
    From IQC_allWAB
   
    Group By IQC_allWAB.PatientPK) e2 On e.PatientPK = e2.PatientPK And
    e.WABDate = e2.wabDate
Group By e.PatientPK,e.FacilityID, e2.wabDate
' 

END

GO