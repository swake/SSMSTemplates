Delete 
FROM         dbo.tblERSWeeklyStaging 
WHERE     BusinessDate < '2015-06-17' AND IDNo = '65296'

INSERT INTO dbo.tblERSWeeklyStaging (FKStoreID, BusinessDate, IDNo, DollarVariance, UnitsVariance)
SELECT DISTINCT
W.FKStoreID,
W.BusinessDate,
W.IDNo,
SUM(W.DollarVariance),
SUM(W.UnitsVariance)
FROM dbo.tblERSVariances W
WHERE W.BusinessDate < '2015-06-17' AND IDNo = '65296' 
GROUP BY W.FKStoreID, W.BusinessDate, W.IDNo


SELECT 
[BusinessDate],
COUNT(*) as countperday
FROM [FinanceDataMart].[dbo].[tblERSVariances]
where IDNo = '65296' AND BusinessDate < '2015-06-17'
group by [BusinessDate]
order by 1