if exists(select * from sysobjects where name='pr_Reports_HEIRegister' and type='p')
	drop proc pr_Reports_HEIRegister
go

create proc pr_Reports_HEIRegister @fromdate datetime, @todate datetime
as
begin

if exists(select * from sysobjects where name='tempHEIPCR' and type='u')
	drop table tempHEIPCR
if exists(select * from sysobjects where name='tempHEIAntibody' and type='u')
	drop table tempHEIAntibody
if exists(select * from sysobjects where name='tempHEIVLs' and type='u')
	drop table tempHEIVLs
if exists(select * from sysobjects where name='tempHEIFeedingmode' and type='u')
	drop table tempHEIFeedingmode
if exists(select * from sysobjects where name='tempHEIProphylaxis' and type='u')
	drop table tempHEIProphylaxis

select PatientPK, OrderedbyDate, ReportedbyDate, 
case when TestResult='0.00' then 'Negative'
	when TestResult='114.00' then 'Negative'
	when TestResult='1.00' then 'Positive'
	else TestResult end as TestResult
, ROW_NUMBER() over(partition by x.PatientPK order by x.OrderedByDate) TestNo
into tempHEIPCR
from tmp_Labs x
where x.TestName like '%pcr%'

select PatientPK, OrderedbyDate, ReportedbyDate,
case when TestResult='0.00' then 'Negative'
	when TestResult='1.00' then 'Positive'
	else TestResult end as TestResult
, ROW_NUMBER() over(partition by x.PatientPK order by x.OrderedByDate) TestNo
into tempHEIAntibody
from tmp_Labs x
where x.TestName like '%antibody%'

select PatientPK, OrderedbyDate, ReportedbyDate, TestResult
, ROW_NUMBER() over(partition by x.PatientPK order by x.OrderedByDate) TestNo
into tempHEIVLs
from tmp_Labs x
where x.TestName like '%viral%'

select a.PatientPK, c.visitdate as visitdate
, datediff(ww, a.dob, c.visitdate) as age_weeks 
, datediff(MM, a.dob, c.visitdate) as age_months 
, d.name as feedingMode
, ROW_NUMBER() over(partition by a.PatientPK order by c.visitdate) visitno 
into tempHEIFeedingmode
from tmp_PatientMaster a
inner join dtl_InfantInfo b on a.PatientPK=b.ptn_pk
inner join ord_visit c on b.visit_pk=c.visit_id
left join mst_pmtctdecode d on b.feedingoption = d.id


select a.ptn_pk as Patientpk, a.ARVProphylaxis, a.visitdate
, datediff(MM, b.DOB, a.visitdate) as AgeAtDispene
, ROW_NUMBER() over(partition by a.ptn_pk order by a.visitdate) RowNo
into tempHEIProphylaxis
from
(
	select a.ptn_pk
	, case when b.Name='Other Specify' then a.ARVPropOther
	else b.Name end as ARVProphylaxis
	, c.visitdate as VisitDate
	from dtl_KNHPMTCTHEI a
	inner join mst_ModDeCode b on a.ChildPEPARVs =b.id
	inner join ord_visit c on a.visit_pk = c.visit_id
	union all
	select a.patientpk, a.drug, a.dispenseDate
	from tmp_Pharmacy a 
	where a.PatientPK in (select ptn_pk from dtl_KNHPMTCTHEI)
	and a.Drug like '%cotri%'
) a
inner join tmp_PatientMaster b on a.ptn_pk = b.PatientPK

select a.RegistrationDate as [Enrollment Date]
, a.PatientID as [HEI ID]
, a.PatientName as [Infant Name]
, a.dob as [Date of Birth]
, DATEDIFF(ww, a.dob, a.registrationdate) as [Age at Enrollment (Weeks)]
, DATEDIFF(MM, a.dob, getdate()) as [Current Age (Months)]
, a.Gender
, a.PhoneNumber as [Phone Number]

