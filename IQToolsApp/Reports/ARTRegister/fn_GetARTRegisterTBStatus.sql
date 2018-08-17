IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterTBStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetARTRegisterTBStatus]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetARTRegisterTBStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_GetARTRegisterTBStatus](@PatientPK INT, @RegisterMonth INT, @StartARTDate date)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @TBStatus AS VARCHAR(10)

	select @TBStatus = MAX(''TB Rx'') from tmp_TBPatients
	where COALESCE(TBTreatmentStartDate, RegistrationAtTBClinic)
	BETWEEN DATEADD(MM, -6, DATEADD(MM, @RegisterMonth, @StartARTDate))
	AND DATEADD(MM, @RegisterMonth, @StartARTDate)
	AND PatientPK = @PatientPK

	RETURN @TBStatus
END' 
END
GO