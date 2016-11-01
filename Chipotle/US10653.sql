-- Get all Actual Sales for stores that moved opening to later date. These need to go to the Pre-Opening file
SELECT * 
FROM Part.FactSalesHeader_Jan FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),1,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Feb FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),2,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Mar FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),3,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Apr FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),4,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_May FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),5,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Jun FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),6,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Jul FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),7,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Aug FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),8,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Sep FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),9,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Oct FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),10,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Nov FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),11,1,0,0,0,0))
UNION
SELECT * 
FROM Part.FactSalesHeader_Dec FSH
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate > EOMONTH(DATETIMEFROMPARTS(YEAR(GETDATE()),12,1,0,0,0,0))


-- Get all sales that are in Pre-Opening for Open Dates that moved to earlier. These need to go to the correct Actual Month file
SELECT *
FROM Part.FactSalesHeaderPreOpening FSH
INNER JOIN vwDimDate D
	ON FSH.DateID = D.DateID
LEFT JOIN tblStores S
	ON FSH.EntityID = S.FKEntityID
WHERE S.OpenDate < D.[Date]