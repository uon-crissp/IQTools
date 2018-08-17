IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateKeyPopMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateKeyPopMaster
GO

CREATE Proc [dbo].pr_CreateKeyPopMaster
AS
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tmp_KeyPops') AND type in (N'U'))
	DROP TABLE tmp_KeyPops;
	
	CREATE TABLE tmp_KeyPops
	(PatientPK INT NOT NULL
	, VisitDate DATE NOT NULL
	, SexWorker VARCHAR(10) NULL
	, PeopleWhoInjectDrugs VARCHAR(10) NULL
	, MenWhoHaveSexWithMen VARCHAR(10) NULL
	, ClientsToSexWorkers VARCHAR(10) NULL
	, DiscordantCouple VARCHAR(10) NULL
	);	

	IF EXISTS(Select Name FROM sys.synonyms Where Name = N'dtl_PatientAtRiskPopulation')
	BEGIN

	EXEC('INSERT INTO tmp_KeyPops
	SELECT a.Ptn_Pk, CAST(a.VisitDate as DATE) VisitDate
	, MAX(SexWorker)SexWorker
	, MAX(PeopleWhoInjectDrugs)PeopleWhoInjectDrugs
	, MAX(MenWhoHaveSexWithMen)MenWhoHaveSexWithMen
	, MAX(ClientsToSexWorkers)ClientsToSexWorkers
	, MAX(DiscordantCouple)DiscordantCouple
	FROM (
	Select a.Ptn_Pk, b.VisitDate
	, CASE WHEN a.KeyPop IN (''SW = Sex worker'') THEN ''YES'' ELSE NULL END AS SexWorker
	, CASE WHEN a.KeyPop IN (''People Who Inject Drugs (PWID)'',''IDU = Intravenous drug users'') THEN ''YES'' ELSE NULL END AS PeopleWhoInjectDrugs
	, CASE WHEN a.KeyPop IN (''MSM = Men who have sex with men'') THEN ''YES'' ELSE NULL END AS MenWhoHaveSexWithMen
	, CASE WHEN a.KeyPop IN (''CSW= Clients to sex worker'') THEN ''YES'' ELSE NULL END AS ClientsToSexWorkers
	, CASE WHEN a.KeyPop IN (''DC=Discordant Couple'') THEN ''YES'' ELSE NULL END AS DiscordantCouple
	FROM (
	select a.Ptn_pk, a.Visit_Pk, b.Name KeyPop
	from dtl_PatientAtRiskPopulation a INNER join mst_BlueDecode b on a.ID = b.ID AND b.CodeID = 9
	UNION
	select a.Ptn_pk, a.Visit_Pk, b.Name KeyPop
	from dtl_PatientAtRiskPopulation a INNER join mst_Decode b on a.ID = b.ID AND b.CodeID = 1180) a
	INNER JOIN ord_Visit b ON a.Visit_Pk = b.Visit_Id
	WHERE b.DeleteFlag = 0 OR b.DeleteFlag IS NULL) a
	GROUP BY a.Ptn_Pk, CAST(a.VisitDate as DATE)')

	END

	Exec('
	CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_KeyPops] ([PatientPK] ASC )
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