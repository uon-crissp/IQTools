IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_PreARTRegisterQFollowUp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_PreARTRegisterQFollowUp]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_PreARTRegisterQFollowUp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_PreARTRegisterQFollowUp](@PatientPK INT, @ReferenceDate DATETIME
, @Topic VARCHAR(100)
, @Quarter INT)
RETURNS VARCHAR(100)
AS
BEGIN
Declare @RC VARCHAR(100)
Declare @StartARTDate as datetime
Declare @QuarterEnd as datetime

Select @QuarterEnd = dbo.fn_GetQuarterEnd(RegistrationAtCCC, @Quarter)
FROM tmp_PatientMaster
WHERE PatientPK = @PatientPK


Select @StartARTDate = StartARTDate from tmp_ARTPatients where PatientPK = @PatientPK
AND StartARTDate <= @QuarterEnd

IF(@Topic = ''CD4'')
BEGIN
	IF(@StartARTDate IS NULL)
	BEGIN
		Select @RC = MAX(a.TestResult)  
		FROM tmp_Labs a INNER JOIN (
		Select PatientPK, MAX(OrderedbyDate) TestDate 
		FROM tmp_Labs Where TestName = ''CD4''
		AND OrderedbyDate BETWEEN DATEADD(MM, -3, @QuarterEnd) AND @QuarterEnd
		AND PatientPK =  @PatientPK
		GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.OrderedbyDate = b.TestDate
		AND a.TestName = ''CD4''
	END
END
ELSE IF(@Topic = ''WHO'')
	BEGIN
	IF(@StartARTDate IS NULL)
		BEGIN
		SELECT @RC = MAX(a.WHOStage) FROM tmp_ClinicalEncounters a INNER JOIN
		(Select PatientPK, MAX(VisitDate) WHODate FROM tmp_ClinicalEncounters
		WHERE VisitDate BETWEEN DATEADD(MM, -3, @QuarterEnd) AND @QuarterEnd
		AND PatientPK =  @PatientPK
		AND WHOStage IS NOT NULL
		GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.VisitDate = b.WHODate
		END
	END
ELSE IF(@Topic = ''CTX'')
	BEGIN
	IF(@StartARTDate IS NULL)
		BEGIN
		SELECT @RC = CASE WHEN CTXDate IS NOT NULL THEN ''YES'' ELSE NULL END FROM (
				Select ''YES'' CTX, MAX(DispenseDate) CTXDate FROM tmp_Pharmacy 
				Where ProphylaxisType = ''CTX''
				AND PatientPK = @PatientPK 
				AND DispenseDate BETWEEN  DATEADD(MM, -3, @QuarterEnd) AND @QuarterEnd) A
			
		END
	END
ELSE IF(@Topic = ''TBStatus'')
BEGIN
	IF(@StartARTDate IS NULL)
		BEGIN
			SELECT @RC =
			MAX(CASE WHEN a.Symptom IN (''No signs'',
			''None'') OR a.Symptom IS NULL THEN ''No signs'' 
				WHEN a.Symptom IN (''Contact TB'',
				''Cough'',
				''Cough > 2 weeks'',
				''Fever'',
				''Fever > 2 weeks'',
				''Prolonged night sweats'',
				''Suspect'',
				''Sweat'',
				''Weight Loss'') THEN ''TB Suspect'' 
				WHEN a.Symptom IN (''TB Rx'') THEN ''TB Rx'' 
				ELSE ''TB Suspect'' END) 
			FROM tmp_ClinicalEncounters a
			INNER JOIN
			(SELECT a.PatientPK,
				Max(a.VisitDate) LastScreening
			FROM tmp_ClinicalEncounters a
			WHERE a.SymptomCategory = ''TB Screening''
			AND PatientPK = @PatientPK
			AND VisitDate BETWEEN DATEADD(MM, -3, @QuarterEnd) AND @QuarterEnd       
			GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK
			AND a.VisitDate = b.LastScreening
			WHERE a.SymptomCategory = ''TB Screening''			
		END
	END
ELSE IF(@Topic = ''PatientStatus'')
	BEGIN
	IF(@StartARTDate IS NULL)
		BEGIN
			SELECT @RC =
			MAX(ExitReason) FROM tmp_LastStatus 
			Where ExitDate Between DATEADD(MM, -3, @QuarterEnd) AND @QuarterEnd 
			AND PatientPK = @PatientPK		
		END
	END

RETURN @RC

END


' 
END

GO

Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'PreART_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'PreART_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'PreART_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('PreART_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Registers')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Registers',2)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Registers'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'PreART_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'PreART_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'PreART_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'PreART_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('PreART_Register'
,'PreART Register'
,'PreART Register'
, @CatID
, 'PreART_Register_Template.xlsx'
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
(   N'PreART_Register',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'PreART_Register_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'PreART_Register_Header'


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
(   N'PreART_Register_Header',       -- qryName - nvarchar(50)
    N'Select FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster), DateName(mm, CAST(@ToDate as datetime)) + ''/'' + DateName(yy, CAST(@todate as datetime)) ReportMonth',       -- qryDefinition - nvarchar(max)
    N'PreART_Register_Header',       -- qryDescription - nvarchar(200)
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
(   N'PreART_Register',       -- sbCategory - nvarchar(50)
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
(   N'C3',       
    @QueryID,         
    N'ReportMonth',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Pre ART Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'PreART_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'PreART_Register_LineList'


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
(   N'PreART_Register_LineList',       -- qryName - nvarchar(50)
    N'Select DISTINCT a.PatientPK   , a.RegistrationAtCCC  , a.PatientID  , a.PatientName, a.AgeEnrollment, a.Gender, a.PatientSource  , CASE WHEN b.TBTreatmentStartDate <= a.RegistrationAtCCC THEN ''Y'' ELSE NULL END AS TBStatus  , b.TBTreatmentStartDate  , c.DistrictRegistrationNr  , CASE WHEN d.PregnantOnEnrollment = 1 THEN ''Y'' ELSE NULL END AS Pregnancy  , CTX.CTXStart  , INH.INHStart  , d.EDD EDD1  , CASE WHEN d.EDD IS NOT NULL THEN c.ANCNumber ELSE NULL END AS ANC1  , NULL Birth1, NULL HEI1  , NULL EDD2, NULL ANC2, NULL Birth2, NULL HEI2  , NULL EDD3, NULL ANC3, NULL Birth3, NULL HEI3  , CASE WHEN f.bCD4 <= 500 THEN f.bCD4Date ELSE NULL END DateMedicallyEligible  , e.StartARTDate  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',1) CD4Y1Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',1) WHOY1Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',1) CTXY1Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',1) TBStatusY1Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',1) PatientStatusY1Q1    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',2) CD4Y1Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',2) WHOY1Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',2) CTXY1Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',2) TBStatusY1Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',2) PatientStatusY1Q2    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',3) CD4Y1Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',3) WHOY1Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',3) CTXY1Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',3) TBStatusY1Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',3) PatientStatusY1Q3    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',4) CD4Y1Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',4) WHOY1Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',4) CTXY1Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',4) TBStatusY1Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',4) PatientStatusY1Q4    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',5) CD4Y2Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',5) WHOY2Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',5) CTXY2Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',5) TBStatusY2Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',5) PatientStatusY2Q1    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',6) CD4Y2Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',6) WHOY2Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',6) CTXY2Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',6) TBStatusY2Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',6) PatientStatusY2Q2    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',7) CD4Y2Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',7) WHOY2Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',7) CTXY2Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',7) TBStatusY2Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',7) PatientStatusY2Q3    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',8) CD4Y2Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',8) WHOY2Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',8) CTXY2Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',8) TBStatusY2Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',8) PatientStatusY2Q4    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',9) CD4Y3Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',9) WHOY3Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',9) CTXY3Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',9) TBStatusY3Q1  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',9) PatientStatusY3Q1    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',10) CD4Y3Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',10) WHOY3Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',10) CTXY3Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',10) TBStatusY3Q2  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',10) PatientStatusY3Q2    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',11) CD4Y3Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',11) WHOY3Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',11) CTXY3Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',11) TBStatusY3Q3  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',11) PatientStatusY3Q3    , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CD4'',12) CD4Y3Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''WHO'',12) WHOY3Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''CTX'',12) CTXY3Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''TBStatus'',12) TBStatusY4Q4  , dbo.fn_PreARTRegisterQFollowUp(a.PatientPK, a.RegistrationAtCCC, ''PatientStatus'',12) PatientStatusY3Q4  FROM tmp_PatientMaster a   LEFT JOIN (select patientpk, tbtreatmentstartdate from tmp_tbpatients) b ON a.PatientPK = b.PatientPK  LEFT JOIN mst_Patient c ON a.PatientPK = c.Ptn_Pk  LEFT JOIN (Select PatientPK, MIN(EDD) EDD, MAX(PregnantOnEnrollment)PregnantOnEnrollment FROM tmp_Pregnancies GROUP BY PatientPK) d ON a.PatientPK = d.PatientPK  LEFT JOIN (select patientpk, startartdate from tmp_artpatients) e ON a.PatientPK = e.PatientPK  LEFT JOIN (Select a.PatientPK,     Min(a.DispenseDate) CTXStart     From tmp_Pharmacy a inner join tmp_patientmaster b on a.PatientPK = b.PatientPK     Where a.ProphylaxisType = ''CTX''     Group By a.PatientPK) CTX On a.PatientPK = CTX.PatientPK  Left Join (Select a.PatientPK,     Min(a.DispenseDate) INHStart     From tmp_Pharmacy a inner join tmp_patientmaster b on a.PatientPK = b.PatientPK     Where a.Drug LIKE ''Isoniazid%''     Group By a.PatientPK) INH On a.PatientPK = INH.PatientPK  LEFT JOIN IQC_bCD4 f ON a.PatientPK = f.PatientPK  Where RegistrationAtCCC Between CAST(@FromDate as datetime) AND CAST(@ToDate as datetime)  ORDER BY a.RegistrationAtCCC',       -- qryDefinition - nvarchar(max)
    N'PreART_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'PreART_Register',       -- sbCategory - nvarchar(50)
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
(   N'A8',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 