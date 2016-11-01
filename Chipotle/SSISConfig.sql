USE [SSISConfig]
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[InitialCatalog]'
           ,'String'
           ,'FinanceDataMart'
           ,1
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[InitialCatalog]'
           ,'String'
           ,'FinanceDataMart'
           ,2
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[InitialCatalog]'
           ,'String'
           ,'FinanceDataMart'
           ,3
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[Password]'
           ,'String'
           ,'Admin69'
           ,1
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[Password]'
           ,'String'
           ,'Admin69'
           ,2
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[Password]'
           ,'String'
           ,'Admin69'
           ,3
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[ServerName]'
           ,'String'
           ,'CMGVSQLPRD01'
           ,1
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[ServerName]'
           ,'String'
           ,'D03SQLDEV10'
           ,2
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[ServerName]'
           ,'String'
           ,'D03SQLDEV10'
           ,3
           ,SYSTEM_USER
           ,GETDATE())
GO

INSERT INTO [dbo].[SSIS_Config_base]
           ([ConfigurationFilter]
           ,[PackagePath]
           ,[ConfiguredValueType]
           ,[ConfiguredValue]
           ,[EnvironmentEnum]
           ,[ModifiedBy]
           ,[ModifiedOn])
     VALUES
           ('POSSalesStoreOpenDateChanges'
           ,'\Package.Connections[FinanceDataMart-OLEDB].Properties[UserName]'
           ,'String'
           ,'SSISETL'
           ,0
           ,SYSTEM_USER
           ,GETDATE())
GO