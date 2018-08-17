Declare @CatID as INT, @ReportGroupID as INT, @ReportID as INT, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'MoH_731_v1')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'MoH_731_v1'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID =(Select CatID FROM aa_Category WHERE Category = N'MoH_731_v1')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('MoH_731_v1',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'MOH Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('MOH Reports',3)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'MOH Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731_v1')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'MoH_731_v1'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731_v1')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports WHERE ReportName = N'MoH_731_v1')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('MoH_731_v1'
,'MoH 731 v1'
,'MoH 731 v1'
, @CatID
, 'MoH_731_v1_Template.xlsx'
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_Header'


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
(   N'MoH_731_v1_Header',       -- qryName - nvarchar(50)
    N'Select DATENAME(mm, Cast(@ToDate AS DATE)) ReportMonth, DATENAME(yy, Cast(@ToDate AS DATE)) ReportYear, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)  
, MFLCode = (Select TOP 1 SiteCode FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Header',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'I3',       
    @QueryID,         
    N'ReportMonth',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'K3',       
    @QueryID,         
    N'ReportYear',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'M3',       
    @QueryID,         
    N'MFLCode',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B3',       
    @QueryID,         
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.1 On HEI CTX
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_HEICTX')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_HEICTX'


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
(   N'MoH_731_v1_HEICTX',       -- qryName - nvarchar(50)
    N'Select COUNT(DISTINCT a.PatientPK) EligibleForCTX
, COUNT(b.PatientPK) OnCTX 
From tmp_HEI a
LEFT JOIN (Select tmp_Pharmacy.PatientPK,
			Min(tmp_Pharmacy.DispenseDate) FirstCTXDate
			From tmp_Pharmacy
			Where tmp_Pharmacy.ProphylaxisType = ''CTX''
			Group By tmp_Pharmacy.PatientPK) b On a.PatientPK = b.PatientPK
Where DateDiff(dd, a.DOB, Cast(@todate As datetime)) <= 60',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 HEI On CTX',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J6',       
    @QueryID,         
    N'OnCTX',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J7',       
    @QueryID,         
    N'EligibleForCTX',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.1 On CTX/Dapsone
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_OnCTX')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_OnCTX'


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
(   N'MoH_731_v1_OnCTX',       -- qryName - nvarchar(50)
    N'Select a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_PatientMaster a  
Where a.RegistrationAtCCC <= Cast(@todate As datetime)  
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 On CTX/Dapsone',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J8',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L8',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J9',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L9',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.2 Enrollment into Care Below 1
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v2_EnrolledInCareBelow1')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v2_EnrolledInCareBelow1'


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
(   N'MoH_731_v2_EnrolledInCareBelow1',       -- qryName - nvarchar(50)
    N'Select Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  
Where p.RegistrationAtCCC   Between Cast(@fromdate As datetime) And Cast(@todate As datetime)  
AND (p.PatientSource NOT LIKE ''%transfer in%'' OR p.PatientSource IS NULL)
AND p.AgeEnrollment < 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v2 Enrolled In Care Below 1',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J13',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.2 Enrollment into Care
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v2_EnrolledInCare')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v2_EnrolledInCare'


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
(   N'MoH_731_v2_EnrolledInCare',       -- qryName - nvarchar(50)
    N'Select p.Gender
,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'') AgeGroup
,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  
Where p.RegistrationAtCCC   Between Cast(@fromdate As datetime) And Cast(@todate As datetime)  
AND (p.PatientSource NOT LIKE ''%transfer in%'' OR p.PatientSource IS NULL)
Group By p.Gender, dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v2 EnrolledInCare',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J14',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L14',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J15',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L15',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.3 CurrentCare Below 1
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentCareBelow1')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentCareBelow1'


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
(   N'MoH_731_v1_CurrentCareBelow1',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_PatientMaster a  
Where a.RegistrationAtCCC <= Cast(@todate As datetime)  
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
AND a.AgeLastVisit < 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Current On Care Below 1',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J19',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.3 CurrentCare
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentCare')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentCare'


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
(   N'MoH_731_v1_CurrentCare',       -- qryName - nvarchar(50)
    N'Select a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_PatientMaster a  
Where a.RegistrationAtCCC <= Cast(@todate As datetime)  
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Current On Care',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J20',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L20',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J21',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L21',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.4 Starting ART Below 1
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTBelow1')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTBelow1'


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
(   N'MoH_731_v1_StartingARTBelow1',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
AND a.AgeARTStart < 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Starting ART Below 1',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J25',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.4 Starting ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingART'


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
(   N'MoH_731_v1_StartingART',       -- qryName - nvarchar(50)
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''COARSE'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeARTStart, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 StartingART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J26',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L26',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J27',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L27',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.4 Starting ART Pregnant
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTPregnant')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTPregnant'


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
(   N'MoH_731_v1_StartingARTPregnant',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
	INNER JOIN tmp_Pregnancies b ON a.PatientPK = b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
AND b.PregnantOnARTStart = 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Starting ART Pregnant',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J29',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.4 Starting ART TB
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTTB')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_StartingARTTB'


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
(   N'MoH_731_v1_StartingARTTB',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
	INNER JOIN tmp_TBPatients b ON a.PatientPK = b.PatientPK
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime) 
AND b.TBTreatmentStartDate BETWEEN Cast(@fromdate As datetime)  AND Cast(@todate As datetime)',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Starting ART TB',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J30',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.6 Current On ART Below 1
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentARTBelow1')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentARTBelow1'


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
(   N'MoH_731_v1_CurrentARTBelow1',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
AND a.AgeLastVisit < 1',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 CurrentART Below 1',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J39',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.6 Current On ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CurrentART'


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
(   N'MoH_731_v1_CurrentART',       -- qryName - nvarchar(50)
    N'Select a.Gender
,    dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup
,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  
Where a.RegistrationDate <= Cast(@todate As datetime)  
AND a.StartARTDate <= Cast(@todate As datetime) 
AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1
Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 CurrentART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J40',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L40',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J41',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L41',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)




--3.7 Cumulative ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CumulativeART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CumulativeART'


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
(   N'MoH_731_v1_CumulativeART',       -- qryName - nvarchar(50)
    N'Select e.Gender,
  dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'') AgeGroup,
  Count(Distinct e.PatientPK) Total
From tmp_ARTPatients e
  Left Join (Select Distinct e.PatientPK
  From tmp_ARTPatients e
  Where e.StartARTDate <= Cast(@todate As datetime) 
  And e.StartARTDate < e.StartARTAtThisFacility 
  And e.RegistrationDate <= Cast(@todate As datetime)
  And e.PatientSource In (''Transfer In'', ''Other facility'')) TI
On e.PatientPK = TI.PatientPK
Where e.StartARTDate <= Cast(@todate As datetime) 
And e.RegistrationDate <= Cast(@todate As datetime) 
And TI.PatientPK Is Null
Group By e.Gender,
  dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Cumulative ART',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J45',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L45',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J46',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L46',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)



--3.8 Survival and Retention
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_Retention')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_Retention'


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
(   N'MoH_731_v1_Retention',       -- qryName - nvarchar(50)
    N'Select SUM(A.OnART) OnART  
, SUM(A.NetCohort) NetCohort  
, SUM(A.OnOriginalFirstLine) OnOriginalFirstLine  
, SUM(A.OnAlternativeFirstLine) OnAlternativeFirstLine   
, SUM(A.OnSecondLineOrHigher) OnSecondLineOrHigher   
FROM   (
Select   a.PatientPK  
, a.StartARTDate  
, a.ExitReason  
, CASE WHEN a.ExitReason IS NULL OR a.ExitReason != ''Transfer''  THEN 1 ELSE 0 END AS NetCohort  
, dbo.fn_ActiveCCC(@Todate, a.PatientPK) OnART   
, a.LastVisit
, a.LastARTDate
, CASE WHEN (a.LastRegimenLine = ''First line'' OR a.LastRegimenLine NOT IN (''First line substitute'',''Second line'',''Second line substitute'') OR a.LastRegimenLine IS NULL) AND dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1 THEN 1 ELSE 0 END AS OnOriginalFirstLine
, CASE WHEN a.LastRegimenLine = ''First line substitute'' AND dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1 THEN 1 ELSE 0 END AS OnAlternativeFirstLine
, CASE WHEN a.LastRegimenLine IN (''Second line'',''Second line substitute'') 
AND dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1 THEN 1 ELSE 0 END AS OnSecondLineOrHigher
FROM tmp_ARTPatients a  
Where a.StartARTDate   Between DateAdd(mm, -12, Cast(@fromdate As datetime))   And DateAdd(mm, -12, Cast(@todate As datetime)
)) A',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Retention',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J50',       
    @QueryID,         
    N'NetCohort',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J51',       
    @QueryID,         
    N'OnOriginalFirstLine',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J52',       
    @QueryID,         
    N'OnAlternativeFirstLine',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J53',       
    @QueryID,         
    N'OnSecondLineOrHigher',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--3.9 TB Screening
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_TBScreening')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_TBScreening'


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
(   N'MoH_731_v1_TBScreening',       -- qryName - nvarchar(50)
    N'Select a.Gender,  dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup  
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
GROUP BY a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J57',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L57',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J58',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'L58',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)





--3.9 CaCx Screening
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CaCxScreening')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_CaCxScreening'


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
(   N'MoH_731_v1_CaCxScreening',       -- qryName - nvarchar(50)
    N'	SELECT COUNT(Distinct a.Ptn_Pk) Total
	FROM DTL_Adult_Initial_Evaluation_Form a INNER JOIN ord_Visit b ON a.Visit_Pk = b.Visit_Id
	WHERE CervicalCancerScreenedDate BETWEEN 
	Cast(@fromdate As datetime) And Cast(@todate As datetime)    
	AND CervicalCancerScreened > 0
	AND (b.DeleteFlag = 0 OR b.DeleteFlag IS NULL)',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1 Cervical Cancer Screening',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J60',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.10 PwP
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_PwP')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_PwP'


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
(   N'MoH_731_v1_PwP',       -- qryName - nvarchar(50)
    N'SELECT SUM(ProvidedWithCondoms)ProvidedWithCondoms
	, SUM(ModernContraception) ModernContraception
	FROM (
	select DISTINCT a.PatientPK
	, CASE WHEN ProvidedWithCondoms = ''YES'' THEN 1 ELSE 0 END AS ProvidedWithCondoms 
	, CASE WHEN ModernContraception = ''YES'' THEN 1 ELSE 0 END AS ModernContraception 
	from tmp_PwPServices a INNER JOIN tmp_PatientMaster b ON a.PatientPK = b.PatientPK
	WHERE VisitDate BETWEEN CAST(@fromdate as date) AND CAST(@todate as date)
	AND b.RegistrationAtCCC <= CAST(@todate as date)
	) a',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1_PwP PwP Services',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J63',       
    @QueryID,         
    N'ProvidedWithCondoms',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'J64',       
    @QueryID,         
    N'ModernContraception',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.11 Females 18+ Visits
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_VisitsF18')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_VisitsF18'


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
(   N'MoH_731_v1_VisitsF18',       -- qryName - nvarchar(50)
    N'Select Count(f18.VisitDate) Total
	From (Select Distinct a.PatientPK,
    a.VisitDate
	From tmp_ClinicalEncounters a
    Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK
	Where a.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate As
    datetime) And a.Service = ''ART'' And b.Gender = ''Female'' And
	DATEDIFF(dd, b.DOB, Cast(@todate As datetime))/365.25 >= 18) f18',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1_Visits Female 18+',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J67',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)




--3.11 Scheduled Visits
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_ScheduledVisits')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_ScheduledVisits'


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
(   N'MoH_731_v1_ScheduledVisits',       -- qryName - nvarchar(50)
    N'Select Count(sch.VisitDate) Total
From (Select Distinct c.PatientPK,
c.VisitDate
From tmp_ClinicalEncounters c
Inner Join (Select Distinct a.PatientPK,
a.VisitDate
From tmp_ClinicalEncounters a) a On c.PatientPK = a.PatientPK And
c.VisitDate = a.VisitDate
Inner Join (Select Distinct a.PatientPK,
a.NextAppointmentDate
From tmp_ClinicalEncounters a) b On a.PatientPK = b.PatientPK And
a.VisitDate = b.NextAppointmentDate
Inner Join tmp_PatientMaster p On c.PatientPK = p.PatientPK
Where c.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate As
datetime) And c.Service = ''ART'') sch',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1_Scheduled Visits',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J68',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--3.11 Unscheduled Visits
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_UnscheduledVisits')
DELETE FROM dbo.aa_Queries WHERE qryName = 'MoH_731_v1_UnscheduledVisits'


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
(   N'MoH_731_v1_UnscheduledVisits',       -- qryName - nvarchar(50)
    N'Select Count(unsch.VisitDate) Total
From (Select Distinct c.PatientPK,
    c.VisitDate
  From tmp_ClinicalEncounters c
    Inner Join (Select Distinct a.PatientPK,
      a.VisitDate
    From tmp_ClinicalEncounters a) a On c.PatientPK = a.PatientPK And
      c.VisitDate = a.VisitDate
    Left Join (Select Distinct a.PatientPK,
      a.NextAppointmentDate
    From tmp_ClinicalEncounters a) b On a.PatientPK = b.PatientPK And
      a.VisitDate = b.NextAppointmentDate
    Inner Join tmp_PatientMaster p On c.PatientPK = p.PatientPK
  Where c.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate As
    datetime) And b.PatientPK Is Null And c.Service = ''ART'') unsch',       -- qryDefinition - nvarchar(max)
    N'MoH_731_v1_Unscheduled Visits',       -- qryDescription - nvarchar(200)
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
(   N'MoH_731_v1',       -- sbCategory - nvarchar(50)
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
(   N'J69',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

