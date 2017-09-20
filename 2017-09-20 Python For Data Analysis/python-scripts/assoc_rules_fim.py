'''
Written by Stan Smoltis for Sydney Business Intelligence User Group
'''
from fim import arules
import pandas
import pyodbc

suppParam =  0.1
confParam = 0.7

_conn = pyodbc.connect("DRIVER={SQL Server};SERVER=(local)\sql2017;Database=PythonDemo;Trusted_Connection=yes;")
_sql = "SELECT [Departments] as [Values] FROM [dbo].[CombinedSets] WHERE StoreCode=20"
InputDataSet = pandas.read_sql_query(sql=_sql, con=_conn)

rules = arules(InputDataSet["Values"].str.split(",\s*"), supp=suppParam, conf=confParam, zmin=2, report="SCl")

OutputDataSet = pandas.DataFrame(rules,columns=["cons","ante","supp","conf", "lift"])
OutputDataSet["ante"]=OutputDataSet["ante"].apply(lambda col: ", ".join(col))
print(len(OutputDataSet))
print(OutputDataSet)