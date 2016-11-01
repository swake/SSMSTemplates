use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimDepartment') drop table dbo.dimDepartment
go

create table dbo.dimDepartment
	(
	departmentSK int identity(1,1) not null
	, departmentCd char(10) not null -- type 0
	, departmentDesc varchar(35) not null -- type 1
	, departmentShortDesc varchar(15) null -- type 1
	, effectiveDate date not null -- type 2
	, statusCd nchar(1) not null -- type 1
	)
go

alter table dbo.dimDepartment add constraint PK_dimDepartment primary key nonclustered (departmentSK)
go

create clustered index IX_dimDepartment_Cd on dbo.dimDepartment
	(
	departmentCd asc
	)
go

create nonclustered index IX_dimDepartment_Desc on dbo.dimDepartment
	(
	departmentDesc asc
	)
go

-- unspecified
set identity_insert dbo.dimDepartment on
 
insert into dbo.dimDepartment
	(
	departmentSK
	, departmentCd
	, departmentDesc
	, departmentShortDesc
	, effectiveDate
	, statusCd
	)
values
	(
	0 -- departmentSK
	, '000' -- departmentCd
	, 'Unspecified' -- departmentDesc
	, 'Unspecified' -- departmentShortDesc
	, '1901-01-01' -- effectiveDate
	, 'A' -- statusCd
	)
	
set identity_insert dbo.dimDepartment off
go

-- Load data
insert into
	dbo.dimDepartment
select distinct
	rtrim(DEPTID) as departmentCd
	, rtrim(DESCR) as departmentDesc
	, rtrim(DESCRSHORT) as departmentShortDesc
	, cast(EFFDT as date) as effectiveDate
	, EFF_STATUS as statusCd
from
	PS.PS_DEPT_TBL
where
	SETID = 'SHARE'
go

select * from dbo.dimDepartment
go
