Declare @CatID as INT, @ReportGroupID as INT, @ReportID as INT, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'MoH_731')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'MoH_731'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID =(Select CatID FROM aa_Category WHERE Category = N'MoH_731')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('MoH_731',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'MOH Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('MOH Reports',2)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'MOH Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'MoH_731'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('MoH_731'
,'MoH 731 v2'
,'MoH 731 v2'
, @CatID
, 'MoH_731_Template.xlsx'
, 'MoH731'
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    NULL,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)


--Header
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_Header'


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
(   N'MoH_731_Header',       -- qryName - nvarchar(50)
    N'Select DATENAME(mm, Cast(@ToDate AS DATE)) ReportMonth, DATENAME(yy, Cast(@ToDate AS DATE)) ReportYear, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)  
, MFLCode = (Select TOP 1 SiteCode FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'MoH_731 Header',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'F3',       
    @QueryID,         
    N'ReportMonth',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F4',       
    @QueryID,         
    N'ReportYear',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'F5',       
    @QueryID,         
    N'MFLCode',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B5',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.1 Enrollment into Care
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.1a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.1a'


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
(   N'MoH_731_3.1a',       -- qryName - nvarchar(50)
    N'Select p.Gender
,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''MOH731'') AgeGroup
,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  
Where p.RegistrationAtCCC   Between Cast(@fromdate As datetime) And Cast(@todate As datetime)  
AND (p.PatientSource NOT LIKE ''%transfer in%'' OR p.PatientSource IS NULL)
Group By p.Gender, dbo.fn_GetAgeGroup(p.AgeEnrollment, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.1a Enrollment in Care',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'D135',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E135',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D136',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E136',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C137',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E137',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C138',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E138',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C139',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E139',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C140',       
    @QueryID,         
    N'Male25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E140',       
    @QueryID,         
    N'Female25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.1 Enrollment into Care Key Pops
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.1_KeyPop')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.1_KeyPop'


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
(   N'MoH_731_3.1_KeyPop',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_PatientMaster a 
INNER JOIN (select distinct patientpk from tmp_KeyPops
Where VisitDate BETWEEN Cast(@fromdate As datetime) And Cast(@todate As datetime)
AND (SexWorker = ''YES'' OR MenWhoHaveSexWithMen = ''YES'' OR PeopleWhoInjectDrugs = ''YES'')
) b on a.PatientPK = b.PatientPK
Where a.RegistrationAtCCC   Between Cast(@fromdate As datetime) And Cast(@todate As datetime)  
AND (a.PatientSource NOT LIKE ''%transfer in%'' OR a.PatientSource IS NULL)',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.1a Enrollment in Care (Key Pop)',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'E142',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.2 Current Pre-ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.2')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.2'


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
(   N'MoH_731_3.2',       -- qryName - nvarchar(50)
    N'Select CASE WHEN a.AgeLastVisit <= 14.9 THEN ''0-14'' ELSE ''15+'' END AS AgeGroup
, COUNT(DISTINCT a.PatientPK) Total
FROM tmp_PatientMaster a LEFT JOIN tmp_ARTPatients b
ON a.PatientPK = b.PatientPK
WHERE (b.PatientPK IS NULL OR b.StartARTDate > CAST(@todate as date))
AND a.RegistrationAtCCC <= CAST(@todate as date)
AND dbo.fn_ActiveCCC(cast(@todate as date), a.PatientPK) = 1
GROUP BY CASE WHEN a.AgeLastVisit <= 14.9 THEN ''0-14'' ELSE ''15+'' END',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.2 Current on Pre ART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C145',       
    @QueryID,         
    N'0-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C146',       
    @QueryID,         
    N'15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.3 Starting ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.3a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.3a'


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
(   N'MoH_731_3.3a',       -- qryName - nvarchar(50)
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''MOH731'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeARTStart, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.3a Starting ART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'D150',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E150',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D151',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E151',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C152',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E152',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C153',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E153',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C154',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E154',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C155',       
    @QueryID,         
    N'Male25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E155',       
    @QueryID,         
    N'Female25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.3 Starting ART Key Pop
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.3_KeyPop')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.3_KeyPop'


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
(   N'MoH_731_3.3_KeyPop',       -- qryName - nvarchar(50)
    N'Select  Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
INNER JOIN (select distinct patientpk from tmp_KeyPops
Where VisitDate BETWEEN Cast(@fromdate As datetime) And Cast(@todate As datetime)
AND (SexWorker = ''YES'' OR MenWhoHaveSexWithMen = ''YES'' OR PeopleWhoInjectDrugs = ''YES'')
) b on a.PatientPK = b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) ',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.3a Starting ART (Key Pop)',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'E157',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.4 Current On ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.4a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.4a'


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
(   N'MoH_731_3.4a',       -- qryName - nvarchar(50)
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.4a Current On ART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'D160',       
    @QueryID,         
    N'Male<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E160',       
    @QueryID,         
    N'Female<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D161',       
    @QueryID,         
    N'Male1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E161',       
    @QueryID,         
    N'Female1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C162',       
    @QueryID,         
    N'Male10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E162',       
    @QueryID,         
    N'Female10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C163',       
    @QueryID,         
    N'Male15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E163',       
    @QueryID,         
    N'Female15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C164',       
    @QueryID,         
    N'Male20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E164',       
    @QueryID,         
    N'Female20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C165',       
    @QueryID,         
    N'Male25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'E165',       
    @QueryID,         
    N'Female25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.4 Current On ART Key Pop
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.4_KeyPop')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.4_KeyPop'


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
(   N'MoH_731_3.4_KeyPop',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  
From tmp_ARTPatients a INNER JOIN
(select DISTINCT a.PatientPK from tmp_KeyPops a inner join 
(select PatientPK, MAX(VisitDate) LastVisit FROM tmp_ClinicalEncounters
WHERE VisitDate <= cast(@todate as date)
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.VisitDate = b.LastVisit
WHERE (SexWorker = ''YES'' OR MenWhoHaveSexWithMen = ''YES'' OR PeopleWhoInjectDrugs = ''YES'')
)  b ON a.PatientPK = b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.4a Current On ART (Key Pop)',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'E167',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.5 Retention On ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.5')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.5'


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
(   N'MoH_731_3.5',       -- qryName - nvarchar(50)
    N'Select SUM(A.OnART) OnART  
, SUM(A.NetCohort) NetCohort  
, SUM(A.VLSuppressed) VLSuppressed  
, SUM(A.VLResult) VLResult   
FROM   (
Select   a.PatientPK  
, a.StartARTDate  
, a.ExitReason  
, CASE WHEN a.ExitReason IS NULL OR a.ExitReason != ''Transfer''  THEN 1 ELSE 0 END AS NetCohort  
, b.LastVL  
, CASE WHEN b.PatientPK IS NOT NULL AND dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1 THEN 1 ELSE 0 END AS VLResult  
, Case WHEN FLOOR(b.LastVL) < 1000.0 AND dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1 THEN 1 ELSE 0 END AS VLSuppressed  
, dbo.fn_ActiveCCC(@Todate, a.PatientPK) OnART   
, a.LastVisit
, a.LastARTDate
FROM tmp_ARTPatients a  
LEFT JOIN    (Select    a.PatientPK   
			, LastVL    FROM IQC_LastVL  a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
			Where LastVLDate    
			Between DateAdd(mm, -12, Cast(@fromdate As datetime))  And  Cast(@todate As datetime)) b   
On a.PatientPK = b.PatientPK  
Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime))
) A',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.5 12m Retention On ART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C170',       
    @QueryID,         
    N'OnART',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C171',       
    @QueryID,         
    N'NetCohort',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C172',       
    @QueryID,         
    N'VLSuppressed',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C173',       
    @QueryID,         
    N'VLResult',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.6 On CTX/Dapsone
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.6')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.6'


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
(   N'MoH_731_3.6',       -- qryName - nvarchar(50)
    N'Select  dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_PatientMaster a  
Where a.RegistrationAtCCC <= Cast(@todate As datetime)  
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By  dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.6 On CTX/Dapsone',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C176',       
    @QueryID,         
    N'<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C177',       
    @QueryID,         
    N'1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C178',       
    @QueryID,         
    N'10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C179',       
    @QueryID,         
    N'15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C180',       
    @QueryID,         
    N'20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C181',       
    @QueryID,         
    N'25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.7a TB Screening
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7a'


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
(   N'MoH_731_3.7a',       -- qryName - nvarchar(50)
    N'Select   dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'') AgeGroup  
, COUNT(Distinct a.PatientPK) Total  
FROM tmp_PatientMaster a  INNER JOIN 
	(SELECT a.PatientPK, Max(a.VisitDate) LastScreen     
	FROM tmp_ClinicalEncounters a     
	INNER JOIN       
			(SELECT a.PatientPK
			,Max(VisitDate) LastVisit        
			FROM tmp_ClinicalEncounters a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK         
			WHERE VisitDate <= CAST(@ToDate as Datetime)     
			AND (EncounterType = ''Self'' Or EncounterType IS NULL)                
			GROUP BY a.PatientPK) b 
		ON a.PatientPK = b.PatientPK  AND a.VisitDate = b.LastVisit      
	inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK      
	WHERE a.SymptomCategory = ''TB Screening''     
	AND (a.EncounterType = ''Self'' Or a.EncounterType IS NULL)          
	GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK 
Where dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1  
AND a.RegistrationAtCCC <= Cast(@todate As datetime)  
GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.7a TB Screening at Last Visit',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C185',       
    @QueryID,         
    N'<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C186',       
    @QueryID,         
    N'1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C187',       
    @QueryID,         
    N'10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C188',       
    @QueryID,         
    N'15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C189',       
    @QueryID,         
    N'20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C190',       
    @QueryID,         
    N'25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.7a Linelist of Active Patients NOT Screened at Last Visit
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7a_NotScreened')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7a_NotScreened'


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
(   N'MoH_731_3.7a_NotScreened',       -- qryName - nvarchar(50)
    N'Select a.PatientPK, a.SatelliteName SiteName, a.PatientID, a.Gender
, c.LastVisit FROM tmp_PatientMaster a INNER JOIN (
Select Distinct a.PatientPK  From tmp_PatientMaster a  
Where a.RegistrationAtCCC <= Cast(@todate As datetime)  
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1) active 
ON a.PatientPK = active.PatientPK
left join
(Select Distinct a.PatientPK 
FROM tmp_PatientMaster a  INNER JOIN 
	(SELECT a.PatientPK, Max(a.VisitDate) LastScreen     
	FROM tmp_ClinicalEncounters a     
	INNER JOIN       
			(SELECT a.PatientPK
			,Max(VisitDate) LastVisit        
			FROM tmp_ClinicalEncounters a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK         
			WHERE VisitDate <= CAST(@ToDate as Datetime)     
			AND (EncounterType = ''Self'' Or EncounterType IS NULL)                
			GROUP BY a.PatientPK) b 
		ON a.PatientPK = b.PatientPK  AND a.VisitDate = b.LastVisit      
	inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK      
	WHERE a.SymptomCategory = ''TB Screening''     
	AND (a.EncounterType = ''Self'' Or a.EncounterType IS NULL)          
	GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK 
Where dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1  
AND a.RegistrationAtCCC <= Cast(@todate As datetime)) screened on active.PatientPK = screened.PatientPK
LEFT JOIN
(SELECT a.PatientPK
			,Max(VisitDate) LastVisit        
			FROM tmp_ClinicalEncounters a          
			WHERE VisitDate <= CAST(@ToDate as Datetime)     
			AND (EncounterType = ''Self'' Or EncounterType IS NULL)                
			GROUP BY a.PatientPK) c ON active.PatientPK = c.PatientPK
Where screened.PatientPK is null',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.7a Linelist of Active Patients NOT Screened for TB at their last visit',       -- qryDescription - nvarchar(200)
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
(@ReportID, @QueryID,'Not Screened TB', GETDATE())

--3.7b Presumed TB 
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7b')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7b'


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
(   N'MoH_731_3.7b',       -- qryName - nvarchar(50)
    N'select count(distinct patientpk) Total
 from tmp_ClinicalEncounters
where VisitDate between cast(@fromdate as date) and cast(@todate as date)
and SymptomCategory = ''TB Screening'' and Symptom Not IN (''No signs'',''None'') ',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.7b Presumed TB in the Reporting Period',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C192',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.7b Linelist of Active Patients with Presumed TB In The Reporting Period
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7b_PresumedTB')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.7b_PresumedTB'


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
(   N'MoH_731_3.7b_PresumedTB',       -- qryName - nvarchar(50)
    N'with symptoms as 
(select distinct PatientPK
, VisitDate
, Symptom 
from tmp_ClinicalEncounters WHERE VisitDate between cast(@fromdate as date) and cast(@todate as date)
and SymptomCategory = ''TB Screening'' and Symptom NOT IN (''No signs'',''None''))

, GeneXpert as (select
a.Ptn_pk PatientPK
, b.Name GeneXpert
, c.VisitDate
from [dtl_TBScreening] a INNER JOIN mst_Decode b ON a.GeneExpert = b.ID
inner join ord_Visit c ON a.Visit_Pk = c.Visit_Id
where cast(c.VisitDate as date) >= cast(@fromdate as date) 
)


, Sputum as (select
a.Ptn_pk PatientPK
, b.Name Sputum
, c.VisitDate
from [dtl_TBScreening] a INNER JOIN mst_Decode b ON a.SputumDST = b.ID
inner join ord_Visit c ON a.Visit_Pk = c.Visit_Id
where cast(c.VisitDate as date) >= cast(@fromdate as date) 
)

Select distinct
 c.SatelliteName FacilityName
, c.PatientID
, c.Gender
, cast(b.visitdate as date) VisitDate
, stuff((select '', '' + Symptom from symptoms r where r.VisitDate = s.VisitDate AND r.PatientPK = s.PatientPK 
for xml PATH('''')),1,1,'''') TBScreening
, d.GeneXpert
, e.Sputum
from symptoms s inner join tmp_ClinicalEncounters b on s.VisitDate = b.VisitDate and s.PatientPK = b.PatientPK
inner join tmp_PatientMaster c ON b.PatientPK = c.PatientPK
left join GeneXpert d ON s.PatientPK = d.PatientPK
left join Sputum e ON s.PatientPK = e.PatientPK',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.7a Linelist of Active Patients with Presumed TB in the Reporting Period',       -- qryDescription - nvarchar(200)
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
(@ReportID, @QueryID,'Presumed TB', GETDATE())


--3.8a Starting IPT
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.8a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.8a'


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
(   N'MoH_731_3.8a',       -- qryName - nvarchar(50)
    N'Select   dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'') AgeGroup  
,COUNT(Distinct a.PatientPK) Total  
FROM tmp_PatientMaster a  INNER JOIN   
	(Select a.PatientPK FROM	
		(Select a.PatientPK,  Min(Coalesce(a.DispenseDate, b.visitdate)) IPTStartDate  
		From tmp_Pharmacy a  Inner Join ord_visit b On a.VisitID = b.visit_id  inner join tmp_PatientMaster c ON a.PatientPK = c.PatientPK  
		Where a.Drug LIKE ''Isoniazid%''  
		Group By a.PatientPK) a  
	inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
	Where a.IPTStartDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime))  b 
ON a.PatientPK = b.PatientPK  
Where dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1  
GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, ''MOH731'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.8a Starting IPT in the Reporting Period',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C195',       
    @QueryID,         
    N'<1Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C196',       
    @QueryID,         
    N'1-9Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C197',       
    @QueryID,         
    N'10-14Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C198',       
    @QueryID,         
    N'15-19Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C199',       
    @QueryID,         
    N'20-24Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C200',       
    @QueryID,         
    N'25+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.9a Nutrition Assessment
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9a')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9a'


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
(   N'MoH_731_3.9a',       -- qryName - nvarchar(50)
    N'With NutritionAssessment AS
(select a.ptn_pk PatientPK
, cast(b.visitdate as date) VisitDate
, CASE NutritionalProblem WHEN 939 THEN ''Normal''
WHEN 936 THEN ''Severe Acute Malnutrition''
WHEN 937 THEN ''Moderate Acute Malnutrition''
WHEN 941 THEN ''Overweight'' ELSE NULL END AS Assessment
from dtl_patientCounseling a
inner join ord_visit b on a.visit_pk = b.visit_id
where a.NutritionalProblem > 0)

, LastVisit AS
(Select PatientPK, MAX(VisitDate) LastVisitDate
FROM tmp_ClinicalEncounters Where VisitDate <= CAST(@todate as date)
GROUP BY PatientPK)

Select dbo.fn_GetAgeGroup(c.AgeLastVisit, ''COARSE'') AgeGroup
, COUNT(DISTINCT b.PatientPK) Total 
FROM LastVisit a INNER JOIN NutritionAssessment b ON a.PatientPK = b.PatientPK AND a.LastVisitDate = b.VisitDate
INNER JOIN tmp_PatientMaster c ON a.PatientPK = c.PatientPK
WHERE c.RegistrationAtCCC <= CAST(@todate as DATE)
GROUP BY dbo.fn_GetAgeGroup(c.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.9a Assessed for Nutrition at Last Visit',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C205',       
    @QueryID,         
    N'<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C206',       
    @QueryID,         
    N'15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.9b Malnourished at Last Visit
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9b')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9b'

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
(   N'MoH_731_3.9b',       -- qryName - nvarchar(50)
    N'With NutritionAssessment AS
(select a.ptn_pk PatientPK
, cast(b.visitdate as date) VisitDate
, CASE NutritionalProblem WHEN 939 THEN ''Normal''
WHEN 936 THEN ''Severe Acute Malnutrition''
WHEN 937 THEN ''Moderate Acute Malnutrition''
WHEN 941 THEN ''Overweight'' ELSE NULL END AS Assessment
from dtl_patientCounseling a
inner join ord_visit b on a.visit_pk = b.visit_id
where a.NutritionalProblem > 0)

, LastVisit AS
(Select PatientPK, MAX(VisitDate) LastVisitDate
FROM tmp_ClinicalEncounters Where VisitDate <= CAST(@todate as date)
GROUP BY PatientPK)

SELECT dbo.fn_GetAgeGroup(c.AgeLastVisit, ''COARSE'') AgeGroup, SUM(Malnourished) Total
FROM (
Select DISTINCT b.PatientPK
, CASE WHEN b.Assessment IN (''Severe Acute Malnutrition'',''Moderate Acute Malnutrition'') THEN 1 ELSE 0 END AS Malnourished
FROM LastVisit a INNER JOIN NutritionAssessment b ON a.PatientPK = b.PatientPK AND a.LastVisitDate = b.VisitDate) a
INNER JOIN tmp_PatientMaster c ON a.PatientPK = c.PatientPK
WHERE c.RegistrationAtCCC <= CAST(@todate as DATE)
GROUP BY dbo.fn_GetAgeGroup(c.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.9b Malnourished at Last Visit',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C208',       
    @QueryID,         
    N'<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C209',       
    @QueryID,         
    N'15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)




--3.9 Nutrition Assessment LineLists
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9a_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.9a_LineList'


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
(   N'MoH_731_3.9a_LineList',       -- qryName - nvarchar(50)
    N'With NutritionAssessment AS
(select a.ptn_pk PatientPK
, cast(b.visitdate as date) VisitDate
, CASE NutritionalProblem WHEN 939 THEN ''Normal''
WHEN 936 THEN ''Severe Acute Malnutrition''
WHEN 937 THEN ''Moderate Acute Malnutrition''
WHEN 941 THEN ''Overweight'' ELSE NULL END AS Assessment
, CASE WHEN a.NutritionCounseling = 1 THEN ''YES'' ELSE NULL END AS NutritionCounseling
from dtl_patientCounseling a
inner join ord_visit b on a.visit_pk = b.visit_id
where a.NutritionalProblem > 0)

, LastVisit AS
(Select PatientPK, MAX(VisitDate) LastVisitDate
FROM tmp_ClinicalEncounters Where VisitDate <= CAST(@todate as date)
GROUP BY PatientPK)

Select c.SatelliteName FacilityName
, c.PatientID
, c.AgeLastVisit
, CAST(d.StartARTDate as DATE) StartARTDate
, c.Gender
, b.VisitDate
, b.Assessment 
, b.NutritionCounseling

FROM LastVisit a INNER JOIN NutritionAssessment b ON a.PatientPK = b.PatientPK AND a.LastVisitDate = b.VisitDate
INNER JOIN tmp_PatientMaster c ON a.PatientPK = c.PatientPK
LEFT JOIN tmp_ARTPatients d ON a.PatientPK = d.PatientPK
WHERE c.RegistrationAtCCC <= CAST(@todate as DATE)',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.9a Line List of Clients Assessed for Nutrition',       -- qryDescription - nvarchar(200)
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
(@ReportID, @QueryID,'Nutrition Assessment', GETDATE())



--3.10 HIV in TB Clinic
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.10')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.10'


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
(   N'MoH_731_3.10',       -- qryName - nvarchar(50)
    N'Select 
COUNT(TB.PatientPK) NewCases
, ISNULL(SUM(TB.KP),0) KP
, ISNULL(SUM(TB.NewlyTestedHIV),0) NewlyTested
, ISNULL(SUM(TB.NewHIVPositive),0) NewPositive
, ISNULL(SUM(TB.TBAlreadyOnHAART),0) AlreadyOnHAART
, ISNULL(SUM(TB.StartHAART),0) StartHAART
FROM (
Select DISTINCT a.PatientPK
, a.HIVTestDate
, COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) TBStartDate
, b.RegistrationAtCCC
, coalesce(c.StartARTDate, a.StartARTDate) StartARTDate
, CASE WHEN a.HIVTestDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) THEN 1 ELSE 0 END AS NewlyTestedHIV
, CASE WHEN a.HIVTestDate < CAST(@FromDate as datetime) AND a.HIVStatus = ''Positive'' 
OR b.RegistrationAtCCC < CAST(@FromDate as datetime) THEN 1 ELSE 0 END AS KP
, a.HIVStatus
, CASE WHEN a.HIVTestDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) 
AND a.HIVStatus = ''Positive'' THEN 1 ELSE 0 END AS NewHIVPositive 
, CASE WHEN coalesce(c.StartARTDate, a.StartARTDate) < COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) 
THEN 1 ELSE 0 END AS TBAlreadyOnHAART
, CASE WHEN coalesce(c.StartARTDate, a.StartARTDate) >= COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) 
AND c.StartARTDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) 
THEN 1 ELSE 0 END AS StartHAART
FROM tmp_TBPatients a LEFT JOIN tmp_PatientMaster b ON a.PatientPK =  b.PatientPK
LEFT JOIN tmp_ARTPatients c ON a.PatientPK = c.PatientPK
Where COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime)) TB',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.10 HIV in TB Clinic during the reporting period',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C216',       
    @QueryID,         
    N'NewCases',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C217',       
    @QueryID,         
    N'KP',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C218',       
    @QueryID,         
    N'NewlyTested',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C220',       
    @QueryID,         
    N'NewPositive',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C222',       
    @QueryID,         
    N'AlreadyOnHAART',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C223',       
    @QueryID,         
    N'StartHAART',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.10a HIV in TB Clinic Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.10a_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_3.10a_LineList'


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
(   N'MoH_731_3.10a_LineList',       -- qryName - nvarchar(50)
    N'Select DISTINCT b.SatelliteName FacilityName
, a.PatientID
, a.Gender
, b.AgeLastVisit
, CAST(a.HIVTestDate as DATE) HIVTestDate
, CAST(COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) AS DATE) TBStartDate
, CAST(b.RegistrationAtCCC AS DATE) RegistrationAtCCC
, CAST(c.StartARTDate AS DATE) StartARTDate
, CASE WHEN a.HIVTestDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) THEN ''YES'' ELSE ''NO'' END AS NewlyTestedHIV
, CASE WHEN a.HIVTestDate < CAST(@FromDate as datetime) AND a.HIVStatus = ''Positive'' 
OR b.RegistrationAtCCC < CAST(@FromDate as datetime) THEN ''YES'' ELSE NULL END AS KP
, a.HIVStatus
, CASE WHEN a.HIVTestDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) AND a.HIVStatus = ''Positive'' 
THEN ''YES'' ELSE NULL END AS NewHIVPositive 
, CASE WHEN c.StartARTDate < COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) THEN ''YES'' ELSE NULL END AS TBAlreadyOnHAART
, CASE WHEN c.StartARTDate >= COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) 
AND c.StartARTDate BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime) 
THEN ''YES'' ELSE NULL END AS StartHAART
FROM tmp_TBPatients a LEFT JOIN tmp_PatientMaster b ON a.PatientPK =  b.PatientPK
LEFT JOIN tmp_ARTPatients c ON a.PatientPK = c.PatientPK
Where COALESCE(a.TBTreatmentStartDate, a.RegistrationAtTBClinic) BETWEEN CAST(@FromDate as datetime) AND CAST(@Todate as datetime)
',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.10a Line List of Clients with HIV in TB Clinic during the reporting period',       -- qryDescription - nvarchar(200)
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
(@ReportID, @QueryID,'HIV in TB Clinic', GETDATE())



--3.12 CaCx Screening
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_CaCxScreening')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_CaCxScreening'


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
(   N'MoH_731_CaCxScreening',       -- qryName - nvarchar(50)
    N'	SELECT COUNT(Distinct a.Ptn_Pk) Total
	FROM DTL_Adult_Initial_Evaluation_Form a INNER JOIN ord_Visit b ON a.Visit_Pk = b.Visit_Id
	WHERE CervicalCancerScreenedDate BETWEEN 
	Cast(@fromdate As datetime) And Cast(@todate As datetime)    
	AND CervicalCancerScreened > 0
	AND (b.DeleteFlag = 0 OR b.DeleteFlag IS NULL)',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.12 Cervical Cancer Screening',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C230',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.11 Females 18+ Visits
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_VisitsF18')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_VisitsF18'


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
(   N'MoH_731_VisitsF18',       -- qryName - nvarchar(50)
    N'Select Count(f18.VisitDate) Total
	From (Select Distinct a.PatientPK,
    a.VisitDate
	From tmp_ClinicalEncounters a
    Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK
	Where a.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate As
    datetime) And a.Service = ''ART'' And b.Gender = ''Female'' And
	DATEDIFF(dd, b.DOB, Cast(@todate As datetime))/365.25 >= 18) f18',       -- qryDefinition - nvarchar(max)
    N'MoH_731 3.12 Clinical Visits Female 18+',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C231',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)



 
--3.12 On Modern FP
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_ModernFP')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_ModernFP'


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
(   N'MoH_731_ModernFP',       -- qryName - nvarchar(50)
    N'SELECT SUM(ModernContraception) Total
	FROM (
	select DISTINCT a.PatientPK
	, CASE WHEN ProvidedWithCondoms = ''YES'' THEN 1 ELSE 0 END AS ProvidedWithCondoms 
	, CASE WHEN ModernContraception = ''YES'' THEN 1 ELSE 0 END AS ModernContraception 
	from tmp_PwPServices a INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK
	WHERE VisitDate BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
	AND b.RegistrationAtCCC <= CAST(@todate as date)
	) a',       -- qryDefinition - nvarchar(max)
    N'MoH_731 Modern FP',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731',       -- sbCategory - nvarchar(50)
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
(   N'C232',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)