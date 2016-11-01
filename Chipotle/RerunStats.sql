--- *
--- Groups 1 & 2 -- Watch for each group below and only run each section at a time and verify that dates are setup correctly
--- *

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @enddate AS SMALLDATETIME = NULL
DECLARE @startdate SMALLDATETIME
DECLARE @MaxLoopID INT
DECLARE @LoopID INT;
	

BEGIN TRY        

IF @enddate IS NULL SET @enddate = DATEADD(DAY,-1,CAST(GETDATE() AS DATE));
SELECT @startdate = CAST('2014-12-29' AS DATE);

BEGIN TRANSACTION
	SELECT @LoopID = 1 
		   ,@MaxLoopID = (SELECT DATEDIFF(DAY,@startdate,@enddate))+1;

	WHILE (@LoopID < @MaxLoopID + 1)
	BEGIN
		-- Delete/Insert tblDailyLaborMatrixParameters for all days
		DELETE tblDailyLaborMatrixParameters WHERE BusinessDate = @startdate

		INSERT INTO tblDailyLaborMatrixParameters (FKStoreID,BusinessDate,NumSalariedMgrs,ArmoredCar,MPI,SmartSafe)
			SELECT S.PKStoreID 
					,@startdate 
					,COUNT(DISTINCT v.EMPLID) AS NumSalariedMgrs
					,CASE WHEN AC.Company IS NULL THEN 0 ELSE 1 END AS ArmoredCar
					,(mpt.PmixAmount/mpt.IndexAmount)/dbo.fn_MPIFactor() AS MPI
					,CASE WHEN AC.SmartSafe = 'Y' THEN 1 ELSE 0 END AS SmartSafe
			FROM tblStores S 
			LEFT OUTER JOIN 
				(
				SELECT V.FKEntityID
					,V.EMPLID
					,V.DT 
				FROM  HR.dbo.factEmployee V 
				INNER JOIN dbo.DimJobCode jc 
					ON V.JOBCODE = jc.JobCode 
						AND jc.EmployeeCategory = 'Manager'
				WHERE V.EmplStatus = 'A' 
					AND V.DT = @startdate
				) V
				ON S.FKEntityID = V.FKEntityID 
					AND v.DT = @startdate
			LEFT OUTER JOIN tblStoresArmoredCars AC 
				ON S.PKStoreID = AC.FKStoreID
			LEFT OUTER JOIN tblMenuPriceTiers mpt 
				ON s.FKMenuPriceTier = mpt.PKMenuPriceTier
			WHERE S.OpenDate <= @startdate 
				AND (S.CloseDate >= @startdate 
					OR s.CloseDate IS NULL)
			GROUP BY S.PKStoreID 
				,CASE WHEN AC.Company IS NULL THEN 0 ELSE 1 END
				,(mpt.PmixAmount/mpt.IndexAmount)/dbo.fn_MPIFactor()
				,CASE WHEN AC.SmartSafe = 'Y' THEN 1 ELSE 0 END 		
		
		-- Merge data for the Current processed
		-- SalesDate ( @startdate which gets incremented by 1 for each loop iteration )
		MERGE INTO [dbo].tblDailyLaborMatrix AS TargetSET
		USING 
		(			
			SELECT  ds.FKStoreId
					,CAST(ds.SalesDate AS SMALLDATETIME) AS SalesDate 
					,0 AS FKStoreConfigID 
					,ds.NetSales 
					,ISNULL((som.Fax + som.[Online]), 0) AS NetFaxSales 
					,(ds.NetSales / lmp.MPI) AS AdjSales 
					,0 AS AdjFaxSales 
					,lmm.Hours AS MainHours 
					,0 AS FaxHours 
					,CASE WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 7 THEN 35
						WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 21 THEN 20
						WHEN DATEDIFF(d,st.OpenDate,ds.SalesDate) <= 35 THEN 10
						ELSE 0
					 END AS NewStoreHours 
					,0 AS MenuPriceActual 
					,0 AS MenuPriceIndex 
					,lmp.MPI 
					,DATEDIFF(d,st.OpenDate,ds.SalesDate) AS DaysOpen
			FROM    [dbo].vwDailySales ds
					INNER JOIN [dbo].tblStores st WITH (NOLOCK) 
						ON ds.FKStoreID = st.PKStoreID		
					LEFT OUTER JOIN [dbo].tblDailyLaborMatrixParameters lmp WITH (NOLOCK) 
						ON ds.FKStoreId = lmp.FKStoreID
						AND ds.SalesDate = lmp.BusinessDate
					LEFT OUTER JOIN [dbo].vwSalesByOrderMode som 
						ON ds.FKStoreId = som.FKStoreId
						AND ds.SalesDate = som.DateOfBusiness
					LEFT OUTER JOIN [dbo].tblLaborMatrixMain lmm WITH (NOLOCK) 
						ON lmm.FKConceptID = st.FKConceptID
						AND (ds.NetSales/lmp.MPI) >= lmm.SalesMin
						AND (ds.NetSales/lmp.MPI) <= lmm.SalesMax
			WHERE ds.SalesDate = CAST (@startdate AS DATE)
				AND st.CloseDate IS NULL 			
		) AS SourceSET
		ON TargetSET.[FKStoreID] = SourceSET.[FKStoreID] 
			AND TargetSET.[SalesDate] = SourceSET.[SalesDate] 

		WHEN MATCHED 
			AND  
			(
			COALESCE(TargetSET.FKStoreConfigID,0)  <> COALESCE(SourceSET.FKStoreConfigID, 0) 
			OR COALESCE(ROUND(TargetSET.NetSales,6),0) <> COALESCE(ROUND(SourceSET.NetSales,6),0) 
			OR COALESCE(ROUND(TargetSET.NetFaxSales,6),0) <> COALESCE(ROUND(SourceSET.NetFaxSales,6),0) 
			OR COALESCE(ROUND(TargetSET.AdjSales,6),0) <> COALESCE(ROUND(SourceSET.AdjSales,6),0) 
			OR COALESCE(ROUND(TargetSET.AdjFaxSales,6),0) <> COALESCE(ROUND(SourceSET.AdjFaxSales,6),0) 
			OR COALESCE(ROUND(TargetSET.MainHours,6),0) <> COALESCE(ROUND(SourceSET.MainHours,6),0) 
			OR COALESCE(ROUND(TargetSET.FaxHours,6),0) <> COALESCE(ROUND(SourceSET.FaxHours,6),0) 
			OR COALESCE(ROUND(TargetSET.NewStoreHours,6),0) <> COALESCE(ROUND(SourceSET.NewStoreHours,6),0) 
			OR COALESCE(ROUND(TargetSET.MenuPriceActual,6),0) <> COALESCE(ROUND(SourceSET.MenuPriceActual,6),0) 
			OR COALESCE(ROUND(TargetSET.MenuPriceIndex,6),0) <> COALESCE(ROUND(SourceSET.MenuPriceIndex,6),0) 
			OR COALESCE(ROUND(TargetSET.MPI,6),0) <> COALESCE(ROUND(SourceSET.MPI,6),0) 
			OR COALESCE(TargetSET.DaysOpen,0)  <> COALESCE(SourceSET.DaysOpen,0) 
			) 
		THEN UPDATE 
			SET FKStoreConfigID = SourceSET.FKStoreConfigID
				,NetSales = ROUND(SourceSET.NetSales,6)
				,NetFaxSales = ROUND(SourceSET.NetFaxSales,6)
				,AdjSales = ROUND(SourceSET.AdjSales,6)
				,AdjFaxSales = ROUND(SourceSET.AdjFaxSales,6)
				,MainHours = ROUND(SourceSET.MainHours,6)
				,FaxHours = ROUND(SourceSET.FaxHours,6)
				,NewStoreHours = ROUND(SourceSET.NewStoreHours,6)
				,MenuPriceActual = ROUND(SourceSET.MenuPriceActual,6)
				,MenuPriceIndex = ROUND(SourceSET.MenuPriceIndex,6)
				,MPI = SourceSET.MPI
				,DaysOpen = SourceSET.DaysOpen
		WHEN NOT MATCHED 
			THEN INSERT 
			(					
				[FKStoreID]
				,[SalesDate]
				,[FKStoreConfigID]
				,[NetSales]
				,[NetFaxSales]
				,[AdjSales]
				,[AdjFaxSales]
				,[MainHours]
				,[FaxHours]
				,[NewStoreHours]
				,[MenuPriceActual]
				,[MenuPriceIndex]
				,[MPI]
				,[DaysOpen]
			)	
			VALUES
			(					
				SourceSET.[FKStoreID]
				,SourceSET.[SalesDate]
				,SourceSET.[FKStoreConfigID]
				,ROUND(SourceSET.NetSales,6)
				,ROUND(SourceSET.NetFaxSales,6)
				,ROUND(SourceSET.AdjSales,6)
				,ROUND(SourceSET.AdjFaxSales,6)
				,ROUND(SourceSET.MainHours,6)
				,ROUND(SourceSET.FaxHours,6)
				,ROUND(SourceSET.NewStoreHours,6)
				,ROUND(SourceSET.MenuPriceActual,6)
				,ROUND(SourceSET.MenuPriceIndex,6)
				,SourceSET.MPI
				,SourceSET.[DaysOpen]
			)	
		WHEN NOT MATCHED BY SOURCE 
			AND TargetSET.SalesDate = @startdate 
		THEN DELETE;	
			  			  
		--Update Hours for stores that have Armored Car
		UPDATE [dbo].tblDailyLaborMatrix
			SET MainHours = MainHours-1.5
		FROM [dbo].tblDailyLaborMatrix M 
		INNER JOIN [dbo].tblDailyLaborMatrixParameters E 
			ON M.FKStoreID = E.FKStoreID 
			AND M.SalesDate = E.BusinessDate
		WHERE E.ArmoredCar = 1
			AND M.SalesDate = @startdate;

		--Update Hours for stores that have < 2 mgrs
		; WITH CTEStoresWLTTwoMgrs AS 
			(
			SELECT FKStoreID 
				,BusinessDate
				,NumSalariedMgrs
			FROM [dbo].tblDailyLaborMatrixParameters
			WHERE NumSalariedMgrs < 2
				AND BusinessDate = @startdate		
			)

		UPDATE [dbo].tblDailyLaborMatrix
			SET MainHours = MainHours+4
		FROM [dbo].tblDailyLaborMatrix M
		INNER JOIN CTEStoresWLTTwoMgrs S 
			ON M.FKStoreID = S.FKStoreID 
			AND M.SalesDate = S.BusinessDate
		WHERE M.SalesDate = @startdate;

		--Update Hours for stores that have Smart Safe
		UPDATE [dbo].tblDailyLaborMatrix
			SET MainHours = MainHours-.5
		FROM [dbo].tblDailyLaborMatrix M 
		INNER JOIN [dbo].tblDailyLaborMatrixParameters E 
			ON M.FKStoreID = E.FKStoreID 
			AND M.SalesDate = E.BusinessDate
		WHERE E.SmartSafe = 1
			AND M.SalesDate = @startdate;

		--Addition for next step	
		SELECT @LoopID = @LoopID+1 , @startdate = DATEADD(DAY,1,@startdate);
	END;
