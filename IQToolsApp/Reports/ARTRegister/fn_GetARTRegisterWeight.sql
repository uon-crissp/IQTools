IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterWeight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetARTRegisterWeight]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterWeight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_GetARTRegisterWeight](@PatientPK INT, @WeightDate DATE)
RETURNS DECIMAL(18,1) AS
BEGIN
DECLARE @Weight AS DECIMAL(18,1)
	SELECT @Weight = MAX([Weight]) FROM tmp_ClinicalEncounters a INNER JOIN (
	Select MAX(VisitDate)LastVisit FROM tmp_ClinicalEncounters
	WHERE Weight IS NOT NULL AND PatientPK = @PatientPK
	AND VisitDate <= @WeightDate) b ON a.VisitDate = b.LastVisit
	WHERE a.PatientPK = @PatientPK AND a.[Weight] IS NOT NULL
RETURN @Weight
END' 
END
GO