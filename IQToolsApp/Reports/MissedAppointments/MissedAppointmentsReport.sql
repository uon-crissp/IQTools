Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'Missed_Appointments_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'Missed_Appointments_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'Missed_Appointments_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('Missed_Appointments_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'TAS Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('TAS Reports',1)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'TAS Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'Missed_Appointments_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'Missed_Appointments_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'Missed_Appointments_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'Missed_Appointments_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('Missed_Appointments_Report'
,'Missed Appointments Report'
,'Missed Appointments Report'
, @CatID
, 'Missed_Appointments_Report_Template.xlsx'
, 'Summary'
, @ReportGroupID
, NULL)

SELECT @ReportID = IDENT_CURRENT('aa_Reports')

INSERT INTO dbo.aa_ReportParameters
(
    ReportID,
    ParamName,
    ParamLabel,
    ParamType,
    ParamDefaultValue,
    Position,
    CreateDate,
    UpdateDate,
    DeleteFlag
)
VALUES
(   @ReportID,         -- ReportID - int
    'iqtDatehelper',        -- ParamName - varchar(100)
    'Select Reporting Period',        -- ParamLabel - varchar(100)
    'datehelper',        -- ParamType - varchar(50)
    'monthly',        -- ParamDefaultValue - varchar(100)
    1,         -- Position - int
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL       
),
(   @ReportID,         -- ReportID - int
    'linelist',        -- ParamName - varchar(100)
    'Include Line Lists',        -- ParamLabel - varchar(100)
    'checkbox',        -- ParamType - varchar(50)
    'false',        -- ParamDefaultValue - varchar(100)
    2,         -- Position - int
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL       
)

IF EXISTS(SELECT sbCatID FROM aa_SBCategory WHERE catID = @CatID)
DELETE FROM dbo.aa_SBCategory WHERE catID = @CatID

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       
    @CatID,        
    NULL,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,         
    NULL,       
    NULL,     
    NULL   
)

--Header
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_00_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_00_Header'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_00_Header',       -- qryName - nvarchar(50)
    N'SELECT TOP 1 FacilityName , cast(@fromdate as varchar(10)) + '' - '' + cast(@todate as varchar(10)) ReportingPeriod  from tmp_PatientMaster',       -- qryDefinition - nvarchar(max)
    N'MissedAppointments_00_Header',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)

