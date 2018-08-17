Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'ART_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'ART_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'ART_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('ART_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Registers')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Registers',2)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Registers'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'ART_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'ART_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'ART_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'ART_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('ART_Register'
,'ART Register'
,'ART Register'
, @CatID
, 'ART_Register_Template.xlsx'
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
(   N'ART_Register',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'ART_Register_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'ART_Register_Header'


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
(   N'ART_Register_Header',       -- qryName - nvarchar(50)
    N'Select DateName(mm, Cast(@FromDate As Datetime)) Month,   DateName(yy, Cast(@FromDate As Datetime)) Year,    LPTF = (Select Top 1 tmp_PatientMaster.FacilityName From tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'ART_Register_Header',       -- qryDescription - nvarchar(200)
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
(   N'ART_Register',       -- sbCategory - nvarchar(50)
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
(   N'C3',       
    @QueryID,         
    N'Year',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)

--Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'ART_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'ART_Register_LineList'


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
(   N'ART_Register_LineList',       -- qryName - nvarchar(50)
    --N'Select Top 100 Percent Row_Number() Over (Order By TransferIn, a.StartARTDate) SerialCounter, * FROM (Select Distinct      Case When a.PatientSource = ''Transfer In'' Then Upper(''Y'') Else Upper(''N'')      End As TransferIn,      b.StartARTDate,      a.PatientID,      a.PatientName,      a.Gender,      a.DOB,   b.AgeARTStart,      a.Address,   a.PhoneNumber,      Case When c.bCD4 <= 500 Then ''CD4 <= 500'' Else Null End As Eligibilty,      d.bWHO,      c.bCD4,      PHeight.Height HeightForChild,      AWeight.Weight,      CTX.CTXStart,   INH.INHStart,   TB.TBTreatmentStartDate TBStartDate   , NULL TBRegNumber   , j.EDD EDD1   , j.ANCNumber ANC1   , NULL EDD2   , NULL ANC2   , NULL EDD3   , NULL ANC3    , COALESCE(dbo.fn_GetARTRegisterFollowUp(b.PatientPK, b.StartARTDate), b.StartRegimen) StartRegimen      , COALESCE(dbo.fn_GetARTRegisterFollowUp(h.PatientPK, h.Sub1Date), h.Sub1Regimen) Sub1Regimen     , h.Sub1Date     , NULL Sub1Reason     , NULL Sub2Regimen     , NULL Sub2Date     , NULL Sub2Reason     , COALESCE(dbo.fn_GetARTRegisterFollowUp(i.PatientPK, i.SecondLineRegimenStart) ,i.SecondLineRegimen)SecondLineRegimen     , i.SecondLineRegimenStart     , NULL Sub1Reasonn     , NULL Sub2Regimenn     , NULL Sub2Datee     , NULL Sub2Reasonn   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 0, b.StartARTDate)) Month0   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 1, b.StartARTDate)) Month1   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 2, b.StartARTDate)) Month2   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 3, b.StartARTDate)) Month3   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 4, b.StartARTDate)) Month4   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 5, b.StartARTDate)) Month5   , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 6, b.StartARTDate)) Month6  ,NULL CD46  ,NULL Weight6  ,NULL TBStatus6  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 7, b.StartARTDate)) Month7  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 8, b.StartARTDate)) Month8  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 9, b.StartARTDate)) Month9  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 10, b.StartARTDate)) Month10  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 11, b.StartARTDate)) Month11  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 12, b.StartARTDate)) Month12  ,NULL CD412  ,NULL Weight12  ,NULL TBStatus12  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 13, b.StartARTDate)) Month13  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 14, b.StartARTDate)) Month14  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 15, b.StartARTDate)) Month15  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 16, b.StartARTDate)) Month16  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 17, b.StartARTDate)) Month17  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 18, b.StartARTDate)) Month18  ,NULL CD418  ,NULL Weight18  ,NULL TBStatus18  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 19, b.StartARTDate)) Month19  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 20, b.StartARTDate)) Month20  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 21, b.StartARTDate)) Month21  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 22, b.StartARTDate)) Month22  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 23, b.StartARTDate)) Month23  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 24, b.StartARTDate)) Month24  ,NULL CD424  ,NULL Weight24  ,NULL TBStatus24  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 25, b.StartARTDate)) Month25  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 26, b.StartARTDate)) Month26  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 27, b.StartARTDate)) Month27  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 28, b.StartARTDate)) Month28  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 29, b.StartARTDate)) Month29  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 30, b.StartARTDate)) Month30  ,NULL CD430  ,NULL Weight30  ,NULL TBStatus30  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 31, b.StartARTDate)) Month31  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 32, b.StartARTDate)) Month32  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 33, b.StartARTDate)) Month33  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 34, b.StartARTDate)) Month34  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 35, b.StartARTDate)) Month35  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 36, b.StartARTDate)) Month36  ,NULL CD436  ,NULL Weight36  ,NULL TBStatus36  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 37, b.StartARTDate)) Month37  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 38, b.StartARTDate)) Month38  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 39, b.StartARTDate)) Month39  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 40, b.StartARTDate)) Month40  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 41, b.StartARTDate)) Month41  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 42, b.StartARTDate)) Month42  ,NULL CD442  ,NULL Weight42  ,NULL TBStatus42  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 43, b.StartARTDate)) Month43  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 44, b.StartARTDate)) Month44  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 45, b.StartARTDate)) Month45  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 46, b.StartARTDate)) Month46  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 47, b.StartARTDate)) Month47  , dbo.fn_GetARTRegisterFollowUp(a.PatientPK, DATEADD(MM, 48, b.StartARTDate)) Month48  ,NULL CD448  ,NULL Weight48  ,NULL TBStatus48    From tmp_PatientMaster As a      Inner Join (select patientpk, startartdate, ageartstart, StartRegimen from tmp_artpatients) b On a.PatientPK = b.PatientPK       Left Outer Join IQC_bCD4 As c On a.PatientPK = c.PatientPK      Left Outer Join IQC_bWHO As d On a.PatientPK = d.PatientPK      Left Join (Select b.PatientPK,        Max(a.Height) Height      From tmp_ClinicalEncounters a        Inner Join (Select a.PatientPK,          Max(a.VisitDate) HDate        From tmp_ClinicalEncounters a          Inner Join tmp_ARTPatients b On a.PatientPK = b.PatientPK        Where b.StartARTDate > a.VisitDate And b.AgeARTStart < 15        Group By a.PatientPK) b On a.PatientPK = b.PatientPK And          a.VisitDate = b.HDate      Group By b.PatientPK) PHeight On a.PatientPK = PHeight.PatientPK      Left Join (Select b.PatientPK,        Max(a.Weight) Weight      From tmp_ClinicalEncounters a        Inner Join (Select a.PatientPK,          Max(a.VisitDate) WDate        From tmp_ClinicalEncounters a          Inner Join tmp_ARTPatients b On a.PatientPK = b.PatientPK        Where b.StartARTDate > a.VisitDate        Group By a.PatientPK) b On a.PatientPK = b.PatientPK And          a.VisitDate = b.WDate      Group By b.PatientPK) AWeight On a.PatientPK = AWeight.PatientPK        Left Join (Select a.PatientPK,        Min(a.DispenseDate) CTXStart      From tmp_Pharmacy a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK       Where a.ProphylaxisType = ''CTX''      Group By a.PatientPK) CTX On a.PatientPK = CTX.PatientPK        Left Join (Select a.PatientPK,        Min(a.DispenseDate) INHStart      From tmp_Pharmacy a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK       Where a.Drug LIKE ''Isoniazid%''      Group By a.PatientPK) INH On a.PatientPK = INH.PatientPK        Left Join (select patientpk, tbtreatmentstartdate from tmp_tbpatients) TB On a.PatientPK = TB.PatientPK     LEFT JOIN    (Select a.PatientPK, a.Drug Sub1Regimen   , b.Sub1Date FROM tmp_Pharmacy a INNER JOIN (   Select a.PatientPK, MIN(DispenseDate) Sub1Date    FROM tmp_ARTPatients a INNER JOIN    tmp_Pharmacy b ON a.PatientPK = b.PatientPK   Where b.RegimenLine = ''First line substitute''   AND a.StartRegimen <> b.Drug   GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK and a.DIspenseDate = b.Sub1Date    inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK    Where a.RegimenLine = ''First line substitute'') h ON a.PatientPK = h.PatientPK   LEFT JOIN     (Select a.PatientPK, a.Drug SecondLineRegimen   , b.SecondLineRegimenStart FROM tmp_Pharmacy a INNER JOIN (   Select a.PatientPK, MIN(DispenseDate) SecondLineRegimenStart    FROM tmp_ARTPatients a INNER JOIN    tmp_Pharmacy b ON a.PatientPK = b.PatientPK   Where b.RegimenLine = ''Second line''   AND a.StartRegimen <> b.Drug   GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK    and a.DispenseDate = b.SecondLineRegimenStart    inner join tmp_PatientMaster c on a.PatientPK = c.PatientPK    Where a.RegimenLine = ''Second line'') i ON a.PatientPK = i.PatientPK     LEFT JOIN (Select b.PatientPK, a.ANCNumber, b.EDD FROM mst_Patient a INNER JOIN (  Select a.PatientPK  , MIN(a.LMP) LMP, MIN(a.EDD) EDD   FROM tmp_Pregnancies a INNER JOIN tmp_ARTPatients b  ON a.PatientPK = b.PatientPK  Where b.StartARTDate between a.LMP and a.EDD  or b.StartARTDate <= a.LMP   GROUP BY a.PatientPK) b  ON a.Ptn_pk = b.PatientPK) j ON a.PatientPK = j.PatientPK    Where b.StartARTDate Between Cast(@FromDate As datetime) And Cast(@ToDate As  datetime)) A',       -- qryDefinition - nvarchar(max)
    N'pr_GetARTRegister',
	N'ART_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'ART_Register',       -- sbCategory - nvarchar(50)
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
(   N'A6',       
    @QueryID,         
    N'#linelist_',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 