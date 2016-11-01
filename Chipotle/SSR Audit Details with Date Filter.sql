USE FinanceDataMart
GO

DECLARE @StartDate AS DATE = '12/1/2015';   -- Change to the Audit Start Date
DECLARE @EndDate AS DATE = '12/10/2015';  -- Change to the Audit End Date

WITH AllTDs AS  -- Return only one row per TD, with the Last Date they were a TD and Time in Position on that date
(
	SELECT EmplID
		,MAX(DT) AS [LastDate]
		,MAX(TimeInPOS) AS [TimeInPosition]
	FROM [HR].[dbo].[vwFactEmployeeSnapshot] FES
	WHERE JobCode = 'OPS102' -- Team Directors only
	GROUP BY EmplID  
)

SELECT EH.EntityLevel3 AS [Region]
	,EH.EntityLevel4 AS [Subregion]
	,EH.EntityLevel6 AS [Market]
	,EH.EntityLevel7 AS [Patch]
	,EH.EntityLevel8 AS [Restaurant Name]
	,S.PKStoreID AS [Restaurant Number]
	,O.FullName AS [Team Director]
	,TD.TimeInPosition AS [Time As TD (in years)]
	,CASE WHEN COALESCE(SI.RestaurateurEmpID, SI.Restaurateur2EmpID, SI.Restaurateur3EmpID, SI.Restaurateur4EmpID) IS NULL THEN 'N'
	 ELSE 'Y'
	 END AS [Restaurateur Flag]  -- Determine if this restaurant has a Restauranteur assigned to it by evaluating all 4 levels
	,CAST(SSR.[AuditCompleteDate] AS DATE) AS [Audit Date]
	,DD.Period AS [Audit Period]
	,DD.[Quarter] AS [Audit Quarter]
	,DD.[Year] AS [Audit Year]
	,SSR.[OpsScore] AS [Audit Score]
	,RIGHT(LTRIM(RTRIM(SSR.[RestaurateurEval])),1) AS [Restaurateur Score]  -- Return only the right most character of this column to show the Score number
	,CASE WHEN RANK() OVER (ORDER BY SSR.AuditCompleteDate DESC) = 1 THEN 'Y'
	 ELSE 'N'
	 END AS [Most Recent Audit]  -- Indicate the most recent audit completed between the @StartDate and @EndDate selected
FROM [FinanceDataMart].[dbo].[SSRAuditSummary] SSR
INNER JOIN [FinanceDataMart].[dbo].[tblStores] S
	ON SSR.RestNumber = S.PKStoreID
INNER JOIN [FinanceDataMart].[dbo].[vwStoreInfo] SI
	ON S.FKEntityID = SI.FKEntityID
INNER JOIN [FinanceDataMart].[dbo].[tblEntityHierarchy] EH
	ON S.FKEntityID = EH.FKEntityID
INNER JOIN [FinanceDataMart].[dbo].[tblEntities] E 
	ON EH.EntityLevel4 = E.EntityDes	
LEFT OUTER JOIN [FinanceDataMart].[dbo].[tblODAssignment] OA 
	ON E.PKEntityID = OA.FKEntityID 							
LEFT OUTER JOIN [Administrative].[dbo].[vwCorporateUsers] O 
	ON OA.FKODID = O.EmployeeID
LEFT OUTER JOIN AllTDs TD
	ON O.EmployeeID = TD.EmplID
INNER JOIN [FinanceDataMart].[dbo].[vwDimDate] DD
	ON CAST(SSR.AuditCompleteDate AS DATE) = DD.[Date]
WHERE CAST(SSR.AuditCompleteDate AS DATE) BETWEEN @StartDate AND @EndDate 
ORDER BY EH.EntityLevel3
	,EH.EntityLevel4
	,EH.EntityLevel6
	,EH.EntityLevel7
	,EH.EntityLevel8
	,AuditCompleteDate