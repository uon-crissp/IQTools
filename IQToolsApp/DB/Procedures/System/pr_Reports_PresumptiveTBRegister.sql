if exists(select * from sysobjects where name='pr_Reports_PresumptiveTBRegister' and type='p')
	drop proc pr_Reports_PresumptiveTBRegister
go

create proc pr_Reports_PresumptiveTBRegister @fromdate datetime, @todate datetime
as
begin
	if exists(select * from sysobjects where name='tempPresumptiveTB' and type='u')
		drop table tempPresumptiveTB

	select a.ptn_pk as PatientPK
	, a.Visit_pk
	, a.name as TBStatus
	, b.visitdate as TBSuspectDate
	, case when a.chestXray=1 then 'Yes' when a.chestXray=0 then 'No' end as chestXray
	, case when a.chestXray=1 then a.ChestXrayDate end as ChestXrayDate
	, SputumSmearResult
	, SputumSmearDate
	into tempPresumptiveTB
	from
	(
		select a.*, ROW_NUMBER() over (partition by a.ptn_pk order by a.visit_pk desc) RowNo
		,b.name as SputumSmearResult
		from
		(
		select b.name, a.*
		from dtl_tbscreening a
		inner join MST_BLUEDECODE b on a.TBFindings=b.id
		where name like '%suspect%'
		union all
		select b.name, a.*
		from dtl_tbscreening a
		inner join mst_Decode b on a.TBFindings=b.id
		where name like '%suspect%' and b.ID>100
		) a
		left join mst_decode b on a.sputumsmear = b.id
	) a
	inner join ord_visit b on a.visit_pk = b.visit_id
	where a.RowNo=1

	select a.PatientPK
	, a.PatientID
	, a.PatientName
	, a.PhoneNumber
	, a.Gender
	, a.AgeCurrent
	, a.ServiceArea
	, b.StartARTDate
	, b.LastRegimen
	, b.LastRegimenLine
	, c.TBStatus as TBScreeningStatus
	, c.TBSuspectDate as TB_Screening_Date
	, '' [Sputum_collected]
	, '' [sputum collected]
	, (select top 1 x.OrderedbyDate from ord_patientlaborder x
		inner join dtl_patientlabresults y on x.LabID=y.LabID
		inner join mst_labtest z on y.labtestid=z.labtestid
		where z.labName like '%gene%' and x.Ptn_pk=a.patientpk order by x.OrderedbyDate desc) as GeneXpertOrderDate
	, (select top 1 z.Result from ord_patientlaborder x
		inner join dtl_patientlabresults y on x.LabID=y.LabID
		inner join lnk_parameterresult z on y.TestResultid=z.ResultID
		inner join mst_labtest zz on y.labtestid=zz.labtestid
		where zz.labName like '%gene%' and x.Ptn_pk=a.patientpk order by x.OrderedbyDate desc) as GeneXpertResult
	, '' MicroscopyOrderDate
	, '' MicroscopyResults
	, '' CultureOrderDate
	, '' CultureResults
	, chestXray as ChestXRayOrdered
	, ChestXrayDate
	, (select top 1 y.name from dtl_TbScreening x 
	inner join MST_BLUEDECODE y on x.TBFindings=y.id
	where x.ptn_pk=a.PatientPK and x.visit_pk>c.visit_pk) as OutcomeOfInvestigation
	, (select top 1 'Yes' from VW_PatientPharmacy x where x.Ptn_pk=a.patientpk and x.DispensedByDate > c.TBSuspectDate 
	and (x.DrugName like '%RHZE%' or x.DrugName like '%RIFAMPICIN%')) as StartedAntiTB
	, (select top 1 'Yes' from VW_PatientPharmacy x where x.Ptn_pk=a.patientpk and x.DispensedByDate > c.TBSuspectDate 
	and x.DrugName like 'isoniazid%') as StartedIPT
	, b.CurrentStatus
	from tmp_PatientMaster a
	inner join tmp_ARTPatients b on a.PatientPK=b.PatientPK
	inner join tempPresumptiveTB c on b.PatientPK=c.PatientPK
	where c.TBSuspectDate between cast(@fromdate as datetime) and cast(@todate as datetime)
end
go
