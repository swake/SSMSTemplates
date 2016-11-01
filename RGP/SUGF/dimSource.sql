use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimSource') drop table dbo.dimSource
go

create table dbo.dimSource
	(
	sourceSK int identity(1,1) not null
	, sourceCd char(3) not null -- Type 0
	, sourceDesc varchar(35) not null -- Type 1
	, effectiveDate date not null -- Type 2
	, statusCd char(1) not null -- Type 1
	)
go

alter table dbo.dimSource add constraint PK_dimSource primary key nonclustered (sourceSK)
go

create clustered index IX_dimSource_Cd on dbo.dimSource
	(
	sourceCd asc
	)
go

create nonclustered index IX_dimSource_Desc on dbo.dimSource
	(
	sourceDesc asc
	)
go

-- unspecified
set identity_insert dbo.dimSource on
 
insert into dbo.dimSource
	(
	sourceSK
	, sourceCd
	, sourceDesc
	, effectiveDate
	, statusCd
	)
values
	(
	0 -- sourceSK
	, '000' -- sourceCd
	, 'Unspecified' -- sourceDesc
	, '1901-01-01' -- effectiveDate
	, 'A' -- statusCd
	)

set identity_insert dbo.dimSource off
go

insert into
	dbo.dimSource
select distinct
	rtrim([SOURCE]) as sourceCd
	, rtrim(DESCR) as sourceDesc
	, cast(EFFDT as date) as effectiveDate
	, EFF_STATUS as statusCd
from
	PS.PS_SOURCE_TBL
where
	SETID = 'SHARE'
go

select * from dbo.dimSource
go
