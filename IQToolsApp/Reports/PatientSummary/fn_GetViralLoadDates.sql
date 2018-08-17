IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetViralLoadDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetViralLoadDates]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetViralLoadDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fn_GetViralLoadDates] (@PatientPK INT, @num INT)

RETURNS DATETIME

AS
BEGIN
	DECLARE @VLDates TABLE( Id  INT IDENTITY(1,1) PRIMARY KEY, VLDate DATETIME)
	DECLARE @VLDate DATETIME
	
	INSERT INTO @VLDates(VLDate )
	SELECT DISTINCT TOP 10 ReportedbyDate FROM dbo.tmp_Labs
	WHERE TestName LIKE ''%viral%'' AND PatientPK = @PatientPK ORDER BY ReportedbyDate DESC
	
	SET @VLDate = (SELECT TOP 1 VLDate FROM @VLDates WHERE id = @num)
	
	RETURN @VLDate
END
' 
END

GO