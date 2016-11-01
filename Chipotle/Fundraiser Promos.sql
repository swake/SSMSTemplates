USE FinanceDataMart
GO

DECLARE @StartDate AS DATE
DECLARE @EndDate AS DATE
SET @StartDate = '11/1/2015'
SET @EndDate = '11/30/2015';	

-- All Promo Lines
WITH ItemPromo AS
(
	SELECT L.FKStoreID
		,L.CheckNumber
		,L.DateOfBusiness
		,L.[Type] AS CompOrPromo
		,L.TypeId as CompOrPromoType
		,SUM(L.Amount) AS AmtOfDisc
	FROM AlohaData.dbo.dpvHstGndLine L
	WHERE L.DateOfBusiness BETWEEN @StartDate AND @EndDate
	GROUP BY L.FKStoreID
		,L.DateOfBusiness
		,L.CheckNumber
		,L.[Type]
		,L.TypeId
)

-- All Fundrasier Items sold
,FundraiserItem AS
(
	SELECT FKStoreID
		,CheckNumber
		,DateOfBusiness
	FROM AlohaData.dbo.dpvHstGndItem
	WHERE FKItemId = 265 -- Fundraiser Type
		AND DateOfBusiness BETWEEN @StartDate AND @EndDate
	GROUP BY FKStoreID
		,DateOfBusiness
		,CheckNumber
)

-- This part pulls ALL COMPS (Type 3)
SELECT FI.FKStoreID
	,FI.DateOfBusiness
	,FI.CheckNumber
	,IP.CompOrPromo
	,IP.CompOrPromoType
	,C.Name as CompOrPromoName
	,SUM(IP.AmtOfDisc) AS AmtOfDisc
FROM FundraiserItem FI
INNER JOIN ItemPromo IP
	ON FI.FKStoreId = IP.FKStoreId
	AND FI.CheckNumber = IP.CheckNumber
	AND FI.DateOfBusiness = IP.DateOfBusiness
	AND IP.CompOrPromo = 3
INNER JOIN AlohaData.DBO.Comp C 
	ON IP.CompOrPromoType = C.CompId
GROUP BY FI.FKStoreId
	,FI.DateOfBusiness
	,FI.CheckNumber
	,IP.CompOrPromo
	,IP.CompOrPromoType
	,C.Name

UNION

--This part pulls ALL PROMOS (Type 2)
SELECT FI.FKStoreID
	,FI.DateOfBusiness
	,FI.CheckNumber
	,IP.CompOrPromo
	,IP.CompOrPromoType
	,C.Name as CompOrPromoName
	,SUM(IP.AmtOfDisc) AS AmtOfDisc
FROM FundraiserItem FI
INNER JOIN ItemPromo IP
	ON FI.FKStoreId = IP.FKStoreId
	AND FI.CheckNumber = IP.CheckNumber
	AND FI.DateOfBusiness = IP.DateOfBusiness
	AND IP.CompOrPromo = 2
INNER JOIN AlohaData.DBO.Promotion C 
	ON IP.CompOrPromoType = C.PromotionId
GROUP BY FI.FKStoreId
	,FI.DateOfBusiness
	,FI.CheckNumber
	,IP.CompOrPromo
	,IP.CompOrPromoType
	,C.Name
ORDER BY FKStoreId
	,DateOfBusiness
	,CheckNumber