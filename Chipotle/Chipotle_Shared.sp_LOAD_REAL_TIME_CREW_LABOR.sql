USE Chipotle_Shared
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_LOAD_REAL_TIME_CREW_LABOR]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_LOAD_REAL_TIME_CREW_LABOR]
GO

CREATE PROCEDURE sp_LOAD_REAL_TIME_CREW_LABOR AS

DECLARE @CUR_PERIOD CHAR(6)
DECLARE @PREV_PERIOD CHAR(6)
DECLARE @DATEBEG DATETIME
DECLARE @DATEEND DATETIME

SELECT @CUR_PERIOD = CurrentPeriod, @PREV_PERIOD = PreviousPeriod, @DATEBEG = FirstDateOfMonth, @DATEEND = LastDayOfMonth  
from dbo.tblRealTimeProcessConstants

TRUNCATE TABLE dbo.tblRealTimePnLDetail_Load


INSERT INTO dbo.tblRealTimePnLDetail_Load ( 
      [SourceId]
      ,[SourceDocId]
      ,[CostCenter]
      ,[Account]
      ,[Department]
      ,[VendorName]
      ,[Description]
      ,[Amount]
      ,[EffectiveDate]
      ,[InvoiceNumber]
      ,[Period])
       select  5 as SourceID
                     ,NULL SourceDocID
                     ,s.PKStoreID as CostCenter
                     ,5502 as Account
                     ,'000' as Department
                     ,'Crew Labor' as VendorName
                     ,'Crew Labor -'  + CONVERT(CHAR(10),t.Date, 101) as Description
                     ,SUM(TotalEarnings) as Amount
                     ,CONVERT(CHAR(10),t.Date, 101) as EffectiveDAte
                     ,'Crew Labor'  as InvoiceNumber
                     ,T.Period 
 FROM FinanceDataMart.dbo.vwFactEarnings fe
INNER JOIN FinanceDataMart.dbo.tblStores s 
       ON s.FKEntityID = fe.EntityID
INNER JOIN FinanceDataMart.dbo.DimJobCode jc
       ON jc.JobCodeID = fe.JobCodeID
INNER JOIN FinanceDataMart.dbo.tblTime t
       ON t.dateID = fe.DateID
WHERE jc.EmployeeCategory = 'Crew'
       AND t.date BETWEEN @DATEBEG AND @DATEEND
GROUP BY s.PKStoreID
                     ,CONVERT(CHAR(10),t.Date, 101)
                     ,t.Period 


DELETE FROM dbo.tblRealTimePnLDetail
WHERE SourceId = 5
AND Period = @CUR_PERIOD


INSERT INTO dbo.tblRealTimePnLDetail ( 
      [SourceId]
      ,[SourceDocId]
      ,[CostCenter]
      ,[Account]
      ,[Department]
      ,[VendorName]
      ,[Description]
      ,[Amount]
      ,[EffectiveDate]
      ,[InvoiceNumber]
      ,[Period])

SELECT SourceId, SourceDocId, CostCenter, Account, Department, 
VendorName, Description, Amount, EffectiveDate, InvoiceNumber, Period 
FROM dbo.tblRealTimePnLDetail_Load