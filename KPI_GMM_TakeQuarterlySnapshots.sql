USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_TakeQuarterlySnapshots]    Script Date: 05/01/2015 10:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_TakeQuarterlySnapshots]
@QuarterBeginDate DateTime
AS

/*
[dbo].[KPI_GMM_TakeQuarterlySnapshots] '1/1/2015'
*/

IF Not Exists(SELECT TOP 1* FROM KPI_GMM_VIP_Hierarchy_Snapshot 
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)				
INSERT INTO  KPI_GMM_VIP_Hierarchy_Snapshot
select *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMM_VIP_Hierarchy


IF Not Exists(SELECT TOP 1* FROM dbo.KPI_GMM_BottomUpAssignments_Snapshot 
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)				
INSERT INTO  dbo.KPI_GMM_BottomUpAssignments_Snapshot
select *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM dbo.KPI_GMM_BottomUpAssignments

IF Not Exists(SELECT TOP 1* FROM KPI_GMMHFSTarget_Snapshot 
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)
INSERT INTO KPI_GMMHFSTarget_Snapshot 
SELECT *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMMHFSTarget

IF Not Exists(SELECT TOP 1* FROM KPI_GMMNOofLeads_Snapshot
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)
INSERT INTO  KPI_GMMNOofLeads_Snapshot
SELECT *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMMNOofLeads

IF Not Exists(SELECT TOP 1* FROM KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions_Snapshot
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)
INSERT INTO  KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions_Snapshot
SELECT *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions


IF Not Exists(SELECT TOP 1* FROM KPI_GMMTimeAndWeightAllocationsByRegionExceptions_Snapshot
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)
INSERT INTO  KPI_GMMTimeAndWeightAllocationsByRegionExceptions_Snapshot
SELECT *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMMTimeAndWeightAllocationsByRegionExceptions


IF Not Exists(SELECT TOP 1* FROM KPI_GMMTimeAndWeightAllocationsBySuperRegion_Snapshot
				WHERE SnapshotQuarterBeginDate=@QuarterBeginDate)
INSERT INTO  KPI_GMMTimeAndWeightAllocationsBySuperRegion_Snapshot
SELECT *,@QuarterBeginDate [SnapshotQuarterBeginDate] FROM KPI_GMMTimeAndWeightAllocationsBySuperRegion

