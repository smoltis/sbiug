USE [PythonDemo]
GO

IF OBJECT_ID('MineAssociationRules') IS NOT NULL DROP PROCEDURE MineAssociationRules
GO

CREATE PROCEDURE [dbo].[MineAssociationRules]
(
	@SQLQuery nvarchar(max) = NULL,
	@Support float = 0.1,
	@Confidence float = 0.8
)
AS
BEGIN

IF(@SQLQuery IS NULL)
	SET @SQLQuery = FORMATMESSAGE(N'SELECT TOP (%d) [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=20',10000);

execute sp_execute_external_script 
@language = N'Python',
@script = N'
from orangecontrib.associate.fpgrowth import frequent_itemsets, association_rules
from sklearn.preprocessing import MultiLabelBinarizer

mlb = MultiLabelBinarizer(sparse_output=True)
X = mlb.fit_transform(InputDataSet["Values"].str.split(",\s*")) > 0
classes = mlb.classes_

itemsets = dict(frequent_itemsets(X, suppParam))

rules = [[", ".join(classes[i] for i in P), classes[next(iter(Q))], supp, conf]
         for P, Q, supp, conf in association_rules(itemsets, confParam)]

OutputDataSet = pandas.DataFrame(rules,columns=["ante","cons","supp","conf"])
rows = len(InputDataSet)
OutputDataSet["suppPCT"] = pandas.Series([(i/rows) for i in OutputDataSet["supp"]], dtype = "float")
OutputDataSet.sort_values(["conf"],ascending=False)
', 
@input_data_1 = @SQLQuery,
@params = N'@confParam float, @suppParam float',
@confParam=@Confidence,
@suppParam=@Support
with result sets (("ante" varchar(4000) null, "cons" varchar(4000) null, "supp" float null, "conf" float null, "suppPCT" float null))
END
GO

EXEC MineAssociationRules N'SELECT [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.7
GO
EXEC MineAssociationRules N'SELECT [Category] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.1
GO
EXEC MineAssociationRules N'SELECT [SubCategory] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=47',0.1,0.7
GO
