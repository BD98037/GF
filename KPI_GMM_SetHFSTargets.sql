USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMM_SetHFSTargets]    Script Date: 05/01/2015 10:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GMM_SetHFSTargets]
AS

DECLARE @MaxSnapshot DateTime

SELECT @MaxSnapshot = MAX(Date_UpDate) FROM [CHC-SQLPSG12].SSA.dbo.AM_GOALFACTORY_HFS2015TAR_HOTEL
	
SELECT * INTO #VIPHotelHierarchy_NQ  FROM [CHC-SQLPSG12].VIPAnalytics.dbo.VIPHotelHierarchy_NQ	

SELECT * INTO #VIPSMHierarchy_NQ FROM [CHC-SQLPSG12].VIPAnalytics.[dbo].[VIPSMHierarchy_NQ] 
	
TRUNCATE TABLE KPI_GMMHFSTarget
INSERT INTO KPI_GMMHFSTarget
-- To get MMA & MAA
SELECT 
st.TerritoryLevelID,
st.TerritoryID, 
CASE WHEN SUM(HOTEL_HFS_TAR_N) > 0 AND SUM(HOTEL_HFS_TAR_D) > 0 THEN SUM(HOTEL_HFS_TAR_N)/SUM(HOTEL_HFS_TAR_D) ELSE 0 END HFS_Target,
SUM(HOTEL_HFS_TAR_N) NUM_HFS,
SUM(HOTEL_HFS_TAR_D) DENOM_HFS
FROM  [CHC-SQLPSG12].SSA.dbo.AM_GOALFACTORY_HFS2015TAR_HOTEL t
JOIN #VIPHotelHierarchy_NQ sip ON t.Hotel_Key = sip.HotelKey
JOIN dbo.KPI_GMM_VIP_Territories st ON st.TerritoryID = CASE st.TerritoryLevelID /*WHEN 40 THEN sip.AMTID*/
																	WHEN 50 THEN sip.MMAID
																	WHEN 60 THEN sip.MAAID END
WHERE Date_UpDate=@MaxSnapshot
GROUP BY
st.TerritoryLevelID,
st.TerritoryID

UNION ALL

-- To get AMT
SELECT 
40 TerritoryLevelID,
st.AMTID TerritoryID, 
CASE WHEN SUM(HOTEL_HFS_TAR_N) > 0 AND SUM(HOTEL_HFS_TAR_D) > 0 THEN SUM(HOTEL_HFS_TAR_N)/SUM(HOTEL_HFS_TAR_D) ELSE 0 END HFS_Target,
SUM(HOTEL_HFS_TAR_N) NUM_HFS,
SUM(HOTEL_HFS_TAR_D) DENOM_HFS
FROM  [CHC-SQLPSG12].SSA.dbo.AM_GOALFACTORY_HFS2015TAR_HOTEL t
JOIN #VIPHotelHierarchy_NQ sip ON t.Hotel_Key = sip.HotelKey
JOIN #VIPSMHierarchy_NQ st ON st.SubMarketID = sip.SubMarketID
JOIN dbo.KPI_GMM_VIP_Territories tt ON tt.TerritoryID = st.AMTID
WHERE tt.TerritoryLevelID = 40
GROUP BY
st.AMTID

