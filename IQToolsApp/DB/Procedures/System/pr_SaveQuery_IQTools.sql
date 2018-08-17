IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_SaveQuery_IQTools]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pr_SaveQuery_IQTools]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pr_SaveQuery_IQTools]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[pr_SaveQuery_IQTools] AS' 
END
GO
ALTER Procedure [dbo].[pr_SaveQuery_IQTools]
(@qryName varchar(50), @qryDescription varchar(200),@qryGroup varchar(10)
, @qryCategory varchar(100)
, @qrySubCategory varchar(100)
, @qrySQL varchar(max)
, @devFlag int
) AS

BEGIN
	Declare @qryID as Int;
	Declare @sbCategoryID as Int;
	Declare @categoryID as Int;
	IF (@devFlag = 1)
	BEGIN
		
		Select @qryID = qryID FROM aa_Queries WHERE QryName = @qryName AND Deleteflag IS NULL;
		Select @sbCategoryID = sbCatID FROM aa_sbCategory WHERE QryID =  @qryID AND sbCategory = @qrySubCategory
		Select @categoryID = CatID FROM aa_Category WHERE Category =  @qryCategory;

		IF EXISTS(Select * FROM aa_Queries WHERE QryName = @qryName)
			BEGIN
			--Update
			UPDATE aa_Queries SET qryDefinition = @qrySQL, qryDescription = qryDescription, qryGroup =@qryGroup, UpdateDate = dbo.fn_GetCurrentDate()
			WHERE qryName = @qryName
			END
		ELSE
			BEGIN
			INSERT INTO aa_Queries(qryName, qryDefinition, qryDescription, CreateDate,qryGroup)
			VALUES
			(@qryName, @qrySQL, @qryDescription, dbo.fn_GetCurrentDate(),@qryGroup)
			Select @qryID = qryID FROM aa_Queries WHERE QryName = @qryName AND Deleteflag IS NULL;
			END

		IF EXISTS (Select * FROM aa_Category WHERE Category = @qryCategory)
			BEGIN
				IF EXISTS (Select * FROM aa_sbCategory WHERE sbCategory = @qrySubCategory)
					BEGIN
						IF (@sbCategoryID IS NOT NULL)
							BEGIN
							UPDATE aa_sbCategory SET UpdateDate = GETDATE() WHERE sbCatID = @sbCategoryID
							END 
						ELSE
						BEGIN
							INSERT INTO aa_sbCategory(sbCategory,catID,QryID, CreateDate)
							VALUES
							(@qrySubCategory,@categoryID,@qryID,getdate())
						END
					END
				ELSE
					BEGIN
						INSERT INTO aa_sbCategory(sbCategory,catID,QryID, CreateDate)
						VALUES
						(@qrySubCategory,@categoryID,NULL,getdate())
						Select @qryID = qryID FROM aa_Queries WHERE QryName = @qryName AND Deleteflag IS NULL
						INSERT INTO aa_sbCategory(sbCategory,catID,QryID, CreateDate)
						VALUES
						(@qrySubCategory,@categoryID,@qryID,getdate())
					END
			END
		ELSE
			BEGIN
				INSERT INTO aa_Category(Category,CreateDate,Deleteflag,Excel)
				VALUES
				(@qryCategory,getdate(),0,1)
				Select @categoryID = CatID FROM aa_Category WHERE Category =  @qryCategory
				INSERT INTO aa_sbCategory(sbCategory,catID,QryID, CreateDate)
				VALUES
				(@qrySubCategory,@categoryID,NULL,getdate())
				Select @qryID = qryID FROM aa_Queries WHERE QryName = @qryName AND Deleteflag IS NULL
				INSERT INTO aa_sbCategory(sbCategory,catID,QryID, CreateDate)
				VALUES
				(@qrySubCategory,@categoryID,@qryID,getdate())
			END

	END	
ELSE 

BEGIN
		Select @qryID = qryID FROM aa_UserQueries WHERE QryName = @qryName AND Deleteflag IS NULL;
		Select @sbCategoryID = sbCatID FROM aa_UserSBCategory WHERE QryID =  @qryID AND sbCategory = @qrySubCategory
		Select @categoryID = CatID FROM aa_UserCategory WHERE Category =  @qryCategory;

		IF EXISTS(Select * FROM aa_UserQueries WHERE QryName = @qryName)
			BEGIN
			--Update
			UPDATE aa_UserQueries SET qryDefinition = @qrySQL, qryDescription = qryDescription, qryGroup =@qryGroup, UpdateDate = dbo.fn_GetCurrentDate()
			WHERE qryName = @qryName
			END
		ELSE
			BEGIN
			INSERT INTO aa_UserQueries(qryName, qryDefinition, qryDescription, CreateDate,qryGroup)
			VALUES
			(@qryName, @qrySQL, @qryDescription, dbo.fn_GetCurrentDate(),@qryGroup)
			END

		IF EXISTS (Select * FROM aa_UserCategory WHERE Category = @qryCategory)
			BEGIN
				IF EXISTS (Select * FROM aa_UserSBCategory WHERE sbCategory = @qrySubCategory)
					BEGIN
						IF (@sbCategoryID IS NOT NULL)
							BEGIN
							UPDATE aa_UserSBCategory SET UpdateDate = GETDATE() WHERE sbCatID = @sbCategoryID
							END 
						ELSE
						BEGIN
							INSERT INTO aa_UserSBCategory(sbCategory,catID,QryID, CreateDate)
							VALUES
							(@qrySubCategory,@categoryID,@qryID,getdate())
						END
					END
				ELSE
					BEGIN
						INSERT INTO aa_UserSBCategory(sbCategory,catID,QryID, CreateDate)
						VALUES
						(@qrySubCategory,@categoryID,NULL,getdate())
						Select @qryID = qryID FROM aa_UserQueries WHERE QryName = @qryName AND Deleteflag IS NULL
						INSERT INTO aa_UserSBCategory(sbCategory,catID,QryID, CreateDate)
						VALUES
						(@qrySubCategory,@categoryID,@qryID,getdate())
					END
			END
		ELSE
			BEGIN
				INSERT INTO aa_UserCategory(Category,CreateDate,Deleteflag,Excel)
				VALUES
				(@qryCategory,getdate(),0,1)
				Select @categoryID = CatID FROM aa_UserCategory WHERE Category =  @qryCategory
				INSERT INTO aa_UserSBCategory(sbCategory,catID,QryID, CreateDate)
				VALUES
				(@qrySubCategory,@categoryID,NULL,getdate())
				Select @qryID = qryID FROM aa_UserQueries WHERE QryName = @qryName AND Deleteflag IS NULL
				INSERT INTO aa_UserSBCategory(sbCategory,catID,QryID, CreateDate)
				VALUES
				(@qrySubCategory,@categoryID,@qryID,getdate())
			END
END
END
GO