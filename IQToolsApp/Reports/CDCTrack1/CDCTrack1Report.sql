Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'CDCTack1_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'CDCTack1_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'CDCTack1_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('CDCTack1_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'HIV Care Routine Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('HIV Care Routine Reports',1)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'HIV Care Routine Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'CDCTack1_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'CDCTack1_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CDCTack1_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CDCTack1_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('CDCTack1_Report'
,'CDC Track 1 Quarterly Report'
,'CDC Track 1 Quarterly Report'
, @CatID
, 'CDCTrack1_Template.xlsx'
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
(   N'CDCTack1_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_Report_Header'


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
(   N'CDCTack1_Report_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @fromdate, 106) StartDate ,CONVERT(varchar(20), @todate, 106) EndDate, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'CDCTack1_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'D5',       
    @QueryID,         
    N'StartDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L5',       
    @QueryID,         
    N'EndDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L6',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative number enrolled in HIV care by the beginning of Quarter
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CumulativeQuarterBeginning')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CumulativeQuarterBeginning'


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
(   N'CDCTack1_CumulativeQuarterBeginning',       -- qryName - nvarchar(50)
    N'Select p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'') AgeGroup,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  Where p.RegistrationAtCCC < Cast(@FromDate As DateTime)  Group By p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'')  Order By p.Gender Desc,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative number enrolled in HIV care by the beginning of Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'E21',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E22',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E23',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E24',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E25',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E26',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E13',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E15',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--NEW enrollees in HIV care during the Quarter
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_NewOnCareDuringTheQuarter')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_NewOnCareDuringTheQuarter'


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
(   N'CDCTack1_NewOnCareDuringTheQuarter',       -- qryName - nvarchar(50)
    N'Select p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'') AgeGroup,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  Where p.RegistrationAtCCC Between Cast(@FromDate As Datetime) And Cast(@ToDate    As datetime)  Group By p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'')  Order By p.Gender Desc,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''CDCTrack1'')',       -- qryDefinition - nvarchar(max)
    N'NEW enrollees in HIV care during the Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'G21',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G22',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G23',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G24',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G25',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G26',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G13',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G15',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Total number who received HIV care during the Quarter
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ReceivedCareDuringTheQuarter')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ReceivedCareDuringTheQuarter'


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
(   N'CDCTack1_ReceivedCareDuringTheQuarter',       -- qryName - nvarchar(50)
    N'Select p.Gender,    dbo.fn_GetAgeGroup(p.AgeLastVisit, ''CDCTrack1'') AgeGroup,  Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p    Inner Join tmp_ClinicalEncounters a On p.PatientPK = a.PatientPK  Where a.VisitDate Between dateadd(dd, 1, dateadd(mm, -3, Cast(@todate As datetime))) And Cast(@todate As datetime) And    a.Service = ''ART'' And p.RegistrationAtCCC <= Cast(@todate As datetime)  Group By p.Gender,    dbo.fn_GetAgeGroup(p.AgeLastVisit, ''CDCTrack1'')',       -- qryDefinition - nvarchar(max)
    N'Total number who received HIV care during the Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'Q21',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q22',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q23',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q24',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q25',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q26',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q13',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q15',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Number in HIV care during the Quarter & eligible for ART, but NOT started ART by the end of the Quarter PRE-ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_PreART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_PreART'


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
(   N'CDCTack1_PreART',       -- qryName - nvarchar(50)
    N'Select COUNT(DISTINCT a.PatientPK) Total FROM tmp_PatientMaster a LEFT JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK WHERE (b.PatientPK IS NULL OR b.StartARTDate > CAST(@todate as date)) AND a.RegistrationAtCCC <= CAST(@todate as date) AND dbo.fn_ActiveCCC(cast(@todate as date), a.PatientPK) = 1',       -- qryDefinition - nvarchar(max)
    N'Number in HIV care during the Quarter & eligible for ART, but NOT started ART by the end of the Quarter (PRE-ART)',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'Q18',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative number started on ART by the beginning of the Quarter
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CumulativeOnARTByQuarterBeginning')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CumulativeOnARTByQuarterBeginning'


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
(   N'CDCTack1_CumulativeOnARTByQuarterBeginning',       -- qryName - nvarchar(50)
    N'Select a.Gender,  dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') AgeGroup,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where Cast(a.StartARTDate As datetime) < Cast(@FromDate As datetime)  Group By a.Gender,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') ',       -- qryDefinition - nvarchar(max)
    N'Cumulative number started on ART by the beginning of the Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'E44',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E45',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E46',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E47',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E48',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E49',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E32',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E34',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Number started on ART in program during the Quarter (includes NEW and TRANSFERS)
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_NewOnARTInTheQuarter')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_NewOnARTInTheQuarter'


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
(   N'CDCTack1_NewOnARTInTheQuarter',       -- qryName - nvarchar(50)
    N'Select a.Gender,  dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') AgeGroup,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where Cast(a.StartARTDate As datetime) BETWEEN Cast(@FromDate As datetime) AND Cast(@ToDate As datetime) Group By a.Gender,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') ',       -- qryDefinition - nvarchar(max)
    N'Number started on ART in program during the Quarter (includes NEW and TRANSFERS)',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'G44',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G45',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G46',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G47',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G48',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G49',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G32',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G34',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Number on ART who TRANSFERRED in during the Quarter   
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTTransfersIn')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTTransfersIn'


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
(   N'CDCTack1_ARTTransfersIn',       -- qryName - nvarchar(50)
    N'Select a.Gender,  dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') AgeGroup,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where Cast(a.StartARTDate As datetime) BETWEEN Cast(@FromDate As datetime) AND Cast(@ToDate As datetime) AND PatientSource = ''Transfer In'' Group By a.Gender,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') ',       -- qryDefinition - nvarchar(max)
    N'Number on ART who TRANSFERRED in during the Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'N44',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N45',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N46',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N47',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N48',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N49',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N32',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'N34',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Total number on ART at the end of the Quarter (CURRENT ART)
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CurrentART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_CurrentART'


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
(   N'CDCTack1_CurrentART',       -- qryName - nvarchar(50)
    N'Select a.Gender,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') AgeGroup,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where a.RegistrationDate <= Cast(@todate As datetime)  AND a.StartARTDate <= Cast(@todate As datetime) AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1 Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'')',       -- qryDefinition - nvarchar(max)
    N'Total number on ART at the end of the Quarter (CURRENT ART)',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'Q44',       
    @QueryID,         
    N'Male0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q45',       
    @QueryID,         
    N'Male2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q46',       
    @QueryID,         
    N'Male5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q47',       
    @QueryID,         
    N'Female0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q48',       
    @QueryID,         
    N'Female2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q49',       
    @QueryID,         
    N'Female5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q32',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'Q34',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--ART Terminations
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTTerminations')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTTerminations'


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
(   N'CDCTack1_ARTTerminations',       -- qryName - nvarchar(50)
    N'Select aa.Gender, aa.AgeGroup,aa.ExitReason, Count(Distinct aa.PatientPK) Total  
From (Select a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''CDCTrack1'') AgeGroup
, a.PatientPK, a.ExitReason     
From tmp_ARTPatients a Where a.ExitDate <= Cast(@Todate As datetime)    
Union Select b.Gender, dbo.fn_GetAgeGroup(dbo.fn_GetAge(b.DOB, b.LastARTDate), ''CDCTrack1'') AgeGroup
, b.PatientPK, ''Lost'' ExitReason    
From tmp_ARTPatients b  Where dbo.fn_ActiveCCC(cast(@todate as date), b.PatientPK) = 0    
And b.ExitReason Is Null) aa  WHERE ExitReason IN (''Death'',''Lost'',''Transfer'',''Stop'')
Group By aa.Gender, aa.AgeGroup, aa.ExitReason',       -- qryDefinition - nvarchar(max)
    N'Total number on ART at the end of the Quarter (CURRENT ART)',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'E85',       
    @QueryID,         
    N'Male0-1StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E86',       
    @QueryID,         
    N'Male2-4StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E87',       
    @QueryID,         
    N'Male5-14StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E88',       
    @QueryID,         
    N'Female0-1StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E89',       
    @QueryID,         
    N'Female2-4StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E90',       
    @QueryID,         
    N'Female5-14StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E79',       
    @QueryID,         
    N'Male15+StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E81',       
    @QueryID,         
    N'Female15+StopTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

,(   N'G85',       
    @QueryID,         
    N'Male0-1TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G86',       
    @QueryID,         
    N'Male2-4TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G87',       
    @QueryID,         
    N'Male5-14TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G88',       
    @QueryID,         
    N'Female0-1TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G89',       
    @QueryID,         
    N'Female2-4TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G90',       
    @QueryID,         
    N'Female5-14TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G79',       
    @QueryID,         
    N'Male15+TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G81',       
    @QueryID,         
    N'Female15+TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

,(   N'I85',       
    @QueryID,         
    N'Male0-1DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I86',       
    @QueryID,         
    N'Male2-4DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I87',       
    @QueryID,         
    N'Male5-14DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I88',       
    @QueryID,         
    N'Female0-1DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I89',       
    @QueryID,         
    N'Female2-4DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I90',       
    @QueryID,         
    N'Female5-14DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I79',       
    @QueryID,         
    N'Male15+DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'I81',       
    @QueryID,         
    N'Female15+DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

,(   N'L85',       
    @QueryID,         
    N'Male0-1LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L86',       
    @QueryID,         
    N'Male2-4LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L87',       
    @QueryID,         
    N'Male5-14LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L88',       
    @QueryID,         
    N'Female0-1LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L89',       
    @QueryID,         
    N'Female2-4LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L90',       
    @QueryID,         
    N'Female5-14LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L79',       
    @QueryID,         
    N'Male15+LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L81',       
    @QueryID,         
    N'Female15+LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--ART Regimens
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTRegimens')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CDCTack1_ARTRegimens'


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
(   N'CDCTack1_ARTRegimens',       -- qryName - nvarchar(50)
    N'WITH CDCRegimens AS
(SELECT ''3TC+AZT+NVP'' regimen UNION
SELECT ''3TC+AZT+EFV'' regimen UNION
SELECT ''3TC+AZT+LPV/r'' regimen UNION
SELECT ''3TC+ABC+EFV'' regimen UNION
SELECT ''3TC+ABC+NVP'' regimen UNION
SELECT ''3TC+ABC+LPV/r'' regimen UNION
SELECT ''3TC+NVP+TDF'' regimen UNION
SELECT ''3TC+EFV+TDF'' regimen UNION
SELECT ''3TC+D4T+EFV'' regimen UNION
SELECT ''3TC+D4T+LPV/r'' regimen UNION
SELECT ''3TC+D4T+NVP'' regimen UNION
SELECT ''3TC+LPV/r+TDF'' regimen )	
	SELECT a.Regimen
, a.AgeGroup
, COUNT(DISTINCT a.PatientPK) Total FROM
(Select a.PatientPK
, a.Gender
, dbo.fn_GetAgeGroup(a.AgeARTStart, ''CDCTrack1'') AgeGroup
, Case WHEN b.regimen IS NULL THEN ''Others'' ELSE b.regimen END AS Regimen 
From tmp_ARTPatients a  
LEFT JOIN CDCRegimens b ON a.LastRegimen = b.regimen
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1) a
Group By a.AgeGroup, a.Regimen',       -- qryDefinition - nvarchar(max)
    N'Number of Active patients on each regimen at the end of the Quarter',       -- qryDescription - nvarchar(200)
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
(   N'CDCTack1_Report',       -- sbCategory - nvarchar(50)
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
(   N'D110',       
    @QueryID,         
    N'3TC+AZT+NVP0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D111',       
    @QueryID,         
    N'3TC+AZT+EFV0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D112',       
    @QueryID,         
    N'3TC+AZT+LPV/r0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D113',       
    @QueryID,         
    N'3TC+ABC+EFV0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D114',       
    @QueryID,         
    N'3TC+ABC+NVP0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D115',       
    @QueryID,         
    N'3TC+ABC+LPV/r0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D116',       
    @QueryID,         
    N'3TC+NVP+TDF0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D117',       
    @QueryID,         
    N'3TC+EFV+TDF0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D118',       
    @QueryID,         
    N'3TC+LPV/r+TDF0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D119',       
    @QueryID,         
    N'Others0-1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F110',       
    @QueryID,         
    N'3TC+AZT+NVP2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F111',       
    @QueryID,         
    N'3TC+AZT+EFV2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F112',       
    @QueryID,         
    N'3TC+AZT+LPV/r2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F113',       
    @QueryID,         
    N'3TC+ABC+EFV2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F114',       
    @QueryID,         
    N'3TC+ABC+NVP2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F115',       
    @QueryID,         
    N'3TC+ABC+LPV/r2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F116',       
    @QueryID,         
    N'3TC+NVP+TDF2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F117',       
    @QueryID,         
    N'3TC+EFV+TDF2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F118',       
    @QueryID,         
    N'3TC+LPV/r+TDF2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F119',       
    @QueryID,         
    N'Others2-4Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H110',       
    @QueryID,         
    N'3TC+AZT+NVP5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H111',       
    @QueryID,         
    N'3TC+AZT+EFV5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H112',       
    @QueryID,         
    N'3TC+AZT+LPV/r5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H113',       
    @QueryID,         
    N'3TC+ABC+EFV5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H114',       
    @QueryID,         
    N'3TC+ABC+NVP5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H115',       
    @QueryID,         
    N'3TC+ABC+LPV/r5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H116',       
    @QueryID,         
    N'3TC+NVP+TDF5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H117',       
    @QueryID,         
    N'3TC+EFV+TDF5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H118',       
    @QueryID,         
    N'3TC+LPV/r+TDF5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'H119',       
    @QueryID,         
    N'Others5-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J110',       
    @QueryID,         
    N'3TC+AZT+NVP15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J111',       
    @QueryID,         
    N'3TC+AZT+EFV15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J112',       
    @QueryID,         
    N'3TC+AZT+LPV/r15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J113',       
    @QueryID,         
    N'3TC+ABC+EFV15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J114',       
    @QueryID,         
    N'3TC+ABC+NVP15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J115',       
    @QueryID,         
    N'3TC+ABC+LPV/r15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J116',       
    @QueryID,         
    N'3TC+NVP+TDF15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J117',       
    @QueryID,         
    N'3TC+EFV+TDF15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J118',       
    @QueryID,         
    N'3TC+LPV/r+TDF15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J119',       
    @QueryID,         
    N'Others15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)