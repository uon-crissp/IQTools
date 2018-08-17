IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetRegimenAtMonthX]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetRegimenAtMonthX]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetRegimenAtMonthX]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE Function [dbo].[fn_GetRegimenAtMonthX](@PatientPK varchar(100), @Month int)
Returns varchar(100) As
Begin
Declare @Regimen As Varchar(100)
Declare @Termination As Varchar(100);

--With CleanART As (
--Select 
--PatientPK
--,VisitID
--, Regimen 
--, DispenseDate
--, ExpectedReturn
--, RegimenLine
--From (
--Select  
--PatientPK
--,VisitID
--, replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') as Regimen 
--, DispenseDate
--, ExpectedReturn
--, RegimenLine
 
--From tmp_Pharmacy Where TreatmentType = ''ART''
--and len(replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') ) between 11 and 12) a
--Where SUBSTRING(Regimen,0,4)!= SUBSTRING(Regimen,5,3)
--and SUBSTRING(Regimen,0,4) != SUBSTRING(Regimen,9,3)
--and SUBSTRING(Regimen,5,3) != SUBSTRING(Regimen,9,3)
--)

--Select @Regimen = Max(a.Regimen)
--From CleanART a Inner Join tmp_ARTPatients b On a.PatientPK = b.PatientPK 
--Where  
--a.PatientPK = @PatientPK
--And DateDiff(mm,  b.StartARTDate, a.DispenseDate) = @Month

if @Month = 0
Begin 
With CleanART As (
Select 
PatientPK
,VisitID
, Regimen 
, DispenseDate
, ExpectedReturn
, RegimenLine
From (
Select  
PatientPK
,VisitID
, replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') as Regimen 
, DispenseDate
, ExpectedReturn
, RegimenLine
 
From tmp_Pharmacy Where TreatmentType = ''ART''
and len(replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') ) between 11 and 12) a
Where SUBSTRING(Regimen,0,4)!= SUBSTRING(Regimen,5,3)
and SUBSTRING(Regimen,0,4) != SUBSTRING(Regimen,9,3)
and SUBSTRING(Regimen,5,3) != SUBSTRING(Regimen,9,3)
)
Select @Regimen =  a.Regimen From CleanART a Inner Join
(Select PatientPK, MIN(DispenseDate) FirstDispense 
From CleanART Where PatientPK = @PatientPK
Group By PatientPK) b on a.PatientPK = b.PatientPK and a.DispenseDate = b.FirstDispense
End

Else
Begin
With CleanART As (
Select 
PatientPK
,VisitID
, Regimen 
, DispenseDate
, ExpectedReturn
, RegimenLine
From (
Select  
PatientPK
,VisitID
, replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') as Regimen 
, DispenseDate
, ExpectedReturn
, RegimenLine
 
From tmp_Pharmacy Where TreatmentType = ''ART''
and len(replace(replace(replace(replace(replace(Drug,''30'',''''),''40'',''''),''20'',''''),''15'',''''),''1m'','''') ) between 11 and 12) a
Where SUBSTRING(Regimen,0,4)!= SUBSTRING(Regimen,5,3)
and SUBSTRING(Regimen,0,4) != SUBSTRING(Regimen,9,3)
and SUBSTRING(Regimen,5,3) != SUBSTRING(Regimen,9,3)
)
Select @Regimen = Max(a.Regimen) From CleanART a Inner Join
(Select a.PatientPK, Max(a.DispenseDate) LD 
From CleanART a Inner Join tmp_ARTPatients b On a.PatientPK = b.PatientPK  
Where a.PatientPK = @PatientPK And  DateDiff(mm,  b.StartARTDate, a.DispenseDate) Between @Month - 3 And @Month
Group By a.PatientPK) b On a.PatientPK = b.PatientPK And a.DispenseDate = b.LD

--Select @Termination = ExitReason
--From tmp_ARTPatients a
--Where 
--DateDiff(mm,  a.StartARTDate, a.ExitDate) = @Month And a.PatientPK = @PatientPK
End
Return Coalesce(@Termination,@Regimen)


End' 
END

GO