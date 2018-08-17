Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'FCDRR_Report')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'FCDRR_Report'
	DELETE FROM dbo.aa_XLMaps WHERE xlCatID = (Select CatID FROM aa_Category 
											  WHERE Category = N'FCDRR_Report')
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('FCDRR_Report',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')

IF NOT EXISTS(Select ReportGroupID FROM aa_ReportGroups WHERE GroupName = 'Pharmacy Reports')
INSERT INTO aa_ReportGroups (GroupName, Position)
VALUES
('Pharmacy Reports',4)

SELECT @ReportGroupID = ReportGroupID FROM aa_ReportGroups
WHERE GroupName = 'Pharmacy Reports'

IF EXISTS(Select ReportID FROM aa_Reports WHERE ReportName = N'FCDRR_Report')
BEGIN
	DELETE FROM dbo.aa_Reports WHERE ReportName = 'FCDRR_Report'
	DELETE FROM dbo.aa_ReportParameters WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'FCDRR_Report')
	DELETE FROM dbo.aa_ReportLineLists WHERE ReportID = (Select ReportID FROM aa_Reports 
															WHERE ReportName = N'FCDRR_Report')
END

INSERT INTO aa_Reports (ReportName, ReportDisplayName, ReportDescription, QueryCategoryID, ExcelTemplateName
, ExcelWorksheetName, ReportGroupID, [Password])
VALUES
('FCDRR_Report'
,'Facility Consumption Data Report and Request (F-CDRR) for ARV and OI Medicines'
,'Facility Consumption Data Report and Request (F-CDRR) for ARV and OI Medicines'
, @CatID
, 'FCDRR_Template.xlsx'
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
(   N'FCDRR_Report',       
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FCDRR_Report_Header')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FCDRR_Report_Header'


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
(   N'FCDRR_Report_Header',       -- qryName - nvarchar(50)
    N'Select CONVERT(varchar(20), @fromdate, 106) + '' - '' + CONVERT(varchar(20), @todate, 106) ReportingPeriod
	, FacilityName = (Select TOP 1 FacilityName FROM tmp_PatientMaster)',       -- qryDefinition - nvarchar(max)
    N'FCDRR_Report_Header',       -- qryDescription - nvarchar(200)
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
(   N'FCDRR_Report',       -- sbCategory - nvarchar(50)
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
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'FCDRR_Consumption')
DELETE FROM dbo.aa_Queries WHERE qryName = 'FCDRR_Consumption'


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
(   N'FCDRR_Consumption',       -- qryName - nvarchar(50)
    N'WITH CDRRDrugs AS
  (SELECT 0 ID,
          ''Adult Preparations'' DrugName,
                               NULL PackSize
   UNION SELECT 1 ID,
                ''Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) 300/150/200mg FDC Tabs'' DrugName,
                                                                                        60 PackSize
   UNION SELECT 2 ID,
                ''Zidovudine/Lamivudine (AZT/3TC) 300/150mg FDC Tabs'',
                60 PackSize
   UNION SELECT 3 ID,
                ''Zidovudine/Lamivudine (AZT/3TC) 300/150mg FDC Tabs'',
                120 PackSize
   UNION SELECT 4 ID,
                ''Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) 300/300/600mg FDC Tabs'',
                30 PackSize
   UNION SELECT 5 ID,
                ''Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) 300/150/600mg FDC Tabs'',
                30 PackSize
   UNION SELECT 6 ID,
                ''Tenofovir/Lamivudine (TDF/3TC) 300/300mg FDC Tabs'',
                30 PackSize
   UNION SELECT 7 ID,
                ''Tenofovir/Lamivudine (TDF/3TC) 300/150mg FDC Tabs'',
                30 PackSize
   UNION SELECT 8 ID,
                ''Stavudine/Lamivudine/Nevirapine (d4T/3TC/NVP) 30/150/200mg FDC Tabs'',
                60 PackSize
   UNION SELECT 9 ID,
                ''Stavudine/Lamivudine (d4T/3TC) 30/150mg FDC Tabs'',
                60 PackSize
   UNION SELECT 10 ID,
                ''Efavirenz (EFV) 600mg Tabs'',
                30 PackSize
   UNION SELECT 11 ID,
                ''Lamivudine (3TC) 150mg Tabs'',
                60 PackSize
   UNION SELECT 12 ID,
                ''Lamivudine (3TC) 300mg Tabs'',
                60 PackSize
   UNION SELECT 13 ID,
                ''Nevirapine (NVP) 200mg Tabs'',
                60 PackSize
   UNION SELECT 14 ID,
                ''Nevirapine (NVP) 400mg Tabs'',
                30 PackSize
   UNION SELECT 15 ID,
                ''Tenofovir (TDF) 300mg Tabs'',
                30 PackSize
   UNION SELECT 16 ID,
                ''Zidovudine (AZT) 300mg Tabs'',
                60 PackSize
   UNION SELECT 17 ID,
                ''Abacavir (ABC) 300mg Tabs'',
                60 PackSize
   UNION SELECT 18 ID,
                ''Didanosine (ddI) 400mg EC Tabs'',
                30 PackSize
   UNION SELECT 19 ID,
                ''Didanosine (ddI) 250mg EC Tabs'',
                30 PackSize
   UNION SELECT 20 ID,
                ''Lopinavir/ritonavir (LPV/r) 200/50mg Tabs'',
                120 PackSize
   UNION SELECT 21 ID,
                ''Stavudine (d4T) 30mg Tabs'',
                60 PackSize
   UNION SELECT 22 ID,
                ''Atazanavir/Ritonavir 300/100mg Tabs'',
                30 PackSize
   UNION SELECT 23 ID,
                ''Atazanavir 300mg Tabs'',
                60 PackSize
   UNION SELECT 24 ID,
                NULL,
                NULL PackSize
   UNION SELECT 24 ID,
                ''Paed Preparations'',
                NULL PackSize
   UNION SELECT 25 ID,
                ''Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) 60/30/50mg FDC Tabs'',
                60 PackSize
   UNION SELECT 26 ID,
                ''Zidovudine/Lamivudine (AZT/3TC) 60/30mg FDC Tabs'',
                60 PackSize
   UNION SELECT 27 ID,
                ''Abacavir/Lamivudine (ABC/3TC) 60/30mg FDC Tabs'',
                60 PackSize
   UNION SELECT 28 ID,
                ''Stavudine/Lamivudine/Nevirapine (d4T/3TC/NVP) 12/60/100mg FDC Tabs'',
                60 PackSize
   UNION SELECT 29 ID,
                ''Abacavir (ABC) 20mg/ml Liquid'',
                1 PackSize
   UNION SELECT 30 ID,
                ''Didanosine (ddI) 25mg Buffered Tabs'',
                60 PackSize
   UNION SELECT 31 ID,
                ''Didanosine (ddI) 125mg EC Tabs'',
                30 PackSize
   UNION SELECT 32 ID,
                ''Didanosine (ddI) 200mg EC Tabs'',
                30 PackSize
   UNION SELECT 33 ID,
                ''Efavirenz (EFV) 50mg Tabs'',
                30 PackSize
   UNION SELECT 34 ID,
                ''Efavirenz (EFV) 200mg Tabs'',
                90 PackSize
   UNION SELECT 35 ID,
                ''Efavirenz (EFV) 100mg Tabs'',
                90 PackSize
   UNION SELECT 36 ID,
                ''Lamivudine (3TC) 10mg/ml Liquid'',
                1 PackSize
   UNION SELECT 37 ID,
                ''Lopinavir/ritonavir (LPV/r) 100/25mg Tabs'',
                120 PackSize
   UNION SELECT 38 ID,
                ''Lopinavir/ritonavir (LPV/r) 100/25mg Tabs'',
                60 PackSize
   UNION SELECT 39 ID,
                ''Lopinavir/ritonavir (LPV/r) 80/20mg/ml Liquid'',
                1 PackSize
   UNION SELECT 40 ID,
                ''Nevirapine (NVP) 50mg Tabs'',
                30 PackSize
   UNION SELECT 41 ID,
                ''Nevirapine (NVP) 50mg Tabs'',
                60 PackSize
   UNION SELECT 42 ID,
                ''Nevirapine (NVP) 10mg/ml Suspension'',
                1 PackSize
   UNION SELECT 43 ID,
                ''Stavudine (d4T) 15mg Tabs'',
                60 PackSize
   UNION SELECT 44 ID,
                ''Stavudine (d4T) 20mg Tabs'',
                60 PackSize
   UNION SELECT 45 ID,
                ''Zidovudine (AZT) 100mg Tabs'',
                100 PackSize
   UNION SELECT 46 ID,
                ''Zidovudine (AZT) 10mg/ml Liquid'',
                1 PackSize
   UNION SELECT 47 ID,
                ''Didanosine (ddI) 50mg EC Tabs'',
                60 PackSize
   UNION SELECT 48 ID,
                ''Ritonavir (RTV) 80mg/ml Oral Solution'',
                1 PackSize
   UNION SELECT 50 ID,
                ''Nevirapine (NVP) 50mg/5ml Suspension'',
                1 PackSize
   UNION SELECT 51 ID,
                NULL,
                NULL PackSize
   UNION SELECT 51 ID,
                NULL,
                NULL PackSize
   UNION SELECT 51 ID,
                ''OI Medication'',
                NULL PackSize
   UNION SELECT 52 ID,
                ''Cotrimoxazole 480mg Tabs'',
                1000 PackSize
   UNION SELECT 53 ID,
                ''Cotrimoxazole 480mg Tabs'',
                100 PackSize
   UNION SELECT 54 ID,
                ''Cotrimaxazole 960mg Tabs'',
                100 PackSize
   UNION SELECT 55 ID,
                ''Cotrimaxazole 960mg Tabs'',
                500 PackSize
   UNION SELECT 56 ID,
                ''Cotrimaxazole 240mg/5ml 100ml Suspension'',
                1 PackSize
   UNION SELECT 57 ID,
                ''Dapsone 100mg Tabs'',
                1000 PackSize
   UNION SELECT 58 ID,
                ''Dapsone 100mg Tabs'',
                100 PackSize
   UNION SELECT 59 ID,
                ''Fluconazole 200mg Tabs'',
                100 PackSize
   UNION SELECT 60 ID,
                ''Fluconazole 200mg Tabs'',
                28 PackSize
   UNION SELECT 61 ID,
                ''Fluconazole IV 2MG/ML'',
                100 PackSize
   UNION SELECT 62 ID,
                ''Amphotericin B 50mg/10ml IV Injection'',
                1 PackSize
   UNION SELECT 63 ID,
                ''Acyclovir 200mg Tabs'',
                30 PackSize
   UNION SELECT 64 ID,
                ''Pyridoxine 50mg Tabs'',
                100 PackSize
   UNION SELECT 65 ID,
                ''Ethambutol 100mg Tabs'',
                100 PackSize
   UNION SELECT 66 ID,
                ''Ethambutol 400mg Tabs'',
                100 PackSize
   UNION SELECT 67 ID,
                ''Ethambutol 400mg Tabs'',
                28 PackSize
   UNION SELECT 68 ID,
                ''Isoniazid 300mg Tabs'',
                100 PackSize
   UNION SELECT 69 ID,
                ''Isoniazid 300mg Tabs'',
                28 PackSize
   UNION SELECT 70 ID,
                ''Nystatin 100000 IU Oral drops'',
                1 PackSize
   UNION SELECT 71 ID,
                ''Nystatin 500000 IU Oral drops'',
                1 PackSize
   UNION SELECT 72 ID,
                ''Pyrazinamide 500mg Tabs'',
                100 PackSize
   UNION SELECT 73 ID,
                ''Pyrazinamide 500mg Tabs'',
                28 PackSize
   UNION SELECT 74 ID,
                ''Rifabutin 150 mg Tabs'',
                30 PackSize
   UNION SELECT 75 ID,
                ''Diflucan 200mg Tabs'',
                28 PackSize
   UNION SELECT 76 ID,
                ''Isoniazid 100mg Tabs'',
                100 PackSize
   UNION SELECT 77 ID,
                ''Acyclovir 400mg Tabs'',
                30 PackSize
   UNION SELECT 78 ID,
                ''Acyclovir 400mg Tabs'',
                10 PackSize
   UNION SELECT 79 ID,
                ''Acyclovir 800mg Tabs'',
                20 PackSize),
     OtherDrugs AS
  (SELECT 0 ID,
          ''Not Mapped'' DrugName,
                       NULL PackSize
   UNION SELECT a.Drug_Pk ID,
                a.DrugName,
                a.QtyPerPurchaseUnit PackSize
   FROM mst_Drug a
   LEFT JOIN CDRRDrugs b ON a.DrugName = b.DrugName
   AND a.QtyPerPurchaseUnit = b.PackSize
   WHERE b.ID IS NULL),
     OpeningBalance AS
  (SELECT z.Id,
          CEILING(SUM(a.Quantity)/z.PackSize) OpeningBalance
   FROM Dtl_StockTransaction a
   INNER JOIN mst_Drug b ON a.ItemId = b.Drug_pk
   INNER JOIN cdrrdrugs z ON b.DrugName = z.drugName
   AND z.PackSize = b.QtyPerPurchaseUnit
   WHERE CAST(TransactionDate AS date) < Cast(@fromdate AS date)
   GROUP BY z.Id,
            z.PackSize),
     QuantityReceived AS
  (SELECT c.Id,
          SUM(a.Quantity)/c.PackSize QuantityReceived
   FROM dtl_StockTransaction a
   INNER JOIN mst_Drug b ON a.ItemId = b.Drug_pk
   INNER JOIN CDRRDrugs c ON b.DrugName = c.DrugName
   AND b.QtyPerPurchaseUnit = c.PackSize
   WHERE CAST(TransactionDate AS date) BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND a.ptn_pharmacy_pk IS NULL
     AND a.quantity > 0
     AND a.StoreId IN
       (SELECT Id
        FROM mst_Store
        WHERE CentralStore = 1)
   GROUP BY c.Id,
            c.PackSize),
     Dispensed AS
  (SELECT a.ID,
          sum(abs(c.Quantity)) DispensedUnits,
          sum(abs(c.Quantity))/a.PackSize DispensedPacks
   FROM CDRRDrugs a
   INNER JOIN mst_drug b ON a.DrugName = b.DrugName
   AND a.PackSize = b.QtyPerPurchaseUnit
   INNER JOIN Dtl_StockTransaction c ON b.Drug_pk = c.ItemId
   INNER JOIN ord_PatientPharmacyOrder d ON c.Ptn_Pharmacy_Pk = d.ptn_pharmacy_pk
   INNER JOIN tmp_PatientMaster e ON d.ptn_pk = e.PatientPK
   WHERE c.TransactionDate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND c.Ptn_Pharmacy_Pk IS NOT NULL
     AND e.RegistrationAtCCC <= cast(@todate AS date)
   GROUP BY a.ID,
            a.PackSize),
     OtherDrugs_OpeningBalance AS
  (SELECT z.Id,
          CEILING(SUM(a.Quantity)/CASE
                                      WHEN z.PackSize = 0
                                           OR z.PackSize IS NULL THEN 1
                                      ELSE z.PackSize
                                  END) OpeningBalance
   FROM Dtl_StockTransaction a
   INNER JOIN mst_Drug b ON a.ItemId = b.Drug_pk
   INNER JOIN OtherDrugs z ON b.DrugName = z.drugName
   AND z.PackSize = b.QtyPerPurchaseUnit
   WHERE CAST(TransactionDate AS date) < Cast(@fromdate AS date)
   GROUP BY z.Id,
            CASE
                WHEN z.PackSize = 0
                     OR z.PackSize IS NULL THEN 1
                ELSE z.PackSize
            END),
     OtherDrugs_QuantityReceived AS
  (SELECT c.Id,
          SUM(a.Quantity)/CASE
                              WHEN c.PackSize = 0
                                   OR c.PackSize IS NULL THEN 1
                              ELSE c.PackSize
                          END QuantityReceived
   FROM dtl_StockTransaction a
   INNER JOIN mst_Drug b ON a.ItemId = b.Drug_pk
   INNER JOIN OtherDrugs c ON b.DrugName = c.DrugName
   AND b.QtyPerPurchaseUnit = c.PackSize
   WHERE CAST(TransactionDate AS date) BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND a.ptn_pharmacy_pk IS NULL
     AND a.quantity > 0
     AND a.StoreId IN
       (SELECT Id
        FROM mst_Store
        WHERE CentralStore = 1)
   GROUP BY c.Id,
            CASE
                WHEN c.PackSize = 0
                     OR c.PackSize IS NULL THEN 1
                ELSE c.PackSize
            END) ,
     OtherDispensed AS
  (SELECT a.ID,
          sum(abs(c.Quantity)) DispensedUnits,
          sum(abs(c.Quantity))/CASE
                                   WHEN a.PackSize = 0
                                        OR a.PackSize IS NULL THEN 1
                                   ELSE a.PackSize
                               END DispensedPacks
   FROM OtherDrugs a
   LEFT JOIN dtl_StockTransaction c ON a.ID = c.ItemId
   LEFT JOIN ord_PatientPharmacyOrder d ON c.ptn_pharmacy_pk = d.ptn_pharmacy_pk
   LEFT JOIN tmp_PatientMaster e ON d.ptn_pk = e.PatientPK
   WHERE c.TransactionDate BETWEEN cast(@fromdate AS date) AND cast(@todate AS date)
     AND e.RegistrationAtCCC <= cast(@todate AS date)
   GROUP BY a.ID,
            CASE
                WHEN a.PackSize = 0
                     OR a.PackSize IS NULL THEN 1
                ELSE a.PackSize
            END
   HAVING sum(abs(c.Quantity)) > 0)