, c.PatientID as [Mothers IP Number]
, c.PatientName as [Mothers Name]
, c.AgeCurrent as [Mothers Age]
, c.AgeEnrollment as [Mothers Age Entry]
, c.RegistrationAtPMTCT as [Mother Entry Date]
, null as [Mother Pregnant at Entry]
, c.MaritalStatus as [Mother Marital Status]
, (select top 1 x.lastWHO from IQC_lastWHO x where x.PatientPK=a.PatientPK) as [Mother WHO]
, c.Gender as [Mother Gender]
, c.PatientSource as [Mother Patient Source]
, c.EducationLevel as [Mother EducationLevel]
, f.StartARTDate as [Mother ART StartDate]
, f.LastRegimen as [Mother ART Regimen]
, f.LastRegimenLine as [Mother Regimen Line]
, (select top 1 'Yes' from tmp_ClinicalEncounters x where x.PatientPK=c.PatientPK and x.VisitType like '%ANC%' and VisitDate < a.DOB) as [Mother ANC Record At KNH]
, (select top 1 'Yes' from tmp_ClinicalEncounters x where x.PatientPK=c.PatientPK and x.VisitType like '%maternity%') as [Mother Maternity Record KNH]
, d.LastVL as [Mother Current VL]
, d.LastVLDate as [Mother Current VL Date]
, (select top 1 x.lastCD4 from IQC_lastCD4 x where x.PatientPK=c.PatientPK) as [Mother last CD4]
, (select top 1 x.lastCD4Date from IQC_lastCD4 x where x.PatientPK=c.PatientPK) as [Mother last CD4Date]
, (select top 1 x.ExitReason from tmp_LastStatus x where x.PatientPK=c.PatientPK) as [Mother ART Outcome]

, a.LastVisit as [Last Visit Date]
, a.AgeLastVisit as [Age at Last Visit]
, e.ExitDate as [Date exited care]
, e.ExitReason [Outcome at Exit]

, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%AZT%' order by RowNo) as AZT_Startdate
, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%AZT%' order by RowNo desc) as AZT_LastDate
, (select top 1 x.AgeAtDispene from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%AZT%' order by RowNo desc) as AZT_AgeLastDispense

, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%NVP%' order by RowNo) as NVP_Startdate
, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%NVP%' order by RowNo desc) as NVP_LastDate
, (select top 1 x.AgeAtDispene from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%NVP%' order by RowNo desc) as NVP_AgeLastDispense

, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%cotri%' order by RowNo) as CTX_Startdate
, (select top 1 x.visitdate from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%cotri%' order by RowNo desc) as CTX_LastDate
, (select top 1 x.AgeAtDispene from tempHEIProphylaxis x where x.Patientpk=a.patientpk and x.ARVProphylaxis like '%cotri%' order by RowNo desc) as CTX_AgeLastDispense

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks<6 order by visitno) as Visit_2wks
, (select top 1 age_weeks from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks<6 order by visitno) as Visit_2wks_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks<6 order by visitno) as Visit_2wks_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 6 and 9 order by visitno) as Visit_6wks
, (select top 1 age_weeks from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 6 and 9 order by visitno) as Visit_6wks_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 6 and 9 order by visitno) as Visit_6wks_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 10 and 13 order by visitno) as Visit_10wks
, (select top 1 age_weeks from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 10 and 13 order by visitno) as Visit_10wks_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 10 and 13 order by visitno) as Visit_10wks_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 14 and 18 order by visitno) as Visit_14wks
, (select top 1 age_weeks from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 14 and 18 order by visitno) as Visit_14wks_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_weeks between 14 and 18 order by visitno) as Visit_14wks_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months=6 order by visitno) as Visit_6mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months=6 order by visitno) as Visit_6mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months=6 order by visitno) as Visit_6mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 7 and 8 order by visitno) as Visit_7mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 7 and 8 order by visitno) as Visit_7mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 7 and 8 order by visitno) as Visit_7mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 9 and 10 order by visitno) as Visit_10mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 9 and 10 order by visitno) as Visit_10mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 9 and 10 order by visitno) as Visit_10mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 12 and 13 order by visitno) as Visit_12mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 12 and 13 order by visitno) as Visit_12mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 12 and 13 order by visitno) as Visit_12mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 15 and 16 order by visitno) as Visit_15mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 15 and 16 order by visitno) as Visit_15mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 15 and 16 order by visitno) as Visit_15mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 18 and 19 order by visitno) as Visit_18mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 18 and 19 order by visitno) as Visit_18mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 18 and 19 order by visitno) as Visit_18mths_feedmode

