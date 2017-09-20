USE PythonDemo
GO

DECLARE @t TABLE (cons varchar(4000) null, ante varchar(4000) null, supp float null, conf float null, lift float null)
INSERT @t
exec [dbo].[MineAssociationRulesFIM]
SELECT * from @t order by lift desc
GO

/*
EXEC MineAssociationRulesFIM N'SELECT [Departments] as [Transactions] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.3,0.9
GO
EXEC MineAssociationRulesFIM N'SELECT [Category] as [Transactions] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.3,0.9
GO
EXEC MineAssociationRulesFIM N'SELECT [SubCategory] as [Transactions] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.3,0.9
GO
*/