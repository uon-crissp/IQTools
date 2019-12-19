if exists(select * from sysobjects where name='pr_Reports_ValidVL' and type='p')
	drop proc pr_Reports_ValidVL
go

create proc pr_Reports_ValidVL @todate datetime
as
begin
select * from
(
SELECT a.Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
inner join IQC_LastVL b on a.PatientPK=b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
and DATEDIFF(mm, LastVLDate, @todate)<= 12
GROUP BY a.Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT 'Total' as Gender,
  dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
inner join IQC_LastVL b on a.PatientPK=b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
and DATEDIFF(mm, LastVLDate, @todate)<= 12
GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM')

union all

SELECT a.Gender,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
inner join IQC_LastVL b on a.PatientPK=b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
and DATEDIFF(mm, LastVLDate, @todate)<= 12
GROUP BY a.Gender

union all

SELECT 'Total' as Gender,
  'TOTAL' AgeGroup,
  Count(DISTINCT a.PatientPK) no_of_patients
FROM tmp_ARTPatients a
inner join IQC_LastVL b on a.PatientPK=b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
and DATEDIFF(mm, LastVLDate, @todate)<= 12

) a PIVOT (SUM(no_of_patients) For Gender IN (Male, Female, Total)) AS Total
end
go

