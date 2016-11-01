/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING OFF
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.TimeBlocksCalculated
	DROP CONSTRAINT DefTimeBlocksCalculated_LoadTS
GO
CREATE TABLE dbo.Tmp_TimeBlocksCalculated
	(
	EmployeeId int NULL,
	LocationId int NULL,
	TimeBlockId varchar(100) NOT NULL,
	TimeBlockDescr varchar(100) NULL,
	OriginatingTimeBlockId varchar(100) NULL,
	CalculatedDate datetime2(0) NULL,
	TimeEntryCode varchar(100) NULL,
	ClockIn datetime2(0) NULL,
	ClockOut datetime2(0) NULL,
	CalculatedHours decimal(9, 2) NULL,
	ReportedHours decimal(9, 2) NULL,
	TimeCalculationCode varchar(100) NULL,
	CalculationTag varchar(100) NULL,
	Adjusted char(1) NULL,
	EarningsforTimeBlock decimal(9, 2) NULL,
	EarningsAmountforTimeBlock decimal(9, 2) NULL,
	PayrollStatus varchar(100) NULL,
	IsReportedTime bit NULL,
	IsCalculatedTime bit NULL,
	IsDeleted bit NULL,
	DerivedLocationID int NULL,
	reprocessflg bit NULL,
	LoadTS smalldatetime NOT NULL
	)  ON Secondary
GO
ALTER TABLE dbo.Tmp_TimeBlocksCalculated SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_TimeBlocksCalculated ADD CONSTRAINT
	DF_TimeBlocksCalculated_IsDeleted DEFAULT 0 FOR IsDeleted
GO
ALTER TABLE dbo.Tmp_TimeBlocksCalculated ADD CONSTRAINT
	DefTimeBlocksCalculated_LoadTS DEFAULT (getdate()) FOR LoadTS
GO
IF EXISTS(SELECT * FROM dbo.TimeBlocksCalculated)
	 EXEC('INSERT INTO dbo.Tmp_TimeBlocksCalculated (EmployeeId, LocationId, TimeBlockId, TimeBlockDescr, OriginatingTimeBlockId, CalculatedDate, TimeEntryCode, ClockIn, ClockOut, CalculatedHours, ReportedHours, TimeCalculationCode, CalculationTag, Adjusted, EarningsforTimeBlock, EarningsAmountforTimeBlock, PayrollStatus, IsReportedTime, IsCalculatedTime, DerivedLocationID, reprocessflg, LoadTS)
		SELECT EmployeeId, LocationId, TimeBlockId, TimeBlockDescr, OriginatingTimeBlockId, CalculatedDate, TimeEntryCode, ClockIn, ClockOut, CalculatedHours, ReportedHours, TimeCalculationCode, CalculationTag, Adjusted, EarningsforTimeBlock, EarningsAmountforTimeBlock, PayrollStatus, IsReportedTime, IsCalculatedTime, DerivedLocationID, reprocessflg, LoadTS FROM dbo.TimeBlocksCalculated WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.TimeBlocksCalculated
GO
EXECUTE sp_rename N'dbo.Tmp_TimeBlocksCalculated', N'TimeBlocksCalculated', 'OBJECT' 
GO
CREATE UNIQUE NONCLUSTERED INDEX UIDX_ReprocessedFlg_TimeBlockID ON dbo.TimeBlocksCalculated
	(
	reprocessflg,
	TimeBlockId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON Secondary
GO
COMMIT