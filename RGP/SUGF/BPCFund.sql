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
		o.[name] = 'Fund'
		and s.name = 'BPC'
	)
	drop table BPC.Fund
go

create table BPC.Fund
	(
	Level1Key nvarchar(35) null
	, Level2Name nvarchar(35) null
	, Level3Name nvarchar(35) null
	, Level4Name nvarchar(35) null
	, Level5Name nvarchar(35) null
	, Level6Name nvarchar(35) null
	, Level7Name nvarchar(35) null
	, Level8Name nvarchar(35) null
	, Level9Name nvarchar(35) null
	)
go

insert into
	BPC.Fund
select
	"[Measures].[Level1 Key]" as Level1Key
	, "[Measures].[Level2 Name]" as Level2Name
	, "[Measures].[Level3 Name]" as Level3Name
	, "[Measures].[Level4 Name]" as Level4Name
	, "[Measures].[Level5 Name]" as Level5Name
	, "[Measures].[Level6 Name]" as Level6Name
	, "[Measures].[Level7 Name]" as Level7Name
	, "[Measures].[Level8 Name]" as Level8Name
	, "[Measures].[Level9 Name]" as Level9Name
from
	openquery(BPC,
'
with
	member [Measures].[Level1 Key] as [Fund].[H1].currentMember.properties("Key0")

	member [Measures].[Level9 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV9]).name
	member [Measures].[Level8 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV8]).name
	member [Measures].[Level7 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV7]).name
	member [Measures].[Level6 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV6]).name
	member [Measures].[Level5 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV5]).name
	member [Measures].[Level4 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV4]).name
	member [Measures].[Level3 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV3]).name
	member [Measures].[Level2 Name] as ancestor([Fund].[H1].currentMember, [Fund].[H1].[LEV2]).name
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
	, [Measures].[Level9 Name]
	}
	on columns
	,
	[Fund].[H1].[LEV1].members
	on rows
from
	[Finance]
'
)
go

select * from BPC.Fund
go
