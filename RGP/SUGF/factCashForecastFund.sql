use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'factCashForecastFund' and [type] = 'U') drop table dbo.factCashForecastFund
go

create table dbo.factCashForecastFund
	(
	fundSK int not null
	, accountForecastSK int not null
	, dateID int not null
	, forecastAmt money not null
	)
go

insert into
	dbo.factCashForecastFund
select
	isnull(dimF.fundSK, 0) as fundSK
	, isnull(dimAF.accountForecastSK, 0) as accountForecastSK
	, isnull(dimD.dateID, 0) as dateID
	, cast(cff.CashForecastAmt as money) as cashForecastAmt
from
	bpc.CashForecastFund cff
	left outer join dbo.dimfund dimF on
		dimF.fundCd = replace(rtrim(cff.fundKey), 'F_', '')
	left outer join dbo.dimAccountForecast dimAF on
		dimAF.accountForecastCd = cff.AccountKey
	left outer join dbo.dimDate dimD on
		dimD.calendarDate = dateAdd(d, -1, dateAdd(m, 1, cast(left(cff.MonthKey, 4) + '-' + substring(cff.MonthKey, 5, 2) + '-01' as date)))
go

select * from dbo.factCashForecastFund
go
