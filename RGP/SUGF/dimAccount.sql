use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimAccount') drop table dbo.dimAccount
go

create table dbo.dimAccount
	(
	accountSK int identity(1,1) not null
	, accountNum nvarchar(10) not null -- type 0
	, accountDesc nvarchar(35) null -- type 1
	, accountShortDesc nvarchar(25) null -- type 1
	, accountTypeID nchar(1) not null -- type 0
	, accountTypeDesc nvarchar(35) not null -- type 1
	, accountTypeShortDesc nvarchar(25) not null -- type 1
	, effectiveDate date not null -- type 2
	, statusCd nchar(1) not null -- type 1
	)
go

alter table dbo.dimAccount add constraint PK_dimAccount primary key nonclustered (AccountSK)
go

create clustered index IX_dimAccount_Num on dbo.dimAccount
	(
	accountNum asc
	)
go

-- unspecified
set identity_insert dbo.dimAccount on
 
insert into dbo.dimAccount
	(
	accountSK
	, accountNum
	, accountDesc
	, accountShortDesc
	, accountTypeID
	, accountTypeDesc
	, accountTypeShortDesc
	, effectiveDate
	, statusCd
	)
values
	(
	0 -- accountSK
	, '00000' -- accountNum
	, 'Unspecified' -- accountDesc
	, 'Unspecified' -- accountShortDesc
	, 'U' -- accountTypeID
	, 'Unspecified' -- accountTypeDesc
	, 'Unspecified' -- accountTypeShortDesc
	, '1901-01-01' -- effectiveDate
	, 'A' -- statusCd
	)

set identity_insert dbo.dimAccount off
go

-- PeopleSoft
insert into
	dbo.dimAccount
select distinct
	rtrim(a.ACCOUNT) as accountNum
	, case isnull(rtrim(a.DESCR), '') when '' then null else rtrim(a.DESCR) end as accountDesc
	, case isnull(rtrim(a.DESCRSHORT), '') when '' then null else rtrim(a.DESCRSHORT) end as accountShortDesc
	, case isnull(rtrim(typ.DESCR), '') when '' then 'S' else rtrim(typ.ACCOUNT_TYPE) end as accountTypeID
	, case isnull(rtrim(typ.DESCR), '') when '' then 'Statistical' else rtrim(typ.DESCR) end as accountTypeDesc
	, case isnull(rtrim(typ.DESCRSHORT), '') when '' then 'Statistical' else rtrim(typ.DESCRSHORT) end as accountTypeShortDesc
	, cast(a.EFFDT as date) as effectiveDate
	, a.EFF_STATUS as statusCd
from
	PS.PS_GL_ACCOUNT_TBL a
	left outer join PS.PS_ACCT_TYPE_TBL typ on
		typ.ACCOUNT_TYPE = a.ACCOUNT_TYPE
where
	a.SETID = 'SHARE'
order by
	rtrim(a.ACCOUNT)
go

select * from dbo.dimAccount
go

