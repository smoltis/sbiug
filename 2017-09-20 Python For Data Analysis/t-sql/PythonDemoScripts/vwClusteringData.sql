
CREATE VIEW dbo.vwClusteringData
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