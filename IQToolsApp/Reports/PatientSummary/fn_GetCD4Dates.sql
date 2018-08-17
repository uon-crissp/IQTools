IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetCD4Dates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetCD4Dates]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetCD4Dates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fn_GetCD4Dates] (@PatientPK INT, @num INT)

RETURNS DATETIME

AS
BEGIN
	DECLARE @CD4Dates TABLE( Id  INT IDENTITY(1,1) PRIMARY KEY, CD4Date DATETIME)
	DECLARE @CD4Date DATETIME
	
	INSERT INTO @CD4Dates(CD4Date )
	SELECT DISTINCT TOP 10 ReportedbyDate FROM dbo.tmp_Labs
	WHERE TestName LIKE ''CD4%'' AND PatientPK = @PatientPK ORDER BY ReportedbyDate DESC
	
	SET @CD4Date = (SELECT TOP 1 CD4Date FROM @CD4Dates WHERE id = @num)
	
	RETURN @CD4Date
END
' 
END

GO