USE [FinanceDataMart]
GO

SELECT fhwd.[DateID]
      ,fhwd.[EntityID]
      ,fhwd.[EmployeeID]
      ,fhwd.[ShiftNumber]
      ,fhwd.[JobCodeID]
      ,fhwd.[ClockInTime]
      ,fhwd.[ClockOutTime]
      ,fhwd.[TotalHours]
      ,fhwd.[EmployeeRate]
	  ,fe.JOBCODE
	  ,djc.JobCode
FROM [FinanceDataMart].[dbo].[FactHoursWorkdayReported] fhwd
JOIN [FinanceDataMart].[dbo].[vwDimDate] vdd
	ON fhwd.DateID = vdd.DateID
JOIN [HR].[dbo].[factEmployee] fe
	ON fhwd.EmployeeID = fe.EMPLID
	AND vdd.[Date] = fe.DT
LEFT OUTER JOIN [FinanceDataMart].[dbo].[DimJobCode] djc
	ON fe.JOBCODE = djc.JobCode
WHERE fhwd.JobCodeID = 1
	AND fe.JOBCODE <> 'RC500'
ORDER BY fe.JOBCODE


DELETE [dbo].[FactHoursWorkdayReported]
FROM [dbo].[FactHoursWorkdayReported] fhwd
JOIN [FinanceDataMart].[dbo].[vwDimDate] vdd
	ON fhwd.DateID = vdd.DateID
JOIN [HR].[dbo].[factEmployee] fe
	ON fhwd.EmployeeID = fe.EMPLID
	AND vdd.[Date] = fe.DT
LEFT OUTER JOIN [FinanceDataMart].[dbo].[DimJobCode] djc
	ON fe.JOBCODE = djc.JobCode
WHERE fhwd.EmployeeRate IS NULL
	AND fhwd.JobCodeID = 1