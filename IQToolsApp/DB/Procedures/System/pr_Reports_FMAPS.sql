if exists(select * from sysobjects where name='pr_Reports_FMAPS' and type='p')
	drop proc pr_Reports_FMAPS
go

create proc pr_Reports_FMAPS @todate datetime
as
begin

	select LastRegimen as Regimen, count(*) as No_of_Clients from tmp_ARTPatients a
	where dbo.fn_ActiveCCC(cast(@todate as datetime), a.PatientPK)=1
	group by LastRegimen
	order by LastRegimen
end
go