USE [SSATools]
GO
/****** Object:  StoredProcedure [dbo].[KPI_GMMUpdateTimeAllocationByScenarios]    Script Date: 05/01/2015 10:54:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KPI_GMMUpdateTimeAllocationByScenarios]
@Level INT =1, --1=VP,0=DMM,2=Resource
@IDToUpdate INT=1,
@TerritoryID INT =0,
@TerritoryLevelID INT = 0,
@ActionID int =0,
@UserEmail Varchar(50) ='sea/bdoan',
@ScenarioID INT = 0,

--time allocations
@BML INT = 0,
@LocalProjects INT = 0,
@Acq INT = 0,
@PKG INT = 0,
@AMgt INT = 0,
@PTO INT = 0,
@TMgt INT = 0,

@Override int = 0,
@RoleBucketID int =0,

--weights
@wRMD FLOAT = 0,
@wNRN FLOAT = 0,
@wRate FLOAT = 0,
@wInv FLOAT = 0,
@wPKG FLOAT = 0,
@wAcq FLOAT = 0

--[dbo].[KPI_GMMUpdateTimeAllocationByScenarios] @Level=0,@IDToUpdate=101740,@ActionID=1

As

CREATE TABLE #Territories(TerritoryLevelID INT,TerritoryID INT, RegionID INT)
			
IF(@Level=1) --VP
	BEGIN
		UPDATE dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion 
		SET 
		--time allocations
		tBML = convert(float,@BML)/100,
		tLocalProjects = convert(float,@LocalProjects)/100,
		tAcq = convert(float,@Acq)/100,
		tHFS = convert(float,@PKG)/100,
		tAccntMgmt = convert(float,@AMgt)/100,
		tPTO = convert(float,@PTO)/100,
		tTeamMgmt = convert(float,@TMgt)/100,
		
		ChangedBy = @UserEmail,
		ChangedDate = GETDATE(),
		--weights
		wRMD = convert(float,@wRMD)/100,
		wNRN = convert(float,@wNRN)/100,
		wRate = convert(float,@wRate)/100, -- 
		wInv = convert(float,@wInv)/100,
		wHFS = convert(float,@wPKG)/100,
		wAcq= convert(float,@wAcq)/100
		
		WHERE ScenarioID = @ScenarioID AND SuperRegionID =@IDToUpdate AND RoleBucketID = @RoleBucketID
		/*
		--update region table to match up at SR level
		UPDATE r
		SET
		--time allocations
		tBML = convert(float,@BML)/100,
		tLocalProjects = convert(float,@LocalProjects)/100,
		tAcq= convert(float,@Acq)/100,
		tHFS = convert(float,@PKG)/100,
		tAccntMgmt = convert(float,@AMgt)/100,
		tPTO= convert(float,@PTO)/100,
		tTeamMgmt = convert(float,@TMgt)/100,
		
		ChangedBy = @UserEmail,
		ChangedDate = GETDATE(),
		--weights
		wRMD = convert(float,@wRMD)/100,
		wNRN = convert(float,@wNRN)/100,
		wRate = convert(float,@wRate)/100,
		wInv = convert(float,@wInv)/100,
		wHFS = convert(float,@wPKG)/100,
		wAcq= convert(float,@wAcq)/100
		
		FROM dbo.KPI_GMMTimeAndWeightAllocationsByRegion r
		JOIN (SELECT DISTINCT RegionID,SuperRegionID FROM SIP_Hierrachy WHERE SuperRegionID =@IDToUpdate) s
		ON r.RegionID = s.RegionID 
		WHERE  r.ScenarioID = @ScenarioID AND r.RoleBucketID = @RoleBucketID AND isnull(ChangedBy,'') <>''
		*/
		
	END
