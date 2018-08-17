IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreatePwPServicesMaster]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreatePwPServicesMaster
GO

CREATE Proc [dbo].pr_CreatePwPServicesMaster
AS
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'tmp_PwPServices') AND type in (N'U'))
	DROP TABLE tmp_PwPServices;
	
	CREATE TABLE tmp_PwPServices
	(PatientPK INT NOT NULL
	, VisitDate DATE NOT NULL
	, PartnerHIVTesting VARCHAR(10) NULL
	, ProvidedWithCondoms VARCHAR(10) NULL
	, PartnerDisclosure VARCHAR(10) NULL
	, ModernContraception VARCHAR(10) NULL
	, STIScreening VARCHAR(10) NULL
	, CouplesCounselling VARCHAR(10) NULL
	, AdherenceCounselling VARCHAR(10) NULL
	, NeedleAndSyringeProgramme VARCHAR(10) NULL
	, OtherPwPService VARCHAR(10) NULL
	);	

	IF EXISTS(Select Name FROM sys.synonyms Where Name = N'dtl_patientCounseling')
	AND EXISTS(Select Name FROM sys.synonyms Where Name = N'dtl_PatientPreventionwithpositives')
	AND EXISTS(Select Name FROM sys.synonyms Where Name = N'dtl_PwP')
	BEGIN

	EXEC('WITH FP AS
	(SELECT Ptn_pk, Visit_pk, FPMethod FROM (
	select Ptn_pk, Visit_pk, b.Name FPMethod
	from dtl_patientCounseling a
	INNER JOIN mst_BlueDecode b on a.FamilyPlanningMethod = b.ID AND b.CodeID IN (2,14)
	WHERE FamilyPlanningMethod IS NOT NULL
	UNION
	select Ptn_pk, Visit_pk, b.Name
	from dtl_patientCounseling a
	INNER JOIN mst_PmtctDecode b on a.FamilyPlanningMethod = b.ID  AND b.CodeID IN (6)
	WHERE FamilyPlanningMethod IS NOT NULL) a 
	WHERE a.FPMethod 
	IN (''D =diaphragm/cervical cap''
	,''IMP =implant'',''INJ =Injectable''
	,''IUD =intrauterine device''
	,''OC =oral contraceptive pills''
	,''TL =tubal ligation/female sterilization''))

	, PwPServices AS (
	select a.Ptn_Pk, a.Visit_Pk, b.Name PwPService from 
	dtl_PatientPreventionwithpositives a INNER JOIN mst_BlueDecode b on a.ID = b.ID
	UNION
	select a.Ptn_Pk, a.Visit_Pk, b.Name PwPService from 
	dtl_PatientAtRiskPopulationServices a INNER join mst_BlueDecode b on a.ID = b.ID 
	UNION
	select a.Ptn_Pk, a.Visit_Pk, ''On site screening for STIs/RTI'' PwPService 
	from [dbo].[dtl_PwP] a WHERE ScreenedForSTI = 1
	UNION
	Select Ptn_Pk, Visit_Pk, ''Modern contraceptive methods'' PwPService FROM FP)

	, PwPServices_f AS 
	(Select a.Ptn_Pk, CAST(b.VisitDate as DATE)VisitDate
	, a.PwPService 
	, CASE WHEN a.PwPService IN (''PT  =   Partner Testing'',''Partner received on site HIV testing'') THEN ''YES'' ELSE NULL END AS PartnerHIVTesting
	, CASE WHEN a.PwPService IN (''C= Condom promotion/provision'',''Provided with condoms'') THEN ''YES'' ELSE NULL END AS ProvidedWithCondoms
	, CASE WHEN a.PwPService IN (''Disclosed HIV status to sexual partner'') THEN ''YES'' ELSE NULL END AS PartnerDisclosure
	, CASE WHEN a.PwPService IN (''Modern contraceptive methods'') THEN ''YES'' ELSE NULL END AS ModernContraception
	, CASE WHEN a.PwPService IN (''On site screening for STIs/RTI'') THEN ''YES'' ELSE NULL END AS STIScreening
	, CASE WHEN a.PwPService IN (''CC= couple counselling'') THEN ''YES'' ELSE NULL END AS CouplesCounselling
	, CASE WHEN a.PwPService IN (''AdC = Adherence counselling'') THEN ''YES'' ELSE NULL END AS AdherenceCounselling
	, CASE WHEN a.PwPService IN (''NSP= Needle and syringe programmes'') THEN ''YES'' ELSE NULL END AS NeedleAndSyringeProgramme
	, CASE WHEN a.PwPService IN (''Other (specify)'') THEN ''YES'' ELSE NULL END AS OtherPwPService
	FROM PwPServices a INNER JOIN ord_Visit b ON a.Visit_pk = b.Visit_Id
	WHERE b.DeleteFlag = 0 OR b.DeleteFlag IS NULL)

	INSERT INTO tmp_PwPServices
	Select Ptn_pk, VisitDate
	, MAX(PartnerHIVTesting)PartnerHIVTesting
	, MAX(ProvidedWithCondoms)ProvidedWithCondoms
	, MAX(PartnerDisclosure)PartnerDisclosure
	, MAX(ModernContraception)ModernContraception
	, MAX(STIScreening)STIScreening
	, MAX(CouplesCounselling)CouplesCounselling
	, MAX(AdherenceCounselling)AdherenceCounselling
	, MAX(NeedleAndSyringeProgramme)NeedleAndSyringeProgramme
	, MAX(OtherPwPService)OtherPwPService
	FROM PwPServices_f
	GROUP BY Ptn_pk, VisitDate')

	END

	Exec('
	CREATE CLUSTERED INDEX [IDX_PatientPK] ON 
	[dbo].[tmp_PwPServices] ([PatientPK] ASC )
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