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
		o.[name] = 'EBITDAForecast'
		and s.name = 'BPC'
	)
	drop table BPC.EBITDAForecast
go

create table BPC.EBITDAForecast
	(
	AccountKey nvarchar(35) not null
	, CategoryKey nvarchar(35) not null
	, DepartmentKey nvarchar(35) not null
	, FundKey nvarchar(35) not null
	, MonthKey nvarchar(10) not null
	, EBITDAForecastAmt float not null
	)
go

insert into
	BPC.EBITDAForecast
select
	"[Measures].[Account Key]" as AccountKey
	, "[Measures].[Category Key]" as CategoryKey
	, "[Measures].[Department Key]" as DepartmentKey
	, "[Measures].[Fund Key]" as FundKey
	, "[Measures].[Month Key]" as MonthKey
	, cast("[Measures].[EBITDA Forecast Amt]" as float) as EBITDAForecastAmt
from
	openquery(BPC,
'
with
	member [Measures].[EBITDA Forecast Amt] as [Measures].[Periodic]

	set [Accounts] as {[Account].[H1].[CFCST_EBITDA_H],[Account].[H1].[CFCST_EBITDA_L],[Account].[H1].[CFCST_EBITDA_INP],[Account].[H1].[EBITDA]}
	set [Categories] as {[Category].[H1].[FORECAST], filter([Category].[H1].[Lev1].members, VBA!left([Category].[H1].currentMember.name, 14) = "Budget_Final_2")}
	set [Departments] as descendants([Department].[H1].[ALL DEPARTMENT.H1],,leaves)
	set [Funds] as descendants([Fund].[H1].[ALL_FUNDS],,leaves)
	set [Months] as except([Time].[H1].[MONTH].members, [Time].[H1].[XXXX.QX].children)

	member [Measures].[Account Key] as [Account].[H1].currentMember.properties("Key0")
	member [Measures].[Category Key] as [Category].[H1].currentMember.properties("Key0")
	member [Measures].[Department Key] as [Department].[H1].currentMember.properties("Key0")
	member [Measures].[Fund Key] as [Fund].[H1].currentMember.properties("Key0")
	member [Measures].[Month Key] as [Time].[H1].currentMember.properties("Key0")
select
	{
	[Measures].[Account Key]
	, [Measures].[Category Key]
	, [Measures].[Department Key]
	, [Measures].[Fund Key]
	, [Measures].[Month Key]
	, [Measures].[EBITDA Forecast Amt]
	}
	on columns
	,
	nonEmpty(
		[Accounts]
		* [Categories]
		* [Departments]
		* [Funds]
		* [Months]
		,
		[Measures].[Periodic]
		)
	on rows
from
	[Finance]
'
)
go

select * from BPC.EBITDAForecast
go
