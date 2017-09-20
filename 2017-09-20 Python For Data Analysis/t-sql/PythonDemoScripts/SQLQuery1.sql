USE [PythonDemo]
GO

ALTER PROCEDURE [dbo].[MineAssociationRulesFIM]
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

rules = fim.arules(InputDataSet["Transactions"].str.split(",\s*"), supp=suppParam, conf=confParam, zmin=2, report="(SCl)")

OutputDataSet = pandas.DataFrame(rules,columns=["cons","ante","supp","conf", "lift"])
OutputDataSet["ante"]=OutputDataSet["ante"].apply(lambda col: ", ".join(col))
OutputDataSet.sort_values(["lift"],ascending=False)
', 
@input_data_1 = @SQLQuery,
@params = N'@confParam int, @suppParam int',
@confParam=@Confidence,
@suppParam=@Support
with result sets (("cons" varchar(4000) null, "ante" varchar(4000) null, "supp" float null, "conf" float null, "lift" float null))
END
GO

exec [MineAssociationRulesFIM]