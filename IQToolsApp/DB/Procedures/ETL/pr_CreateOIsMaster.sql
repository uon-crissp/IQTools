IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateOIsMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreateOIsMaster]
GO

CREATE PROCEDURE [dbo].[pr_CreateOIsMaster]

AS

BEGIN
EXEC('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''tmp_OIs'') AND type in (N''U''))
DROP TABLE tmp_OIs')

		IF EXISTS(Select Name FROM sys.tables WHERE NAME = 'tempOIs')
		DROP TABLE tempOIs
		
		EXEC('CREATE TABLE tempOIs (ptn_pk INT NULL,visit_pk INT NULL,FacilityID int null
				, OI Varchar(50) NULL	,OIDate  datetime NULL
				, WHOStage int NULL)')
IF EXISTS (Select * FROM sys.synonyms WHERE name = 'dtl_FB_WHO_I')
EXEC('INSERT INTO tempOIs 
Select Ptn_Pk, Visit_Pk, FacilityID, OI, OIDate, WHOStage
FROM
(Select a.Ptn_Pk , a.visit_pk, a.LocationID FacilityID
, b.Name OI
, case when cast('''' as datetime) = DateField1 or datefield1 is null 
then c.visitdate else DateField1 end OIDate
, 1 WHOStage
FROM dtl_FB_WHO_I a 
inner join mst_ModDeCode b on a.WHO_I = b.ID
inner join ord_visit c on a.visit_pk = c.visit_id
where b.name <> ''Asymptomatic''
UNION
Select a.Ptn_Pk , a.visit_pk, a.LocationID 
, b.Name OI
, case when cast('''' as datetime) = DateField1 or datefield1 is null 
then c.visitdate else DateField1 end OIDate
, 2 WHOStage
FROM dtl_FB_WHO_II a 
inner join mst_ModDeCode b on a.WHO_II = b.ID
inner join ord_visit c on a.visit_pk = c.visit_id
UNION
Select a.Ptn_Pk , a.visit_pk, a.LocationID 
, b.Name OI
, case when cast('''' as datetime) = DateField1 or datefield1 is null 
then c.visitdate else DateField1 end OIDate
, 3 WHOStage
FROM dtl_FB_WHO_III a 
inner join mst_ModDeCode b on a.WHO_III = b.ID
inner join ord_visit c on a.visit_pk = c.visit_id
UNION
Select a.Ptn_Pk , a.visit_pk, a.LocationID 
, b.Name OI
, case when cast('''' as datetime) = DateField1 or datefield1 is null 
then c.visitdate else DateField1 end OIDate
, 4 WHOStage
FROM dtl_FB_WHO_IV a 
inner join mst_ModDeCode b on a.WHO_IV = b.ID
inner join ord_visit c on a.visit_pk = c.visit_id)A
')

EXEC('SELECT m.PatientPK,
	m.FacilityID,
	m.RegistrationDate,
	c.StartARTDate,
	COALESCE(b.OI,a.OI) OI,
	Min(COALESCE(b.OIDate,a.OIDate)) OIDate
	,Max(COALESCE(b.WHOStage,a.WHOStage)) WHOStage

	,CASE
	   WHEN DateDiff(dd, m.registrationDate, Min(COALESCE(b.OIDate,a.OIDate))) <= 60 THEN 1
	   ELSE 0
	END AS eOITest,
	CASE
	   WHEN DateDiff(dd, c.startARTDate, Min(COALESCE(b.OIDate,a.OIDate))) BETWEEN -90 AND 60 THEN 1
	   ELSE 0
	END AS bOITest,
	CASE
	   WHEN DateDiff(dd, m.registrationDate, Min(COALESCE(b.OIDate,a.OIDate))) <= 60
			AND a.OI IN (''Pulmonary TB Smear+'',
										''Pulmonary TB'',
										''Pulmonary TB Smear-'',
										''TB'',
										''Extrapulmonary TB'') THEN 1
	   ELSE 0
	END AS eTBTest,
	CASE
	   WHEN DateDiff(dd, c.startARTDate, Min(COALESCE(b.OIDate,a.OIDate))) BETWEEN -90 AND 60
			AND a.OI IN (''Pulmonary TB Smear+'',
										''Pulmonary TB'',
										''Pulmonary TB Smear-'',
										''TB'',
										''Extrapulmonary TB'') THEN 1
	   ELSE 0
	END AS bTBTest,
	CASE
	   WHEN DateDiff(dd, m.registrationDate, Min(COALESCE(b.OIDate,a.OIDate))) <= 60
			AND a.OI IN (''PCP'',
										''Pneumonia'') THEN 1
	   ELSE 0
	END AS ePCPTest,
	CASE
	   WHEN DateDiff(dd, c.startARTDate, Min(COALESCE(b.OIDate,a.OIDate))) BETWEEN -90 AND 60
			AND a.OI IN (''PCP'',
										''Pneumonia'') THEN 1
	   ELSE 0
	END AS bPCPTest,
	CASE
	   WHEN DateDiff(dd, m.registrationDate, Min(COALESCE(b.OIDate,a.OIDate))) <= 60
			AND a.OI IN (''Cryptococcal Meningitis'', ''Cryptococcal Menengitis'') THEN 1
	   ELSE 0
	END AS eCryptoTest,
	CASE
	   WHEN DateDiff(dd, c.startARTDate, Min(COALESCE(b.OIDate,a.OIDate))) BETWEEN -90 AND 60
			AND a.OI IN (''Cryptococcal Meningitis'', ''Cryptococcal Menengitis'') THEN 1
	   ELSE 0
	END AS bCryptoTest

	INTO tmp_OIs

	FROM tmp_PatientMaster m LEFT JOIN tempOIs b ON m.PatientPK = b.Ptn_Pk
	
	LEFT JOIN tmp_ClinicalEncounters a ON m.PatientPK = a.PatientPK
	LEFT JOIN tmp_ARTPatients c ON m.PatientPK = c.PatientPK
	WHERE COALESCE(a.PatientPK, b.Ptn_PK) IS NOT NULL  
	AND COALESCE(b.OI, a.OI) IS NOT NULL
	AND COALESCE(b.OI,a.OI) NOT IN (''None - OIs & AIDS Illness'',
									  ''Not Documented-Med History'',
									  ''None - Med History'',
									  ''None - HIV Assoc Condition'',
									  ''Not Documented - OIs & AIDS Illness'',
									  ''Not Documented - HIV Assoc Condition'')
	OR b.Ptn_pk IS NOT NULL
	GROUP BY m.PatientPK,
	b.Ptn_pk,
	b.OI,
			 m.FacilityID,       
			 a.OI,
			 m.RegistrationDate,
			 c.StartARTDate')

IF EXISTS(Select Name FROM sys.tables WHERE NAME = 'tempOIs')
DROP TABLE tempOIs

Exec('CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
[dbo].[tmp_OIs] ([PatientPK] ASC )
WITH (PAD_INDEX  = OFF
, STATISTICS_NORECOMPUTE  = OFF
, SORT_IN_TEMPDB = OFF
, IGNORE_DUP_KEY = OFF
, DROP_EXISTING = OFF
, ONLINE = OFF
, ALLOW_ROW_LOCKS  = ON
, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] ')

End
GO