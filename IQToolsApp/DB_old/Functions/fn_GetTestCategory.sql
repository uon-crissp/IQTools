IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetTestCategory]') 
AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetTestCategory]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create Function [dbo].[fn_GetTestCategory](@StartARTDate datetime, @ComparisonDate datetime)
Returns Int
As
Begin

Declare @TestCategory int
Set @TestCategory = FLOOR(CASE WHEN (DATEDIFF(dd, @StartARTDate, @ComparisonDate)%180)/180.0 > 0.67 
THEN ROUND(DATEDIFF(dd, @StartARTDate, @ComparisonDate)/180.0,0) 
WHEN (DATEDIFF(dd, @StartARTDate, @ComparisonDate)%180)/180.0 < 0.17 
Then FLOOR(DATEDIFF(dd, @StartARTDate, @ComparisonDate)/180) ELSE NULL END * 6)
Return @TestCategory
End
GO
