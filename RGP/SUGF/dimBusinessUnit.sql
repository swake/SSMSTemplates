use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimBusinessUnit') drop table dbo.dimBusinessUnit
go

create table dbo.dimBusinessUnit
	(
	businessUnitSK int identity(1,1) not null
	, businessUnitID nchar(5) not null -- type 0
	, businessUnitDesc nvarchar(35) null -- type 1
	, businessUnitShortDesc nvarchar(25) null -- type 1
	)
go

alter table dbo.dimBusinessUnit add constraint PK_dimBusinessUnit primary key nonclustered (businessUnitSK)
go

create clustered index IX_dimBusinessUnit_ID on dbo.dimBusinessUnit
	(
	businessUnitID asc
	)
go

-- unspecified
set identity_insert dbo.dimBusinessUnit on
 
insert into dbo.dimBusinessUnit
	(
	businessUnitSK
	, businessUnitID
	, businessUnitDesc
	, businessUnitShortDesc
	)
values
	(
	0 -- businessUnitSK
	, '00000' -- businesUnitID
	, 'Unspecified' -- businessUnitDesc
	, 'Unspecified' -- businessUnitShortDesc
	)

set identity_insert dbo.dimBusinessUnit off
go

insert into
	dbo.dimBusinessUnit
select distinct
	BUSINESS_UNIT as businesUnitID
	, DESCR as businessUnitDesc
	, DESCRSHORT as businessUnitShortDesc
from
	PS.PS_BUS_UNIT_TBL_FS
go

select * from dbo.dimBusinessUnit