USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetAccountAcqTargets]    Script Date: 05/01/2015 10:55:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetAccountAcqTargets]
AS


/*SELECT h.*,
ISNULL(Country,'All') Country,
ISNULL(Acquisition_Default,0) Acquisition_Default,
ISNULL(Acquisition_Override,0) Acquisition_Override

FROM (SELECT DISTINCT ParentChainID,ParentChainName,SuperRegionID,SuperRegionName,ChainAccountTypeID,ChainAccountTypeName 
		FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID IN (1,2,3) AND BusinessModel NOT IN ('Lead','GDS Agency')) h
LEFT JOIN dbo.KPI_GPGAccountAssignments a
ON h.ParentChainID = a.ParentChainID AND h.SuperRegionID = a.SuperRegionID
LEFT JOIN dbo.KPI_GPGAccountAcqTargets t
ON h.ParentChainID = t.ParentChainID
AND h.SuperRegionID = t.SuperRegionID

UNION ALL*/

SELECT h.*,
ISNULL(Country,'All') Country,
ISNULL(Acquisition_Default,0) Acquisition_Default,
ISNULL(Acquisition_Override,0) Acquisition_Override

FROM (SELECT DISTINCT ParentChainID,ParentChainName,SuperRegionID,SuperRegionName,ChainAccountTypeID,CASE WHEN ChainAccountTypeID NOT IN (1,2,3)  THEN 'Acquisition' ELSE 'Existing Account' END ChainAccountTypeName
		FROM Pliny.dbo.DimHotelExpand WHERE /*ChainAccountTypeID NOT IN (1,2,3) AND*/ BusinessModel NOT IN ('Lead','GDS Agency')) h
--JOIN KPI_GPGAccountAssignments a
--ON h.ParentChainID = a.ParentChainID
--AND h.SuperRegionID = a.SuperRegionID
JOIN dbo.KPI_GPGAccountAcqTargets t
ON h.ParentChainID = t.ParentChainID
AND h.SuperRegionID = t.SuperRegionID
ORDER BY ChainAccountTypeName,ParentChainName,SuperRegionName,ISNULL(Country,'All') 

