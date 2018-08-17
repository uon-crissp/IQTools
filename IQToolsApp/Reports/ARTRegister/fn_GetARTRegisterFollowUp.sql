IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterFollowUp]') 
AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetARTRegisterFollowUp]
GO

CREATE FUNCTION [dbo].[fn_GetARTRegisterFollowUp](@PatientPK int, @ReferenceDate date)  
RETURNS VARCHAR(100) AS  
BEGIN  
Declare @Regimen as VARCHAR(100) = '', @LastStatus as VARCHAR(100);  

WITH Codes AS (SELECT 'AF4B' RCode, '3TC+ABC+EFV' RName, 'Adult' AgeGroup UNION 
SELECT 'AF4A' RCode, '3TC+ABC+NVP' RName, 'Adult' AgeGroup UNION 
SELECT 'AF1B' RCode, '3TC+AZT+EFV' RName, 'Adult' AgeGroup UNION 
SELECT 'AF1A' RCode, '3TC+AZT+NVP' RName, 'Adult' AgeGroup UNION 
SELECT 'AF3B' RCode, '3TC+D4T+EFV' RName, 'Adult' AgeGroup UNION 
SELECT 'AF3A' RCode, '3TC+D4T+NVP' RName, 'Adult' AgeGroup UNION 
SELECT 'AF2B' RCode, '3TC+EFV+TDF' RName, 'Adult' AgeGroup UNION 
SELECT 'AF2A' RCode, '3TC+NVP+TDF' RName, 'Adult' AgeGroup UNION 
SELECT 'AF5X' RCode, 'other Adult 1st line' RName, 'Adult' AgeGroup UNION 
SELECT 'AS5B' RCode, '3TC+ABC+ATV/r' RName, 'Adult' AgeGroup UNION 
SELECT 'AS5A' RCode, '3TC+ABC+LPV/r' RName, 'Adult' AgeGroup UNION 
SELECT 'AS1B' RCode, '3TC+ATV/r+AZT' RName, 'Adult' AgeGroup UNION 
SELECT 'AS1A' RCode, '3TC+AZT+LPV/r' RName, 'Adult' AgeGroup UNION 
SELECT 'AS2C' RCode, '3TC+ATV/r+TDF' RName, 'Adult' AgeGroup UNION 
SELECT 'AS2A' RCode, '3TC+LPV/r+TDF' RName, 'Adult' AgeGroup UNION 
SELECT 'AS6X' RCode, 'other Adult 2nd line' RName, 'Adult' AgeGroup UNION 
SELECT 'AT2A' RCode, '3TC+DRV+ETV+RTV' RName, 'Adult' AgeGroup UNION 
SELECT 'AT1A' RCode, '3TC+DRV+RAL+RTV' RName, 'Adult' AgeGroup UNION 
SELECT 'AT1B' RCode, '3TC+AZT+DRV+RAL+RTV' RName, 'Adult' AgeGroup UNION 
SELECT 'AT1C' RCode, '3TC+DRV+RAL+RTV+TDF' RName, 'Adult' AgeGroup UNION 
SELECT 'AT2X' RCode, 'other Adult 3rd line' RName, 'Adult' AgeGroup UNION 
SELECT 'CF2E' RCode, '3TC+ABC+ATV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CF2B' RCode, '3TC+ABC+EFV' RName, 'Child' AgeGroup UNION 
SELECT 'CF2D' RCode, '3TC+ABC+LPV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CF2A' RCode, '3TC+ABC+NVP' RName, 'Child' AgeGroup UNION 
SELECT 'CF1D' RCode, '3TC+ATV/r+AZT' RName, 'Child' AgeGroup UNION 
SELECT 'CF1B' RCode, '3TC+AZT+EFV' RName, 'Child' AgeGroup UNION 
SELECT 'CF1C' RCode, '3TC+AZT+LPV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CF1A' RCode, '3TC+AZT+NVP' RName, 'Child' AgeGroup UNION 
SELECT 'CF3B' RCode, '3TC+D4T+EFV' RName, 'Child' AgeGroup UNION 
SELECT 'CF3A' RCode, '3TC+D4T+NVP' RName, 'Child' AgeGroup UNION 
SELECT 'CF4D' RCode, '3TC+ATV/r+TDF' RName, 'Child' AgeGroup UNION 
SELECT 'CF4B' RCode, '3TC+EFV+TDF' RName, 'Child' AgeGroup UNION 
SELECT 'CF4C' RCode, '3TC+LPV/r+TDF' RName, 'Child' AgeGroup UNION 
SELECT 'CF4A' RCode, '3TC+NVP+TDF' RName, 'Child' AgeGroup UNION 
SELECT 'CF5X' RCode, 'other Paediatric 1st line' RName, 'Child' AgeGroup UNION 
SELECT 'CS2C' RCode, '3TC+ABC+ATV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CS2A' RCode, '3TC+ABC+LPV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CS1B' RCode, '3TC+ATV/r+AZT' RName, 'Child' AgeGroup UNION 
SELECT 'CS1A' RCode, '3TC+AZT+LPV/r' RName, 'Child' AgeGroup UNION 
SELECT 'CS4X' RCode, 'other Paediatric 2nd line' RName, 'Child' AgeGroup UNION 
SELECT 'CT2A' RCode, '3TC+DRV+ETV+RTV' RName, 'Child' AgeGroup UNION 
SELECT 'CT1A' RCode, '3TC+DRV+RAL+RTV' RName, 'Child' AgeGroup UNION 
SELECT 'CT1C' RCode, '3TC+DRV+RAL+RTV + ABC' RName, 'Child' AgeGroup UNION 
SELECT 'CT1B' RCode, '3TC+AZT+DRV+RAL+RTV' RName, 'Child' AgeGroup UNION 
SELECT 'CT3X' RCode, 'other Paediatric 3rd line' RName, 'Child' AgeGroup)

  
Select @Regimen = MAX(b.RCode)  
FROM (  
Select c.PatientPK  
, COALESCE(MAX(Drug),MAX(c.StartRegimen)) Regimen   
, CASE WHEN (DATEDIFF(dd, MAX(c.DOB), COALESCE(MIN(a.DispenseDate),MAX(c.StartARTDate)))/365.25) >= 15.0 THEN 3 ELSE 6 END AS L  
, CASE WHEN (DATEDIFF(dd, MAX(c.DOB), COALESCE(MIN(a.DispenseDate),MAX(c.StartARTDate)))/365.25) >= 15.0 THEN 5 ELSE 8 END AS U  
, MAX(CASE WHEN c.AgeLastVisit < 15 THEN 'Child' ELSE 'Adult' END) AS AgeGroup
FROM tmp_ARTPatients c INNER JOIN   
(Select PatientPK  
 , DispenseDate   
 , Drug  
 FROM tmp_Pharmacy   
 WHERE TreatmentType = 'ART' AND PatientPK =  @PatientPK) a ON c.PatientPK = a.PatientPK   
LEFT JOIN  
 (Select PatientPK  
 , MIN(DispenseDate) DispenseDate   
 FROM tmp_Pharmacy  
 Where ExpectedReturn >= @ReferenceDate  
 AND DispenseDate <= @ReferenceDate  
 AND PatientPK =  @PatientPK  
 AND TreatmentType = 'ART'  
 GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK AND a.DispenseDate = b.DispenseDate   
 WHERE @ReferenceDate <= c.ExpectedReturn  
GROUP BY c.PatientPK  
) a INNER JOIN Codes b ON a.Regimen = b.RName 
AND a.AgeGroup = b.AgeGroup
  
Select @LastStatus = CASE ExitReason WHEN 'Transfer'  
THEN 'TO' WHEN 'Death' THEN 'DEAD' WHEN 'Lost' THEN 'LOST' ELSE NULL END   
FROM tmp_ARTPatients  
Where ExitDate BETWEEN DATEADD(MM, -1, @ReferenceDate) AND @ReferenceDate AND PatientPK =  @PatientPK  
  
RETURN COALESCE(@LastStatus, @Regimen)  
  
END  