IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePatientMaster_KHMIS]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreatePatientMaster_KHMIS
GO

CREATE Proc [dbo].pr_CreatePatientMaster_KHMIS WITH ENCRYPTION
AS
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tmp_PatientMaster') AND type in (N'U'))
	DROP TABLE tmp_PatientMaster;
	
	CREATE TABLE tmp_PatientMaster
	(PatientPK INT NOT NULL
	, PatientID VARCHAR(200) NULL
	, FacilityID INT NOT NULL
	, SiteCode VARCHAR(100) NULL
	, FacilityName VARCHAR(200) NULL
	, SatelliteName VARCHAR(200) NULL
	, Gender VARCHAR(10) NULL
	, DOB DATE NULL
	, RegistrationDate DATE NULL
	, RegistrationAtCCC DATE NULL
	, RegistrationAtPMTCT DATE NULL
	, RegistrationAtTBClinic DATE NULL
	, PatientName VARCHAR(200) NULL
	, PatientSource VARCHAR(100) NULL
	, Village VARCHAR(100) NULL
	, [Address] VARCHAR(100) NULL
	, PhoneNumber VARCHAR(100) NULL
	, ContactName VARCHAR(100) NULL
	, ContactRelation VARCHAR(100) NULL
	, ContactPhoneNumber VARCHAR(100) NULL
	, ContactAddress VARCHAR(100) NULL
	, LastVisit DATE NULL
	, AgeCurrent DECIMAL(18,1) NULL
	, AgeEnrollment DECIMAL(18,1) NULL
	, AgeLastVisit DECIMAL(18,1) NULL
	, MaritalStatus VARCHAR(100) NULL
	, EducationLevel VARCHAR(100) NULL
	, HIVTestDate DATE NULL
	, PreviousARTExposure VARCHAR(100) NULL
	, PreviousARTStartDate DATE NULL
	, SMSConsented VARCHAR(10) NULL);

	INSERT INTO tmp_PatientMaster (PatientPK, FacilityID)
	Select b.ptn_Pk, b.FacilityID
	FROM Person_Decoded a INNER JOIN Patient b ON a.PersonID = b.PersonId;

END
GO