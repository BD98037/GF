USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GPG_UpdateAccountAssignments]    Script Date: 05/01/2015 10:59:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GPG_UpdateAccountAssignments]
@ParentChainID int,
@SuperRegionID int,
@RM varchar(100),
@SDMM varchar(100),
@Global varchar(100),
@Regional varchar(100),
@UpDatedBy varchar(100),
@CM varchar(100),
@TL varchar(100) = null,
@TeamID int = null,
@RegionID int = 0,
@LeadRM varchar(100) = null,
@IncludeInTotal Smallint =0,
@OriginalRegionID int = 0
AS

IF(@RegionID = @OriginalRegionID) -- not a region update
	BEGIN
		IF EXISTS(SELECT * FROM KPI_GPGAccountAssignments WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND ISNULL(RegionID,0) = @RegionID)
		BEGIN
			UPDATE KPI_GPGAccountAssignments 
			SET 
			ReveneManager = @RM,
			[SDMM/VP] = @SDMM,
			GlobalOwner = @Global,
			RegionalOwner = @Regional,
			UpdatedBy = @UpDatedBy, 
			UpdatedDate = GETDATE(),
			ConnectivityManager = @CM,
			TeamLeader = @TL,
			TeamID = @TeamID,
			LeadRM = @LeadRM,
			IncludeInTotal = @IncludeInTotal
			WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND ISNULL(RegionID,0) = @RegionID
		END
	ELSE
		BEGIN
			INSERT INTO KPI_GPGAccountAssignments -- newly account added with assignments
			(
			ParentChainID,
			SuperRegionID,
			ReveneManager,
			[SDMM/VP],
			GlobalOwner,
			RegionalOwner,
			SVP,
			UpdatedBy, 
			UpdatedDate,
			ConnectivityManager,
			TeamLeader,
			TeamID,
			RegionID,
			LeadRM,
			IncludeInTotal
			)
			SELECT 
			h.ParentChainID,
			h.SuperRegionID,
			RevenueManager = @RM,
			[SDMM/VP] = @SDMM,
			GlobalOwner = @Global,
			RegionalOwner = @Regional,
			SVP ='',
			UpdatedBy = @UpDatedBy, 
			UpdatedDate = GETDATE(),
			ConnectivityManager = @CM,
			TeamLeader = @TL,
			TeamID = @TeamID,
			RegionID = @RegionID,
			LeadRM = @LeadRM,
			IncludeInTotal = @IncludeInTotal
			FROM (SELECT DISTINCT ParentChainID,ParentChainName,ChainAccountTypeID,ChainAccountTypeName,SuperRegionID,SuperRegionName 
					FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID<>4 AND BusinessModel NOT IN ('Lead','GDS Agency')) h
			LEFT JOIN KPI_GPGAccountAssignments a
			ON h.ParentChainID = a.ParentChainID
			AND h.SuperRegionID = a.SuperRegionID
			WHERE h.ParentChainID = @ParentChainID AND h.SuperRegionID = @SuperRegionID
		END
	END
ELSE 
	BEGIN
		IF EXISTS(SELECT * FROM KPI_GPGAccountAssignments WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND ISNULL(RegionID,0) = @OriginalRegionID)
			BEGIN
				UPDATE KPI_GPGAccountAssignments --region updates
				SET 
				ReveneManager = @RM,
				[SDMM/VP] = @SDMM,
				GlobalOwner = @Global,
				RegionalOwner = @Regional,
				UpdatedBy = @UpDatedBy, 
				UpdatedDate = GETDATE(),
				ConnectivityManager = @CM,
				TeamLeader = @TL,
				TeamID = @TeamID,
				RegionID = @RegionID,
				LeadRM = @LeadRM,
				IncludeInTotal = @IncludeInTotal
				WHERE ParentChainID = @ParentChainID AND SuperRegionID = @SuperRegionID AND ISNULL(RegionID,0) = @OriginalRegionID
			END
		ELSE
			BEGIN
				INSERT INTO KPI_GPGAccountAssignments -- newly account added with assignments
				(
				ParentChainID,
				SuperRegionID,
				ReveneManager,
				[SDMM/VP],
				GlobalOwner,
				RegionalOwner,
				SVP,
				UpdatedBy, 
				UpdatedDate,
				ConnectivityManager,
				TeamLeader,
				TeamID,
				RegionID,
				LeadRM,
				IncludeInTotal
				)
				SELECT 
				h.ParentChainID,
				h.SuperRegionID,
				RevenueManager = @RM,
				[SDMM/VP] = @SDMM,
				GlobalOwner = @Global,
				RegionalOwner = @Regional,
				SVP ='',
				UpdatedBy = @UpDatedBy, 
				UpdatedDate = GETDATE(),
				ConnectivityManager = @CM,
				TeamLeader = @TL,
				TeamID = @TeamID,
				RegionID = @RegionID,
				LeadRM = @LeadRM,
				IncludeInTotal = @IncludeInTotal
				FROM (SELECT DISTINCT ParentChainID,ParentChainName,ChainAccountTypeID,ChainAccountTypeName,SuperRegionID,SuperRegionName 
						FROM Pliny.dbo.DimHotelExpand WHERE ChainAccountTypeID<>4 AND BusinessModel NOT IN ('Lead','GDS Agency')) h
				LEFT JOIN KPI_GPGAccountAssignments a
				ON h.ParentChainID = a.ParentChainID
				AND h.SuperRegionID = a.SuperRegionID
				WHERE h.ParentChainID = @ParentChainID AND h.SuperRegionID = @SuperRegionID
			END
	END
