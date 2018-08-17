IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueries_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetQueries_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueries_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetQueries_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_GetQueries_IQTools] (@EMR as varchar(10))
AS
BEGIN
Select a.qryID
, a.qryName QueryName
, a.qryDefinition
, a.qryDescription QueryDescription
, b.sbCategory SubCategory
, c.Category
, Case WHEN a.qryDefinition LIKE '%COUNT%' AND a.qryDefinition LIKE '%@%' THEN 1 ELSE 0 END AS Report 
, CASE WHEN a.qryDefinition LIKE '%COUNT%' THEN 1 ELSE 0 END AS [Aggregate]
, CASE WHEN a.qryName LIKE '%IQC%' THEN 1 ELSE 0 END AS [System]
, CASE WHEN a.qryDescription LIKE '%Line%' THEN 1 ELSE 0 END AS LineList
, 0 MyQueries
 FROM aa_Queries a left join aa_sbCategory b On a.qryID = b.QryID left join aa_Category c On b.catID = c.catID
And (a.Deleteflag IS NULL Or a.Deleteflag = 0)
UNION
Select a.qryID
, a.qryName
, a.qryDefinition
, a.qryDescription
, b.sbCategory
, c.Category
, 0 Report 
, 0 [Aggregate]
, 0 [System]
, 0 LineList
, 1 MyQueries
 FROM aa_UserQueries a left join aa_UserSBCategory b On a.qryID = b.QryID left join aa_UserCategory c On b.catID = c.catID
And (a.Deleteflag IS NULL Or a.Deleteflag = 0)

END
GO
