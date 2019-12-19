if exists(select * from sysobjects where name='pr_Reports_HighVLRegister' and type='p')
	drop proc pr_Reports_HighVLRegister
go

create proc pr_Reports_HighVLRegister @fromdate datetime, @todate datetime
as
begin

if exists(select * from sysobjects where name='tempEACForms' and type='u')
	drop table tempEACForms

select a.PatientPK, cast(a.VisitDate as date) as VisitDate
, ROW_NUMBER() over(partition by a.PatientPK order by cast(a.VisitDate as date) desc) RowNo
into tempEACForms
from tmp_ClinicalEncounters a where VisitType like '%Adherence%'
group by a.PatientPK, cast(a.VisitDate as date)

;WITH VLGT1000 AS (select PatientPK, VLOrderDate, VLReportDate, VLResult from IQC_AllVL WHERE VLOrderDate 
BETWEEN CAST(@fromdate as date) AND CAST(@todate as date) AND VLResult > 1000) 

, PreviousVL AS ( SELECT a.PatientPK , a.VLOrderDate HighVLDate , a.VLResult HighVLResult , b.VLOrderDate PreviousVLDate 
, b.VLResult PreviousVLResult , DATEDIFF(dd, a.VLOrderDate, b.VLOrderDate) DaysElapsed FROM VLGT1000 a 
INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK WHERE b.VLOrderDate < a.VLOrderDate) 

, FilterOut AS ( Select DISTINCT PatientPK  FROM PreviousVL WHERE PreviousVLResult >= 1000 AND DaysElapsed >= -180) ,
 
HighVLClients AS ( Select a.PatientPK, a.VLOrderDate, a.VLReportDate, a.VLResult  FROM VLGT1000 a LEFT JOIN FilterOut b ON a.PatientPK = b.PatientPK 
WHERE b.PatientPK IS NULL) 

, RepeatVLs AS ( select a.PatientPK , a.VLOrderDate , a.VLResult , b.VLOrderDate PreviousVLDate , 
b.VLResult PreviousVL , DATEDIFF(mm, a.VLOrderDate, b.VLOrderDate) dd  from HighVLClients a
INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK WHERE DATEDIFF(mm, a.VLOrderDate, b.VLOrderDate) BETWEEN -5 AND -2 AND b.VLResult > 1000) , 
 
