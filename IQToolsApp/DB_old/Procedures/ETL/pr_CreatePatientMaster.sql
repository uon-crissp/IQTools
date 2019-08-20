IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePatientMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreatePatientMaster]
GO

CREATE Proc [dbo].[pr_CreatePatientMaster] WITH ENCRYPTION
AS
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tmp_PatientMaster') AND type in (N'U'))
	DROP TABLE tmp_PatientMaster;
	
	CREATE TABLE tmp_PatientMaster
	(PatientPK INT NOT NULL
	, PatientID VARCHAR(1000) NULL
	, FacilityID INT NOT NULL
	, SiteCode VARCHAR(1000) NULL
	, FacilityName VARCHAR(1000) NULL
	, SatelliteName VARCHAR(1000) NULL
	, Gender VARCHAR(10) NULL
	, DOB DATE NULL
	, RegistrationDate DATE NULL
	, RegistrationAtCCC DATE NULL
	, RegistrationAtPMTCT DATE NULL
	, RegistrationAtTBClinic DATE NULL
	, PatientName VARCHAR(1000) NULL
	, PatientSource VARCHAR(1000) NULL
	, Village VARCHAR(1000) NULL
	, [Address] VARCHAR(1000) NULL
	, PhoneNumber VARCHAR(1000) NULL
	, ContactName VARCHAR(1000) NULL
	, ContactRelation VARCHAR(1000) NULL
	, ContactPhoneNumber VARCHAR(1000) NULL
	, ContactAddress VARCHAR(1000) NULL
	, LastVisit DATE NULL
	, AgeCurrent DECIMAL(18,1) NULL
	, AgeEnrollment DECIMAL(18,1) NULL
	, AgeLastVisit DECIMAL(18,1) NULL
	, MaritalStatus VARCHAR(1000) NULL
	, EducationLevel VARCHAR(1000) NULL
	, HIVTestDate DATE NULL
	, PreviousARTExposure VARCHAR(1000) NULL
	, PreviousARTStartDate DATE NULL
	, SMSConsented VARCHAR(10) NULL
	, ServiceArea varchar(100) NULL
	, NextAppointmentDate datetime NULL);

	IF EXISTS(SELECT name FROM sys.tables WHERE name = N'x_SMSConsent')
	DROP TABLE x_SMSConsent;
	
	CREATE TABLE x_SMSConsent(PatientPK INT NOT NULL);

	BEGIN TRY 
		EXEC('INSERT INTO x_SMSConsent 
		SELECT DISTINCT Ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration
		WHERE SMSConsented = 1')
	END TRY
	BEGIN CATCH
		
	END CATCH

	IF EXISTS(Select Name FROM sys.tables WHERE Name = N'tempIE')
	DROP TABLE tempIE;
	Create TABLE tempIE(Ptn_Pk int null, DateConfirmedHIVPositive datetime Null
							, StartARTDate datetime null, StartRegimen VARCHAR(1000) null);

	IF EXISTS(Select Name FROM sys.synonyms Where Name = N'DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form')
	BEGIN
	EXEC('	
		WITH PreviousART_a AS (
		Select a.Ptn_pk, a.ARTStartDate, b.PreviousRegimen, b.PreviousRegimenDate 
		FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form a 
		LEFT JOIN [DTL_CUSTOMFORM_Prior ART_01_Initial_Evaluation_Form] b ON a.Ptn_Pk = b.Ptn_Pk
		LEFT JOIN ord_Visit c ON a.Visit_Pk = c.Visit_Id AND a.Ptn_pk = c.Ptn_Pk
		Where (c.DeleteFlag IS NULL OR c.DeleteFlag = 0))

		, PreviousART_b AS (
		Select a.Ptn_pk, MIN(PreviousRegimen) StartRegimen, COALESCE(MIN(a.ARTStartDate), MIN(PreviousRegimenDate)) StartARTDate 
		FROM PreviousART_a a INNER JOIN (
		Select Ptn_pk, MIN(PreviousRegimenDate) StartART FROM PreviousART_a
		GROUP BY Ptn_pk) b ON a.Ptn_pk = b.Ptn_pk AND a.PreviousRegimenDate = b.StartART
		GROUP BY a.Ptn_pk) 

		, HIVTesting AS (Select Ptn_Pk, max(HIVTestDate) as HIVTestDate FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form
		WHERE HIVTestDate IS NOT NULL AND HIVTestDate <> Cast('''' AS Datetime)
		group by Ptn_Pk)
	
		INSERT INTO tempIE 
		SELECT a.Ptn_pk, b.HIVTestDate, c.StartARTDate, c.StartRegimen 
		FROM DTL_FBCUSTOMFIELD_01_Initial_Evaluation_Form a
		LEFT JOIN HIVTesting b ON a.Ptn_Pk = b.Ptn_Pk
		LEFT JOIN PreviousART_b c ON a.Ptn_Pk = c.Ptn_Pk
		Where COALESCE(b.Ptn_Pk, c.Ptn_Pk) IS NOT NULL
	')
	END
	
	EXEC('	
	WITH HIVTesting AS (Select a.ptn_pk, Max(HIVDate)HIVTestDate From 
			(Select a.ptn_pk, a.ConfirmHIVPosDate HIVDate
			From dtl_PatientHivPrevCareEnrollment a  
			Where a.ConfirmHIVPosDate Is Not Null And a.ConfirmHIVPosDate <> Cast('''' as datetime)
			union
			Select a.ptn_pk, a.DateHIVDiagnosis
			From dtl_PatientClinicalStatus a 
			Where a.DateHIVDiagnosis Is Not Null And a.DateHIVDiagnosis <> Cast('''' as datetime)) a group by a.ptn_pk)
	
	, PreviousART AS (SELECT A.Ptn_Pk,
					MIN(A.prevARTStartDate) StartARTDate,
					MAX(A.prevRegimen) StartRegimen
					FROM
					(SELECT ptn_pk,
					MIN([Previous ART StartDate]) prevARTStartDate ,
					MAX([Previous ART Regimen]) prevRegimen
					FROM vw_patientdetail
					WHERE [Previous ART StartDate] > CAST('''' AS datetime)
					GROUP BY ptn_pk
					UNION SELECT a.ptn_pk,
					MIN(a.ARTStartDate) ARTStartDate,
					MAX(b.regimen) Regimen
					FROM dtl_patientHivPrevCareEnrollment a
					LEFT JOIN dtl_patientBlueCardPriorART b ON a.visit_pk = b.visit_pk
					WHERE a.ARTStartDate > CAST('''' AS datetime)
					GROUP BY a.ptn_pk) A	GROUP BY A.Ptn_Pk)	
	
	INSERT INTO tempIE
	SELECT a.Ptn_pk, MIN(b.HIVTestDate) HIVTestDate, MIN(c.StartARTDate) StartARTDate
	, MAX(c.StartRegimen) StartRegimen
		FROM mst_Patient a
		LEFT JOIN HIVTesting b ON a.Ptn_Pk = b.Ptn_Pk
		LEFT JOIN PreviousART c ON a.Ptn_Pk = c.Ptn_Pk
		Where COALESCE(b.Ptn_Pk, c.Ptn_Pk) IS NOT NULL
	GROUP BY a.Ptn_Pk
	union
	select distinct a.ptn_pk, null, b.FirstLineRegStDate, d.RegimenCode+'' - ''+d.RegimenName as Regimen
	from mst_patient a
	inner join dtl_patientARTCare b on a.ptn_pk=b.ptn_pk and a.TransferIn=1
	left join mst_Regimen d on b.FirstLineReg=d.RegimenID
	where len(FirstLineReg)>0 and d.RegimenName is not null
	')
	
	EXEC('
	   Declare @allIDs as varchar(max)
		Select @allIDs = stuff((select '',Case When Cast(m.['' + cast(fieldName as VARCHAR(1000))+ ''] as varchar(50)) = '''''''' Then Null Else  Cast(m.['' + cast(fieldName as VARCHAR(1000))+ ''] as varchar(50)) End ''  
		from mst_patientidentifier for xml PATH('''')),1,1,'''')
		
		EXEC(''INSERT INTO tmp_PatientMaster 
		select DISTINCT d.ptn_pk PatientPK
		, Cast(coalesce(''+@allIDs+'') as varchar(50)) PatientID
		, d.locationID FacilityID
		, Case WHEN LEN(d.SatelliteID) <= 3 THEN CAST(d.CountryID+d.PosID AS VARCHAR(10)) ELSE
		cast(d.SatelliteID as varchar(10)) END AS SiteCode
		, l.FacilityName 
		, d.FacilityName SatelliteName
		, d.Gender
		, d.DOB
		, m.[RegistrationDate] RegistrationDate
		, regCCC.RegistrationAtCCC
		, regPMTCT.RegistrationAtPMTCT
		, regTB.RegistrationAtTBClinic

		, m.dFirstName + '''' '''' + m.dMiddleName + '''' '''' + m.dLastName PatientName 
		, Case When d.TransferIn = 1 OR 
		(t.ARTTransferInDate > CAST('''''''' as datetime) 
		AND t.ARTTransferInDate <= regCCC.RegistrationAtCCC) 
		then ''''Transfer In'''' else d2.Name end as PatientSource
		, d.Village
		, Case When m.dAddress = '''''''' Then NULL Else  m.dAddress End As Address
		, Case WHen m.dPhone = '''''''' Then NULL Else m.dPhone End As PhoneNumber
		, CASE WHEN c.EmergContactName = '''''''' THEN NULL ELSE c.EmergContactName END ContactName
		, d1.Name ContactRelation
		, Case When c.EmergContactPhone = '''''''' Then Null Else c.EmergContactPhone End As ContactPhoneNumber
		, Case When c.EmergContactAddress = '''''''' Then Null Else c.EmergContactAddress End As ContactAddress
		, lV.LastVisit
		, Cast((DateDiff(day, d.DOB, GETDATE()) / 365.25) as decimal(5,1))AgeCurrent
		, Cast((DateDiff(day, d.DOB, m.[RegistrationDate]) / 365.25) as decimal(5,1)) AgeEnrollment
		, Cast((DateDiff(day, d.DOB, lV.lastVisit) / 365.25) as decimal(5,1))  AgeLastVisit
			, d4.Name MaritalStatus
		, d3.Name EducationLevel	
		, (select top 1 z.DateConfirmedHIVPositive from tempIE z where z.ptn_pk=d.ptn_pk and z.DateConfirmedHIVPositive is not null) as DateConfirmedHIVPositive
		, (select top 1 z.StartRegimen from tempIE z where z.ptn_pk=d.ptn_pk and z.StartRegimen is not null) PreviousARTExposure
		, (select top 1 z.StartARTDate from tempIE z where z.ptn_pk=d.ptn_pk and z.StartARTDate is not null) PreviousARTStartDate		
		, CASE WHEN aa.PatientPK IS NOT NULL THEN ''''YES'''' ELSE NULL END AS SMSConsented
		, (select top 1 x.ModuleName from mst_module x where x.moduleid=d.ModuleId) as ServiceArea	
		, (select top 1 x.appdate from dtl_PatientAppointment x where x.Ptn_pk=m.ptn_pk order by x.appdate desc) as NextAppointmentDate

		from (Select b.FacilityName 
					From mst_patient a inner join mst_facility b on a.LocationID = b.facilityid
					Where a.DeleteFlag = 0
					group by b.FacilityName
					having count(locationid) in (Select Max(ID) ID From
					(Select LocationID, Count(LocationID) ID From mst_patient
					Where DeleteFlag = 0
					Group By LocationID)a))l
		, (Select a.Ptn_Pk
			, a.dob
			, a.LocationID
			, a.TransferIn
			, f.Name Village
			, b.countryid
			, b.posid
			, b.satelliteid
			, b.facilityName
			, c.Name Gender
			, a.ModuleId		
			From mst_patient a left join mst_facility b on a.LocationID = b.facilityid
			left join mst_decode c on a.sex = c.ID 			
			Left JOIN mst_Village f On a.VillageName = f.ID
			Where a.DeleteFlag = 0)d 
		inner join mst_patient_decoded m on d.ptn_pk = m.ptn_pk 
		left join 
		(Select 
		c.ptn_pk
		, Max(c.EmergContactRelation) EmergContactRelation
		, Max(c.EmergContactName) EmergContactName
		, Max(c.EmergContactPhone) EmergContactPhone
		, Max(c.EmergContactAddress) EmergContactAddress 
		From dtl_patientcontacts c
		Group By c.ptn_pk)c on d.ptn_pk = c.ptn_pk 
		left join mst_decode d1 on c.EmergContactRelation = d1.ID		
		left join mst_decode d2 on m.ReferredFrom = d2.ID and d2.CodeID IN (17, 1089)		
		left join (Select Ptn_Pk, Max(ARTTransferInDate) ARTTransferInDate 
		From dtl_PatientHivPrevCareIE Group By Ptn_Pk) t on d.ptn_pk = t.ptn_pk
		inner join mst_facility f on d.LocationID = f.FacilityID
		LEFT join 

		(select ptn_pk, max(visitDate) as lastVisit 
		from Ord_Visit a Inner Join mst_VisitType b 
		On a.VisitType = b.VisitTypeID
		where b.VisitName Not In (''''Scheduler''''
								,''''ART History''''
								, ''''ART Therapy''''
								,''''Contact Tracking Form'''')
		AND b.VisitName NOT LIKE ''''%Enrollment%''''
		And (a.DeleteFlag = 0 Or a.DeleteFlag Is Null)
		AND a.VisitDate <= GETDATE()
		group by ptn_pk)lV on d.ptn_pk = lV.ptn_pk

		left join mst_education d3 on m.EducationLevel = d3.ID
		left join mst_decode d4 on m.MaritalStatus = d4.ID

		Left Join (Select a.Ptn_pk
					, MAX(e.FacilityName) f
					, Coalesce(Min(Case When c.ModuleName = ''''CCC Patient Card MoH 257'''' 
					Then COALESCE(b.OldEnrollDate, a.StartDate) Else Null End) 
					,Min(Case When c.ModuleName = ''''ART Clinic'''' 
					Then COALESCE(b.OldEnrollDate, a.StartDate) Else Null End)
					,Min(Case When c.ModuleName = ''''Paediatric ART'''' 
					Then COALESCE(b.OldEnrollDate, a.StartDate) Else Null End)
					,MIN(Case When c.ModuleName = ''''Comprehensive Care Clinic'''' 
					Then COALESCE(b.OldEnrollDate, a.StartDate) Else Null End)
					) RegistrationAtCCC
					From Lnk_PatientProgramStart a 
					LEFT JOIN Lnk_PatientReEnrollment b ON a.Ptn_pk = b.Ptn_Pk AND a.ModuleId = b.ModuleId 		
					LEFT join mst_module c on a.ModuleId = c.ModuleID
					INNER JOIN mst_Patient d ON a.Ptn_Pk = d.Ptn_Pk
					INNER JOIN mst_Facility e ON d.LocationID = e.FacilityID
					WHERE e.FacilityName NOT LIKE ''''%transit%''''
					AND e.FacilityName NOT LIKE ''''%pep%''''
					AND e.FacilityName NOT LIKE ''''%probation%''''
					Group By a.Ptn_pk) regCCC on d.ptn_pk = regCCC.ptn_pk

		Left Join (Select a.Ptn_pk
		, Coalesce(Min(Case When b.ModuleName = ''''ANC and PMTCT Services'''' Then a.StartDate Else Null End) 
		, Min(Case When b.ModuleName = ''''PACTInfant'''' Then a.StartDate Else Null End)
		, Min(Case When b.ModuleName = ''''ANC Maternity and Postnatal'''' Then a.StartDate Else Null End)) RegistrationAtPMTCT
		From Lnk_PatientProgramStart a Inner join mst_module b on a.ModuleId = b.ModuleID
		Group By a.Ptn_pk) regPMTCT on d.ptn_pk = regPMTCT.ptn_pk

		Left Join (Select a.Ptn_pk
		, MIN(a.StartDate) RegistrationAtTBClinic
		From Lnk_PatientProgramStart a Inner join mst_module b on a.ModuleId = b.ModuleID
		Where b.ModuleName In (''''TB''''
							,''''T B''''
							, ''''TB Module''''
							,''''TB Clinic Module''''
							,''''TB Clinic'''') And b.Status = 2
		Group By a.Ptn_pk) regTB on d.ptn_pk = regTB.ptn_pk
	
		LEFT JOIN x_SMSConsent aa ON d.Ptn_Pk = aa.PatientPK'')')

	Exec('
	CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_patientMaster] ([PatientPK] ASC )
	WITH (PAD_INDEX  = OFF
	, STATISTICS_NORECOMPUTE  = OFF
	, SORT_IN_TEMPDB = OFF
	, IGNORE_DUP_KEY = OFF
	, DROP_EXISTING = OFF
	, ONLINE = OFF
	, ALLOW_ROW_LOCKS  = ON
	, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	 ')

	 IF EXISTS(SELECT name FROM sys.tables WHERE name = N'x_SMSConsent')
	DROP TABLE x_SMSConsent;

	IF EXISTS(SELECT name FROM sys.tables WHERE name = N'tempIE')
	DROP TABLE tempIE
	
END
GO