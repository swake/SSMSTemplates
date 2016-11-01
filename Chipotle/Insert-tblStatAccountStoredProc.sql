USE [FinanceDataMart]
GO

DECLARE @StatAccountCalcIDs TABLE (PKStatAccountCalcID INT,
									StatIdentifier INT)

INSERT INTO [dbo].[tblStatAccountStoredProc]
           ([StatIdentifier]
           ,[StatProcName]
           ,[FKDataVersionID]
           ,[FKStatTypeID]
           ,[DVType]
           ,[FKStatProcessTypeID])
	OUTPUT INSERTED.PKStatAccountCalcID, 9 INTO @StatAccountCalcIDs
    VALUES
           (9
           ,'StpStatDaily9MatrixHours'
           ,NULL
           ,2
           ,NULL
           ,NULL)

INSERT INTO [dbo].[tblStatAccountStoredProc]
           ([StatIdentifier]
           ,[StatProcName]
           ,[FKDataVersionID]
           ,[FKStatTypeID]
           ,[DVType]
           ,[FKStatProcessTypeID])
	OUTPUT INSERTED.PKStatAccountCalcID, 13 INTO @StatAccountCalcIDs
    VALUES
           (13
           ,'StpStatDaily13MPI'
           ,NULL
           ,2
           ,NULL
           ,NULL)

INSERT INTO [dbo].[tblStatAccountStoredProc]
           ([StatIdentifier]
           ,[StatProcName]
           ,[FKDataVersionID]
           ,[FKStatTypeID]
           ,[DVType]
           ,[FKStatProcessTypeID])
	OUTPUT INSERTED.PKStatAccountCalcID, 54 INTO @StatAccountCalcIDs
    VALUES
           (54
           ,'StpStatDaily54Terms90Day'
           ,NULL
           ,2
           ,NULL
           ,NULL)

INSERT INTO [dbo].[tblStatAccountIndex]
           ([FKStatAccountCalcID]
           ,[FKGroupID]
           ,[RunOrder])
     VALUES
           ((SELECT PKStatAccountCalcID FROM @StatAccountCalcIDs WHERE StatIdentifier = 9)
           ,6
           ,3)

INSERT INTO [dbo].[tblStatAccountIndex]
           ([FKStatAccountCalcID]
           ,[FKGroupID]
           ,[RunOrder])
     VALUES
           ((SELECT PKStatAccountCalcID FROM @StatAccountCalcIDs WHERE StatIdentifier = 13)
           ,6
           ,4)

INSERT INTO [dbo].[tblStatAccountIndex]
           ([FKStatAccountCalcID]
           ,[FKGroupID]
           ,[RunOrder])
     VALUES
           ((SELECT PKStatAccountCalcID FROM @StatAccountCalcIDs WHERE StatIdentifier = 54)
           ,1
           ,7)