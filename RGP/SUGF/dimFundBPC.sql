use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'dimFundBPC' and [type] = 'U') drop table dbo.dimFundBPC
go

create table dbo.dimFundBPC
	(
	fundCd nchar(5) not null
	, level8Name nvarchar(35) null
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
	dbo.dimFundBPC
select distinct
	replace(rtrim(level1Key), 'F_', '') as fundCd
	, replace(rtrim(level2Name), '_', ' ') as level8Name
	, replace(rtrim(level3Name), '_', ' ') as level7Name
	, replace(rtrim(level4Name), '_', ' ') as level6Name
	, replace(rtrim(level5Name), '_', ' ') as level5Name
	, replace(rtrim(level6Name), '_', ' ') as level4Name
	, replace(rtrim(level7Name), '_', ' ') as level3Name
	, replace(rtrim(level8Name), '_', ' ') as level2Name
	, replace(rtrim(level9Name), '_', ' ') as level1Name
from
	BPC.Fund
go

select * from dbo.dimFundBPC
go
