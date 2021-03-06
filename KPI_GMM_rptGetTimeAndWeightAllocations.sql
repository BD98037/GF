USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_rptGetTimeAndWeightAllocations]    Script Date: 05/01/2015 10:51:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_rptGetTimeAndWeightAllocations]  -- KPI_GMM_rptGetTimeAndWeightAllocations 3,'4/1/2015'
@SuperRegions Varchar(400),
@QuarterSnapshot DateTime = NULL

AS

DECLARE @MaxUpdateDate DateTime
SELECT @MaxUpdateDate = MAX(Update_Date) FROM dbo.vVIPAssignment_SnapShot WHERE SnapshotQuarterBeginDate=@QuarterSnapshot


CREATE TABLE #Territories 
(
TerritoryLevelID Int, 
TerritoryLevelCode Varchar(10), 
TerritoryID Int,
TerritoryName Varchar(80),
AMTID Int,
AMTName Varchar(80), 
RegionID Int,
RegionName Varchar(80),
SuperRegionID Int,
SuperRegionName Varchar(80),
SnapshotQuarterBeginDate DateTime
)

SELECT * INTO #DMMs FROM dbo.SIP_AssignmentRules
WHERE TerritoryLevelID = 30 --AND @QuarterSnapshot = h.SnapshotQuarterBeginDate


IF(@MaxUpdateDate >= @QuarterSnapshot)
	BEGIN
		INSERT INTO #Territories 
		SELECT DISTINCT 30 TerritoryLevelID, 'Region' TerritoryLevelCode, RegionID TerritoryID, RegionName TerritoryName,0 AMTID, NULL AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,SnapshotQuarterBeginDate
			FROM KPI_GMM_VIP_Hierarchy_Snapshot h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE AMTID>0 AND @QuarterSnapshot = h.SnapshotQuarterBeginDate
		UNION ALL
		SELECT DISTINCT 40 TerritoryLevelID, 'AMT' TerritoryLevelCode, AMTID TerritoryID, AMTName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,SnapshotQuarterBeginDate
			FROM KPI_GMM_VIP_Hierarchy_Snapshot h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE AMTID>0 AND @QuarterSnapshot = h.SnapshotQuarterBeginDate
		UNION ALL
		SELECT DISTINCT 50 TerritoryLevelID, 'MMA' TerritoryLevelCode, MMAID TerritoryID, MMAName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,SnapshotQuarterBeginDate
			FROM KPI_GMM_VIP_Hierarchy_Snapshot h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE MMAID>0 AND @QuarterSnapshot = h.SnapshotQuarterBeginDate
		UNION ALL 
		SELECT DISTINCT 60 TerritoryLevelID,'MAA' TerritoryLevelCode, MAAID TerritoryID,MAAName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,SnapshotQuarterBeginDate
			FROM KPI_GMM_VIP_Hierarchy_Snapshot h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERe MAAID>0 AND @QuarterSnapshot = h.SnapshotQuarterBeginDate
				
		SELECT DISTINCT
			st.SuperRegionName,
			st.SuperRegionID,
			st.RegionName,
			st.RegionID,
			st.AMTID,
			st.AMTName,
			st.TerritoryLevelID,
			st.TerritoryLevelCode,
			st.TerritoryID,
			st.TerritoryName,
			ISNULL(a.RoleBucketID,0) RoleBucketID,
			ISNULL(a.RoleBucketDesc,'Unassigned') RoleBucketDesc,
			COALESCE(a.FirstName + ' ' + a.LastName,dmm.FirstName + ' ' + dmm.LastName,  'Unassigned') ResourceName,
			COALESCE(a.UserID,dmm.UserID, 0) ResourceID,
			COALESCE(a.RoleID,dmm.RoleID,0) RoleID,
			COALESCE(a.RoleDescription,dmm.RoleName, 'Unassigned') RoleDescription
			,Convert(int,Round(COALESCE(t.tTeamMgmt,r.tTeamMgmt,sr.tTeamMgmt,0)*100,0))  AS TeamManagement_Allocation
			,Convert(int,Round(COALESCE(t.tAccntMgmt,r.tAccntMgmt,sr.tAccntMgmt,0)*100,0))  AS AccntManagement_Allocation
			,Convert(int,Round(COALESCE(t.tBML,r.tBML,sr.tBML,0)*100,0)) AS BML_Allocation
			,Convert(int,Round(COALESCE(t.tAcq,r.tAcq,sr.tAcq,0)*100,0))  AS Acquisition_Allocation
			,Convert(int,Round(COALESCE(t.tHFS,r.tHFS,sr.tHFS,0)*100,0))  AS Pkg_Allocation
			,Convert(int,Round(COALESCE(t.tLocalProjects,r.tLocalProjects,sr.tLocalProjects,0)*100,0))  AS LocalProjects_Allocation
			,Convert(int,Round(COALESCE(t.tPTO,r.tPTO,sr.tPTO,0)*100,0))  AS PTO_Allocation
			,COALESCE(t.wRMD,r.wRMD,sr.wRMD,0)*100 AS RMD_Weights
			,COALESCE(t.wNRN,r.wNRN,sr.wNRN,0)*100 AS NRN_Weights
			,COALESCE(t.wRate,r.wRate,sr.wRate,0)*100 AS Rate_Weights
			,COALESCE(t.wInv,r.wInv,sr.wInv,0)*100 AS Inv_Weights
			,CASE HFS_Target WHEN 0 THEN 0 ELSE COALESCE(t.wHFS,r.wHFS,sr.wHFS,0)*100 END AS Package_Weights
			,COALESCE(t.wAcq,r.wAcq,sr.wAcq,0)*100 AS Acquisition_Weights
			,Convert(decimal(31,1),HFS_Target*100) HFS_Target
			,ISNULL(NO_Leads,0) NO_Leads
			,ISNULL(hfs.NUM_HFS,0) NUM_HFS
			,ISNULL(hfs.DENOM_HFS,0) DENOM_HFS
			
		 FROM #Territories st
			LEFT JOIN dbo.KPI_GMM_BottomUpAssignments_Snapshot a 
			ON a.TerritoryLevelID = st.TerritoryLevelID AND a.TerritoryID = st.TerritoryID	AND a.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN KPI_GMMHFSTarget_Snapshot hfs 
			ON hfs.TerritoryID = st.TerritoryID AND hfs.TerritoryLevelID = st.TerritoryLevelID AND hfs.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions_Snapshot] t
			ON a.TerritoryLevelID = t.TerritoryLevelID AND a.TerritoryID = t.TerritoryID AND a.UserID = t.UserID AND t.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions_Snapshot r 
			ON st.RegionID = r.RegionID	AND (a.RoleBucketID = r.RoleBucketID OR r.RoleBucketID = CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END) AND r.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END AND r.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion_Snapshot sr
			ON st.SuperRegionID = sr.SuperregionID AND (a.RoleBucketID = sr.RoleBucketID OR sr.RoleBucketID = CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END) AND sr.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END AND sr.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN KPI_GMMNOofLeads_Snapshot le 
			ON le.TerritoryID = st.TerritoryID AND le.TerritoryLevelID = st.TerritoryLevelID AND le.SnapshotQuarterBeginDate = st.SnapshotQuarterBeginDate
			LEFT JOIN #DMMs dmm
			ON st.TerritoryLevelID = dmm.TerritoryLevelID
			AND st.TerritoryID = dmm.TerritoryID 
			
			
		ORDER BY RegionName,AMTID,st.TerritoryLevelID,ISNULL(a.RoleBucketDesc,'Unassigned'),st.TerritoryName ASC
	END
	ELSE -- if it is the current quarter
		BEGIN
			INSERT INTO #Territories 
			SELECT DISTINCT 30 TerritoryLevelID, 'Region' TerritoryLevelCode, RegionID TerritoryID, RegionName TerritoryName,0 AMTID, NULL AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,@QuarterSnapshot
			FROM KPI_GMM_VIP_Hierarchy h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE AMTID>0 
		UNION ALL
		SELECT DISTINCT 40 TerritoryLevelID, 'AMT' TerritoryLevelCode, AMTID TerritoryID, AMTName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,@QuarterSnapshot
			FROM KPI_GMM_VIP_Hierarchy h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE AMTID>0
		UNION ALL
		SELECT DISTINCT 50 TerritoryLevelID, 'MMA' TerritoryLevelCode, MMAID TerritoryID, MMAName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,@QuarterSnapshot
			FROM KPI_GMM_VIP_Hierarchy h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERE MMAID>0
		UNION ALL 
		SELECT DISTINCT 60 TerritoryLevelID,'MAA' TerritoryLevelCode, MAAID TerritoryID,MAAName TerritoryName,AMTID, AMTName, RegionID,RegionName,h.SuperRegionID,SuperRegionName,@QuarterSnapshot
			FROM KPI_GMM_VIP_Hierarchy h
			JOIN (SELECT [STR] SuperRegionID FROM dbo.charlist_to_table(@SuperRegions,DEFAULT)) sr
			ON h.SuperRegionID = sr.SuperRegionID WHERe MAAID>0
			
		SELECT DISTINCT
			st.SuperRegionName,
			st.SuperRegionID,
			st.RegionName,
			st.RegionID,
			st.AMTID,
			st.AMTName,
			st.TerritoryLevelID,
			st.TerritoryLevelCode,
			st.TerritoryID,
			st.TerritoryName,
			ISNULL(a.RoleBucketID,0) RoleBucketID,
			ISNULL(a.RoleBucketDesc,'Unassigned') RoleBucketDesc,
			COALESCE(a.FirstName + ' ' + a.LastName,dmm.FirstName + ' ' + dmm.LastName,  'Unassigned') ResourceName,
			COALESCE(a.UserID,dmm.UserID, 0) ResourceID,
			COALESCE(a.RoleID,dmm.RoleID,0) RoleID,
			COALESCE(a.RoleDescription,dmm.RoleName, 'Unassigned') RoleDescription
			,Convert(int,Round(COALESCE(t.tTeamMgmt,r.tTeamMgmt,sr.tTeamMgmt,0)*100,0))  AS TeamManagement_Allocation
			,Convert(int,Round(COALESCE(t.tAccntMgmt,r.tAccntMgmt,sr.tAccntMgmt,0)*100,0))  AS AccntManagement_Allocation
			,Convert(int,Round(COALESCE(t.tBML,r.tBML,sr.tBML,0)*100,0)) AS BML_Allocation
			,Convert(int,Round(COALESCE(t.tAcq,r.tAcq,sr.tAcq,0)*100,0))  AS Acquisition_Allocation
			,Convert(int,Round(COALESCE(t.tHFS,r.tHFS,sr.tHFS,0)*100,0))  AS Pkg_Allocation
			,Convert(int,Round(COALESCE(t.tLocalProjects,r.tLocalProjects,sr.tLocalProjects,0)*100,0))  AS LocalProjects_Allocation
			,Convert(int,Round(COALESCE(t.tPTO,r.tPTO,sr.tPTO,0)*100,0))  AS PTO_Allocation
			,COALESCE(t.wRMD,r.wRMD,sr.wRMD,0)*100 AS RMD_Weights
			,COALESCE(t.wNRN,r.wNRN,sr.wNRN,0)*100 AS NRN_Weights
			,COALESCE(t.wRate,r.wRate,sr.wRate,0)*100 AS Rate_Weights
			,COALESCE(t.wInv,r.wInv,sr.wInv,0)*100 AS Inv_Weights
			,CASE HFS_Target WHEN 0 THEN 0 ELSE COALESCE(t.wHFS,r.wHFS,sr.wHFS,0)*100 END AS Package_Weights
			,COALESCE(t.wAcq,r.wAcq,sr.wAcq,0)*100 AS Acquisition_Weights
			,Convert(decimal(31,1),HFS_Target*100) HFS_Target
			,ISNULL(NO_Leads,0) NO_Leads
			,ISNULL(hfs.NUM_HFS,0) NUM_HFS
			,ISNULL(hfs.DENOM_HFS,0) DENOM_HFS
			
		 FROM #Territories st
			LEFT JOIN dbo.KPI_GMM_BottomUpAssignments a 
			ON a.TerritoryLevelID = st.TerritoryLevelID AND a.TerritoryID = st.TerritoryID
			LEFT JOIN KPI_GMMHFSTarget hfs 
			ON hfs.TerritoryID = st.TerritoryID AND hfs.TerritoryLevelID = st.TerritoryLevelID
			LEFT JOIN [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] t
			ON a.TerritoryLevelID = t.TerritoryLevelID AND a.TerritoryID = t.TerritoryID AND a.UserID = t.UserID
			LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions r 
			ON st.RegionID = r.RegionID	AND (r.RoleBucketID = CASE a.RoleBucketID WHEN 0 THEN CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END ELSE a.RoleBucketID END) AND r.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END
			LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion sr
			ON st.SuperRegionID = sr.SuperregionID AND (sr.RoleBucketID = CASE a.RoleBucketID WHEN 0 THEN CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END ELSE a.RoleBucketID END) AND sr.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END
			LEFT JOIN KPI_GMMNOofLeads le 
			ON le.TerritoryID = st.TerritoryID AND le.TerritoryLevelID = st.TerritoryLevelID
			LEFT JOIN #DMMs dmm
			ON st.TerritoryLevelID = dmm.TerritoryLevelID
			AND st.TerritoryID = dmm.TerritoryID 
			
			
			ORDER BY RegionName,AMTID,st.TerritoryLevelID,ISNULL(a.RoleBucketDesc,'Unassigned'),st.TerritoryName ASC
		END
