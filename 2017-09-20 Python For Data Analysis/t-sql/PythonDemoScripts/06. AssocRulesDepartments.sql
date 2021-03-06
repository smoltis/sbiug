USE PythonDemo
GO


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
@input_data_1 = 'SELECT TOP (10000) [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=20',
@params = N'@confParam float, @suppParam float',
@confParam=@Confidence,
@suppParam=@Support
with result sets (("ante" varchar(4000) null, "cons" varchar(4000) null, "supp" float null, "conf" float null, "suppPCT" float null))

--#list(rules_stats(rules, itemsets, 10)) #
--#    Yields
--#    ------
--#    atecedent: frozenset
--#        The LHS of the association rule.
--#    consequent: frozenset
--#        The RHS of the association rule.
--#    support: int
--#        Support as an absolute number of instances.
--#    confidence: float
--#        The confidence percent, calculated as: ``total_support / lhs_support``.
--#    coverage: float
--#        Calculated as: ``lhs_support / n_examples``
--#    strength: float
--#        Calculated as: ``rhs_support / lhs_examples``
--#    lift: float
--#        Calculated as: ``n_examples * total_support / lhs_support / rhs_support``
--#    leverage: float
--#        Calculated as: ``(total_support * n_examples - lhs_support * rhs_support) / n_examples**2``


GO
