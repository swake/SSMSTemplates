SELECT DISTINCT ftr.[OrderlineKey]
FROM [DDS].[FactTotalRevenue] ftr WITH (NOLOCK)
WHERE NOT EXISTS
(
SELECT DISTINCT [OrderlineKey]
FROM [ETL].[v_dw_as_DimOrderLine] WITH (NOLOCK)
)