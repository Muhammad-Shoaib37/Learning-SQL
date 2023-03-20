
-- use database for a session
use SalesDB;

--create tables
CREATE TABLE Products  
(ProductID int PRIMARY KEY NOT NULL,  
ProductName varchar(50) NOT NULL,  
ProductDescription varchar(max) NOT NULL);

--insert data
INSERT Products (ProductID, ProductName, ProductDescription)  
    VALUES (1, 'The brown fox and the yellow bear', 'A popular book for children.');

--query data from table directly
SELECT ProductName, ProductDescription
    FROM Products;

--create a view

/*
Views are saved queries that you can create in your databases. A single view can reference one or more tables.
And, just like a table, a view consists of rows and columns of data. 
You can use views as a source for your queries in much the same way as tables

*/

go
CREATE VIEW sales.CustOrders
AS
SELECT
  O.custid, 
  DATEADD(month, DATEDIFF(month, 0, O.orderdate), 0) AS ordermonth,
  SUM(OD.qty) AS qty
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY custid, DATEADD(month, DATEDIFF(month, 0, O.orderdate), 0);

--query a view 
SELECT custid, ordermonth, qty
FROM Sales.CustOrders;

-- create local and global temp tables

--local
CREATE TABLE #Products (
    ProductID INT PRIMARY KEY,
    ProductName varchar,
    ...
);
--global
CREATE TABLE ##Products (
    ProductID INT PRIMARY KEY,
    ProductName varchar,
    ...
);


INSERT #Products (ProductID, ProductName, ProductDescription)  
    VALUES (1, 'The temporary time leap', 'A novel about temporary time leaping.');

SELECT *  
FROM #Products  
ORDER BY ProductName;

		------- CTE: Common Table Expression ----------

--Common Table Expressions (CTEs) provide a mechanism for you to define a subquery that may then be
--used elsewhere in a query. Unlike a derived table, a CTE is defined at the beginning of a query and
--may be referenced multiple times in the outer query.

/*
CTEs are named expressions defined in a query. Like subqueries and derived tables, CTEs provide a means
to break down query problems into smaller, more modular units. CTEs are limited in scope to the execution
of the outer query. When the outer query ends, so does the CTE's lifetime.
*/

WITH CTE_year 
AS
(
    SELECT YEAR(orderdate) AS orderyear, custid
    FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS cust_count
FROM CTE_year
GROUP BY orderyear;

--						------------ Derived Tables --------------

-- helping you to break down complex queries into more manageable parts.
-- Unlike subqueries, you write derived tables using a named expression that is logically equivalent to a
--table and may be referenced as a table elsewhere in the outer query.

--A derived table is created at the time of execution of the outer query and goes out of scope when the outer query ends. 

SELECT orderyear, COUNT(DISTINCT custid) AS cust_count
FROM (SELECT YEAR(orderdate) AS orderyear, custid
    FROM Sales.Orders) AS derived_year
GROUP BY orderyear;

--pass args

DECLARE @emp_id INT = 9; --declare and assign the variable
SELECT orderyear, COUNT(DISTINCT custid) AS cust_count
FROM (    
    SELECT YEAR(orderdate) AS orderyear, custid
    FROM Sales.Orders
    WHERE empid=@emp_id --use the variable to pass a value to the derived table query
) AS derived_year
GROUP BY orderyear;
GO




--Exercises:

SELECT ProductID, Name, ListPriceFROM SalesLT.ProductWHERE ProductCategoryID = 6;go

CREATE VIEW SalesLT.vProductsRoadBikes ASSELECT ProductID, Name, ListPriceFROM SalesLT.Product
WHERE ProductCategoryID = 6;GO

SELECT ProductID, Name, ListPriceFROM SalesLT.vProductsRoadBikes
WHERE ListPrice < 1000;goSELECT ProductID, Name, ListPrice,      
CASE WHEN ListPrice > 1000 THEN N'High' ELSE N'Normal' END AS PriceTypeFROM SalesLT.Product;go


SELECT DerivedTable.ProductID, DerivedTable.Name, DerivedTable.ListPriceFROM    (        
SELECT ProductID, Name, ListPrice,        CASE WHEN ListPrice > 1000 THEN N'High' 
ELSE N'Normal' END AS PriceType        FROM SalesLT.Product    ) AS DerivedTable
WHERE DerivedTable.PriceType = N'High';go

create view citycustomer as select AddressLine1, city, StateProvince, CountryRegion from SalesLT.Address 
where CountryRegion = 'Canada';go select * from citycustomer;GO


select ProductID, Name, Weight, ListPrice,case when Weight > 1000 then 'Heavy' else 'Normal' end as 

WeightType from SalesLT.Product; GO

select derived.ProductID, derived.Name, derived.Weight, derived.ListPrice  from  (    

select ProductID, Name, Weight, ListPrice,case when Weight > 1000 then 'Heavy' else 'Normal' end as 

WeightType from SalesLT.Product) as derivedwhere derived.WeightType='Heavy'
