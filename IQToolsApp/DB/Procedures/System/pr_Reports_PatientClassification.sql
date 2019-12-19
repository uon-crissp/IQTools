if exists(select * from sysobjects where name='pr_Reports_PatientClassification' and type='P')
	drop proc pr_Reports_PatientClassification
go

create proc pr_Reports_PatientClassification
as
begin
select * from
(
SELECT isnull(a.patientclassification, 'Unclassfied') as PatClassification,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
Where a.CurrentStatus = 'active'
GROUP BY isnull(a.patientclassification, 'Unclassfied'),
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT 'Total' as patientclassification,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
Where a.CurrentStatus = 'active'
GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT isnull(a.patientclassification, 'Unclassfied') as PatClassification,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
Where a.CurrentStatus = 'active'
GROUP BY isnull(a.patientclassification, 'Unclassfied')

union all

SELECT 'Total' as patientclassification,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
Where a.CurrentStatus = 'active'

) a PIVOT (SUM(no_of_patients) For PatClassification IN ([Well], [Advance HIV Disease], [Unstable], [Stable], [Unclassfied], Total)) AS Total
end
go

