DELETE FROM aa_Queries WHERE qryName IN 
('IQC_CorePatientLineList','IQC_PatientAppointments'
,'IQC_MissedARVPickup','IQC_MissedAppointments'
,'IQC_NonARTCD4','IQC_NonARTNoCD4'
,'IQC_DetectableViralLoads', 'IQC_DueForViralLoad')

INSERT [dbo].[aa_Queries] ([qryName], [qryDefinition], [qryDescription], [qryType]
, [CreateDate], [UpdateDate], [Deleteflag], [MkTable], [Decrypt], [Hidden], [qryGroup], [UID]) 
VALUES (N'IQC_CorePatientLineList', N'Select Distinct m.PatientPK,
  m.FacilityName,
  m.SatelliteName,
  m.PatientID,
  m.DOB,
  m.Gender,
  m.RegistrationDate,
  m.PatientSource,
  e.StartARTDate,
  e.LastARTDate,
  e.Duration ARVsForXDays,
  e.ExpectedReturn,
  c2.CDCExitReason LastStatus,
  c2.CDCExitDate LastStatusDate,
  e.LastRegimen,
  e.LastARTDate LastRegimenDate,
  e.StartRegimen,
  e.StartARTDate StartRegimenDate,
  e3.eCD4,
  e3.eCD4Date,
  b.bCD4,
  b.bCD4Date,
  m6.m6CD4,
  m6.m6CD4Date,
  m12.m12CD4,
  m12.m12CD4Date,
  m.LastVisit,
  Case When c2.CDCExitReason = ''Stop'' Then c2.ExitDescription End As StopReason
From tmp_PatientMaster m
  Left Join tmp_ARTPatients e On m.PatientPK = e.PatientPK
  Left Join tmp_LastStatus c2 On m.PatientPK = c2.PatientPK
  Left Join IQC_eCD4 e3 On m.PatientPK = e3.PatientPK
  Left Join IQC_bCD4 b On m.PatientPK = b.PatientPK
  Left Join IQC_m6CD4 m6 On m.PatientPK = m6.PatientPK
  Left Join IQC_m12CD4 m12 On m.PatientPK = m12.PatientPK', N'Line List Of All Patients In The Facility', N'View'
  , CAST(N'2013-06-25' AS DateTime), CAST(N'2015-01-13' AS DateTime), NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_MissedARVPickup', N'Select Distinct a.PatientPK, a.SatelliteName, a.PatientID, a.PatientName
, c.LastARTDate, Floor(c.Duration) Duration, c.ExpectedReturn, DateDiff(dd, c.ExpectedReturn, Cast(@todate As datetime)) DaysOverdue
, b.PhoneNumber, b.Address, b.ContactPhoneNumber, b.ContactName, b.ContactAddress 
From tmp_ARTPatients a Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK 
Inner Join (Select a.PatientPK, Max(a.DispenseDate) LastARTDate, Min(a.Duration) Duration
, Max(a.ExpectedReturn) ExpectedReturn From tmp_Pharmacy a Where a.TreatmentType = ''ART'' And a.DispenseDate <= Cast(@ToDate As datetime) 
Group By a.PatientPK) c On a.PatientPK = c.PatientPK Left Join (Select Distinct tmp_LastStatus.PatientPK From tmp_LastStatus 
Where tmp_LastStatus.ExitDate <= Cast(@todate As datetime)) d On a.PatientPK = d.PatientPK 
Where DateDiff(dd, c.ExpectedReturn, Cast(@todate As datetime)) >= Cast(@NumDays As int) And d.PatientPK Is Null Order By DaysOverdue Desc'
, N'Line List Of ART Defaulters', N'Function'
, CAST(N'2013-06-25' AS DateTime)
, CAST(N'2015-01-13' AS DateTime), NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_MissedAppointments', N'Select Distinct a.PatientPK, a.SatelliteName, a.PatientID, a.PatientName, a.LastVisit
, IsNull(Convert(varchar(30),b.NextAppointmentDate,101), ''Missing Appointment Date'') NextAppointmentDate
,DateDiff(dd, Case When b.NextAppointmentDate Is Null Or b.NextAppointmentDate = Cast('''' As DateTime) Then DateAdd(dd, 30, a.LastVisit) Else b.NextAppointmentDate End
, Cast(@todate As datetime)) OverDueBy, a.PhoneNumber, a.Address, a.ContactName, a.ContactPhoneNumber
, a.ContactAddress From tmp_PatientMaster a Left Join (Select a.PatientPK, b.LastVisit, Max(a.NextAppointmentDate) NextAppointmentDate 
From tmp_ClinicalEncounters a Inner Join (Select a.PatientPK, Max(a.VisitDate) LastVisit From tmp_ClinicalEncounters a 
Where a.VisitDate <= Cast(@ToDate As datetime) Group By a.PatientPK) b On a.PatientPK = b.PatientPK And a.VisitDate = b.LastVisit 
Group By a.PatientPK, b.LastVisit) b On a.PatientPK = b.PatientPK Left Join (Select Distinct tmp_LastStatus.PatientPK
, tmp_LastStatus.ExitReason From tmp_LastStatus Where tmp_LastStatus.ExitDate <= Cast(@todate As datetime)) d 
On a.PatientPK = d.PatientPK Where DateDiff(dd, Case When b.NextAppointmentDate Is Null Or b.NextAppointmentDate = Cast('''' As DateTime) 
Then DateAdd(dd, 30, a.LastVisit) Else b.NextAppointmentDate End, Cast(@todate As datetime)) >= Cast(@NumDays As int) 
And a.RegistrationAtCCC <= Cast(@ToDate As Datetime) And (d.ExitReason Is Null Or d.ExitReason = ''Stop'') Order By OverDueBy Desc'
, N'Line List Of Missed Appointments', N'Function'
, CAST(N'2013-06-25' AS DateTime)
, CAST(N'2015-01-13' AS DateTime)
, NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_PatientAppointments', N'Select Distinct a.PatientPK,
  c.PatientID,
  c.SatelliteName CCC,
  c.PatientName,
  c.Gender,
  c.AgeLastVisit,
  b.LastVisit,
  f.LastService,
  a.NextAppointmentDate AppointmentDate,
  d.LastRegimen CurrentRegimen,
  e.lastCD4 LastCD4,
  e.lastCD4Date LastCD4Date,
  Case When (DateDiff(mm, e.lastCD4Date, a.NextAppointmentDate) Is Null Or
    DateDiff(mm, e.lastCD4Date, a.NextAppointmentDate) >= 5) And
    c.AgeLastVisit >= 6 Then ''Yes'' Else ''No'' End As DueForCD4,
  c.PhoneNumber,
  c.Address
From tmp_ClinicalEncounters a
  Inner Join (Select tmp_ClinicalEncounters.PatientPK,
    Max(tmp_ClinicalEncounters.VisitDate) LastVisit
  From tmp_ClinicalEncounters
  Where tmp_ClinicalEncounters.NextAppointmentDate Is Not Null
  Group By tmp_ClinicalEncounters.PatientPK) b On a.PatientPK = b.PatientPK And
    a.VisitDate = b.LastVisit
  Inner Join tmp_PatientMaster c On a.PatientPK = c.PatientPK
  Left Join tmp_ARTPatients d On a.PatientPK = d.PatientPK
  Left Join IQC_lastCD4 e On a.PatientPK = e.PatientPK
  Left Join (Select A.PatientPK,
    Max(A.Service) LastService
  From tmp_ClinicalEncounters A
    Inner Join (Select tmp_ClinicalEncounters.PatientPK,
      Max(tmp_ClinicalEncounters.VisitDate) LastVisit
    From tmp_ClinicalEncounters
    Group By tmp_ClinicalEncounters.PatientPK) B On A.PatientPK = B.PatientPK
      And A.VisitDate = B.LastVisit
  Group By A.PatientPK) f On f.PatientPK = c.PatientPK
Where a.NextAppointmentDate Is Not Null And a.NextAppointmentDate Between
  DateAdd(dd, -1, Cast(@AppDate As Datetime)) And DateAdd(dd, 0, Cast(@AppDate
  As Datetime))', N'Line List Of Appointments On A Specified Date', N'Function'
  , CAST(N'2013-06-25' AS DateTime)
  , CAST(N'2015-01-13' AS DateTime), NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_NonARTCD4', N'Select m.PatientPK,
  m.PatientID,
  m.SatelliteName,
  m.AgeLastVisit,
  m.Gender,
  m.RegistrationDate,
  m.PatientName,
  lcd4.lastCD4,
  lcd4.lastCD4Date,
  m.LastVisit
From tmp_PatientMaster m
  Inner Join IQC_lastCD4 lcd4 On m.PatientPK = lcd4.PatientPK
  Left Join tmp_ARTPatients d On lcd4.PatientPK = d.PatientPK
  Left Join tmp_LastStatus c On m.PatientPK = c.PatientPK
Where m.AgeLastVisit >= 6 And lcd4.lastCD4 Between Cast(@lowcd4 As int) And
  Cast(@highcd4 As int) And d.PatientPK Is Null And c.PatientPK Is Null And
  m.RegistrationAtCCC Is Not Null', N'Line List Of Non-ART Patients With A CD4 Count Between X And Y', N'Function'
  , CAST(N'2013-06-25' AS DateTime)
  , CAST(N'2015-01-13' AS DateTime), NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_NonARTNoCD4', N'Select m.PatientPK,
  m.PatientID,
  m.SatelliteName,
  m.AgeLastVisit,
  m.Gender,
  m.RegistrationDate,
  m.PatientName,
  m.LastVisit
From tmp_PatientMaster m
  Left Join IQC_lastCD4 l On m.PatientPK = l.PatientPK
  Left Join tmp_ARTPatients d On m.PatientPK = d.PatientPK
  Left Join tmp_LastStatus c On m.PatientPK = c.PatientPK
Where m.AgeLastVisit > 6 And l.PatientPK Is Null And d.PatientPK Is Null And
  c.PatientPK Is Null And m.RegistrationAtCCC Is Not Null', N'Line List Of Non-ART Patients With No CD4 Done', N'View'
  , CAST(N'2013-06-25' AS DateTime)
  , CAST(N'2015-01-13' AS DateTime)
  , NULL, NULL, NULL, NULL, N'IQCare', NULL)

,(N'IQC_DetectableViralLoads'
, N'Select A.FacilityName, A.SatelliteName, A.PatientPK, A.PatientID
, A.Gender, DateDiff(mm, A.StartARTDate, A.LastARTDate) MonthsOnART
, A.AgeLastVisit, A.ARTStatus, A.LastVL, A.LastVLDate, A.LastVLStatus
, A.LastARTDate, A.LastRegimen, A.LastRegimenLine
, A.AgeGroup From (Select Distinct a.FacilityName
, a.SatelliteName, a.PatientPK, a.PatientID, a.Gender, a.RegistrationDate
, a.AgeLastVisit, a.StartARTDate, b.LastVL, b.LastVLDate, b.LastVLStatus, a.LastARTDate
, a.LastRegimen, a.LastRegimenLine, Case When a.AgeLastVisit Between 0 And 0.9 Then ''<1'' When a.AgeLastVisit 
Between 1 And 4.9 Then ''1-4'' When a.AgeLastVisit Between 5 And 14.9 Then ''5-14'' When a.AgeLastVisit 
Between 15 And 19.9 Then ''15-19'' When a.AgeLastVisit >= 20 Then ''20+'' Else Null End As AgeGroup
, Case When DateDiff(dd, a.ExpectedReturn, GetDate()) > 90 And c.ExitReason Is Null Then ''Lost'' 
When DateDiff(dd, a.ExpectedReturn, GetDate()) Between 14 And 90 And c.ExitReason Is Null Then ''Defaulted'' When DateDiff(dd, a.ExpectedReturn, GetDate()) < 14 And c.ExitReason Is Null Then ''Active'' Else c.ExitReason End As ARTStatus From tmp_ARTPatients a Left Join (Select a.PatientPK, Max(b.LVLDate) LastVLDate, Max(a.VLResult) LastVL, Max(a.VLStatus) LastVLStatus From (Select a.PatientPK, b.SatelliteName, a.OrderedbyDate VLDate, Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) VLResult, Case When a.TestName Like ''%undetect%'' Or Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) < 1000 Then ''UNDETECTABLE'' When Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) >= 1000 Then ''DETECTABLE'' Else Null End As VLStatus From tmp_Labs a Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK Where a.TestName Like ''%viral%'' And IsNumeric(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) = 1) a Inner Join (Select a.PatientPK, Max(a.OrderedbyDate) LVLDate From tmp_Labs a Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK Where a.TestName Like ''%viral%'' Group By a.PatientPK) b On a.PatientPK = b.PatientPK And a.VLDate = b.LVLDate Group By a.PatientPK) b On a.PatientPK = b.PatientPK Left Join tmp_LastStatus c On a.PatientPK = c.PatientPK) A Where A.ARTStatus In (''Active'', ''Defaulted'') And A.LastVL >= Cast(@LowVL As int)', N'Line List Of Patients With A Last Viral Load Above Specified Value', NULL, CAST(N'2015-07-03' AS DateTime), NULL, NULL, NULL, NULL, NULL, N'All', NULL)

