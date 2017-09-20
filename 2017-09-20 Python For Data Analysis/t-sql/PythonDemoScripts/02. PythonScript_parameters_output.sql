USE PythonDemo
GO

EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT 1 AS col'
--WITH RESULT SETS ((Col1 AS int))
GO
EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT 1 AS col'
WITH RESULT SETS ((MyColumnName int))
GO