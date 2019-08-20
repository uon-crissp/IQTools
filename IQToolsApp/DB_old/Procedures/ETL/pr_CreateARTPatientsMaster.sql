IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateARTPatientsMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateARTPatientsMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateARTPatientsMaster] 
AS 
BEGIN 
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_ARTPatients'') AND type in (N''U''))
		DROP TABLE tmp_ARTPatients')

	EXEC('Select m.PatientPK,
		  m.PatientID,
		  m.SiteCode,
		  m.FacilityName,
		  m.SatelliteName,
		  m.DOB,
		  m.AgeEnrollment,
		  Cast((DateDiff(day, m.DOB, c.startARTDate) / 365.25) As decimal(5,1))
		  AgeARTStart,
		  m.AgeLastVisit,
		  Coalesce(m.RegistrationAtCCC, m.RegistrationAtPMTCT) RegistrationDate,
		  m.PatientSource,
		  m.Gender,
		  m.PatientName,
		  m.ServiceArea,
		  Coalesce(m.PreviousARTStartDate, c.startARTDate) StartARTDate,
		  m.PreviousARTStartDate,
		  m.PreviousARTExposure PreviousARTRegimen,
		  c.startARTDate StartARTAtThisFacility,
		  c.startRegimen StartRegimen,
		  c.RegimenLine StartRegimenLine,
		  d.lastARTDate LastARTDate,
		  d.lastRegimen LastRegimen,
		  d.RegimenLine LastRegimenLine,
		  d.Duration,
		  d.expectedReturn ExpectedReturn,
		  d.Provider,
		  m.LastVisit LastVisit,
		  m.NextAppointmentDate as LatestAppointmentDate,
		  e.CDCExitReason ExitReason,
		  e.CDCExitDate ExitDate,
		  dbo.fn_GetNextVisitDate(getdate(), m.PatientPK) as NextVisitDate,
		  dbo.fn_GetLastActiveDate(getdate(), m.PatientPK) as LastActiveDate,

		  case when [dbo].[fn_ActiveCCC](getdate(), m.PatientPK)=1 then ''Active''
			when [dbo].[fn_ActiveCCC](getdate(), m.PatientPK)=0 and e.CDCExitReason is not null then e.CDCExitReason
			else ''Lost - Not care-ended'' end as CurrentStatus,
		  
		  case 
		    when [dbo].[fn_ActiveCCC](getdate(), m.PatientPK)=1 
				and datediff(dd, dbo.fn_GetNextVisitDate(getdate(), m.PatientPK), getdate()) > 0 then datediff(dd, dbo.fn_GetNextVisitDate(getdate(), m.PatientPK), getdate()) 
			when [dbo].[fn_ActiveCCC](getdate(), m.PatientPK)=0 and e.CDCExitReason is null
				and datediff(dd, dbo.fn_GetNextVisitDate(getdate(), m.PatientPK), getdate()) > 0 then datediff(dd, dbo.fn_GetNextVisitDate(getdate(), m.PatientPK), getdate()) 
			end as DaysMissed

		INTO tmp_ARTPatients
  
		From tmp_PatientMaster m
		  Inner Join (Select Distinct b.PatientPK,
			a.StartARTDate,
			Min(b.Duration) Duration,
			Max(b.Drug) As StartRegimen,
			MAX(b.RegimenLine) RegimenLine
		  From tmp_pharmacy b
			Inner Join (Select a.PatientPK,
			  Min(a.DispenseDate) StartARTDate
			From tmp_pharmacy a
			Where a.TreatmentType = ''ART''
			Group By a.PatientPK) a On b.PatientPK = a.PatientPK And
			  b.DispenseDate = a.startARTDate And b.TreatmentType = ''ART''
		  Group By b.PatientPK,
			a.startARTDate) c On m.PatientPK = c.PatientPK
		  Inner Join 
		  ( Select Distinct b.PatientPK,
			a.LastARTDate,
			Min(b.Duration) Duration,
			Max(b.Drug) As LastRegimen,
			MAX(b.Provider) Provider,
			DateAdd(dd, Min(b.Duration), a.lastARTDate) ExpectedReturn,
			MAX(b.RegimenLine) RegimenLine
		  From tmp_pharmacy b
			Inner Join (Select a.PatientPK,
			  Max(a.DispenseDate) LastARTDate
			From tmp_pharmacy a
			Where a.TreatmentType = ''ART''
			Group By a.PatientPK) a On b.PatientPK = a.PatientPK And
			  b.DispenseDate = a.lastARTDate and b.TreatmentType = ''ART''
		  Group By b.PatientPK,
			a.lastARTDate) d On m.PatientPK = d.PatientPK
		  Left Join tmp_lastStatus e On m.PatientPK = e.PatientPK
		Where coalesce(m.RegistrationAtCCC,m.registrationAtPMTCT) Is Not Null 
		and m.patientpk in (
			select x.ptn_pk from ord_visit x 
			inner join mst_visittype y on x.visittype=y.visittypeid
			where isnull(x.deleteflag,0)=0 and y.visitname in (''Initial and Follow up Visits'', ''Clinical Encounter'')
			)')
	
	EXEC('CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
		[dbo].[tmp_ARTPatients] ([PatientPK] ASC )
		WITH (PAD_INDEX  = OFF
		, STATISTICS_NORECOMPUTE  = OFF
		, SORT_IN_TEMPDB = OFF
		, IGNORE_DUP_KEY = OFF
		, DROP_EXISTING = OFF
		, ONLINE = OFF
		, ALLOW_ROW_LOCKS  = ON
		, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
		 ')
END
GO