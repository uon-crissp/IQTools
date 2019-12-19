if exists(select * from sysobjects where name='pr_Reports_RecentLost_Linelist' and type='P')
	drop proc pr_Reports_RecentLost_Linelist
go

create proc pr_Reports_RecentLost_Linelist
as
begin
	Select * FROM tmp_ARTPatients a  
	Where DaysMissed between 31 and 90
end
go