CurrentRegimen AS (Select a.PatientPK , b.Regimen , MIN(CAST(a.DispenseDate as DATE)) RegimenStartDate  FROM tmp_Pharmacy a 
INNER JOIN ( Select DISTINCT a.PatientPK , a.Drug Regimen , CAST(b.LastDate as DATE) RegimenLastDate 
FROM tmp_Pharmacy a INNER JOIN ( Select a.PatientPK, MAX(b.DispenseDate) LastDate 
FROM HighVLClients a LEFT JOIN tmp_Pharmacy b ON a.PatientPK = b.PatientPK  AND a.VLOrderDate >= b.DispenseDate 
AND b.TreatmentType = 'ART' AND LEN(b.Drug) >= 11 GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK 
AND a.DispenseDate = b.LastDate AND a.TreatmentType = 'ART') b ON a.PatientPK = b.PatientPK AND a.Drug = b.Regimen 
GROUP BY a.PatientPK, b.Regimen) 
 
, FUVL AS ( Select a.PatientPK , CAST(a.VLOrderDate as DATE) VLOrderDate , 
CAST(a.VLReportDate as DATE) VLReportDate , a.VLResult  FROM IQC_AllVL a 
INNER JOIN ( Select a.PatientPK, MIN(a.VLOrderDate)FUVLDate FROM 
IQC_AllVL a INNER JOIN HighVLClients b ON a.PatientPK = b.PatientPK AND a.VLOrderDate > b.VLOrderDate GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK 
AND a.VLOrderDate = b.FUVLDate) 
 
, LastRegimen AS (Select a.PatientPK, a.LastRegimen , CAST(b.LastRegimenStartDate as DATE) LastRegimenStartDate 
FROM tmp_ARTPatients a INNER JOIN ( Select a.PatientPK, MIN(c.DispenseDate) LastRegimenStartDate  FROM HighVLClients a 
INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK INNER JOIN tmp_Pharmacy c ON b.PatientPK = c.PatientPK AND b.LastRegimen = c.Drug 
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK) 
 
, RegimenChange AS ( Select a.PatientPK , 
CASE WHEN e.LastRegimen <> c.Regimen  AND e.LastRegimenStartDate >= a.VLOrderDate THEN 'YES' 
ELSE NULL END AS RegimenChanged , CASE WHEN e.LastRegimen <> c.Regimen  AND e.LastRegimenStartDate >= a.VLOrderDate THEN e.LastRegimenStartDate ELSE NULL END AS RegimenChangeDate , 
CASE WHEN e.LastRegimen <> c.Regimen  AND e.LastRegimenStartDate >= a.VLOrderDate THEN e.LastRegimen ELSE NULL END AS LastRegimen 
FROM HighVLClients a INNER JOIN CurrentRegimen c ON a.PatientPK = c.PatientPK LEFT JOIN LastRegimen e ON a.PatientPK = e.PatientPK 
WHERE e.LastRegimen <> c.Regimen  AND e.LastRegimenStartDate >= a.VLOrderDate ) 
 
, m6VL AS (SELECT a.PatientPK , CAST(b.VLOrderDate as DATE)VLOrderDate 
, b.VLResult  FROM RegimenChange a INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK WHERE DATEDIFF(dd, RegimenChangeDate, VLOrderDate) BETWEEN 180 AND 360)

Select DISTINCT b.ServiceArea
, b.PatientID 
, b.PatientName 
, CAST(b.DOB as DATE) as [Date of Birth]
, b.AgeLastVisit Age  
, b.Gender
, a.VLResult 
, CAST(a.VLOrderDate as DATE) VLDate 
, CASE WHEN b.StartRegimen <> c.Regimen AND LEN(b.StartRegimen) BETWEEN 11 AND 13 THEN b.StartRegimen ELSE NULL END AS PreviousRegimen 
, CASE WHEN b.StartRegimen <> c.Regimen AND LEN(b.StartRegimen) BETWEEN 11 AND 13 THEN CAST(b.StartARTDate as DATE)  ELSE NULL END AS PreviousRegimenStartDate 
, c.Regimen CurrentRegimen 
, c.RegimenStartDate CurrentRegimenStartDate 
, (select top 1 x.VisitDate from tmp_ClinicalEncounters x where x.PatientPK=a.PatientPK and x.VisitType like '%social%' order by x.VisitDate desc) [Psychosocial Form Date] 

, (select top 1 'Yes' from tempEACForms x where x.PatientPK=a.PatientPK and x.RowNo=1 and x.VisitDate>a.VLOrderDate) [Atleast 1 EAC] 
, (select top 1 VisitDate from tempEACForms x where x.PatientPK=a.PatientPK and x.RowNo=3 and x.VisitDate>a.VLOrderDate) [EAC Date 1] 
, (select top 1 VisitDate from tempEACForms x where x.PatientPK=a.PatientPK and x.RowNo=2 and x.VisitDate>a.VLOrderDate) [EAC Date 1] 
, (select top 1 VisitDate from tempEACForms x where x.PatientPK=a.PatientPK and x.RowNo=1 and x.VisitDate>a.VLOrderDate) [EAC Date 3] 
, d.VLOrderDate as [Repeat VL SampleCollected]
--, d.VLReportDate [Repeat VL ResultReceived 
, d.VLResult [Repeat VL Result]
, CASE WHEN e.PatientPK IS NOT NULL THEN 'YES' ELSE NULL END AS RegimenChanged 
, e.RegimenChangeDate
, e.LastRegimen as RegimenIssued
, f.VLResult [VL 6 Months after change] 
, f.VLOrderDate [Vl After Change Date] 
FROM HighVLClients a 
INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK 
LEFT JOIN CurrentRegimen c ON a.PatientPK = c.PatientPK 
LEFT JOIN FUVL d ON a.PatientPK = d.PatientPK 
LEFT JOIN RegimenChange e ON a.PatientPK = e.PatientPK 
LEFT JOIN m6VL f ON a.PatientPK = f.PatientPK
where b.ServiceArea <> 'Patient in transit'
end
go