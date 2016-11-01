use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'factLedger') drop table dbo.factledger
go

create table dbo.factLedger
	(
	businessUnitSK int not null
	, ledgerSK int not null
	, accountSK int not null
	, fundSK int not null
	, departmentSK int not null
	, projectSK int not null
	, postedDateID int not null
	, postedBaseAmt money not null
	, postedTranAmt money not null
	)
go

-- Ledger
insert into
	dbo.factLedger
select
	isnull(dimBU.businessUnitSK, 0) as businessUnitSK
	, isnull(dimL.ledgerSK, 0) as ledgerSK
	, isnull(dimA.accountSK, 0) as accountSK
	, isnull(dimF.fundSK, 0) as fundSK
	, isnull(dimDe.departmentSK, 0) as departmentSK
	, isnull(dimP.projectSK, 0) as projectSK
	, isnull(dimD.dateID, 0) as postedDateID
	, isnull(sum(l.POSTED_BASE_AMT), 0.00) as postedBaseAmt
	, isnull(sum(l.POSTED_TRAN_AMT), 0.00) as postedTranAmt
from
	PS.PS_LEDGER l
	left outer join dbo.dimBusinessUnit dimBU on
		dimBU.businessUnitID = l.BUSINESS_UNIT
	left outer join dbo.dimLedger dimL on
		dimL.ledgerName = l.LEDGER
	left outer join dbo.dimAccount dimA on
		dimA.accountNum = l.ACCOUNT
	left outer join dbo.dimFund dimF on
		dimF.fundCd = l.FUND_CODE
	left outer join dbo.dimDepartment dimDe on
		dimDe.departmentCd = l.DEPTID
	left outer join dbo.dimProject dimP on
		dimP.projectID = l.PROJECT_ID
	left outer join dbo.dimDate dimD on
		dimD.dateID =
			(
			select	max(dimD2.dateID)
			from	dbo.dimDate dimD2
			where	dimD2.fiscalYearNum = l.FISCAL_YEAR
					and dimD2.fiscalPeriodNum = l.ACCOUNTING_PERIOD
			)
group by
	dimBU.businessUnitSK
	, dimL.ledgerSK
	, dimA.accountSK
	, dimF.fundSK
	, dimDe.departmentSK
	, dimP.projectSK
	, dimD.dateID
go

-- Ledger Budget
insert into
	dbo.factLedger
select
	isnull(dimBU.businessUnitSK, 0) as businessUnitSK
	, isnull(dimL.ledgerSK, 0) as ledgerSK
	, isnull(dimA.accountSK, 0) as accountSK
	, isnull(dimF.fundSK, 0) as fundSK
	, isnull(dimDe.departmentSK, 0) as departmentSK
	, isnull(dimP.projectSK, 0) as projectSK
	, isnull(dimD.dateID, 0) as postedDateID
	, isnull(sum(l.POSTED_BASE_AMT), 0.00) as postedBaseAmt
	, isnull(sum(l.POSTED_TRAN_AMT), 0.00) as postedTranAmt
from
	PS.PS_LEDGER_BUDG l
	left outer join dbo.dimBusinessUnit dimBU on
		dimBU.businessUnitID = l.BUSINESS_UNIT
	left outer join dbo.dimLedger dimL on
		dimL.ledgerName = l.LEDGER
	left outer join dbo.dimAccount dimA on
		dimA.accountNum = l.ACCOUNT
		and dimA.statusCd = 'A'
	left outer join dbo.dimFund dimF on
		dimF.fundCd = l.FUND_CODE
		and dimF.statusCd = 'A'
	left outer join dbo.dimDepartment dimDe on
		dimDe.departmentCd = l.DEPTID
		and dimDe.statusCd = 'A'
	left outer join dbo.dimProject dimP on
		dimP.projectID = l.PROJECT_ID
	left outer join dbo.dimDate dimD on
		dimD.dateID =
			(
			select	max(dimD2.dateID)
			from	dbo.dimDate dimD2
			where	dimD2.fiscalYearNum = l.FISCAL_YEAR
					and dimD2.fiscalPeriodNum = l.ACCOUNTING_PERIOD
			)
group by
	dimBU.businessUnitSK
	, dimL.ledgerSK
	, dimA.accountSK
	, dimF.fundSK
	, dimDe.departmentSK
	, dimP.projectSK
	, dimD.dateID
go

select top 10000 * from dbo.factLedger
go
