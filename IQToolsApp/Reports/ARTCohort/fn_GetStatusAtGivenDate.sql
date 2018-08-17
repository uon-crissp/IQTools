IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetStatusAtGivenDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fn_GetStatusAtGivenDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fn_GetStatusAtGivenDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE Function [dbo].[fn_GetStatusAtGivenDate](@PatientPK varchar(100), @date datetime, @StatusOrDate varchar(10))
returns varchar(100)
as 
Begin
Declare @Status as varchar(100)
Declare @EMR as varchar(10)
Select @EMR = PMMS From aa_Database
Set @Status = Null

If(@EMR = ''iqcare'' AND @date <= getdate())
Begin
	If(@StatusOrDate = ''status'')
		Begin
			Select @Status = 
			Case When a.ARTended = 1 AND a.ARTEndDate <= d.LastVisit   Then ''Stop'' Else c.Name End 
			From dtl_PatientCareEnded a Inner Join 
				(Select 
				a.Ptn_Pk	
				, Max (Coalesce(a.CareEndedDate, a.ARTEndDate)) ExitDate
				From dtl_PatientCareEnded a 
				Left Join dtl_patienttrackingcare b On a.ptn_pk = b.ptn_pk and a.trackingid = b.trackingid
				Where (b.ModuleID in(2,203) Or a.ARTEnded = 1) 
				And Coalesce(a.CareEndedDate, a.ARTEndDate) <= @date And
				(a.UpdateDate Is Null Or a.UpdateDate <= @date) And a.Ptn_Pk = @PatientPK
				Group By a.Ptn_Pk) 
			b On a.Ptn_pk = b.Ptn_pk And Coalesce(a.CareEndedDate, a.ARTEndDate) = b.ExitDate

			Left Join
			(Select PatientPK, Max(VisitDate) LastVisit 
			From tmp_ClinicalEncounters a 
			Where a.VisitDate <= @date
			Group By PatientPK) d
			On a.Ptn_Pk = d.PatientPK
	
			Left Join mst_Decode c On a.PatientExitReason = c.ID
			Where a.CareEndedDate >= d.LastVisit or a.ARTended = 1

			If (@Status Is Null)
			Begin
				Select @Status = Case 
				When DateDiff (dd,ER,@date) Between 30 and 90 Then ''Defaulter'' 
				When DateDiff(dd,ER,@date) > 90 Then ''LostND'' Else ''Active'' End 
				From (
				Select PatientPK, Max(ExpectedReturn)ER From tmp_Pharmacy 
				Where PatientPK = @patientPK And DispenseDate<@date 
				AND TreatmentType = ''ART''
				Group By PatientPK)a
			End
		END	
	Else If (@StatusOrDate = ''date'')
		Begin
			Select @Status = 
			Case When a.ARTended = 1 Then a.ARTEndDate Else a.CareEndedDate End 
			From dtl_PatientCareEnded a Inner Join 
				(Select 
				a.Ptn_Pk	
				, Max (Coalesce(a.CareEndedDate, a.ARTEndDate)) ExitDate
				From dtl_PatientCareEnded a 
				Left Join dtl_patienttrackingcare b On a.ptn_pk = b.ptn_pk and a.trackingid = b.trackingid
				Where (b.ModuleID in(2,203) Or a.ARTEnded = 1) 
				And Coalesce(a.CareEndedDate, a.ARTEndDate) <= @date And
				(a.UpdateDate Is Null Or a.UpdateDate <= @date) And a.Ptn_Pk = @PatientPK
				Group By a.Ptn_Pk) 
			b On a.Ptn_pk = b.Ptn_pk And Coalesce(a.CareEndedDate, a.ARTEndDate) = b.ExitDate

			Left Join
			(Select PatientPK, Max(VisitDate) LastVisit 
			From tmp_ClinicalEncounters a 
			Where a.VisitDate <= @date
			Group By PatientPK) d
			On a.Ptn_Pk = d.PatientPK
	
			Left Join mst_Decode c On a.PatientExitReason = c.ID
			Where a.CareEndedDate >= d.LastVisit

			If (@Status Is Null)
			Begin
				Select @Status = Case 
				When DateDiff (dd,ER,@date) Between 30 and 90 Then DateAdd(dd,30,ER)
				When DateDiff(dd,ER,@date) > 90 Then DateAdd(dd,91,ER) Else LastARTDate End 
				From (
				Select PatientPK, Max(ExpectedReturn)ER, Max(DispenseDate) LastARTDate 
				From tmp_Pharmacy 
				Where PatientPK = @patientPK And DispenseDate<@date 
				AND TreatmentType = ''ART''
				Group By PatientPK)a
			End

		End
	End
Else If(@EMR = ''ctc2'')
	Begin
		Select @Status = a.Status 
		From tblStatus a Inner Join
			(Select PatientID, Max(StatusDate)MaxStatusDate 
			From tblStatus Where StatusDate <= @date
			Group By PatientID) b On a.PatientID = b.PatientID And a.StatusDate = b.MaxStatusDate
		Where a.PatientID = @PatientPK
	End
Else
	Begin
		If(@StatusOrDate = ''status'')
			Select @Status = a.ExitReason From tmp_LastStatus a Where a.PatientPK = @PatientPK 
		Else If (@StatusOrDate = ''date'')
			Select @Status = a.ExitDate From tmp_LastStatus a Where a.PatientPK = @PatientPK 
	End

Set @Status = Case When @Status Like ''%Lost to%'' Then ''Lost''
					When @Status Like ''%Dea%'' Then ''Death''
					When @Status Like ''%Transfer%'' Then ''Transfer''
					When @Status Like ''%Stop%'' Then ''Stop''
					Else @Status End
Return @Status	
End

' 
END

GO