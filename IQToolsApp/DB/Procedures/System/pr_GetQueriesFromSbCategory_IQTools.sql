IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueriesFromSbCategory_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetQueriesFromSbCategory_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQueriesFromSbCategory_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetQueriesFromSbCategory_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_GetQueriesFromSbCategory_IQTools] (@EMR as varchar(10),@SBC as Varchar (20),@CATEGORY as Varchar(20))
AS
BEGIN
SELECT  QryDescription Description From (aa_Queries LEFT JOIN aa_SBCategory ON aa_Queries.QryID = aa_SBCategory.QryID) 
LEFT JOIN aa_Category on aa_SBCategory.catID = aa_Category.catID 
WHERE category = @CATEGORY And (aa_Queries.Deleteflag=0 Or aa_Queries.DeleteFlag Is Null) And 
(aa_SBCategory.Deleteflag=0 Or aa_SBCategory.DeleteFlag Is Null) And 
aa_SBCategory.sbCategory=@SBC  
ORDER By aa_Queries.CreateDate
END

GO