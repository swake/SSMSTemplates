use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimLedger') drop table dbo.dimLedger
go

create table dbo.dimLedger
	(
	ledgerSK int identity(1,1) not null
	, ledgerName varchar(35) not null -- Type 0
	, ledgerGroupCd char(1) not null -- Type 1
	)
go

alter table dbo.dimLedger add constraint PK_dimLedger primary key nonclustered (ledgerSK)
go

create clustered index IX_dimLedger_Name on dbo.dimLedger
	(
	ledgerName asc
	)
go

-- unspecified
set identity_insert dbo.dimLedger on
 
insert into dbo.dimLedger
	(
	ledgerSK
	, ledgerName
	, ledgerGroupCd
	)
values
	(
	0 -- ledgerSK
	, 'Unspecified' -- ledgerName
	, '0' -- ledgerGroupCd
	)

set identity_insert dbo.dimLedger off
go

insert into
	dbo.dimLedger
select
	left(ledgerName, 1) + lower(right(ledgerName, len(ledgerName) - 1)) as ledgerName 
	, case ledgerName
		when 'AMENDED' then 'B' 
		when 'ACTUALS' then 'A'
		else 'O'
		end as ledgerGroupCd
from
	(
	select distinct
		rtrim(LEDGER) as ledgerName
	from
		PS.PS_LEDGER
	union select distinct
		rtrim(LEDGER) as ledgerName
	from
		PS.PS_LEDGER_BUDG
	) l
go

select * from dbo.dimLedger
go