INSERT INTO dbo.aa_XLMaps
(
    xlsCell,
    qryID,
    xlsTitle,
    Deleteflag,
    CreateDate,
    xlCatID,
    DHISElementID,
    CategoryOptionID
)
VALUES
(   N'C2',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C3',       
    @QueryID,         
    N'ReportingPeriod',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Visits Vs Valid Appointments
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_01_ValidAppointments')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_01_ValidAppointments'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_01_ValidAppointments',       -- qryName - nvarchar(50)
    N'WITH Exits AS
  (SELECT PatientPK,
          MAX(ExitDate) ExitDate
   FROM tmp_LastStatus
   WHERE ExitReason IN (''HIV Negative'',''Transfer'')
   GROUP BY PatientPK),

     Visits AS
  (SELECT DISTINCT a.ptn_pk,
                   CASE
                       WHEN YEAR(a.visitdate) = 1900 THEN NULL
                       ELSE CAST(a.VisitDate AS DATE)
                   END AS VisitDate
   FROM ord_visit a
   INNER JOIN mst_visittype b ON a.visittype = b.visittypeid
   LEFT JOIN DTL_FBCUSTOMFIELD_HEI_Part_II c ON a.Ptn_Pk = c.Ptn_pk
   AND a.Visit_Id = c.Visit_Pk
   LEFT JOIN Exits d ON a.Ptn_Pk = d.PatientPK
   AND a.VisitDate = d.ExitDate
   WHERE visitdate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND (a.DeleteFlag IS NULL
          OR a.DeleteFlag = 0)
     AND b.VisitName IN (''Initial and Follow up Visits'',
                         ''Scheduler'',
                         ''Pharmacy Order'',
                         ''HEI Part II'',
						 ''Clinical Encounter'')
     AND d.PatientPK IS NULL),


     BlueGreenCardVisits AS
  (SELECT a.ptn_pk,
          CASE
              WHEN YEAR(a.visitdate) = 1900 THEN NULL
              ELSE CAST(a.VisitDate AS DATE)
          END AS VisitDate,
          CASE
              WHEN YEAR(c.AppDate) = 1900 THEN NULL
              ELSE CAST(c.AppDate AS DATE)
          END AS BlueCardAppointmentDate
   FROM ord_visit a
   INNER JOIN mst_visittype b ON a.visittype = b.visittypeid
   LEFT JOIN dtl_PatientAppointment c ON a.Ptn_Pk = c.Ptn_pk
   AND a.Visit_Id = c.Visit_pk
   WHERE visitdate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND b.visitname IN (''Initial and Follow up Visits'',''Clinical Encounter'')),



     SchedularVisits AS
  (SELECT a.ptn_pk,
          CASE
              WHEN YEAR(a.visitdate) = 1900 THEN NULL
              ELSE CAST(a.VisitDate AS DATE)
          END AS VisitDate,
          CASE
              WHEN YEAR(c.AppDate) = 1900 THEN NULL
              ELSE CAST(c.AppDate AS DATE)
          END AS SchedularAppointmentDate
   FROM ord_visit a
   INNER JOIN mst_visittype b ON a.visittype = b.visittypeid
   LEFT JOIN dtl_PatientAppointment c ON a.Ptn_Pk = c.Ptn_pk
   AND a.Visit_Id = c.Visit_pk
   WHERE visitdate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND b.visitname = ''Scheduler''),



     PharmacyVisits AS
  (SELECT a.ptn_pk,
          CASE
              WHEN YEAR(a.visitdate) = 1900 THEN NULL
              ELSE CAST(a.VisitDate AS DATE)
          END AS VisitDate,
          CASE
              WHEN YEAR(c.AppDate) = 1900 THEN NULL
              ELSE CAST(c.AppDate AS DATE)
          END AS PharmacyAppointmentDate
   FROM ord_visit a
   INNER JOIN mst_visittype b ON a.visittype = b.visittypeid
   LEFT JOIN dtl_PatientAppointment c ON a.Ptn_Pk = c.Ptn_pk
   AND a.Visit_Id = c.Visit_pk
   WHERE visitdate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND b.visitname = ''Pharmacy Order''),


     HEIVisits AS
  (SELECT a.ptn_pk,
          CASE
              WHEN YEAR(a.visitdate) = 1900 THEN NULL
              ELSE CAST(a.VisitDate AS DATE)
          END AS VisitDate,
          CASE
              WHEN YEAR(c.AppointmentDate) = 1900 THEN NULL
              ELSE CAST(c.AppointmentDate AS DATE)
          END AS HEICardAppointmentDate
   FROM ord_visit a
   INNER JOIN mst_visittype b ON a.visittype = b.visittypeid
   INNER JOIN DTL_FBCUSTOMFIELD_HEI_Part_II c ON a.Ptn_Pk = c.Ptn_pk
   AND a.Visit_Id = c.Visit_Pk
   WHERE visitdate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND b.visitname = ''HEI Part II''),



     Appointments AS
  (SELECT DISTINCT a.Ptn_Pk,
                   a.VisitDate,
                   b.BlueCardAppointmentDate,
                   c.SchedularAppointmentDate,
                   d.PharmacyAppointmentDate,
                   e.HEICardAppointmentDate,
                   CASE
                       WHEN COALESCE(b.BlueCardAppointmentDate, c.SchedularAppointmentDate, d.PharmacyAppointmentDate, e.HEICardAppointmentDate) IS NULL THEN 1
                       ELSE 0
                   END AS AppointmentDateMissing,
                   CASE
                       WHEN b.BlueCardAppointmentDate IS NOT NULL
                            AND c.SchedularAppointmentDate IS NOT NULL
                            AND b.BlueCardAppointmentDate != c.SchedularAppointmentDate THEN 1
                       WHEN b.BlueCardAppointmentDate IS NOT NULL
                            AND d.PharmacyAppointmentDate IS NOT NULL
                            AND b.BlueCardAppointmentDate != d.PharmacyAppointmentDate THEN 1
                       WHEN c.SchedularAppointmentDate IS NOT NULL
                            AND d.PharmacyAppointmentDate IS NOT NULL
                            AND c.SchedularAppointmentDate != d.PharmacyAppointmentDate THEN 1
                       WHEN b.BlueCardAppointmentDate IS NOT NULL
                            AND e.HEICardAppointmentDate IS NOT NULL
                            AND b.BlueCardAppointmentDate != e.HEICardAppointmentDate THEN 1
                       WHEN c.SchedularAppointmentDate IS NOT NULL
                            AND e.HEICardAppointmentDate IS NOT NULL
                            AND c.SchedularAppointmentDate != e.HEICardAppointmentDate THEN 1
                       WHEN d.PharmacyAppointmentDate IS NOT NULL
                            AND e.HEICardAppointmentDate IS NOT NULL
                            AND d.PharmacyAppointmentDate != e.HEICardAppointmentDate THEN 1
                       ELSE 0
                   END AS InvalidAppointmentDate
   FROM Visits a
   LEFT JOIN BlueGreenCardVisits b ON a.Ptn_Pk = b.Ptn_Pk
   AND a.VisitDate = b.VisitDate
   LEFT JOIN SchedularVisits c ON a.Ptn_Pk = c.Ptn_Pk
   AND a.VisitDate = c.VisitDate
   LEFT JOIN PharmacyVisits d ON a.Ptn_Pk = d.Ptn_Pk
   AND a.VisitDate = d.VisitDate
   LEFT JOIN HEIVisits e ON a.Ptn_Pk = e.Ptn_Pk
   AND a.VisitDate = e.VisitDate)
SELECT COUNT(a.ptn_pk) Visits,
       COUNT(a.ptn_pk) - (SUM(AppointmentDateMissing) + SUM(InvalidAppointmentDate)) ValidAppointments
FROM Appointments a
INNER JOIN tmp_PatientMaster b ON a.ptn_pk = b.PatientPK',
    N'MissedAppointments_01_ValidAppointments',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)

