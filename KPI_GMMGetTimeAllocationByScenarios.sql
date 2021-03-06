USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMMGetTimeAllocationByScenarios]    Script Date: 05/01/2015 10:54:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GMMGetTimeAllocationByScenarios] 
@IDToPull int =1,
@Level int = 1,
@RoleBucketID int = 0
AS
/*
[dbo].[KPI_GMMGetTimeAllocationByScenarios]  2,1
[dbo].[KPI_GMMGetTimeAllocationByScenarios]  94277,0
[dbo].[KPI_GMMGetTimeAllocationByScenarios]  175,2,0
*/
            
IF(@Level=1)--VP
	BEGIN
		SELECT DISTINCT CASE ISNULL(t.[ScenarioID],0) WHEN 1 THEN 'Package destinations' WHEN 0 THEN  'Non Package destinations' ELSE 'N/A' END [Pkg_Scenario]
			,t.[RoleBucketID],[ScenarioID],l.RoleBucketDesc,t.SuperRegionID
			,Convert(int,Round(t.tTeamMgmt*100,0))  AS TeamManagement_Allocation
			,Convert(int,Round(t.tAccntMgmt*100,0))  AS AccntManagement_Allocation
			,Convert(int,Round(t.tBML*100,0)) AS BML_Allocation
			,Convert(int,Round(t.tAcq*100,0))  AS Acquisition_Allocation
			,Convert(int,Round(t.tHFS*100,0))  AS HFS_Allocation
			,Convert(int,Round(t.tLocalProjects*100,0))  AS LocalProjects_Allocation
			,Convert(int,Round(t.tPTO*100,0))  AS PTO_Allocation

			,Convert(float,t.wRMD)*100 AS RMD_Weights
			,Convert(float,t.wNRN)*100 AS NRN_Weights
			,Convert(float,t.wRate)*100 AS Rate_Weights
			,Convert(float,t.wInv)*100 AS Inv_Weights
			,Convert(float,t.wHFS)*100 AS HFS_Weights
			,Convert(float,t.wAcq)*100 AS Acquisition_Weights

			FROM dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion t  
			JOIN (SELECT DISTINCT RoleBucketID, RoleBucketDesc FROM dbo.KPIRoleLookUp WHERE RoleBucketID>0) l
			ON l.RoleBucketID = t.RoleBucketID 
			WHERE SuperRegionID =@IDToPull
			ORDER BY t.RoleBucketID,t.ScenarioID ASC

	END
ELSE IF(@Level=0)--DMM
	BEGIN
		SELECT DISTINCT CASE ISNULL(t.[ScenarioID],0) WHEN 1 THEN 'Package destinations' WHEN 0 THEN  'Non Package destinations' ELSE 'N/A' END [Pkg_Scenario]
			,t.[RoleBucketID],t.[ScenarioID],l.RoleBucketDesc,s.RegionID
			,Convert(int,Round(COALESCE(t.tTeamMgmt,e.tTeamMgmt)*100,0))  AS TeamManagement_Allocation
			,Convert(int,Round(COALESCE(t.tAccntMgmt,e.tAccntMgmt)*100,0))  AS AccntManagement_Allocation
			,Convert(int,Round(COALESCE(t.tBML,e.tBML)*100,0)) AS BML_Allocation
			,Convert(int,Round(COALESCE(t.tAcq,e.tAcq)*100,0))  AS Acquisition_Allocation
			,Convert(int,Round(COALESCE(t.tHFS,e.tHFS)*100,0))  AS HFS_Allocation
			,Convert(int,Round(COALESCE(t.tLocalProjects,e.tLocalProjects)*100,0))  AS LocalProjects_Allocation
			,Convert(int,Round(COALESCE(t.tPTO,e.tPTO)*100,0))  AS PTO_Allocation

			,COALESCE(t.wRMD,e.wRMD)*100 AS RMD_Weights
			,COALESCE(t.wNRN,e.wNRN)*100 AS NRN_Weights
			,COALESCE(t.wRate,e.wRate)*100 AS Rate_Weights
			,COALESCE(t.wInv,e.wInv)*100 AS Inv_Weights
			,COALESCE(t.wHFS,e.wHFS)*100 AS HFS_Weights
			,COALESCE(t.wAcq,e.wAcq)*100 AS Acquisition_Weights
			
			FROM dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion t
				JOIN (SELECT DISTINCT RegionID,SuperRegionID FROM dbo.KPI_GMM_VIP_Hierarchy WHERE RegionID =@IDToPull) s
				ON t.SuperregionID = s.SuperRegionID
				JOIN (SELECT DISTINCT RoleBucketID, RoleBucketDesc FROM dbo.KPIRoleLookUp WHERE RoleBucketID>0) l
				ON l.RoleBucketID = t.RoleBucketID 
				LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions e
				ON s.RegionID = e.RegionID
			ORDER BY t.RoleBucketID,t.ScenarioID ASC
			
		
	END
