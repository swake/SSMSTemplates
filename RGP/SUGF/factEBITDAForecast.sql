use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'factEBITDAForecast' and [type] = 'U') drop table dbo.factEBITDAForecast
go

create table dbo.factEBITDAForecast
	(
	accountForecastSK int not null
	, departmentSK int not null
	, fundSK int not null
	, dateID int not null
	, forecastAmt money not null
	)
go

insert into
	dbo.factEBITDAForecast
select distinct
	isnull(dimAF.accountForecastSK, 0) as accountForecastSK
	, isnull(dimDE.departmentSK, 0) as departmentSK
	, isnull(dimF.fundSK, 0) as fundSK
	, isnull(dimD.dateID, 0) as dateID
	, cast(cast(EBITDAForecastAmt as float) as money) as forecastAmt
from
	BPC.EBITDAForecast ef
	left outer join dbo.dimAccountForecast dimAF on
		dimAF.accountForecastCd = AccountKey
	left outer join dbo.dimDepartment dimDE on
		dimDE.departmentCd = replace(rtrim(ef.DepartmentKey), 'D_', '')
	left outer join dbo.dimFund dimF on
		dimF.fundCd = replace(rtrim(ef.FundKey), 'F_', '')
	left outer join dbo.dimDate dimD on
		dimD.calendarDate = dateAdd(d, -1, dateAdd(m, 1, cast(left(ef.MonthKey, 4) + '-' + substring(ef.MonthKey, 5, 2) + '-01' as date)))
where
	ef.CategoryKey = 'FORECAST'
go

select * from dbo.factEBITDAForecast
go
