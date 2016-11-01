use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'factJournalLine') drop table dbo.factJournalLine
go

create table dbo.factJournalLine
	(
	journalHeaderSK int not null
	, accountSK int not null
	, fundSK int not null
	, departmentSK int not null
	, projectSK int not null
	, monetaryAmt money not null
	, journalLineDesc nvarchar(65)
	)
go

insert into
	dbo.factJournalLine
select
	factJH.journalHeaderSK
	, isnull(dimA.accountSK, 0) as accountSK
	, isnull(dimF.fundSK, 0) as fundSK
	, isnull(dimDe.departmentSK, 0) as departmentSK
	, isnull(dimP.projectSK, 0) as projectSK
	, isnull(jl.MONETARY_AMOUNT, 0.00) as monetaryAmt
	, jl.LINE_DESCR as journalLineDesc
from
	PS.PS_JRNL_LN jl
	inner join dbo.factJournalHeader factJH on
		factJH.journalID = jl.JOURNAL_ID
		and factJH.businessUnitID = jl.BUSINESS_UNIT
		and factJH.unpostSeqNum = jl.UNPOST_SEQ
		and factJH.journalDate = jl.JOURNAL_DATE
	left outer join dbo.dimAccount dimA on
		dimA.accountNum = jl.ACCOUNT
	left outer join dbo.dimFund dimF on
		dimF.fundCd = jl.FUND_CODE
	left outer join dbo.dimDepartment dimDe on
		dimDe.departmentCd = jl.DEPTID
	left outer join dbo.dimProject dimP on
		dimP.projectID = jl.PROJECT_ID
go

select * from dbo.factJournalLine
go