SELECT *
FROM
  (SELECT DISTINCT a.ID,
                   a.DrugName,
                   a.PackSize,
                   b.OpeningBalance BeginningBalance,
                   c.QuantityReceived,
                   ceiling(d.DispensedUnits) DispensedUnits,
                   ceiling(d.DispensedPacks) DispensedPacks
   FROM CDRRDrugs a
   LEFT JOIN OpeningBalance b ON a.ID = b.ID
   LEFT JOIN QuantityReceived c ON a.ID = c.ID
   LEFT JOIN Dispensed d ON a.ID = d.ID
   WHERE d.DispensedUnits > 0
     OR c.QuantityReceived > 0
     OR a.PackSize IS NULL
   UNION SELECT 1001 ID,
                NULL DrugName,
                     NULL PackSize,
                          NULL BeginningBalance,
                               NULL QuantityReceived,
                                    NULL DispensedUnits,
                                         NULL DispensedPacks
   UNION SELECT 1002 ID,
                NULL DrugName,
                     NULL PackSize,
                          NULL BeginningBalance,
                               NULL QuantityReceived,
                                    NULL DispensedUnits,
                                         NULL DispensedPacks
   UNION SELECT 1003 ID,
                ''Other Drugs'' DrugName,
                              NULL PackSize,
                                   NULL BeginningBalance,
                                        NULL QuantityReceived,
                                             NULL DispensedUnits,
                                                  NULL DispensedPacks
   UNION SELECT 1003 + a.ID,
                a.DrugName,
                a.PackSize,
                b.OpeningBalance,
                c.QuantityReceived,
                d.DispensedUnits,
                d.DispensedPacks
   FROM OtherDrugs a
   LEFT JOIN OtherDrugs_OpeningBalance b ON a.ID = b.ID
   LEFT JOIN OtherDrugs_QuantityReceived c ON a.ID = c.ID
   LEFT JOIN OtherDispensed d ON a.ID = d.ID
   WHERE d.DispensedUnits > 0
     OR c.QuantityReceived > 0 ) A
ORDER BY ID',       -- qryDefinition - nvarchar(max)
    N'FCDRR_Consumption',       -- qryDescription - nvarchar(200)
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
(   N'FCDRR_Report',       -- sbCategory - nvarchar(50)
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
(   N'A9',       
    @QueryID,         
    N'#linelist',       
    NULL,      
    GETDATE(), 
    @CatID,         
    NULL,        
    NULL        
) 