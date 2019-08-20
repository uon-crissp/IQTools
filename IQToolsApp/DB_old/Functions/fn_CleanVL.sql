IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_CleanVL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_CleanVL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_CleanVL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



CREATE Function [dbo].[fn_CleanVL](@VL Varchar(100))
RETURNS VARCHAR(100) AS

BEGIN


SET  @VL = CASE WHEN  @VL LIKE ''%unde%'' THEN ''0'' ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%copies/ml%'' THEN REPLACE(@VL, ''copies/ml'','''') ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%>%'' THEN REPLACE(@VL, ''>'','''') ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%<%'' THEN REPLACE(@VL, ''<'','''') ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%.00'' THEN REPLACE(@VL, ''.00'','''') ELSE @VL END

SET  @VL = CASE WHEN  @VL LIKE ''%failed%'' THEN NULL ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%negative%'' THEN NULL ELSE @VL END
SET  @VL = CASE WHEN  @VL LIKE ''%positive%'' THEN NULL ELSE @VL END
SET  @VL = CASE WHEN  @VL = ''O'' THEN ''0'' ELSE @VL END

RETURN LTRIM(RTRIM(@VL))
END
' 
END
GO
