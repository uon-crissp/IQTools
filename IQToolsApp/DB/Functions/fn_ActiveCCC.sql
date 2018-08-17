IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_ActiveCCC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_ActiveCCC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_ActiveCCC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_ActiveCCC](@ToDate datetime, @PatientPK int)
RETURNS int AS

BEGIN
Declare @ReturnValue as int = 0;
WITH CCCPatients AS
(Select a.PatientPK, a.LastVisit FROM tmp_PatientMaster a
Where RegistrationAtCCC <= CAST(@ToDate AS datetime)
AND a.PatientPK = @PatientPK)

, CareEndedPatients AS
(Select a.PatientPK FROM CCCPatients a INNER JOIN 
tmp_LastStatus b ON a.PatientPK = b.PatientPK 
WHere ExitDate <= CAST(@ToDate as datetime))

, MaybeActive AS
(Select a.PatientPK, a.LastVisit FROM CCCPatients a LEFT JOIN CareEndedPatients b
ON a.PatientPK = b.PatientPK WHERE b.PatientPK IS NULL)

, Appointments AS(
Select a.PatientPK, MAX(a.NextAppointmentDate) AppointmentDate 
FROM tmp_ClinicalEncounters a INNER JOIN(
Select PatientPK, MAX(VisitDate) LastVisit 
FROM tmp_ClinicalEncounters
Where VisitDate <= CAST(@ToDate as datetime) AND 
NextAppointmentDate IS NOT NULL AND PatientPK = @PatientPK
GROUP BY PatientPK) b ON a.PatientPK = b.PatientPK
AND a.VisitDate = b.LastVisit INNER JOIN MaybeActive c ON a.PatientPK = c.PatientPK
GROUP BY a.PatientPK)

, DrugCollections AS (
Select a.PatientPK, MAX(ExpectedReturn) DrugDate FROM tmp_Pharmacy a INNER JOIN
MaybeActive b ON a.PatientPK = b.PatientPK
Where TreatmentType IN (''ART'',''Prophylaxis'')
AND DispenseDate <= CAST(@ToDate as datetime)
GROUP BY a.PatientPK)

, MaxActive AS (
Select a.PatientPK, CAST(a.NextVisitDate AS Date) NextVisitDate 
, CAST(DATEADD(dd, 90, a.NextVisitDate) AS Date) MaxActiveDate
FROM 
(Select a.PatientPK,
CASE WHEN b.AppointmentDate >= c.DrugDate THEN b.AppointmentDate
WHEN c.DrugDate > b.AppointmentDate THEN c.DrugDate
ELSE a.LastVisit END AS NextVisitDate
 FROM 
MaybeActive a LEFT JOIN Appointments b ON a.PatientPK = b.PatientPK
LEFT JOIN DrugCollections c ON a.PatientPK = c.PatientPK) a)


Select @ReturnValue = 1 FROM MaxActive
Where MaxActiveDate >= CAST(@ToDate AS datetime)

RETURN @ReturnValue
END' 
END
GO
