USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetTeams]    Script Date: 05/01/2015 10:57:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GPG_GetTeams]
AS

SELECT * FROM KPI_GPGTeams

ORDER BY TeamID