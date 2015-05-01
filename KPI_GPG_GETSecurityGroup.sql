USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_GETSecurityGroup]    Script Date: 05/01/2015 10:57:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_GETSecurityGroup] -- KPI_GPG_GETSecurityGroup 'sea\bdoan'
@ResourceAlias varchar(100) = 'sea\bdoan'

AS 

SELECT * FROM KPI_GPGSecurityGroup WHERE ResourceAlias = Replace(@ResourceAlias,'sea\','')
