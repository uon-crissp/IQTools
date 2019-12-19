if exists(select * from sysobjects where name='pr_Reports_NoFutureAppointment' and type='p')
	drop proc pr_Reports_NoFutureAppointment
go

create proc pr_Reports_NoFutureAppointment
as
begin
	select PatientID, PatientName, AgeCurrent, Gender, ServiceArea, LastVisit, LatestAppointmentDate 
	from tmp_artpatients where LastVisit >= LatestAppointmentDate
	and CurrentStatus in ('active', 'Lost - Not care-ended')
end
go