IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetReportData_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetReportData_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetReportData_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetReportData_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_GetReportData_IQTools](@reportName as varchar(100)) AS
BEGIN
Select catID, Category,a.[Password] FROM 
aa_Reports a INNER JOIN
aa_Category b ON a.QueryCategoryID = b.catID
Where a.ReportName = @reportName AND (b.Deleteflag = 0 OR b.Deleteflag IS NULL)

--Queries
Select Distinct a.qryID, a.qryName, a.qryDefinition 
FROM aa_Queries a INNER JOIN aa_SBCategory b ON a.qryID = b.QryID
INNER JOIN aa_Category c ON b.catID = c.catID
INNER JOIN aa_Reports d ON c.catID = d.QueryCategoryID
Where d.ReportName = @reportName AND (c.Deleteflag = 0 OR c.Deleteflag IS NULL)

--Excel Mapping
Select a.xlsID, a.xlsCell, a.qryID, a.xlsTitle FROM aa_XLMaps a Where qryID IN 
(Select Distinct a.qryID
FROM aa_Queries a INNER JOIN aa_SBCategory b ON a.qryID = b.QryID
INNER JOIN aa_Category c ON b.catID = c.catID
INNER JOIN aa_Reports d ON c.catID = d.QueryCategoryID
Where d.ReportName = @reportName AND (c.Deleteflag = 0 OR c.Deleteflag IS NULL)) 
END

--Facilities
Select FacilityName FROM IQC_SiteDetails

--LineLists
Select c.qryDefinition,a.WorksheetName FROM aa_ReportLineLists a INNER JOIN aa_Reports b ON a.ReportID = b.ReportID
INNER JOIN aa_Queries c ON a.QryID = c.QryID 
Where a.DeleteFlag IS NULL AND b.ReportName = @reportName
GO