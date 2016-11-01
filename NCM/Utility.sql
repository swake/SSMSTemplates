-- Find ETL batches being processed
SELECT * 
FROM admin.ETLDDSBatch 
WHERE DDSObjectName LIKE '%inventory%' 
ORDER BY StartRunDateTime DESC 

-- Find Fragmentation on indexes
SELECT * FROM sys.dm_db_index_physical_stats (5, object_id('DDS.FactInventoryCapacity'), NULL, NULL, 'DETAILED')

-- Rebuild index
ALTER INDEX ALL ON DDS.FactInventoryCapacity REBUILD

-- Clear caches/buffers
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS