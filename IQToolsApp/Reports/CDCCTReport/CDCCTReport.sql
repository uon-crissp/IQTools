Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'CDCCT_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'CDCCT_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'CDCCT_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('CDCCT_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'HIV Care Routine Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('HIV Care Routine Reports',1)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'HIV Care Routine Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'CDCCT_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'CDCCT_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CDCCT_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CDCCT_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('CDCCT_Report'
,'CDC Care and Treatment Program Report (*NEW)'
,'CDC Care and Treatment Program Report'
, @CatID
, 'CDC_Care_and_Treatment_Report_Template.xlsx'
, 'Facility'
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
(   @ReportID,         
    'iqtDatehelper',        
    'Select Reporting Period',        
    'datehelper',       
    'monthly',       
    1,         
    GETDATE(), 
    NULL,
    NULL       
),
(   @ReportID,         
    'linelist',        
    'Include Line Lists',        
    'checkbox',       
    'false',       
    2,     
    GETDATE(), 
    NULL, 
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
(   N'CDCCT_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_Report_Header'


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
(   N'CDCCT_Report_Header',       
    N'Select CONVERT(varchar(20), @fromdate, 106) StartDate, CONVERT(varchar(20), @todate, 106) EndDate, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       
    N'CDCCT_Report_Header',       
    N'Function',       
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
(   N'CDCCT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B3',       
    @QueryID,         
    N'StartDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B2',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E3',       
    @QueryID,         
    N'EndDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


-- Starting ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NewOnART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NewOnART'


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
(   N'CDCCT_NewOnART',       
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'')',       
    N'CDCCT Starting ART',       
    N'Function',       
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
(   N'CDCCT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)



-- Current ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_CurrentOnART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_CurrentOnART'


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
(   N'CDCCT_CurrentOnART',       
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeLastVisit, ''DATIM'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''DATIM'')',       
    N'CDCCT Current On ART',       
    N'Function',       
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
(   N'CDCCT_Report',       -- sbCategory - nvarchar(50)
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
(   N'D7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


-- Net Cohort
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NetCohort')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NetCohort'


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
(   N'CDCCT_NetCohort',       
    N'Select   
a.Gender
, dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'') AgeGroup
, COUNT(Distinct a.PatientPK ) Total
FROM tmp_ARTPatients a  
LEFT JOIN    (Select    a.PatientPK   
			, LastVL    FROM IQC_LastVL  a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
			Where LastVLDate    
			Between DateAdd(mm, -12, Cast(@fromdate As datetime))  And  Cast(@todate As datetime)) b   
On a.PatientPK = b.PatientPK  
Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
AND (a.ExitReason IS NULL OR a.ExitReason != ''Transfer'')
GROUP BY a.Gender
, dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'')',       
    N'CDCCT Net 12month Cohort',       
    N'Function',       
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
(   N'CDCCT_Report',       -- sbCategory - nvarchar(50)
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
(   N'F7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


-- Net Cohort Still Active
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NetCohortStillActive')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_NetCohortStillActive'


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
(   N'CDCCT_NetCohortStillActive',       
    N'Select   
a.Gender
, dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'') AgeGroup
, COUNT(Distinct a.PatientPK ) Total
FROM tmp_ARTPatients a  
LEFT JOIN    (Select    a.PatientPK   
			, LastVL    FROM IQC_LastVL  a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
			Where LastVLDate    
			Between DateAdd(mm, -12, Cast(@fromdate As datetime))  And  Cast(@todate As datetime)) b   
On a.PatientPK = b.PatientPK  
Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
AND (a.ExitReason IS NULL OR a.ExitReason != ''Transfer'')
AND  dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1
GROUP BY a.Gender
, dbo.fn_GetAgeGroup(a.AgeARTStart, ''DATIM'')',       
    N'CDCCT Net 12month Cohort Still Active',       
    N'Function',       
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
(   N'CDCCT_Report',       -- sbCategory - nvarchar(50)
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
(N'H7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'H16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'I16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Eligible for VL
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_EligibleVL')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_EligibleVL'


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
(   N'CDCCT_EligibleVL',       
    N'WITH Active AS (
select DISTINCT PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(cast(@todate as date), PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)

, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%''
AND CAST(OrderedByDate as date) <= CAST(@todate as date)
)

, LastVLs AS (
SELECT a.PatientPK
, MAX(a.VLResult) LastVL
, MAX(a.DateOrdered) LastVLDateOrdered
, MAX(a.DateReported) LastVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MAX(DateOrdered) LastVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastVLDate
GROUP BY a.PatientPK)

, FirstVLs AS
(SELECT a.PatientPK
, MAX(a.VLResult) FirstVL
, MAX(a.DateOrdered) FirstVLDateOrdered
, MAX(a.DateReported) FirstVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MIN(DateOrdered) FirstVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.FirstVLDate
GROUP BY a.PatientPK)

, LastVL AS (
Select a.PatientPK
, b.LastVL
,LastVLDateOrdered
,LastVLDateReported 
, DATEDIFF(mm, b.LastVLDateOrdered, CAST(@todate as DATE)) ElapsedMonths
FROM Active a INNER JOIN LastVLs b ON a.PatientPK = b.PatientPK)

, FirstVL AS (
Select a.PatientPK
, b.FirstVL
, FirstVLDateOrdered
, FirstVLDateReported 
FROM Active a INNER JOIN FirstVLs b ON a.PatientPK = b.PatientPK)

, PreviousVLs AS 
(SELECT a.PatientPK, MAX(a.VLResult) PreviousVL
, MAX(b.PreviousVLDateOrdered) PreviousVLDateOrdered
FROM VLs a INNER JOIN (
SELECT a.PatientPK, MAX(a.DateOrdered) PreviousVLDateOrdered 
FROM VLs a LEFT JOIN LastVLs b ON a.PatientPK = b.PatientPK
WHERE a.DateOrdered < b.LastVLDateOrdered
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
AND a.DateOrdered = b.PreviousVLDateOrdered
GROUP BY a.PatientPK)

, PreviousVL AS
(Select a.PatientPK, a.PreviousVL 
, a.PreviousVLDateOrdered
, DATEDIFF(mm, PreviousVLDateOrdered, CAST(@todate as date)) ElapsedMonths_P
FROM PreviousVLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK)

, Eligible AS (
Select a.PatientPK, a.Gender, a.AgeLastVisit
, CASE WHEN (MonthsOnART > 6 AND FirstVLDateOrdered IS NULL) THEN 1 
 WHEN (MonthsOnART > 6 AND FirstVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)) THEN 1 
 ELSE 0 END AS EligibleFirst
, CASE WHEN (c.ElapsedMonths > 12 OR (d.ElapsedMonths_P > 12 AND c.LastVLDateOrdered BETWEEN CAST(@fromdate as date) 
	AND CAST(@todate as date))) 
 THEN 1 ELSE 0 END EligibleAnnual

, CASE WHEN (FLOOR(PreviousVL) >= 1000 AND LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)) 
	OR (FLOOR(LastVL) >= 1000 AND ElapsedMonths > 3) 
 THEN 1 ELSE 0 END AS EligibleRepeat

FROM Active a LEFT JOIN FirstVL b ON a.PatientPK = b.PatientPK
LEFT JOIN LastVL c ON a.PatientPK = c.PatientPK
LEFT JOIN PreviousVL d ON a.PatientPK = d.PatientPK
)


SELECT Gender, dbo.fn_GetAgeGroup(AgeLastVisit, ''DATIM'') AgeGroup
, COUNT(DISTINCT PatientPK) Total
FROM Eligible a WHERE EligibleAnnual = 1 OR EligibleFirst = 1 OR EligibleRepeat = 1
GROUP BY  Gender, dbo.fn_GetAgeGroup(AgeLastVisit, ''DATIM'')',       
    N'CDCCT Eligible for VL',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'J7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'J16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'K16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)



--VL Samples Collected
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SamplesCollected')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SamplesCollected'


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
(   N'CDCCT_SamplesCollected',       
    N'WITH Active AS (
SELECT DISTINCT PatientPK
, Gender
, AgeLastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)
, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%'')

SELECT b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'') AgeGroup
,COUNT(DISTINCT b.PatientPK) Total
 FROM VLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK 
WHERE DateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
GROUP BY b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'')',       
    N'CDCCT VL Samples Collected',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'L7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'L16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'M16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)





--VL Results Received
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceived')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceived'


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
(   N'CDCCT_ResultsReceived',       
    N'WITH Active AS (
SELECT DISTINCT PatientPK
, Gender
, AgeLastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)
, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%'')

SELECT b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'') AgeGroup
,COUNT(DISTINCT b.PatientPK) Total
 FROM VLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK 
WHERE DateReported BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
AND VLResult IS NOT NULL
GROUP BY b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'')',       
    N'CDCCT VL Results Received',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'N7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'N16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'O16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--VL Results Received LT 1000
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceivedLT1000')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceivedLT1000'


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
(   N'CDCCT_ResultsReceivedLT1000',       
    N'WITH Active AS (
SELECT DISTINCT PatientPK
, Gender
, AgeLastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)
, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%'')

SELECT b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'') AgeGroup
,COUNT(DISTINCT b.PatientPK) Total
 FROM VLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK 
WHERE DateReported BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
AND CAST(VLResult AS INT) < 1000
GROUP BY b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'')',      
 
    N'CDCCT VL Results Received Less Than 1000',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'P7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'P16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Q16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--VL Results Received LDL
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceivedLDL')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_ResultsReceivedLDL'


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
(   N'CDCCT_ResultsReceivedLDL',       
    N'WITH Active AS (
SELECT DISTINCT PatientPK
, Gender
, AgeLastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)
, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%'')

SELECT b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'') AgeGroup
,COUNT(DISTINCT b.PatientPK) Total
 FROM VLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK 
WHERE DateReported BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
AND CAST(VLResult AS INT) = 0
GROUP BY b.Gender
,dbo.fn_GetAgeGroup(b.AgeLastVisit, ''DATIM'')',      
 
    N'CDCCT VL Results Received LDL',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'R7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'R16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'S16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Repeat VL Done
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_RepeatVLDone')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_RepeatVLDone'


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
(   N'CDCCT_RepeatVLDone',       
    N'WITH Active AS (
select DISTINCT FacilityName, PatientID, PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)

, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%''
AND CAST(OrderedByDate as date) <= CAST(@todate as date))

, LastVLs AS (
SELECT a.PatientPK
, MAX(a.VLResult) LastVL
, MAX(a.DateOrdered) LastVLDateOrdered
, MAX(a.DateReported) LastVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MAX(DateOrdered) LastVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastVLDate
GROUP BY a.PatientPK)

, LastVL AS (
Select a.PatientPK
, b.LastVL
,LastVLDateOrdered
,LastVLDateReported 
, DATEDIFF(mm, b.LastVLDateOrdered, CAST(@todate as DATE)) ElapsedMonths
FROM Active a INNER JOIN LastVLs b ON a.PatientPK = b.PatientPK)

, PreviousVLs AS 
(SELECT a.PatientPK, MAX(a.VLResult) PreviousVL
, MAX(b.PreviousVLDateOrdered) PreviousVLDateOrdered
FROM VLs a INNER JOIN (
SELECT a.PatientPK, MAX(a.DateOrdered) PreviousVLDateOrdered 
FROM VLs a LEFT JOIN LastVLs b ON a.PatientPK = b.PatientPK
WHERE a.DateOrdered < b.LastVLDateOrdered
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
AND a.DateOrdered = b.PreviousVLDateOrdered
GROUP BY a.PatientPK)

, PreviousVL AS
(Select a.PatientPK, a.PreviousVL 
, a.PreviousVLDateOrdered
, DATEDIFF(mm, PreviousVLDateOrdered, CAST(@todate as date)) ElapsedMonths_P
FROM PreviousVLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK)

SELECT ac.Gender, dbo.fn_GetAgeGroup(ac.AgeLastVisit, ''DATIM'') AgeGroup
, COUNT(DISTINCT ac.PatientPK) Total 
FROM Active ac INNER JOIN PreviousVL a ON ac.PatientPK = a.PatientPK
LEFT JOIN LastVL b ON a.PatientPK = b.PatientPK 
WHERE (FLOOR(PreviousVL) >= 1000 AND LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date))
GROUP BY  ac.Gender, dbo.fn_GetAgeGroup(ac.AgeLastVisit, ''DATIM'')',      
 
    N'CDCCT Repeat VL Done AND Results Received During the Reporting Period',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'T7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'T16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'U16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Repeat VL Done GT 1000
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_RepeatVLDoneGT1000')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_RepeatVLDoneGT1000'


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
(   N'CDCCT_RepeatVLDoneGT1000',       
    N'WITH Active AS (
select DISTINCT FacilityName, PatientID, PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)

, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%''
AND CAST(OrderedByDate as date) <= CAST(@todate as date))

, LastVLs AS (
SELECT a.PatientPK
, MAX(a.VLResult) LastVL
, MAX(a.DateOrdered) LastVLDateOrdered
, MAX(a.DateReported) LastVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MAX(DateOrdered) LastVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastVLDate
GROUP BY a.PatientPK)

, LastVL AS (
Select a.PatientPK
, b.LastVL
,LastVLDateOrdered
,LastVLDateReported 
, DATEDIFF(mm, b.LastVLDateOrdered, CAST(@todate as DATE)) ElapsedMonths
FROM Active a INNER JOIN LastVLs b ON a.PatientPK = b.PatientPK)

, PreviousVLs AS 
(SELECT a.PatientPK, MAX(a.VLResult) PreviousVL
, MAX(b.PreviousVLDateOrdered) PreviousVLDateOrdered
FROM VLs a INNER JOIN (
SELECT a.PatientPK, MAX(a.DateOrdered) PreviousVLDateOrdered 
FROM VLs a LEFT JOIN LastVLs b ON a.PatientPK = b.PatientPK
WHERE a.DateOrdered < b.LastVLDateOrdered
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
AND a.DateOrdered = b.PreviousVLDateOrdered
GROUP BY a.PatientPK)

, PreviousVL AS
(Select a.PatientPK, a.PreviousVL 
, a.PreviousVLDateOrdered
, DATEDIFF(mm, PreviousVLDateOrdered, CAST(@todate as date)) ElapsedMonths_P
FROM PreviousVLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK)

SELECT ac.Gender, dbo.fn_GetAgeGroup(ac.AgeLastVisit, ''DATIM'') AgeGroup
, COUNT(DISTINCT ac.PatientPK) Total 
FROM Active ac INNER JOIN PreviousVL a ON ac.PatientPK = a.PatientPK
LEFT JOIN LastVL b ON a.PatientPK = b.PatientPK 
WHERE (FLOOR(PreviousVL) >= 1000 AND LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date))
AND b.LastVL >= 1000
GROUP BY  ac.Gender, dbo.fn_GetAgeGroup(ac.AgeLastVisit, ''DATIM'')',      
 
    N'CDCCT Repeat VL Greater than 1000 During the Reporting Period',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'V7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'V16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'W16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Started Second Line
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SwitchedToSecondLine')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SwitchedToSecondLine'


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
(   N'CDCCT_SwitchedToSecondLine',       
    N'WITH Active AS (
select DISTINCT FacilityName, PatientID, PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)


,  CodedDispense AS (Select a.ptn_pk PatientPK
, CAST(a.OrderedByDate AS DATE) DateOrdered
, c.RegimenCode
, d.[Name] RegimenLine
FROM ord_patientpharmacyorder a inner join dtl_regimenmap b on a.ptn_pharmacy_pk = b.OrderID
INNER JOIN mst_Regimen c on b.RegimenId = c.RegimenID
INNER JOIN mst_RegimenLine d ON c.RegimenLineID = d.ID
WHERE (a.DeleteFLag = 0 OR a.DeleteFlag IS NULL))

, FirstLine AS (Select a.PatientPK
, a.RegimenCode FirstLineRegimen
, b.LastFirstLineDate FROM CodedDispense a INNER JOIN (
SELECT PatientPK, MAX(DateOrdered) LastFirstLineDate
FROM CodedDispense
WHERE RegimenLine LIKE ''%First%''
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastFirstLineDate)

, SecondLine AS (Select a.PatientPK
, a.RegimenCode SecondLineRegimen
, b.SecondLineStart 
FROM CodedDispense a INNER JOIN (
SELECT PatientPK, MIN(DateOrdered) SecondLineStart FROM CodedDispense
WHERE RegimenLine LIKE ''%Second%''
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.SecondLineStart)

Select a.Gender
, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''DATIM'') AgeGroup
, COUNT(DISTINCT a.PatientPK) Total
FROM Active a LEFT JOIN FirstLine b ON a.PatientPK = b.PatientPK
LEFT JOIN SecondLine c ON a.PatientPK = c.PatientPK
WHERE c.SecondLineStart > b.LastFirstLineDate
AND c.SecondLineStart BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
GROUP BY a.Gender
, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''DATIM'')',      
 
    N'CDCCT Switched on Second Line During the Reporting Period',       
    N'Function',       
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,    
    NULL,  
    NULL,   
    N'IQCare',    
    NULL    
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
(   N'CDCCT_Report',  
    @CatID,    
    @QueryID,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,     
    NULL,     
    NULL        
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
(N'X7',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y7',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X8',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y8',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X9',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y9',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X10',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y10',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X11',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y11',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X12',       
    @QueryID,         
    N'Male25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y12',       
    @QueryID,         
    N'Female25-29Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X13',       
    @QueryID,         
    N'Male30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y13',       
    @QueryID,         
    N'Female30-34Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X14',       
    @QueryID,         
    N'Male35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y14',       
    @QueryID,         
    N'Female35-39Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X15',       
    @QueryID,         
    N'Male40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y15',       
    @QueryID,         
    N'Female40-49Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'X16',       
    @QueryID,         
    N'Male50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),(N'Y16',       
    @QueryID,         
    N'Female50+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Eligible for VL Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_EligibleforVL_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_EligibleforVL_LineList'


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
(   N'CDCCT_EligibleforVL_LineList',       
    N'WITH Active AS (
select DISTINCT FacilityName, PatientID, PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(cast(@todate as date), PatientPK) = 1)

, Labs AS (Select distinct a.Ptn_pk
, v.VisitId VisitID
, a.TestName
, Coalesce(Cast((CASE WHEN a.TestResultId = 9998 AND a.TestName LIKE ''%viral%'' THEN ''0'' ELSE a.TestResults END) As varchar(100))
, Cast(a.[Parameter Result] As varchar(100))
, Cast(a.TestResults1 As varchar(100))) TestResult
		, a.OrderedbyDate
		, a.ReportedbyDate
		From VW_PatientLaboratory a 
		inner join ord_PatientLabOrder v on v.Ptn_Pk = a.ptn_pk  and a.LabID = v.LabID)

, VLs AS (
Select DISTINCT Ptn_Pk PatientPK 
, dbo.fn_CleanVL(TestResult) VLResult
, CAST(OrderedByDate as date) DateOrdered
, CAST(ReportedByDate as date) DateReported
FROM Labs WHERE TestName LIKE ''%Viral%''
AND CAST(OrderedByDate as date) <= CAST(@todate as date))

, LastVLs AS (
SELECT a.PatientPK
, MAX(a.VLResult) LastVL
, MAX(a.DateOrdered) LastVLDateOrdered
, MAX(a.DateReported) LastVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MAX(DateOrdered) LastVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastVLDate
GROUP BY a.PatientPK)

, FirstVLs AS
(SELECT a.PatientPK
, MAX(a.VLResult) FirstVL
, MAX(a.DateOrdered) FirstVLDateOrdered
, MAX(a.DateReported) FirstVLDateReported
FROM VLs a INNER JOIN (
Select PatientPK, MIN(DateOrdered) FirstVLDate 
FROM VLs 
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.FirstVLDate
GROUP BY a.PatientPK)

, LastVL AS (
Select a.PatientPK
, b.LastVL
,LastVLDateOrdered
,LastVLDateReported 
, DATEDIFF(mm, b.LastVLDateOrdered, CAST(@todate as DATE)) ElapsedMonths
FROM Active a INNER JOIN LastVLs b ON a.PatientPK = b.PatientPK)


, FirstVL AS (
Select a.PatientPK
, b.FirstVL
, FirstVLDateOrdered
, FirstVLDateReported 
FROM Active a INNER JOIN FirstVLs b ON a.PatientPK = b.PatientPK)

, PreviousVLs AS 
(SELECT a.PatientPK, MAX(a.VLResult) PreviousVL
, MAX(b.PreviousVLDateOrdered) PreviousVLDateOrdered
FROM VLs a INNER JOIN (
SELECT a.PatientPK, MAX(a.DateOrdered) PreviousVLDateOrdered 
FROM VLs a LEFT JOIN LastVLs b ON a.PatientPK = b.PatientPK
WHERE a.DateOrdered < b.LastVLDateOrdered
GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
AND a.DateOrdered = b.PreviousVLDateOrdered
GROUP BY a.PatientPK)

, PreviousVL AS
(Select a.PatientPK, a.PreviousVL 
, a.PreviousVLDateOrdered
, DATEDIFF(mm, PreviousVLDateOrdered, CAST(@todate as date)) ElapsedMonths_P
FROM PreviousVLs a INNER JOIN Active b ON a.PatientPK = b.PatientPK)


, Eligible AS (
Select a.*
, b.FirstVL
, b.FirstVLDateOrdered
, d.PreviousVL
, d.PreviousVLDateOrdered
, c.LastVL
, c.LastVLDateOrdered
, c.LastVLDateReported
, CASE WHEN (MonthsOnART > 6 AND FirstVLDateOrdered IS NULL) THEN 1 
 WHEN (MonthsOnART > 6 AND FirstVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)) THEN 1 
 ELSE 0 END AS EligibleFirst

, COALESCE(CASE WHEN c.LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date) THEN ElapsedMonths_P ELSE NULL END, c.ElapsedMonths)
 AS ElapsedMonths
 
, CASE WHEN (c.ElapsedMonths > 12 OR (d.ElapsedMonths_P > 12 AND c.LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date))) 
 THEN 1 ELSE 0 END EligibleAnnual

, CASE WHEN (FLOOR(PreviousVL) >= 1000 AND LastVLDateOrdered BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)) OR (FLOOR(LastVL) >= 1000 AND ElapsedMonths > 3) 
 THEN 1 ELSE 0 END AS EligibleRepeat

FROM Active a LEFT JOIN FirstVL b ON a.PatientPK = b.PatientPK
LEFT JOIN LastVL c ON a.PatientPK = c.PatientPK
LEFT JOIN PreviousVL d ON a.PatientPK = d.PatientPK
)
SELECT 
a.FacilityName
, a.PatientID
, a.Gender
, a.StartARTDate
, a.AgeLastVisit
, a.LastVisit
, a.MonthsOnART
, a.FirstVL
, a.FirstVLDateOrdered
, a.PreviousVL
, a.PreviousVLDateOrdered
, a.LastVL
, a.LastVLDateOrdered
, a.LastVLDateReported
, a.ElapsedMonths
, CASE  
WHEN EligibleFirst = 1 THEN ''First VL'' 
WHEN EligibleRepeat = 1 THEN ''Repeat VL''
WHEN EligibleAnnual = 1 THEN ''Annual VL''
ELSE NULL END AS Criteria
FROM Eligible a WHERE 
EligibleAnnual = 1 OR EligibleFirst = 1 OR EligibleRepeat = 1',      
    N'CDCCT Line list of Active Patients Eligible for VL during the reporting period',    
    N'Function',  
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,    
    NULL,    
    N'IQCare',   
    NULL      
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_ReportLineLists (ReportID, QryID, WorksheetName, CreateDate)
VALUES
(@ReportID, @QueryID,'Eligible for VL', GETDATE())



