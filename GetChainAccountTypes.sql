USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[GetChainAccountTypes]    Script Date: 05/01/2015 11:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetChainAccountTypes]
AS
SELECT DISTINCT 
ChainAccountTypeID,
ChainAccountTypeName 
FROM Pliny.dbo.DimHotelExpand 
WHERE ChainAccountTypeID IN(1,2,3) 
ORDER BY ChainAccountTypeName ASC