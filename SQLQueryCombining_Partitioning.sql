
-- set operators for performing operations using the sets that result from two or more different queries.
--Set operators allow you to combine, compare, or operate on result sets.


/*
UNION is different from JOIN. JOIN compares columns from two tables, to create a result set containing rows
from two tables. UNION concatenates two result sets together: all the rows in the first result set are appended
to the rows in the second result set.


*/
--Union:
--With UNION or UNION ALL, both queries must have the same number of columns, and
--the columns must be of the same data type, allowing you to join rows from different queries.

SELECT customerid, companyname, FirstName + ' ' + LastName AS 'Name'
FROM saleslt.Customer
WHERE customerid BETWEEN 1 AND 9
UNION
SELECT customerid, companyname, FirstName + ' ' + LastName AS 'Name'
FROM saleslt.Customer
WHERE customerid BETWEEN 10 AND 19;

--INtersect

SELECT color FROM SalesLT.Product
WHERE ProductID BETWEEN 500 and 750
INTERSECT
SELECT color FROM SalesLT.Product
WHERE ProductID BETWEEN 751 and 1000;

--except

SELECT color FROM SalesLT.Product
WHERE ProductID BETWEEN 500 and 750
EXCEPT
SELECT color FROM SalesLT.Product
WHERE ProductID BETWEEN 751 and 1000;

--APPLY is actually a table operator, not a set operator, and is part of the FROM clause. 
--APPLY is more like a JOIN, rather than as a set operator that operates on two compatible result sets of queries.

-- APPLY returns a table-valued result rather than a scalar or multi-valued result.

SELECT oh.SalesOrderID, oh.OrderDate,
od.ProductID, od.UnitPrice, od.Orderqty 
FROM SalesLT.SalesOrderHeader AS oh 
CROSS APPLY (SELECT productid, unitprice, Orderqty 
        FROM SalesLT.SalesOrderDetail AS od 
        WHERE oh.SalesOrderID = SalesOrderID
              ) AS od;


--						---------- Window Functions ------------

--https://learn.microsoft.com/en-us/training/modules/write-queries-that-use-window-functions/3-use-over-clause

--SQL windowing operations allow you to define a subset of rows from a result set and apply functions
--against those rows.

-- Window functions allow you to perform calculations such as ranking, aggregations, and offset 
--comparisons between rows.

--Window functions require a set of rows to work on, known as a window. The OVER clause is used to define the 
--window you want to work on. You can then use a window function on the subset of rows you have defined.

--Dividing a result set into different parts and applying a window function to each.

-- You can use the OVER clause with functions to compute aggregated values such as moving averages, 
--cumulative aggregates, running totals, or a top N per group results.


--The ROWS clause limits the rows within a partition by specifying a fixed number of rows preceding or following the current row.

--the RANGE clause logically limits the rows within a partition by specifying a range of values with respect 
--to the value in the current row.

-- CURRENT ROW: Specifies that the window starts or ends at the current row when used with ROWS or the current value when
--used with RANGE. CURRENT ROW can be specified as both a starting and ending point.

/*
-Aggregate functions. Such as SUM, AVG, and COUNT which operate on a window and return a scalar value.

Aggregate functions return totals, averages, or counts of things. Aggregate functions perform a calculation and return a single value. 

*/

SELECT Name, ProductNumber, Color, SUM(Weight) 
OVER(PARTITION BY Color) AS WeightByColor
FROM SalesLT.Product
ORDER BY ProductNumber;

/*

-Ranking functions. Such as RANK, ROW_NUMBER, and NTILE. Ranking functions require a sort order and return
a ranking value for each row in a partition.

Ranking functions assign a number to each row, depending on its position within an order you have specified. 
The order is specified using the ORDER BY clause.
*/
SELECT productid, name, listprice 
    ,ROW_NUMBER() OVER (ORDER BY productid) AS "Row Number"  
    ,RANK() OVER (ORDER BY listprice) AS PriceRank  
    ,DENSE_RANK() OVER (ORDER BY listprice) AS "Dense Rank"  
    ,NTILE(4) OVER (ORDER BY listprice) AS Quartile  
FROM SalesLT.Product

/*
-Analytic functions. Such as CUME_DIST, PERCENTILE_CONT, or PERCENTILE_DISC. Analytic functions calculate the
distribution of values in the partition.

Analytic functions calculate a value based on a group of rows. Analytic functions are used to calculate moving averages, 
running totals, and top-N results. These functions include:

*/



/*
-Offset functions. Such as LAG, LEAD, and LAST_VALUE. Offset functions return values from other rows relative to the position of the current row.
Offset functions allow you to return a value subsequent or previous rows within a result set.

*/
SELECT [Year], Budget, LEAD(Budget, 1, 0) OVER (ORDER BY [Year]) AS 'Next'
    FROM dbo.Budget
    ORDER BY [Year];


--Exercises:

WITH sales AS
(
    SELECT C.Name AS 'Category', CAST(SUM(D.LineTotal) AS numeric(12, 2)) AS 'SalesValue'
    FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS C
        ON P.ProductCategoryID = C.ProductCategoryID
    WHERE C.ParentProductCategoryID = 4
        GROUP BY C.Name
)
SELECT Category, SalesValue, RANK() OVER(ORDER BY SalesValue DESC) AS 'Rank'
FROM sales
    ORDER BY Category;

go

SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', COUNT(SC.Name) OVER (PARTITION BY C.Name) AS 'SubcatCount'
FROM SalesLT.SalesOrderDetail AS D
INNER JOIN SalesLT.Product AS P
    ON D.ProductID = P.ProductID