, (select top 1 visitdate from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 23 and 25 order by visitno) as Visit_24mths
, (select top 1 age_months from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 23 and 25 order by visitno) as Visit_24mths_Age
, (select top 1 feedingMode from tempHEIFeedingmode x where x.patientpk=a.patientpk and x.age_months between 23 and 25 order by visitno) as Visit_24mths_feedmodes

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=1) as PCR1_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=1) as PCR1_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=1) as PCR1_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=1) as PCR1_Result

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=2) as PCR2_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=2) as PCR2_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=2) as PCR2_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=2) as PCR2_Result

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=3) as PCR3_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=3) as PCR3_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=3) as PCR3_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=3) as PCR3_Result

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=4) as PCR4_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=4) as PCR4_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=4) as PCR4_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=4) as PCR4_Result

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=5) as PCR5_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=5) as PCR5_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=5) as PCR5_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=5) as PCR5_Result

, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=6) as PCR6_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=6) as PCR6_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=6) as PCR6_ResultDate
, (select top 1 x.TestResult from tempHEIPCR x where x.PatientPK=a.PatientPK and x.TestNo=6) as PCR6_Result

, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=1) as AB1_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=1) as AB1_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=1) as AB1_ResultDate
, (select top 1 x.TestResult from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=1) as AB1_Result

, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=2) as AB2_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=2) as AB2_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=2) as AB2_ResultDate
, (select top 1 x.TestResult from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=2) as AB2_Result

, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=3) as AB3_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=3) as AB3_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=3) as AB3_ResultDate
, (select top 1 x.TestResult from tempHEIAntibody x where x.PatientPK=a.PatientPK and x.TestNo=3) as AB3_Result

, (select top 1 x.OrderedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=1) as VL1_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=1) as VL1_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=1) as VL1_ResultDate
, (select top 1 x.TestResult from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=1) as VL1_Result

, (select top 1 x.OrderedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=2) as VL2_OrderDate
, (select top 1 x.OrderedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=2) as VL2_SampleCollectDate
, (select top 1 x.ReportedbyDate from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=2) as VL2_ResultDate
, (select top 1 x.TestResult from tempHEIVLs x where x.PatientPK=a.PatientPK and x.TestNo=2) as VL2_Result

from tmp_PatientMaster a
left join
	(select PatientPK as ChildPK, RPatientPK as MotherPK from tmp_FamilyInfo where RPatientPK is not null
	union
	select RPatientPK, PatientPK from tmp_FamilyInfo where RPatientPK is not null)
	b on a.PatientPK = b.ChildPK
left join tmp_PatientMaster c on b.MotherPK = c.PatientPK
left join tmp_ARTPatients f on c.PatientPK = f.PatientPK
left join IQC_LastVL d on c.PatientPK = d.PatientPK
left join tmp_LastStatus e on a.PatientPK = e.PatientPK

where a.PatientPK in
(select x.ptn_pk from ord_visit x
inner join mst_visittype y on x.visittype=y.visittypeid
where y.visitname like '%hei%')
and a.AgeEnrollment < 2.0
and a.DOB between cast(@fromdate as datetime) and cast(@todate as datetime)
order by a.DOB

if exists(select * from sysobjects where name='tempHEIPCR' and type='u')
	drop table tempHEIPCR
if exists(select * from sysobjects where name='tempHEIAntibody' and type='u')
	drop table tempHEIAntibody
if exists(select * from sysobjects where name='tempHEIVLs' and type='u')
	drop table tempHEIVLs
if exists(select * from sysobjects where name='tempHEIFeedingmode' and type='u')
	drop table tempHEIFeedingmode
if exists(select * from sysobjects where name='tempHEIProphylaxis' and type='u')
	drop table tempHEIProphylaxis

end
go