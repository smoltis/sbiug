USE [master]
GO

CREATE DATABASE [PythonDemo]
GO

USE [PythonDemo]
GO

CREATE TABLE [dbo].[_03_RawDataFull](
	[StoreCode] [smallint] NULL,
	[StoreName] [varchar](15) NULL,
	[ProductCode] [int] NULL,
	[ItemSeqNo] [smallint] NULL,
	[UnitPrice] [real] NULL,
	[Quantity] [real] NULL,
	[SalesValue] [real] NULL,
	[Weighted] [bit] NULL,
	[TillNo] [smallint] NULL,
	[TransactionID] [int] NULL,
	[SalesDate] [datetime] NULL,
	[ProductDescription] [varchar](100) NULL,
	[DepartmentDescription] [varchar](100) NULL,
	[CategoryDescription] [varchar](100) NULL,
	[SubCategoryDescription] [varchar](100) NULL,
	[BasketID] [int] NULL
)
GO

CREATE VIEW [dbo].[vwClusteringData]
WITH SCHEMABINDING
AS
SELECT [StoreCode]
	  ,COUNT_BIG(DISTINCT BasketID) as BasketsCnt
      ,SUM(SalesValue) TotalSales
	  ,SUM(IIF(DATEPART(HH,[SalesDate]) IN (7,8),[SalesValue],0))/SUM(SalesValue) as SalesPCTHour7to9
	  ,SUM(IIF(DATEPART(HH,[SalesDate]) IN (9,10),[SalesValue],0))/SUM(SalesValue) as SalesPCTHour9to11
	  ,SUM(IIF(DATEPART(HH,[SalesDate]) IN (11,12),[SalesValue],0))/SUM(SalesValue) as SalesPCTHour11to13
	  ,SUM(IIF(DATEPART(HH,[SalesDate]) IN (13,14),[SalesValue],0))/SUM(SalesValue) as SalesPCTHour13to15
	  ,SUM(IIF(DATEPART(HH,[SalesDate]) IN (15,16),[SalesValue],0))/SUM(SalesValue) as SalesPCTHour15to17
	  ,SUM(cast(Weighted as int)) as TimesWeighted
	  ,SUM(IIF(DATEPART([DW],[SalesDate])=2,[SalesValue],0))/SUM(SalesValue) as PctSalesOnMon
	  ,SUM(IIF(DATEPART([DW],[SalesDate])=3,[SalesValue],0))/SUM(SalesValue) as PctSalesOnTue
	  ,SUM(IIF(DATEPART([DW],[SalesDate])=4,[SalesValue],0))/SUM(SalesValue) as PctSalesOnWed
	  ,SUM(IIF(DATEPART([DW],[SalesDate])=5,[SalesValue],0))/SUM(SalesValue) as PctSalesOnThu
	  ,SUM(IIF(DATEPART([DW],[SalesDate])=6,[SalesValue],0))/SUM(SalesValue) as PctSalesOnFri
	  ,SUM(IIF(DATEPART([DW],[SalesDate]) IN (1,7),[SalesValue],0))/SUM(SalesValue) as PctSalesOnWeekend
FROM [dbo].[_03_RawDataFull] r
GROUP BY [StoreCode]
GO

CREATE TABLE [dbo].[Stores](
	[StoreCode] [smallint] NULL,
	[StoreName] [varchar](15) NULL,
	[airport_min_dist] [int] NULL,
	[lat] [decimal](9, 6) NULL,
	[lon] [decimal](9, 6) NULL,
	[Tavghigh] [decimal](4, 2) NULL,
	[Tavglow] [decimal](4, 2) NULL,
	[AvgRainyDays] [int] NULL,
	[AvgSunnyDays] [int] NULL,
	[State] [nchar](10) NULL
)
GO

CREATE TABLE [dbo].[_01_TestData](
	[StoreCode] [smallint] NULL,
	[StoreName] [varchar](15) NULL,
	[ProductCode] [int] NULL,
	[ItemSeqNo] [smallint] NULL,
	[UnitPrice] [real] NULL,
	[Quantity] [real] NULL,
	[SalesValue] [real] NULL,
	[Weighted] [bit] NULL,
	[TillNo] [smallint] NULL,
	[TransactionID] [int] NULL,
	[SalesDate] [datetime] NULL
)
GO