COMMIT TRANSACTION ;

END TRY

	-- XACT_STATE VALUES
	--
	--	-1 The current request has an active user transaction, but an error has occurred that has caused the transaction 
	--		to be classified as an uncommittable transaction.
	--
	--   0 There is no active user transaction for the current request.
	--
	--   1 The current request has an active user transaction. 
	--		The request can perform any actions, including writing data and committing the transaction.

BEGIN CATCH       
		-- Given that we are in the CATCH block,
		-- this implies that an ERROR has occured
		-- and given this and the fact that we are in a transaction
		-- we immediately rollback the transaction.
    	IF (XACT_STATE()) <> 0
	        ROLLBACK TRANSACTION;

		-- Now that the transaction has rolled back, we re-throw the error.
		DECLARE @ContextInfo NVARCHAR(128);		
		
		SET @ContextInfo = CAST( @startdate AS NVARCHAR(128)) ;
		
		EXECUTE [dbo].stpInserttblErrorLog @Caller = N'dbo.stpDlyLaborMatrixCalc',
			@ContextInfo = @ContextInfo ;
END CATCH;
    
-- Double check the transaction state here...
IF XACT_STATE()=-1 -- AND @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;
ELSE
	IF XACT_STATE() = 1 -- AND @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END

--- *
--- Group 3 --- Run this manually once for each month, one month at a time
--- *

