IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetOIDrugsHeaders]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetOIDrugsHeaders]
GO

CREATE PROCEDURE [dbo].[pr_GetOIDrugsHeaders]
(
  @Fromdate DATETIME, @ToDate DATETIME 
)

AS

BEGIN
	DECLARE @ColumnHeaders VARCHAR(8000)
	DECLARE @colNum INT
	SET @ColumnHeaders = ''
	SET @colNum = 1
	
	IF OBJECT_ID('tempdb..#OIHeaders') IS NOT NULL
		DROP TABLE #OIHeaders

	CREATE TABLE #OIHeaders(id INT IDENTITY, drugname varchar(400))
	
	INSERT INTO #OIHeaders (drugname )
	 
	SELECT DISTINCT DrugName FROM VW_PatientPharmacy a inner join tmp_PatientMaster b 
		on a.ptn_pk = b.PatientPK 
		left join tmp_HEI c ON a.Ptn_Pk = c.PatientPK
		WHERE (b.registrationatccc <= CAST(@todate AS DATETIME) OR c.RegistrationAtPMTCT <= CAST(@todate AS DATETIME))
		AND drugtype <> 'ARV Medication' 
		AND DispensedByDate BETWEEN CAST(@Fromdate AS DATETIME) AND CAST(@todate AS DATETIME)
	ORDER BY DrugName
	
	SELECT @colNum = @colNum+1, @ColumnHeaders = @ColumnHeaders + ', ''' + drugname + ''' as A'+CAST(@colNum AS VARCHAR) 
	FROM #OIHeaders ORDER BY drugname
		
	SET @ColumnHeaders = STUFF(@ColumnHeaders, 1, 2, '')
	
	EXEC('SELECT ''PatientID'' as A0, ''Month/Year'' as A1, '+@ColumnHeaders)
END

GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetOIDrugTotals]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetOIDrugTotals]
GO

CREATE PROC [dbo].[pr_GetOIDrugTotals]
(
  @Fromdate DATETIME, @ToDate DATETIME 
)

AS

BEGIN
	DECLARE @OIDrugs TABLE(id INT IDENTITY, Drug_pk INT, drugName VARCHAR(MAX))
	DECLARE @ColumnNames VARCHAR(MAX)
	DECLARE @ColumnNames2 VARCHAR(MAX)
	DECLARE @SumColumnNames VARCHAR(MAX)
	DECLARE @PriceColumnNames VARCHAR(MAX)
	DECLARE @CostColumnNames VARCHAR(MAX)
	DECLARE @VSQl VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#OIDispensing') IS NOT NULL
		DROP TABLE #OIDispensing

	IF EXISTS(SELECT * FROM sysobjects WHERE name='zzz_OIDispensing' AND type='U')
		DROP TABLE zzz_OIDispensing

	CREATE TABLE #OIDispensing(PatientID VARCHAR(200), [Month/Year] VARCHAR(20), drugname VARCHAR(500), DispensedQuantity DECIMAL)

	
	INSERT INTO @OIDrugs (drugName )
		SELECT DISTINCT DrugName FROM VW_PatientPharmacy a inner join tmp_PatientMaster b 
		on a.ptn_pk = b.PatientPK 
		left join tmp_HEI c ON a.Ptn_Pk = c.PatientPK
		WHERE (b.registrationatccc <= CAST(@todate AS DATETIME) OR c.RegistrationAtPMTCT <= CAST(@todate AS DATETIME))
		AND drugtype <> 'ARV Medication' 
		AND DispensedByDate BETWEEN CAST(@Fromdate AS DATETIME) AND CAST(@todate AS DATETIME)
	--ORDER BY DrugName

	INSERT INTO #OIDispensing (PatientID, [Month/Year], drugname, DispensedQuantity)
	SELECT a.PatientID 
	, CAST(MONTH(b.DispensedByDate) AS VARCHAR(2)) +'/'+ CAST(YEAR(b.DispensedByDate) AS VARCHAR(4))
	, b.drugname
	, SUM(b.DispensedQuantity) DispensedQuantity
	FROM dbo.tmp_patientMaster a
	INNER JOIN dbo.VW_PatientPharmacy b ON a.patientpk = b.ptn_pk
	inner join @OIDrugs c on b.DrugName collate database_default = c.DrugName collate database_default
	left join tmp_HEI d ON a.PatientPK = d.PatientPK
		WHERE (a.registrationatccc <= CAST(@todate AS DATETIME) OR d.RegistrationAtPMTCT <= CAST(@todate AS DATETIME))
		AND b.DispensedByDate BETWEEN CAST(@Fromdate AS DATETIME) AND CAST(@todate AS DATETIME)
	--WHERE a.RegistrationAtCCC <= CAST(@todate AS DATETIME)
	GROUP BY a.PatientID 
	, CAST(MONTH(b.DispensedByDate) AS VARCHAR(2)) +'/'+ CAST(YEAR(b.DispensedByDate) AS VARCHAR(4))
	, b.drugname

	
	set @ColumnNames = ''
	select @ColumnNames = @ColumnNames + ', [' + drugname + ']' from @OIDrugs ORDER BY drugName
	SET @ColumnNames = STUFF(@ColumnNames, 1, 2, '')
	Print (@ColumnNames)
	set @ColumnNames2 = ''
	select @ColumnNames2 = @ColumnNames2 + ', cast([' + drugname + '] as varchar)' from @OIDrugs ORDER BY drugName
	SET @ColumnNames2 = STUFF(@ColumnNames2, 1, 2, '')

	set @SumColumnNames = ''
	select @SumColumnNames = @SumColumnNames+', cast(SUM(isnull(['+drugname+'], 0)) as INT)' from @OIDrugs ORDER BY drugName
	SET @SumColumnNames = STUFF(@SumColumnNames, 1, 2, '')

	set @PriceColumnNames = ''
	select @PriceColumnNames = @PriceColumnNames + ', null' from @OIDrugs ORDER BY drugName
	SET @PriceColumnNames = STUFF(@PriceColumnNames, 1, 2, '')

	
	EXEC('SELECT * into zzz_OIDispensing FROM #OIDispensing 
	PIVOT (SUM(DispensedQuantity) For drugname IN ('+ @ColumnNames +')) AS Total')

	EXEC('
	SELECT '+@SumColumnNames+' FROM zzz_OIDispensing
	--union all
	--SELECT ''UNIT COST'', null, '+@PriceColumnNames+'
	--union all
	--SELECT ''TOTAL COST'', null, '+@CostColumnNames+'
	--union all
	--SELECT PatientID, [Month/Year], '+@ColumnNames2+' FROM zzz_OIDispensing
	')
	
	IF EXISTS(SELECT * FROM sysobjects WHERE name='zzz_OIDispensing' AND type='U')
		DROP TABLE zzz_OIDispensing
END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetOIDrugsSummary]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetOIDrugsSummary]
GO

CREATE PROCEDURE [dbo].[pr_GetOIDrugsSummary]
(
  @Fromdate DATETIME, @ToDate DATETIME 
)

AS

BEGIN
	DECLARE @OIDrugs TABLE(id INT IDENTITY, Drug_pk INT, drugName VARCHAR(MAX))
	DECLARE @ColumnNames VARCHAR(MAX)
	DECLARE @ColumnNames2 VARCHAR(MAX)
	DECLARE @SumColumnNames VARCHAR(MAX)
	DECLARE @VSQl VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#OIDispensing') IS NOT NULL
		DROP TABLE #OIDispensing

	IF EXISTS(SELECT * FROM sysobjects WHERE name='zzz_OIDispensing' AND type='U')
		DROP TABLE zzz_OIDispensing

	CREATE TABLE #OIDispensing(PatientID VARCHAR(200), [Month/Year] VARCHAR(20), drugname VARCHAR(500), DispensedQuantity DECIMAL)

	
	INSERT INTO @OIDrugs (drugName )
	SELECT DISTINCT DrugName FROM VW_PatientPharmacy a inner join tmp_PatientMaster b 
		on a.ptn_pk = b.PatientPK 
		left join tmp_HEI c ON a.Ptn_Pk = c.PatientPK
		WHERE (b.registrationatccc <= CAST(@todate AS DATETIME) OR c.RegistrationAtPMTCT <= CAST(@todate AS DATETIME))
		AND drugtype <> 'ARV Medication' 
		AND DispensedByDate BETWEEN CAST(@Fromdate AS DATETIME) AND CAST(@todate AS DATETIME)

	INSERT INTO #OIDispensing (PatientID, [Month/Year], drugname, DispensedQuantity)
	SELECT a.PatientID 
	, CAST(MONTH(b.DispensedByDate) AS VARCHAR(2)) +'/'+ CAST(YEAR(b.DispensedByDate) AS VARCHAR(4))
	, b.drugname
	, SUM(b.DispensedQuantity) DispensedQuantity
	FROM dbo.tmp_patientMaster a
	INNER JOIN dbo.VW_PatientPharmacy b ON a.patientpk = b.ptn_pk
	inner join @OIDrugs c on b.DrugName collate database_default = c.DrugName collate database_default
	left join tmp_HEI d ON a.PatientPK = d.PatientPK
		WHERE (a.registrationatccc <= CAST(@todate AS DATETIME) OR d.RegistrationAtPMTCT <= CAST(@todate AS DATETIME))
		AND b.DispensedByDate BETWEEN CAST(@Fromdate AS DATETIME) AND CAST(@todate AS DATETIME)
	GROUP BY a.PatientID 
	, CAST(MONTH(b.DispensedByDate) AS VARCHAR(2)) +'/'+ CAST(YEAR(b.DispensedByDate) AS VARCHAR(4))
	, b.drugname

	
	set @ColumnNames = ''
	select @ColumnNames = @ColumnNames + ', [' + drugname + ']' from @OIDrugs ORDER BY drugName
	SET @ColumnNames = STUFF(@ColumnNames, 1, 2, '')
	Print (@ColumnNames)
	set @ColumnNames2 = ''
	select @ColumnNames2 = @ColumnNames2 + ', cast([' + drugname + '] as int)' from @OIDrugs ORDER BY drugName
	SET @ColumnNames2 = STUFF(@ColumnNames2, 1, 2, '')

	set @SumColumnNames = ''
	select @SumColumnNames = @SumColumnNames+', cast(SUM(isnull(['+drugname+'], 0)) as int)' from @OIDrugs ORDER BY drugName
	SET @SumColumnNames = STUFF(@SumColumnNames, 1, 2, '')
	
	EXEC('SELECT * into zzz_OIDispensing FROM #OIDispensing 
	PIVOT (SUM(DispensedQuantity) For drugname IN ('+ @ColumnNames +')) AS Total')

	EXEC('	
	SELECT PatientID, [Month/Year], '+@ColumnNames2+' FROM zzz_OIDispensing
	')
	
	IF EXISTS(SELECT * FROM sysobjects WHERE name='zzz_OIDispensing' AND type='U')
		DROP TABLE zzz_OIDispensing
END

GO

Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'OIDrugs_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'OIDrugs_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'OIDrugs_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('OIDrugs_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Pharmacy Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Pharmacy Reports',3)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Pharmacy Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'OIDrugs_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'OIDrugs_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'OIDrugs_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'OIDrugs_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('OIDrugs_Report'
,'OI Drugs Consumption Report'
,'OI Drugs Consumption Report'
, @CatID
, 'OIDrugs_Report_Template.xlsx'
, 'LPTF'
, @ReportGroupID
, 'NWU+HyiRPmQ=')

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
(   N'OIDrugs_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_Header'


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
(   N'OIDrugs_Report_Header',       -- qryName - nvarchar(50)
    N'Select DATENAME(mm, Cast(@ToDate AS DATE)) ReportMonth, DATENAME(yy, Cast(@ToDate AS DATE)) ReportYear, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'OIDrugs_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'OIDrugs_Report',       -- sbCategory - nvarchar(50)
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
(   N'B4',       
    @QueryID,         
    N'ReportMonth',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B5',       
    @QueryID,         
    N'ReportYear',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Drug Headers

IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_DrugsHeader')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_DrugsHeader'


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
(   N'OIDrugs_Report_DrugsHeader',       -- qryName - nvarchar(50)
    N'pr_GetOIDrugsHeaders',       -- qryDefinition - nvarchar(max)
    N'OIDrugs_Report_DrugsHeader',       -- qryDescription - nvarchar(200)
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
(   N'OIDrugs_Report',       -- sbCategory - nvarchar(50)
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

--Drug Totals

IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_DrugTotals')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_DrugTotals'


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
(   N'OIDrugs_Report_DrugTotals',       -- qryName - nvarchar(50)
    N'pr_GetOIDrugTotals',       -- qryDefinition - nvarchar(max)
    N'OIDrugs_Report_DrugTotals',       -- qryDescription - nvarchar(200)
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
(   N'OIDrugs_Report',       -- sbCategory - nvarchar(50)
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
(   N'C8',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Patient Line List

IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_Patients')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OIDrugs_Report_Patients'


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
(   N'OIDrugs_Report_Patients',       -- qryName - nvarchar(50)
    N'pr_GetOIDrugsSummary',       -- qryDefinition - nvarchar(max)
    N'OIDrugs_Report_Patients',       -- qryDescription - nvarchar(200)
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
(   N'OIDrugs_Report',       -- sbCategory - nvarchar(50)
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
(   N'A11',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)