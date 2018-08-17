Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'HEI_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'HEI_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'HEI_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('HEI_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Registers')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Registers',3)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Registers'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'HEI_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'HEI_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HEI_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HEI_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('HEI_Register'
,'HIV Exposed Infants Register'
,'HEI Register'
, @CatID
, 'HEI_Register_Template.xlsx'
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
    'Select Birth Cohort',        -- ParamLabel - varchar(100)
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
(   N'HEI_Register',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'HEI_Register_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'HEI_Register_Header'


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
(   N'HEI_Register_Header',       -- qryName - nvarchar(50)
    N'Select FacilityName = (Select Top 1 a.FacilityName FROM tmp_PatientMaster a)  ,DATENAME(mm,Cast(@FromDate As DATETIME)) + ''/'' + DATENAME(YY,Cast(@ToDate As DATETIME)) BirthCohort',       -- qryDefinition - nvarchar(max)
    N'HEI_Register_Header',       -- qryDescription - nvarchar(200)
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
(   N'HEI_Register',       -- sbCategory - nvarchar(50)
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
    N'BirthCohort',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)
--Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'HEI_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'HEI_Register_LineList'


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
(   N'HEI_Register_LineList',       -- qryName - nvarchar(50)
    N'WITH HEI AS (Select   c.FacilityName  , a.Ptn_Pk PatientPK  , b.RegistrationDate  
, CASE WHEN b.HEIIDNumber   collate database_default 
IS NULL OR b.HEIIDNumber   collate database_default  = '''' THEN c.PatientID 
ELSE b.HEIIDNumber   collate database_default END AS HEIIDNumber  
, c.PatientName  , c.DOB  , DATEDIFF(ww, c.DOB, b.RegistrationDate) Age  
, c.Gender  , c.PatientSource  
, MAX(CASE WHEN d.Name LIKE ''other%'' THEN ''Other'' + ISNULL('' - '' + a.OtherPEP,'''') ELSE d.Name END) AS InfantARVs  
, MAX(a.MothersName) MothersName  , MAX(a.MothersPointOfCare) MothersPointOfCare  
, MAX(a.MotherARTRegimenAtEnrollment) MothersARVs  
FROM   DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card a  INNER JOIN mst_Patient b ON a.Ptn_pk = b.ptn_Pk  
INNER JOIN tmp_PatientMaster c ON b.Ptn_Pk = c.PatientPK  
LEFT JOIN mst_ModDecode d ON a.ChildPEPARVs = d.ID  
GROUP BY   c.FacilityName  , a.Ptn_Pk   , b.RegistrationDate  
, b.HEIIDNumber  , c.PatientID  , c.PatientName  , c.DOB  , c.Gender  , c.PatientSource  )    

, b AS (  Select b.ChildsPK  , b.MothersPK  , b.MothersName  , b.MothersPhoneNumber 
FROM HEI a INNER JOIN (  Select b.PatientPK ChildsPK, a.PatientPK MothersPK  , a.PatientName MothersName  
, a.PhoneNumber MothersPhoneNumber  FROM tmp_PatientMaster a INNER JOIN(  Select a.PatientPK, MAX(RPatientPK) RPatientPK   
FROM tmp_FamilyInfo a inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK  Where Relationship = ''Parent'' 
AND RGender = ''Female''  GROUP BY a.PatientPK) b ON a.PatientPK = b.RPatientPK) b ON a.PatientPK = b.ChildsPK)    

, c AS (  Select b.PatientPK ChildsPK  , a.PatientPK MothersPK  , a.PatientName MothersName  
, a.PhoneNumber MothersPhoneNumber FROM tmp_PatientMaster a INNER JOIN (  Select a.PatientPk, MAX(b.MothersPk) MothersPK   
FROM HEI a INNER JOIN (  Select DISTINCT a.PatientPK MothersPk, a.RPatientpK ChildsPk FROM tmp_FamilyInfo a   
inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   Where RelationShip = ''Child'') b ON a.PatientPK = b.ChildsPk  
GROUP BY a.PatientPK)b on a.PatientPK = b.MothersPK)    

, Mothers AS  (Select 
ChildsPK  
,MothersPK  , MothersName collate database_default MothersName
, MothersPhoneNumber FROM b  
UNION  Select ChildsPK  
,MothersPK  , MothersName collate database_default MothersName
, MothersPhoneNumber FROM c)  


, MothersARVs AS (Select a.PatientPK, MAX(a.Drug) ARVs   
FROM tmp_Pharmacy a INNER JOIN  (Select a.PatientPK, MIN(a.DispenseDate) DispenseDate  FROM  tmp_Pharmacy a 
INNER JOIN Mothers b ON a.PatientPK = b.MothersPK  INNER JOIN HEI c ON b.ChildsPK = c.PatientPK  
inner join tmp_PatientMaster d ON a.PatientPK = d.PatientPK   Where DATEDIFF(dd,a.DispenseDate,c.DOB) 
BETWEEN -90 AND 90  AND TreatmentType IN (''ART'')  GROUP BY a.PatientPK) b ON a.PatientPK = b.PatientPK 
AND a.DispenseDate = b.DispenseDate  inner join tmp_PatientMaster c ON a.PatientPK = c.PatientPK  
Where a.TreatmentType IN (''ART'')  GROUP BY a.PatientPK)    

, FirstPCR AS  (Select Ptn_Pk PatientPK  , FirstPCRDate  , b.Name FirstPCRResults   
FROM DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card a  LEFT JOIN mst_ModDecode b ON a.FirstPCRResults = b.ID  
inner join tmp_PatientMaster c on a.Ptn_Pk = c.PatientPK  WHERE b.Name IN (''Positive'', ''Negative''))    

, FirstAB AS  (Select  Ptn_Pk PatientPK  , FirstAntiBodyTestDate  
, b.Name FirstABResult  FROM DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card a  
LEFT JOIN mst_ModDecode b ON a.FirstAntiBodyTestResult = b.ID  
inner join tmp_PatientMaster c on a.Ptn_Pk = c.PatientPK  WHERE b.Name IN (''Positive'', ''Negative''))    

, CPCR AS  (Select  Ptn_Pk PatientPK  , ConfirmatoryPCRDate CPCRDate  , b.Name CPCR  
FROM DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card a  LEFT JOIN mst_ModDecode b ON a.CornfirmatoryPCRResult = b.ID  
inner join tmp_PatientMaster c on a.Ptn_Pk = c.PatientPK  WHERE b.Name IN (''Positive'', ''Negative''))    

, FinalAB AS  (Select  Ptn_Pk PatientPK  , a.FinalAntiBodyTestDate FinalABTestDate  , b.Name FinalABTestResult  
FROM DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card a  LEFT JOIN mst_ModDecode b ON a.FinalAntiBodyTestResult = b.ID  
inner join tmp_PatientMaster c on a.Ptn_Pk = c.PatientPK  WHERE b.Name IN (''Positive'', ''Negative''))    

, Outcomes AS (  Select a.PatientPK, MAX(d.Name) Outcome FROM HEI a INNER JOIN dtl_PatientCareEnded b ON a.PatientPK = b.Ptn_Pk  
INNER JOIN dtl_PatientTrackingCare c ON b.Ptn_Pk = c.Ptn_Pk AND b.TrackingID = c.TrackingID  
INNER JOIN mst_Decode d ON b.PatientExitReason = d.ID  INNER JOIN mst_Module e ON c.ModuleID = e.ModuleID  
inner join tmp_PatientMaster f on a.patientpk = f.PatientPK   WHERE e.ModuleName = ''ANC Maternity and Postnatal''  
GROUP BY a.PatientPK)    

Select DISTINCT a.PatientPK  
, a.RegistrationDate  
, a.HEIIDNumber  
, a.PatientName  
, a.DOB  
, a.Age  
, a.Gender  
, a.PatientSource  
, a.InfantARVs  
, COALESCE(b.MothersName,a.MothersName) MothersName  
, b.MothersPhoneNumber  
, CASE WHEN b.MothersPK IS NOT NULL THEN a.FacilityName ELSE a.MothersPointOfCare collate database_default END AS MothersPointOfCare
, c.PatientID CCCNumber  
, COALESCE(d.ARVs, a.MothersARVs) MothersARVs  
, DATEDIFF(ww, a.DOB, e.FirstPCRDate) AgeFPCR  
, e.FirstPCRDate  
, e.FirstPCRResults  
, f.FirstAntiBodyTestDate  
, DATEDIFF(mm, a.DOB,f.FirstAntiBodyTestDate) AgeFirstAB  
, f.FirstABResult  
, DATEDIFF(mm, a.DOB, g.CPCRDate) AgeCPCR  
, g.CPCRDate  
, g.CPCR  
, h.FinalABTestDate  
, DATEDIFF(mm, a.DOB, h.FinalABTestDate) AgeFinalAB  
, h.FinalABTestResult  
, NULL HIVStatusAt18Months  
, NULL FinalChildARVs  
, i.Outcome  
, CASE WHEN CCC.PatientPK IS NOT NULL AND j.RegistrationAtCCC IS NOT NULL  THEN j.PatientID ELSE NULL END AS CCCNumber    
FROM HEI a LEFT JOIN Mothers b ON a.PatientPK = b.ChildsPK  
LEFT JOIN  (select patientpk, patientid from tmp_patientmaster) c ON b.MothersPK = c.PatientPK  
LEFT JOIN MothersARVs d ON b.MothersPK = d.PatientPK   
LEFT JOIN FirstPCR e ON a.PatientPK = e.PatientPK  
LEFT JOIN FirstAB f ON a.PatientPK = f.PatientPK  
LEFT JOIN CPCR g ON a.PatientPK = g.PatientPK  
LEFT JOIN FinalAB h ON a.PatientPK = h.PatientPK  
LEFT JOIN Outcomes i ON a.PatientPK = i.PatientPK  
LEFT JOIN (Select Distinct a.PatientPK from tmp_ClinicalEncounters    a 
			inner join tmp_PatientMaster b on a.PatientPK = b.PatientPK   
Where VisitType = ''Initial and Follow up Visits'') CCC ON a.PatientPK = CCC.PatientPK  
LEFT JOIN tmp_PatientMaster j ON a.PatientPK = j.PatientPK  
WHERE a.DOB Between CAST(@FromDate as datetime) AND CAST(@ToDate as datetime)',
    N'HEI_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'HEI_Register',       -- sbCategory - nvarchar(50)
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
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 