DECLARE @StartDateID INT
DECLARE @EndDAteID INT
DECLARE @CurrentDateID INT

SET @StartDateID = 20141229
SET @EndDateID = 20150228
SET @CurrentDateID = @StartDateID

IF OBJECT_ID('tempdb..#loop') IS NOT NULL
	DROP TABLE #loop

CREATE TABLE #loop (ID INT IDENTITY (1,1), DateID INT) 

INSERT INTO #loop (dateid)
	SELECT DateID
	FROM tblTime
	WHERE DateID BETWEEN @StartDateID AND @EndDateID
	ORDER BY DateID ASC

WHILE @CurrentDateID <= @EndDateID
BEGIN
	PRINT @CurrentDateID

	EXEC stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 85
	EXEC stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 86
	EXEC stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 87
	EXEC stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 88
	EXEC stpStatDailyAtModel89to99 @CurrentDateID, @CurrentDateID

	SET @CurrentDateID = @CurrentDateID + 1 
END

--- *
--- Group 4 --- Run this manually once for each month, one month at a time
--- *

DECLARE @StartDateInt INT = 20150601
DECLARE @EndDateInt INT = 20150810

-- use these 2 date parameters to loop through stats 72 and 73 since they can only be run a day at a time

EXEC [dbo].[StpStatDaily3and4PHCLunchDinner] @startDateInt, @EndDateInt, 3
EXEC [dbo].[StpStatDaily3and4PHCLunchDinner] @startDateInt, @EndDateInt, 4
EXEC [dbo].[StpStatDaily7PHCScoreLunch] @startDateInt, @EndDateInt,7
EXEC [dbo].[StpStatDaily8PHCScoreDinner] @startDateInt, @EndDateInt, 8
EXEC [dbo].[StpStatDaily10ActualHours] @startDateInt, @EndDateInt, 10
EXEC [dbo].[StpStatDaily16OvertimePay] @startDateInt, @EndDateInt, 16
EXEC [dbo].[StpStatDaily17OvertimeHours] @startDateInt, @EndDateInt, 17
EXEC [dbo].[StpStatDaily74ActualHoursBefore11] @startDateInt, @EndDateInt, 74
EXEC [dbo].[StpStatDaily112ActualLunchDinnerCloserShortShift] @startDateInt, @EndDateInt, 112

