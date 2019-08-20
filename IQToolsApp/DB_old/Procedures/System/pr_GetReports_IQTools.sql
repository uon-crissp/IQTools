IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetReports_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetReports_IQTools]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pr_GetReports_IQTools] AS

BEGIN

--Reports 0

IF EXISTS (Select name from sys.synonyms Where name = N'dtl_HTNPatientProfile')
Select a.*, b.GroupName FROM aa_Reports a inner join aa_ReportGroups b on a.reportgroupid = b.reportgroupid
ELSE 
Select a.*, b.GroupName FROM aa_Reports a inner join aa_ReportGroups b on a.reportgroupid = b.reportgroupid
WHERE b.GroupName != 'HHA Reports'

--Parameters 1

Select * FROM aa_ReportParameters ORDER BY ReportID, Position

--Queries 2

Select a.ReportID
, a.ReportName
, a.QueryCategoryID
, c.sbCatID
, c.sbCategory
, d.qryID
, d.qryName
, d.qryDefinition
 FROM aa_Reports a INNER JOIN aa_Category b 
ON a.QueryCategoryID = b.catID INNER JOIN aa_SBCategory c
ON b.catID = c.catID
INNER JOIN aa_Queries d ON c.QryID = d.qryID

--Excel Mapping 3

Select a.ReportID
, a.ReportName
, a.QueryCategoryID
, c.sbCatID
, c.sbCategory
, d.qryID
, e.xlsCell
, e.xlsTitle
 FROM aa_Reports a INNER JOIN aa_Category b 
ON a.QueryCategoryID = b.catID INNER JOIN aa_SBCategory c
ON b.catID = c.catID
INNER JOIN aa_Queries d ON c.QryID = d.qryID
INNER JOIN aa_XLMaps e ON d.qryID = e.qryID

--Report Box 4

Select 
NULL ReportID
, NULL ReportName
, NULL GeneratedOn
, NULL GeneratedBy
, NULL ReportLink

--Satellites 5

Select FacilityID, FacilityName FROM IQC_SiteDetails 
ORDER BY FacilityID 

--Resources 6

Select NULL ReportID, NULL DisplayName, NULL ResourceURL 

--Report Groups 7

IF EXISTS (Select name from sys.synonyms Where name = N'dtl_HTNPatientProfile')
Select Distinct b.GroupName FROM aa_Reports a inner join aa_ReportGroups b on a.reportgroupid = b.reportgroupid
ELSE 
Select Distinct b.GroupName FROM aa_Reports a inner join aa_ReportGroups b on a.reportgroupid = b.reportgroupid
WHERE b.GroupName != 'HHA Reports'

END