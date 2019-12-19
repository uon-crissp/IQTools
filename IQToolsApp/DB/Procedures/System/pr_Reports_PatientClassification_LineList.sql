if exists(select * from sysobjects where name='pr_Reports_PatientClassification_LineList' and type='P')
	drop proc pr_Reports_PatientClassification_LineList
go

create proc pr_Reports_PatientClassification_LineList
as
begin
	SELECT a.PatientID
	, a.ServiceArea
	, isnull(a.patientclassification, 'Not classfied') as PatClassification
	, dbo.fn_GetAgeGroup(a.AgeLastVisit, 'DATIM') AgeGroup
	, a.*
	FROM tmp_ARTPatients a
	Where a.CurrentStatus = 'active'
end
go

