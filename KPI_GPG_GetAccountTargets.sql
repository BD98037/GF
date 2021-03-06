USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetAccountTargets]    Script Date: 05/01/2015 10:56:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetAccountTargets]
AS

SELECT h.*,ISNULL(a.ReveneManager,'Unassigned') RM,ISNULL(a.[SDMM/VP],'Unassigned') SDMM,ISNULL(a.GlobalOwner,'Unassigned') GlobalOwner,ISNULL(a.RegionalOwner,'Unassigned') RegionalOwner,
ISNULL(rm.ResourceName,'Unassigned') RMName,ISNULL(sdmm.ResourceName,'Unassigned') SDMMName,ISNULL(g.ResourceName,'Unassigned') GlobalOwnerName,ISNULL(r.ResourceName,'Unassigned') RegionalOwnerName,
ROUND(ISNULL(t.RateLose_Default,0),1) RateLose_Default,
ROUND(ISNULL(t.InvLose_Default,0),1) InvLose_Default,
ROUND(ISNULL(t.RateLose_Override,0),1) RateLose_Override,
ROUND(ISNULL(t.InvLose_Override,0),1) InvLose_Override

FROM (SELECT DISTINCT ParentChainID,ParentChainName,ChainAccountTypeID,ChainAccountTypeName,SuperRegionID,SuperRegionName 
		FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID IN (1,2,3) AND BusinessModel NOT IN ('Lead','GDS Agency')) h
LEFT JOIN KPI_GPGAccountAssignments a
ON h.ParentChainID = a.ParentChainID
AND h.SuperRegionID = a.SuperRegionID
LEFT JOIN dbo.KPI_GPGResource rm
ON a.ReveneManager = rm.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource sdmm
ON a.[SDMM/VP] = sdmm.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource g
ON a.GlobalOwner = g.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource r
ON a.RegionalOwner = r.ResourceAlias
LEFT JOIN dbo.KPI_GPGAccountTargets t
ON a.ParentChainID = t.ParentChainID AND a.SuperRegionID = t.SuperRegionID

ORDER BY ChainAccountTypeID,h.ParentChainName,h.SuperRegionID


/*UNION  -- acquistions

SELECT h.*,ISNULL(a.ReveneManager,'Unassigned') RM,ISNULL(a.[SDMM/VP],'Unassigned') SDMM,ISNULL(a.GlobalOwner,'Unassigned') GlobalOwner,ISNULL(a.RegionalOwner,'Unassigned') RegionalOwner,
ISNULL(rm.ResourceName,'Unassigned') RMName,ISNULL(sdmm.ResourceName,'Unassigned') SDMMName,ISNULL(g.ResourceName,'Unassigned') GlobalOwnerName,ISNULL(r.ResourceName,'Unassigned') RegionalOwnerName,
ISNULL(t.RateLose_Default,0) RateLose_Default,
ISNULL(t.InvLose_Default,0) InvLose_Default,
ISNULL(t.RateLose_Override,0) RateLose_Override,
ISNULL(t.InvLose_Override,0) InvLose_Override

FROM (SELECT DISTINCT ParentChainID,ParentChainName,ChainAccountTypeID,'Acquisition' ChainAccountTypeName,SuperRegionID,SuperRegionName 
		FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID NOT IN (1,2,3) AND BusinessModel NOT IN ('Lead','GDS Agency')) h
JOIN KPI_GPGAccountAssignments a
ON h.ParentChainID = a.ParentChainID
AND h.SuperRegionID = a.SuperRegionID
LEFT JOIN dbo.KPI_GPGResource rm
ON a.ReveneManager = rm.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource sdmm
ON a.[SDMM/VP] = sdmm.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource g
ON a.GlobalOwner = g.ResourceAlias
LEFT JOIN dbo.KPI_GPGResource r
ON a.RegionalOwner = r.ResourceAlias
LEFT JOIN dbo.KPI_GPGAccountTargets t
ON a.ParentChainID = t.ParentChainID AND a.SuperRegionID = t.SuperRegionID
ORDER BY ChainAccountTypeID,h.ParentChainName,h.SuperRegionID
*/

