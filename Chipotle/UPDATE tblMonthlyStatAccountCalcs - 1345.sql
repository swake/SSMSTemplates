USE [FinanceDataMart]
GO

UPDATE [dbo].[tblMonthlyStatAccountCalcs]
   SET [StatSQL] = 'INSERT INTO tblGLData
SELECT S.FKEntityID
		, 1345 AS FKAccountID
		, T.Period
		, DV.PKDataVersionID
		, SUM(DollarVariance) AS Amount
FROM dbo.tblERSWeeklyVarianceReport DS WITH (NOLOCK)
INNER JOIN tblERSCriticalItems CI
	ON DS.IDNo = CI.IDNo
INNER JOIN tblStores S WITH (NOLOCK)
	ON DS.FKStoreID = S.PKStoreID
	AND S.OpenDate <= DS.BusinessDate
INNER JOIN tblTime T WITH (NOLOCK)
	ON DS.BusinessDate = T.[Date]
INNER JOIN tblcurrencies C WITH (NOLOCK)
	ON S.HomeCurrency = C.PKCurrencyID
INNER JOIN tblDataVersion DV WITH (NOLOCK)
	ON C.CurrencyAbbrev = DV.CurrencyAbbrev
WHERE T.Period = @Period
	AND DV.DVType = ''Actuals''
GROUP BY S.FKEntityID
		, T.Period
		, DV.PKDataVersionID

UNION ALL

SELECT S.FKEntityID
		, 1345 AS FKAccountID
		, T.Period
		, 0
		, SUM(DS.DollarVariance) * D.Amount AS Amount
FROM dbo.tblERSWeeklyVarianceReport DS WITH (NOLOCK)
INNER JOIN tblERSCriticalItems CI
	ON DS.IDNo = CI.IDNo
INNER JOIN tblStores S WITH (NOLOCK)
	ON DS.FKStoreID = S.PKStoreID
	AND S.OpenDate <= DS.BusinessDate
INNER JOIN tblTime T WITH (NOLOCK)
	ON DS.BusinessDate = T.[Date]
INNER JOIN tblCurrencies C WITH (NOLOCK)
	ON S.HomeCurrency = C.PKCurrencyID
INNER JOIN tblDataVersion DV WITH (NOLOCK)
	ON C.CurrencyAbbrev = DV.CurrencyAbbrev
INNER JOIN tblGLData D WITH (NOLOCK)
	ON S.FKEntityID = D.FKEntityID
	AND D.Period = @Period
	AND D.FKAccountID = 1601
	AND D.FKDataVersionID = 0
WHERE T.Period = @Period
	AND DV.DVType = ''Actuals''
	AND DV.PKDataVersionID <> 0
GROUP BY S.FKEntityID
		, T.Period
		, D.Amount'
 WHERE FKAccountID = 1345
GO