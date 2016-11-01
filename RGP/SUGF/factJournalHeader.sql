use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'factJournalHeader') drop table dbo.factJournalHeader
go

create table dbo.factJournalHeader
	(
	journalHeaderSK int identity(1,1) not null
	, journalID varchar(10) not null
	, businessUnitID char(5) not null
	, unpostSeqNum char(1) not null
	, journalDate date not null
	, businessUnitSK int not null
	, ledgerGroupSK int not null
	, sourceSK int not null
	, journalStatusSK int not null
	, accountingDateID int not null
	, journalDateID int not null
	, postedDateID int not null
	, journalHeaderDesc varchar(35) null
	, accountingDefName varchar(10) null
	, sourceSystemCd char(3) null
	)
go

alter table dbo.factJournalHeader add constraint PK_factJournalHeader primary key nonclustered
	(
	journalID
	, businessUnitID
	, unpostSeqNum
	, journalDate
	)
go

insert into
	dbo.factJournalHeader
select
	jh.JOURNAL_ID as journalID
	, jh.BUSINESS_UNIT
	, jh.UNPOST_SEQ as unpostSeqNum
	, cast(jh.JOURNAL_DATE as date) as journalDate
	, isnull(dimBU.businessUnitSK, 0) as businessUnitSK
	, isnull(dimLG.ledgerGroupSK, 0) as ledgerGroupSK
	, isnull(dimS.sourceSK, 0) as sourceSK
	, isnull(dimJS.journalStatusSK, 0) as journalStatusSK
	, dimDa.dateID as accountingDateID
	, dimDj.dateID as journalDateID
	, dimDp.dateID as postedDateID
	, jh.DESCR as journalHeaderDesc
	, jh.ACCTG_DEF_NAME as accountingDefName
	, jh.SYSTEM_SOURCE as sourceSystemCd
from
	PS.PS_JRNL_HEADER jh
	inner join dbo.dimDate dimDa on
		dimDa.dateID =
			(
			select	max(dimD.dateID)
			from	dbo.dimDate dimD
			where	dimD.fiscalYearNum = jh.FISCAL_YEAR
					and dimD.fiscalPeriodNum = jh.ACCOUNTING_PERIOD
			)
	inner join dbo.dimDate dimDj on
		dimDj.calendarDate = cast(jh.JOURNAL_DATE as date)
	inner join dbo.dimDate dimDp on
		dimDp.calendarDate = cast(jh.POSTED_DATE as date)
	left outer join dbo.dimJournalStatus dimJS on
		dimJS.journalStatusCd = jh.JRNL_HDR_STATUS
	left outer join dbo.dimBusinessUnit dimBU on
		dimBU.businessUnitID = jh.BUSINESS_UNIT
	left outer join dbo.dimSource dimS on
		dimS.sourceCd = jh.[SOURCE]
	left outer join dbo.dimLedgerGroup dimLG on
		dimLG.ledgerGroupCd =
			case jh.LEDGER_GROUP
				when 'AMENDED' then 'B' 
				when 'ACTUALS' then 'A'
				else 'O'
				end
where
	jh.JRNL_HDR_STATUS not in ('N','V')
go

select * from dbo.factJournalHeader
go
