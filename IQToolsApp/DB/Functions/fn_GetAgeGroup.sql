IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetAgeGroup]') 
AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetAgeGroup]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetAgeGroup]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fn_GetAgeGroup]
( @Age decimal(18,2), @Type varchar(10))

RETURNS varchar(10) AS

BEGIN
 DECLARE @AgeGroup varchar(10)
 IF(@Type=''MOH731'')

 BEGIN

  SET @AgeGroup =
  CASE
  WHEN @Age Between 0.0 And 0.9 Then ''<1''
   WHEN @Age Between 1.0 And 9.9 Then ''1-9''
   WHEN @Age Between 10.0 And 14.9 Then ''10-14''
   WHEN @Age Between 15.0 And 19.9 Then ''15-19''
   WHEN @Age Between 20.0 And 24.9 Then ''20-24''
   WHEN @Age >=25.0 Then ''25+''
  END

 END
 IF(@Type=''PEPFAR'')
 BEGIN
  SET @AgeGroup =
  CASE
  WHEN @Age Between 0.0 And 1.9 Then ''0-1''
   WHEN @Age Between 2.0 And 4.9 Then ''2-4''
   WHEN @Age Between 5.0 And 14.9 Then ''5-14''
   WHEN @Age >= 15.0 Then ''Adult''
  END
 END 

 IF(@Type=''COARSE'')
 BEGIN
  SET @AgeGroup =
  CASE
  WHEN @Age Between 0.0 And 14.9 Then ''<15''  
  WHEN @Age >= 15.0 Then ''15+''
  END
 END 

 IF(@Type=''CDCTrack1'')
 BEGIN
  SET @AgeGroup =
  CASE
  WHEN @Age Between 0.0 And 1.9 Then ''0-1''
  WHEN @Age Between 2.0 And 4.9 Then ''2-4''
  WHEN @Age Between 5.0 And 14.9 Then ''5-14''  
  WHEN @Age >= 15.0 Then ''15+''
  END
 END 

 IF(@Type=''DATIM'')
BEGIN
	SET @AgeGroup =
		CASE
		WHEN @Age Between 0.0 And 0.9 Then ''<1''
		WHEN @Age Between 1.0 And 4.9 Then ''01-04''
		WHEN @Age Between 5.0 And 9.9 Then ''05-09''
		WHEN @Age Between 10.0 And 14.9 Then ''10-14''
		WHEN @Age Between 15.0 And 19.9 Then ''15-19''
		WHEN @Age Between 20.0 And 24.9 Then ''20-24''
		WHEN @Age Between 25.0 And 29.9 Then ''25-29''
		WHEN @Age Between 30.0 And 34.9 Then ''30-34''
		WHEN @Age Between 35.0 And 39.9 Then ''35-39''
		WHEN @Age Between 40.0 And 44.9 Then ''40-44''
		WHEN @Age Between 45.0 And 49.9 Then ''45-49''
		WHEN @Age >=50.0 Then ''50+''
		END
END

RETURN @AgeGroup

END' 
END
GO
