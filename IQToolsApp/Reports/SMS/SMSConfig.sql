Declare @CatID as INT
, @ReportGroupID as INT
, @ReportID as INT
, @QueryID AS INT;

IF EXISTS(Select CatID FROM aa_Category WHERE Category = N'SMS')
BEGIN
	DELETE FROM dbo.aa_Category WHERE Category = 'SMS'
END

INSERT INTO aa_Category (Category, CreateDate, Deleteflag, Excel)
VALUES
('SMS',GETDATE(),0,1)

SELECT @CatID = IDENT_CURRENT('aa_Category')


IF EXISTS(SELECT sbCatID FROM aa_SBCategory WHERE catID = @CatID)
DELETE FROM dbo.aa_SBCategory WHERE catID = @CatID

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       
    @CatID,        
    NULL,         
    GETDATE(), 
    NULL, 
    NULL,      
    NULL,         
    NULL,       
    NULL,     
    NULL   
)


--Next Appointment
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'Next Appointment Alert')
DELETE FROM dbo.aa_Queries WHERE qryName = 'Next Appointment Alert'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'Next Appointment Alert',       -- qryName - nvarchar(50)
    N'select distinct a.PatientPK
	, a.PatientName
	, a.PatientID
	, a.PhoneNumber as Phone
	, a.AgeCurrent
	, b.appdate as NextAppointmentDate
	, c.name as AppReason  
	from tmp_PatientMaster a inner join dtl_patientappointment b on a.patientpk= b.ptn_pk
	left join mst_decode c on b.appreason = c.id 
	where 
	b.appdate=CAST(@Appointment_Date as datetime)
	and a.PhoneNumber is not null    
	and c.name = ''Follow up''
	and a.patientpk in(select ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration where SMSConsented=1)',       -- qryDefinition - nvarchar(max)
    N'Next Appointment Alert',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)




--Treatment Preparation
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'Treatment Preparation')
DELETE FROM dbo.aa_Queries WHERE qryName = 'Treatment Preparation'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'Treatment Preparation',       -- qryName - nvarchar(50)
    N'select distinct a.PatientPK, a.PatientName, a.PatientID, a.PhoneNumber as Phone,      
	a.AgeCurrent, b.appdate as NextAppointmentDate, c.name as AppReason  from tmp_PatientMaster a     
	inner join dtl_patientappointment b on a.patientpk= b.ptn_pk     
	left join mst_decode c on b.appreason = c.id     
	where cast(b.appdate as date) =CAST(@Appointment_Date as date)     
	and a.PhoneNumber is not null  
	and c.name = ''Treatment preparation'' 
	and a.patientpk in (select ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration where SMSConsented=1)',       -- qryDefinition - nvarchar(max)
    N'Treatment Preparation Alert',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)





--Support Group Meeting
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'Support_Group_SMS_Reminder')
DELETE FROM dbo.aa_Queries WHERE qryName = 'Support_Group_SMS_Reminder'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'Support_Group_SMS_Reminder',       -- qryName - nvarchar(50)
    N'select distinct a.PatientPK, a.PatientName, a.PatientID, a.PhoneNumber as Phone,      
	a.AgeCurrent, b.appdate as NextAppointmentDate, c.name as AppReason  from tmp_PatientMaster a     
	inner join dtl_patientappointment b on a.patientpk= b.ptn_pk     
	left join mst_decode c on b.appreason = c.id     
	where b.appdate=CAST(@Appointment_Date as datetime)     
	and a.PhoneNumber is not null  
	and c.name = ''support group meeting''
	and a.patientpk in (select ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration where SMSConsented=1)',       -- qryDefinition - nvarchar(max)
    N'Support Group Meeting Alert',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)








--TB Appointments
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'TB_Appointments_SMS_Reminder')
DELETE FROM dbo.aa_Queries WHERE qryName = 'TB_Appointments_SMS_Reminder'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'TB_Appointments_SMS_Reminder',       -- qryName - nvarchar(50)
    N'select distinct a.PatientPK, a.PatientName, a.PatientID, a.PhoneNumber as Phone,      
	a.AgeCurrent, b.appdate as NextAppointmentDate, c.name as AppReason  from tmp_PatientMaster a     
	inner join dtl_patientappointment b on a.patientpk= b.ptn_pk     
	left join mst_decode c on b.appreason = c.id     
	where b.appdate=CAST(@Appointment_Date as datetime)     
	and a.PhoneNumber is not null
	and a.registrationAtTBClinic is not null
	and a.patientpk in (select ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration where SMSConsented=1)',       -- qryDefinition - nvarchar(max)
    N'TB Appointments Alert',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)



--TB Appointments
IF EXISTS(SELECT qryID FROM dbo.aa_Queries WHERE qryName = 'TB_Appointments_SMS_Reminder')
DELETE FROM dbo.aa_Queries WHERE qryName = 'TB_Appointments_SMS_Reminder'


INSERT INTO dbo.aa_Queries
(
    qryName,
    qryDefinition,
    qryDescription,
    qryType,
    CreateDate,
    UpdateDate,
    Deleteflag,
    MkTable,
    Decrypt,
    Hidden,
    qryGroup,
    UID
)
VALUES
(   N'SMS_Consent',       -- qryName - nvarchar(50)
    N'select distinct a.PatientPK, a.PatientName, a.PatientID, a.PhoneNumber as Phone,   
	 a.AgeCurrent from tmp_PatientMaster a  
	 where a.PhoneNumber is not null
	and a.patientpk in (select ptn_pk from DTL_FBCUSTOMFIELD_Patient_Registration where SMSConsented=1)',       -- qryDefinition - nvarchar(max)
    N'Line List of Patients who have consented to SMS Alerts',       -- qryDescription - nvarchar(200)
    N'Function',       -- qryType - nvarchar(10)
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- MkTable - int
    NULL,      -- Decrypt - bit
    NULL,      -- Hidden - bit
    N'IQCare',       -- qryGroup - nvarchar(50)
    NULL          -- UID - int
)

SELECT @QueryID = IDENT_CURRENT('aa_Queries')

INSERT INTO dbo.aa_SBCategory
(
    sbCategory,
    catID,
    QryID,
    CreateDate,
    UpdateDate,
    DeleteFlag,
    Psn,
    sbDescription,
    Flatten,
    DHISDatasetID
)
VALUES
(   N'Appointments',       -- sbCategory - nvarchar(50)
    @CatID,         -- catID - bigint
    @QueryID,         
    GETDATE(), 
    NULL, -- UpdateDate - datetime
    NULL,      
    NULL,         -- Psn - bigint
    NULL,       -- sbDescription - nvarchar(800)
    NULL,      -- Flatten - bit
    NULL         -- DHISDatasetID - varchar(50)
)