INSERT INTO dbo.aa_XLMaps
(
    xlsCell,
    qryID,
    xlsTitle,
    Deleteflag,
    CreateDate,
    xlCatID,
    DHISElementID,
    CategoryOptionID
)
VALUES
(   N'H5',       
    @QueryID,         
    N'Visits',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H6',       
    @QueryID,         
    N'ValidAppointments',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Missed Appointments
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_02_MissedAppointments')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_02_MissedAppointments'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_02_MissedAppointments',       -- qryName - nvarchar(50)
    N'WITH exits AS    (Select a.PatientPK, a.ExitDate, a.ExitReason   FROM (  Select DISTINCT a.Ptn_Pk PatientPK   , b.ExitDate   , CASE WHEN c.Name like ''%hiv%negative%'' THEN ''HIV Negative''       WHEN c.Name IN (''Death'',''Infant Died'') THEN ''Death''       WHEN c.Name Like ''%Lost%'' OR c.Name Like ''%ltfu%'' THEN ''Lost''       WHEN c.Name like ''%Transfer%'' THEN ''Transfer''     ELSE c.Name END AS ExitReason    FROM dtl_PatientCareEnded a INNER JOIN      (select a.Ptn_Pk, MAX(CareEndedDate) ExitDate     from dtl_patientcareended a inner join    dtl_patienttrackingcare b on a.ptn_pk = b.ptn_pk    and a.trackingid = b.trackingid    where b.moduleid in (2,5,203)    and a.CareEnded = 1 GROUP BY a.Ptn_Pk) b ON a.Ptn_Pk = b.Ptn_Pk AND a.CareEndedDate = b.ExitDate     AND a.CareEnded = 1   INNER JOIN mst_Decode c ON a.PatientExitReason = c.ID) a  INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK  WHERE DATEDIFF(dd, a.ExitDate, b.LastVisit) < 2)      , appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select DISTINCT PatientPK, cast(NextAppointmentDate as date) appointmentdate   from tmp_ClinicalEncounters  where NextAppointmentDate Between CAST(@fromdate as date) AND CAST(@todate as date)) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  group by  b.PatientPK, a.appointmentdate)    , earlyappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   , DATEDIFF(dd, a.appointmentdate, a.appointmentmeton) earlyby  from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.visitappointmentmade   and cast(b.VisitDate as date) < a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , ontimeappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK   and cast(b.VisitDate as date) = a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , lateappointments as (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate, a.appointmentmeton   , datediff(dd, a.appointmentdate, a.appointmentmeton) lateby  FROM (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , min(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.appointmentdate   and cast(b.VisitDate as date) <= cast(@todate as date)  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  ) a)    , appointment_analysis as (  select a.PatientPK  , a.visit_appointmentmade   , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) early_late_by  from   (select a.PatientPK, a.visitappointmentmade visit_appointmentmade  , a.appointmentdate  , case when c.PatientPK is not null then ''ontime''  when b.PatientPK is not null then ''early''  when d.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when   c.PatientPK is not null then c.appointmentmeton  when b.PatientPK is not null then b.appointmentmeton  when d.PatientPK is not null then d.appointmentmeton  else cast(@todate as date) end as appointment_analysisdate  from appointments a left join earlyappointments b on a.PatientPK = b.PatientPK and a.appointmentdate = b.appointmentdate  left join ontimeappointments c on a.PatientPK = c.PatientPK and a.appointmentdate = c.appointmentdate  left join lateappointments d on a.PatientPK = d.PatientPK and a.appointmentdate = d.appointmentdate) a)    , prereportingperiod_appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select PatientPK   , max(cast(NextAppointmentDate as date)) appointmentdate    from tmp_ClinicalEncounters   where NextAppointmentDate < CAST(@fromdate as date)   group by PatientPK) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  where a.appointmentdate > b.VisitDate  group by  b.PatientPK, a.appointmentdate)    , pre_reportperiod_visits as (  select patientpk, max(visitdate) lastvisit  from tmp_clinicalencounters   where VisitDate < cast(@fromdate as date)  group by PatientPK)    , previously_missedappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  from prereportingperiod_appointments a left join pre_reportperiod_visits b   on a.PatientPK = b.PatientPK  left join (select distinct patientpk from exits where exitdate < cast(@fromdate as date)) c on a.PatientPK = c.PatientPK  where b.lastvisit <= a.visitappointmentmade   and c.PatientPK is null)    , missedappointments as (  select a.PatientPK  , a.visit_appointmentmade  , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , a.early_late_by lateby  from appointment_analysis a where appointment_status in (''late'',''not met'')  and a.early_late_by > 0  union  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) lateby    from (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , case when b.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when b.PatientPK is not null then b.visitdate  else cast(@todate as date) end as appointment_analysisdate  from previously_missedappointments a   left join (select patientpk, min(cast(visitdate as date)) visitdate from tmp_ClinicalEncounters   where VisitDate between cast(@fromdate as date) and cast(@todate as date)  group by patientpk  ) b on a.PatientPK = b.PatientPK) a)    select  case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end as category  , count(distinct a.patientpk) total  from missedappointments a   inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK  group by  case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end',       -- qryDefinition - nvarchar(max)
    N'MissedAppointments_02_MissedAppointments',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)

