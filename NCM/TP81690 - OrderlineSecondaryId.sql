SELECT DISTINCT dol.OrderlineSecondaryId
FROM [DDS].[FactInventory] fi
INNER JOIN  [DDS].[DimOrderline_Inv] dol
	ON fi.Orderline_InvKey = dol.Orderline_InvKey
WHERE fi.MovieKey = 2439