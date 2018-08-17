IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetAge]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetAge]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetAge]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_GetAge]
(
 @DOB DateTime, 
 @ToDate DateTime
) RETURNS INT AS
BEGIN
 DECLARE @Age int
 SET @Age = FLOOR(DateDiff(day, @DOB, @ToDate)/365.25)
 Return @Age
END' 
END

GO