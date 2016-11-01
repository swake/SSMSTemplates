use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'factCashForecastDepartment' and [type] = 'U') drop table dbo.factCashForecastDepartment
go

create table dbo.factCashForecastDepartment
	(
	departmentSK int not null
	, accountForecastSK int not null
	, dateID int not null
	, forecastAmt money not null
	)
go

insert into
	dbo.factCashForecastDepartment
select
	isnull(dimDE.departmentSK, 0) as departmentSK
	, isnull(dimAF.accountForecastSK, 0) as accountForecastSK
	, isnull(dimD.dateID, 0) as dateID
	, cast(cfd.CashForecastAmt as money) as cashForecastAmt
from
	bpc.CashForecastDepartment cfd
	left outer join dbo.dimDepartment dimDE on
		dimDE.departmentCd = replace(rtrim(cfd.departmentKey), 'D_', '')
	left outer join dbo.dimAccountForecast dimAF on
		dimAF.accountForecastCd = cfd.AccountKey
	left outer join dbo.dimDate dimD on
		dimD.calendarDate = dateAdd(d, -1, dateAdd(m, 1, cast(left(cfd.MonthKey, 4) + '-' + substring(cfd.MonthKey, 5, 2) + '-01' as date)))
go

select * from dbo.factCashForecastDepartment
go
