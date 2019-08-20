IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetQuarterEnd]') 
AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetQuarterEnd]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetQuarterEnd](@ReferenceDate datetime, @Quarter int)
returns datetime
AS
BEGIN

RETURN DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, @ReferenceDate)+@Quarter, 0))

END
GO