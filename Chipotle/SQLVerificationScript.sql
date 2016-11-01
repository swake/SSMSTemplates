-- All missing data from FactEarningsWorkDay
SELECT h.DateID
	  ,h.EntityID
	  ,h.EmployeeID
	  ,h.ShiftNumber
	  ,h.JobCodeID
	  ,h.ClockInTime
	  ,h.ClockOutTime
	  ,h.TotalHours
	  ,h.EmployeeRate
	  ,h.LoadTS
	  ,tb.TimeBlockId
	  ,tb.LocationId
	  ,tb.TimeEntryCode
	  ,tb.ClockIn
	  ,tb.ClockOut
	  ,tb.CalculatedHours
	  ,tb.TimeCalculationCode
	  ,tb.CalculationTag
	  ,tb.Adjusted
	  ,tb.EarningsforTimeBlock
	  ,tb.IsReportedTime
	  ,tb.IsCalculatedTime
	  ,tb.IsDeleted
	  ,wde.WorkDayEarningID
	  ,wde.EarningID
	  ,s.PKStoreID
	  ,s.StoreCity
	  ,s.StoreState
	  ,s.CloseDate
	  ,jc.JobCode
	  ,jc.JobCodeGrouping
FROM FactHoursWorkDay h
LEFT JOIN FactEarningsWorkDay e 
	ON h.DateID = e.DateID 
	AND h.EmployeeID = e.EmployeeID 
	AND h.EntityID = e.EntityID 
	AND h.ShiftNumber = e.ShiftNumber
LEFT JOIN TimeBlocksCalculated tb
	ON h.EmployeeID = tb.EmployeeId
	AND h.DateID = CONVERT(INT, CONVERT(VARCHAR(10), CAST(tb.CalculatedDate AS DATE), 112))
LEFT JOIN Mapping.WorkDayEarning wde
	ON tb.CalculationTag = wde.Calculation_Tag
LEFT JOIN tblEntities en
	ON h.EntityID = en.PKEntityID
LEFT JOIN tblStores s
	ON h.EntityID = s.FKEntityID
LEFT JOIN DimJobCode jc
	ON h.JobCodeID = jc.JobCodeID
WHERE e.EmployeeID IS NULL

--All mising data from FactHoursWorkDay

select * from FactEarningsWorkDay e 
 left join facthoursworkday h on h.dateid = e.dateid and h.EmployeeID = e.EmployeeID and h.entityid = e.entityid and h.ShiftNumber = e.ShiftNumber
where h.EmployeeID is null