CREATE TABLE [dbo].[_02_ProductReference](
	[ProductCode] [int] NULL,
	[ProductDescription] [varchar](100) NULL,
	[DepartmentDescription] [varchar](100) NULL,
	[CategoryDescription] [varchar](100) NULL,
	[SubCategoryDescription] [varchar](100) NULL
)
GO

CREATE TABLE [dbo].[CombinedSets](
	[StoreCode] [smallint] NULL,
	[BasketID] [int] NULL,
	[Departments] [nvarchar](max) NULL,
	[Category] [nvarchar](max) NULL,
	[SubCategory] [nvarchar](max) NULL
)
GO

CREATE PROCEDURE [dbo].[GetGeoCodeFromAddress]
(
	@Address varchar(1000) = NULL
)
AS
BEGIN

execute sp_execute_external_script 
@language = N'Python',
@script = N'
from urllib import parse, request
import json

googleGeocodeUrl = "http://maps.googleapis.com/maps/api/geocode/json?"

def get_coordinates(query, from_sensor=False):
	query = query.encode("utf-8")
	params = {
		"address": query,
		"sensor": "true" if from_sensor else "false"
	}
	url = googleGeocodeUrl + parse.urlencode(params)
	with request.urlopen(url) as json_response:
		response = json.loads(json_response.read().decode())
	if response["results"]:
		location = response["results"][0]["geometry"]["location"]
		latitude, longitude = location["lat"], location["lng"]
		print (query, latitude, longitude)
	else:
		latitude, longitude = None, None
		print (query, "<no results>")
	return query, latitude, longitude

result = get_coordinates(address)
OutputDataSet = pandas.DataFrame([result],columns=["address","lat","lon"])
', 
@params = N'@address varchar(1000)',
@address=@Address
with result sets (("address" varchar(1000),"lat" decimal(9,6) null, "lon" decimal(9,6) null))

END
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

END
GO

CREATE PROCEDURE [dbo].[MineAssociationRulesFIM]
(
	@SQLQuery nvarchar(max) = NULL,
	@Support int = 5,
	@Confidence int = 10
)
AS
BEGIN

IF(@SQLQuery IS NULL)
	SET @SQLQuery = FORMATMESSAGE(N'SELECT TOP (%d) [Departments] as [Transactions] FROM [dbo].[CombinedSets] WHERE StoreCode=20',10000);

execute sp_execute_external_script 
@language = N'Python',
@script = N'
import fim

rules = fim.arules(InputDataSet["Transactions"].str.split(",\s*"), supp=suppParam, conf=confParam, zmin=2, report="SCl")

OutputDataSet = pandas.DataFrame(rules,columns=["cons","ante","supp","conf", "lift"])
OutputDataSet["ante"]=OutputDataSet["ante"].apply(lambda col: ", ".join(col))
', 
@input_data_1 = @SQLQuery,
@params = N'@confParam int, @suppParam int',
@confParam=@Confidence,
@suppParam=@Support
with result sets (("cons" varchar(4000) null, "ante" varchar(4000) null, "supp" float null, "conf" float null, "lift" float null))
END
GO

CREATE PROCEDURE [dbo].[spRefreshStoreCoord]
AS
BEGIN

DECLARE @temp TABLE(StoreName varchar(50) null, lat decimal(9,6) null, lon decimal(9,6) null)

DECLARE store_coord_cur CURSOR
READ_ONLY
FOR SELECT [StoreName] FROM [dbo].[Stores]

DECLARE @name varchar(40)
OPEN store_coord_cur

FETCH NEXT FROM store_coord_cur INTO @name
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		INSERT @temp
		EXEC [dbo].[GetGeoCodeFromAddress] @name
	END
	FETCH NEXT FROM store_coord_cur INTO @name
END

CLOSE store_coord_cur
DEALLOCATE store_coord_cur

UPDATE s
SET lat = t.lat, lon = t.lon
FROM [dbo].[Stores] s
JOIN @temp t ON s.StoreName=t.StoreName
	
END
GO