ELSE IF(@Level=2)--AMT/MMA/MAA
	BEGIN
	
	SELECT DISTINCT 40 TerritoryLevelID, 'AMT' TerritoryLevelCode, AMTID TerritoryID, AMTName TerritoryName, RegionID,SuperRegionID
		INTO #Territories
		FROM dbo.KPI_GMM_VIP_Hierarchy WHERE AMTID = @IDToPull 
	UNION ALL
	SELECT DISTINCT 50 TerritoryLevelID, 'MMA' TerritoryLevelCode, MMAID TerritoryID, MMAName TerritoryName, RegionID, SuperRegionID
		FROM dbo.KPI_GMM_VIP_Hierarchy WHERE AMTID = @IDToPull AND MMAID>0
	UNION ALL 
	SELECT DISTINCT 60 TerritoryLevelID,'MAA' TerritoryLevelCode, MAAID TerritoryID,MAAName TerritoryName, RegionID, SuperRegionID
		FROM dbo.KPI_GMM_VIP_Hierarchy WHERE AMTID = @IDToPull AND MAAID>0
		
	CREATE TABLE #RoleBuckets(RoleBucketID int)
	
	IF(@RoleBucketID =0)
		BEGIN
			INSERT INTO #RoleBuckets
			SELECT DISTINCT RoleBucketID
				FROM KPIRoleLookUp WHERE RoleBucketID IN (1,2,3,0)
		END
	ELSE 
		BEGIN
			INSERT INTO #RoleBuckets
			SELECT DISTINCT RoleBucketID
				FROM KPIRoleLookUp WHERE RoleBucketID =@RoleBucketID
		END
		
	
		BEGIN
			SELECT DISTINCT
							st.TerritoryLevelID,
							st.TerritoryLevelCode,
							st.TerritoryID,
							st.TerritoryName,
							ISNULL(a.RoleBucketID,0) RoleBucketID,
							ISNULL(a.RoleBucketDesc,'Unassigned') RoleBucketDesc,
							ISNULL(a.FirstName + ' ' + a.LastName,'Unassigned') ResourceName,
							ISNULL(a.UserID,0) ResourceID,
							ISNULL(a.RoleID,0) RoleID,
							ISNULL(a.RoleDescription,'Unassigned') RoleDescription
							,Convert(int,Round(COALESCE(t.tTeamMgmt,r.tTeamMgmt,sr.tTeamMgmt,0)*100,0))  AS TeamManagement_Allocation
							,Convert(int,Round(COALESCE(t.tAccntMgmt,r.tAccntMgmt,sr.tAccntMgmt,0)*100,0))  AS AccntManagement_Allocation
							,Convert(int,Round(COALESCE(t.tBML,r.tBML,sr.tBML,0)*100,0)) AS BML_Allocation
							,Convert(int,Round(COALESCE(t.tAcq,r.tAcq,sr.tAcq,0)*100,0))  AS Acquisition_Allocation
							,Convert(int,Round(COALESCE(t.tHFS,r.tHFS,sr.tHFS,0)*100,0))  AS Pkg_Allocation
							,Convert(int,Round(COALESCE(t.tLocalProjects,r.tLocalProjects,sr.tLocalProjects,0)*100,0))  AS LocalProjects_Allocation
							,Convert(int,Round(COALESCE(t.tPTO,r.tPTO,sr.tPTO,0)*100,0))  AS PTO_Allocation
							,Round(COALESCE(t.wRMD,r.wRMD,sr.wRMD,0)*100,1) AS RMD_Weights
							,Round(COALESCE(t.wNRN,r.wNRN,sr.wNRN,0)*100,1) AS NRN_Weights
							,Round(COALESCE(t.wRate,r.wRate,sr.wRate,0)*100,1) AS Rate_Weights
							,Round(COALESCE(t.wInv,r.wInv,sr.wInv,0)*100,1) AS Inv_Weights
							,Round(ISNULL(CASE ISNULL(HFS_Target,0) WHEN 0 THEN 0 ELSE COALESCE(t.wHFS,r.wHFS,sr.wHFS,0)*100 END,0),1) AS Package_Weights
							,Round(COALESCE(t.wAcq,r.wAcq,sr.wAcq,0)*100,1) AS Acquisition_Weights
							,Round(ISNULL(Convert(decimal(31,1),HFS_Target*100),0),1) HFS_Target
							,ISNULL(NO_Leads,0) NO_Leads
							
						 FROM #Territories st
							JOIN dbo.KPI_GMM_BottomUpAssignments a 
							ON a.TerritoryLevelID = st.TerritoryLevelID AND a.TerritoryID = st.TerritoryID	
							JOIN #RoleBuckets rl 
							ON a.RoleBucketID = rl.RoleBucketID	
							LEFT JOIN KPI_GMMHFSTarget hfs 
							ON hfs.TerritoryID = st.TerritoryID AND hfs.TerritoryLevelID = st.TerritoryLevelID
							LEFT JOIN [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] t
							ON a.TerritoryLevelID = t.TerritoryLevelID 
							AND a.TerritoryID = t.TerritoryID
							AND a.UserID = t.UserID
							LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions r 
							ON st.RegionID = r.RegionID	AND (r.RoleBucketID = CASE a.RoleBucketID WHEN 0 THEN CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END ELSE a.RoleBucketID END) AND r.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END
							LEFT JOIN dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion sr
							ON st.SuperRegionID = sr.SuperregionID AND (sr.RoleBucketID = CASE a.RoleBucketID WHEN 0 THEN CASE st.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END ELSE a.RoleBucketID END) AND sr.ScenarioID = CASE WHEN HFS_Target >0 THEN 1 ELSE 0 END
							LEFT JOIN KPI_GMMNOofLeads le ON le.TerritoryID = st.TerritoryID AND le.TerritoryLevelID = st.TerritoryLevelID


						ORDER BY st.TerritoryLevelID,ISNULL(a.RoleBucketDesc,'Unassigned'),st.TerritoryName ASC
		END
	END