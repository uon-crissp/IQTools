if exists(select * from sysobjects where name='pr_Reports_12MonthCohort_Linelist' and type='P')
	drop proc pr_Reports_12MonthCohort_Linelist
go

create proc pr_Reports_12MonthCohort_Linelist @fromdate datetime, @todate datetime
as
begin

	Select * FROM tmp_ARTPatients a  
	Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
	AND (a.ExitReason IS NULL OR a.ExitReason != 'Transfer')
	and Gender is not null

end