

use AdventureWorks2019;

-- A subquery is a SELECT statement nested within another query. 

/*
A subquery is a SELECT statement nested, or embedded, within another query. 
The nested query, which is the subquery, is referred to as the inner query.

The purpose of a subquery is to return results to the outer query. The form 
of the results will determine whether the subquery is a scalar or multi-valued subquery:

Scalar subqueries return a single value. Outer queries must process a single result.
Multi-valued subqueries return a result much like a single-column table. Outer queries must be able to process 
multiple values.

Self-contained: subqueries can be written as stand-alone queries, with no dependencies on the outer query. 
A self-contained subquery is processed once, when the outer query runs and passes its results to that outer query.

Correlated subqueries: reference one or more columns from the outer query and therefore depend on it. 
Correlated subqueries cannot be run separately from the outer query.
*/

/*
Scalar subqueries may be used anywhere in an outer T-SQL statement where a single-valued expression is permitted—such as in a SELECT clause, a WHERE clause, a HAVING clause, or even a FROM clause. 
They can also be used in data modification statements, such as UPDATE or DELETE.


The inner query should generally return a single column. Selecting multiple columns in a subquery is almost always an error. The only exception is if the subquery is introduced with the EXISTS keyword.

--https://learn.microsoft.com/en-us/training/modules/write-subqueries/3-scalar-multi-values-subqueries
*/

SELECT SalesOrderID, ProductID, OrderQty
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 
   (SELECT MAX(SalesOrderID)
    FROM Sales.SalesOrderHeader);

SELECT SalesOrderID, ProductID, OrderQty,
    (SELECT AVG(OrderQty)
     FROM SalesLT.SalesOrderDetail) AS AvgQty
FROM SalesLT.SalesOrderDetail
WHERE SalesOrderID = 
    (SELECT MAX(SalesOrderID)
     FROM SalesLT.SalesOrderHeader);


/*
Multi-valued subqueries
A multi-valued subquery is well suited to return results using the IN operator. 

*/

SELECT CustomerID, SalesOrderID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Sales.Customer
    WHERE CountryRegion = 'Canada');


--										
										----  joins vs subquries ----
 
 --***** if you need to return columns from both tables, you should write the query using a JOIN.
 --***** subqueries work best for complicated processing because it allows you to break down the processing into smaller steps.



 -- Correlated subqueries may also be either scalar or multi-valued subqueries. 
 --They're typically used when the inner query needs to reference a value in the outer query.

 /*
 --Correlated subqueries cannot be executed separately from the outer query. 
 This restriction complicates testing and debugging.
--Unlike self-contained subqueries, which are processed once, 
correlated subqueries will run multiple times. Logically, the outer query 
runs first, and for each row returned, the inner query is processed.

 */

 SELECT SalesOrderID, CustomerID, OrderDate
FROM SalesLT.SalesOrderHeader AS o1
WHERE SalesOrderID =
    (SELECT MAX(SalesOrderID)
     FROM SalesLT.SalesOrderHeader AS o2
     WHERE o2.CustomerID = o1.CustomerID) -- compare with outer query
ORDER BY CustomerID, OrderDate;

-- exist the rows of inner query which needs outer query
SELECT CustomerID, CompanyName, EmailAddress 
FROM Sales.Customer AS c 
WHERE EXISTS
(SELECT * 
  FROM Sales.SalesOrderHeader AS o
  WHERE o.CustomerID = c.CustomerID);

-- customer who never placed an order
SELECT CustomerID, CompanyName, EmailAddress 
FROM SalesLT.Customer AS c 
WHERE NOT EXISTS
  (SELECT * 
   FROM SalesLT.SalesOrderHeader AS o
   WHERE o.CustomerID = c.CustomerID);


