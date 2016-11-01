-- OLP Order Validation
SELECT 'ENT OrderLinePricingQueue',*
FROM [DW_to_Enterprise].[Enterprise].[Audit].[OrderLinePricingQueue]
WHERE OrderlineId IN
(
'8084A5B3-657B-E611-8125-00155D35EC26'
,'FAF0B002-667B-E611-8125-00155D35EC26'
,'E624931E-667B-E611-8125-00155D35EC26'
,'7AFE4295-667B-E611-8125-00155D35EC26'
,'71CEB9C9-667B-E611-8125-00155D35EC26'
,'18657FDB-667B-E611-8125-00155D35EC26'
)
ORDER BY ModifiedDate

SELECT 'DW OLP',*
FROM [NCM_DataWarehouse].[ENT].[OrderlinePricing] WITH (NOLOCK)
WHERE OrderLineSecondaryId IN 
(
793943
,793944
,793945
,793946
,793947
,793948
)

SELECT 'DW OLP_Audit',*
FROM [NCM_DataWarehouse].[ENT].[OrderLinePricing_Audit] WITH (NOLOCK)
WHERE OrderLineSecondaryId IN 
(
793943
,793944
,793945
,793946
,793947
,793948
)

-- Enterprise Order Validation
SELECT TOP 10 'ENT Order',*
FROM [DW_to_Enterprise].[Enterprise].[dbo].[Order] WITH (NOLOCK)
ORDER BY ModifiedDate DESC

SELECT 'ENT Orderline',*
FROM [DW_to_Enterprise].[Enterprise].[dbo].[OrderLine] WITH (NOLOCK)
WHERE OrderId IN 
(
'EC8766BA-667B-E611-8125-00155D35EC26'
,'400EB371-667B-E611-8125-00155D35EC26'
,'299867F7-657B-E611-8125-00155D35EC26'
,'3E0A2F7C-657B-E611-8125-00155D35EC26'
)

SELECT 'ENT Orderline_Location',*
FROM [DW_to_Enterprise].[Enterprise].[dbo].[OrderLine_Location] WITH (NOLOCK)
WHERE OrderlineId IN 
(
'8084A5B3-657B-E611-8125-00155D35EC26'
,'FAF0B002-667B-E611-8125-00155D35EC26'
,'E624931E-667B-E611-8125-00155D35EC26'
,'7AFE4295-667B-E611-8125-00155D35EC26'
,'71CEB9C9-667B-E611-8125-00155D35EC26'
,'18657FDB-667B-E611-8125-00155D35EC26'
)

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