IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CheckQuery_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_CheckQuery_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_CheckQuery_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_CheckQuery_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_CheckQuery_IQTools](@qryName as varchar(100)) AS
BEGIN
Select qryID, qryName FROM aa_Queries WHERE qryName =  @qryName
END
GO