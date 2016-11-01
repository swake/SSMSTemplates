USE FinanceDataMart
GO

SET XACT_ABORT ON

DECLARE @StartDateINT INT = 20141215  -- Change to date you want to start processing on (see below in #loop if you want to load in reverse order)
DECLARE @EndDateINT INT = 20150915  -- Change to date you want to stop processing on
DECLARE @CurrentDateINT INT = @StartDateINT
DECLARE @StartDate SMALLDATETIME
DECLARE @EndDate SMALLDATETIME
DECLARE @DateLoop INT = 1
DECLARE @PeriodLoop INT = 1
DECLARE @Message NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(4000)

IF OBJECT_ID('tempdb..#loop') IS NOT NULL
	DROP TABLE #loop

CREATE TABLE #loop (ID INT IDENTITY (1,1), DateID INT, DateCol SMALLDATETIME)

IF OBJECT_ID('tempdb..#periodloop') IS NOT NULL
	DROP TABLE #periodloop

CREATE TABLE #periodloop (ID INT IDENTITY (1,1), Period VARCHAR(10))  

SET @Message = 'Build #loop with all dates between ' + CAST(@StartDateINT AS NVARCHAR) + ' and ' + CAST(@EndDateINT AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

INSERT INTO #loop (DateID, DateCol)
SELECT DateID, [Date]
FROM tblTime
WHERE DateID BETWEEN @StartDateINT AND @EndDateINT
ORDER BY DateID ASC  -- Change this to DESC if you want to process dates in reverse order

-- Group 1 is only necessary if tblDailyLaborMatrixParameters needs to be reloaded
--SET @Message = 'Starting Group 1 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
--RAISERROR(@Message,0,1) WITH NOWAIT

--BEGIN TRY        
--	BEGIN TRANSACTION

--	SET @CurrentDateINT = @StartDateINT
--	SET @DateLoop = 1
	
--	WHILE @DateLoop <= (SELECT TOP 1 MAX(ID) FROM #loop)
--		BEGIN
--			SET @StartDate = (SELECT TOP 1 DateCol FROM #loop WHERE ID = @DateLoop)

--			-- Delete/Insert tblDailyLaborMatrixParameters for all days
--			DELETE tblDailyLaborMatrixParameters WHERE BusinessDate = @StartDate

--			INSERT INTO tblDailyLaborMatrixParameters (FKStoreID,BusinessDate,NumSalariedMgrs,ArmoredCar,MPI,SmartSafe)
--				SELECT S.PKStoreID 
--					,@StartDate
--					,COUNT(DISTINCT v.EMPLID) AS NumSalariedMgrs
--					,CASE WHEN AC.Company IS NULL THEN 0 ELSE 1 END AS ArmoredCar
--					,(mpt.PmixAmount/mpt.IndexAmount)/dbo.fn_MPIFactor() AS MPI
--					,CASE WHEN AC.SmartSafe = 'Y' THEN 1 ELSE 0 END AS SmartSafe
--			FROM tblStores S 
--			LEFT OUTER JOIN 
--				(
--				SELECT V.FKEntityID
--					,V.EMPLID
--					,V.DT 
--				FROM  HR.dbo.factEmployee V 
--				INNER JOIN dbo.DimJobCode jc 
--					ON V.JOBCODE = jc.JobCode 
--						AND jc.EmployeeCategory = 'Manager'
--				WHERE V.EmplStatus = 'A' 
--					AND V.DT = @StartDate
--				) V
--				ON S.FKEntityID = V.FKEntityID 
--					AND v.DT = @StartDate
--			LEFT OUTER JOIN tblStoresArmoredCars AC 
--				ON S.PKStoreID = AC.FKStoreID
--			LEFT OUTER JOIN tblMenuPriceTiers mpt 
--				ON s.FKMenuPriceTier = mpt.PKMenuPriceTier
--			WHERE S.OpenDate <= @StartDate 
--				AND (S.CloseDate >= @StartDate 
--					OR s.CloseDate IS NULL)
--			GROUP BY S.PKStoreID 
--				,CASE WHEN AC.Company IS NULL THEN 0 ELSE 1 END
--				,(mpt.PmixAmount/mpt.IndexAmount)/dbo.fn_MPIFactor()
--				,CASE WHEN AC.SmartSafe = 'Y' THEN 1 ELSE 0 END 		
		
--		-- Merge data for the Current processed
--		-- SalesDate ( @StartDate which gets incremented by 1 for each loop iteration )
--		MERGE INTO [dbo].tblDailyLaborMatrix AS TargetSET
--		USING 
--		(			
--			SELECT  ds.FKStoreId
--					,CAST(ds.SalesDate AS SMALLDATETIME) AS SalesDate 
--					,0 AS FKStoreConfigID 
--					,ds.NetSales 
--					,ISNULL((som.Fax + som.[Online]), 0) AS NetFaxSales 
--					,(ds.NetSales / lmp.MPI) AS AdjSales 
--					,0 AS AdjFaxSales 
--					,lmm.Hours AS MainHours 
--					,0 AS FaxHours 
--					,CASE WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 7 THEN 35
--						WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 21 THEN 20
--						WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 35 THEN 10
--						ELSE 0
--					 END AS NewStoreHours 
--					,0 AS MenuPriceActual 
--					,0 AS MenuPriceIndex 
--					,lmp.MPI 
--					,DATEDIFF(d,st.OpenDate,ds.SalesDate) AS DaysOpen
--			FROM    [dbo].vwDailySales ds
--					INNER JOIN [dbo].tblStores st WITH (NOLOCK) 
--						ON ds.FKStoreID = st.PKStoreID		
--					LEFT OUTER JOIN [dbo].tblDailyLaborMatrixParameters lmp WITH (NOLOCK) 
--						ON ds.FKStoreId = lmp.FKStoreID
--						AND ds.SalesDate = lmp.BusinessDate
--					LEFT OUTER JOIN [dbo].vwSalesByOrderMode som 
--						ON ds.FKStoreId = som.FKStoreId
--						AND ds.SalesDate = som.DateOfBusiness
--					LEFT OUTER JOIN [dbo].tblLaborMatrixMain lmm WITH (NOLOCK) 
--						ON lmm.FKConceptID = st.FKConceptID
--						AND (ds.NetSales/lmp.MPI) >= lmm.SalesMin
--						AND (ds.NetSales/lmp.MPI) <= lmm.SalesMax
--			WHERE ds.SalesDate = CAST (@StartDate AS DATE)
--				AND st.CloseDate IS NULL 			
--		) AS SourceSET
--		ON TargetSET.[FKStoreID] = SourceSET.[FKStoreID] 
--			AND TargetSET.[SalesDate] = SourceSET.[SalesDate] 

--		WHEN MATCHED 
--			AND  
--			(
--			COALESCE(TargetSET.FKStoreConfigID,0)  <> COALESCE(SourceSET.FKStoreConfigID, 0) 
--			OR COALESCE(ROUND(TargetSET.NetSales,6),0) <> COALESCE(ROUND(SourceSET.NetSales,6),0) 
--			OR COALESCE(ROUND(TargetSET.NetFaxSales,6),0) <> COALESCE(ROUND(SourceSET.NetFaxSales,6),0) 
--			OR COALESCE(ROUND(TargetSET.AdjSales,6),0) <> COALESCE(ROUND(SourceSET.AdjSales,6),0) 
--			OR COALESCE(ROUND(TargetSET.AdjFaxSales,6),0) <> COALESCE(ROUND(SourceSET.AdjFaxSales,6),0) 
--			OR COALESCE(ROUND(TargetSET.MainHours,6),0) <> COALESCE(ROUND(SourceSET.MainHours,6),0) 
--			OR COALESCE(ROUND(TargetSET.FaxHours,6),0) <> COALESCE(ROUND(SourceSET.FaxHours,6),0) 
--			OR COALESCE(ROUND(TargetSET.NewStoreHours,6),0) <> COALESCE(ROUND(SourceSET.NewStoreHours,6),0) 
--			OR COALESCE(ROUND(TargetSET.MenuPriceActual,6),0) <> COALESCE(ROUND(SourceSET.MenuPriceActual,6),0) 
--			OR COALESCE(ROUND(TargetSET.MenuPriceIndex,6),0) <> COALESCE(ROUND(SourceSET.MenuPriceIndex,6),0) 
--			OR COALESCE(ROUND(TargetSET.MPI,6),0) <> COALESCE(ROUND(SourceSET.MPI,6),0) 
--			OR COALESCE(TargetSET.DaysOpen,0)  <> COALESCE(SourceSET.DaysOpen,0) 
--			) 
--		THEN UPDATE 
--			SET FKStoreConfigID = SourceSET.FKStoreConfigID
--				,NetSales = ROUND(SourceSET.NetSales,6)
--				,NetFaxSales = ROUND(SourceSET.NetFaxSales,6)
--				,AdjSales = ROUND(SourceSET.AdjSales,6)
--				,AdjFaxSales = ROUND(SourceSET.AdjFaxSales,6)
--				,MainHours = ROUND(SourceSET.MainHours,6)
--				,FaxHours = ROUND(SourceSET.FaxHours,6)
--				,NewStoreHours = ROUND(SourceSET.NewStoreHours,6)
--				,MenuPriceActual = ROUND(SourceSET.MenuPriceActual,6)
--				,MenuPriceIndex = ROUND(SourceSET.MenuPriceIndex,6)
--				,MPI = SourceSET.MPI
--				,DaysOpen = SourceSET.DaysOpen
--		WHEN NOT MATCHED 
--			THEN INSERT 
--			(					
--				[FKStoreID]
--				,[SalesDate]
--				,[FKStoreConfigID]
--				,[NetSales]
--				,[NetFaxSales]
--				,[AdjSales]
--				,[AdjFaxSales]
--				,[MainHours]
--				,[FaxHours]
--				,[NewStoreHours]
--				,[MenuPriceActual]
--				,[MenuPriceIndex]
--				,[MPI]
--				,[DaysOpen]
--			)	
--			VALUES
--			(					
--				SourceSET.[FKStoreID]
--				,SourceSET.[SalesDate]
--				,SourceSET.[FKStoreConfigID]
--				,ROUND(SourceSET.NetSales,6)
--				,ROUND(SourceSET.NetFaxSales,6)
--				,ROUND(SourceSET.AdjSales,6)
--				,ROUND(SourceSET.AdjFaxSales,6)
--				,ROUND(SourceSET.MainHours,6)
--				,ROUND(SourceSET.FaxHours,6)
--				,ROUND(SourceSET.NewStoreHours,6)
--				,ROUND(SourceSET.MenuPriceActual,6)
--				,ROUND(SourceSET.MenuPriceIndex,6)
--				,SourceSET.MPI
--				,SourceSET.[DaysOpen]
--			)	
--		WHEN NOT MATCHED BY SOURCE 
--			AND TargetSET.SalesDate = @StartDate 
--		THEN DELETE;	
			  			  
--		--Update Hours for stores that have Armored Car
--		UPDATE [dbo].tblDailyLaborMatrix
--			SET MainHours = MainHours-1.5
--		FROM [dbo].tblDailyLaborMatrix M 
--		INNER JOIN [dbo].tblDailyLaborMatrixParameters E 
--			ON M.FKStoreID = E.FKStoreID 
--			AND M.SalesDate = E.BusinessDate
--		WHERE E.ArmoredCar = 1
--			AND M.SalesDate = @startdate

--		--Update Hours for stores that have < 2 mgrs
--		; WITH CTEStoresWLTTwoMgrs AS 
--			(
--			SELECT FKStoreID 
--				,BusinessDate
--				,NumSalariedMgrs
--			FROM [dbo].tblDailyLaborMatrixParameters
--			WHERE NumSalariedMgrs < 2
--				AND BusinessDate = @StartDate		
--			)

--		UPDATE [dbo].tblDailyLaborMatrix
--			SET MainHours = MainHours+4
--		FROM [dbo].tblDailyLaborMatrix M
--		INNER JOIN CTEStoresWLTTwoMgrs S 
--			ON M.FKStoreID = S.FKStoreID 
--			AND M.SalesDate = S.BusinessDate
--		WHERE M.SalesDate = @StartDate

--		--Update Hours for stores that have Smart Safe
--		UPDATE [dbo].tblDailyLaborMatrix
--			SET MainHours = MainHours-.5
--		FROM [dbo].tblDailyLaborMatrix M 
--		INNER JOIN [dbo].tblDailyLaborMatrixParameters E 
--			ON M.FKStoreID = E.FKStoreID 
--			AND M.SalesDate = E.BusinessDate
--		WHERE E.SmartSafe = 1
--			AND M.SalesDate = @StartDate

--		SET @DateLoop = (SELECT ID FROM #loop WHERE ID = @DateLoop + 1) 
--	END
--	COMMIT TRANSACTION
--END TRY
--	-- XACT_STATE VALUES
--	--
--	--	-1 The current request has an active user transaction, but an error has occurred that has caused the transaction 
--	--		to be classified as an uncommittable transaction.
--	--
--	--   0 There is no active user transaction for the current request.
--	--
--	--   1 The current request has an active user transaction. 
--	--		The request can perform any actions, including writing data and committing the transaction.
--BEGIN CATCH       
--		-- Given that we are in the CATCH block,
--		-- this implies that an ERROR has occured
--		-- and given this and the fact that we are in a transaction
--		-- we immediately rollback the transaction.
--    	IF (XACT_STATE()) <> 0
--	        ROLLBACK TRANSACTION

--		-- Now that the transaction has rolled back, we re-throw the error.
--		DECLARE @ContextInfo NVARCHAR(128);		
		
--		SET @ContextInfo = CAST( @startdate AS NVARCHAR(128))
		
--		EXECUTE [dbo].stpInserttblErrorLog @Caller = N'dbo.stpDlyLaborMatrixCalc',
--			@ContextInfo = @ContextInfo
--END CATCH
    
---- Double check the transaction state here...
--IF XACT_STATE() = -1 -- AND @@TRANCOUNT > 0
--	ROLLBACK TRANSACTION
--ELSE
--	IF XACT_STATE() = 1 -- AND @@TRANCOUNT > 0
--		COMMIT TRANSACTION

--SET @Message = 'Completed Group 1 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
--RAISERROR(@Message,0,1) WITH NOWAIT

---- Group 2 is only necessary if HR tables (like factEmployee) have been updated
--SET @Message = 'Starting Group 2 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
--RAISERROR(@Message,0,1) WITH NOWAIT

--WHILE @DateLoop <= (SELECT TOP 1 MAX(ID) FROM #loop)
--	BEGIN
--		SET @CurrentDateINT = (SELECT DateID FROM #loop WHERE ID = @DateLoop)
--		SET @Message = CAST(@CurrentDateINT AS NVARCHAR) + ' - ' + CAST(GETDATE() AS NVARCHAR)
--		RAISERROR(@Message,0,1) WITH NOWAIT

--		EXEC stpStatDailyAtModelCounts85to88 @CurrentDateINT, @CurrentDateINT, 85
--		EXEC stpStatDailyAtModelCounts85to88 @CurrentDateINT, @CurrentDateINT, 86
--		EXEC stpStatDailyAtModelCounts85to88 @CurrentDateINT, @CurrentDateINT, 87
--		EXEC stpStatDailyAtModelCounts85to88 @CurrentDateINT, @CurrentDateINT, 88
--		EXEC stpStatDailyAtModel89to99 @CurrentDateINT, @CurrentDateINT

--		SET @DateLoop = (SELECT ID FROM #loop WHERE ID = @DateLoop + 1) 
--	END

--SET @Message = 'Completed Group 2 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
--RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Starting Group 3 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

--EXEC [dbo].[StpStatDaily1and2MgrLunchDinner] @StartDateInt, @EndDateInt, 1 -- Only for MenuLink
--EXEC [dbo].[StpStatDaily1and2MgrLunchDinner] @StartDateInt, @EndDateInt, 2 -- Only for MenuLink
EXEC [dbo].[StpStatDaily3and4PHCLunchDinner] @StartDateInt, @EndDateInt, 3
EXEC [dbo].[StpStatDaily3and4PHCLunchDinner] @StartDateInt, @EndDateInt, 4
EXEC [dbo].[StpStatDaily5and6RecommendedLunchDinner] @StartDateInt, @EndDateInt, 5
EXEC [dbo].[StpStatDaily5and6RecommendedLunchDinner] @StartDateInt, @EndDateInt, 6
EXEC [dbo].[StpStatDaily7PHCScoreLunch] @StartDateInt, @EndDateInt,7
EXEC [dbo].[StpStatDaily8PHCScoreDinner] @StartDateInt, @EndDateInt, 8
EXEC [dbo].[StpStatDaily10ActualHours] @StartDateInt, @EndDateInt, 10
EXEC [dbo].[StpStatDaily16OvertimePay] @StartDateInt, @EndDateInt, 16
EXEC [dbo].[StpStatDaily17OvertimeHours] @StartDateInt, @EndDateInt, 17
EXEC [dbo].[StpStatDaily74ActualHoursBefore11] @StartDateInt, @EndDateInt, 74
EXEC [dbo].[StpStatDaily112ActualLunchDinnerCloserShortShift] @StartDateInt, @EndDateInt, 112

SET @Message = 'Completed Group 3 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Starting Group 4 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @CurrentDateINT = @StartDateINT
SET @DateLoop = 1
	
WHILE @DateLoop <= (SELECT TOP 1 MAX(ID) FROM #loop)
	BEGIN
		SET @CurrentDateINT = (SELECT DateID FROM #loop WHERE ID = @DateLoop)
		SET @Message = CAST(@CurrentDateINT AS NVARCHAR) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC dbo.StpStatDaily72ActualStaffing @CurrentDateINT, @CurrentDateINT, 72
		EXEC dbo.StpStatDaily73RecommendedStaffing @CurrentDateINT, @CurrentDateINT, 73
		
		SET @DateLoop = (SELECT ID FROM #loop WHERE ID = @DateLoop + 1) 
	END

SET @Message = 'Completed Group 4 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Starting Group 5 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

EXEC dbo.StpStatDaily82VartoMinStaff @StartDateInt, @EndDateInt, 82
EXEC dbo.StpStatDaily83VartoMinStaffAgg @StartDateInt, @EndDateInt, 83

SET @Message = 'Completed Group 5 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Starting Group 6 of 7 - Rebuild Monthly Stats - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

DECLARE @LoopStart SMALLDATETIME = (SELECT TOP 1 DateCol FROM #loop ORDER BY ID ASC)
DECLARE @LoopEnd SMALLDATETIME = (SELECT TOP 1 DateCol FROM #loop ORDER BY ID DESC)

SET @Message = 'Build #periodloop with all periods between ' + CAST(@LoopStart AS NVARCHAR) + ' and ' + CAST(@LoopEnd AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @StartDate = 
	CASE
		WHEN @LoopStart <= @LoopEnd THEN @LoopStart
		WHEN @LoopStart > @LoopEnd THEN @LoopEnd
	END

SET @EndDate = 
	CASE
		WHEN @LoopStart <= @LoopEnd THEN @LoopEnd
		WHEN @LoopStart > @LoopEnd THEN @LoopStart
	END

INSERT INTO #periodloop (Period)
SELECT CAST(YEAR(DATEADD(MONTH, x.number, @StartDate)) AS VARCHAR) + CAST(RIGHT('0' + RTRIM(MONTH(DATEADD(MONTH, x.number, @StartDate))), 2) AS VARCHAR) AS Period
FROM master..spt_values x
WHERE x.type = 'P'        
AND x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)

SET @PeriodLoop = 1
	
WHILE @PeriodLoop <= (SELECT TOP 1 MAX(ID) FROM #periodloop)
	BEGIN
		SET @SQL = 'EXEC stpMonthlyStatProcessing ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ',108'
		SET @Message = 'Run stpMonthlyStatProcessing GroupID=108 for ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC sp_executesql @SQL

		SET @SQL = 'EXEC stpStatMonthlyRestStaffPctActualMTD880 ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop)
		SET @Message = 'Run stpStatMonthlyRestStaffPctActualMTD880 for ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC sp_executesql @SQL

		SET @SQL = 'EXEC stpStatMonthlyRestStaffPctRecommendedMTD881 ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop)
		SET @Message = 'Run stpStatMonthlyRestStaffPctRecommendedMTD881 for ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC sp_executesql @SQL

		SET @SQL = 'EXEC stpStatMonthlyRestStaffPctActualYTD847 ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop)
		SET @Message = 'Run stpStatMonthlyRestStaffPctActualYTD847 for ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC sp_executesql @SQL

		SET @SQL = 'EXEC stpStatMonthlyRestStaffPctRecommendedYTD848 ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop)
		SET @Message = 'Run stpStatMonthlyRestStaffPctRecommendedYTD848 for ' + (SELECT Period FROM #periodloop WHERE ID = @PeriodLoop) + ' - ' + CAST(GETDATE() AS NVARCHAR)
		RAISERROR(@Message,0,1) WITH NOWAIT
		
		EXEC sp_executesql @SQL

		SET @PeriodLoop = (SELECT ID FROM #periodloop WHERE ID = @PeriodLoop + 1) 
	END

SET @Message = 'Completed Group 6 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Starting Group 7 of 7 - Update tblDashboardDailyDataLoad with all new stat data - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

EXEC dbo.stptblDashboardDailyDataLoad @StartDateINT,@EndDateINT

SET @Message = 'Completed Group 7 of 7 - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET @Message = 'Labor Stats Updated! - ' + CAST(GETDATE() AS NVARCHAR)
RAISERROR(@Message,0,1) WITH NOWAIT

SET XACT_ABORT OFF