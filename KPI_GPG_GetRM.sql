USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetRM]    Script Date: 05/01/2015 10:57:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetRM] 
AS

SELECT ResourceAlias,ResourceName,RoleID
FROM dbo.KPI_GPGResource 
ORDER BY ResourceName ASC
