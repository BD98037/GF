USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetRoles]    Script Date: 05/01/2015 10:57:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetRoles]
AS
SELECT * FROM dbo.KPI_GPGRoleLookUp
WHERE Hide = 0
ORDER BY RoleID ASC