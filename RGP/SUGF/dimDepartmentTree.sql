use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimDepartmentTree') drop table dbo.dimDepartmentTree
go

create table dbo.dimDepartmentTree
	(
	treename nvarchar(25) not null
	, departmentRangeMin nchar(10) not null
	, departmentRangeMax nchar(10) not null
	, leafLevelNum int not null
	, level1Name nvarchar(20) not null
	, level1Desc nvarchar(30) not null
	, level2Name nvarchar(20) not null
	, level2Desc nvarchar(30) not null
	, level3Name nvarchar(20) not null
	, level3Desc nvarchar(30) not null
	, level4Name nvarchar(20) not null
	, level4Desc nvarchar(30) not null
	, level5Name nvarchar(20) not null
	, level5Desc nvarchar(30) not null
	, level6Name nvarchar(20) not null
	, level6Desc nvarchar(30) not null
	, level7Name nvarchar(20) not null
	, level7Desc nvarchar(30) not null
	, level8Name nvarchar(20) not null
	, level8Desc nvarchar(30) not null
	, level9Name nvarchar(20) not null
	, level9Desc nvarchar(30) not null
	, level10Name nvarchar(20) not null
	, level10Desc nvarchar(30) not null
	)
go

create clustered index IX_dimDepartmentTree_name on dbo.dimDepartmentTree
	(
	treeName asc
	, level2Name asc
	)
go

insert into
	dbo.dimDepartmentTree
select distinct
	rtrim(t.treeName) as treeName
	, cast(t.accountRangeMin as nchar(10)) as departmentRangeMin
	, cast(t.accountRangeMax as nchar(10)) as departmentRangeMax
	, t.leafLevelNum
	, t.level1Name
	, t.level1Desc
	, t.level2Name
	, t.level2Desc
	, t.level3Name
	, t.level3Desc
	, t.level4Name
	, t.level4Desc
	, t.level5Name
	, t.level5Desc
	, t.level6Name
	, t.level6Desc
	, t.level7Name
	, t.level7Desc
	, t.level8Name
	, t.level8Desc
	, t.level9Name
	, t.level9Desc
	, t.level10Name
	, t.level10Desc
from
	PS.Trees t
where
	t.treeTypeName = 'Department'
	and cast(getDate() as date) between t.effectiveDate and isnull(t.obsoleteDate, cast(getdate() as date))
	and t.leafLevelNum =
		(
		select	min(leafLevelNum)
		from	PS.Trees t2
		where	t2.treeName = t.treeName
				and t2.accountRangeMin = t.accountRangeMin
				and t2.accountRangeMax = t.accountRangeMax
		)
go

select * from dbo.dimDepartmentTree
go
