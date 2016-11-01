USE [FinanceDataMart]
GO

DELETE FROM [dbo].[tblEntityHierarchy]
      WHERE FKEntityID IN (73590
,73591
,73592
,73697
,90432
,90433
,90434
,90435
,90436
,90437
,90438
,90439
,90440
,90441
,90442
,90443
,90444)
GO

USE [HR]
GO

UPDATE [dbo].[factEmployee]
   SET [JOBCODE] = 'FIN218'
 WHERE JOBCODE = 'FIN219'
GO

UPDATE [dbo].[factEmployee]
   SET [JOBCODE] = 'FIN904'
 WHERE JOBCODE = 'FIN905'
GO

USE [FinanceDataMart]
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID])
     VALUES
           (73697
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
           ,9999
           ,10000
           ,20018)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90432
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90432'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90433
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90433'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90434
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90434'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90434
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90434'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90435
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90435'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90436
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90436'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90437
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90437'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90438
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90438'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90439
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90439'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90440
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90440'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90441
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90441'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90442
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90442'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90443
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90443'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (90444
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Chipotle SoCen Central/SE USD New Stores Patch'
		   ,'2016 CMG USD South Central Central/SE - 90444'
           ,9999
           ,10000
           ,20018
		   ,60218)
GO


INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel4]
		   ,[EntityLevel5]
		   ,[EntityLevel6]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel4ID]
		   ,[FKEntityLevel5ID]
		   ,[FKEntityLevel6ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (73590
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Ohio River Valley'
		   ,'Ohio River Valley'
		   ,'Indianapolis'
		   ,'Indy Open Patch'
		   ,'Lima Road - 2691'
           ,9999
           ,10000
           ,20018
		   ,30031
		   ,30031
		   ,50035
		   ,60009)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel4]
		   ,[EntityLevel5]
		   ,[EntityLevel6]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel4ID]
		   ,[FKEntityLevel5ID]
		   ,[FKEntityLevel6ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (73591
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Ohio River Valley'
		   ,'Ohio River Valley'
		   ,'Indianapolis'
		   ,'Indy Open Patch'
		   ,'Lima Road - 2691'
           ,9999
           ,10000
           ,20018
		   ,30031
		   ,30031
		   ,50035
		   ,60009)
GO

INSERT INTO [dbo].[tblEntityHierarchy]
           ([FKEntityID]
           ,[EntityLevel1]
           ,[EntityLevel2]
           ,[EntityLevel3]
		   ,[EntityLevel4]
		   ,[EntityLevel5]
		   ,[EntityLevel6]
		   ,[EntityLevel7]
		   ,[EntityLevel8]
           ,[FKEntityLevel1ID]
           ,[FKEntityLevel2ID]
           ,[FKEntityLevel3ID]
		   ,[FKEntityLevel4ID]
		   ,[FKEntityLevel5ID]
		   ,[FKEntityLevel6ID]
		   ,[FKEntityLevel7ID])
     VALUES
           (73592
           ,'Chipotle'
           ,'US Operations'
           ,'South Central'
		   ,'Ohio River Valley'
		   ,'Ohio River Valley'
		   ,'Indianapolis'
		   ,'Indy Open Patch'
		   ,'Lima Road - 2691'
           ,9999
           ,10000
           ,20018
		   ,30031
		   ,30031
		   ,50035
		   ,60009)
GO