--Switching to Second Line Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SwitchedToSecondLine_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCCT_SwitchedToSecondLine_LineList'


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
(   N'CDCCT_SwitchedToSecondLine_LineList',       
    N'WITH Active AS (
select DISTINCT FacilityName, PatientID, PatientPK, Gender
, CAST(StartARTDate as DATE) StartARTDate
, AgeLastVisit
, DATEDIFF(mm, StartARTDate, CAST(@todate as DATE)) MonthsOnART
, LastVisit
from tmp_ARTPatients
where dbo.fn_ActiveCCC(@todate, PatientPK) = 1)

,  CodedDispense AS (
Select a.ptn_pk PatientPK
, CAST(a.OrderedByDate AS DATE) DateOrdered
, c.RegimenCode
, d.[Name] RegimenLine
FROM ord_patientpharmacyorder a inner join dtl_regimenmap b on a.ptn_pharmacy_pk = b.OrderID
INNER JOIN mst_Regimen c on b.RegimenId = c.RegimenID
INNER JOIN mst_RegimenLine d ON c.RegimenLineID = d.ID
WHERE (a.DeleteFLag = 0 OR a.DeleteFlag IS NULL))

, FirstLine AS (Select a.PatientPK
, a.RegimenCode FirstLineRegimen
, b.LastFirstLineDate FROM CodedDispense a INNER JOIN (
SELECT PatientPK, MAX(DateOrdered) LastFirstLineDate
FROM CodedDispense
WHERE RegimenLine LIKE ''%First%''
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.LastFirstLineDate)

, SecondLine AS (
Select a.PatientPK
, a.RegimenCode SecondLineRegimen
, b.SecondLineStart 
FROM CodedDispense a INNER JOIN (
SELECT PatientPK, MIN(DateOrdered) SecondLineStart FROM CodedDispense
WHERE RegimenLine LIKE ''%Second%''
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DateOrdered = b.SecondLineStart)

Select a.FacilityName, a.PatientID, a.Gender, a.AgeLastVisit, a.LastVisit
, b.FirstLineRegimen, b.LastFirstLineDate
, c.SecondLineRegimen, c.SecondLineStart
FROM Active a LEFT JOIN FirstLine b ON a.PatientPK = b.PatientPK
LEFT JOIN SecondLine c ON a.PatientPK = c.PatientPK
WHERE c.SecondLineStart > b.LastFirstLineDate
AND c.SecondLineStart BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)',      
    N'CDCCT Line list of Active Patients Switched to Second Line ART during the reporting period',    
    N'Function',  
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,        
    NULL,    
    NULL,    
    N'IQCare',   
    NULL      
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_ReportLineLists (ReportID, QryID, WorksheetName, CreateDate)
VALUES
(@ReportID, @QueryID,'Second Line', GETDATE())