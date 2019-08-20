IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateTBPatientsMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreateTBPatientsMaster]
GO

CREATE Proc [dbo].[pr_CreateTBPatientsMaster]
AS

Begin

exec
('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_TBPatients'') AND type in (N''U''))
DROP TABLE tmp_TBPatients')

EXEC
	('
 if EXISTS (Select name From sys.synonyms Where name = ''DTL_FBCUSTOMFIELD_TB_Patient_Profile'')
  BEGIN
   if exists (Select * from sys.synonyms where name = ''dtl_PatientTBType'')
    begin
  		SELECT 
		DISTINCT
		a.PatientPK ,
			   a.PatientID ,
			   a.SiteCode ,
			   a.FacilityName ,
			   a.SatelliteName ,
			   a.Gender ,
			   d4.Name PatientSource ,
			   a.DOB ,
			   a.RegistrationAtTBClinic ,
			   d1.Name TBType ,
			   d2.Name DOTBy ,
			   Min(b.TreatmentDate) TBTreatmentStartDate ,
			   MIN(b.ARTStartDate) StartARTDate,
			   d3.Name TBRegimen ,
			   e.LastDispense LastTBDispenseDate ,
			   b.HIVTestDate ,
			   d7.Name HIVStatus ,
			   b.PartnerHIV_TestDate PartnerHIVTestDate ,
			   d8.Name PartnerHIVStatus ,
			   Max(d5.Name) PatientType ,
			   d6.Name ReferredTo ,
			   CASE
				   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
				   ELSE ''No''
			   END CareEnded ,
			   d.CareEndReason ,
			   d.CareEndDate		       
		INTO tmp_TBPatients		       
		FROM tmp_PatientMaster a
		INNER JOIN DTL_FBCUSTOMFIELD_TB_Patient_Profile b ON a.PatientPK = b.ptn_pk
		INNER JOIN mst_Patient m On a.PatientPK = m.Ptn_Pk
		LEFT JOIN dtl_PatientTBType c ON b.ptn_pk = c.ptn_pk
		LEFT JOIN
		  (SELECT a.Ptn_Pk,
				  a.[Patient CareEnd Reason]CareEndReason ,
				  a.[CareEndedDate]CareEndDate
		   FROM vw_patientCareEnd a
		   INNER JOIN mst_module b ON a.moduleID = b.ModuleID
		   WHERE b.ModuleName IN (''TB'',
								  ''TB Module'',
								  ''T B'')
			 AND a.CareEnded = 1) d ON b.ptn_pk = d.ptn_pk
		LEFT JOIN mst_ModDecode d1 ON c.TBType = d1.ID
		LEFT JOIN mst_ModDecode d2 ON c.DotBy = d2.ID
		LEFT JOIN mst_ModDecode d3 ON b.TBTreatment = d3.ID
		LEFT JOIN mst_ModDecode d4 ON b.TBReferredBy = d4.ID
		LEFT JOIN mst_ModDecode d5 ON b.TBPatientType = d5.ID
		LEFT JOIN mst_ModDecode d6 ON b.TBReferredTo = d6.ID
		LEFT JOIN mst_ModDecode d7 ON b.HIVTest = d7.ID
		LEFT JOIN mst_ModDecode d8 ON b.PartnerHIV_Test = d8.ID
		LEFT JOIN
		  (SELECT a.PatientPK,
				  Max(a.DispenseDate) LastDispense
		   FROM tmp_pharmacy a
		   Where a.TreatmentType = ''TB''
		   GROUP BY a.PatientPK) e ON b.ptn_pk = e.PatientPK
		Group BY 
		a.PatientPK ,
			   a.PatientID ,
			   m.DistrictRegistrationNr ,
			   a.SiteCode ,
			   a.FacilityName ,
			   a.SatelliteName ,
			   a.Gender ,
			   d4.Name ,
			   a.DOB ,
			   a.RegistrationAtTBClinic ,
			   d1.Name ,
			   d2.Name ,		       
			   d3.Name ,
			   e.LastDispense,
			   b.HIVTestDate ,
			   d7.Name  ,
			   b.PartnerHIV_TestDate  ,
			   d8.Name  ,
			   d6.Name  ,
			   CASE
				   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
				   ELSE ''No''
			   END  ,
			   d.CareEndReason ,
			   d.CareEndDate
		  end
		else
		  begin
			SELECT 
			DISTINCT
			a.PatientPK ,
				   a.PatientID ,
				   a.SiteCode ,
				   a.FacilityName ,
				   a.SatelliteName ,
				   a.Gender ,
				   d4.Name PatientSource ,
				   a.DOB ,
				   a.RegistrationAtTBClinic ,
				   '' TBType ,
				   '' DOTBy ,
				   Min(b.TreatmentDate) TBTreatmentStartDate ,
				   MIN(b.ARTStartDate) StartARTDate,
				   d3.Name TBRegimen ,
				   e.LastDispense LastTBDispenseDate ,
				   b.HIVTestDate ,
				   d7.Name HIVStatus ,
				   b.PartnerHIV_TestDate PartnerHIVTestDate ,
				   d8.Name PartnerHIVStatus ,
				   d5.Name PatientType ,
				   d6.Name ReferredTo ,
				   CASE
					   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
					   ELSE ''No''
				   END CareEnded ,
				   d.CareEndReason ,
				   d.CareEndDate			       
			INTO tmp_TBPatients			       
			FROM tmp_PatientMaster a
			INNER JOIN DTL_FBCUSTOMFIELD_TB_Patient_Profile b ON a.PatientPK = b.ptn_pk
			LEFT JOIN
			  (SELECT a.Ptn_Pk,
					  a.[Patient CareEnd Reason]CareEndReason ,
					  a.[CareEndedDate]CareEndDate
			   FROM vw_patientCareEnd a
			   INNER JOIN mst_module b ON a.moduleID = b.ModuleID
			   WHERE b.ModuleName IN (''TB'',
									  ''TB Module'',
									  ''T B'')
				 AND a.CareEnded = 1) d ON b.ptn_pk = d.ptn_pk
			LEFT JOIN mst_ModDecode d3 ON b.TBTreatment = d3.ID
			LEFT JOIN mst_ModDecode d4 ON b.TBReferredBy = d4.ID
			LEFT JOIN mst_ModDecode d5 ON b.TBPatientType = d5.ID
			LEFT JOIN mst_ModDecode d6 ON b.TBReferredTo = d6.ID
			LEFT JOIN mst_ModDecode d7 ON b.HIVTest = d7.ID
			LEFT JOIN mst_ModDecode d8 ON b.PartnerHIV_Test = d8.ID
			LEFT JOIN
			  (SELECT a.PatientPK,
					  Max(a.DispenseDate) LastDispense
			   FROM tmp_pharmacy a
			   Where a.TreatmentType = ''TB''
			   GROUP BY a.PatientPK) e ON b.ptn_pk = e.PatientPK
			Group BY 
			a.PatientPK ,
				   a.PatientID ,
				   a.SiteCode ,
				   a.FacilityName ,
				   a.SatelliteName ,
				   a.Gender ,
				   d4.Name ,
				   a.DOB ,
				   a.RegistrationAtTBClinic ,
				   d3.Name ,
				   e.LastDispense,
				   b.HIVTestDate ,
				   d7.Name  ,
				   b.PartnerHIV_TestDate  ,
				   d8.Name  ,
				   d5.Name  ,
				   d6.Name  ,
				   CASE
					   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
					   ELSE ''No''
				   END  ,
				   d.CareEndReason ,
				   d.CareEndDate
           end
	end

	ELSE 
	IF EXISTS (Select name From sys.synonyms Where name = ''DTL_FBCUSTOMFIELD_TB_Patient_Card'')
	BEGIN
	
			SELECT 
				DISTINCT
				a.PatientPK ,
					   a.PatientID ,
					   a.SiteCode ,
					   a.FacilityName ,
					   a.SatelliteName ,
					   a.Gender ,
					   NULL PatientSource ,
					   a.DOB ,
					   a.RegistrationAtTBClinic ,
					   d1.Name TBType ,
					   d2.Name DOTBy ,
					   Min(b.TreatmentDate) TBTreatmentStartDate ,
					   MIN(b.ARTStartDate) StartARTDate,
					   d3.Name TBRegimen ,
					   e.LastDispense LastTBDispenseDate ,
					   b.HIVTestDate ,
					   d7.Name HIVStatus ,
					   b.PartnerHIV_TestDate PartnerHIVTestDate ,
					   d8.Name PartnerHIVStatus ,
					   Max(d5.Name) PatientType ,
					   NULL ReferredTo ,
					   CASE
						   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
						   ELSE ''No''
					   END CareEnded ,
					   d.CareEndReason ,
					   d.CareEndDate
		       
				INTO tmp_TBPatients 
		       
				FROM tmp_PatientMaster a
				INNER JOIN DTL_FBCUSTOMFIELD_TB_Patient_Card b ON a.PatientPK = b.ptn_pk
				INNER JOIN mst_Patient m On a.PatientPK = m.Ptn_Pk
				LEFT JOIN dtl_PatientTBType c ON b.ptn_pk = c.ptn_pk
				LEFT JOIN
				  (SELECT a.Ptn_Pk,
						  a.[Patient CareEnd Reason]CareEndReason ,
						  a.[CareEndedDate]CareEndDate
				   FROM vw_patientCareEnd a
				   INNER JOIN mst_module b ON a.moduleID = b.ModuleID
				   WHERE b.ModuleName IN (''TB'',
										  ''TB Module'',
										  ''T B'',''TB Clinic Module'')
					 AND a.CareEnded = 1) d ON b.ptn_pk = d.ptn_pk
				LEFT JOIN mst_ModDecode d1 ON c.TBType = d1.ID
				LEFT JOIN mst_ModDecode d2 ON c.DotBy = d2.ID
				LEFT JOIN mst_ModDecode d3 ON b.TBTreatment = d3.ID
				
				LEFT JOIN mst_ModDecode d5 ON b.TBPatientType = d5.ID
				LEFT JOIN mst_ModDecode d7 ON b.HIVTest = d7.ID
				LEFT JOIN mst_ModDecode d8 ON b.PartnerHIV_Test = d8.ID
				LEFT JOIN
				  (SELECT a.PatientPK,
						  Max(a.DispenseDate) LastDispense
				   FROM tmp_pharmacy a
				   Where a.TreatmentType = ''TB''
				   GROUP BY a.PatientPK) e ON b.ptn_pk = e.PatientPK
				Group BY 
						a.PatientPK ,
					   a.PatientID ,
					   m.DistrictRegistrationNr ,
					   a.SiteCode ,
					   a.FacilityName ,
					   a.SatelliteName ,
					   a.Gender ,
					   a.DOB ,
					   a.RegistrationAtTBClinic ,
					   d1.Name ,
					   d2.Name ,		       
					   d3.Name ,
					   e.LastDispense,
					   b.HIVTestDate ,
					   d7.Name  ,
					   b.PartnerHIV_TestDate  ,
					   d8.Name  ,
					   CASE
						   WHEN d.Ptn_pk IS NOT NULL THEN ''Yes''
						   ELSE ''No''
					   END  ,
					   d.CareEndReason ,
					   d.CareEndDate

	END



	ELSE
	CREATE TABLE [dbo].[tmp_TBPatients](
	[PatientPK] [int] NOT NULL,
	[PatientID] [varchar](43)  NULL,
	[SiteCode] [varchar](10)  NULL,
	[FacilityName] [varchar](50)  NULL,
	[SatelliteName] [varchar](50)  NULL,
	[Gender] [varchar](250)  NULL,
	[PatientSource] [varchar](250)  NULL,
	[DOB] [datetime] NOT NULL,
	[RegistrationAtTBClinic] [date] NULL,
	[TBType] [varchar](250)  NULL,
	[DOTBy] [varchar](250)  NULL,
	[TBTreatmentStartDate] [date] NULL,
	[StartARTDate] date NULL,
	[TBRegimen] [varchar](250)  NULL,
	[LastTBDispenseDate] [datetime] NULL,
	[HIVTestDate] [datetime] NULL,
	[HIVStatus] [varchar](250)  NULL,
	[PartnerHIVTestDate] [datetime] NULL,
	[PartnerHIVStatus] [varchar](250)  NULL,
	[PatientType] [varchar](250)  NULL,
	[ReferredTo] [varchar](250)  NULL,
	[CareEnded] [varchar](3)  NOT NULL,
	[CareEndReason] [varchar](250)  NULL,
	[CareEndDate] [datetime] null
	) ON [PRIMARY]    

')

Exec('
CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_TBPatients] ([PatientPK] ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ')

End

GO