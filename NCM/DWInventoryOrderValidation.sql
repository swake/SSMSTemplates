-- DW Inventory Order Validation
SELECT 'DW ETL ChangedInventoryOrderLines',*
FROM [NCM_DataWarehouse].[ETL].[ChangedInventoryOrderLines] WITH (NOLOCK)
WHERE OrderLineSecondaryId IN 
(
793943
,793944
,793945
,793946
,793947
,793948
)

SELECT 'DW ETL ChangedInventoryOrderLinesAudit',*
FROM [NCM_DataWarehouse].[ETL].[ChangedInventoryOrderLinesAudit] WITH (NOLOCK)
WHERE OrderLineSecondaryId IN 
(
793943
,793944
,793945
,793946
,793947
,793948
)

SELECT 'DW DimOrderline_Inv',*
FROM [NCM_DataWarehouse].[DDS].[DimOrderline_Inv] WITH (NOLOCK)
WHERE OrderLineSecondaryId IN 
(
793943
,793944
,793945
,793946
,793947
,793948
)

--SELECT 'DW FactInventory',*
--FROM [NCM_DataWarehouse].[DDS].[FactInventory] WITH (NOLOCK)
--WHERE Orderline_InvKey IN 
--(

--)

--SELECT 'DW FactInventoryNRT2',*
--FROM [NCM_DataWarehouse].[DDS].[FactInventoryNRT2] WITH (NOLOCK)
--WHERE Orderline_InvKey IN 
--(

--)

--SELECT 'DW FactInventoryNRT3',*
--FROM [NCM_DataWarehouse].[DDS].[FactInventoryNRT3] WITH (NOLOCK)
--WHERE Orderline_InvKey IN 
--(

--)