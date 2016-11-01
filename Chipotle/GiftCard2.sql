USE [FinanceDataMart]
GO

--------------------------------------------
----FOR TESTING ONLY
DECLARE @StartDate DATE
SET @StartDate = '9/8/2015'

--Purpose of this variable is due to parameter sniffing slowing the report down
DECLARE @StartDate2 DATE
SET @StartDate2 = @StartDate


Declare @EndDate DATE
Set @EndDate = (select Date from tblTime where DayID = (select (dayID+7) from tblTime where Date = @StartDate2))

--SELECT @StartDate,@EndDate

Select 
A.FKStoreID as StoreNumber, 
--E.EntityLevel8 as StoreName,
--E.EntityLevel7 as Patch,
--E.EntityLevel6 as Market,
--E.EntityLevel5 as SubRegion,
--E.EntityLevel3 Region,
--I.ExecTeamDirector,
EmployeeName,
A.DateofBusiness,
A.CheckNumber, 
B.Amount,
B.Ident,
B.TypeID
From
	(
	select 
	FKStoreID, 
	PD.Name as EmployeeName,
	Checknumber, 
	Dateofbusiness
	From AlohaData.dbo.dpvHstGndItem P
	INNER JOIN DimMenuItemHierarchy D ON P.FKItemID = D.MenuItemID
	LEFT OUTER Join HR.dbo.PS_Personal_Data PD on P.FKEmployeeNumber = PD.Emplid
	where 
	D.MenuItemCategory = 'Gift Cards' and
	Price >= 50 and 
	DateOfBusiness Between @StartDate2 and @EndDate
	Group By 
	FKStoreID, 
	PD.Name, 
	Checknumber, 
	Dateofbusiness
	)  A
Inner Join
	(
	select 
	T.FKStoreID, 
	T.FKEmployeeNumber,
	T.DateofBusiness, 
	T.CheckNumber, 
	T.Amount, 
	T.Ident,
	T.TypeID
	From AlohaData.dbo.dpvhstgndtender T 
	Where 
	T.Track = 'N' and	--N EQUALS THE FACT THAT IT WAS MANUALLY ENTERED, NOT SWIPED
	--T.Ident is not null and
	--T.TypeID in (21,22,23,24) and
	T.Amount >=50 and
	T.DateOfBusiness Between @StartDate2 and @EndDate 
	)  B On A.FKStoreID = B.fkstoreID and A.CHecknumber = B.CHeckNumber and A.DateofBusiness = B.DateofBusiness
--Inner Join tblStores S on A.FKStoreID = S.PKStoreID
--Inner Join tblEntityHierarchy E on S.FKEntityID = E.FKEntityID
--Inner Join vwStoreInfo I on S.PKStoreID = I.PKStoreID

--Order by 9, 1

--------------------------------------------
