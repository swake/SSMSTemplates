DECLARE @DateLastRateCardPush DATETIME
DECLARE @DateLastInventoryFullLoad DATETIME

--Find Date of Last Rate Card Push
SET @DateLastRateCardPush = ISNULL(
	(
		SELECT TOP 1 ModifiedDateTime
		FROM [DWJobs_to_DW].[NCM_DataWarehouse].[RDS].[MovieImpressionsPush]
		ORDER BY ModifiedDateTime DESC
	),'1900-01-01')

--Find Date of Last Inventory Full Load
SET @DateLastInventoryFullLoad = ISNULL(
	(
		SELECT TOP 1 EndRunDateTime
		FROM [DWJobs_to_DW].[NCM_Datawarehouse].[Admin].[ETLDDSBatch]
		WHERE DDSObjectName = 'FactInventory_Initial_CompleteLoad'
			AND EndRunDateTime IS NOT NULL
		ORDER BY EndRunDateTime DESC
	),'1900-01-01')

--If the Last Rate Card Push was after the Last Inventory Full Load, change setting to run a new full Inventory load
IF (DATEDIFF(DAY,@DateLastRateCardPush,@DateLastInventoryFullLoad)) < 0
	BEGIN
		UPDATE [DWJobs_to_DW].[NCM_Datawarehouse].[Admin].[EtlSettings] 
		SET SettingValue = 1 
		WHERE SettingName = 'FactInventory full load In Progress'
	END