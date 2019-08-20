IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueryCategories_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetQueryCategories_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueryCategories_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetQueryCategories_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_GetQueryCategories_IQTools] AS
BEGIN

Select Distinct Category FROM aa_Category Where Deleteflag = 0;
Select Distinct sbCategory, Category FROM aa_sbCategory a inner join aa_Category b 
On a.catID = b.catID
 Where a.DeleteFlag IS NULL

END
GO