USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GetChainAccountType]    Script Date: 05/01/2015 10:56:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[KPI_GPG_GetChainAccountType]
AS

SELECT DISTINCT ChainAccountTypeID ID, ChainAccountTypeName Name FROM Pliny.dbo.DimHotelExpand
WHERE ChainAccountTypeID IN (1,2,3)