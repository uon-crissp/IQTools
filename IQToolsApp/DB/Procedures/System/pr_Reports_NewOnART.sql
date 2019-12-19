if exists(select * from sysobjects where name='pr_Reports_NewOnART' and type='P')
	drop proc pr_Reports_NewOnART
go

create proc pr_Reports_NewOnART @fromdate datetime, @todate datetime
as
begin
select * from
(
SELECT a.Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
WHERE a.RegistrationDate <= CAST(@todate AS datetime) AND
  a.StartARTDate BETWEEN CAST(@fromdate AS datetime) AND CAST(@todate AS
  datetime)
GROUP BY a.Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT 'Total' as Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
WHERE a.RegistrationDate <= CAST(@todate AS datetime) AND
  a.StartARTDate BETWEEN CAST(@fromdate AS datetime) AND CAST(@todate AS
  datetime)
GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT a.Gender,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
WHERE a.RegistrationDate <= CAST(@todate AS datetime) AND
  a.StartARTDate BETWEEN CAST(@fromdate AS datetime) AND CAST(@todate AS
  datetime)
GROUP BY a.Gender

union all

SELECT 'Total' as Gender,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
WHERE a.RegistrationDate <= CAST(@todate AS datetime) AND
  a.StartARTDate BETWEEN CAST(@fromdate AS datetime) AND CAST(@todate AS
  datetime)

) a PIVOT (SUM(no_of_patients) For Gender IN (Male, Female, Total)) AS Total
end
go

