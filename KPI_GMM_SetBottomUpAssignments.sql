USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_SetBottomUpAssignments]    Script Date: 05/01/2015 10:51:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_SetBottomUpAssignments]
AS

/*
SELECT 
DISTINCT AMTID,MAAID
INTO #MAAs
FROM
(
SELECT
AMTID,AMTNAME,MMAID,MMAName,MAAID,MAAName, COUNT(*) HotelCnt,
RANK() OVER(PARTITION BY MAAID,MAAName ORDER BY COUNT(*) DESC) Rnk
FROM [dbo].[SIP_Hierrachy]
GROUP BY AMTID,AMTNAME,MMAID,MMAName,MAAID,MAAName
) s
WHERE Rnk = 1
*/
	   SELECT 
	   RoleID
      ,[RoleName]
      ,[TerritoryID]
      ,[TerritoryLevelID]
      ,'SMT' [TerritoryLevelCode]
      ,[UserID]
      ,UserLogin [UserAlias]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName] 
	  INTO #VIPAssignment
	  FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPSMTAssignment_CQ
      
      UNION ALL
      
       SELECT 
	   RoleID
      ,[RoleName]
      ,[TerritoryID]
      ,[TerritoryLevelID]
      ,'AMT' [TerritoryLevelCode]
      ,[UserID]
      ,UserLogin [UserAlias]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName] 
	  FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPAMTAssignment_CQ
      
      UNION ALL
      
       SELECT 
	   RoleID
      ,[RoleName]
      ,[TerritoryID]
      ,[TerritoryLevelID]
      ,'MMA' [TerritoryLevelCode]
      ,[UserID]
      ,UserLogin [UserAlias]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName] 
      FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPMMAAssignment_CQ
      
      UNION ALL
      
       SELECT 
	   RoleID
      ,[RoleName]
      ,[TerritoryID]
      ,[TerritoryLevelID]
      ,'MAA' [TerritoryLevelCode]
      ,[UserID]
      ,UserLogin [UserAlias]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName] 
      FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPMAAAssignment_CQ
      
TRUNCATE TABLE dbo.KPI_GMM_BottomUpAssignments	
INSERT INTO dbo.KPI_GMM_BottomUpAssignments	
SELECT DISTINCT
	   ISNULL(r.RoleBucketID,CASE t.TerritoryLevelID WHEN 40 THEN 1 WHEN 50 THEN 2 WHEN 60 THEN 3 END) RoleBucketID
	  ,ISNULL(r.RoleBucketDesc,'Unassigned') RoleBucketDesc
	  ,ISNULL(r.[RoleID],0) RoleID
      ,ISNULL(r.[RoleDescription],'Unassigned') RoleDescription
      ,t.TerritoryLevelID
      ,t.TerritoryLevelCode
      ,ISNULL([UserID],0) UserID
      ,ISNULL([UserAlias],'Unassigned') UserAlias
      ,ISNULL([FirstName],'Unassigned') FirstName
      ,ISNULL([MiddleName],'') MiddleName
      ,ISNULL([LastName],'') LastName
      ,t.[TerritoryID]
      ,t.TerritoryName
  FROM dbo.KPI_GMM_VIP_Territories t
  LEFT JOIN  #VIPAssignment a ON a.TerritoryID = t.TerritoryID AND a.TerritoryLevelID = t.TerritoryLevelID  
  LEFT JOIN [dbo].[KPIRoleLookUp] r ON a.RoleID = r.RoleID 
 