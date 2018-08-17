IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetVisitDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetVisitDates]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetVisitDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fn_GetVisitDates] (@PatientPK INT, @num INT)

RETURNS DATETIME

AS
BEGIN
	DECLARE @VisitDates TABLE( Id  INT IDENTITY(1,1) PRIMARY KEY, VisitDate DATETIME)
	DECLARE @VisitDate DATETIME
	
	INSERT INTO @VisitDates(VisitDate )
	SELECT DISTINCT TOP 3  VisitDate FROM dbo.tmp_ClinicalEncounters
	WHERE PatientPK = @PatientPK ORDER BY VisitDate DESC
	
	SET @VisitDate = (SELECT TOP 1 VisitDate FROM @VisitDates WHERE id = @num)
	
	RETURN @VisitDate
END
' 
END

GO