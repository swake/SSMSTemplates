use RGPWork
go

if exists (select object_id from sys.objects where [name] = 'factEnergyPrice' and [type] = 'U') drop table dbo.factEnergyPrice
go

create table dbo.factEnergyPrice
	(
	energyPriceSK int not null
	, dateID int not null
	, energyPrice money not null
	)
go

insert into
	dbo.factEnergyPrice
select
	isnull(dimEP.energyPriceSK, 0) as energyPriceSK
	, isnull(dimD.dateID, 0) as dateID
	, ep.EnergyPrice
from
	BPC.EnergyPrice ep
	left outer join dbo.dimEnergyPrice dimEP on
		dimEP.energyPriceCd = ep.AccountKey
	left outer join dbo.dimDate dimD on
		dimD.calendarDate =
			case left(ep.monthKey, 4)
				when 2014 then cast('2014-09-30' as date)
				else cast(getdate() as date)
				end
go

select * from dbo.factEnergyPrice
go
