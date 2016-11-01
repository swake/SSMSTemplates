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
		o.[name] = 'Account'
		and s.name = 'BPC'
	)
	drop table BPC.Account
go

create table BPC.Account
	(
	accountNum nvarchar(35) null
	, Level2Name nvarchar(35) null
	, Level3Name nvarchar(35) null
	, Level4Name nvarchar(35) null
	, Level5Name nvarchar(35) null
	, Level6Name nvarchar(35) null
	, Level7Name nvarchar(35) null
	, Level8Name nvarchar(35) null
	)
go

insert into
	BPC.account
select
	case "[Measures].[Level1 Key]" when '_N_A' then '#N/A' else "[Measures].[Level1 Key]" end as accountNum
	, "[Measures].[Level2 Name]" as Level2Name
	, "[Measures].[Level3 Name]" as Level3Name
	, "[Measures].[Level4 Name]" as Level4Name
	, "[Measures].[Level5 Name]" as Level5Name
	, "[Measures].[Level6 Name]" as Level6Name
	, "[Measures].[Level7 Name]" as Level7Name
	, "[Measures].[Level8 Name]" as Level8Name
from
	openquery(BPC,
'
with
	member [Measures].[Level1 Key] as [Account].[H1].currentMember.properties("Key0")

	member [Measures].[Level8 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV8]).name
	member [Measures].[Level7 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV7]).name
	member [Measures].[Level6 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV6]).name
	member [Measures].[Level5 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV5]).name
	member [Measures].[Level4 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV4]).name
	member [Measures].[Level3 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV3]).name
	member [Measures].[Level2 Name] as ancestor([Account].[H1].currentMember, [Account].[H1].[LEV2]).name
select
	{
	[Measures].[Level1 Key]
	, [Measures].[Level2 Name]
	, [Measures].[Level3 Name]
	, [Measures].[Level4 Name]
	, [Measures].[Level5 Name]
	, [Measures].[Level6 Name]
	, [Measures].[Level7 Name]
	, [Measures].[Level8 Name]
	}
	on columns
	,
	[Account].[H1].[LEV1].members
	on rows
from
	[Finance]
'
)
go

select * from BPC.Account order by accountNum
go