ELSE IF(@Level=0) --DMM
		BEGIN			
			IF(@ActionID =0) --Submit changes
				BEGIN
					IF EXISTS(SELECT TOP 1* FROM dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions WHERE RegionID =@IDToUpdate AND RoleBucketID = @RoleBucketID AND ScenarioID = @ScenarioID)
						BEGIN
							UPDATE dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions 
							SET 
							--time allocations
							tBML = convert(float,@BML)/100,
							tLocalProjects = convert(float,@LocalProjects)/100,
							tAcq = convert(float,@Acq)/100,
							tHFS = convert(float,@PKG)/100,
							tAccntMgmt = convert(float,@AMgt)/100,
							tPTO = convert(float,@PTO)/100,
							tTeamMgmt = convert(float,@TMgt)/100,
							
							ChangedBy = @UserEmail,
							ChangedDate = GETDATE(),
							--weights
							wRMD = convert(float,@wRMD)/100,
							wNRN = convert(float,@wNRN)/100,
							wRate = convert(float,@wRate)/100,
							wInv = convert(float,@wInv)/100,
							wHFS = convert(float,@wPKG)/100,
							wAcq= convert(float,@wAcq)/100
			
							WHERE ScenarioID = @ScenarioID AND RegionID =@IDToUpdate AND RoleBucketID = @RoleBucketID
						END
					 ELSE -- new exception
						BEGIN
							INSERT INTO dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions
							(
							RegionID,
							ScenarioID,
							RoleBucketID,
							--time allocations
							tBML,
							tLocalProjects,
							tAcq,
							tHFS,
							tAccntMgmt,
							tPTO,
							tTeamMgmt,
							
							ChangedBy,
							ChangedDate,
							--weights
							wRMD,
							wNRN,
							wRate,
							wInv,
							wHFS,
							wAcq
							)
							SELECT
							@IDToUpdate,
							@ScenarioID,
							@RoleBucketID,
							--time allocations
							convert(float,@BML)/100,
							convert(float,@LocalProjects)/100,
							convert(float,@Acq)/100,
							convert(float,@PKG)/100,
							convert(float,@AMgt)/100,
							convert(float,@PTO)/100,
							convert(float,@TMgt)/100,
							
							@UserEmail,
							GETDATE(),
							
							--weights
							convert(float,@wRMD)/100,
							convert(float,@wNRN)/100,
							convert(float,@wRate)/100,
							convert(float,@wInv)/100,
							convert(float,@wPKG)/100,
							convert(float,@wAcq)/100
						END
	
				     IF(@Override = 1) -- override
						BEGIN
							--remove all entered resources
							INSERT INTO #Territories
							SELECT DISTINCT 40 TerritoryLevelID, AMTID TerritoryID,RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							UNION ALL
							SELECT DISTINCT 50 TerritoryLevelID, MMAID TerritoryID, RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							UNION ALL 
							SELECT DISTINCT 60 TerritoryLevelID, MAAID TerritoryID, RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							
							DELETE r
								FROM [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] r
								JOIN #Territories s ON r.TerritoryID = s.TerritoryID AND r.TerritoryLevelID = s.TerritoryLevelID
						END
				
			END
		ELSE
			BEGIN -- Undo
				UPDATE r 
						SET
						--time allocations 
						tBML = sr.tBML,
						tLocalProjects = sr.tLocalProjects,
						tAcq = sr.tAcq,
						tHFS = sr.tHFS,
						tAccntMgmt = sr.tAccntMgmt,
						tPTO = sr.tPTO,
						tTeamMgmt = sr.tTeamMgmt,
						
						ChangedBy = @UserEmail,
						ChangedDate = GETDATE(),
						
						--weights
						wRMD = sr.wRMD,
						wNRN = sr.wNRN,
						wRate = sr.wRate,
						wInv = sr.wInv,
						wHFS = sr.wHFS,
						wAcq= sr.wAcq
		
						FROM dbo.KPI_GMMTimeAndWeightAllocationsByRegionExceptions   r
						JOIN (SELECT DISTINCT RegionID,SuperRegionID FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpdate) s
						ON r.RegionID = s.RegionID
						JOIN dbo.KPI_GMMTimeAndWeightAllocationsBySuperRegion sr 
						ON r.ScenarioID = sr.ScenarioID AND r.RoleBucketID = sr.RoleBucketID ANd s.SuperRegionID = sr.SuperRegionID
						
					IF(@Override = 1)-- Override
						BEGIN
							--remove all entered resources
							INSERT INTO #Territories
							SELECT DISTINCT 40 TerritoryLevelID, AMTID TerritoryID ,RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							UNION ALL
							SELECT DISTINCT 50 TerritoryLevelID, MMAID TerritoryID, RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							UNION ALL 
							SELECT DISTINCT 60 TerritoryLevelID, MAAID TerritoryID, RegionID
							FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE RegionID = @IDToUpDate
							
							DELETE r
								FROM [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] r
								JOIN #Territories s ON r.TerritoryID = s.TerritoryID AND r.TerritoryLevelID = s.TerritoryLevelID
						END

			END
		END 
	ELSE IF(@Level=2) --Resource
		BEGIN
			IF(@ActionID =0) --Submit changes
			  BEGIN
				 IF EXISTS(SELECT TOP 1* FROM [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] 
											WHERE UserID = @IDToUpdate AND TerritoryID = @TerritoryID AND TerritoryLevelID = @TerritoryLevelID)
					BEGIN
						UPDATE [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] 
						SET 
						--Time
						tTeamMgmt = convert(float,@TMgt)/100,
						tAccntMgmt = convert(float,@AMgt)/100,
						tAcq = convert(float,@Acq)/100,
						tBML = convert(float,@BML)/100,
						tHFS = convert(float,@PKG)/100,
						tLocalProjects = convert(float,@LocalProjects)/100,
						tPTO= convert(float,@PTO)/100,
						--weights
						wRMD = convert(float,@wRMD)/100,
						wNRN = convert(float,@wNRN)/100,
						wAcq= convert(float,@wAcq)/100,
						wHFS = convert(float,@wPKG)/100,
						wRate = convert(float,@wRate)/100,
						wInv = convert(float,@wInv)/100,
						
						ChangedBy = @UserEmail,
						ChangedDate = GETDATE()
						
						WHERE UserID = @IDToUpdate AND TerritoryID = @TerritoryID AND TerritoryLevelID = @TerritoryLevelID

					END
				ELSE
					BEGIN
						INSERT INTO [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions]
						(
						   [TerritoryLevelID]
						  ,[TerritoryID]
						  ,[UserID]
						  ,[UserAlias]
						  ,[tTeamMgmt]
						  ,[tAccntmgmt]
						  ,[tAcq]
						  ,[tBML]
						  ,[tHFS]
						  ,[tLocalProjects]
						  ,[tPTO]
						  ,[wRMD]
						  ,[wNRN]
						  ,[wAcq]
						  ,[wHFS]
						  ,[wRate]
						  ,[wInv]
						  ,ChangedBy
						  ,ChangedDate
						)
						SELECT 
						TerritoryLevelID = @TerritoryLevelID,
						TerrritoryID = @TerritoryID,
						UserID = @IDToUpdate,
						UserAlias = UserAlias,
						
						--Time
						tTeamMgmt = convert(float,@TMgt)/100,
						tAccntMgmt = convert(float,@AMgt)/100,
						tAcq = convert(float,@Acq)/100,
						tBML = convert(float,@BML)/100,
						tHFS = convert(float,@PKG)/100,
						tLocalProjects = convert(float,@LocalProjects)/100,
						tPTO= convert(float,@PTO)/100,
						--weights
						wRMD = convert(float,@wRMD)/100,
						wNRN = convert(float,@wNRN)/100,
						wAcq= convert(float,@wAcq)/100,
						wHFS = convert(float,@wPKG)/100,
						wRate = convert(float,@wRate)/100,
						wInv = convert(float,@wInv)/100,
						
						ChangedBy = @UserEmail,
						ChangedDate = GETDATE()
						
						FROM dbo.KPI_GMM_BottomUpAssignments
						WHERE UserID = @IDToUpdate AND TerritoryID = @TerritoryID AND TerritoryLevelID = @TerritoryLevelID
 

						
					END
			END
		ELSE --undo
			BEGIN
				CREATE TABLE #RoleBuckets(RoleBucketID int)

				IF(@RoleBucketID =0)
					BEGIN
						INSERT INTO #RoleBuckets
						SELECT DISTINCT RoleBucketID
							FROM KPIRoleLookUp WHERE RoleBucketID IN (1,2,3,0)
					END
				ELSE 
					BEGIN
						INSERT INTO #RoleBuckets
						SELECT DISTINCT RoleBucketID
							FROM KPIRoleLookUp WHERE RoleBucketID =@RoleBucketID
					END
		
				--remove all entered resources
				INSERT INTO #Territories
				SELECT DISTINCT 40 TerritoryLevelID, AMTID TerritoryID ,RegionID
				FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE AMTID = @IDToUpDate
				UNION ALL
				SELECT DISTINCT 50 TerritoryLevelID, MMAID TerritoryID, RegionID
				FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE AMTID = @IDToUpDate
				UNION ALL 
				SELECT DISTINCT 60 TerritoryLevelID, MAAID TerritoryID, RegionID
				FROM dbo.KPI_GMM_VIP_Hierarchy  WHERE AMTID = @IDToUpDate
				
				DELETE r
					FROM [dbo].[KPI_GMMTimeAndWeightAllocationsByTerritoryExceptions] r
					JOIN #Territories s ON r.TerritoryID = s.TerritoryID AND r.TerritoryLevelID = s.TerritoryLevelID
					JOIN dbo.KPI_GMM_BottomUpAssignments a ON a.TerritoryLevelID = s.TerritoryLevelID AND a.TerritoryID = s.TerritoryID	
					JOIN #RoleBuckets rl ON rl.RoleBucketID = a.RoleBucketID

			END
		END
		