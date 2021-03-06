USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_TeamEntryActions]    Script Date: 05/01/2015 10:58:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_TeamEntryActions] 
@ActionID int,
@ResourceAlias varchar(100),
@ResourceName varchar(100),
@ResourceRole int,
@Updatedby varchar(100),
@OriginalAlias varchar(100),
@TeamID int = null
AS

/*
0 = Delete
1 = update
2 = add
*/
IF(@ActionID = 0)
	BEGIN
		DELETE FROM dbo.KPI_GPGResource WHERE ResourceAlias = @OriginalAlias
	END
ELSE IF(@ActionID = 1)
		BEGIN
			IF(EXISTS(SELECT * FROM dbo.KPI_GPGResource WHERE ResourceAlias = @OriginalAlias))
				BEGIN
					UPDATE dbo.KPI_GPGResource 
					SET ResourceAlias = @ResourceAlias,
						ResourceName = @ResourceName,
						RoleID = @ResourceRole,
						Updatedby = @Updatedby,
						UpdatedDate = GETDATE(),
						TeamID = @TeamID
					WHERE ResourceAlias = @OriginalAlias
				END
		END
		ELSE IF(@ActionID = 2)
				BEGIN
					INSERT INTO dbo.KPI_GPGResource (ResourceAlias,ResourceName,RoleID,UpdatedBy,UpdatedDate,TeamID)
					SELECT @ResourceAlias,@ResourceName,@ResourceRole,@Updatedby,GETDATE(),@TeamID
				END
