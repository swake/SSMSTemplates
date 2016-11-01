use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimFund') drop table dbo.dimFund
go

create table dbo.dimFund
	(
	fundSK int identity(1,1) not null
	, fundCd char(5) not null
	, fundDesc varchar(35) not null
	, fundShortDesc varchar(15) null
	, effectiveDate date not null
	, statusCd nchar(1) not null
	)
go

alter table dbo.dimFund add constraint PK_dimFund primary key nonclustered (fundSK)
go

create clustered index IX_dimFund_Cd on dbo.dimFund
	(
	fundCd asc
	)
go

create nonclustered index IX_dimFund_desc on dbo.dimFund
	(
	fundDesc asc
	)
go

-- unspecified
set identity_insert dbo.dimFund on
 
insert into dbo.dimFund
	(
	fundSK
	, fundCd
	, fundDesc
	, fundShortDesc
	, effectiveDate
	, statusCd
	)
values
	(
	0 -- fundSK
	, '00000' -- fundCd
	, 'Unspecified' -- fundDesc
	, 'Unspecified' -- fundShortDesc
	, '1901-01-01' -- effectiveDate
	, 'A' -- statusCd
	)
	
set identity_insert dbo.dimFund off
go

-- Load PS data
insert into
	dbo.dimFund
select distinct
	rtrim(FUND_CODE) as fundCd
	, rtrim(DESCR) as fundDesc
	, rtrim(DESCRSHORT) as fundShortDesc
	, cast(EFFDT as date) as effectiveDate
	, EFF_STATUS as statusCd
from
	PS.PS_FUND_TBL f
where
	SETID = 'SHARE'
	and FUND_CODE not in
		(
		'207' -- Casino
		, '469' -- FAMPA (Fairfax Midstream)
		, '010', '020', '030' -- Metro
		, '115' -- Permanent
		, '445' -- San Bois
		)
go

select * from dbo.dimFund
go
