use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimStatus') drop table dbo.dimStatus
go

create table dbo.dimStatus
	(
	statusSK int not null
	, statusCd char(1) not null -- type 0
	, statusDesc varchar(35) not null -- type 1
	)
go

alter table dbo.dimStatus add constraint PK_dimStatus primary key nonclustered (statusSK)
go

create clustered index IX_dimStatus_Cd on dbo.dimStatus
	(
	statusCd asc
	)
go

insert into
	dbo.dimStatus
select 0 as statusSK,'U' as statusCd, 'Unspecified' as statusDesc
union select 1,'A','Active'
union select 2,'I', 'Inactive'
go

select * from dbo.dimStatus
go
