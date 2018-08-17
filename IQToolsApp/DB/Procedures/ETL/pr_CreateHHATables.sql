IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateHHATables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CreateHHATables]
GO

CREATE Proc [dbo].[pr_CreateHHATables]
As
Begin

IF EXISTS(Select name from sys.synonyms WHERE name = N'dtl_HTNPatientProfile')
	BEGIN

	IF EXISTS(Select name from sys.tables WHERE name = N'tmp_HTNDrugDispense')
	DROP TABLE tmp_HTNDrugDispense;

	CREATE TABLE tmp_HTNDrugDispense
	(PatientPK INT NOT NULL,
	DispenseDate DATE NULL,
	HTNDrugA VARCHAR(200) NULL,
	HTNDrugB VARCHAR(200) NULL,
	HTNDrugC VARCHAR(200) NULL);

	WITH HTNDrugs_ AS (Select DISTINCT a.Ptn_Pk, a.DispensedByDate DispenseDate  , a.DrugName 
	FROM VW_PatientPharmacy a   INNER JOIN tmp_PatientMaster b ON a.Ptn_Pk = b.PatientPK  
	Where DrugType = 'Antihypertensive')    

	, HTNDrugs AS (SELECT Ptn_Pk, DispenseDate,  ROW_NUMBER() OVER (Partition By DispenseDate ORDER BY DrugName) ID  
	, DrugName   FROM HTNDrugs_)  

	INSERT INTO tmp_HTNDrugDispense
	Select Ptn_Pk,  DispenseDate   , [1] HTNDrugA   , [2] HTNDrugB   , [3] HTNDrugC 
	FROM HTNDrugs PIVOT   (Min(DrugName) FOR ID IN ([1],[2],[3])) A

	END
END 