--- *
--- Group 5 --- Run this manually once for each month, one month at a time
--- *

DECLARE @StartDateInt INT = 20150601
DECLARE @EndDateInt INT = 20150810
DECLARE @date DATE
DECLARE @dateloop INT

SELECT @date = [Date],@dateloop = DateID FROM tblTime WHERE DateID = @StartDateInt
	
WHILE @dateloop <= @EndDateInt
	BEGIN 
		EXEC dbo.StpStatDaily72ActualStaffing @dateloop, @dateloop, 72
		EXEC dbo.StpStatDaily73RecommendedStaffing @dateloop, @dateloop, 73
		SELECT @date = DATEADD(dd,1,@date)
		SELECT @dateloop = DateID FROM tblTime WHERE [Date] = @date
	END

--- *
--- Group 6 --- Run this manually once for each month, one month at a time
--- *

DECLARE @StartDateInt INT = 20150601
DECLARE @EndDateInt INT = 20150810

EXEC dbo.StpStatDaily82VartoMinStaff @startDateInt, @EndDateInt, 82
EXEC dbo.StpStatDaily83VartoMinStaffAgg @startDateInt, @EndDateInt, 83

--- Group 7 --- Rebuilds monthy stats

EXEC stpMonthlyStatProcessing 201507,108
EXEC stpMonthlyStatProcessing 201506,108
EXEC stpMonthlyStatProcessing 201505,108
EXEC stpMonthlyStatProcessing 201504,108
EXEC stpMonthlyStatProcessing 201503,108
EXEC stpMonthlyStatProcessing 201502,108
EXEC stpMonthlyStatProcessing 201501,108

