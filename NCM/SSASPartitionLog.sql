/****** Script for SelectTopNRows command from SSMS  ******/
SELECT pb.DatabaseID AS [Database]
	,pb.CubeID AS [Cube]
	,p.PartitionName AS [Partition]
	,pl.[StartDT] AS [StartDateTime]
	,pl.[EndDT] AS [EndDateTime]
	,DurationInMin = DATEDIFF(MINUTE,pl.[StartDT],pl.[EndDT])
	,pl.[Action]
	,pl.[ProcessType]
FROM [NCM_DataWarehouse].[Admin].[SSASPartitionLog] pl
INNER JOIN [NCM_DataWarehouse].[Admin].[SSASPartition] p
	ON p.SSASPartitionID = pl.SSASPartitionID
INNER JOIN [NCM_DataWarehouse].[Admin].[SSASPartitionBase] pb
	ON p.PartitionBaseID = pb.PartitionBaseID
WHERE pb.DatabaseID LIKE 'Inventory%'
	AND StartDT BETWEEN DATEADD(HOUR,-24,SYSDATETIME()) AND SYSDATETIME()
ORDER BY pl.StartDT DESC