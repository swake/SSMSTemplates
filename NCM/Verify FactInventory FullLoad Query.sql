SELECT 'Inv Admin.ETLSettings'
	,*
FROM [NCM_DataWarehouse].[Admin].[ETLSettings] WITH (NOLOCK)
WHERE SettingName IN 
(
'Inventory: DDS.FactInventory Parallel Processes - Full'
,'FactInventory full load In Progress'
,'FactInventory full load latest OrderlineSecondaryId'
)

EXECUTE [NCM_DataWarehouse].[Admin].[GetThreadCount] 'FactInventory_FullLoad'

IF (SELECT SettingValue FROM [NCM_DataWarehouse].[Admin].[ETLSettings] WITH (NOLOCK) WHERE SettingName = 'FactInventory full load In Progress') = 1
BEGIN
	DECLARE @CurrentOLS FLOAT = ISNULL((SELECT TOP 1 CAST(SettingValue AS FLOAT) FROM [NCM_DataWarehouse].[Admin].[ETLSettings] WITH (NOLOCK) WHERE SettingName = 'FactInventory full load latest OrderlineSecondaryId'),0)
	DECLARE @MaxOLS FLOAT = ISNULL((SELECT TOP 1 MAX([OrderlineSecondaryId]) FROM [NCM_DataWarehouse].[DDS].[DimOrderline_Inv] WITH (NOLOCK)),0)
	DECLARE @PercentComplete INT = ISNULL((@CurrentOLS / @MaxOLS) * 100,0)

	SELECT TOP 1 @CurrentOLS AS CurrentOrderlineSecondaryId
		,@MaxOLS AS MaxOrderlineSecondaryId
		,@PercentComplete AS PercentComplete
	FROM [NCM_DataWarehouse].[DDS].[DimOrderline_Inv] WITH (NOLOCK)

	DECLARE @FactInvStart DATETIME = (SELECT TOP 1 StartRunDateTime FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK) WHERE DDSObjectName = 'FactInventory_Master' AND EndRunDateTime IS NULL ORDER BY StartRunDateTime DESC)
	DECLARE @FactInvDiff INT = DATEDIFF(MINUTE,@FactInvStart,SYSDATETIME())
	DECLARE @FactInvPercentDiff FLOAT = (CAST(100 AS FLOAT) - CAST(@PercentComplete AS FLOAT)) / CAST(100 AS FLOAT)
	DECLARE @EstimatedFinish DATETIME = DATEADD(MINUTE,ISNULL(@FactInvPercentDiff * CAST(@FactInvDiff AS FLOAT),0),SYSDATETIME())
	
	SELECT @EstimatedFinish AS EstimatedFactInventoryLoadComplete
END

SELECT 'Latest Inv Master Batches'
	,*
	,DurationMinutes = DATEDIFF(MINUTE,StartRunDateTime,EndRunDateTime)
FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK)
WHERE DDSBatchId = (SELECT MAX(DDSBatchId) FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK) WHERE DDSObjectName = 'ETL.FactInventoryImpressionsSUM')
UNION
SELECT 'Latest Inv Master Batches'
	,*
	,DurationMinutes = DATEDIFF(MINUTE,StartRunDateTime,EndRunDateTime)
FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK)
WHERE DDSBatchId = (SELECT MAX(DDSBatchId) FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK) WHERE DDSObjectName = 'FactInventoryCapacity_Master')
UNION
SELECT 'Latest Inv Master Batches'
	,*
	,DurationMinutes = DATEDIFF(MINUTE,StartRunDateTime,EndRunDateTime)
FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK)
WHERE DDSBatchId = (SELECT MAX(DDSBatchId) FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK) WHERE DDSObjectName = 'FactInventory_Master')

SELECT *
	  ,DurationMinutes = DATEDIFF(MINUTE,StartRunDateTime,EndRunDateTime)
FROM [NCM_DataWarehouse].[Admin].[ETLDDSBatch] WITH (NOLOCK)
WHERE DDSObjectName LIKE '%FactInventory%'
	AND StartRunDateTime BETWEEN DATEADD(HOUR,-24,SYSDATETIME()) AND SYSDATETIME()
ORDER BY StartRunDateTime DESC