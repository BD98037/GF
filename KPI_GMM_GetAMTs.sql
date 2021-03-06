USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_GetAMTs]    Script Date: 05/01/2015 10:50:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_GetAMTs] 
@RegionIDs VarChar(4000) = NULL
AS


SELECT DISTINCT AMTID ID, AMTNAME Name
FROM dbo.KPI_GMM_VIP_Hierarchy sip
JOIN (SELECT [STR] RegionID FROM Pliny.dbo.charlist_to_table(@RegionIDs,DEFAULT)) r
ON sip.RegionID = r.RegionID
UNION ALL 
SELECT -1 ID ,'Select an AMT' Name
ORDER BY 1 ASC