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
		o.[name] = 'EnergyPrice'
		and s.name = 'BPC'
	)
	drop table BPC.EnergyPrice
go

create table BPC.EnergyPrice
	(
	AccountKey nvarchar(35) not null
	, MonthKey nvarchar(10) not null
	, EnergyPrice money not null
	)
go

insert into
	BPC.EnergyPrice
select
	"[Measures].[Account Key]" as AccountKey
	, "[Measures].[Month Key]" as monthKey
	, cast("[Measures].[Energy Price]" as money) as EnergyPrice
from
	openquery(BPC,
'
with
	member [Measures].[Energy Price] as [Measures].[Periodic]

	set [Accounts] as except(filter([Account].[H1].members, VBA!inStr([Account].[H1].currentMember.name, "Price") > 0), {[Account].[H1].[PRICES]})
	set [Months] as [Time].[H1].Month.members

	member [Measures].[Account Key] as [Account].[H1].currentMember.properties("Key0")
	member [Measures].[Month Key] as [Time].[H1].currentMember.properties("Key0")
select
	{
	[Measures].[Account Key]
	, [Measures].[Month Key]
	, [Measures].[Energy Price]
	}
	on columns
	,
	nonEmpty(
		[Accounts]
		* [Months]
		, [Measures].[Periodic]
		)
	on rows
from
	[Finance]
where
	[Category].[H1].[FORECAST]
'
)
go

select * from BPC.EnergyPrice
go
