USE PythonDemo
GO
  select s.StoreCode,s.StoreName, count(*) TotalBaksets 
  from [dbo].[CombinedSets] cs
  JOIN [dbo].[Stores] s ON cs.StoreCode=s.StoreCode
  GROUP BY s.StoreCode,s.StoreName
  ORDER BY 3 DESC
GO

DECLARE @StoreCode int = 47
SELECT StoreName, COUNT(*) as TotalBaskets FROM [dbo].[CombinedSets] cs
JOIN dbo.Stores s ON cs.StoreCode=s.StoreCode
WHERE cs.StoreCode=@StoreCode
GROUP BY StoreName
GO

EXEC MineAssociationRules N'SELECT [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.7
GO
EXEC MineAssociationRules N'SELECT [Category] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.1
GO
EXEC MineAssociationRules N'SELECT [SubCategory] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.7
GO