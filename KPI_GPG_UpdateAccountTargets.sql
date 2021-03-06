USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_UpdateAccountTargets]    Script Date: 05/01/2015 10:59:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_UpdateAccountTargets]
@ParentChainID int,
@SuperRegionID int,
@NewInvLose float,
@NewRateLose float,
@UpDatedBy varchar(100)
AS

IF EXISTS(SELECT * FROM dbo.KPI_GPGAccountTargets WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID)
	BEGIN
		UPDATE KPI_GPGAccountTargets 
		SET 
		InvLose_Override = @NewInvLose,
		RateLose_Override = @NewRateLose,
		UpdatedBy = @UpDatedBy, 
		UpdatedDate = GETDATE()
		WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID
	END
ELSE
	BEGIN
		INSERT INTO KPI_GPGAccountTargets 
		(
		ParentChainID,SuperRegionID,InvLose_Default,RateLose_Default,InvLose_Override,RateLose_Override,UpdatedBy,UpdatedDate
		)
		SELECT 
		h.ParentChainID,
		h.SuperRegionID,
		InvLose_Default = 0,
		RateLose_Default = 0,
		InvLose_Override = @NewInvLose,
		RateLose_Override = @NewRateLose,
		UpdatedBy = @UpDatedBy, 
		UpdatedDate = GETDATE()
		FROM (SELECT DISTINCT ParentChainID,ParentChainName,ChainAccountTypeID,ChainAccountTypeName,SuperRegionID,SuperRegionName 
				FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID<>4 AND BusinessModel NOT IN ('Lead','GDS Agency')) h
		LEFT JOIN KPI_GPGAccountTargets a
		ON h.ParentChainID = a.ParentChainID
		AND h.SuperRegionID = a.SuperRegionID
		WHERE h.ParentChainID = @ParentChainID AND h.SuperRegionID = @SuperRegionID
	END
