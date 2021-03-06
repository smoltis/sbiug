USE PythonDemo
GO

SELECT TOP (100) * FROM [PythonDemo].[dbo].[_01_TestData]
GO
SELECT TOP (100) * FROM [dbo].[_02_ProductReference]
GO

--join and add BasketID column
SELECT TOP (100) * FROM [dbo].[_03_RawDataFull]
GO

--comma separated list of unique departments, categories and sub-categories per basket
SELECT TOP (100) * FROM [PythonDemo].[dbo].[CombinedSets]
GO

--stores
SELECT [StoreCode],[StoreName] FROM dbo.Stores
GO