use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'dimdepartmentBPC' and [type] = 'U') drop table dbo.dimdepartmentBPC
go

create table dbo.dimdepartmentBPC
	(
	departmentCd nchar(10) not null
	, level8Name nvarchar(35) null
	, level7Name nvarchar(35) null
	, level6Name nvarchar(35) null
	, level5Name nvarchar(35) null
	, level4Name nvarchar(35) null
	, level3Name nvarchar(35) null
	, level2Name nvarchar(35) null
	, level1Name nvarchar(35) null
	)
go

insert into
	dbo.dimDepartmentBPC
select distinct
	replace(level1Key, 'D_', '') as departmentCd
	, replace(rtrim(level2Name), '_', ' ') as level8Name
	, replace(rtrim(level3Name), '_', ' ') as level7Name
	, replace(rtrim(level4Name), '_', ' ') as level6Name
	, replace(rtrim(level5Name), '_', ' ') as level5Name
	, replace(rtrim(level6Name), '_', ' ') as level4Name
	, replace(rtrim(level7Name), '_', ' ') as level3Name
	, replace(rtrim(level8Name), '_', ' ') as level2Name
	, replace(rtrim(level9Name), '_', ' ') as level1Name
from
	BPC.Department
go

select * from dbo.dimDepartmentBPC
go
