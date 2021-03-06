--Set basketIDs
;WITH basket_rollup as
(
SELECT DENSE_RANK() OVER (ORDER BY [StoreCode],[TillNo],[TransactionID],[SalesDate]) as id, BasketID
FROM [dbo].[_03_RawDataFull]
)
UPDATE basket_rollup
SET BasketID=id

--By Dep
;WITH Baskets as (
SELECT DISTINCT [StoreCode],BasketID
FROM [dbo].[_03_RawDataFull]
),
Departments as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [DepartmentDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as Departments
FROM Baskets b
)
SELECT * 
INTO DepartmentSets
FROM Departments

--By Category
;WITH Baskets as (
SELECT DISTINCT [StoreCode],BasketID
FROM [dbo].[_03_RawDataFull]
),
Categories as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [CategoryDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as Category
FROM Baskets b
)
SELECT * 
INTO CategorySets
FROM Categories

--By Subcategory
;WITH Baskets as (
SELECT DISTINCT [StoreCode],BasketID
FROM [dbo].[_03_RawDataFull]
),
Categories as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [SubCategoryDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as Category
FROM Baskets b
)
SELECT * 
INTO SubCategorySets
FROM Categories



--Everything
;WITH Baskets as (
SELECT DISTINCT [StoreCode],BasketID
FROM [dbo].[_03_RawDataFull]
),
Departments as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [DepartmentDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as Departments
FROM Baskets b
),
Categories as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [CategoryDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as Category
FROM Baskets b
),
SubCategories as(
SELECT [StoreCode],BasketID,
(SELECT STUFF((
    SELECT DISTINCT ',' + [SubCategoryDescription]
    FROM [dbo].[_03_RawDataFull]
	WHERE BasketID=b.BasketID
    ORDER BY 1
	FOR XML PATH('')
), 1, 1, '')) as SubCategory
FROM Baskets b
)

SELECT b.*,d.Departments,c.Category,sc.SubCategory 
INTO CombinedSets
FROM Baskets b 
JOIN Departments d ON b.[StoreCode]=d.[StoreCode] AND b.BasketID=d.BasketID
JOIN Categories c ON b.[StoreCode]=c.[StoreCode] AND b.BasketID=c.BasketID
JOIN SubCategories sc ON sc.[StoreCode]=d.[StoreCode] AND b.BasketID=sc.BasketID

