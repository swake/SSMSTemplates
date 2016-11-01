use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimCurrency') drop table dbo.dimCurrency
go

create table dbo.dimCurrency
	(
	currencySK int identity(1,1) not null
	, currencyCd nchar(3) not null -- type 0
	, currencyDesc nvarchar(35) null -- type 1
	, currencyShortDesc nvarchar(25) null -- type 1
	, countryCd nchar(3) null -- type 0
	, countryDesc nvarchar(35) null -- type 1
	, countryShortDesc nvarchar(25) null -- type 1
	, effectiveDate date not null -- type 2
	, statusCd nchar(1) not null -- type 1
	)
go

alter table dbo.dimCurrency add constraint PK_dimCurrency primary key nonclustered (currencySK)
go

create clustered index IX_dimCurrency_Cd on dbo.dimCurrency
	(
	currencyCd asc
	)
go

-- unspecified
set identity_insert dbo.dimCurrency on
 
insert into dbo.dimCurrency
	(
	currencySK
	, currencyCd
	, currencyDesc
	, currencyShortDesc
	, countryCd
	, countryDesc
	, countryShortDesc
	, effectiveDate
	, statusCd
	)
values
	(
	0 -- currencySK
	, '000' -- currencyCd
	, 'Unspecified' -- currencyDesc
	, 'Unspecified' -- currencyShortDesc
	, '000' -- countryCd
	, 'Unspecified' -- countryDesc
	, 'Unspecified' -- countryShortDesc
	, '1901-01-01' -- effectiveDate
	, 'A' -- statusCd
	)

set identity_insert dbo.dimCurrency off
go

insert into
	dbo.dimCurrency
select distinct
	c.CURRENCY_CD as currencyCd
	, c.DESCR as currencyDesc
	, c.DESCRSHORT as currencyShortDesc
	, c.COUNTRY as countryCd
	, cc.DESCR as countryDesc
	, cc.DESCRSHORT as countryShortDesc
	, cast(c.EFFDT as date) as effectiveDate
	, c.EFF_STATUS as statusCd
from
	PS.PS_CURRENCY_CD_TBL c
	inner join PS.PS_COUNTRY_TBL cc on
		c.COUNTRY = cc.COUNTRY
go

select * from dbo.dimCurrency
go
