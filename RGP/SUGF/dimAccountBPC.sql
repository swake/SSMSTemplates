use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'dimAccountBPC' and [type] = 'U') drop table dbo.dimAccountBPC
go

create table dbo.dimAccountBPC
	(
	accountNum nvarchar(35) not null
	, level7Name nvarchar(35) null
	, level6Name nvarchar(35) null
	, level5Name nvarchar(35) null
	, level4Name nvarchar(35) null
	, level3Name nvarchar(35) null
	, level2Name nvarchar(35) null
	, level1Name nvarchar(35) not null
	)
go

insert into
	dbo.dimAccountBPC
select distinct
	accountNum
	, replace(rtrim(level2Name), '_', ' ') as level7Name
	, replace(rtrim(level3Name), '_', ' ') as level6Name
	, replace(rtrim(level4Name), '_', ' ') as level5Name
	, replace(rtrim(level5Name), '_', ' ') as level4Name
	, replace(rtrim(level6Name), '_', ' ') as level3Name
	, replace(rtrim(level7Name), '_', ' ') as level2Name
	, replace(rtrim(level8Name), '_', ' ') as level1Name
from
	BPC.Account
go

select * from dbo.dimAccountBPC
go
