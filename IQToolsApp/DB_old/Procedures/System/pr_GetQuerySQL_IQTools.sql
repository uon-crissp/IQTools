IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQuerySQL_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_GetQuerySQL_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_GetQuerySQL_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_GetQuerySQL_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_GetQuerySQL_IQTools] (@qryName varchar(100)) AS
BEGIN

Select qryDefinition querySQL FROM aa_Queries Where qryName = @qryName

END 
GO