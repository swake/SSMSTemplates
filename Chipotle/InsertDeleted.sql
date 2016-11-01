USE [FinanceDataMartDev]
GO

INSERT INTO [dbo].[TimeBlocksCalculated]
(
TimeBlockId
,TimeBlockDescr
,EmployeeId
,CalculatedDate
,IsCalculatedTime
,IsReportedTime
,ClockIn
,ClockOut
,LoadTS
)
SELECT
TimeBlockId
,TimeBlockDescr
,EmployeeId
,CalculatedDate
,CalculatedFlg
,ReportedFlg
,ClockIn
,ClockOut
,LoadTS
FROM dbo.TimeBlocksDeleted

GO


