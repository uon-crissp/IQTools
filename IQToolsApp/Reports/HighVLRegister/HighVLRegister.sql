Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'HighVL_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'HighVL_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'HighVL_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('HighVL_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Registers')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Registers',2)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Registers'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'HighVL_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'HighVL_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HighVL_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HighVL_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('HighVL_Register'
,'High Viral Load Follow Up Register'
,'High VL Follow Up Register'
, @CatID
, 'HighVL_FollowUp_Register_Template.xlsx'
, 'LPTF'
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
(   N'HighVL_Register',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'HighVL_Register_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'HighVL_Register_Header'


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
(   N'HighVL_Register_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @fromdate, 106) StartDate 
,CONVERT(varchar(20), @todate, 106) EndDate
, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'HighVL_Register_Header',       -- qryDescription - nvarchar(200)
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
(   N'HighVL_Register',       -- sbCategory - nvarchar(50)
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
(   N'B2',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B3',       
    @QueryID,         
    N'StartDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B4',       
    @QueryID,         
    N'EndDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'HighVL_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'HighVL_Register_LineList'


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
(   N'HighVL_Register_LineList',       -- qryName - nvarchar(50)
    N'WITH VLGT1000 AS
(select PatientPK, VLOrderDate, VLReportDate, VLResult from IQC_AllVL
WHERE VLOrderDate BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
AND VLResult > 1000)

, PreviousVL AS (
SELECT a.PatientPK
, a.VLOrderDate HighVLDate
, a.VLResult HighVLResult
, b.VLOrderDate PreviousVLDate
, b.VLResult PreviousVLResult
, DATEDIFF(dd, a.VLOrderDate, b.VLOrderDate) DaysElapsed
FROM VLGT1000 a INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK
WHERE b.VLOrderDate < a.VLOrderDate)

, FilterOut AS (
Select DISTINCT PatientPK 
FROM PreviousVL WHERE PreviousVLResult >= 1000
AND DaysElapsed >= -180)

, HighVLClients AS (
Select a.PatientPK, a.VLOrderDate, a.VLReportDate, a.VLResult 
FROM VLGT1000 a LEFT JOIN FilterOut b ON a.PatientPK = b.PatientPK
WHERE b.PatientPK IS NULL)


, RepeatVLs AS (
select a.PatientPK
, a.VLOrderDate
, a.VLResult
, b.VLOrderDate PreviousVLDate
, b.VLResult PreviousVL
, DATEDIFF(mm, a.VLOrderDate, b.VLOrderDate) dd 
from HighVLClients a INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK
WHERE DATEDIFF(mm, a.VLOrderDate, b.VLOrderDate) BETWEEN -5 AND -2
AND b.VLResult > 1000)

, CurrentRegimen AS (Select a.PatientPK
, b.Regimen
, MIN(CAST(a.DispenseDate as DATE)) RegimenStartDate 
FROM tmp_Pharmacy a INNER JOIN (
Select DISTINCT a.PatientPK
, a.Drug Regimen
, CAST(b.LastDate as DATE) RegimenLastDate FROM tmp_Pharmacy a INNER JOIN (
Select a.PatientPK, MAX(b.DispenseDate) LastDate
FROM HighVLClients a LEFT JOIN tmp_Pharmacy b
ON a.PatientPK = b.PatientPK 
AND a.VLOrderDate >= b.DispenseDate
AND b.TreatmentType = ''ART''
AND LEN(b.Drug) >= 11
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK AND a.DispenseDate = b.LastDate
AND a.TreatmentType = ''ART'') b ON a.PatientPK = b.PatientPK
AND a.Drug = b.Regimen
GROUP BY a.PatientPK, b.Regimen)



, FUVL AS (
Select a.PatientPK
, CAST(a.VLOrderDate as DATE) VLOrderDate
, CAST(a.VLReportDate as DATE) VLReportDate
, a.VLResult 
FROM IQC_AllVL a INNER JOIN (
Select a.PatientPK, MIN(a.VLOrderDate)FUVLDate FROM IQC_AllVL a INNER JOIN HighVLClients b
ON a.PatientPK = b.PatientPK AND a.VLOrderDate > b.VLOrderDate
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK AND a.VLOrderDate = b.FUVLDate)

, LastRegimen AS (Select a.PatientPK, a.LastRegimen
, CAST(b.LastRegimenStartDate as DATE) LastRegimenStartDate
FROM tmp_ARTPatients a INNER JOIN (
Select a.PatientPK, MIN(c.DispenseDate) LastRegimenStartDate 
FROM HighVLClients a INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK
INNER JOIN tmp_Pharmacy c ON b.PatientPK = c.PatientPK AND b.LastRegimen = c.Drug
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK)

, RegimenChange AS (
Select a.PatientPK
, CASE WHEN e.LastRegimen <> c.Regimen 
AND e.LastRegimenStartDate >= a.VLOrderDate
THEN ''YES'' ELSE NULL END AS RegimenChanged
, CASE WHEN e.LastRegimen <> c.Regimen 
AND e.LastRegimenStartDate >= a.VLOrderDate
THEN e.LastRegimenStartDate ELSE NULL END AS RegimenChangeDate
, CASE WHEN e.LastRegimen <> c.Regimen 
AND e.LastRegimenStartDate >= a.VLOrderDate
THEN e.LastRegimen ELSE NULL END AS LastRegimen
FROM HighVLClients a INNER JOIN CurrentRegimen c ON a.PatientPK = c.PatientPK
LEFT JOIN LastRegimen e ON a.PatientPK = e.PatientPK
WHERE e.LastRegimen <> c.Regimen 
AND e.LastRegimenStartDate >= a.VLOrderDate
)

, m6VL AS (SELECT a.PatientPK
, CAST(b.VLOrderDate as DATE)VLOrderDate
, b.VLResult 
FROM RegimenChange a INNER JOIN IQC_AllVL b ON a.PatientPK = b.PatientPK
WHERE DATEDIFF(dd, RegimenChangeDate, VLOrderDate) BETWEEN 180 AND 360)

Select DISTINCT b.PatientID
, b.PatientName
, CAST(b.DOB as DATE) DoB
, b.AgeLastVisit Age 
, b.Gender
, NULL Clinic
, a.VLResult
, CAST(a.VLOrderDate as DATE) VLDate
, CASE WHEN b.StartRegimen <> c.Regimen AND LEN(b.StartRegimen) BETWEEN 11 AND 13 THEN b.StartRegimen ELSE NULL END AS PreviousRegimen
, CASE WHEN b.StartRegimen <> c.Regimen AND LEN(b.StartRegimen) BETWEEN 11 AND 13 THEN CAST(b.StartARTDate as DATE)
 ELSE NULL END AS PreviousRegimenStartDate
, c.Regimen CurrentRegimen
, c.RegimenStartDate CurrentRegimenStartDate
, NULL PSForm
, NULL AAForm
, NULL MDT1
, NULL EA1Date
, NULL EA2
, NULL EA2Date
, NULL EA2
, NULL EA3Date
, NULL EA3
, NULL HomeVisit
, NULL HomeVIsitDate
, d.VLOrderDate SampleCollected
, NULL SampleShipped
, d.VLReportDate ResultReceived
, d.VLResult FUVL
, NULL DRTEligible
, NULL DRTSample
, NULL DRTResult
, NULL DRTResultDate
, NULL MDT2
, NULL MDT2Date
, CASE WHEN e.PatientPK IS NOT NULL THEN ''YES'' ELSE NULL END AS RegimenChanged
, e.RegimenChangeDate
, e.LastRegimen
, f.VLResult m6VL
, f.VLOrderDate m6VLDate
FROM HighVLClients a INNER JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK
LEFT JOIN CurrentRegimen c ON a.PatientPK = c.PatientPK
LEFT JOIN FUVL d ON a.PatientPK = d.PatientPK
LEFT JOIN RegimenChange e ON a.PatientPK = e.PatientPK
LEFT JOIN m6VL f ON a.PatientPK = f.PatientPK',       -- qryDefinition - nvarchar(max)
    N'HighVL_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'HighVL_Register',       -- sbCategory - nvarchar(50)
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
(   N'A7',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 