--Group 8-----Update tblDashboardDailyDataLoad with all new stat data from above

DECLARE @StartDate AS DATE
DECLARE	@EndDate AS DATE
DECLARE	@StartDayID AS INT
DECLARE	@EndDayID AS INT
DECLARE @StartDateInt INT 
DECLARE @EndDateInt INT

SET @StartDateInt = 20150601
SET @EndDateInt = 20150810

SELECT @StartDayID = DayID FROM dbo.tblTime WHERE DateID = @StartDateInt
SELECT @EndDayID = DayID FROM dbo.tblTime WHERE DateID = @EndDateInt
SELECT @StartDateInt,@EndDateInt,@StartDayID,@EndDayID

MERGE dbo.tblDashboardDailyData AS TARGET
USING 
	(
	SELECT FKEntityID
		,FKDayID
		,ManagerLunch
		,ManagerDinner
		,PHCLunchActual
		,PHCDinnerActual
		,RecommendedLunch
		,RecommendedDinner
		,LunchScore
		,DinnerScore
		,MatrixHours
		,ActualHours
		,Sales
		,RestProjSales
		,MPI
		,DailyCurrCompSales
		,DailyPriorCompSales
		,OvertimeDollars
		,OvertimeHours
		,DailyCurrCompTrans
		,DailyPriorComptrans
		,Part2Qtr1
		,Part2Qtr2
		,Part2Qtr3
		,Part2Qtr4
		,Part8Qtr1
		,Part8Qtr2
		,Part8Qtr3
		,Part8Qtr4
		,Part2Qtr1CurrComp
		,Part2Qtr2CurrComp
		,Part2Qtr3CurrComp
		,Part2Qtr4CurrComp
		,Part8Qtr1CurrComp
		,Part8Qtr2CurrComp
		,Part8Qtr3CurrComp
		,Part8Qtr4CurrComp
		,Part2Qtr1PriorComp
		,Part2Qtr2PriorComp
		,Part2Qtr3PriorComp
		,Part2Qtr4PriorComp
		,Part8Qtr1PriorComp
		,Part8Qtr2PriorComp
		,Part8Qtr3PriorComp
		,Part8Qtr4PriorComp
		,Part2Tot
		,Part8Tot
		,Part2CurrComp
		,Part8CurrComp
		,Part2PriorComp
		,Part8PriorComp
		,C7DollarVariance
		,C7Sales
		,DayCount
		,FaxSales
		,FaxTC
		,OnlineSales
		,OnlineTC
		,Max15MinTC
		,Max15MinTCCurrYrComp
		,Max15MinTCPriorYrComp
		,Terms90Day
		,AvocadosDollarVar
		,AvocadosUnitsVar
		,ChickenDollarVar
		,ChickenUnitsVar
		,CarnitasDollarVar
		,CarnitasUnitsVar
		,BarbacoaDollarVar
		,BarbacoaUnitsVar
		,SteakDollarVar
		,SteakUnitsVar
		,CheeseDollarVar
		,CheeseUnitsVar
		,SofritasDollarVar
		,SofritasUnitsVar
		,AbsActualtoProjVar
		,PlanCompSalesCurrentYr
		,PlanCompSalesPriorYr
		,PlanCompSalesPercent
		,WebCommentsPositive
		,WebCommentsNegative
		,AddOnSales
		,VarToMinRecommendedStaff
		,VarToMinRecommendedStaffForAgg
		,DayCountForCompCalcs
		,t.DateID
		,CAST((SELECT CASE WHEN D.DayCount = 1 THEN 1 ELSE 0 END) AS BIT) AS IsOpenDay 
		,CONVERT(VARCHAR(8),DATEADD(dd,-364,t.[Date]),112) AS DateIDMinus364
		,(t.[Year]-1) * 100 + t.Month AS PriorYearPeriod
	FROM dbo.vwDashboardDailyData D
	INNER JOIN dbo.tblTime t
		ON D.FKDayID = t.DayID
	WHERE D.FKDayID BETWEEN @StartDayID AND @EndDayID
	) AS SOURCE 
	(
		FKEntityID
		,FKDayID
		,ManagerLunch
		,ManagerDinner
		,PHCLunchActual
		,PHCDinnerActual
		,RecommendedLunch
		,RecommendedDinner
		,LunchScore
		,DinnerScore
		,MatrixHours
		,ActualHours
		,Sales
		,RestProjSales
		,MPI
		,DailyCurrCompSales
		,DailyPriorCompSales
		,OvertimeDollars
		,OvertimeHours
		,DailyCurrCompTrans
		,DailyPriorComptrans
		,Part2Qtr1
		,Part2Qtr2
		,Part2Qtr3
		,Part2Qtr4
		,Part8Qtr1
		,Part8Qtr2
		,Part8Qtr3
		,Part8Qtr4
		,Part2Qtr1CurrComp
		,Part2Qtr2CurrComp
		,Part2Qtr3CurrComp
		,Part2Qtr4CurrComp
		,Part8Qtr1CurrComp
		,Part8Qtr2CurrComp
		,Part8Qtr3CurrComp
		,Part8Qtr4CurrComp
		,Part2Qtr1PriorComp
		,Part2Qtr2PriorComp
		,Part2Qtr3PriorComp
		,Part2Qtr4PriorComp
		,Part8Qtr1PriorComp
		,Part8Qtr2PriorComp
		,Part8Qtr3PriorComp
		,Part8Qtr4PriorComp
		,Part2Tot
		,Part8Tot
		,Part2CurrComp
		,Part8CurrComp
		,Part2PriorComp
		,Part8PriorComp
		,C7DollarVariance
		,C7Sales
		,DayCount
		,FaxSales
		,FaxTC
		,OnlineSales
		,OnlineTC
		,Max15MinTC
		,Max15MinTCCurrYrComp
		,Max15MinTCPriorYrComp
		,Terms90Day
		,AvocadosDollarVar
		,AvocadosUnitsVar
		,ChickenDollarVar
		,ChickenUnitsVar
		,CarnitasDollarVar
		,CarnitasUnitsVar
		,BarbacoaDollarVar
		,BarbacoaUnitsVar
		,SteakDollarVar
		,SteakUnitsVar
		,CheeseDollarVar
		,CheeseUnitsVar
		,SofritasDollarVar
		,SofritasUnitsVar
		,AbsActualtoProjVar
		,PlanCompSalesCurrentYr
		,PlanCompSalesPriorYr
		,PlanCompSalesPercent
		,WebCommentsPositive
		,WebCommentsNegative
		,AddOnSales
		,VarToMinRecommendedStaff
		,VarToMinRecommendedStaffForAgg
		,DayCountForCompCalcs
		,DateID
		,IsOpenDay
		,DateIDMinus364
		,PriorYearPeriod
	)	
	ON TARGET.FKEntityID = SOURCE.FKEntityID
		AND TARGET.FKDayID = SOURCE.FKDayID
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.FKEntityID = SOURCE.FKEntityID
			,TARGET.FKDayID = SOURCE.FKDayID
			,TARGET.ManagerLunch = SOURCE.ManagerLunch
			,TARGET.ManagerDinner = SOURCE.ManagerDinner
			,TARGET.PHCLunchActual = SOURCE.PHCLunchActual
			,TARGET.PHCDinnerActual = SOURCE.PHCDinnerActual
			,TARGET.RecommendedLunch = SOURCE.RecommendedLunch
			,TARGET.RecommendedDinner = SOURCE.RecommendedDinner
			,TARGET.LunchScore = SOURCE.LunchScore
			,TARGET.DinnerScore = SOURCE.DinnerScore
			,TARGET.MatrixHours = SOURCE.MatrixHours
			,TARGET.ActualHours = SOURCE.ActualHours
			,TARGET.Sales = SOURCE.Sales
			,TARGET.RestProjSales = SOURCE.RestProjSales
			,TARGET.MPI = SOURCE.MPI
			,TARGET.DailyCurrCompSales = SOURCE.DailyCurrCompSales
			,TARGET.DailyPriorCompSales = SOURCE.DailyPriorCompSales
			,TARGET.OvertimeDollars = SOURCE.OvertimeDollars
			,TARGET.OvertimeHours = SOURCE.OvertimeHours
			,TARGET.DailyCurrCompTrans = SOURCE.DailyCurrCompTrans
			,TARGET.DailyPriorComptrans = SOURCE.DailyPriorComptrans
			,TARGET.Part2Qtr1 = SOURCE.Part2Qtr1
			,TARGET.Part2Qtr2 = SOURCE.Part2Qtr2
			,TARGET.Part2Qtr3 = SOURCE.Part2Qtr3
			,TARGET.Part2Qtr4 = SOURCE.Part2Qtr4
			,TARGET.Part8Qtr1 = SOURCE.Part8Qtr1
			,TARGET.Part8Qtr2 = SOURCE.Part8Qtr2
			,TARGET.Part8Qtr3 = SOURCE.Part8Qtr3
			,TARGET.Part8Qtr4 = SOURCE.Part8Qtr4
			,TARGET.Part2Qtr1CurrComp = SOURCE.Part2Qtr1CurrComp
			,TARGET.Part2Qtr2CurrComp = SOURCE.Part2Qtr2CurrComp
			,TARGET.Part2Qtr3CurrComp = SOURCE.Part2Qtr3CurrComp
			,TARGET.Part2Qtr4CurrComp = SOURCE.Part2Qtr4CurrComp
			,TARGET.Part8Qtr1CurrComp = SOURCE.Part8Qtr1CurrComp
			,TARGET.Part8Qtr2CurrComp = SOURCE.Part8Qtr2CurrComp
			,TARGET.Part8Qtr3CurrComp = SOURCE.Part8Qtr3CurrComp
			,TARGET.Part8Qtr4CurrComp = SOURCE.Part8Qtr4CurrComp
			,TARGET.Part2Qtr1PriorComp = SOURCE.Part2Qtr1PriorComp
			,TARGET.Part2Qtr2PriorComp = SOURCE.Part2Qtr2PriorComp
			,TARGET.Part2Qtr3PriorComp = SOURCE.Part2Qtr3PriorComp
			,TARGET.Part2Qtr4PriorComp = SOURCE.Part2Qtr4PriorComp
			,TARGET.Part8Qtr1PriorComp = SOURCE.Part8Qtr1PriorComp
			,TARGET.Part8Qtr2PriorComp = SOURCE.Part8Qtr2PriorComp
			,TARGET.Part8Qtr3PriorComp = SOURCE.Part8Qtr3PriorComp
			,TARGET.Part8Qtr4PriorComp = SOURCE.Part8Qtr4PriorComp
			,TARGET.Part2Tot = SOURCE.Part2Tot
			,TARGET.Part8Tot = SOURCE.Part8Tot
			,TARGET.Part2CurrComp = SOURCE.Part2CurrComp
			,TARGET.Part8CurrComp = SOURCE.Part8CurrComp
			,TARGET.Part2PriorComp = SOURCE.Part2PriorComp
			,TARGET.Part8PriorComp = SOURCE.Part8PriorComp
			,TARGET.C7DollarVariance = SOURCE.C7DollarVariance
			,TARGET.C7Sales = SOURCE.C7Sales
			,TARGET.DayCount = SOURCE.DayCount
			,TARGET.FaxSales = SOURCE.FaxSales
			,TARGET.FaxTC = SOURCE.FaxTC
			,TARGET.OnlineSales = SOURCE.OnlineSales
			,TARGET.OnlineTC = SOURCE.OnlineTC
			,TARGET.Max15MinTC = SOURCE.Max15MinTC
			,TARGET.Max15MinTCCurrYrComp = SOURCE.Max15MinTCCurrYrComp
			,TARGET.Max15MinTCPriorYrComp = SOURCE.Max15MinTCPriorYrComp
			,TARGET.Terms90Day = SOURCE.Terms90Day
			,TARGET.AvocadosDollarVar = SOURCE.AvocadosDollarVar
			,TARGET.AvocadosUnitsVar = SOURCE.AvocadosUnitsVar
			,TARGET.ChickenDollarVar = SOURCE.ChickenDollarVar
			,TARGET.ChickenUnitsVar = SOURCE.ChickenUnitsVar
			,TARGET.CarnitasDollarVar = SOURCE.CarnitasDollarVar
			,TARGET.CarnitasUnitsVar = SOURCE.CarnitasUnitsVar
			,TARGET.BarbacoaDollarVar = SOURCE.BarbacoaDollarVar
			,TARGET.BarbacoaUnitsVar = SOURCE.BarbacoaUnitsVar
			,TARGET.SteakDollarVar = SOURCE.SteakDollarVar
			,TARGET.SteakUnitsVar = SOURCE.SteakUnitsVar
			,TARGET.CheeseDollarVar = SOURCE.CheeseDollarVar
			,TARGET.CheeseUnitsVar = SOURCE.CheeseUnitsVar
			,TARGET.SofritasDollarVar = SOURCE.SofritasDollarVar
			,TARGET.SofritasUnitsVar = SOURCE.SofritasUnitsVar
			,TARGET.AbsActualtoProjVar = SOURCE.AbsActualtoProjVar
			,TARGET.PlanCompSalesCurrentYr = SOURCE.PlanCompSalesCurrentYr
			,TARGET.PlanCompSalesPriorYr = SOURCE.PlanCompSalesPriorYr
			,TARGET.PlanCompSalesPercent = SOURCE.PlanCompSalesPercent
			,TARGET.WebCommentsPositive = SOURCE.WebCommentsPositive
			,TARGET.WebCommentsNegative = SOURCE.WebCommentsNegative
			,TARGET.AddOnSales = SOURCE.AddOnSales
			,TARGET.VarToMinRecommendedStaff = SOURCE.VarToMinRecommendedStaff
			,TARGET.VarToMinRecommendedStaffForAgg = SOURCE.VarToMinRecommendedStaffForAgg
			,TARGET.DayCountForCompCalcs = SOURCE.DayCountForCompCalcs
			,TARGET.DateID = SOURCE.DateID
			,TARGET.IsOpenDay = SOURCE.IsOpenDay
			,TARGET.DateIDMinus364 = SOURCE.DateIDMinus364
			,TARGET.PriorYearPeriod = SOURCE.PriorYearPeriod 
;