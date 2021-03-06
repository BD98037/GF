USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_CarryOver_TerritoryExceptions]    Script Date: 05/01/2015 10:49:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_CarryOver_TerritoryExceptions]
@LastQuarterBeginDate DateTime

/*
dbo.KPI_GMM_CarryOver_TerritoryExceptions '1/1/2015'
*/

AS
-- New quarter territories
SELECT DISTINCT 40 TerritoryLevelID, AMTID TerritoryID, AMTName TerritoryName, RegionID,SuperRegionID
	INTO #Territories
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE AMTID>0 
UNION ALL
SELECT DISTINCT 50 TerritoryLevelID, MMAID TerritoryID, MMAName TerritoryName, RegionID, SuperRegionID
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE MMAID > 0
UNION ALL 
SELECT DISTINCT 60 TerritoryLevelID, MAAID TerritoryID, MAAName TerritoryName,RegionID, SuperRegionID
	FROM dbo.KPI_GMM_VIP_Hierarchy WHERE MAAID > 0

-- Last quarter territories
SELECT DISTINCT 40 TerritoryLevelID, AMTID TerritoryID, AMTName TerritoryName, RegionID,SuperRegionID
	INTO #Territories_Snapshot
	FROM dbo.KPI_GMM_VIP_Hierarchy_Snapshot WHERE AMTID>0 AND SnapshotQuarterBeginDate = @LastQuarterBeginDate 
UNION ALL
SELECT DISTINCT 50 TerritoryLevelID, MMAID TerritoryID, MMAName TerritoryName, RegionID, SuperRegionID
	FROM dbo.KPI_GMM_VIP_Hierarchy_Snapshot WHERE MMAID > 0 AND SnapshotQuarterBeginDate = @LastQuarterBeginDate
UNION ALL 
SELECT DISTINCT 60 TerritoryLevelID, MAAID TerritoryID, MAAName TerritoryName,RegionID, SuperRegionID
	FROM dbo.KPI_GMM_VIP_Hierarchy_Snapshot WHERE MAAID > 0 AND SnapshotQuarterBeginDate = @LastQuarterBeginDate


select e.*
INTO #CarryOver
FROM 	
(	
SELECT e.* ,TerritoryName
  FROM [SSATools].[dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions_snapshot] e
  JOIN #Territories_Snapshot t
  on e.TerritoryID = t.TerritoryID and e.TerritoryLevelID = e.TerritoryLevelID
  WHERE SnapshotQuarterBeginDate = @LastQuarterBeginDate
) e
JOIN #Territories s
ON e.territorylevelid = s.territorylevelid AND e.TerritoryName = s.TerritoryName

UPDATE c
	SET c.UserID = ISNULL(a.UserID,0),
		c.UserAlias = a.UserAlias
  FROM #CarryOver c
  JOIN dbo.KPI_GMM_BottomUpAssignments a
  ON c.TerritoryID = a.TerritoryID AND c.TerritoryLevelID = a.TerritoryLevelID AND a.TerritoryLevelID >60
  
  
TRUNCATE TABLE [SSATools].[dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions]
INSERT INTO [SSATools].[dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions]
SELECT 
[TerritoryLevelID]
      ,[TerritoryID]
      ,[UserID]
      ,[UserAlias]
      ,[tTeamMgmt]
      ,[tAccntmgmt]
      ,[tAcq]
      ,[tBML]
      ,[tHFS]
      ,[tLocalProjects]
      ,[tPTO]
      ,[wRMD]
      ,[wNRN]
      ,[wAcq]
      ,[wHFS]
      ,[wRate]
      ,[wInv]
      ,[ChangedBy]
      ,[ChangedDate]
FROM #CarryOver