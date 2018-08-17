Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'CT_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'CT_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'CT_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('CT_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'HIV Care Routine Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('HIV Care Routine Reports',1)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'HIV Care Routine Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'CT_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'CT_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CT_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'CT_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('CT_Report'
,'HIV Care and Treatment Monthly Report'
,'HIV Care and Treatment Monthly Report'
, @CatID
, 'HIV_Care_And_Treatment_Template.xlsx'
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
(   N'CT_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_Report_Header'


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
(   N'CT_Report_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @todate, 106) EndDate, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'CT_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
    N'EndDate',       
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


--Number of Active Patients Placed On ART in the Month
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_NewART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_NewART'


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
(   N'CT_NewART',       -- qryName - nvarchar(50)
    N'Select Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where a.RegistrationDate <= Cast(@todate As datetime) And    a.StartARTDate Between Cast(@fromdate As datetime) And Cast(@todate As    datetime) And (a.ExitReason Is Null Or a.ExitDate > Cast(@todate As datetime))',       -- qryDefinition - nvarchar(max)
    N'Number of Active Patients Placed On ART in the Month',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B6',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Cumulative Number of Patients on Care and Treatment
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeCare')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeCare'


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
(   N'CT_CumulativeCare',       -- qryName - nvarchar(50)
    N'Select p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'') AgeGroup,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p    Left Join (Select Distinct p.PatientPK    From tmp_PatientMaster p    Where p.RegistrationAtCCC <= Cast(@todate As datetime) And      p.PatientSource In (''Transfer In'', ''Other facility'')) TI      On p.PatientPK = TI.PatientPK  Where p.RegistrationAtCCC <= Cast(@todate As datetime)  Group By p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Number of Patients on Care and Treatment',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B8',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B9',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B10',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B11',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative Number of Transfer In Patients on Care and Treatment
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeTransfersIn')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeTransfersIn'


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
(   N'CT_CumulativeTransfersIn',       -- qryName - nvarchar(50)
    N'Select p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'') AgeGroup,    Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p  Where p.RegistrationAtCCC <= Cast(@todate As datetime) And    p.PatientSource In (''Transfer In'', ''Other facility'')  Group By p.Gender,    dbo.fn_GetAgeGroup(p.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Number of Transfer In Patients on Care and Treatment',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B13',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B14',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B15',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B16',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Unique Patients That Received HIV Care During The Last 3 Months
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_ReceviedCareLast3Months')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_ReceviedCareLast3Months'


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
(   N'CT_ReceviedCareLast3Months',       -- qryName - nvarchar(50)
    N'Select a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') ageGroup, Count(Distinct a.PatientPK) Total From tmp_PatientMaster a Inner Join tmp_ClinicalEncounters b On a.PatientPK = b.PatientPK Where b.VisitDate Between DATEADD(mm, -3, Cast(@todate As datetime)) And Cast(@todate As datetime) And b.Service = ''ART'' And a.RegistrationAtCCC <= Cast(@todate As datetime) Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Unique Patients That Received HIV Care During The Last 3 Months',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B19',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B20',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B21',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B22',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative Number of Patients Started on ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeART'


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
(   N'CT_CumulativeART',       -- qryName - nvarchar(50)
    N'Select e.Gender,    dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'') AgeGroup,    Count(Distinct e.PatientPK) Total  From tmp_ARTPatients e    Left Join (Select Distinct e.PatientPK    From tmp_ARTPatients e    Where e.StartARTDate <= Cast(@todate As datetime) And e.StartARTDate <      e.StartARTAtThisFacility And e.RegistrationDate <= Cast(@todate As datetime)      And e.PatientSource In (''Transfer In'', ''Other facility'')) TI      On e.PatientPK = TI.PatientPK  Where e.StartARTDate <= Cast(@todate As datetime) And e.RegistrationDate <=    Cast(@todate As datetime) And TI.PatientPK Is Null  Group By e.Gender,    dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Number of Patients Started on ART',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B24',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B25',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B26',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B27',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative Number of Patients Transferring in on ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeARTTransfersIN')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeARTTransfersIN'


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
(   N'CT_CumulativeARTTransfersIN',       -- qryName - nvarchar(50)
    N'Select e.Gender,    dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'') AgeGroup,    Count(Distinct e.PatientPK) Total  From tmp_ARTPatients e  Where e.StartARTDate <= Cast(@todate As datetime) And e.StartARTDate <    e.StartARTAtThisFacility And e.RegistrationDate <= Cast(@todate As datetime)    And e.PatientSource In (''Transfer In'', ''Other facility'')  Group By e.Gender,    dbo.fn_GetAgeGroup(e.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Number of Patients Transferring in on ART',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B29',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B30',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B31',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B32',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Current on ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CurrentOnART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CurrentOnART'


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
(   N'CT_CurrentOnART',       -- qryName - nvarchar(50)
    N'Select a.Gender,    dbo.fn_GetAgeGroup(a.AgeARTStart, ''COARSE'') AgeGroup,    Count(Distinct a.PatientPK) Total  From tmp_ARTPatients a  Where a.RegistrationDate <= Cast(@todate As datetime)  AND a.StartARTDate <= Cast(@todate As datetime) AND dbo.fn_ActiveCCC(Cast(@todate As datetime), a.PatientPK) = 1 Group By a.Gender, dbo.fn_GetAgeGroup(a.AgeARTStart, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Current Number of Patients Active on ART',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B34',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B35',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B36',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B37',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative ART Terminations
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeARTTerminations')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeARTTerminations'


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
(   N'CT_CumulativeARTTerminations',       -- qryName - nvarchar(50)
    N'Select aa.[Last Status] exitReason,    Count(Distinct aa.PatientPK) Total  From (Select a.PatientPK,      a.ExitReason [Last Status]    From tmp_ARTPatients a    Where a.ExitReason Is Not Null And Cast(a.LastARTDate As datetime) <=      Cast(@ToDate As datetime) And a.ExitDate <= Cast(@Todate As datetime)    Union    Select b.PatientPK,      ''Lost'' [Last Status]    From tmp_ARTPatients b    Where DateDiff(dd, b.ExpectedReturn, Cast(@todate As datetime)) > 90      And b.ExitReason Is Null) aa  Group By aa.[Last Status]',       -- qryDefinition - nvarchar(max)
    N'Cumulative ART Terminations',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B39',       
    @QueryID,         
    N'StoppedTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B40',       
    @QueryID,         
    N'TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B41',       
    @QueryID,         
    N'DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B42',       
    @QueryID,         
    N'LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Patients Seen in the Month
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_PatientsSeen')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_PatientsSeen'


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
(   N'CT_PatientsSeen',       -- qryName - nvarchar(50)
    N'Select Count(Distinct p.PatientPK) Total  From tmp_PatientMaster p    Inner Join tmp_ClinicalEncounters a On p.PatientPK = a.PatientPK  Where a.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate    As datetime) And a.Service = ''ART'' And p.RegistrationAtCCC <= Cast(@todate As    datetime)',       -- qryDefinition - nvarchar(max)
    N'Unique Patients Seen in the Month',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B45',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Patient Visits in the Month
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_PatientVisits')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_PatientVisits'


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
(   N'CT_PatientVisits',       -- qryName - nvarchar(50)
    N'Select Count(distinctVisits.PatientPK) Total  From (Select Distinct p.PatientPK,      a.VisitDate    From tmp_PatientMaster p      Inner Join tmp_ClinicalEncounters a On p.PatientPK = a.PatientPK    Where a.VisitDate Between Cast(@fromdate As datetime) And Cast(@todate As      datetime) And a.Service = ''ART'' And p.RegistrationAtCCC <= Cast(@todate As      datetime)) distinctVisits',       -- qryDefinition - nvarchar(max)
    N'Patient Visits in the Month',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B46',       
    @QueryID,         
    N'Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)



--Cumulative Non ART
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeNonART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeNonART'


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
(   N'CT_CumulativeNonART',       -- qryName - nvarchar(50)
    N'Select m.Gender,    dbo.fn_GetAgeGroup(m.AgeLastVisit, ''COARSE'') ageGroup,    Count(Distinct m.PatientPK) Total  From tmp_PatientMaster m    Left Join (Select a.PatientPK,      a.StartARTDate    From tmp_ARTPatients a) e On m.PatientPK = e.PatientPK  Where m.RegistrationAtCCC Is Not Null And ((e.PatientPK Is Null) Or      (e.StartARTDate > Cast(@todate As datetime))) And    (m.PatientSource Not In (''Transfer In'', ''Other facility'') Or      m.PatientSource Is Null)  Group By m.Gender,    dbo.fn_GetAgeGroup(m.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Non ART Patients',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B49',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B50',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B51',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B52',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative Non ART Transfers In
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeNonARTTransfersIn')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeNonARTTransfersIn'


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
(   N'CT_CumulativeNonARTTransfersIn',       -- qryName - nvarchar(50)
    N'Select m.Gender,    dbo.fn_GetAgeGroup(m.AgeEnrollment, ''COARSE'') ageGroup,    Count(Distinct m.PatientPK) Total  From tmp_PatientMaster m    Left Join (Select a.PatientPK,      a.StartARTDate    From tmp_ARTPatients a) e On m.PatientPK = e.PatientPK  Where m.RegistrationAtCCC Is Not Null And ((e.PatientPK Is Null) Or      (e.StartARTDate > Cast(@todate As datetime))) And    m.PatientSource In (''Transfer In'', ''Other facility'')  Group By m.Gender,    dbo.fn_GetAgeGroup(m.AgeEnrollment, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Cumulative Non ART Transfer In Patients',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B54',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B55',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B56',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B57',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Current Pre ART Patients
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CurrentPreART')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CurrentPreART'


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
(   N'CT_CurrentPreART',       -- qryName - nvarchar(50)
    N'Select a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup, COUNT(DISTINCT a.PatientPK) Total FROM tmp_PatientMaster a LEFT JOIN tmp_ARTPatients b ON a.PatientPK = b.PatientPK WHERE (b.PatientPK IS NULL OR b.StartARTDate > CAST(@todate as date)) AND a.RegistrationAtCCC <= CAST(@todate as date) AND dbo.fn_ActiveCCC(cast(@todate as date), a.PatientPK) = 1 GROUP BY a.Gender, dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'Current Number of Pre-ART Patients',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B59',       
    @QueryID,         
    N'Male<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B60',       
    @QueryID,         
    N'Male15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B61',       
    @QueryID,         
    N'Female<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B62',       
    @QueryID,         
    N'Female15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Cumulative Terminations
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeTerminations')
DELETE FROM dbo.aa_Queries WHERE qryName = 'CT_CumulativeTerminations'


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
(   N'CT_CumulativeTerminations',       -- qryName - nvarchar(50)
    N'Select aa.ExitReason, Count(Distinct aa.PatientPK) Total From (Select c.PatientPK, c.ExitReason From tmp_LastStatus c Inner Join tmp_PatientMaster m On c.PatientPK = m.PatientPK    Where m.RegistrationAtCCC <= Cast(@todate As datetime) And c.ExitDate <= Cast(@todate As datetime) Union Select b.PatientPK, ''Lost'' exitReason From tmp_ARTPatients b WHERE dbo.fn_ActiveCCC(cast(@todate as date), b.PatientPK) = 0 And b.ExitReason Is Null) aa  Group By aa.ExitReason',       -- qryDefinition - nvarchar(max)
    N'Cumulative Number of Terminations',       -- qryDescription - nvarchar(200)
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
(   N'CT_Report',       -- sbCategory - nvarchar(50)
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
(   N'B64',       
    @QueryID,         
    N'StoppedTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B65',       
    @QueryID,         
    N'TransferTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B66',       
    @QueryID,         
    N'DeathTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(N'B67',       
    @QueryID,         
    N'LostTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
,
(N'B68',       
    @QueryID,         
    N'HIV NegativeTotal',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)