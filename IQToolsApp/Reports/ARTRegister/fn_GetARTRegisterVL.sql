IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterVL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetARTRegisterVL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterVL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_GetARTRegisterVL](@PatientPK INT, @RegisterMonth INT, @StartARTDate date)
RETURNS INT
AS
BEGIN
	DECLARE @VLRESULT AS INT-- = 0

   SELECT @VLRESULT = MAX(VLResult) FROM IQC_AllVL a INNER JOIN (
SELECT MAX(VLOrderDate) VLDate FROM IQC_AllVL
	WHERE VLOrderDate BETWEEN DATEADD(MM, -5, DATEADD(MM, @RegisterMonth, @StartARTDate))
	AND DATEADD(MM, @RegisterMonth + 1, @StartARTDate)
	AND PatientPK = @PatientPK) b ON a.VLOrderDate = b.VLDate
WHERE a.PatientPK = @PatientPK


	RETURN @VLRESULT
END' 
END
GO