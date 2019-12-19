if exists(select * from sysobjects where name='pr_Reports_PendingAppointments' and type='p')
	drop proc pr_Reports_PendingAppointments
go

create proc pr_Reports_PendingAppointments @fromdate DATETIME, @todate datetime
as
begin
	SELECT * FROM
	(
	Select Distinct b.ServiceArea,
	  a.Ptn_Pk As PatientPK,
	  b.PatientID,
	  b.PatientName,
	  b.PhoneNumber,
	  b.Village,
	  a.Age,
	  b.gender,
	  convert(varchar, a.AppDate, 106) As AppointmentDate,
	  a.AppointmentReason,
	  a.VisitDate,
	  Case
		When a.VisitDate Between DateAdd(dd, -14, a.AppDate) And dateadd(hh, 12, a.AppDate) Then 'Came'
		When a.VisitDate > a.AppDate Then 'Missed'
		When a.VisitDate Is Null And GetDate() <= a.AppDate THEN 'Pending' 
	   Else 'Missed' End As AppointmentStatus
	  , convert(varchar, c.StartARTDate, 106) as StartARTDate
	  , DATEDIFF(mm, c.StartARTDate, @todate) as Duration_on_ART_Months
	  , (select top 1 x.LastVL from IQC_LastVL x where x.PatientPK=b.PatientPK) as Last_VL
	  , convert(varchar, (select top 1 x.LastVLDate from IQC_LastVL x where x.PatientPK=b.PatientPK), 106) as Last_VL_Date
	  , convert(varchar, b.LastVisit, 106) as LastVisitDate
	  , DateDiff(dd, a.AppDate, a.VisitDate) Came_After_X_Days
	From (Select p.Ptn_Pk,
		p.PatientIPNo,
		a.AppDate,
		DateDiff(yy, p.DOB, GetDate()) Age,
		(Select Top 1 ord_Visit.VisitDate
		From ord_Visit Inner Join mst_VisitType On ord_Visit.VisitType =
			mst_VisitType.VisitTypeID
		Where ord_Visit.VisitDate >= DateAdd(dd, -14, a.AppDate) And
		  ord_Visit.Ptn_Pk = p.Ptn_Pk And mst_VisitType.VisitName <> 'Scheduler'
		Order By ord_Visit.VisitDate) VisitDate,
		b.Name As AppStatus,
		c.NAME AS AppointmentReason
	  From mst_patient p
		Inner Join dtl_PatientAppointment a On p.Ptn_Pk = a.Ptn_pk
		Left Join mst_Decode b On a.AppStatus = b.ID
		LEFT JOIN mst_decode c ON a.appReason = c.ID) a
	INNER JOIN dbo.tmp_PatientMaster b ON a.Ptn_Pk = b.PatientPK
	INNER JOIN tmp_ARTPatients c on b.PatientPK = c.PatientPK
	Where a.AppDate between Cast(@fromdate As DATETIME) and Cast(@todate As DATETIME)
	) a
	WHERE AppointmentStatus = 'Pending'
	ORDER BY AppointmentDate
end