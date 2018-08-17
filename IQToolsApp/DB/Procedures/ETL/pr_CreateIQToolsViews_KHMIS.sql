IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CreateIQToolsViews_KHMIS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].pr_CreateIQToolsViews_KHMIS
GO

CREATE Proc [dbo].pr_CreateIQToolsViews_KHMIS
As
Begin

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_SiteDetails]'))
DROP VIEW [dbo].[IQC_SiteDetails]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IQC_SiteDetails]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[IQC_SiteDetails] AS
		SELECT f.FacilityID ,
		Case WHEN LEN(f.SatelliteID) <= 3 THEN CAST(f.CountryID+f.PosID AS VARCHAR(10)) ELSE
		cast(f.SatelliteID as varchar(10)) END AS
		   SiteCode ,
		   f.FacilityName ,
		   NULL FacilityOwner ,
		   NULL ImplementingPartner ,
		   f.CountryID ,
		   CASE
			   WHEN f.CountryID = 648 THEN ''Kenya''
			   ELSE NULL
		   END AS Country ,
		   prov.Province Region ,
		   dist.District ,
		   f.PepFarStartDate
	FROM mst_Facility f,
	  (SELECT Top 1 IsNull(b.Name, ''Unknown'') Province,
					COUNT(b.Name) n
	   FROM mst_patient a
	   LEFT JOIN mst_Province b ON a.Province = b.ID
	   GROUP BY b.Name
	   ORDER BY Count(b.Name) DESC) prov,
	  (SELECT Top 1 IsNull(b.Name, ''Unknown'') District,
					COUNT(b.Name) n
	   FROM mst_patient a
	   LEFT JOIN mst_district b ON a.DistrictName = b.ID
	   GROUP BY b.Name
	   ORDER BY Count(b.Name) DESC) dist
	WHERE f.FacilityID IN
		(SELECT DISTINCT mst_Patient.LocationID
		 FROM mst_Patient WHERE DeleteFlag IS NULL OR DeleteFlag = 0)
		 ' 

END