INSERT INTO dbo.aa_XLMaps
(
    xlsCell,
    qryID,
    xlsTitle,
    Deleteflag,
    CreateDate,
    xlCatID,
    DHISElementID,
    CategoryOptionID
)
VALUES
(   N'D10',       
    @QueryID,         
    N'1-13total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E10',       
    @QueryID,         
    N'14-59total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'F10',       
    @QueryID,         
    N'60-89total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G10',       
    @QueryID,         
    N'90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Traced Back
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_03_TracedBack')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_03_TracedBack'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_03_TracedBack',       -- qryName - nvarchar(50)
    N'WITH exits AS    (Select a.PatientPK, a.ExitDate, a.ExitReason   FROM (  Select DISTINCT a.Ptn_Pk PatientPK   , b.ExitDate   , CASE WHEN c.Name like ''%hiv%negative%'' THEN ''HIV Negative''       WHEN c.Name IN (''Death'',''Infant Died'') THEN ''Death''       WHEN c.Name Like ''%Lost%'' OR c.Name Like ''%ltfu%'' THEN ''Lost''       WHEN c.Name like ''%Transfer%'' THEN ''Transfer''     ELSE c.Name END AS ExitReason    FROM dtl_PatientCareEnded a INNER JOIN      (select a.Ptn_Pk, MAX(CareEndedDate) ExitDate     from dtl_patientcareended a inner join    dtl_patienttrackingcare b on a.ptn_pk = b.ptn_pk    and a.trackingid = b.trackingid    where b.moduleid in (2,5,203)    and a.CareEnded = 1 GROUP BY a.Ptn_Pk) b ON a.Ptn_Pk = b.Ptn_Pk AND a.CareEndedDate = b.ExitDate     AND a.CareEnded = 1   INNER JOIN mst_Decode c ON a.PatientExitReason = c.ID) a    INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK  WHERE DATEDIFF(dd, a.ExitDate, b.LastVisit) < 2)    , appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select DISTINCT PatientPK, cast(NextAppointmentDate as date) appointmentdate   from tmp_ClinicalEncounters  where NextAppointmentDate Between CAST(@fromdate as date) AND CAST(@todate as date)) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  group by  b.PatientPK, a.appointmentdate)    , earlyappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   , DATEDIFF(dd, a.appointmentdate, a.appointmentmeton) earlyby  from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.visitappointmentmade   and cast(b.VisitDate as date) < a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , ontimeappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK   and cast(b.VisitDate as date) = a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , lateappointments as (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate, a.appointmentmeton   , datediff(dd, a.appointmentdate, a.appointmentmeton) lateby  FROM (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , min(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.appointmentdate   and cast(b.VisitDate as date) <= cast(@todate as date)  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  ) a)    , appointment_analysis as (  select a.PatientPK  , a.visit_appointmentmade   , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) early_late_by  from     (select a.PatientPK, a.visitappointmentmade visit_appointmentmade  , a.appointmentdate  , case when c.PatientPK is not null then ''ontime''  when b.PatientPK is not null then ''early''  when d.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when   c.PatientPK is not null then c.appointmentmeton  when b.PatientPK is not null then b.appointmentmeton  when d.PatientPK is not null then d.appointmentmeton  else cast(@todate as date) end as appointment_analysisdate  from appointments a left join earlyappointments b on a.PatientPK = b.PatientPK and a.appointmentdate = b.appointmentdate  left join ontimeappointments c on a.PatientPK = c.PatientPK and a.appointmentdate = c.appointmentdate  left join lateappointments d on a.PatientPK = d.PatientPK and a.appointmentdate = d.appointmentdate) a)    , prereportingperiod_appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select PatientPK   , max(cast(NextAppointmentDate as date)) appointmentdate    from tmp_ClinicalEncounters   where NextAppointmentDate < CAST(@fromdate as date)   group by PatientPK) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  where a.appointmentdate > b.VisitDate  group by  b.PatientPK, a.appointmentdate)    , pre_reportperiod_visits as (  select patientpk, max(visitdate) lastvisit  from tmp_clinicalencounters   where VisitDate < cast(@fromdate as date)  group by PatientPK)    , previously_missedappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  from prereportingperiod_appointments a left join pre_reportperiod_visits b   on a.PatientPK = b.PatientPK  left join (select distinct patientpk from exits where exitdate < cast(@fromdate as date)) c on a.PatientPK = c.PatientPK  where b.lastvisit <= a.visitappointmentmade   and c.PatientPK is null)    , missedappointments as (  select a.PatientPK  , a.visit_appointmentmade  , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , a.early_late_by lateby  from appointment_analysis a where appointment_status in (''late'',''not met'')  and a.early_late_by > 0  union  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) lateby    from (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , case when b.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when b.PatientPK is not null then b.visitdate  else cast(@todate as date) end as appointment_analysisdate  from previously_missedappointments a   left join (select patientpk, min(cast(visitdate as date)) visitdate from tmp_ClinicalEncounters   where VisitDate between cast(@fromdate as date) and cast(@todate as date)  group by patientpk  ) b on a.PatientPK = b.PatientPK) a)    select   case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end as category  , count(distinct a.patientpk) total  from missedappointments a   inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK  where a.appointment_status = ''late''  group by  case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end',       -- qryDefinition - nvarchar(max)
    N'MissedAppointments_03_TracedBack',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)

