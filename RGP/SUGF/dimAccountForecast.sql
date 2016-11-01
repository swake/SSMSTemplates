use RGPWork
go

if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimAccountForecast') drop table dbo.dimAccountForecast
go

create table dbo.dimAccountForecast
	(
	accountForecastSK int identity(1,1) not null
	, accountForecastCd nvarchar(35) null -- type 0
	, accountForecastDesc nvarchar(25) null -- type 1
	)
go

alter table dbo.dimAccountForecast add constraint PK_dimAccountForecast primary key nonclustered (accountForecastSK)
go

create clustered index IX_dimAccountForecast_Desc on dbo.dimAccountForecast
	(
	accountForecastDesc asc
	)
go

-- unspecified
set identity_insert dbo.dimAccountForecast on
 
insert into dbo.dimAccountForecast
	(
	accountForecastSK
	, accountForecastCd
	, accountForecastDesc
	)
values
	(
	0 -- accountForecastSK
	, 'Unspecified' -- accountForecastCd
	, 'Unspecified' -- accountForecastDesc
	)

set identity_insert dbo.dimAccountForecast off
go

insert into
	dbo.dimAccountForecast
select distinct
	AccountKey as accountForecastCd
	, replace(replace(AccountKey, 'CFCST_', ''), '_', ' ') as cashForecastDesc
from
	BPC.accountForecast
go

select * from dbo.dimAccountForecast
go
