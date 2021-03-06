USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_UpdateAccountAcqTargets]    Script Date: 05/01/2015 10:58:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_UpdateAccountAcqTargets]
@ParentChainID int,
@SuperRegionID int,
@Country varchar(50),
@NewAcq int,
@UpDatedBy varchar(100)
AS
IF EXISTS(SELECT * FROM dbo.KPI_GPGAccountAcqTargets WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND Country = @Country)
	UPDATE dbo.KPI_GPGAccountAcqTargets
	SET 
	Acquisition_Override = @NewAcq,
	UpdatedBy = @UpDatedBy, 
	UpdatedDate = GETDATE()
	WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND Country = @Country
ELSE 
	INSERT INTO dbo.KPI_GPGAccountAcqTargets
	(ParentChainID,SuperRegionID,Country,Acquisition_Default,Acquisition_Override,UpdatedBy,UpdatedDate)
	VALUES(@ParentChainID,@SuperRegionID,@Country,0,@NewAcq,@UpDatedBy,GETDATE())