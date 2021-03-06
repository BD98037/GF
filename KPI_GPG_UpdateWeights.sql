USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_UpdateWeights]    Script Date: 05/01/2015 10:59:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_UpdateWeights] -- [KPI_GPG_UpdateWeights]
@RMD int,
@RateLose int,
@InvLose int,
@ETP int,
@Acq int,
@Other int,
@UpdatedBy varchar(200),
@RoleID int
As

UPDATE dbo.KPI_GPGWeights 
SET RMD = convert(float,@RMD)/100,
RateLose = convert(float,@RateLose)/100,
InvLose = convert(float,@InvLose)/100,
ETP = convert(float,@ETP)/100,
Acquisitions = convert(float,@Acq)/100,
Other = convert(float,@Other)/100,
UpdatedBy = @UpdatedBy,
UpdatedDate = GETDATE()
WHERE RoleID = @RoleID