INSERT INTO dbo.aa_XLMaps
(
    xlsCell,
    qryID,
    xlsTitle,
    Deleteflag,
    CreateDate,
    xlCatID,
    DHISElementID,
    CategoryOptionID
)
VALUES
(   N'D11',       
    @QueryID,         
    N'1-13total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E11',       
    @QueryID,         
    N'14-59total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'F11',       
    @QueryID,         
    N'60-89total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G11',       
    @QueryID,         
    N'90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Not Traced Back
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_04_NotTracedBack')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_04_NotTracedBack'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_04_NotTracedBack',       -- qryName - nvarchar(50)
    N'WITH exits AS    (Select a.PatientPK, a.ExitDate, a.ExitReason   FROM (  Select DISTINCT a.Ptn_Pk PatientPK   , b.ExitDate   , CASE WHEN c.Name like ''%hiv%negative%'' THEN ''HIV Negative''       WHEN c.Name IN (''Death'',''Infant Died'') THEN ''Death''       WHEN c.Name Like ''%Lost%'' OR c.Name Like ''%ltfu%'' THEN ''Lost''       WHEN c.Name like ''%Transfer%'' THEN ''Transfer''     ELSE c.Name END AS ExitReason    FROM dtl_PatientCareEnded a INNER JOIN      (select a.Ptn_Pk, MAX(CareEndedDate) ExitDate     from dtl_patientcareended a inner join    dtl_patienttrackingcare b on a.ptn_pk = b.ptn_pk    and a.trackingid = b.trackingid    where b.moduleid in (2,5,203)    and a.CareEnded = 1 GROUP BY a.Ptn_Pk) b ON a.Ptn_Pk = b.Ptn_Pk AND a.CareEndedDate = b.ExitDate     AND a.CareEnded = 1   INNER JOIN mst_Decode c ON a.PatientExitReason = c.ID) a    INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK  WHERE DATEDIFF(dd, a.ExitDate, b.LastVisit) < 2)    , appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select DISTINCT PatientPK, cast(NextAppointmentDate as date) appointmentdate   from tmp_ClinicalEncounters  where NextAppointmentDate Between CAST(@fromdate as date) AND CAST(@todate as date)) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  group by  b.PatientPK, a.appointmentdate)    , earlyappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   , DATEDIFF(dd, a.appointmentdate, a.appointmentmeton) earlyby  from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.visitappointmentmade   and cast(b.VisitDate as date) < a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , ontimeappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK   and cast(b.VisitDate as date) = a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , lateappointments as (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate, a.appointmentmeton   , datediff(dd, a.appointmentdate, a.appointmentmeton) lateby  FROM (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , min(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.appointmentdate   and cast(b.VisitDate as date) <= cast(@todate as date)  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  ) a)  , appointment_analysis as (  select a.PatientPK  , a.visit_appointmentmade   , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) early_late_by  from     (select a.PatientPK, a.visitappointmentmade visit_appointmentmade  , a.appointmentdate  , case when c.PatientPK is not null then ''ontime''  when b.PatientPK is not null then ''early''  when d.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when   c.PatientPK is not null then c.appointmentmeton  when b.PatientPK is not null then b.appointmentmeton  when d.PatientPK is not null then d.appointmentmeton  else cast(@todate as date) end as appointment_analysisdate  from appointments a left join earlyappointments b on a.PatientPK = b.PatientPK and a.appointmentdate = b.appointmentdate  left join ontimeappointments c on a.PatientPK = c.PatientPK and a.appointmentdate = c.appointmentdate  left join lateappointments d on a.PatientPK = d.PatientPK and a.appointmentdate = d.appointmentdate) a)    , prereportingperiod_appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select PatientPK   , max(cast(NextAppointmentDate as date)) appointmentdate    from tmp_ClinicalEncounters   where NextAppointmentDate < CAST(@fromdate as date)   group by PatientPK) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  where a.appointmentdate > b.VisitDate  group by  b.PatientPK, a.appointmentdate)    , pre_reportperiod_visits as (  select patientpk, max(visitdate) lastvisit  from tmp_clinicalencounters   where VisitDate < cast(@fromdate as date)  group by PatientPK)    , previously_missedappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  from prereportingperiod_appointments a left join pre_reportperiod_visits b   on a.PatientPK = b.PatientPK  left join (select distinct patientpk from exits where exitdate < cast(@fromdate as date)) c on a.PatientPK = c.PatientPK  where b.lastvisit <= a.visitappointmentmade   and c.PatientPK is null)    , missedappointments as (  select a.PatientPK  , a.visit_appointmentmade  , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , a.early_late_by lateby  from appointment_analysis a where appointment_status in (''late'',''not met'')  and a.early_late_by > 0  union  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) lateby    from (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , case when b.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when b.PatientPK is not null then b.visitdate  else cast(@todate as date) end as appointment_analysisdate  from previously_missedappointments a   left join (select patientpk, min(cast(visitdate as date)) visitdate from tmp_ClinicalEncounters   where VisitDate between cast(@fromdate as date) and cast(@todate as date)  group by patientpk  ) b on a.PatientPK = b.PatientPK) a)    select   case when b.ExitReason is null then ''nottracedback'' else b.ExitReason end as patientstatus  ,case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end as category  , count(distinct a.patientpk) total  from missedappointments a left join (select patientpk, exitreason from  tmp_LastStatus where exitdate between cast(@fromdate as date) and cast(@todate as date)) b  on a.PatientPK = b.PatientPK  inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK  where a.appointment_status = ''not met''  group by  case when b.ExitReason is null then ''nottracedback'' else b.ExitReason end,  case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end',       -- qryDefinition - nvarchar(max)
    N'MissedAppointments_04_NotTracedBack',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Missed_Appointments_Report',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)

INSERT INTO dbo.aa_XLMaps
(
    xlsCell,
    qryID,
    xlsTitle,
    Deleteflag,
    CreateDate,
    xlCatID,
    DHISElementID,
    CategoryOptionID
)
VALUES
(   N'D12',       
    @QueryID,         
    N'death1-13total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E12',       
    @QueryID,         
    N'death14-59total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'F12',       
    @QueryID,         
    N'death60-89total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G12',       
    @QueryID,         
    N'death90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,(   N'D13',       
    @QueryID,         
    N'transfer1-13total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E13',       
    @QueryID,         
    N'transfer14-59total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'F13',       
    @QueryID,         
    N'transfer60-89total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G13',       
    @QueryID,         
    N'transfer90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G14',       
    @QueryID,         
    N'lost90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,(   N'D15',       
    @QueryID,         
    N'nottracedback1-13total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E15',       
    @QueryID,         
    N'nottracedback14-59total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'F15',       
    @QueryID,         
    N'nottracedback60-89total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(   N'G15',       
    @QueryID,         
    N'nottracedback90+total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--MissedAppointments_05_LineList
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_05_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MissedAppointments_05_LineList'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'MissedAppointments_05_LineList',       -- qryName - nvarchar(50)
    N'WITH exits AS    (Select a.PatientPK, a.ExitDate, a.ExitReason   FROM (  Select DISTINCT a.Ptn_Pk PatientPK   , b.ExitDate   , CASE WHEN c.Name like ''%hiv%negative%'' THEN ''HIV Negative''       WHEN c.Name IN (''Death'',''Infant Died'') THEN ''Death''       WHEN c.Name Like ''%Lost%'' OR c.Name Like ''%ltfu%'' THEN ''Lost''       WHEN c.Name like ''%Transfer%'' THEN ''Transfer''     ELSE c.Name END AS ExitReason    FROM dtl_PatientCareEnded a INNER JOIN      (select a.Ptn_Pk, MAX(CareEndedDate) ExitDate     from dtl_patientcareended a inner join    dtl_patienttrackingcare b on a.ptn_pk = b.ptn_pk    and a.trackingid = b.trackingid    where b.moduleid in (2,5,203)    and a.CareEnded = 1 GROUP BY a.Ptn_Pk) b ON a.Ptn_Pk = b.Ptn_Pk AND a.CareEndedDate = b.ExitDate     AND a.CareEnded = 1   INNER JOIN mst_Decode c ON a.PatientExitReason = c.ID) a    INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK  WHERE DATEDIFF(dd, a.ExitDate, b.LastVisit) < 2)      , appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select DISTINCT PatientPK, cast(NextAppointmentDate as date) appointmentdate   from tmp_ClinicalEncounters  where NextAppointmentDate Between CAST(@fromdate as date) AND CAST(@todate as date)) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  group by  b.PatientPK, a.appointmentdate)    , earlyappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   , DATEDIFF(dd, a.appointmentdate, a.appointmentmeton) earlyby  from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.visitappointmentmade   and cast(b.VisitDate as date) < a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , ontimeappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  , a.appointmentmeton   from (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , max(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK   and cast(b.VisitDate as date) = a.appointmentdate  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate) a)    , lateappointments as (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate, a.appointmentmeton   , datediff(dd, a.appointmentdate, a.appointmentmeton) lateby  FROM (  select a.PatientPK   , a.visitappointmentmade  , a.appointmentdate  , min(cast(b.VisitDate as date)) appointmentmeton  from appointments a inner join tmp_ClinicalEncounters b  on a.PatientPK = b.PatientPK and cast(b.VisitDate as date) > a.appointmentdate   and cast(b.VisitDate as date) <= cast(@todate as date)  group by a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  ) a)    , appointment_analysis as (  select a.PatientPK  , a.visit_appointmentmade   , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) early_late_by  from     (select a.PatientPK, a.visitappointmentmade visit_appointmentmade  , a.appointmentdate  , case when c.PatientPK is not null then ''ontime''  when b.PatientPK is not null then ''early''  when d.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when   c.PatientPK is not null then c.appointmentmeton  when b.PatientPK is not null then b.appointmentmeton  when d.PatientPK is not null then d.appointmentmeton  else cast(@todate as date) end as appointment_analysisdate  from appointments a left join earlyappointments b on a.PatientPK = b.PatientPK and a.appointmentdate = b.appointmentdate  left join ontimeappointments c on a.PatientPK = c.PatientPK and a.appointmentdate = c.appointmentdate  left join lateappointments d on a.PatientPK = d.PatientPK and a.appointmentdate = d.appointmentdate) a)    , prereportingperiod_appointments as (  select distinct b.PatientPK  , max(cast(b.VisitDate as date)) visitappointmentmade   , a.appointmentdate  from (select PatientPK   , max(cast(NextAppointmentDate as date)) appointmentdate    from tmp_ClinicalEncounters   where NextAppointmentDate < CAST(@fromdate as date)   group by PatientPK) a   inner join tmp_ClinicalEncounters b on a.PatientPK = b.PatientPK and a.appointmentdate = b.NextAppointmentDate  where a.appointmentdate > b.VisitDate  group by  b.PatientPK, a.appointmentdate)    , pre_reportperiod_visits as (  select patientpk, max(visitdate) lastvisit  from tmp_clinicalencounters   where VisitDate < cast(@fromdate as date)  group by PatientPK)    , previously_missedappointments as (  select a.PatientPK  , a.visitappointmentmade  , a.appointmentdate  from prereportingperiod_appointments a left join pre_reportperiod_visits b   on a.PatientPK = b.PatientPK  left join (select distinct patientpk from exits where exitdate < cast(@fromdate as date)) c on a.PatientPK = c.PatientPK  where b.lastvisit <= a.visitappointmentmade   and c.PatientPK is null)    , missedappointments as (  select a.PatientPK  , a.visit_appointmentmade  , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , a.early_late_by lateby  from appointment_analysis a where appointment_status in (''late'',''not met'')  and a.early_late_by > 0  union  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , DATEDIFF(dd, a.appointmentdate, a.appointment_analysisdate) lateby    from (  select a.PatientPK, a.visitappointmentmade, a.appointmentdate  , case when b.PatientPK is not null then ''late''  else ''not met'' end as appointment_status  , case when b.PatientPK is not null then b.visitdate  else cast(@todate as date) end as appointment_analysisdate  from previously_missedappointments a   left join (select patientpk, min(cast(visitdate as date)) visitdate from tmp_ClinicalEncounters   where VisitDate between cast(@fromdate as date) and cast(@todate as date)  group by patientpk  ) b on a.PatientPK = b.PatientPK) a)    select c.PatientID  , a.visit_appointmentmade  , a.appointmentdate  , a.appointment_status  , a.appointment_analysisdate  , a.lateby  , case when lateby between 1 and 13 then ''1-13''  when lateby between 14 and 59 then ''14-59''  when lateby between 60 and 89 then ''60-89'' else ''90+'' end as overduebycategory  , b.ExitReason documentedexitwithinreportingperiod  from missedappointments a left join (select patientpk, exitreason from  tmp_LastStatus where exitdate between cast(@fromdate as date) and cast(@todate as date)) b  on a.PatientPK = b.PatientPK  inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK',       -- qryDefinition - nvarchar(max)
    N'MissedAppointments_05_LineList',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_ReportLineLists (ReportID, QryID, WorksheetName, CreateDate)
VALUES
(@ReportID, @QueryID,'Line List', GETDATE())