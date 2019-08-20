IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_FindHEI]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_FindHEI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_FindHEI]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_FindHEI](@MothersPatientPK int)
RETURNS int AS

BEGIN
Declare @HEIPK as INT;
	SELECT @HEIPK = PatientPK FROM (
	SELECT TOP 1 PatientPK FROM (
	select c.PatientPK from dtl_FamilyInfo a 
	inner join tmp_HEI c ON a.referenceid = c.patientpk
	where a.ptn_pk = @MothersPatientPK
	UNION
	select b.PatientPK from dtl_FamilyInfo a
	inner join tmp_HEI b ON a.ptn_pk = b.PatientPK
	where a.referenceid = @MothersPatientPK) a) a
	RETURN @HEIPK
END' 
END

GO