IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_RefreshIQTools]') 
AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_RefreshIQTools]
GO

CREATE PROCEDURE [dbo].[pr_RefreshIQTools]
AS
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Person]'))
	BEGIN
		EXEC pr_CreatePatientMaster_KHMIS
		EXEC pr_CreateIQToolsViews_KHMIS
	END 
	ELSE
	BEGIN
		EXEC pr_CreatePatientMaster
		EXEC pr_CreatePharmacyMaster 
		EXEC pr_CreateClinicalEncountersMaster
		EXEC pr_CreateLastStatusMaster
		EXEC pr_CreateARTPatientsMaster
		EXEC pr_CreateLabMaster
		EXEC pr_CreatePregnanciesMaster
		EXEC pr_CreateOIsMaster
		EXEC pr_CreateTBPatientsMaster
		EXEC pr_CreateHEIMaster
		EXEC pr_CreateANCMothersMaster 
		EXEC pr_CreateFamilyInfoMaster
		EXEC pr_CreateIQToolsViews 
		EXEC pr_CreateHHATables
		EXEC pr_CreateKeyPopMaster
		EXEC pr_CreatePwPServicesMaster
		EXEC pr_CreateIPTMaster
	END
END
GO