IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetTBFollowUp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetTBFollowUp]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetTBFollowUp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_GetTBFollowUp](@PatientPK INT, @ReferenceDate Date, @Months INT, @StatusOrDate VARCHAR(10))
RETURNS VARCHAR(100) AS
BEGIN
Declare @Status as Varchar(100)
Declare @StatusDate as Varchar(100)
DECLARE @RC as VARCHAR(100)


IF EXISTS (Select * FROM tmp_ClinicalEncounters 
WHERE VisitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
AND PatientPK = @PatientPK
)
BEGIN

	IF EXISTS (SELECT DISTINCT PatientPK FROM tmp_TBPatients
	Where RegistrationAtTBClinic BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK)
	BEGIN
	Select  @Status = ''2'', @StatusDate = (SELECT MIN(RegistrationAtTBClinic) FROM tmp_TBPatients
	Where RegistrationAtTBClinic BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK)
	END

	ELSE IF EXISTS
	(Select Distinct PatientPK FROM tmp_ClinicalEncounters
	WHERE SymptomCategory = ''TB Screening'' 
	AND (Symptom LIKE ''%cough%'' OR Symptom LIKE ''%fever%'' OR Symptom LIKE ''%suspect%'' OR
	Symptom LIKE ''%weight%'' OR Symptom LIKE ''%sweat%'')
	AND VisitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK)
	BEGIN

	Select @Status = ''1'', @StatusDate = (Select MIN(VisitDate) FROM tmp_ClinicalEncounters
	WHERE SymptomCategory = ''TB Screening'' 
	AND (Symptom LIKE ''%cough%'' OR Symptom LIKE ''%fever%'' OR Symptom LIKE ''%suspect%'' OR
	Symptom LIKE ''%weight%'' OR Symptom LIKE ''%sweat%'')
	AND VisitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK)

	END

	ELSE IF EXISTS
	(Select * FROM tmp_LastStatus WHERE ExitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK AND ExitReason = ''Lost'')
	BEGIN
	SELECT @Status = ''3'', @StatusDate = (Select MIN(ExitDate) FROM tmp_LastStatus 
	WHERE ExitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK AND ExitReason = ''Lost'')
	END

	ELSE IF EXISTS
	(Select * FROM tmp_LastStatus WHERE ExitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK AND ExitReason = ''Death'')
	BEGIN
	SELECT @Status = ''4'', @StatusDate = (Select MIN(ExitDate) FROM tmp_LastStatus 
	WHERE ExitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
	AND PatientPK =  @PatientPK AND ExitReason = ''Death'')
	END

ELSE 
SELECT @Status = ''0'', @StatusDate = (Select MAX(VisitDate) FROM tmp_ClinicalEncounters WHERE VisitDate BETWEEN @ReferenceDate AND DATEADD(MM, @Months, @ReferenceDate)
AND PatientPK =  @PatientPK)

END



IF @StatusOrDate = ''Status''
Set @RC = @Status
ELSE
Set @RC = @StatusDate

RETURN @RC

END' 
END

GO


Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'IPT_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'IPT_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'IPT_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('IPT_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Registers')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Registers',2)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Registers'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'IPT_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'IPT_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'IPT_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'IPT_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('IPT_Register'
,'TB IPT Register'
,'IPT Register'
, @CatID
, 'IPT_Register_Template.xlsx'
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
(   N'IPT_Register',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'IPT_Register_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'IPT_Register_Header'


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
(   N'IPT_Register_Header',       -- qryName - nvarchar(50)
    N'Select DateName(mm, Cast(@FromDate As Datetime)) Month,    DateName(yy, Cast(@FromDate As Datetime)) Year,    LPTF = (Select Top 1 tmp_PatientMaster.FacilityName From tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'IPT_Register_Header',       -- qryDescription - nvarchar(200)
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
(   N'IPT_Register',       -- sbCategory - nvarchar(50)
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
    N'LPTF',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'B3',       
    @QueryID,         
    N'Month',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
),
(   N'D3',       
    @QueryID,         
    N'Year',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--IPT Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'IPT_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'IPT_Register_LineList'


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
(   N'IPT_Register_LineList',       -- qryName - nvarchar(50)
    N'WITH Weights AS  
(Select a.PatientPK, MAX([Weight]) W  
from tmp_ClinicalEncounters a INNER JOIN  tmp_IPT b ON a.PatientPK = b.PatientPK AND   DATEDIFF(M, IPTStartDate, a.VisitDate) BETWEEN -60 and 60  
GROUP BY a.PatientPK)  

, Heights AS  
(Select a.PatientPK, MAX([Height]) H  
from tmp_ClinicalEncounters a INNER JOIN  tmp_IPT b ON a.PatientPK = b.PatientPK AND   DATEDIFF(M, IPTStartDate, a.VisitDate) BETWEEN -60 and 60  
GROUP BY a.PatientPK)  
   

Select   a.IPTStartDate  
, b.PatientPK  
, NULL IPTNumber  
, b.PatientID  
, b.PatientName  
, b.[Address]  
, b.PhoneNumber  
, b.Gender   
, DATEDIFF(yy, b.DOB, a.IPTStartDate) Years  
, DATEDIFF(mm, b.DOB, a.IPTStartDate)%12 Months  , c.W  , d.H  , NULL BMIForAge  , NULL ZScore  
, CASE WHEN b.RegistrationAtCCC < a.IPTStartDate THEN ''PLHIV - On Care'' WHEN b.RegistrationAtCCC   BETWEEN CAST(@FromDate as datetime) AND CAST(@ToDate as datetime)  THEN ''PLHIV - Newly Enrolled'' ELSE NULL END AS IndicationForIPT  
, CASE WHEN b.RegistrationAtCCC <= CAST(@ToDate as datetime) THEN ''Y'' ELSE NULL END AS HIVStatus  
, CASE WHEN a.Medication LIKE ''%300%'' THEN ''300mg'' WHEN a.Medication LIKE ''%100%'' THEN ''100mg'' ELSE NULL END AS IPTDose  
, a.IPTOutcome  
, a.DiscontinuationReason  
, a.DateOfOutcome  
, dbo.fn_GetTBFollowUp(a.PatientPK, a.DateOfOutcome, 6, ''Status'') m6FollowUpStatus 
 , CAST(dbo.fn_GetTBFollowUp(a.PatientPK, a.DateOfOutcome, 6, ''Date'') AS DATE) m6FollowUpStatus  
 , dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,6,a.DateOfOutcome), 6, ''Status'') m12FollowUpStatus  
 , CAST(dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,6,a.DateOfOutcome), 6, ''Date'') AS DATE) m12FollowUpStatus  
 , dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,12,a.DateOfOutcome), 6, ''Status'') m18FollowUpStatus  
 , CAST(dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,12,a.DateOfOutcome), 6, ''Date'') AS DATE) m24FollowUpStatus  
 , dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,18,a.DateOfOutcome), 6, ''Status'') m18FollowUpStatus  
 , CAST(dbo.fn_GetTBFollowUp(a.PatientPK, DATEADD(MM,18,a.DateOfOutcome), 6, ''Date'') AS DATE) m24FollowUpStatus  
 
 From tmp_IPT a Inner Join tmp_PatientMaster b On a.PatientPK = b.PatientPK    
 LEFT JOIN Weights c ON a.PatientPK = c.PatientPK    
 LEFT JOIN Heights d ON a.PatientPK = d.PatientPK      
 WHERE a.IPTStartDate BETWEEN CAST(@FromDate as datetime) AND CAST(@ToDate as datetime)',
    N'IPT_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'IPT_Register',       -- sbCategory - nvarchar(50)
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