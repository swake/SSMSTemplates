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
		o.[name] = 'AccountForecast'
		and s.name = 'BPC'
	)
	drop table BPC.AccountForecast
go

create table BPC.AccountForecast
	(
	AccountKey nvarchar(35) not null
	)
go

insert into
	BPC.AccountForecast
select
	"[Measures].[Account Key]" as AccountKey
from
	openquery(BPC,
'
with
	set [Accounts] as
		{
		filter(descendants([Account].[H1].[CASHFCST],,leaves), vba!left([Account].[H1].currentMember.name, 10) = "CFCST_CASH")
		, {[Account].[H1].[CFCST_EBITDA_H],[Account].[H1].[CFCST_EBITDA_L],[Account].[H1].[CFCST_EBITDA_INP],[Account].[H1].[EBITDA]}
		}

	member [Measures].[Account Key] as [Account].[H1].currentMember.properties("Key0")
select
	[Measures].[Account Key]
	on columns
	,
	[Accounts]
	on rows
from
	[Finance]
'
)
go

select * from BPC.AccountForecast
go
