IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetNextVisitDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetNextVisitDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetNextVisitDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

create Function [dbo].[fn_GetNextVisitDate](@ToDate datetime, @PatientPK int)
RETURNS datetime AS

BEGIN
Declare @ReturnValue as datetime = null;

WITH CCCPatients AS
(Select a.PatientPK, a.LastVisit FROM tmp_PatientMaster a
Where coalesce(RegistrationAtCCC,registrationAtPMTCT) <= CAST(@ToDate AS datetime)
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
FROM tmp_PatientMaster a
INNER JOIN MaybeActive c ON a.PatientPK = c.PatientPK
GROUP BY a.PatientPK)

, DrugCollections AS (
Select a.PatientPK, MAX(ExpectedReturn) DrugDate FROM tmp_Pharmacy a INNER JOIN
MaybeActive b ON a.PatientPK = b.PatientPK
Where TreatmentType IN (''ART'',''Prophylaxis'',''PMTCT'')
AND DispenseDate <= CAST(@ToDate as datetime)
GROUP BY a.PatientPK)

, MaxActive AS (
Select a.PatientPK, CAST(a.NextVisitDate AS Date) NextVisitDate 
, CAST(DATEADD(dd, 31, a.NextVisitDate) AS Date) MaxActiveDate
FROM 
(Select a.PatientPK,
CASE WHEN isnull(b.AppointmentDate, ''01-Jan-1900'') >= c.DrugDate and isnull(b.AppointmentDate, ''01-Jan-1900'') >= a.LastVisit THEN b.AppointmentDate
WHEN c.DrugDate > isnull(b.AppointmentDate, ''01-Jan-1900'') and c.DrugDate > a.LastVisit THEN c.DrugDate
ELSE a.LastVisit END AS NextVisitDate
 FROM 
MaybeActive a LEFT JOIN Appointments b ON a.PatientPK = b.PatientPK
LEFT JOIN DrugCollections c ON a.PatientPK = c.PatientPK) a)

Select top 1 @ReturnValue = NextVisitDate FROM MaxActive order by NextVisitDate desc

RETURN @ReturnValue
END
' 
END
GO
