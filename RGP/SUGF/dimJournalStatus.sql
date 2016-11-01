use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimJournalStatus') drop table dbo.dimJournalStatus
go

create table dbo.dimJournalStatus
	(
	journalStatusSK int identity(1,1) not null
	, journalStatusCd char(1) not null -- Type 0
	, journalStatusDesc varchar(50) null -- Type 1
	, journalStatusShortDesc varchar(30) null -- Type 1
	)
go

alter table dbo.dimJournalStatus add constraint PK_dimJournalStatus primary key nonclustered (journalStatusSK)
go

create clustered index IX_dimJournalStatus_Desc on dbo.dimJournalStatus
	(
	journalStatusDesc asc
	)
go

-- unspecified
set identity_insert dbo.dimJournalStatus on
 
insert into dbo.dimJournalStatus
	(
	journalStatusSK
	, journalStatusCd
	, journalStatusDesc
	, journalStatusShortDesc
	)
values
	(
	0 -- journalStatusSK
	, '0' -- journalStatusCd
	, 'Unspecified' -- journalStatusDesc
	, 'Unspecified' -- journalStatusShortDesc
	)

set identity_insert dbo.dimJournalStatus off
go

insert into
	dbo.dimJournalStatus
select distinct
	JRNL_HDR_STATUS as journalStatusCd
	, rtrim(DESCR50) as journalStatusDesc
	, rtrim(DESCR30) as journalStatusShortDesc
from
	PS.PS_BOBJ_JRNLSTATUS
where
	JRNL_HDR_STATUS not in ('N','V')
go

select * from dbo.dimJournalStatus
go
