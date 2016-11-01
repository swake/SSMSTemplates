DECLARE @Date AS DATE
SET @Date =	'11/1/2015'

-- Testing
--DROP TABLE #Tender

SELECT FKStoreId
	,MAX(TypeId) AS TypeId
	,CheckNumber
	,DateOfBusiness
	,[Hour]
INTO #Tender
FROM AlohaData.dbo.dpvhstgndtender
WHERE DateOfBusiness >= @Date
GROUP BY FKStoreID
	,CheckNumber
	,DateOfBusiness
	,[Hour]

-- Add index to temp table to improve performance
CREATE INDEX idx_Tender ON #Tender ([FKStoreId],[CheckNumber],[DateOfBusiness]);

WITH ItemTax AS
(
	SELECT FKStoreID
		,CheckNumber
		,DateOfBusiness
		,MAX(FKTaxId) AS MaxTaxID
		,SUM(DiscPric) AS DiscPrice
	FROM AlohaData.dbo.dpvHstGndItem 
	WHERE DateOfBusiness >= @Date
	GROUP BY FKStoreID
		,CheckNumber
		,DateOfBusiness
)

,FundraiserItem AS
(
	SELECT FKStoreID
		,CheckNumber
		,DateOfBusiness
	FROM AlohaData.dbo.dpvHstGndItem
	WHERE FKItemId = 265 -- Fundraiser Type
		AND DateOfBusiness >= @Date
	GROUP BY FKStoreID
		,CheckNumber
		,DateOfBusiness
)

SELECT hgt.FKStoreId
	,CAST(hgt.DateOfBusiness AS DATE) AS DateOfBusiness
	,SUM(X.DiscPrice) AS Amount
	,CASE WHEN ta.Name IS NULL THEN 'No Tax' ELSE LEFT(ta.Name,10) END AS Tax
	,t.Name AS PaymentType
	,hod.TimeRange
FROM #Tender hgt
INNER JOIN
	( 
	SELECT FI.FKStoreID
		,FI.CheckNumber
		,FI.DateOfBusiness
		,IT.MaxTaxID
		,IT.DiscPrice
	FROM FundraiserItem FI
	INNER JOIN ItemTax IT
		ON FI.FKStoreId = IT.FKStoreId
		AND FI.CheckNumber = IT.CheckNumber
		AND FI.DateOfBusiness = IT.DateOfBusiness
	GROUP BY FI.FKStoreId
		,FI.CheckNumber
		,FI.DateOfBusiness
		,IT.MaxTaxID
		,IT.DiscPrice
	) X
	ON hgt.CheckNumber = X.CheckNumber
	AND hgt.FKStoreId = X.FKStoreId
	AND hgt.DateOfBusiness = X.DateOfBusiness
INNER JOIN AlohaData.dbo.Tender t
	ON hgt.TypeId = t.TenderId
INNER JOIN FinanceDataMart.dbo.tblHourOfDay hod 
	ON hgt.[Hour] = hod.HourOfDay
LEFT JOIN AlohaData.dbo.Tax ta 
	ON X.MaxTaxID = ta.TaxID
GROUP BY hgt.FKStoreId
	,hgt.DateOfBusiness
	,CASE WHEN ta.Name IS NULL THEN 'No Tax' ELSE LEFT(ta.Name,10) END
	,t.Name
	,hod.TimeRange