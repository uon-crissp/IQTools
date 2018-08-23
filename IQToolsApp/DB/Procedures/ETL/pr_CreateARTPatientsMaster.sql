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
		  e.CDCExitReason ExitReason,
		  e.CDCExitDate ExitDate
  
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
		Where coalesce(m.RegistrationAtCCC,m.registrationAtPMTCT) Is Not Null and c.startRegimen <> ''NVP''')
	
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