INNER JOIN SalesLT.ProductCategory AS SC
    ON P.ProductCategoryID = SC.ProductCategoryID
INNER JOIN SalesLT.ProductCategory AS C
    ON SC.ParentProductCategoryID = C.ProductCategoryID
    GROUP BY C.Name, SC.Name
    ORDER BY C.Name, SC.Name;

go


--ex:1

WITH sales AS
(
    SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', CAST(SUM(D.LineTotal) AS numeric(12, 2)) AS 'SalesValue'
    FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS SC
        ON P.ProductCategoryID = SC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory AS C
        ON SC.ParentProductCategoryID = C.ProductCategoryID
        GROUP BY C.Name, SC.Name
)
SELECT Category, Subcategory, SalesValue, RANK() OVER(PARTITION BY Category ORDER BY SalesValue DESC) AS 'Rank'
FROM sales
    ORDER BY Category, SalesValue DESC;

--ex:2

SELECT [Year], Budget, LEAD(Budget, 1, 0) OVER (ORDER BY [Year]) AS 'Next'
FROM dbo.Budget
    ORDER BY [Year];

--ex:3
SELECT [Year], Budget,
        FIRST_VALUE(Budget) OVER (ORDER BY [Year]) AS 'First_Value',
        LAST_VALUE(Budget) OVER (ORDER BY [Year] ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS 'Last_Value'
FROM dbo.Budget
    ORDER BY [Year];

--ex:4
SELECT C.Name AS 'Category', SC.Name AS 'Subcategory', COUNT(P.Name) OVER (PARTITION BY C.Name) AS 'ProductCount'
FROM SalesLT.SalesOrderDetail AS D
    INNER JOIN SalesLT.Product AS P
        ON D.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory AS SC
        ON P.ProductCategoryID = SC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory AS C
        ON SC.ParentProductCategoryID = C.ProductCategoryID
    GROUP BY C.Name, SC.Name, P.Name
    ORDER BY C.Name, SC.Name, P.Name;


--					----------Pivoting -------------

--pivot
SELECT  Category, [2019],[2020],[2021]
FROM  ( SELECT  Category, Qty, Orderyear FROM Sales.CategoryQtyYear) AS D 
          PIVOT(SUM(qty) FOR orderyear IN ([2019],[2020],[2021])) AS pvt;

--unpivot
SELECT category, qty, orderyear
FROM Sales.PivotedCategorySales
UNPIVOT(qty FOR orderyear IN([2019],[2020],[2021])) AS unpvt;


--					------------	Grouping ----------

--if you need to group by different attributes at the same time, for example to report at different levels,
--you would normally need multiple queries combined with UNION ALL. 

--you can use the GROUPING SETS subclause of the GROUP BY clause in Transact-SQL. GROUPING SETS provides
--an alternative to using UNION ALL to combine results from multiple individual queries, each with its own GROUP BY clause.

SELECT Category, Cust, SUM(Qty) AS TotalQty
FROM Sales.CategorySales
GROUP BY 
    GROUPING SETS((Category),(Cust),())
ORDER BY Category, Cust;

/*
CUBE will determine all possible combinations and output groupings. ROLLUP creates combinations,
assuming the input columns represent a hierarchy. 
Therefore, CUBE and ROLLUP can be thought of as shortcuts to GROUPING SETS.
*/

SELECT Category, Cust, SUM(Qty) AS TotalQty
FROM Sales.CategorySales
GROUP BY CUBE(Category,Cust);

SELECT Category, Subcategory, Product, SUM(Qty) AS TotalQty
FROM Sales.ProductSales
GROUP BY ROLLUP(Category,Subcategory, Product);

--Exercises:

CREATE VIEW SalesLT.vCustGroups AS
SELECT AddressID, CHOOSE(AddressID % 3 + 1, N'A', N'B', N'C') AS custgroup, CountryRegion
FROM SalesLT.Address;

go

CREATE VIEW SalesLT.vCustomerSales AS 
SELECT Customer.CustomerID, Customer.CompanyName, Customer.SalesPerson, SalesOrderHeader.TotalDue 
FROM SalesLT.Customer 
INNER JOIN SalesLT.SalesOrderHeader 
    ON Customer.CustomerID = SalesOrderHeader.CustomerID;


go

SELECT CountryRegion, p.A, p.B, p.C
FROM SalesLT.vCustGroups PIVOT (
        COUNT(AddressID) FOR custgroup IN (A, B, C)
) AS p;

go

SELECT SalesPerson, CompanyName, SUM(TotalDue) AS TotalSales
FROM SalesLT.vCustomerSales
    GROUP BY ROLLUP (SalesPerson, CompanyName);

SELECT * 
FROM 
(
    SELECT P.ProductID, PC.Name, ISNULL(P.Color, 'Uncolored') AS Color 
    FROM Saleslt.ProductCategory AS PC 
    JOIN SalesLT.Product AS P 
        ON PC.ProductCategoryID = P.ProductCategoryID
) AS PPC PIVOT(
    COUNT(ProductID) FOR Color IN(
        [Red], [Blue], [Black], [Silver], [Yellow], 
        [Grey], [Multi], [Uncolored]
    )
) AS pvt 
    ORDER BY Name;

SELECT CompanyName, SalesPerson, SUM(TotalDue) AS TotalSales
FROM SalesLT.vCustomerSales
    GROUP BY CUBE (CompanyName, SalesPerson);

