Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'HHA_Register')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'HHA_Register'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'HHA_Register')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('HHA_Register',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'HHA Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('HHA Reports',5)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'HHA Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'HHA_Register')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'HHA_Register'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HHA_Register')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'HHA_Register')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, Password)
VALUES
('HHA_Register'
,'Hypertension Treatment Monthly Register'
,'HHA Register'
, @CatID
, 'HHA_Register_Template.xlsx'
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
(   N'HHA_Register',       
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


--Register Line List
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'HHA_Register_LineList')
DELETE FROM dbo.aa_Queries WHERE qryName = 'HHA_Register_LineList'


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
(   N'HHA_Register_LineList',       -- qryName - nvarchar(50)
    N'SELECT DISTINCT
DATEPART(DD,c.VisitDate) [DAY]  
, DATEPART(MM,c.VisitDate) [MONTH]  
, DATEPART(YY,c.VisitDate) [YEAR]  
, MAX(a.SatelliteName) SatelliteName  
, MAX(CASE WHEN d.StartDate < c.VisitDate THEN UPPER(''Y'') ELSE UPPER(''N'') END) AS ReturningClient  
, MAX(a.PatientName) PatientName  , e.HTNUniqueID HTNUniqueID  
, MAX(YEAR(a.DOB)) YoB  
, MAX(CASE a.Gender WHEN ''Male'' THEN UPPER(''M'') WHEN ''Female'' THEN UPPER(''F'') ELSE NULL END) AS Gender  
, MAX(a.PhoneNumber) PhoneNumber  
, MAX(CASE WHEN a.PhoneNumber IS NOT NULL THEN UPPER(''Y'') ELSE NULL END) MobileConsent  
, MAX(e.SubLocation) Village  
, MAX(f.Name) County  
, MAX(g.Name) ReferredFrom  
, MAX(a.SiteCode) SiteCode  
, MAX(h.BPSystolic) BPS  
, MAX(h.BPDiastolic) BPD  
, MAX(  CASE   WHEN h.BPSystolic > 179 OR h.BPDiastolic > 109 THEN ''Severe''  
WHEN h.BPSystolic BETWEEN 160 AND 179 OR h.BPDiastolic BETWEEN 100 AND 109 THEN ''Moderate''   
WHEN h.BPSystolic BETWEEN 140 AND 159 OR h.BPDiastolic BETWEEN 90 AND 99 
THEN ''Mild''    WHEN h.BPSystolic < 140 AND h.BPDiastolic < 90 
THEN ''Controlled''   ELSE NULL END)   HypertensionStatus  
, MAX(h.[Weight]) [Weight]  
, MAX(h.[Height]) [Height]  
, MAX(CASE WHEN h.[Weight] BETWEEN 20 AND 200 AND h.[Height] BETWEEN 100 AND 250 
THEN  CAST(h.[Weight]/((h.[Height]/100.0)*(h.[Height]/100.0)) AS DECIMAL(18,1)) ELSE NULL END) BMI  
, MAX(j.Name) Smoker  
, MAX(k.Name) DrinksAlcohol  
, MAX(CASE WHEN o.Name = ''Diabetes'' THEN ''Y'' ELSE NULL END) AS Diabetic  
, MAX(CASE WHEN h.BPSystolic < 140 AND h.BPDiastolic < 90 THEN UPPER(''Y'') WHEN h.BPSystolic >=  140 OR h.BPDiastolic >= 90 
THEN UPPER(''N'') ELSE NULL END) Controlled  
, MAX(COALESCE(n.HTNDrugA,p.TreatmentPlan)) HTNDrugA 
, MAX(n.HTNDrugB) HTNDrugB  
, MAX(n.HTNDrugC) HTNDrugC  
 
 FROM tmp_patientmaster a  INNER JOIN dtl_HTNPatientProfile b ON a.PatientPK = b.Ptn_Pk   
 INNER JOIN (Select Visit_Id, Ptn_Pk, VisitDate FROM ord_Visit a inner join tmp_PatientMaster b   
 ON a.Ptn_Pk = b.PatientPK  
 inner join mst_Visittype c on a.visittype = c.visittypeid
 WHERE c.VisitName IN (''HTN Initial Encounter'',''HTN Follow Up Visit'',''NCD Initial Encounter'',''NCD Follow Up'')
 and (a.deleteflag = 0 or a.deleteflag is null)) c ON a.PatientPk = c.Ptn_Pk 
INNER JOIN  (Select Ptn_Pk, MIN(StartDate) StartDate   FROM lnk_PatientProgramStart a 
			INNER JOIN tmp_PatientMaster b ON a.Ptn_Pk = b.PatientPK   
			Where ModuleId = 101  GROUP BY Ptn_Pk) d ON a.PatientPK = d.Ptn_Pk    
INNER JOIN mst_Patient e ON a.PatientPK = e.Ptn_Pk    
LEFT JOIN mst_County f ON e.CountyID = f.ID    
LEFT JOIN mst_Decode g ON b.EntryPointID = g.ID    
LEFT JOIN dtl_PatientVitals h ON c.Visit_Id = h.Visit_Pk    
LEFT JOIN dtl_HTNPatientRiskFactors i ON c.Visit_Id = i.Visit_Pk    
LEFT JOIN mst_Decode j ON i.SmokesID = j.ID    
LEFT JOIN mst_Decode k ON i.AlcoholID = k.ID    
LEFT JOIN dtl_HTNPatientFollowUp l ON c.Visit_Id = l.Visit_Pk  
LEFT JOIN mst_Decode m ON l.HTStageID = m.ID    
LEFT JOIN tmp_HTNDrugDispense n ON cast(c.VisitDate as date) = cast(n.DispenseDate as date)  
AND c.Ptn_Pk = n.PatientPK  
LEFT JOIN mst_Decode o ON i.OtherIllnessID = o.ID AND o.Name = ''Diabetes''      
LEFT JOIN (SELECT a.Ptn_Pk, a.Visit_Pk, b.Name TreatmentPlan   FROM dtl_HTNPatientFollowUp a 
INNER JOIN mst_Decode b ON a.TreatmentPlanID = b.ID   INNER JOIN tmp_PatientMaster c ON a.ptn_pk = c.PatientPK   
WHERE b.Name = ''Lifestyle'') p ON c.Visit_Id = p.Visit_Pk     
 WHERE c.VisitDate BETWEEN CAST(@FromDate as datetime) AND CAST(@ToDate as datetime)  
GROUP BY c.VisitDate, e.HTNUniqueID ORDER BY [YEAR],[MONTH],[DAY]',     -- qryDefinition - nvarchar(max)
    N'HHA_Register_LineList',       -- qryDescription - nvarchar(200)
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
(   N'HHA_Register',       -- sbCategory - nvarchar(50)
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
(   N'A3',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)