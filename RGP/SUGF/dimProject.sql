use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimProject') drop table dbo.dimProject
go

create table dbo.dimProject
	(
	projectSK int identity(1,1) not null
	, projectID varchar(15) not null -- Type 0
	, projectDesc varchar(255) null -- Type 1
	, projectShortDesc varchar(180) null -- Type 1
	, businessUnitID char(5) not null -- Type 0
	)
go

alter table dbo.dimProject add constraint PK_dimProject primary key nonclustered (projectSK)
go

create clustered index IX_dimProject_ID on dbo.dimProject
	(
	businessUnitID asc
	, projectID asc
	)
go

-- unspecified
set identity_insert dbo.dimProject on
 
insert into dbo.dimProject
	(
	projectSK
	, projectID
	, projectDesc
	, projectShortDesc
	, businessUnitID
	)
values
	(
	0 -- projectSK
	, 'Unspecified' -- projectID
	, 'Unspecified' -- projectDesc
	, 'Unspecified' -- projectShortDesc
	, '00000' -- businessUnitID
	)
go

set identity_insert dbo.dimProject off
go

insert into
	dbo.dimProject
select distinct
	rtrim(PROJECT_ID) as projectID
	, rtrim(cast(DESCR254 as varchar(255))) as projectDesc
	, rtrim(cast(DESCRLONG as varchar(180))) as projectShortDesc
	, rtrim(BUSINESS_UNIT) as businessUnitID
from
	PS.PS_PROJECT_DESCR
go

select * from dbo.dimProject
go
