'''
Written by Stan Smoltis for Sydney Business Intelligence User Group
'''
from orangecontrib.associate.fpgrowth import frequent_itemsets, association_rules
from sklearn.preprocessing import MultiLabelBinarizer
import pandas
import pyodbc

suppParam =  0.1
confParam = 0.7

_conn = pyodbc.connect("DRIVER={SQL Server};SERVER=(local)\sql2017;Database=PythonDemo;Trusted_Connection=yes;")
_sql = "SELECT [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=20"
InputDataSet = pandas.read_sql_query(sql=_sql, con=_conn)

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

print(OutputDataSet)