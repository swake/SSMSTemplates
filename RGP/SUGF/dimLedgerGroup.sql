use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimLedgerGroup') drop table dbo.dimLedgerGroup
go

create table dbo.dimLedgerGroup
	(
	ledgerGroupSK int identity(1,1) not null
	, ledgerGroupCd char(1) not null -- Type 0
	, ledgerGroupName varchar(35) not null -- Type 1 
	)
go

alter table dbo.dimLedgerGroup add constraint PK_dimLedgerGroup primary key nonclustered (ledgerGroupSK)
go

create clustered index IX_dimLedgerGroup_Name on dbo.dimLedgerGroup
	(
	ledgerGroupName asc
	)
go

-- unspecified
set identity_insert dbo.dimLedgerGroup on
 
insert into dbo.dimLedgerGroup
	(
	ledgerGroupSK
	, ledgerGroupCd
	, ledgerGroupName
	)
values
	(
	0 -- ledgerGroupSK
	, '0' -- ledgerGroupCd
	, 'Unspecified' -- ledgerGroupName
	)

set identity_insert dbo.dimLedgerGroup off
go

insert into
	dbo.dimLedgerGroup
select 'A' as ledgerGroupCd, 'Actuals' as ledgerGroupName
union select 'B', 'Budget'
union select 'O', 'Other'
go

select * from dbo.dimLedgerGroup
go
