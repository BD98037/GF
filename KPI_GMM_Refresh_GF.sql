USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_Refresh_GF]    Script Date: 05/01/2015 10:50:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_Refresh_GF]
AS
/*
Need to refresh [dbo].[SetVIPAssignment_Snapshot] on the 12 first before execute this
*/

EXEC dbo.KPI_GMM_SetVIP_Hierarchy

EXEC dbo.KPI_GMM_SetBottomUpAssignments

EXEC dbo.KPI_GMM_SetHFSTargets

EXEC dbo.KPI_GMM_SetNOofLeads

