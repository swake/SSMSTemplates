if exists (select OBJECT_ID from sys.objects where [type] = 'U' and [name] = 'dimEnergyPrice') drop table dbo.dimEnergyPrice
go

create table dbo.dimEnergyPrice
	(
	energyPriceSK int identity(1,1) not null
	, energyPriceCd varchar(7) not null -- type 0
	, energyPriceDesc nvarchar(35) null -- type 1
	)
go

alter table dbo.dimEnergyPrice add constraint PK_dimEnergyPrice primary key nonclustered (energyPriceSK)
go

create clustered index IX_dimEnergyPrice_desc on dbo.dimEnergyPrice
	(
	energyPriceDesc asc
	)
go

create nonclustered index IX_dimEnergyPrice_Cd on dbo.dimEnergyPrice
	(
	energyPriceCd asc
	)
go

-- unspecified
set identity_insert dbo.dimEnergyPrice on
 
insert into dbo.dimEnergyPrice
	(
	energyPriceSK
	, energyPriceCd
	, energyPriceDesc
	)
values
	(
	0 -- energyPriceSK
	, '0' -- energyPriceCd
	, 'Unspecified' -- energyPriceDesc
	)

set identity_insert dbo.dimEnergyPrice off
go

insert into
	dbo.dimEnergyPrice
select 'Price1' energyPriceID, 'Gas Budget' as energyPriceDesc
union select 'Price2', 'Gas Low'
union select 'Price3', 'Gas Expected'
union select 'Price4', 'Gas High'
union select 'Price5', 'SJB Gas Budget'
union select 'Price6', 'SJB Gas Low'
union select 'Price7', 'SJB Gas Expected'
union select 'Price8', 'SJB Gas High'
union select 'Price9', 'WTI Oil Budget'
union select 'Price10', 'WTI Oil Low'
union select 'Price11', 'WTI Oil Expected'
union select 'Price12', 'WTI Oil High'
union select 'Price13', 'Gulf of Mexico Budget'
union select 'Price14', 'Gulf of Mexico Low'
union select 'Price15', 'Gulf of Mexico Expected'
union select 'Price16', 'Gulf of Mexico High'
go

select * from dbo.dimEnergyPrice
go
