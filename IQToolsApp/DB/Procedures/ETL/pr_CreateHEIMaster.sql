IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateHEIMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateHEIMaster
GO

CREATE PROCEDURE [dbo].[pr_CreateHEIMaster]

AS
BEGIN
	
	EXEC
	('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_HEI'') AND type in (N''U''))
	DROP TABLE tmp_HEI')

	if exists (Select * from sys.synonyms where name = 'DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card')

	EXEC('Select distinct a.PatientPK
	, a.PatientID
	, a.DOB
	, a.AgeEnrollment
	, a.RegistrationAtPMTCT
	, MAX(fb1.Name) PatientSource 
	, MAX(c.BirthWeight) BirthWeight
	, MAX(d.Name) ARVProphylaxis
	, MAX(h.PatientID) MotherID 
	, MAX(i.OutCome) HEIOutcome
	, MAX(i.OutcomeDate) OutcomeDate
	, MAX(CASE WHEN j.PatientPK IS NULL THEN ''No'' ELSE ''Yes'' END) AS MotherOnARVs
	, null as Reasons

	INTO tmp_HEI

	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_HEI_Follow_Up_Card b on a.PatientPK = b.Ptn_pk
	left join dtl_FB_ChildRefferedFrom fb on fb.ptn_pk = b.ptn_pk
	left join mst_moddecode fb1 on fb.ChildRefferedFrom = fb1.id
	left join dtl_InfantInfo c on c.visit_pk = b.visit_pk
	left join mst_moddecode d on b.ChildPEPARVs = d.id
	left join dtl_PatientCareEnded e on e.ptn_pk = b.Ptn_pk 
	left join (select distinct e.ptn_pk, g.Name OutCome, CareEndedDate OutComedate 
	from dtl_PatientCareEnded e 
	left join Lnk_PatientProgramStart f on f.ptn_pk = e.ptn_pk
	inner join mst_Decode g on g.ID = e.PatientExitReason  
	where f.ModuleID = (select top 1 moduleid from mst_module where ModuleName = ''ANC, Maternity and Postnatal Clinic'')) f on f.ptn_pk = b.ptn_pk
	left join dtl_familyInfo g on g.ptn_pk = b.ptn_pk
	left join 
	(Select distinct a.PatientPK
	, a.PatientID
	, a.SiteCode
	From tmp_PatientMaster a 
	inner join DTL_FBCUSTOMFIELD_Maternal_and_Exposed_Infant_I b on a.PatientPK = b.Ptn_pk
	) h on h.PatientPK = g.ReferenceId
	LEFT JOIN 
	(Select b.Ptn_Pk 
	, MAX(d.Name) Outcome 
	, MAX(b.CareEndedDate) OutcomeDate
	FROM	dtl_PatientCareEnded b
	INNER JOIN dtl_PatientTrackingCare c ON b.Ptn_Pk = c.Ptn_Pk AND b.TrackingID = c.TrackingID
	INNER JOIN mst_Decode d ON b.PatientExitReason = d.ID
	INNER JOIN mst_Module e ON c.ModuleID = e.ModuleID
	WHERE e.ModuleName = ''ANC Maternity and Postnatal''
	GROUP BY b.Ptn_Pk) i ON b.ptn_pk = i.ptn_pk
	LEFT JOIN dbo.tmp_ARTPatients j ON a.PatientPK = j.PatientPK
	WHERE a.AgeEnrollment <= 2
	GROUP BY  a.PatientPK
	, a.PatientID
	, a.DOB
	, a.AgeEnrollment
	, a.RegistrationAtPMTCT')
	
	ELSE

	CREATE TABLE [dbo].[tmp_HEI](
		[PatientPK] [int] NOT NULL,
		[PatientID] [varchar](43)  NULL,
		[DOB] [datetime] NOT NULL,
		[AgeEnrollment] [decimal](3, 1) NULL,
		[RegistrationAtPMTCT] [datetime] NULL,
		[PatientSource] [varchar](250)  NULL,
		[BirthWeight] [numeric](18, 2) NULL,
		[ARVProphylaxis] [varchar](250)  NULL,
		[MotherID] [varchar](43)  NULL,
		[HEIOutcome] [varchar](250)  NULL,
		[OutcomeDate] [datetime] NULL,
		[MotherOnARVs] [varchar](10) null,
		Reasons varchar(200) null
	) ON [PRIMARY]

	EXEC('
	CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_HEI] ([PatientPK] ASC )
	WITH (PAD_INDEX  = OFF
	, STATISTICS_NORECOMPUTE  = OFF
	, SORT_IN_TEMPDB = OFF
	, IGNORE_DUP_KEY = OFF
	, DROP_EXISTING = OFF
	, ONLINE = OFF
	, ALLOW_ROW_LOCKS  = ON
	, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	 ')

END
GO