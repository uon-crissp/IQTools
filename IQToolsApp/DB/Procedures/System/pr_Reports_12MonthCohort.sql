if exists(select * from sysobjects where name='pr_Reports_12MonthCohort' and type='P')
	drop proc pr_Reports_12MonthCohort
go

create proc pr_Reports_12MonthCohort @fromdate datetime, @todate datetime
as
begin

	Select 'Net Cohort' as Category, 
	a.Gender,
	count(*) as No_of_Clients
	FROM tmp_ARTPatients a  
	Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
	AND (a.ExitReason IS NULL OR a.ExitReason != 'Transfer')
	and Gender is not null
	GROUP BY a.Gender

	union all

	Select 'Active' as Category, 
	a.Gender,
	count(*) as No_of_Clients
	FROM tmp_ARTPatients a  
	Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
	AND (a.ExitReason IS NULL OR a.ExitReason != 'Transfer')
	AND  dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1
	and Gender is not null
	GROUP BY a.Gender

end
go