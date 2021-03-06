USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_DeleteAccountAssignments]    Script Date: 05/01/2015 10:55:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_DeleteAccountAssignments]
@ParentChainID int,
@SuperRegionID int,
@RegionID int = 0
AS
IF EXISTS(SELECT * FROM KPI_GPGAccountAssignments WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND ISNULL(RegionID,0) = @RegionID)
BEGIN
	DELETE a
	FROM KPI_GPGAccountAssignments a
	WHERE a.ParentChainID = @ParentChainID AND a.SuperRegionID = @SuperRegionID AND RegionID = @RegionID
END
