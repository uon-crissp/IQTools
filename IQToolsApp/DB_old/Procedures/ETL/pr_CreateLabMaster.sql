IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateLabMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateLabMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateLabMaster]
AS
BEGIN

	EXEC
	('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_Labs'') AND type in (N''U''))
	DROP TABLE tmp_Labs')

	Exec('Select Distinct m.PatientPK, 
		labs.VisitID,
		m.FacilityID,
		labs.OrderedbyDate,
		labs.ReportedbyDate,
		labs.TestName,
		labs.TestResult,
		Case When DateDiff(dd, m.RegistrationDate, labs.ReportedbyDate) <= 60 Then 1 Else 0 End As EnrollmentTest
		, dbo.fn_GetTestCategory(c.startartdate, labs.reportedbydate) As BaselineTest
		INTO tmp_Labs    
		From 
		(
		Select distinct a.Ptn_pk, v.VisitId VisitID, a.TestName
		, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
				, Cast(a.[Parameter Result] As varchar(100))
				, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID
		Where Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' 
						ELSE a.TestResults END) As varchar(100))
				, Cast(a.[Parameter Result] As varchar(100))
				, Cast(a.TestResults1 As varchar(100))) 			
		!= ''''
		) labs  
		Inner Join tmp_PatientMaster m On labs.Ptn_pk = m.PatientPK
		Left Join 
		(Select a.PatientPK, Coalesce(a.PreviousARTStartDate, ART.FirstDispense) StartARTDate 
		From tmp_PatientMaster a Inner Join 
		(Select a.PatientPK
		, Min(a.DispenseDate) FirstDispense 
		From tmp_Pharmacy a Where a.TreatmentType = ''ART''
		Group By a.PatientPK) ART on a.PatientPK = ART.PatientPK) c On m.PatientPK = c.PatientPK')

	Exec('CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
		[dbo].[tmp_Labs] ([PatientPK] ASC )
		WITH (PAD_INDEX  = OFF
		, STATISTICS_NORECOMPUTE  = OFF
		, SORT_IN_TEMPDB = OFF
		, IGNORE_DUP_KEY = OFF
		, DROP_EXISTING = OFF
		, ONLINE = OFF
		, ALLOW_ROW_LOCKS  = ON
		, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]')

END			

GO