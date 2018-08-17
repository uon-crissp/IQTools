Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'OPDDCR_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'OPDDCR_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'OPDDCR_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('OPDDCR_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Pharmacy Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Pharmacy Reports',4)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Pharmacy Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'OPDDCR_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'OPDDCR_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'OPDDCR_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'OPDDCR_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('OPDDCR_Report'
,'OPD Drugs Consumption Report'
,'OPD Drugs Consumption Report'
, @CatID
, 'OPDDCR_Template.xlsx'
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
(   N'OPDDCR_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OPDDCR_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OPDDCR_Report_Header'


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
(   N'OPDDCR_Report_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @fromdate, 106) + '' - '' + CONVERT(varchar(20), @todate, 106) ReportingPeriod
	, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'OPDDCR_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'OPDDCR_Report',       -- sbCategory - nvarchar(50)
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
(   N'C2',       
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
    N'ReportingPeriod',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
)


--Drug Consumption
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'OPDDCR_Consumption')
DELETE FROM dbo.aa_Queries WHERE qryName = 'OPDDCR_Consumption'


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
(   N'OPDDCR_Consumption',       -- qryName - nvarchar(50)
    N'WITH OPDPatients AS
  (SELECT a.PatientPK Ptn_Pk
   FROM tmp_PatientMaster a
   WHERE RegistrationAtCCC IS NULL
     AND RegistrationAtPMTCT IS NULL
     AND RegistrationAtTBClinic IS NULL) ,

     OPDDrugs AS
  (SELECT DISTINCT d.Drug_pk ID,
                   d.DrugName,
                   d.QtyPerPurchaseUnit PackSize
   FROM OPDPatients a
   INNER JOIN ord_PatientPharmacyOrder b ON a.Ptn_Pk = b.Ptn_pk
   INNER JOIN dtl_PatientPharmacyOrder c ON b.ptn_pharmacy_pk = c.ptn_pharmacy_pk
   INNER JOIN mst_Drug d ON c.Drug_Pk = d.Drug_pk
   INNER JOIN lnk_DrugGeneric e ON d.Drug_pk = e.Drug_pk
   INNER JOIN mst_Generic f ON e.GenericID = f.GenericID
   INNER JOIN lnk_DrugTypeGeneric g oN f.GenericID = g.GenericId
   INNER JOIN mst_DrugType h ON g.DrugTypeId = h.DrugTypeID
   WHERE h.DrugTypeName NOT IN (''ARV Medication'',''Antituberculosis'')
   ) ,
   
   
   
     OpeningStocks AS
  (SELECT a.ItemId,
          b.LastStockDate,
          Sum(a.Quantity) OpeningStock
   FROM Dtl_StockTransaction a
   INNER JOIN
     (SELECT Dtl_StockTransaction.ItemId,
             Dtl_StockTransaction.BatchId,
             Max(Dtl_StockTransaction.TransactionDate) LastStockDate
      FROM Dtl_StockTransaction
      WHERE Dtl_StockTransaction.OpeningStock = 1
        AND Dtl_StockTransaction.TransactionDate <= Cast(@fromdate AS datetime)
      GROUP BY Dtl_StockTransaction.ItemId,
               Dtl_StockTransaction.BatchId) b ON a.ItemId = b.ItemId
   AND a.BatchId = b.BatchId
   WHERE a.OpeningStock = 1
     AND a.TransactionDate <= Cast(@fromdate AS datetime)
   GROUP BY a.ItemId,
            b.LastStockDate),
     ReceivedStock AS
  (SELECT a.ItemId,
          Sum(b.RecievedQuantity) ReceivedStock
   FROM OpeningStocks a
   LEFT JOIN Dtl_GRNote b ON a.ItemId = b.ItemId
   LEFT JOIN mst_Drug c ON b.ItemId = c.Drug_pk
   WHERE b.CreateDate BETWEEN a.LastStockDate AND Cast(@fromdate AS datetime)
   GROUP BY a.ItemId),
     OpeningBalance AS
  (SELECT z.ID,
          Sum(Ceiling((IsNull(a.OpeningStock, 0) + IsNull(b.ReceivedStock, 0)) / CASE WHEN z.PackSize = 0 OR z.PackSize IS NULL THEN 1 ELSE z.PackSize END)) OpeningBalance
   FROM OPDDrugs z
   INNER JOIN mst_Drug y ON z.DrugName = y.DrugName
   AND z.PackSize = y.QtyPerPurchaseUnit
   LEFT JOIN OpeningStocks a ON y.Drug_pk = a.ItemId
   LEFT JOIN ReceivedStock b ON a.ItemId = b.ItemId
   GROUP BY z.ID),
     QuantityReceived AS
  (SELECT a.ID,
          a.DrugName,
          
          Sum(c.RecievedQuantity) / CASE WHEN a.PackSize = 0 OR a.PackSize IS NULL THEN 1 ELSE a.PackSize END QuantityReceived
   FROM OPDDrugs a
   LEFT JOIN mst_drug b ON a.DrugName = b.DrugName
   AND a.PackSize = b.QtyPerPurchaseUnit
   LEFT JOIN Dtl_GRNote c ON b.Drug_pk = c.ItemId
   AND c.CreateDate BETWEEN Cast(@fromdate AS date) AND Cast(@todate AS date)
   WHERE c.RecievedQuantity > 0
   GROUP BY a.ID,
            a.DrugName,
            CASE WHEN a.PackSize = 0 OR a.PackSize IS NULL THEN 1 ELSE a.PackSize END),
     Dispensed AS
  (SELECT a.ID,
          Sum(Abs(c.DispensedQuantity)) DispensedUnits,
          Sum(Abs(c.DispensedQuantity)) / CASE WHEN a.PackSize = 0 OR a.PackSize IS NULL THEN 1 ELSE a.PackSize END DispensedPacks
   FROM OPDDrugs a
   LEFT JOIN mst_drug b ON a.DrugName = b.DrugName
   AND a.PackSize = b.QtyPerPurchaseUnit
   LEFT JOIN dtl_PatientPharmacyOrder c ON b.Drug_pk = c.Drug_Pk
   LEFT JOIN ord_PatientPharmacyOrder d ON c.ptn_pharmacy_pk = d.ptn_pharmacy_pk
   LEFT JOIN OPDPatients e ON d.Ptn_pk = e.Ptn_Pk
   WHERE d.DispensedByDate BETWEEN Cast(@fromdate AS date) AND Cast(@todate AS date)
     AND e.Ptn_Pk IS NOT NULL
   GROUP BY a.ID,
            CASE WHEN a.PackSize = 0 OR a.PackSize IS NULL THEN 1 ELSE a.PackSize END)
SELECT DISTINCT a.DrugName,
                a.PackSize,
                b.OpeningBalance BeginningBalance,
                c.QuantityReceived,
                Ceiling(d.DispensedUnits) DispensedUnits,
                Ceiling(d.DispensedPacks) DispensedPacks
FROM OPDDrugs a
LEFT JOIN OpeningBalance b ON a.ID = b.ID
LEFT JOIN QuantityReceived c ON a.ID = c.ID
LEFT JOIN Dispensed d ON a.ID = d.ID
WHERE Coalesce(CASE
                   WHEN b.OpeningBalance = 0 THEN NULL
                   ELSE b.OpeningBalance
               END, c.QuantityReceived, d.DispensedUnits) IS NOT NULL
ORDER BY a.DrugName',       -- qryDefinition - nvarchar(max)
    N'OPDDCR_Consumption',       -- qryDescription - nvarchar(200)
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
(   N'OPDDCR_Report',       -- sbCategory - nvarchar(50)
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
(   N'B9',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 