,(N'IQC_DueForViralLoad'
, N'Select A.FacilityName, A.SatelliteName, A.PatientPK, A.PatientID, A.Gender
, DateDiff(mm, A.StartARTDate, A.LastARTDate) MonthsOnART, Case When A.PregnantNow = 1 And DateDiff(mm, A.StartARTDate, A.LastARTDate) > 6 Then ''Pregnant'' When DateDiff(mm, A.StartARTDate, A.LastARTDate) > 6 And A.LastVL Is Null Then ''First VL'' 
When A.LastVL >= 1000 And DateDiff(mm, A.LastVLDate, GetDate()) > 3 Then ''Retest'' 
When DateDiff(mm, A.LastVLDate, GetDate()) > 12 Then ''Annual VL'' Else Null End As Eligible
, A.AgeLastVisit, A.ARTStatus, A.LastVL, A.LastVLDate, A.LastVLStatus, A.LastARTDate
, A.LastRegimen, A.LastRegimenLine, A.AgeGroup From (Select Distinct a.FacilityName
, a.SatelliteName, a.PatientPK, a.PatientID, a.Gender, a.RegistrationDate, a.AgeLastVisit
, a.StartARTDate, b.LastVL, b.LastVLDate, d.PregnantNow, b.LastVLStatus, a.LastARTDate
, a.LastRegimen, a.LastRegimenLine, Case When a.AgeLastVisit Between 0 And 0.9 Then ''<1'' When a.AgeLastVisit 
Between 1 And 4.9 Then ''1-4'' When a.AgeLastVisit Between 5 And 14.9 Then ''5-14'' When a.AgeLastVisit 
Between 15 And 19.9 Then ''15-19'' When a.AgeLastVisit >= 20 Then ''20+'' Else Null End As AgeGroup
, Case When DateDiff(dd, a.ExpectedReturn, GetDate()) > 90 And c.ExitReason Is Null Then ''Lost'' 
When DateDiff(dd, a.ExpectedReturn, GetDate()) Between 14 And 90 And c.ExitReason Is Null Then ''Defaulted'' 
When DateDiff(dd, a.ExpectedReturn, GetDate()) < 14 And c.ExitReason Is Null Then ''Active'' Else c.ExitReason 
End As ARTStatus From tmp_ARTPatients a Left Join (Select a.PatientPK, Max(b.LVLDate) LastVLDate, Max(a.VLResult) LastVL
, Max(a.VLStatus) LastVLStatus From (Select a.PatientPK, b.SatelliteName, a.OrderedbyDate VLDate
, Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) VLResult, Case When a.TestName Like ''%undetect%'' Or 
Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) < 1000 Then ''UNDETECTABLE'' 
When Floor(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) >= 1000 Then ''DETECTABLE'' Else Null 
End As VLStatus From tmp_Labs a Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK Where a.TestName 
Like ''%viral%'' And IsNumeric(Replace(Replace(a.TestResult, ''<'', ''''), ''>'', '''')) = 1) a 
Inner Join (Select a.PatientPK, Max(a.OrderedbyDate) LVLDate From tmp_Labs a Inner Join tmp_PatientMaster b 
On a.PatientPK = b.PatientPK Where a.TestName Like ''%viral%'' Group By a.PatientPK) b On a.PatientPK = b.PatientPK 
And a.VLDate = b.LVLDate Group By a.PatientPK) b On a.PatientPK = b.PatientPK Left Join tmp_LastStatus c 
On a.PatientPK = c.PatientPK Left Join tmp_Pregnancies d On a.PatientPK = d.PatientPK) A Where Case When A.PregnantNow = 1 And DateDiff(mm, A.StartARTDate, A.LastARTDate) > 6 Then ''Pregnant'' When DateDiff(mm, A.StartARTDate, A.LastARTDate) > 6 And A.LastVL Is Null Then ''First VL'' When A.LastVL >= 1000 And DateDiff(mm, A.LastVLDate, GetDate()) > 3 Then ''Retest'' When DateDiff(mm, A.LastVLDate, GetDate()) > 12 Then ''Annual VL'' Else Null End Is Not Null And A.ARTStatus In (''Active'', ''Defaulted'')', N'Line List Of Patients Due For a Viral Load', NULL, CAST(N'2015-07-03' AS DateTime), NULL, NULL, NULL, NULL, NULL, N'All', NULL)

