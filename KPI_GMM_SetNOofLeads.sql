USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_SetNOofLeads]    Script Date: 05/01/2015 10:52:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_SetNOofLeads]
AS

SELECT * INTO #VIPLeadHierarchy_NQ FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPLeadHierarchy_NQ 
SELECT * INTO #VIPSMHierarchy_NQ FROM [CHC-SQLPSG12].VIPAnalytics.[dbo].[VIPSMHierarchy_NQ]

TRUNCATE TABLE dbo.KPI_GMMNOofLeads
INSERT INTO dbo.KPI_GMMNOofLeads
SELECT 
st.TerritoryLevelID,
st.TerritoryID,
COUNT(DISTINCT l.HotelKey) NO_Leads
FROM [CHC-SQLPSG12].SSA.dbo.AE_Q215Tgt_CleanedLeads l 
LEFT JOIN [CHC-SQLPSG12].VIPAnalytics.dbo.VIPLeadHierarchy_NQ h ON l.LeadID = h.LeadID
LEFT JOIN [CHC-SQLPSG12].VIPAnalytics.[dbo].[VIPSMHierarchy_NQ] sm on h.SubmarketID = sm.SubmarketID
JOIN dbo.KPI_GMM_VIP_Territories st ON st.TerritoryID = CASE st.TerritoryLevelID WHEN 40 THEN   CONVERT(int,sm.AMTID)
																	WHEN 50 THEN h.MMAID
																	WHEN 60 THEN h.MAAID END
																
GROUP BY
st.TerritoryLevelID,
st.TerritoryID