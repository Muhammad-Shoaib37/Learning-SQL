
use AdventureWorks2019;

-- Built-In Functions: 
/*
Scalar

Operate on a single row, return a single value.

Logical

Compare multiple values to determine a single output.

Ranking

Operate on a partition (set) of rows.

Rowset

Return a virtual table that can be used in a FROM clause in a T-SQL statement.

Aggregate

Take one or more input values, return a single summarizing value.


*/

/*

Configuration functions
Conversion functions
Cursor functions
Date and Time functions
Mathematical functions
Metadata functions
Security functions
String functions
System functions
System Statistical functions
Text and Image functions

*/

--								Scalar Functions

-- return single value

--date functions:
SELECT  SalesOrderID,
    OrderDate,
        YEAR(OrderDate) AS OrderYear,
        DATENAME(mm, OrderDate) AS OrderMonth,
        DAY(OrderDate) AS OrderDay,
        DATENAME(dw, OrderDate) AS OrderWeekDay,
        DATEDIFF(yy,OrderDate, GETDATE()) AS YearsSinceOrder
FROM Sales.SalesOrderHeader;

--maths functions
SELECT TaxAmt,
       ROUND(TaxAmt, 0) AS Rounded,
       FLOOR(TaxAmt) AS Floor,
       CEILING(TaxAmt) AS Ceiling,
       SQUARE(TaxAmt) AS Squared,
       SQRT(TaxAmt) AS Root,
       LOG(TaxAmt) AS Log,
       TaxAmt * RAND() AS Randomized
FROM Sales.SalesOrderHeader;

--string functions
SELECT  CompanyName,
        UPPER(CompanyName) AS UpperCase,
        LOWER(CompanyName) AS LowerCase,
        LEN(CompanyName) AS Length,
        REVERSE(CompanyName) AS Reversed,
        CHARINDEX(' ', CompanyName) AS FirstSpace,
        LEFT(CompanyName, CHARINDEX(' ', CompanyName)) AS FirstWord,
        SUBSTRING(CompanyName, CHARINDEX(' ', CompanyName) + 1, LEN(CompanyName)) AS RestOfName
FROM Sales.Customer as c;

--logical functions: The IIF function evaluates a Boolean input expression, and returns a specified value 
--if the expression evaluates to True, and an alternative value if the expression evaluates to False.

SELECT AddressType,
      IIF(AddressType = 'Main Office', 'Billing', 'Mailing') AS UseAddressFor
FROM Sales.CustomerAddress;

SELECT SalesOrderID, Status,
CHOOSE(Status, 'Ordered', 'Shipped', 'Delivered') AS OrderStatus
FROM Sales.SalesOrderHeader;


--								Ranking and rowset Functions
-- Ranking functions
--Ranking functions allow you to perform calculations against a user-defined set of rows. 
--These functions include ranking, offset, aggregate, and distribution functions.

SELECT TOP 100 ProductID, Name, ListPrice,
RANK() OVER(ORDER BY ListPrice DESC) AS RankByPrice
FROM Production.Product AS p
ORDER BY RankByPrice;

--********* Over clasue: You can use the OVER clause to define partitions, or groupings within the data. 

SELECT c.Name AS Category, p.Name AS Product, ListPrice,
  RANK() OVER(PARTITION BY c.Name ORDER BY ListPrice DESC) AS RankByPrice
FROM Production.Product AS p
JOIN Production.ProductCategory AS c
ON p.ProductSubcategoryID = c.ProductcategoryID
ORDER BY Category, RankByPrice;


-- ****** Rowset

-- Rowset functions return a virtual table that can be used in the FROM clause as a data source. 
--These functions take parameters specific to the rowset function itself.
--They include OPENDATASOURCE, OPENQUERY, OPENROWSET, OPENXML, and OPENJSON.


--The OPENDATASOURCE, OPENQUERY, and OPENROWSET functions enable you to pass a query to
--a remote database server. The remote server will then return a set of result rows.

SELECT a.*
FROM OPENROWSET('SQLNCLI', 'Server=SalesDB;Trusted_Connection=yes;',
    'SELECT Name, ListPrice
    FROM AdventureWorks.Production.Product') AS a;


-- ****** The OPENXML and OPENJSON: 
--functions enable you to query structured data in XML or JSON format and extract values into a tabular rowset.


--										Aggregate Functions

/* 
Aggregate functions in a SELECT list operate on all rows passed to the SELECT operation.
If there is no GROUP BY clause, all rows satisfying any filter in the WHERE clause will be summarized. 
You will learn more about GROUP BY in the next topic.
Unless you're using GROUP BY, you shouldn't combine aggregate functions with columns not included in 
functions in the same SELECT list
*/

-- Aggregate functions ignore NULLs, except when using COUNT(*).

--Aggregate functions return a single (scalar) value and can be used in SELECT statements almost anywhere a single value can be used.

-- %%%%% To extend beyond the built-in functions, SQL Server provides a mechanism for user-defined aggregate functions 
--via the .NET Common Language Runtime (CLR).

SELECT AVG(ListPrice) AS AveragePrice,
       MIN(ListPrice) AS MinimumPrice,
       MAX(ListPrice) AS MaximumPrice
FROM Production.Product;

SELECT SUM(c2) AS sum_nonnulls, 
    COUNT(*) AS count_all_rows, 
    COUNT(c2) AS count_nonnulls, 
    AVG(c2) AS average, 
    (SUM(c2)/COUNT(*)) AS arith_average
FROM t1;

--											Group By
--GROUP BY creates groups and places rows into each group as determined by the elements specified in the clause.

SELECT CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

SELECT CustomerID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

SELECT CustomerID AS Customer,
       COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY Customer;


--												error in group by:

--The following query will return an error because 
--PurchaseOrderNumber isn't part of the GROUP BY, and it isn't used with an aggregate function.
SELECT CustomerID, PurchaseOrderNumber, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

--correction:
SELECT CustomerID, PurchaseOrderNumber, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, PurchaseOrderNumber;

-- Having: When you have created groups with a GROUP BY clause, you can further filter the results.
--The HAVING clause acts as a filter on groups. This is similar to the way that the WHERE clause acts
--as a filter on rows returned by the FROM clause.


SELECT CustomerID,
      COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(*) > 10;

-where vs having: A HAVING clause is processed after GROUP BY and only operates on groups, not detail rows. To summarize:

--A WHERE clause filters rows before any groups are formed
--A HAVING clause filters entire groups, and usually looks at the results of an aggregation.

/*
Order of query exection:

The clauses in a SELECT statement are applied in the following order:

FROM
WHERE

GROUP BY
HAVING

SELECT
ORDER BY

*/