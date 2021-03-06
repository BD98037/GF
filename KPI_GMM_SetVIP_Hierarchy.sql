USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_SetVIP_Hierarchy]    Script Date: 05/01/2015 10:53:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_SetVIP_Hierarchy]
AS

SELECT * INTO #DimHotelExpand FROM [CHCXSQLPSG001].GPCMaster.dbo.DimHotelExpand 

SELECT * INTO #VIPHotelHierarchy_NQ  FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPHotelHierarchy_NQ

SELECT * INTO #VIPLeadHierarchy_NQ FROM [CHC-SQLPSG12].VIPAnalytics.[dbo].[VIPLeadHierarchy_NQ]

SELECT * INTO #VIPSMHierarchy_NQ FROM [CHC-SQLPSG12].VIPAnalytics.[dbo].[VIPSMHierarchy_NQ]

SELECT * INTO #Leads FROM [CHCXSQLPSG001].GPCMaster.leads.Masters 

TRUNCATE TABLE KPI_GMM_VIP_Hierarchy
INSERT INTO KPI_GMM_VIP_Hierarchy
SELECT DISTINCT
ISNULL(h.MAAID,0),
ISNULL(h.MAA,'Unassigned'),
ISNULL(h.MMAID,0),
ISNULL(h.MMA,'Unassigned'),
sm.AMTID,
sm.AMT AMTName,
sm.RegionID,
sm.Region RegionName,
sm.SuperRegionID,
sm.SuperRegion SuperRegionName
FROM #VIPHotelHierarchy_NQ h
JOIN #DimHotelExpand  dhe 
ON h.HotelKey = dhe.HotelKey
JOIN #VIPSMHierarchy_NQ sm
ON h.SubmarketID = sm.SubmarketID
WHERE BusinessModel IN ('Merchant','Dual','Direct Agency','Flex')
AND dhe.ExpediaID>0 

UNION 

SELECT DISTINCT
ISNULL(h.MAAID,0),
ISNULL(h.MAA,'Unassigned'),
ISNULL(h.MMAID,0),
ISNULL(h.MMA,'Unassigned'),
sm.AMTID,
sm.AMT AMTName,
sm.RegionID,
sm.Region RegionName,
sm.SuperRegionID,
sm.SuperRegion SuperRegionName
FROM #VIPLeadHierarchy_NQ h
JOIN #Leads   dhe 
ON h.LeadID = dhe.LeadID
JOIN #VIPSMHierarchy_NQ sm
ON h.SubmarketID = sm.SubmarketID
WHERE BusinessModel NOT IN ('Merchant','Dual','Direct Agency','Flex')
AND dhe.EIRMD > 0 
AND ISNULL(dhe.LeadStatus,'') NOT IN ('Wrong Geography','Not a lead (Bad data)') 
AND ISNULL(dhe.SubmarketID,0) > 0


TRUNCATE TABLE dbo.KPI_GMM_VIP_Territories
INSERT INTO dbo.KPI_GMM_VIP_Territories
SELECT DISTINCT 40 TerritoryLevelID, 'AMT' TerritoryLevelCode,
					AMTID TerritoryID, AMTName,
					RegionID, RegionName,
					SuperRegionID, SuperRegionName
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE AMTID>0
UNION ALL
SELECT DISTINCT 50 TerritoryLevelID, 'MMA' TerritoryLevelCode,
					MMAID TerritoryID, MMAName,
					RegionID, RegionName,
					SuperRegionID, SuperRegionName
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE MMAID > 0
UNION ALL 
SELECT DISTINCT 60 TerritoryLevelID,'MAA' TerritoryLevelCode,
					MAAID TerritoryID, MAAName,
					RegionID, RegionName,
					SuperRegionID, SuperRegionName
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE MAAID > 0
