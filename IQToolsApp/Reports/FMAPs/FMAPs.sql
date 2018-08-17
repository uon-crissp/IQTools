Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'FMAPs_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'FMAPs_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'FMAPs_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('FMAPs_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Pharmacy Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Pharmacy Reports',4)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Pharmacy Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'FMAPs_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'FMAPs_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'FMAPs_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'FMAPs_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('FMAPs_Report'
,'Facility Monthly ARV Patient Summary (F-MAPS) Report'
,'Facility Monthly ARV Patient Summary (F-MAPS) Report'
, @CatID
, 'FMAPs_Template.xlsx'
, 'MAPS'
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
(   N'FMAPs_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_Header'


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
(   N'FMAPs_Report_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @fromdate, 106) StartDate, CONVERT(varchar(20), @todate, 106) EndDate, SiteCode = (Select Top 1 SiteCode FROM tmp_PatientMaster), FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'FMAPs_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'FMAPs_Report',       -- sbCategory - nvarchar(50)
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
    N'FacilityName',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G3',       
    @QueryID,         
    N'SiteCode',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C4',       
    @QueryID,         
    N'StartDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'C5',       
    @QueryID,         
    N'EndDate',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--ART, PMTCT & PEP
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_ARTPMTCTPEP')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_ARTPMTCTPEP'


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
(   N'FMAPs_Report_ARTPMTCTPEP',       -- qryName - nvarchar(50)
    N'With Codes AS (
	SELECT  
	1 ID, ''PMTCT Regimens for Pregnant Women'' RegimenCode
	UNION SELECT 2 ID, ''PM1''
	UNION SELECT 3 ID, ''PM2''
	UNION SELECT 4 ID, ''PM3''
	UNION SELECT 5 ID, ''PM4''
	UNION SELECT 6 ID, ''PM5''
	UNION SELECT 7 ID, ''PM6''
	UNION SELECT 8 ID, ''PM7''
	UNION SELECT 9 ID, ''PM9''
	UNION SELECT 10 ID, ''PM10''
	UNION SELECT 11 ID, ''PM11''
	UNION SELECT 12 ID, ''PM1X''
	UNION SELECT 13 ID,  NULL
	UNION SELECT 14 ID, ''PMTCT Regimens for Infants''
	UNION SELECT 15 ID, ''PC1''
	UNION SELECT 16 ID, ''PC2''
	UNION SELECT 17 ID, ''PC4''
	UNION SELECT 18 ID, ''PC5''
	UNION SELECT 19 ID, ''PC6''
	UNION SELECT 20 ID, ''PC1X''
	UNION SELECT 21 ID,  NULL
	UNION SELECT 22 ID, ''ADULT ART First-Line Regimens''
	UNION SELECT 23 ID, ''AF1A''
	UNION SELECT 24 ID, ''AF1B''
	UNION SELECT 25 ID, ''AF2A''
	UNION SELECT 26 ID, ''AF2B''
	UNION SELECT 27 ID, ''AF3A''
	UNION SELECT 28 ID, ''AF3B''
	UNION SELECT 29 ID, ''AF4A''
	UNION SELECT 30 ID, ''AF4B''
	UNION SELECT 31 ID, ''AF5X''
	UNION SELECT 32 ID,  NULL
	UNION SELECT 33 ID, ''ADULT ART Second-Line Regimens''
	UNION SELECT 34 ID, ''AS1A''
	UNION SELECT 35 ID, ''AS1B''
	UNION SELECT 36 ID, ''AS2A''
	UNION SELECT 37 ID, ''AS2C''
	UNION SELECT 38 ID, ''AS5A''
	UNION SELECT 39 ID, ''AS5B''
	UNION SELECT 40 ID, ''AS6X''
	UNION SELECT 41 ID,  NULL
	UNION SELECT 42 ID, ''ADULT ART Third-Line Regimens''
	UNION SELECT 43 ID, ''AT1A''
	UNION SELECT 44 ID, ''AT1B''
	UNION SELECT 45 ID, ''AT1C''
	UNION SELECT 46 ID, ''AT2A''
	UNION SELECT 47 ID, ''AT2X''
	UNION SELECT 48 ID,  NULL
	UNION SELECT 49 ID,  ''PAEDIATRIC ART First-Line Regimens''
	UNION SELECT 50 ID, ''CF1A''
	UNION SELECT 51 ID, ''CF1B''
	UNION SELECT 52 ID, ''CF1C''
	UNION SELECT 53 ID, ''CF1D''
	UNION SELECT 54 ID, ''CF2A''
	UNION SELECT 55 ID, ''CF2B''
	UNION SELECT 56 ID, ''CF2C''
	UNION SELECT 57 ID, ''CF2D''
	UNION SELECT 58 ID, ''CF2E''
	UNION SELECT 59 ID, ''CF3A''
	UNION SELECT 60 ID, ''CF3B''
	UNION SELECT 61 ID, ''CF4A''
	UNION SELECT 62 ID, ''CF4B''
	UNION SELECT 63 ID, ''CF4C''
	UNION SELECT 64 ID, ''CF4D''
	UNION SELECT 65 ID, ''CF5X''
	UNION SELECT 66 ID,  NULL
	UNION SELECT 67 ID,  ''PAEDIATRIC ART Second-Line Regimens''
	UNION SELECT 68 ID, ''CS1A''
	UNION SELECT 69 ID, ''CS1B''
	UNION SELECT 70 ID, ''CS2A''
	UNION SELECT 71 ID, ''CS2C''
	UNION SELECT 72 ID, ''CS4X''
	UNION SELECT 73 ID,  NULL
	UNION SELECT 74 ID, ''PAEDIATRIC Third-Line ART Regimens''
	UNION SELECT 75 ID, ''CT1A''
	UNION SELECT 76 ID, ''CT1B''
	UNION SELECT 77 ID, ''CT1C''
	UNION SELECT 78 ID, ''CT2A''
	UNION SELECT 79 ID, ''CT3X''
	UNION SELECT 80 ID,  NULL
	UNION SELECT 81 ID, ''Post Exposure Prophylaxis (PEP) for Adults''
	UNION SELECT 82 ID, ''PA1B''
	UNION SELECT 83 ID, ''PA1C''
	UNION SELECT 84 ID, ''PA3B''
	UNION SELECT 85 ID, ''PA3C''
	UNION SELECT 86 ID, ''PA4X''
	UNION SELECT 87 ID,  NULL
	UNION SELECT 88 ID,  ''Post Exposure Prophylaxis (PEP) for Children''
	UNION SELECT 89 ID, ''PC1A''
	UNION SELECT 90 ID, ''PC3A''
	UNION SELECT 91 ID, ''PC4X'')

	, ActiveART AS 
	(Select Distinct a.PatientPK
	From tmp_ARTPatients a 
	Where 
	a.StartARTDate <= CAST(@todate as datetime)
	AND dbo.fn_ActiveCCC(@todate, a.PatientPK) = 1)

	,  CodedDispense AS (
	Select a.ptn_pk, a.OrderedByDate, c.RegimenCode
	FROM ord_patientpharmacyorder a inner join dtl_regimenmap b on a.ptn_pharmacy_pk = b.OrderID
	inner join mst_Regimen c on b.RegimenId = c.RegimenID)

	, LastCodedDispense AS (
	Select a.Ptn_pk PatientPK, MAX(a.RegimenCode) RegimenCode, MAX(LastDispense) LastDispense FROM CodedDispense a INNER JOIN
	(Select Ptn_pk, MAX(OrderedByDate) LastDispense 
	FROM CodedDispense GROUP BY Ptn_pk) b ON a.Ptn_pk = b.Ptn_pk
	AND a.OrderedByDate = b.LastDispense
	GROUP BY a.Ptn_pk)

	, ActiveARTWithCode AS (
	Select a.PatientPK, b.RegimenCode FROM ActiveART a LEFT JOIN LastCodedDispense b ON a.PatientPK = b.PatientPK)

	, ARTRegimens AS (
	Select a.ID, a.RegimenCode, COUNT(Distinct b.PatientPK) Total FROM 
	Codes a LEFT JOIN ActiveARTWithCode b ON a.RegimenCode = b.RegimenCode
	WHERE a.ID Between 23 AND 77 OR a.ID BETWEEN 2 AND 12
	GROUP BY a.ID, a.RegimenCode)

	, HEIRegimens AS (
	Select c.ID, c.RegimenCode, COUNT(DISTINCT a.PatientPK) Total 
	FROM Codes c LEFT JOIN LastCodedDispense a ON c.RegimenCode = a.RegimenCode 
	AND LastDispense >= DATEADD(mm, -3, CAST(@todate as date)) 
	LEFT JOIN tmp_HEI b ON a.PatientPK = b.PatientPK
	Where c.ID Between 15 and 20
	GROUP BY c.ID, c.RegimenCode)

	, PEPRegimens AS 
	(Select c.ID, c.RegimenCode, COUNT(Distinct a.PatientPK) Total 
	FROM Codes c LEFT JOIN LastCodedDispense a ON c.RegimenCode = a.RegimenCode 
	AND LastDispense >= DATEADD(mm, -1, CAST(@todate as date)) 
	Where c.ID Between 80 and 89
	GROUP BY c.ID, c.RegimenCode)

	Select a.ID, b.Total FROM Codes a LEFT JOIN (
	SELECT ID, Total, RegimenCode FROM ARTRegimens
	UNION
	SELECT ID, Total, RegimenCode FROM HEIRegimens
	UNION
	Select ID, Total, RegimenCode FROM PEPRegimens
	) b ON a.ID = b.ID
	ORDER BY a.ID',       -- qryDefinition - nvarchar(max)
    N'FMAPs_Report_ARTPMTCTPEP',       -- qryDescription - nvarchar(200)
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
(   N'FMAPs_Report',       -- sbCategory - nvarchar(50)
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
(   N'F9',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--FMAPs_Report_CTX Dapsone Prophylaxis
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_CTXDapsoneProphylaxis')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_CTXDapsoneProphylaxis'


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
(   N'FMAPs_Report_CTXDapsoneProphylaxis',       -- qryName - nvarchar(50)
    N'Select ''CTX'' Drug,  dbo.fn_GetAgeGroup(b.AgeLastVisit, ''COARSE'') AgeGroup
	,  Count(Distinct a.PatientPK) Total  From tmp_Pharmacy a    
	Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK  
	Where a.Drug LIKE ''%trimoxazole%'' 
	And a.DispenseDate <= Cast(@todate As datetime)    
	AND dbo.fn_ActiveCCC(@todate, b.PatientPK) = 1
	Group By     
	dbo.fn_GetAgeGroup(b.AgeLastVisit, ''COARSE'')
	UNION
	Select ''Dapsone'' Drug,  dbo.fn_GetAgeGroup(b.AgeLastVisit, ''COARSE'') AgeGroup
	,  Count(Distinct a.PatientPK) Total  From tmp_Pharmacy a    
	Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK  
	LEFT JOIN (Select Distinct a.PatientPK From tmp_Pharmacy a    
	Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK  
	Where a.Drug LIKE ''%trimoxazole%''
	And a.DispenseDate <= Cast(@todate As datetime)    
	AND dbo.fn_ActiveCCC(@todate, b.PatientPK) = 1) c ON a.PatientPK = c.PatientPK
	Where a.Drug LIKE ''%dapsone%'' 
	And a.DispenseDate <= Cast(@todate As datetime)    
	AND dbo.fn_ActiveCCC(@todate, b.PatientPK) = 1
	AND c.PatientPK IS NULL
	Group By     
	dbo.fn_GetAgeGroup(b.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'FMAPs_Report_CTXDapsoneProphylaxis',       -- qryDescription - nvarchar(200)
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
(   N'FMAPs_Report',       -- sbCategory - nvarchar(50)
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
(   N'G103',       
    @QueryID,         
    N'CTX15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G104',       
    @QueryID,         
    N'CTX<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G105',       
    @QueryID,         
    N'Dapsone15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G106',       
    @QueryID,         
    N'Dapsone<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--FMAPs On IPT
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_OnIPT')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_OnIPT'


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
(   N'FMAPs_Report_OnIPT',       -- qryName - nvarchar(50)
    N'Select   dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'') AgeGroup  
	,COUNT(Distinct a.PatientPK) Total  
	FROM tmp_PatientMaster a  INNER JOIN   
		(Select a.PatientPK FROM	
			(Select a.PatientPK,  Min(Coalesce(a.DispenseDate, b.visitdate)) IPTStartDate  
			From tmp_Pharmacy a  Inner Join ord_visit b On a.VisitID = b.visit_id  inner join tmp_PatientMaster c ON a.PatientPK = c.PatientPK  
			Where a.Drug LIKE ''Isoniazid%''  
			Group By a.PatientPK) a  
		inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
		Where a.IPTStartDate BETWEEN DATEADD(mm, -6, CAST(@Todate as datetime)) AND CAST(@Todate as datetime))  b 
	ON a.PatientPK = b.PatientPK  
	Where dbo.fn_ActiveCCC(@Todate, a.PatientPK) = 1  
	GROUP BY dbo.fn_GetAgeGroup(a.AgeLastVisit, ''COARSE'')',       -- qryDefinition - nvarchar(max)
    N'FMAPs_Report_OnIPT',       -- qryDescription - nvarchar(200)
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
(   N'FMAPs_Report',       -- sbCategory - nvarchar(50)
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
(   N'G109',       
    @QueryID,         
    N'15+Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'G110',       
    @QueryID,         
    N'<15Total',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Coded Regimens Line List

IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_CodedRegimensLineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FMAPs_Report_CodedRegimensLineList'


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
(   N'FMAPs_Report_CodedRegimensLineList',       -- qryName - nvarchar(50)
    N'With Codes AS (
	SELECT  
	1 ID, ''PMTCT Regimens for Pregnant Women'' RegimenCode
	UNION SELECT 2 ID, ''PM1''
	UNION SELECT 3 ID, ''PM2''
	UNION SELECT 4 ID, ''PM3''
	UNION SELECT 5 ID, ''PM4''
	UNION SELECT 6 ID, ''PM5''
	UNION SELECT 7 ID, ''PM6''
	UNION SELECT 8 ID, ''PM7''
	UNION SELECT 9 ID, ''PM9''
	UNION SELECT 10 ID, ''PM10''
	UNION SELECT 11 ID, ''PM11''
	UNION SELECT 12 ID, ''PM1X''
	UNION SELECT 13 ID,  NULL
	UNION SELECT 14 ID, ''PMTCT Regimens for Infants''
	UNION SELECT 15 ID, ''PC1''
	UNION SELECT 16 ID, ''PC2''
	UNION SELECT 17 ID, ''PC4''
	UNION SELECT 18 ID, ''PC5''
	UNION SELECT 19 ID, ''PC6''
	UNION SELECT 20 ID, ''PC1X''
	UNION SELECT 21 ID,  NULL
	UNION SELECT 22 ID, ''ADULT ART First-Line Regimens''
	UNION SELECT 23 ID, ''AF1A''
	UNION SELECT 24 ID, ''AF1B''
	UNION SELECT 25 ID, ''AF2A''
	UNION SELECT 26 ID, ''AF2B''
	UNION SELECT 27 ID, ''AF3A''
	UNION SELECT 28 ID, ''AF3B''
	UNION SELECT 29 ID, ''AF4A''
	UNION SELECT 30 ID, ''AF4B''
	UNION SELECT 31 ID, ''AF5X''
	UNION SELECT 32 ID,  NULL
	UNION SELECT 33 ID, ''ADULT ART Second-Line Regimens''
	UNION SELECT 34 ID, ''AS1A''
	UNION SELECT 35 ID, ''AS1B''
	UNION SELECT 36 ID, ''AS2A''
	UNION SELECT 37 ID, ''AS2C''
	UNION SELECT 38 ID, ''AS5A''
	UNION SELECT 39 ID, ''AS5B''
	UNION SELECT 40 ID, ''AS6X''
	UNION SELECT 41 ID,  NULL
	UNION SELECT 42 ID, ''ADULT ART Third-Line Regimens''
	UNION SELECT 43 ID, ''AT1A''
	UNION SELECT 44 ID, ''AT1B''
	UNION SELECT 45 ID, ''AT1C''
	UNION SELECT 46 ID, ''AT2A''
	UNION SELECT 47 ID, ''AT2X''
	UNION SELECT 48 ID,  NULL
	UNION SELECT 49 ID,  ''PAEDIATRIC ART First-Line Regimens''
	UNION SELECT 50 ID, ''CF1A''
	UNION SELECT 51 ID, ''CF1B''
	UNION SELECT 52 ID, ''CF1C''
	UNION SELECT 53 ID, ''CF1D''
	UNION SELECT 54 ID, ''CF2A''
	UNION SELECT 55 ID, ''CF2B''
	UNION SELECT 56 ID, ''CF2C''
	UNION SELECT 57 ID, ''CF2D''
	UNION SELECT 58 ID, ''CF2E''
	UNION SELECT 59 ID, ''CF3A''
	UNION SELECT 60 ID, ''CF3B''
	UNION SELECT 61 ID, ''CF4A''
	UNION SELECT 62 ID, ''CF4B''
	UNION SELECT 63 ID, ''CF4C''
	UNION SELECT 64 ID, ''CF4D''
	UNION SELECT 65 ID, ''CF5X''
	UNION SELECT 66 ID,  NULL
	UNION SELECT 67 ID,  ''PAEDIATRIC ART Second-Line Regimens''
	UNION SELECT 68 ID, ''CS1A''
	UNION SELECT 69 ID, ''CS1B''
	UNION SELECT 70 ID, ''CS2A''
	UNION SELECT 71 ID, ''CS2C''
	UNION SELECT 72 ID, ''CS4X''
	UNION SELECT 73 ID,  NULL
	UNION SELECT 74 ID, ''PAEDIATRIC Third-Line ART Regimens''
	UNION SELECT 75 ID, ''CT1A''
	UNION SELECT 76 ID, ''CT1B''
	UNION SELECT 77 ID, ''CT1C''
	UNION SELECT 78 ID, ''CT2A''
	UNION SELECT 79 ID, ''CT3X''
	UNION SELECT 80 ID,  NULL
	UNION SELECT 81 ID, ''Post Exposure Prophylaxis (PEP) for Adults''
	UNION SELECT 82 ID, ''PA1B''
	UNION SELECT 83 ID, ''PA1C''
	UNION SELECT 84 ID, ''PA3B''
	UNION SELECT 85 ID, ''PA3C''
	UNION SELECT 86 ID, ''PA4X''
	UNION SELECT 87 ID,  NULL
	UNION SELECT 88 ID,  ''Post Exposure Prophylaxis (PEP) for Children''
	UNION SELECT 89 ID, ''PC1A''
	UNION SELECT 90 ID, ''PC3A''
	UNION SELECT 91 ID, ''PC4X'')


, ActiveART AS 
(Select Distinct a.PatientPK
From tmp_ARTPatients a 
Where 
a.StartARTDate <= CAST(@todate as datetime)
AND dbo.fn_ActiveCCC(@todate, a.PatientPK) = 1)

,  CodedDispense AS (
Select a.ptn_pk, a.OrderedByDate, c.RegimenCode
FROM ord_patientpharmacyorder a inner join dtl_regimenmap b on a.ptn_pharmacy_pk = b.OrderID
inner join mst_Regimen c on b.RegimenId = c.RegimenID)

, LastCodedDispense AS (
Select a.Ptn_pk PatientPK, MAX(a.RegimenCode) RegimenCode, MAX(LastDispense) LastDispense FROM CodedDispense a INNER JOIN
(Select Ptn_pk, MAX(OrderedByDate) LastDispense 
FROM CodedDispense GROUP BY Ptn_pk) b ON a.Ptn_pk = b.Ptn_pk
AND a.OrderedByDate = b.LastDispense
GROUP BY a.Ptn_pk)


Select c.PatientID
, c.Gender
, c.AgeLastVisit
, b.RegimenCode
, CAST(b.LastDispense as DATE)  LastDispenseDate
FROM ActiveART a LEFT JOIN LastCodedDispense b ON a.PatientPK = b.PatientPK
LEFT JOIN tmp_ARTPatients c ON a.PatientPK = c.PatientPK 
LEFT JOIN Codes d ON b.RegimenCode = d.RegimenCode',       -- qryDefinition - nvarchar(max)
    N'FMAPs_Report Line List of All Active ART Patients with Regimen Code at Last Dispense',       -- qryDescription - nvarchar(200)
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
(@ReportID, @QueryID,'Active ART', GETDATE())