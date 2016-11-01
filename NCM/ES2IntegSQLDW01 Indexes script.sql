USE [NCM_DataWarehouse]
GO

CREATE NONCLUSTERED INDEX [IDX_DimDate_FlightWeekKey]
ON [DDS].[DimDate] ([FlightWeekKey],[Date])

CREATE NONCLUSTERED INDEX [IDX_DimTheatre_IsRowCurrent]
ON [DDS].[DimTheatre] ([IsRowCurrent])
INCLUDE ([InitialTheatreKey],[NaturalKey],[ChainKey],[Name])

CREATE NONCLUSTERED INDEX [IDX_InventoryCapacityGroup_Location_LocationId]
ON [RDS].[InventoryCapacityGroup_Location] ([LocationId])
INCLUDE ([InventoryCapacityGroupId],[StandardCapacity],[ManagedCapacity],[EffectiveStartDate],[EffectiveEndDate])

CREATE NONCLUSTERED INDEX [IDX_InventoryCapacityGroup_Location_InventoryCapacityGroupId]
ON [RDS].[InventoryCapacityGroup_Location] ([InventoryCapacityGroupId])
INCLUDE ([LocationId],[StandardCapacity],[ManagedCapacity],[EffectiveStartDate],[EffectiveEndDate])

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS