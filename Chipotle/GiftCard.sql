DECLARE @StartDate DATE
SET @StartDate = '9/8/2015'

--Purpose of this variable is due to parameter sniffing slowing the report down
DECLARE @StartDate2 DATE
SET @StartDate2 = @StartDate


Declare @EndDate DATE
Set @EndDate = (select Date from tblTime where DayID = (select (dayID+7) from tblTime where Date = @StartDate2))

	select 
	FKStoreID, 
	P.FKEmployeeNumber,
	PD.Name as EmployeeName,
	Checknumber, 
	Dateofbusiness
	From AlohaData.dbo.dpvHstGndItem P
	INNER JOIN DimMenuItemHierarchy D ON P.FKItemID = D.MenuItemID
	LEFT OUTER JOIN HR.dbo.PS_Personal_Data PD on P.FKEmployeeNumber = PD.Emplid
	where 
	D.MenuItemCategory = 'Gift Cards' and
	Price >= 50 and 
	DateOfBusiness Between @StartDate2 and @EndDate
	AND PD.Name IS NULL
	Group By 
	FKStoreID,
	P.FKEmployeeNumber, 
	PD.Name, 
	Checknumber, 
	Dateofbusiness


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
	AND T.CheckNumber IN (10137
,10415
,10002)