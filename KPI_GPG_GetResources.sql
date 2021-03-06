USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetResources]    Script Date: 05/01/2015 10:56:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetResources] --[dbo].[KPI_GPG_GetResources] 0,1
@ActionID int,
@RoleBucketID int = null
AS
/*
0 = Just display resources
1 = Add a resource action
2 = Display by role
*/
IF(@ActionID = 0)
	BEGIN
		IF EXISTS(SELECT * FROM dbo.KPI_GPGResource)
			BEGIN
				SELECT r.ResourceAlias,r.ResourceName,l.RoleID,l.RoleDescription,TeamName,r.TeamID FROM dbo.KPI_GPGRoleLookUp l
				JOIN dbo.KPI_GPGResource r
				ON l.RoleID = r.RoleID
				LEFT JOIN dbo.KPI_GPGTeams t
				ON r.TeamID = t.TeamID
				--WHERE l.Hide = 0
				ORDER BY RoleID ASC
			END
			ELSE
				BEGIN
					SELECT '' ResourceAlias,'' ResourceName,-1 RoleID,'' RoleDescription, '' TeamName,-1 TeamID
				END
				
	END
ELSE IF(@ActionID = 1)
		BEGIN
			SELECT r.ResourceAlias,r.ResourceName,l.RoleID,l.RoleDescription,TeamName,r.TeamID FROM dbo.KPI_GPGRoleLookUp l
			JOIN dbo.KPI_GPGResource r
			ON l.RoleID = r.RoleID
			LEFT JOIN dbo.KPI_GPGTeams t
			ON r.TeamID = t.TeamID
			WHERE l.Hide = 0
			UNION ALL 
			SELECT '' ResourceAlias,'' ResourceName,0 RoleID,'' RoleDescription,'' TeamName, -1 TeamID
			ORDER BY RoleID ASC
		END
		ELSE IF(@ActionID = 2)
		BEGIN
			SELECT r.ResourceAlias,r.ResourceName,r.RoleID,l.RoleBucketID,TeamName,r.TeamID
			FROM dbo.KPI_GPGResource r
			JOIN dbo.KPI_GPGRoleLookUp l 
			ON r.RoleID = l.RoleID 
			LEFT JOIN dbo.KPI_GPGTeams t
			ON r.TeamID = t.TeamID
			WHERE RoleBucketID = @RoleBucketID AND l.Hide = 0
			UNION
			SELECT 'Unassigned' ResourceAlias,'Unassigned' ResourceName,0 RoleID, 0 RoleBucketID,'Unassigned' TeamName,0 TeamID
			ORDER BY RoleID,ResourceName ASC

		END
		
	
