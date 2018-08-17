IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateANCMothersMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateANCMothersMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateANCMothersMaster]
As

Begin

	declare @IQCareDB varchar(200), @sqlStr1  varchar(500),@sqlStr2  varchar(500), @Out varchar(500), @sqlStr3 varchar(500)
	declare @col1 table(colName varchar(500))
	declare @col2 table(colName varchar(500))
	declare @col3 table(colName varchar(500))

	set @IQCareDB = (select DBase from dbo.aa_Database)
	SET @sqlStr1 = 'SELECT COLUMN_NAME FROM ' + @IQCareDB + '.INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = ''PMTCT1StartDate'' and TABLE_NAME = ''DTL_FBCUSTOMFIELD_Maternal_HIV_History'';'
	SET @sqlStr2 = 'SELECT COLUMN_NAME FROM ' + @IQCareDB + '.INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = ''FacilityName'' and TABLE_NAME = ''DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I'';'
	SET @sqlStr3 = 'SELECT COLUMN_NAME FROM ' + @IQCareDB + '.INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = ''MaternalIntraPartumARV'' and TABLE_NAME = ''DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I'';'


	insert @col1
	exec(@sqlStr1)

	insert @col2
	exec(@sqlStr2)

	insert @col3 
	exec(@sqlStr3)

	exec
	('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_ANCMothers'') AND type in (N''U''))
	DROP TABLE tmp_ANCMothers')

	if exists (select * from @col1) 
	Begin
	EXEC('
	if exists (select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Mother_Enrollment'') 
	SELECT * INTO tmp_ANCMothers FROM 
	(
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk

	UNION

	Select a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, e.PMTCT1StartDate StartARTDate
	, e.PMTCT1Regimen StartARTRegimen
	, case when e.PMTCT1Regimen  = ''NVP'' then e.PMTCT1EndDate else null end SingleDoseNVPDate
	, e.CD4atDiagnosis LowestCD4
	, e.MostRecentCD4 CurrentCD4
	, null HighestViralLoad
	, e.MostRecentViralLoad CurrentViralLoad
	, g2.Name ModeOfDelivery
	, NULL InfantStatus
	--, case when g3.Name = ''Other facility'' then g4.Name else g3.Name end PlaceOfDelivery
	, NULL PlaceOfDelivery
	, f1.Name MaternalIntraPartumARV
	, f2.Name PostpartumUseARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Mother_Enrollment a1 on a.PatientPK = a1.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Antenatal_and_Delivery_Plan b on a1.Ptn_pk = b.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Maternal_HIV_History e on a1.Ptn_pk = e.Ptn_pk
	left join [DTL_FBCUSTOMFIELD_L&D_and_Postpartum_Plan] f on a1.Ptn_pk = f.Ptn_pk
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk
	left join dtl_PatientDelivery g on a.PatientPK = g.Ptn_pk
	left join mst_pmtctDeCode g2 on g2.ID = g.DeliveryMode
	--left join mst_modDeCode g4 on g4.ID = f.DeliveryLocationOther
	left join mst_moddecode f1 on f1.id = f.IntrapartumARVs
	left join mst_moddecode f2 on f2.id = f.PostPartumARV
	)a

	else if exists 
	(Select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I'')
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL  PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	INTO tmp_ANCMothers

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk
	')
	end
	else if not exists (select * from @col1) 
	and not exists (select * from @col2) 
	and exists (select * from @col3)
	Begin
	EXEC('
	if exists (select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Mother_Enrollment'') 
	SELECT * INTO tmp_ANCMothers FROM 
	(
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk

	UNION

	Select a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, e.PMTCT1StartDate StartARTDate
	, e.PMTCT1Regimen StartARTRegimen
	, case when e.PMTCT1Regimen  = ''NVP'' then e.PMTCT1EndDate else null end SingleDoseNVPDate
	, e.CD4atDiagnosis LowestCD4
	, e.MostRecentCD4 CurrentCD4
	, null HighestViralLoad
	, e.MostRecentViralLoad CurrentViralLoad
	, g2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, f1.Name MaternalIntraPartumARV
	, f2.Name PostpartumUseARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Mother_Enrollment a1 on a.PatientPK = a1.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Antenatal_and_Delivery_Plan b on a1.Ptn_pk = b.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Maternal_HIV_History e on a1.Ptn_pk = e.Ptn_pk
	left join [DTL_FBCUSTOMFIELD_L&D_and_Postpartum_Plan] f on a1.Ptn_pk = f.Ptn_pk
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk
	left join dtl_PatientDelivery g on a.PatientPK = g.Ptn_pk
	left join mst_pmtctDeCode g2 on g2.ID = g.DeliveryMode
	--left join mst_modDeCode g4 on g4.ID = f.DeliveryLocationOther
	left join mst_moddecode f1 on f1.id = f.IntrapartumARVs
	left join mst_moddecode f2 on f2.id = f.PostPartumARV
	)a

	else if exists 
	(Select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I'')
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	INTO tmp_ANCMothers

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk

	ELSE

	CREATE TABLE [dbo].[tmp_ANCMothers](
		[PatientPK] [int] NOT NULL,
		[PatientID] [varchar](100) NULL,
		[FacilityID] [int] NULL,
		[AgeEnrollment] [decimal](3, 1) NULL,
		[EDD] [datetime] NULL,
		[RegistrationAtPMTCT] [datetime] NULL,
		[StartARTDate] [datetime] NULL,
		[StartARTRegimen] [nvarchar](255) NULL,
		[SingleDoseNVPDate] [datetime] NULL,
		[LowestCD4] [numeric](20, 2) NULL,
		[CurrentCD4] [numeric](20, 2) NULL,
		[HighestViralLoad] [numeric](20, 2) NULL,
		[CurrentViralLoad] [numeric](20, 2) NULL,
		[ModeOfDelivery] [varchar](250) NULL,
		[InfantStatus] [varchar](250) NULL,
		[PlaceOfDelivery] [varchar](1000) NULL,
		[IntraPartumARV] [varchar](250) NULL,
		[PostPartumARV] [varchar](250) NULL,
		Discordant AS [varchar](10) NULL,
		DateofDelivery AS datetime NULL,
		AdmissionReason [varchar](250) NULL,
		MaternalProphylaxis [varchar](100) NULL,
		InfantARVProphylaxis [varchar](100) NULL,
		InfantARVProphylaxisDate DATETIME NULL,
		KnownHIVPositive [varchar](10) NULL,
		HIVTestingAtANC [varchar](10) NULL,
		DateHIVTestingAtANC DATETIME NULL,
		HIVResultAtANC [varchar](100) NULL,
		HIVTestingAtLD [varchar](10) NULL,
		DateHIVTestingAtLD DATETIME NULL,
		HIVResultAtLD [varchar](100) NULL,
		HIVTestingAtPNC [varchar](10) NULL,
		DateHIVTestingAtPNC DATETIME NULL,
		HIVResultAtPNC [varchar](100) NULL

	) ON [PRIMARY]
	')
	End
	else if not exists (select * from @col1) 
	and exists (select * from @col2) 
	and exists (select * from @col3)
	begin
	EXEC('
	if exists (select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Mother_Enrollment'') 
	SELECT * INTO tmp_ANCMothers FROM 
	(
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk

	UNION

	Select a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, null StartARTDate
	, null StartARTRegimen
	, null SingleDoseNVPDate
	, e.CD4atDiagnosis LowestCD4
	, e.MostRecentCD4 CurrentCD4
	, null HighestViralLoad
	, e.MostRecentViralLoad CurrentViralLoad
	, g2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, f1.Name MaternalIntraPartumARV
	, f2.Name PostpartumUseARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Mother_Enrollment a1 on a.PatientPK = a1.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Antenatal_and_Delivery_Plan b on a1.Ptn_pk = b.Ptn_pk
	left join DTL_FBCUSTOMFIELD_Maternal_HIV_History e on a1.Ptn_pk = e.Ptn_pk
	left join [DTL_FBCUSTOMFIELD_L&D_and_Postpartum_Plan] f on a1.Ptn_pk = f.Ptn_pk
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk
	left join dtl_PatientDelivery g on a.PatientPK = g.Ptn_pk
	left join mst_pmtctDeCode g2 on g2.ID = g.DeliveryMode
	--left join mst_modDeCode g4 on g4.ID = f.DeliveryLocationOther
	left join mst_moddecode f1 on f1.id = f.IntrapartumARVs
	left join mst_moddecode f2 on f2.id = f.PostPartumARV
	)a

	else if exists 
	(Select * from sys.synonyms where name = ''DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I'')
	Select distinct a.PatientPK
	, a.PatientID
	, a.FacilityID
	, a.AgeEnrollment
	, c.EDD
	, b.CurrentARTDate StartARTDate
	, b7.Name StartARTRegimen
	, b.SingleDoseNVPDate
	, b.LowestCD4
	, b.CurrentCD4
	, b.HighestViralLoad
	, b.CurrentViralLoad
	, b2.Name ModeOfDelivery
	, NULL InfantStatus
	, NULL PlaceOfDelivery
	, b5.Name IntraPartumARVs
	, b6.Name PostpartumARVs
	, null as Discordant
	, null as DateofDelivery
	, null as AdmissionReason
	, null as MaternalProphylaxis
	, null as InfantARVProphylaxis
	, null as InfantARVProphylaxisDate
	, null as KnownHIVPositive
	, null as HIVTestingAtANC
	, null as DateHIVTestingAtANC
	, null as HIVResultAtANC
	, null as HIVTestingAtLD
	, null as DateHIVTestingAtLD
	, null as HIVResultAtLD
	, null as HIVTestingAtPNC
	, null as DateHIVTestingAtPNC
	, null as HIVResultAtPNC
	INTO tmp_ANCMothers

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	left join mst_moddecode b2 on b.ModeofDelivery = b2.id
	left join mst_moddecode b5 on b.MaternalIntraPartumARV = b5.id
	left join mst_moddecode b6 on b.ARVsPrescribedforUsePostpartum = b6.id
	left join mst_moddecode b7 on b.CurrentART = b7.id
	left join dtl_PatientClinicalStatus c on c.visit_pk = b.visit_pk

	')
	end
	else 
	Begin
	EXEC('CREATE TABLE [dbo].[tmp_ANCMothers](
		[PatientPK] [int] NOT NULL,
		[PatientID] [varchar](100) NULL,
		[FacilityID] [int] NULL,
		[AgeEnrollment] [decimal](3, 1) NULL,
		[EDD] [datetime] NULL,
		[RegistrationAtPMTCT] [datetime] NULL,
		[StartARTDate] [datetime] NULL,
		[StartARTRegimen] [nvarchar](255) NULL,
		[SingleDoseNVPDate] [datetime] NULL,
		[LowestCD4] [numeric](20, 2) NULL,
		[CurrentCD4] [numeric](20, 2) NULL,
		[HighestViralLoad] [numeric](20, 2) NULL,
		[CurrentViralLoad] [numeric](20, 2) NULL,
		[ModeOfDelivery] [varchar](250) NULL,
		[InfantStatus] [varchar](250) NULL,
		[PlaceOfDelivery] [varchar](1000) NULL,
		[IntraPartumARV] [varchar](250) NULL,
		[PostPartumARV] [varchar](250) NULL,
		Discordant [varchar](10) NULL,
		DateofDelivery datetime NULL,
		AdmissionReason [varchar](250) NULL,
		MaternalProphylaxis [varchar](100) NULL,
		InfantARVProphylaxis [varchar](100) NULL,
		InfantARVProphylaxisDate DATETIME NULL,
		KnownHIVPositive [varchar](10) NULL,
		HIVTestingAtANC [varchar](10) NULL,
		DateHIVTestingAtANC DATETIME NULL,
		HIVResultAtANC [varchar](100) NULL,
		HIVTestingAtLD [varchar](10) NULL,
		DateHIVTestingAtLD DATETIME NULL,
		HIVResultAtLD [varchar](100) NULL,
		HIVTestingAtPNC [varchar](10) NULL,
		DateHIVTestingAtPNC DATETIME NULL,
		HIVResultAtPNC [varchar](100) NULL
	) ON [PRIMARY]')
	End

Exec('
CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_ANCMothers] ([PatientPK] ASC )
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


