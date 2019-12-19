IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateARTPatientsMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateARTPatientsMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateARTPatientsMaster] 
AS 
BEGIN 
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_ARTPatients'') AND type in (N''U''))
		DROP TABLE tmp_ARTPatients')
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_a'') AND type in (N''U''))
		DROP TABLE temp_art_a')
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_b'') AND type in (N''U''))
		DROP TABLE temp_art_b')
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_c'') AND type in (N''U''))
		DROP TABLE temp_art_c')

	exec('Select Distinct b.PatientPK,
			a.StartARTDate,
			Min(b.Duration) Duration,
			Max(b.Drug) As StartRegimen,
			MAX(b.RegimenLine) RegimenLine
			into temp_art_a
		  From tmp_pharmacy b
			Inner Join (Select a.PatientPK,
			  Min(a.DispenseDate) StartARTDate			
			From tmp_pharmacy a
			Where a.TreatmentType = ''ART''
			Group By a.PatientPK) a On b.PatientPK = a.PatientPK And
			  b.DispenseDate = a.startARTDate And b.TreatmentType = ''ART''
		  Group By b.PatientPK,
			a.startARTDate')

	exec('Select Distinct b.PatientPK,
			a.LastARTDate,
			Min(b.Duration) Duration,
			Max(b.Drug) As LastRegimen,
			MAX(b.Provider) Provider,
			DateAdd(dd, Min(b.Duration), a.lastARTDate) ExpectedReturn,
			MAX(b.RegimenLine) RegimenLine
			into temp_art_b
		  From tmp_pharmacy b
			Inner Join (Select a.PatientPK,
			  Max(a.DispenseDate) LastARTDate
			From tmp_pharmacy a
			Where a.TreatmentType = ''ART''
			Group By a.PatientPK) a On b.PatientPK = a.PatientPK And
			  b.DispenseDate = a.lastARTDate and b.TreatmentType = ''ART''
		  Group By b.PatientPK,
			a.lastARTDate')

	exec('select distinct a.ptn_pk as PatientPK into temp_art_c 
				from ord_visit a
				inner join mst_visittype b on a.visittype=b.visittypeid
				where isnull(a.deleteflag,0)=0 
				and b.visitname in (''clinical encounter'',''ART History'',''01 Initial Evaluation Form'',''02 Follow Up Form'',''Initial and Follow up Visits'')')

	EXEC('CREATE CLUSTERED INDEX [IDX_PatientPK] ON [dbo].[temp_art_a] ([PatientPK] ASC )')
	EXEC('CREATE CLUSTERED INDEX [IDX_PatientPK] ON [dbo].[temp_art_b] ([PatientPK] ASC )')
	EXEC('CREATE CLUSTERED INDEX [IDX_PatientPK] ON [dbo].[temp_art_c] ([PatientPK] ASC )')

	EXEC('Select m.PatientPK,
		  m.PatientID,
		  m.SiteCode,
		  m.FacilityName,
		  m.SatelliteName,
		  m.DOB,
		  m.AgeEnrollment,
		  Cast((DateDiff(day, m.DOB, c.startARTDate) / 365.25) As decimal(5,1)) AgeARTStart,
		  m.AgeLastVisit,
		  m.AgeCurrent,
		  m.HIVTestDate,
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
			end as DaysMissed,

        (select top 1 y.Name from ord_Visit x inner join mst_Decode y on x.PatientClassification =y.ID
			where x.ptn_pk=m.patientpk order by x.visitdate desc) as PatientClassification,
		(select top 1 case when x.IsEnrolDifferenciatedCare=1 then ''Yes'' when x.IsEnrolDifferenciatedCare=0 then ''No'' end as dcm
			from ord_Visit x where x.ptn_pk=m.patientpk order by x.visitdate desc) as EnrolledonDifferentiatedCare,

		IPTStartDate, LastIPTDispense, IPTOutcome, DateOfOutcome as IPTDateOfOutcome
		, null as PatientType
		, null as PopulationCategory
		, null as Address
		, null as KeyPopulationType
		, null as PhoneNumber

		INTO tmp_ARTPatients
  
		From tmp_PatientMaster m
		  Inner Join temp_art_a c On m.PatientPK = c.PatientPK
		  Inner Join temp_art_b d On m.PatientPK = d.PatientPK
		  inner join temp_art_c f On m.PatientPK = f.PatientPK
		  Left Join tmp_lastStatus e On m.PatientPK = e.PatientPK
		  left join tmp_IPT g on m.patientpk = g.patientpk
		  ')
	
	exec('update tmp_ARTPatients set currentstatus=''Active'' where isnull(daysmissed,0) < 31 and currentstatus=''Lost - Not care-ended''')

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

	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_a'') AND type in (N''U''))
		DROP TABLE temp_art_a')
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_b'') AND type in (N''U''))
		DROP TABLE temp_art_b')
	EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''temp_art_c'') AND type in (N''U''))
		DROP TABLE temp_art_c')
END
GO