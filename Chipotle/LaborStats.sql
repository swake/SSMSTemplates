DECLARE @yesterday DATE
       ,@yesterdayINT INT
       ,@dateCounter DATE 
	   ,@dayCount INT
       ,@startDateINT INT
       ,@startDateINT2 INT
 
SET @yesterday = DATEADD(dd,-1,GETDATE())
 
--SELECT @StartDateINT = DateID
--      ,@dateCounter = [Date]
--FROM dbo.tblTime 
--WHERE DATE = DATEADD(dd,-17,CAST(GETDATE() AS DATE))

SELECT @startDateINT = DateID
      ,@dateCounter = [Date]
FROM dbo.tblTime 
WHERE DATE = '2014-12-29'

SELECT @yesterdayINT = DateID
FROM dbo.tblTime 
WHERE DATE = @yesterday
 
--SET @startDateINT2 = (SELECT DateID FROM dbo.tblTime WHERE [Date] = DATEADD(dd,-17,CAST(GETDATE() AS DATE)))
SET @startDateINT2 = (SELECT DateID FROM dbo.tblTime WHERE [Date] = '2014-12-29')

SET @dayCount = DATEDIFF(dd,@dateCounter,@yesterday)
 
EXEC dbo.stpLaborMatrixDailyParams
EXEC dbo.stpDlyLaborMatrixCalc
EXEC dbo.stpStatCalcDriver  9,NULL,@yesterday,@dayCount
 
WHILE @startDateINT <=  @yesterdayINT 
	BEGIN 
		EXEC dbo.StpStatDaily72ActualStaffing  @startDateINT, @startDateINT, 72
		EXEC dbo.StpStatDaily73RecommendedStaffing  @startDateINT, @startDateINT, 73
 
		SELECT @dateCounter = DATEADD(dd,1,@dateCounter)
		SELECT @startDateINT = dateID FROM tbltime WHERE [Date] = @dateCounter
	END
 
EXEC dbo.StpStatDaily82VartoMinStaff @startDateINT2, @yesterdayINT, 82
EXEC dbo.StpStatDaily83VartoMinStaffAgg @startDateINT2, @yesterdayINT, 83

EXEC dbo.stpTblDailyMeasureDataLoad
EXEC dbo.stptblDashboardDailyDataLoad
EXEC dbo.stp_UpdateDashboardAlerts
EXEC dbo.stpDashBoardSalesAndLaborProcessing

Declare @StartDateID int
Declare @EndDAteID int
Declare @CurrentDateID int

SET @StartDateID = 20150101
SET @EndDateID = 20150131
SET @CurrentDateID = @StartDateID

IF OBJECT_ID('tempdb..#loop') IS NOT NULL
	DROP TABLE #loop

CREATE TABLE #loop (ID int identity (1,1), 
 DateID INT) 

INSERT INTO #loop (dateid)
	select dateid
	from tbltime
	where dateid between @StartDateID and @EndDateID
	order by 1 asc
WHILE @CurrentDateID <= @EndDateID

BEGIN
	PRINT @CurrentDateID

	exec stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 85
	exec stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 86
	exec stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 87
	exec stpStatDailyAtModelCounts85to88 @CurrentDateID, @CurrentDateID, 88
	exec stpStatDailyAtModel89to99 @CurrentDateID, @CurrentDateID

	SET @CurrentDateID = @CurrentDateID + 1 
END
