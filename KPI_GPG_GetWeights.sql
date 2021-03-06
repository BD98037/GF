USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetWeights]    Script Date: 05/01/2015 10:58:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GetWeights]
AS

SELECT 
lk.*,
ISNULL(w.RMD*100,0) RMD_Allocation,
ISNULL(w.RateLose*100,0) RateLose_Allocation,
ISNULL(w.InvLose*100,0) InvLose_Allocation,
ISNULL(w.ETP*100,0) ETP_Allocation,
ISNULL(w.Acquisitions*100,0) Acquisitions_Allocation,
ISNULL(w.Other*100,0) Other_Allocation

FROM dbo.KPI_GPGRoleLookUp lk
LEFT JOIN dbo.KPI_GPGWeights w
ON lk.RoleID = w.RoleID
WHERE RoleBucketID >0 
ORDER BY lk.RoleID

