use RGPWork
go

if exists
	(
	select
		o.object_id
	from
		sys.objects o
		inner join sys.schemas s on
			s.schema_id = o.schema_id
	where
		o.[name] = 'CashForecastDepartment'
		and s.name = 'BPC'
	)
	drop table BPC.CashForecastDepartment
go

create table BPC.CashForecastDepartment
	(
	DepartmentKey nvarchar(35) not null
	, AccountKey nvarchar(35) not null
	, MonthKey nvarchar(10) not null
	, CashForecastAmt float not null
	)
go

insert into
	BPC.CashForecastDepartment
select
	"[Measures].[Department Key]" as DepartmentKey
	, "[Measures].[Account Key]" as AccountKey
	, "[Measures].[Month Key]" as MonthKey
	, cast("[Measures].[Cash Forecast Amt]" as float) as CastForecastAmt
from
	openquery(BPC,
'
with
	member [Measures].[Cash Forecast Amt] as [Measures].[Periodic]

	set [Accounts] as filter(descendants([Account].[H1].[CASHFCST],,leaves), vba!left([Account].[H1].currentMember.name, 10) = "CFCST_CASH")
	set [Departments] as filter(descendants([Department].[H1].[ALL_DepartmentS],,leaves), vba!left([Department].[H1].currentMember.name, 2) = "D_")
	set [Months] as [Time].[H1].[MONTH].members

	member [Measures].[Account Key] as [Account].[H1].currentMember.properties("Key0")
	member [Measures].[Department Key] as [Department].[H1].currentMember.properties("Key0")
	member [Measures].[Month Key] as [Time].[H1].currentMember.properties("Key0")
select
	{
	[Measures].[Account Key]
	, [Measures].[Department Key]
	, [Measures].[Month Key]
	, [Measures].[Cash Forecast Amt]
	}
	on columns
	,
	filter(
		[Accounts]
		* [Departments]
		* [Months]
		,
		coalesceEmpty([Measures].[Periodic], 0) <> 0
		)
	on rows
from
	[Finance]
where
	[Category].[H1].[FORECAST]
'
)
go

select * from BPC.CashForecastDepartment
go
