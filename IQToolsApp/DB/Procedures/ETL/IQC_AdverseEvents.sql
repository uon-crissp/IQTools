IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'IQC_AdverseEvents') AND type='v')
DROP view IQC_AdverseEvents
GO

/****** Object:  View [dbo].[IQC_AdverseEvents]    Script Date: 10/9/2019 11:32:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW IQC_AdverseEvents
AS
select Distinct PatientID, PatientPK, SiteCode, null as VisitDate, null as Regimen, null as AdverseEvent, null as AdverseEventCause, null as Severity, null as ActionTaken, null as  
             ClinicalOutcome, null as AdverseEventEndDate, null as Pregnancy 
			 from tmp_PatientMaster
GO


