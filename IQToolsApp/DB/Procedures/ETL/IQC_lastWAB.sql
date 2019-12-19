IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'IQC_lastWAB') AND type='v')
DROP view IQC_lastWAB
GO
/****** Object:  View [dbo].[IQC_lastWAB]    Script Date: 10/9/2019 11:55:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[IQC_lastWAB] as 
WITH IQC_allWAB AS
(Select Distinct a.PatientPK, m.FacilityID
, Case When a.WABStage In ('Working','W') Then 1      
When a.WABStage In ('Ambulatory','A') 
Then 2 When a.WABStage In ('Bedridden','B') Then 3    
End As WABStage, a.VisitDate WABDate
, Case      When DateDiff(dd, m.registrationDate, a.VisitDate) <= 90 Then 1 Else 0    
End As enrollmentTest, Case      When DateDiff(dd, c.startARTDate, a.VisitDate) 
Between -90 And 14 Then 1      Else 0 End As baselineTest  
From TMP_ClinicalEncounters a 
Inner Join    tmp_patientmaster m On a.PatientPK = m.PatientPK 
Left Join    tmp_ARTPatients c On a.PatientPK = c.PatientPK  
Where a.WABStage Is Not Null)

Select e.PatientPK,e.FacilityID, Max(e.WABStage) lastWAB, e2.wabDate lastWABDate
From IQC_allWAB e Inner Join
  (Select IQC_allWAB.PatientPK, Max(IQC_allWAB.WABDate) wabDate
    From IQC_allWAB
   
    Group By IQC_allWAB.PatientPK) e2 On e.PatientPK = e2.PatientPK And
    e.WABDate = e2.wabDate
Group By e.PatientPK,e.FacilityID, e2.wabDate
GO


