USE PythonDemo
GO

DECLARE @tmp TABLE 
	(Antecedent varchar(100) 
	,Consecutive varchar(100)
	,SupportAbs int
	,Confidence decimal(5,3)
	,SupportPCT decimal(5,3))

INSERT @tmp
EXEC [dbo].[MineAssociationRules]

SELECT TOP(10) * FROM @tmp